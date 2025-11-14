# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Dashboards is a browser based analytics and search dashboard for OpenSearch"
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

RDEPEND="
	|| ( >=dev-db/opensearch-bin-3.3.0 >=dev-db/opensearch-3.3.0 )
	acct-group/opensearch-dashboards
	acct-user/opensearch-dashboards
	>=net-libs/nodejs-20
	<net-libs/nodejs-24
"

BDEPEND="verify-sig? ( sec-keys/openpgp-keys-opensearch-release )"

src_prepare() {
	default
	sed -i 's/^# opensearch.logQueries: false/opensearch.logQueries: true/' config/opensearch_dashboards.yml
	sed -i 's/^# logging.verbose: false/logging.verbose: true/' config/opensearch_dashboards.yml
	sed -i "s%^# logging.dest: stdout%logging.dest: /var/log/${MY_PN}/${MY_PN}.log%" config/opensearch_dashboards.yml
	rm LICENSE.txt NOTICE.txt || die
}

src_install() {
	keepdir /etc/${MY_PN}

	insinto /etc/${MY_PN}
	doins -r config/.
	rm -r config || die

	fowners -R root:${MY_PN} /etc/${MY_PN}
	fperms 640 /etc/${MY_PN}/{node.options,opensearch_dashboards.yml}

	insinto /usr/share/${MY_PN}
	doins -r .

	fperms -R +x /usr/share/${MY_PN}/bin

	keepdir /var/log/${MY_PN}
	fowners ${MY_PN}:${MY_PN} /var/log/${MY_PN}
	fperms 0750 /var/log/${MY_PN}

	newconfd "${FILESDIR}/${MY_PN}.confd" ${MY_PN}
	newinitd "${FILESDIR}/${MY_PN}.initd" ${MY_PN}

	dosym ../../../etc/opensearch-dashboards /usr/share/opensearch-dashboards/config
	dosym ../../../var/log/opensearch-dashboards /usr/share/opensearch-dashboards/logs
}
