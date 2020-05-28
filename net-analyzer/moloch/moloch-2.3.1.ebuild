# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic systemd

DESCRIPTION="Open source, large scale, full packet capturing, indexing, and database system"
HOMEPAGE="https://molo.ch https://github.com/aol/moloch"
SRC_URI="https://github.com/aol/moloch/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="+capture parliament test +viewer wise"
# test is wip
# network required for npm :(
# see other npm-based ebuild such as www-apps/mattermost-server in chaoslab
RESTRICT="mirror network-sandbox test"

RDEPEND="parliament? ( net-libs/nodejs )
		viewer? ( net-libs/nodejs )
		wise? ( net-libs/nodejs )
		dev-libs/glib:2
		app-forensics/yara
		dev-libs/libmaxminddb
		net-libs/libpcap[static-libs]
		net-misc/curl
		dev-lang/lua
		net-libs/daq
		dev-libs/libyaml
		dev-perl/HTTP-Message
		dev-perl/libwww-perl
		dev-perl/JSON"
DEPEND="${RDEPEND}
		>=net-libs/nodejs-8.12.0[npm]
		test? ( dev-perl/Test-Differences )"

src_prepare() {
	# unknown crashes
	filter-flags -funroll-loops

	# bad alignment on arm
	append-cflags $(test-flags-CC -fno-strict-aliasing)
	append-cxxflags $(test-flags-CXX -fno-strict-aliasing)

	# creates longs beyond max size
	filter-flags -flto*

	# misc nodejs compat issues

	# bump sqlite3 to 4.1.1
	sed -i "s/\"sqlite3\": \"^4.0.2\"/\"sqlite3\": \"^4.2.0\"/g" "package.json" || die

	# swap unmaintained unzip to unzipper to fix too-old graceful-fs
	sed -i "s/\"unzip\": \"^0\.1\.11\"/\"unzipper\": \"0\.10\.11\"/g" "package.json" || die
	sed -i "s/require('unzip')/require('unzipper')/g" wiseService/source.{threatq,threatstream}.js viewer/viewer.js || die

	npm install --package-lock-only || die
	# https://stackoverflow.com/a/15483897
	npm cache verify || die

	# bump fs-ext to 2.0.0
	sed -i "s/0\.5\.0/2\.0\.0/g" "viewer/package.json" || die
	npm -C "viewer" install --package-lock-only || die

	# https://github.com/mapbox/node-sqlite3/issues/474#issuecomment-120057820
	# https://github.com/nodejs/node-gyp/issues/1236
	sed -i "s/npm ci/npm ci --unsafe-perm/g" "Makefile.am" \
		{parliament,viewer,wiseService}/Makefile.in || die

	sed -i "s/release //g" "Makefile.am" || die
	use capture || sed -i "s/capture //g" "Makefile.am"
	use parliament || sed -i "s/parliament //g" "Makefile.am"
	use test || sed -i "s/tests //g" "Makefile.am"
	use viewer || sed -i "s/viewer //g" "Makefile.am"
	use wise || sed -i "s/wiseService //g" "Makefile.am"

	eautoreconf

	default
}

src_configure() {
	# because the makefiles respect the INSTALL environment variable,
	# which points to the portage helper, to install files, they
	# are able to bypass the sandbox and write directly to the
	# filesystem.  this should keep their paws off, and the cost
	# of having to write all the install functions manually in
	# src_install.
	mkdir -vp "${S}/pre-image"/{bin,lib}
	econf --with-yara="${EROOT}/usr" --with-libpcap="${EROOT}/usr" \
		--prefix="${S}/pre-image/lib" --exec-prefix="${S}/pre-image/bin"
}

src_install() {
	default

	# should writer-s3 plugin be built here?

	dodir "${EROOT}/var/log/moloch"
	keepdir "${EROOT}/var/log/moloch"
	fowners nobody:daemon "${EROOT}/var/log/moloch"

	use capture && dobin "capture/moloch-capture"

	exeinto "${EROOT}/usr/lib/moloch"
	doexe "capture/plugins/taggerUpload.pl"
	doexe "${FILESDIR}/moloch_add_user.sh"
	doexe "${FILESDIR}/moloch_update_geo.sh"

	insinto "${EROOT}/etc/moloch"
	doins "release/config.ini.sample"
	doins "release/wise.ini.sample"

	for f in capture parliament viewer wise
	do
		if use "$f"
		then
			newconfd "${FILESDIR}/moloch-$f.confd" "moloch-$f"
			newinitd "${FILESDIR}/moloch-$f.init.d" "moloch-$f"
			systemd_dounit "${FILESDIR}/moloch-$f.service"
		fi
	done

	use capture && doheader "capture/"*.h

	insinto "${EROOT}/usr/lib/moloch"
	doins "pre-image/lib/package.json"
	doins -r "pre-image/lib/node_modules"
	doins -r "pre-image/lib/notifiers"
	use parliament && doins -r "pre-image/lib/parliament"
	use viewer && doins -r "pre-image/lib/viewer"
	use wise && doins -r "pre-image/lib/wiseService"

	exeinto "${EROOT}/usr/lib/moloch/db"
	doexe "pre-image/lib/db/db.pl"
	doexe "pre-image/lib/db/daily.sh"

	insinto "${EROOT}/usr/lib/moloch/lua"
	doins "capture/plugins/lua/samples/"*.lua

	insinto "${EROOT}/usr/lib/moloch/parsers"
	doins "capture/parsers/"*.jade
	insinto "${EROOT}/etc/security/limits.d"
	doins "${FILESDIR}/99-moloch.conf"
	insinto "${EROOT}/usr/lib/moloch/plugins"
	doins "capture/plugins/"*.jade
	doins "capture/plugins/"*.js

	if use capture
	then
		insopts "-m755"
		insinto "${EROOT}/usr/lib/moloch/parsers"
		doins "capture/parsers/"*.so
		insinto "${EROOT}/usr/lib/moloch/plugins"
		doins "capture/plugins/"*.so
	fi
}

src_test() {
	# test pcap parser
	cd "tests/"
	perl "./tests.pl" --make || die
	perl "./tests.pl" || die

	# test viewer apis
	# this requires a live elasticsearch instance!
	# perl tests/tests.pl --viewer || die
}

pkg_postinst() {
	einfo "It's recommended to turn off advanced features on your packet ingestion interfaces"
	einfo "https://github.com/aol/moloch/wiki/FAQ#moloch-requires-full-packet-captures-error"
	einfo "You can do this using sys-apps/ethtool like so:"
	einfo
	einfo "ethtool -G \$interface rx 4096 tx 4096"
	einfo "for i in rx tx sg tso ufo gso gro lro ; do"
	einfo "	ethtool -K \$interface \$i off ; done"
	einfo
	einfo "To initialize Elasticsearch:"
	einfo "${EROOT}/usr/lib/moloch/db/db.pl http://ESHOST:9200 init"
	einfo
	einfo "To upgrade Elasticsearch:"
	einfo "${EROOT}/usr/lib/moloch/db/db.pl http://ESHOST:9200 upgrade"
	einfo
	einfo "Add an admin user (this is required to log in after install!):"
	einfo "${EROOT}/usr/lib/moloch/moloch_add_user.sh admin \"Admin User\" THEPASSWORD --admin"
	einfo
	einfo "Update geolocation databases:"
	einfo "${EROOT}/usr/lib/moloch/moloch_update_geo.sh"
}
