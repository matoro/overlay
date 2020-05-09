# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7,8} )
inherit distutils-r1

DESCRIPTION="An LDAP3 auth provider for Synapse"
HOMEPAGE="https://github.com/matrix-org/matrix-synapse-ldap3"
SRC_URI="https://github.com/matrix-org/matrix-synapse-ldap3/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"
# tests not compatible with python3 yet
# https://github.com/matrix-org/matrix-synapse-ldap3/issues/73
# https://stackoverflow.com/a/28204760
RESTRICT="mirror test"

RDEPEND=">=dev-python/twisted-15.1.0[${PYTHON_USEDEP}]
		>=dev-python/ldap3-0.9.5[${PYTHON_USEDEP}]
		dev-python/service_identity[${PYTHON_USEDEP}]"
DEPEND="test? (
			dev-python/mock[${PYTHON_USEDEP}]
			dev-python/ldaptor[${PYTHON_USEDEP}]
		)"

python_test() {
	trial tests || die
}
