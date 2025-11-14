# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

OPENSEARCH_JAVA_VER=21

inherit systemd tmpfiles verify-sig

MY_PN="${PN%-bin}"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Open source distributed and RESTful search engine"
HOMEPAGE="https://docs.opensearch.org/latest/"
SRC_URI="
	amd64? ( https://artifacts.opensearch.org/releases/bundle/${MY_PN}/${PV}/${MY_P}-linux-x64.tar.gz )
	arm64? ( https://artifacts.opensearch.org/releases/bundle/${MY_PN}/${PV}/${MY_P}-linux-arm64.tar.gz )
	verify-sig? (
		amd64? ( https://artifacts.opensearch.org/releases/bundle/${MY_PN}/${PV}/${MY_P}-linux-x64.tar.gz.sig )
		arm64? ( https://artifacts.opensearch.org/releases/bundle/${MY_PN}/${PV}/${MY_P}-linux-arm64.tar.gz.sig )
	)
"

S="${WORKDIR}/${MY_P}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="verify-sig"
RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/${MY_PN}-env-r2.patch"
)

BDEPEND="verify-sig? ( sec-keys/openpgp-keys-opensearch-release )"

RDEPEND="
	!dev-db/opensearch
	acct-group/opensearch
	acct-user/opensearch
	virtual/zlib
	virtual/jre:${OPENSEARCH_JAVA_VER}
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/opensearch-release.gpg

src_prepare() {
	default
	rm -rf jdk || die
	sed -i -e "s:logs/:/var/log/${MY_PN}/:g" config/jvm.options || die
	rm LICENSE.txt NOTICE.txt || die
	rmdir logs || die
}

src_install() {
	keepdir /etc/${MY_PN}
	keepdir /etc/${MY_PN}/scripts

	insinto /etc/${MY_PN}
	doins -r config/.
	rm -r config || die

	fowners -R root:${MY_PN} /etc/${MY_PN}

	find "${ED}"/etc/${MY_PN} -type d -exec chmod 2770 {} +
	find "${ED}"/etc/${MY_PN} -type f -exec chmod 660 {} +

	insinto /usr/share/${MY_PN}
	doins -r .

	keepdir /usr/share/${MY_PN}/plugins
	keepdir /usr/share/${MY_PN}/extensions

	exeinto /usr/share/${MY_PN}/bin
	doexe "${FILESDIR}/${MY_PN}-systemd-pre-exec"

	fperms -R +x /usr/share/${MY_PN}/bin

	keepdir /var/{lib,log}/${MY_PN}
	fowners ${MY_PN}:${MY_PN} /var/{lib,log}/${MY_PN}
	fperms 0750 /var/{lib,log}/${MY_PN}

	insinto /etc/sysctl.d
	newins "${FILESDIR}/${MY_PN}.sysctl.d" ${MY_PN}.conf

	newconfd "${FILESDIR}/${MY_PN}.conf.5" ${MY_PN}
	newinitd "${FILESDIR}/${MY_PN}.init.9" ${MY_PN}

	systemd_install_serviced "${FILESDIR}/${MY_PN}.service.conf"
	systemd_newunit "${FILESDIR}"/${MY_PN}.service.4 ${MY_PN}.service

	dosym ../../../etc/opensearch /usr/share/opensearch/config
	dosym ../../../var/log/opensearch /usr/share/opensearch/logs
	dosym ../../../var/lib/opensearch /usr/share/opensearch/data

	sed -i "s/^OPENSEARCH_JAVA_VER=XXX/OPENSEARCH_JAVA_VER=${OPENSEARCH_JAVA_VER}/" "${ED}"/usr/share/${MY_PN}/bin/opensearch-env "${ED}"/etc/conf.d/${MY_PN} || die "Could not set OPENSEARCH_JAVA_VER"

	newtmpfiles "${FILESDIR}"/${MY_PN}.tmpfiles.d ${MY_PN}.conf
}

pkg_postinst() {
	# Elasticsearch will choke on our keep file and dodir will not preserve the empty dir
	rm /usr/share/${MY_PN}/plugins/.keep* || die
	tmpfiles_process /usr/lib/tmpfiles.d/${MY_PN}.conf
	if [ ! systemd_is_booted ]; then
		elog "You may create multiple instances of ${MY_PN} by"
		elog "symlinking the init script:"
		elog "ln -sf /etc/init.d/${MY_PN} /etc/init.d/${MY_PN}.instance"
		elog
		elog "Please make sure you put ${MY_PN}.yml, log4j2.properties and scripts"
		elog "from /etc/${MY_PN} into the configuration directory of the instance:"
		elog "/etc/${MY_PN}/instance"
		elog
	fi
	ewarn "Please make sure you have proper permissions on /etc/${MY_PN}"
	ewarn "prior to keystore generation or you may experience startup failures."
	ewarn "chown root:${MY_PN} /etc/${MY_PN} && chmod 2750 /etc/${MY_PN}"
	ewarn "chown root:${MY_PN} /etc/${MY_PN}/${MY_PN}.keystore && chmod 0660 /etc/${MY_PN}/${MY_PN}.keystore"
}

pkg_config() {
	local opensearch_admin

	einfo "Running the demo-cluster-setup script."
	einfo
	einfo "WARNING: this configuration is not recommended for production;"
	einfo "review /etc/${MY_PN}/opensearch.yml and .../opensearch-security/"
	einfo "and replace demo certificates with real ones."
	einfo
	einfo "Enter password for opensearch admin: "
	read -p "    >" opensearch_admin

	einfo "About to run opensearch-tar-install.sh to configure."
	einfo "Once output stops scrolling, run from another terminal:"
	einfo
	einfo "  curl -X GET https://localhost:9200/_cat/plugins?v -u 'admin:${opensearch_admin}' --insecure"
	einfo
	einfo "Once you see a list of components and versions, you can ^C here."
	einfo
	einfo "Hit enter to continue, ^C to cancel."
	read

	su -s /bin/bash -c "OPENSEARCH_INITIAL_ADMIN_PASSWORD='${opensearch_admin}' /bin/bash /usr/share/opensearch/opensearch-tar-install.sh" opensearch
}
