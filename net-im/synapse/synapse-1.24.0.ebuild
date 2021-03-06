# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Matrix reference homeserver"
HOMEPAGE="https://github.com/matrix-org/synapse https://matrix.org"
SRC_URI="https://github.com/matrix-org/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="acme jwt ldap mail oidc opentracing postgres redis saml sentry +sqlite systemd test urlpreview"
# postgres tests run only against prod instance or docker
RESTRICT="mirror postgres? ( test )"

# https://github.com/matrix-org/synapse/pull/8665
# "Note support for Python 3.9"
PYTHON_COMPAT=( python3_{5,6,7,8,9} )
PYTHON_REQ_USE="sqlite(+)?"

inherit distutils-r1 systemd user

REQUIRED_USE="|| ( postgres sqlite )"

# https://github.com/matrix-org/synapse/pull/8898
# "Fix installing pysaml2 on Python 3.5"
RDEPEND=">=dev-python/jsonschema-2.5.1[${PYTHON_USEDEP}]
		>=dev-python/frozendict-1[${PYTHON_USEDEP}]
		>=dev-python/unpaddedbase64-1.1.0[${PYTHON_USEDEP}]
		>=dev-python/canonicaljson-1.4.0[${PYTHON_USEDEP}]
		>=dev-python/signedjson-1.1.0[${PYTHON_USEDEP}]
		>=dev-python/pynacl-1.2.1[${PYTHON_USEDEP}]
		>=dev-python/idna-2.5[${PYTHON_USEDEP}]
		>=dev-python/service_identity-18.1.0[${PYTHON_USEDEP}]
		>=dev-python/twisted-18.9.0[${PYTHON_USEDEP}]
		>=dev-python/treq-15.1[${PYTHON_USEDEP}]
		>=dev-python/pyopenssl-16.0.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-3.11[${PYTHON_USEDEP}]
		>=dev-python/pyasn1-0.1.9[${PYTHON_USEDEP}]
		>=dev-python/pyasn1-modules-0.0.7[${PYTHON_USEDEP}]
		>=dev-python/bcrypt-3.1.0[${PYTHON_USEDEP}]
		>=dev-python/pillow-4.3.0[${PYTHON_USEDEP},jpeg,jpeg2k]
		>=dev-python/sortedcontainers-1.4.4[${PYTHON_USEDEP}]
		>=dev-python/pymacaroons-0.13.0[${PYTHON_USEDEP}]
		>=dev-python/msgpack-0.5.2[${PYTHON_USEDEP}]
		>=dev-python/phonenumbers-8.2.0[${PYTHON_USEDEP}]
		>=dev-python/prometheus_client-0.4.0[${PYTHON_USEDEP}]
		>=dev-python/attrs-19.1.0[${PYTHON_USEDEP}]
		>=dev-python/netaddr-0.7.18[${PYTHON_USEDEP}]
		>=dev-python/jinja-2.9[${PYTHON_USEDEP}]
		>=dev-python/bleach-1.4.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-3.7.4[${PYTHON_USEDEP}]
		sqlite? ( >=dev-db/sqlite-3.11[${PYTHON_USEDEP}] )
		ldap? ( >=dev-python/matrix-synapse-ldap3-0.1[${PYTHON_USEDEP}] )
		postgres? ( >=dev-python/psycopg-2.7:2[${PYTHON_USEDEP}] )
		acme? (
			>=dev-python/txacme-0.9.2[${PYTHON_USEDEP}]
			$(python_gen_cond_dep '<dev-python/eliot-1.8.0[${PYTHON_USEDEP}]' python3_5)
		)
		saml? (
			>=dev-python/pysaml2-4.5.0[${PYTHON_USEDEP}]
			$(python_gen_cond_dep '<dev-python/pysaml2-6.4.0[${PYTHON_USEDEP}]' python3_5)
		)
		systemd? ( >=dev-python/python-systemd-231[${PYTHON_USEDEP}] )
		urlpreview? ( >=dev-python/lxml-3.5.0[${PYTHON_USEDEP}] )
		sentry? ( >=dev-python/sentry-sdk-0.7.2[${PYTHON_USEDEP}] )
		opentracing? (
			>=dev-python/jaeger-client-4.0.0[${PYTHON_USEDEP}]
			>=dev-python/opentracing-2.2.0[${PYTHON_USEDEP}]
		)
		jwt? ( >=dev-python/pyjwt-1.6.4[${PYTHON_USEDEP}] )
		redis? (
			>=dev-python/txredisapi-1.4.7[${PYTHON_USEDEP}]
			dev-python/hiredis[${PYTHON_USEDEP}]
		)
		oidc? ( >=dev-python/authlib-0.14.0[${PYTHON_USEDEP}] )"
DEPEND="${RDEPEND}
		test? (
			>=dev-python/mock-2.0[${PYTHON_USEDEP}]
			>=dev-python/parameterized-0.7.0[${PYTHON_USEDEP}]
		)"

pkg_setup() {
	enewgroup synapse
	enewuser synapse -1 -1 "/var/lib/synapse" "synapse"
}

python_test() {
	use postgres && SYNAPSE_POSTGRES=True
	"${EPYTHON}" -m twisted.trial -ex tests || die "tests failed under ${EPYTHON}"
}

python_install() {
	distutils-r1_python_install --skip-build
	dodir \
		/etc/${PN} \
		/var/lib/${PN} \
		/var/log/${PN}
	keepdir \
		/etc/${PN} \
		/var/lib/${PN} \
		/var/log/${PN}
	systemd_dounit "contrib/systemd/matrix-${PN}.service"
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
	elog "    sudo -u synapse python -m synapse.app.homeserver \\"
	elog "      --server-name my.domain.name \\"
	elog "      --config-path ${EROOT}/etc/synapse/homeserver.yaml \\"
	elog "      --generate-config \\"
	elog "      --report-stats=yes"
}
