# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd tmpfiles

DESCRIPTION="Open source distributed and RESTful search engine"
HOMEPAGE="https://opensearch.org/docs/opensearch/index/"
SRC_URI="amd64? ( https://artifacts.opensearch.org/releases/bundle/${PN}/${PV}/${P}-linux-x64.tar.gz )
	arm64? ( https://artifacts.opensearch.org/releases/bundle/${PN}/${PV}/${P}-linux-arm64.tar.gz )"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/${PN}-env.patch"
)

DEPEND="acct-group/opensearch
		acct-user/opensearch"

RDEPEND="acct-group/opensearch
		acct-user/opensearch
		sys-libs/zlib
		virtual/jre:17"

src_prepare() {
	default
	rm -rf jdk || die
	sed -i -e "s:logs/:/var/log/${PN}/:g" config/jvm.options || die
	rm LICENSE.txt NOTICE.txt || die
	rmdir logs || die
}

src_install() {
	keepdir /etc/${PN}
	keepdir /etc/${PN}/scripts

	insinto /etc/${PN}
	doins -r config/.
	rm -r config || die

	fowners -R root:${PN} /etc/${PN}
	fperms -R 2750 /etc/${PN}

	insinto /usr/share/${PN}
	doins -r .

	keepdir /usr/share/${PN}/plugins

	exeinto /usr/share/${PN}/bin
	doexe ${FILESDIR}/${PN}-systemd-pre-exec

	fperms -R +x /usr/share/${PN}/bin

	keepdir /var/{lib,log}/${PN}
	fowners ${PN}:${PN} /var/{lib,log}/${PN}
	fperms 0750 /var/{lib,log}/${PN}

	insinto /etc/sysctl.d
	newins "${FILESDIR}/${PN}.sysctl.d" ${PN}.conf

	newconfd "${FILESDIR}/${PN}.conf.4" ${PN}
	newinitd "${FILESDIR}/${PN}.init.8" ${PN}

	systemd_install_serviced "${FILESDIR}/${PN}.service.conf"
	systemd_newunit "${FILESDIR}"/${PN}.service.4 ${PN}.service

	newtmpfiles "${FILESDIR}"/${PN}.tmpfiles.d ${PN}.conf
}

pkg_postinst() {
	# Elasticsearch will choke on our keep file and dodir will not preserve the empty dir
	rm /usr/share/${PN}/plugins/.keep* || die
	tmpfiles_process /usr/lib/tmpfiles.d/${PN}.conf
	if [ ! systemd_is_booted ]; then
		elog "You may create multiple instances of ${PN} by"
		elog "symlinking the init script:"
		elog "ln -sf /etc/init.d/${PN} /etc/init.d/${PN}.instance"
		elog
		elog "Please make sure you put ${PN}.yml, log4j2.properties and scripts"
		elog "from /etc/${PN} into the configuration directory of the instance:"
		elog "/etc/${PN}/instance"
		elog
	fi
	ewarn "Please make sure you have proper permissions on /etc/${PN}"
	ewarn "prior to keystore generation or you may experience startup failures."
	ewarn "chown root:${PN} /etc/${PN} && chmod 2750 /etc/${PN}"
	ewarn "chown root:${PN} /etc/${PN}/${PN}.keystore && chmod 0660 /etc/${PN}/${PN}.keystore"
}
