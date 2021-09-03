# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6,7,8,9} pypy{,3} )
inherit distutils-r1

DESCRIPTION="Sign JSON objects with ED25519 signatures"
HOMEPAGE="https://github.com/matrix-org/python-signedjson https://pypi.python.org/pypi/signedjson"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~ppc64"
RESTRICT="mirror"
IUSE="test"

RDEPEND=">=dev-python/canonicaljson-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/unpaddedbase64-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/pynacl-0.3.0[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/typing-extensions[${PYTHON_USEDEP}]' python3_{5,6})
		$(python_gen_cond_dep 'dev-python/typing[${PYTHON_USEDEP}]' 'python2*' pypy)
		dev-python/importlib_metadata[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
		dev-python/setuptools_scm[${PYTHON_USEDEP}]
		test? ( dev-python/nose[${PYTHON_USEDEP}] )"

python_test() {
	nosetests || die
}
