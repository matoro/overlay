# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-3 lua5-4 )
inherit autotools systemd lua-single toolchain-funcs flag-o-matic pam

DESCRIPTION="Open source, large scale, full packet capturing, indexing, and database system"
HOMEPAGE="https://arkime.com https://github.com/arkime/arkime"
SRC_URI="https://github.com/arkime/arkime/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	viewer? ( https://github.com/gchq/CyberChef/releases/download/v10.5.2/CyberChef_v10.5.2.zip )"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE="+capture +viewer +parliament +wise +cont3xt pfring daq test netlink lua"
REQUIRED_USE="lua? ( ${LUA_REQUIRED_USE} ) pfring? ( capture ) daq? ( capture ) netlink? ( capture ) lua? ( capture )"
RESTRICT="mirror viewer? ( network-sandbox ) parliament? ( network-sandbox ) wise? ( network-sandbox ) cont3xt? ( network-sandbox )"
QA_PREBUILT="usr/lib/${PN}/node_modules/* usr/lib/${PN}/*/node_modules/*"

DEPEND="
	capture? (
		lua? ( ${LUA_DEPS} )
		test? (
			virtual/perl-Test-Simple
			dev-perl/Test-Differences
			dev-perl/URI
			virtual/perl-Test-Harness
			dev-perl/Socket6
		)
	)
	viewer? ( >=net-libs/nodejs-16.20.2[npm] <net-libs/nodejs-19:=[npm] )
	parliament? ( >=net-libs/nodejs-16.20.2[npm] )
	wise? ( >=net-libs/nodejs-16.20.2[npm] )
"

RDEPEND="${DEPEND}
	capture? (
		>=dev-libs/glib-2.72.4:2
		>=app-forensics/yara-4.0.2:=
		>=dev-libs/libmaxminddb-1.4.3
		!pfring? ( >=net-libs/libpcap-1.10.4 )
		>=net-misc/curl-7.78.0
		>=net-libs/nghttp2-1.44.0
		>=app-arch/zstd-1.5.2
		sys-apps/file
		dev-libs/libpcre
		sys-apps/util-linux
		dev-libs/libyaml
		dev-libs/openssl
		lua? ( $(lua_gen_cond_dep '>=dev-lang/lua-5.3.6[${LUA_USEDEP}]' 'lua5-3') )
		pfring? ( net-libs/libpfring )
		daq? ( >=net-libs/daq-2.0.7 )
		netlink? ( dev-libs/libnl:3 )
		dev-perl/HTTP-Message
		dev-perl/libwww-perl
		dev-perl/JSON
		virtual/perl-MIME-Base64
		virtual/perl-Data-Dumper
		virtual/perl-IO-Compress
	)
	viewer? ( >=net-libs/nodejs-16.20.2 <net-libs/nodejs-19:= )
	parliament? ( >=net-libs/nodejs-16.20.2 )
	wise? ( >=net-libs/nodejs-16.20.2 )
"

src_prepare() {
	default

	if use capture; then
		for datafile in \
			ipv4-address-space.csv \
			oui.txt \
			GeoLite2-Country.mmdb \
			GeoLite2-ASN.mmdb
		do
			if use test; then
				ln -sv "${FILESDIR}/${datafile}" "tests/${datafile}" || die
			fi
		done

		local deps=( yara libmaxminddb gio-2.0 gobject-2.0 gthread-2.0 glib-2.0 gmodule-2.0 libcurl libmagic libnghttp2 )
		use pfring && deps+=( pfring ) || deps+=( libpcap )
		use netlink && deps+=( libnl )
		use lua && deps+=( lua )
		for dep in ${deps[@]}
		do
			append-cflags $($(tc-getPKG_CONFIG) --cflags "${dep}")
			append-libs $($(tc-getPKG_CONFIG) --libs "${dep}")
		done

		sed -i \
			-e 's/gcc/$(CC)/g' \
			-e 's/INCLUDE_OTHER = /INCLUDE_OTHER = $(CFLAGS) /g' \
			tests/plugins/Makefile.in || die

		find . -name 'Makefile.in' | xargs sed -i 's/@prefix@/$(DESTDIR)@prefix@/g' || die

		tc-export CC
		CFLAGS="" LDFLAGS="" eautoreconf
	fi

	for f in viewer cont3xt wiseService parliament; do
		sed -i \
			-e "s/JSON.stringify(git('describe --tags'))/\'\"Gentoo ${PVR}\"\'/g" "${f}/vueapp/build/webpack.prod.conf.js" \
			-e "s/JSON.stringify(git('log -1 --format=%aI'))/\'\"$(date --iso-8601=seconds)\"\'/g" "${f}/vueapp/build/webpack.prod.conf.js" \
			|| die
	done
}

