# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} pypy{,3} )
inherit distutils-r1

DESCRIPTION="A Python Macaroon Library"
HOMEPAGE="https://github.com/ecordell/pymacaroons https://pymacaroons.readthedocs.org"
SRC_URI="https://github.com/ecordell/pymacaroons/archive/v${PV}.tar.gz -> ${P}.tar.gz"
# pypi missing tests
# SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="doc test"
RESTRICT="mirror"

RDEPEND=">=dev-python/six-1.8.0[${PYTHON_USEDEP}]
		>=dev-python/pynacl-1.1.2[${PYTHON_USEDEP}]
		!>=dev-python/pynacl-2.0[${PYTHON_USEDEP}]
		!dev-python/pymacaroons-pynacl[${PYTHON_USEDEP}]"
# hypothesis 1.x required per maintainer
DEPEND="${RDEPEND}
		doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
		test? (
			~dev-python/nose-1.3.7[${PYTHON_USEDEP}]
			>=dev-python/coverage-4.5[${PYTHON_USEDEP}]
			!>=dev-python/coverage-4.99[${PYTHON_USEDEP}]
			>=dev-python/mock-2.0.0[${PYTHON_USEDEP}]
			!>=dev-python/mock-2.99[${PYTHON_USEDEP}]
			>=dev-python/sphinx-1.2.3[${PYTHON_USEDEP}]
			>=dev-python/python-coveralls-2.4.2[${PYTHON_USEDEP}]
			>=dev-python/hypothesis-1.0.0[${PYTHON_USEDEP}]
			!>=dev-python/hypothesis-2[${PYTHON_USEDEP}]
			dev-python/bumpversion[${PYTHON_USEDEP}]
			dev-python/yanc[${PYTHON_USEDEP}]
		)"

python_prepare() {
	if use doc && use test
	then
		sed -i "s/extensions = \[/extensions = \[\n\"sphinx.ext.doctest\",/g" "docs/conf.py" || die
	fi
}

python_compile() {
	distutils-r1_python_compile
	use doc && emake -C docs html
}

python_test() {
	nosetests --with-yanc || die "Tests failed under ${EPYTHON}"
	use doc && emake -C docs doctest
}
