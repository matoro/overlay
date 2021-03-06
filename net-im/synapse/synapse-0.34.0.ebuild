# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Matrix reference homeserver"
HOMEPAGE="https://github.com/matrix-org/synapse https://matrix.org"
SRC_URI="https://github.com/matrix-org/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="consent ldap mail postgres saml +sqlite test urlpreview webclient"
# postgres tests run only against prod instance or docker
RESTRICT="mirror postgres? ( test )"

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )
PYTHON_REQ_USE="sqlite(+)?"

inherit distutils-r1 systemd user

REQUIRED_USE="|| ( postgres sqlite )"
RDEPEND=">=dev-python/jsonschema-2.5.1[${PYTHON_USEDEP}]
		>=dev-python/frozendict-1[${PYTHON_USEDEP}]
		>=dev-python/unpaddedbase64-1.1.0[${PYTHON_USEDEP}]
		>=dev-python/canonicaljson-1.1.3[${PYTHON_USEDEP}]
		>=dev-python/signedjson-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/pynacl-1.2.1[${PYTHON_USEDEP}]
		>=dev-python/service_identity-16.0.0[${PYTHON_USEDEP}]
		>=dev-python/twisted-17.1.0[${PYTHON_USEDEP}]
		>=dev-python/treq-15.1[${PYTHON_USEDEP}]
		>=dev-python/pyopenssl-16.0.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-3.11[${PYTHON_USEDEP}]
		>=dev-python/pyasn1-0.1.9[${PYTHON_USEDEP}]
		>=dev-python/pyasn1-modules-0.0.7[${PYTHON_USEDEP}]
		>=dev-python/daemonize-2.3.1[${PYTHON_USEDEP}]
		>=dev-python/bcrypt-3.1.0[${PYTHON_USEDEP}]
		>=dev-python/pillow-3.1.2[${PYTHON_USEDEP},jpeg]
		>=dev-python/sortedcontainers-1.4.4[${PYTHON_USEDEP}]
		>=dev-python/psutil-2.0.0[${PYTHON_USEDEP}]
		>=dev-python/pymacaroons-pynacl-0.9.3[${PYTHON_USEDEP}]
		>=dev-python/msgpack-0.4.2[${PYTHON_USEDEP}]
		>=dev-python/phonenumbers-8.2.0[${PYTHON_USEDEP}]
		>=dev-python/six-1.10[${PYTHON_USEDEP}]
		>=dev-python/prometheus_client-0.0.18[${PYTHON_USEDEP}]
		!>dev-python/prometheus_client-0.4.0[${PYTHON_USEDEP}]
		>=dev-python/attrs-16.0.0[${PYTHON_USEDEP}]
		>=dev-python/netaddr-0.7.18[${PYTHON_USEDEP}]
		ldap? ( >=dev-python/matrix-synapse-ldap3-0.1[${PYTHON_USEDEP}] )
		postgres? ( >=dev-python/psycopg-2.6:2[${PYTHON_USEDEP}] )
		saml? ( >=dev-python/pysaml2-4.5.0[${PYTHON_USEDEP}] )
		urlpreview? ( >=dev-python/lxml-3.5.0[${PYTHON_USEDEP}] )
		webclient? ( >=dev-python/matrix-angular-sdk-0.6.8[${PYTHON_USEDEP}] )
		mail? (
			>=dev-python/jinja-2.9[${PYTHON_USEDEP}]
			>=dev-python/bleach-1.4.2[${PYTHON_USEDEP}]
		)
"

DEPEND="${RDEPEND}
		test? (
			>=dev-python/mock-2.0[${PYTHON_USEDEP}]
		)
"

pkg_setup() {
	enewgroup synapse
	enewuser synapse -1 -1 "/var/lib/synapse" "synapse"
}

python_test() {
	use postgres && SYNAPSE_POSTGRES=True
	"${EPYTHON}" -m twisted.trial -ex tests || die "tests failed under ${EPYTHON}"
}

python_install() {
	distutils-r1_python_install --optimize=1 --skip-build
	dodir \
		/etc/${PN} \
		/var/lib/${PN} \
		/var/log/${PN}
	keepdir \
		/etc/${PN} \
		/var/lib/${PN} \
		/var/log/${PN}
	# systemd_dounit "contrib/systemd/matrix-${PN}.service"
	insinto /etc/${PN}
	doins "contrib/systemd/log_config.yaml"
	fowners ${PN}:${PN} \
		/etc/${PN} \
		/var/lib/${PN} \
		/var/log/${PN}
	fperms 0700 "/var/lib/${PN}"
	fperms 0750 "/var/log/${PN}"
	newinitd "${FILESDIR}/${PN}.init.d" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
}

pkg_postinst() {
	elog
	elog "==> A synapse configuration file needs to be generated before you can"
	elog "    start synapse, and you should make sure that it's readable by the"
	elog "    synapse user."
	elog
	elog "    cd /var/lib/synapse"
	elog "    sudo -u synapse ${EPYTHON} -m synapse.app.homeserver \\"
	elog "      --server-name my.domain.name \\"
	elog "      --config-path ${EROOT}/etc/synapse/homeserver.yaml \\"
	elog "      --generate-config \\"
	elog "      --report-stats=yes"
}