src_configure() {
	use capture && econf \
		--with-pfring=no \
		--with-libpcap=no \
		--with-yara=no \
		--with-maxminddb=no \
		$(use_with netlink libnl) \
		--with-glib2=no \
		--with-curl=no \
		--with-lua=no \
		--with-magic=no \
		--with-nghttp2=no \
		--prefix="${EPREFIX}"/usr/lib/${PN}
}


src_compile() {
	if use capture; then
		emake -C capture EXTRA_CFLAGS="${CFLAGS}" EXTRA_LDFLAGS="${LDFLAGS}"

		use lua && emake -C capture/plugins/lua
		use pfring && emake -C capture/plugins/pfring
		use daq && emake -C capture/plugins/daq
	fi
	if use viewer || use parliament || use wise || use cont3xt; then
		npm ci || die
		if use viewer; then (cd viewer && npm ci && NODE_OPTIONS="--openssl-legacy-provider" npm run bundle:min && npm ci --omit=dev) || die ; fi
		if use wise; then (cd wiseService && npm ci && NODE_OPTIONS="--openssl-legacy-provider" npm run bundle:min && npm ci --omit=dev) || die ; fi
		if use parliament; then (cd parliament && npm ci && NODE_OPTIONS="--openssl-legacy-provider" npm run bundle:min && npm ci --omit=dev) || die ; fi
		if use cont3xt; then (cd cont3xt && npm ci && NODE_OPTIONS="--openssl-legacy-provider" npm run bundle:min && npm ci --omit=dev) || die ; fi
		npm ci --omit=dev || die
	fi
}

src_test() {
	if use capture; then (cd tests && ./tests.pl) || die ; fi
	if use viewer || use parliament || use wise || use cont3xt; then
		npm ci || die
	fi
	if use viewer; then (cd viewer && npm ci && npm test) || die ; fi
	if use cont3xt; then (cd cont3xt && npm ci && npm test) || die ; fi
}

