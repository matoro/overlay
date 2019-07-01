# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} pypy{,3} )
inherit distutils-r1

DESCRIPTION="Faker is a Python package that generates fake data for you"
HOMEPAGE="https://github.com/joke2k/faker"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"
RESTRICT="mirror"

RDEPEND=">=dev-python/python-dateutil-2.4[${PYTHON_USEDEP}]
		>=dev-python/six-1.10[${PYTHON_USEDEP}]
		>=dev-python/text-unidecode-1.2[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/ipaddress[${PYTHON_USEDEP}]' python2_7)"
DEPEND="dev-python/pytest-runner[${PYTHON_USEDEP}]
		test? (
			>=dev-python/email-validator-1.0.1[${PYTHON_USEDEP}]
			!>=dev-python/email-validator-1.1.0[${PYTHON_USEDEP}]
			>=dev-python/ukpostcodeparser-1.1.1[${PYTHON_USEDEP}]
			$(python_gen_cond_dep 'dev-python/mock[${PYTHON_USEDEP}]' python2_7)
			>=dev-python/pytest-3.8.0[${PYTHON_USEDEP}]
			!>=dev-python/pytests-3.9[${PYTHON_USEDEP}]
			$(python_gen_cond_dep '<dev-python/more-itertools-6.0.0[${PYTHON_USEDEP}]' python2_7)
			>=dev-python/random2-1.0.1[${PYTHON_USEDEP}]
			>=dev-python/freezegun-0.3.11[${PYTHON_USEDEP}]
		)"

python_test() {
	esetup.py test || die "Tests failed under ${EPYTHON}"
}
