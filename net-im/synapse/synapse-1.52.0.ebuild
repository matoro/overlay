# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Matrix reference homeserver"
HOMEPAGE="https://github.com/matrix-org/synapse https://matrix.org"
SRC_URI="https://github.com/matrix-org/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE="jwt ldap mail oidc opentracing postgres redis saml sentry +sqlite systemd test urlpreview"
# postgres tests run only against prod instance or docker
RESTRICT="mirror postgres? ( test )"

# https://github.com/matrix-org/synapse/pull/11633
# "Drop Bionic from Debian builds"
PYTHON_COMPAT=( python3_{7,8,9} pypy3 )
PYTHON_REQ_USE="sqlite(+)?"

inherit distutils-r1 systemd user

REQUIRED_USE="|| ( postgres sqlite )"

# https://github.com/matrix-org/synapse/pull/11834
# "Avoid type annotation problems in prom-client"
RDEPEND=">=dev-python/jsonschema-3.0.0[${PYTHON_USEDEP}]
		>=dev-python/frozendict-1[${PYTHON_USEDEP}]
		<dev-python/frozendict-2.1.2[${PYTHON_USEDEP}]
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
		>=dev-python/pillow-5.4.0[${PYTHON_USEDEP},jpeg,jpeg2k]
		>=dev-python/sortedcontainers-1.4.4[${PYTHON_USEDEP}]
		>=dev-python/pymacaroons-0.13.0[${PYTHON_USEDEP}]
		>=dev-python/msgpack-0.5.2[${PYTHON_USEDEP}]
		>=dev-python/phonenumbers-8.2.0[${PYTHON_USEDEP}]
		>=dev-python/prometheus_client-0.4.0[${PYTHON_USEDEP}]
		<dev-python/prometheus_client-0.13.0[${PYTHON_USEDEP}]
		>=dev-python/attrs-19.2.0[${PYTHON_USEDEP}]
		!~dev-python/attrs-21.1.0[${PYTHON_USEDEP}]
		>=dev-python/netaddr-0.7.18[${PYTHON_USEDEP}]
		>=dev-python/jinja-2.9[${PYTHON_USEDEP}]
		>=dev-python/bleach-1.4.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-3.7.4[${PYTHON_USEDEP}]
		>=dev-python/cryptography-3.4.7[${PYTHON_USEDEP}]
		>=dev-python/ijson-3.1[${PYTHON_USEDEP}]
		~dev-python/matrix-common-1.0.0[${PYTHON_USEDEP}]
		sqlite? ( >=dev-db/sqlite-3.11[${PYTHON_USEDEP}] )
		ldap? ( >=dev-python/matrix-synapse-ldap3-0.1[${PYTHON_USEDEP}] )
		postgres? (
			$(python_gen_cond_dep '>=dev-python/psycopg-2.8:2[${PYTHON_USEDEP}]' 'python3_*')
			$(python_gen_cond_dep '>=dev-python/psycopg2cffi-2.8[${PYTHON_USEDEP}]' pypy3)
			$(python_gen_cond_dep '~dev-python/psycopg2cffi-compat-1.1[${PYTHON_USEDEP}]' pypy3)
		)
		saml? ( >=dev-python/pysaml2-4.5.0[${PYTHON_USEDEP}] )
		systemd? ( >=dev-python/python-systemd-231[${PYTHON_USEDEP}] )
		urlpreview? ( >=dev-python/lxml-4.2.0[${PYTHON_USEDEP}] )
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
		test? ( >=dev-python/parameterized-0.7.0[${PYTHON_USEDEP}] )"

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