src_install() {
	dodir "/usr/lib/${PN}"
	cp -ra "assets" "common" "contrib" "db" "tests" "${ED}/usr/lib/${PN}/" || die

	dosym "../../../etc/${PN}" "/usr/lib/${PN}/etc"
	dodoc "release/README.txt" "LICENSE"

	if use capture; then
		emake -C capture DESTDIR="${ED}" install
		dosym "../lib/${PN}/include" "${EPREFIX}/usr/include/${PN}"
		insinto "/etc/${PN}"
		newins "release/env.example" "capture.env"
		sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkimecapture.systemd.service" || die
		systemd_newunit "release/arkimecapture.systemd.service" "arkimecapture.service"
		newconfd "release/env.example" "arkimecapture"
		newinitd "${FILESDIR}/arkimecapture.init.d" "arkimecapture"
		newpamsecurity "limits.d" "${FILESDIR}/99-${PN}.conf" "99-${PN}.conf"
	fi

	if use viewer || use parliament || use wise || use cont3xt; then
		cp -ra "node_modules" "${ED}/usr/lib/${PN}/" || die
		dostrip -x "/usr/lib/${PN}/node_modules"
	fi

	if use viewer; then
		cp -ra "viewer" "${ED}/usr/lib/${PN}/" || die
		dostrip -x "/usr/lib/${PN}/viewer/node_modules"
		insinto "/etc/${PN}"
		newins "release/env.example" "viewer.env"
		sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkimeviewer.systemd.service" || die
		systemd_newunit "release/arkimeviewer.systemd.service" "arkimeviewer.service"
		newconfd "release/env.example" "arkimeviewer"
		newinitd "${FILESDIR}/arkimeviewer.init.d" "arkimeviewer"
		for archive in ${A[@]}
		do
			if [[ "${archive}" =~ CyberChef_v.*\.zip ]]; then
				insinto "/usr/lib/${PN}/viewer/public"
				newins "${DISTDIR}/${archive}" "$(basename "${archive}")"
			fi
		done
	fi

	if use viewer || use capture; then
		sed -i "s#ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/config.ini.sample" || die
		insinto "/etc/${PN}"
		newins "release/config.ini.sample" "config.ini"
	fi

	if use wise; then
		cp -ra "wiseService" "${ED}/usr/lib/${PN}/" || die
		dostrip -x "/usr/lib/${PN}/wiseService/node_modules"
		insinto "/etc/${PN}"
		newins "release/wise.ini.sample" "wise.ini"
		newins "release/env.example" "wise.env"
		sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkimewise.systemd.service" || die
		systemd_newunit "release/arkimewise.systemd.service" "arkimewise.service"
		newconfd "release/env.example" "arkimewise"
		newinitd "${FILESDIR}/arkimewise.init.d" "arkimewise"
	fi

	if use parliament; then
		cp -ra "parliament" "${ED}/usr/lib/${PN}/" || die
		dostrip -x "/usr/lib/${PN}/parliament/node_modules"
		insinto "/etc/${PN}"
		newins "release/parliament.env.example" "parliament.env"
		newins "parliament/parliament.example.json" "parliament.json"
		sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkimeparliament.systemd.service" || die
		systemd_newunit "release/arkimeparliament.systemd.service" "arkimeparliament.service"
		newconfd "release/parliament.env.example" "arkimeparliament"
		newinitd "${FILESDIR}/arkimeparliament.init.d" "arkimeparliament"
	fi

	if use cont3xt; then
		cp -ra "cont3xt" "${ED}/usr/lib/${PN}/" || die
		dostrip -x "/usr/lib/${PN}/cont3xt/node_modules"
		insinto "/etc/${PN}"
		newins "release/env.example" "conte3xt.env"
		newins "release/cont3xt.ini.sample" "cont3xt.ini"
		sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkimecont3xt.systemd.service" || die
		systemd_newunit "release/arkimecont3xt.systemd.service" "arkimecont3xt.service"
		newconfd "release/env.example" "arkimecont3xt"
		newinitd "${FILESDIR}/arkimecont3xt.init.d" "arkimecont3xt"
	fi

	sed -i -e "s#/usr/sbin/ip#/bin/ip#g" -e "s#/sbin/ethtool#/usr/sbin/ethtool#g" "release/arkime_config_interfaces.sh" || die
	sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkime_update_geo.sh" || die
	sed -i "s#BUILD_ARKIME_INSTALL_DIR#${EPREFIX}/usr/lib/${PN}#g" "release/arkime_add_user.sh" || die
	sed -i "s#/opt/arkime#${EPREFIX}/usr/lib/${PN}#g" "release/arkime_config_interfaces.sh" || die
	exeinto "/usr/lib/${PN}/bin"
	newexe "release/arkime_update_geo.sh" "arkime_update_geo.sh"
	newexe "release/arkime_add_user.sh" "arkime_add_user.sh"
	newexe "release/arkime_config_interfaces.sh" "arkime_config_interfaces.sh"

	dosym "../../../bin/node" "/usr/lib/${PN}/bin/node"
	insinto "/usr/lib/${PN}/etc"
	newins "${FILESDIR}/ipv4-address-space.csv" "ipv4-address-space.csv"
	newins "${FILESDIR}/oui.txt" "oui.txt"
	newins "${FILESDIR}/GeoLite2-ASN.mmdb" "GeoLite2-ASN.mmdb"
	newins "${FILESDIR}/GeoLite2-Country.mmdb" "GeoLite2-Country.mmdb"
}
