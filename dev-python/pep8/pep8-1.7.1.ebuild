# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6,7,8} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Python style guide checker"
HOMEPAGE="https://github.com/PyCQA/pep8 https://pypi.org/project/pep8/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"

# https://github.com/PyCQA/pycodestyle/issues/786
# https://github.com/nothingmuch/guix/commit/2be878d8e54057980121e4c659ca48317b79970e
PATCHES=( "${FILESDIR}/python-pep8-stdlib-tokenize-compat.patch" )

python_prepare_all() {
	# disable tests which compares stdout
	# fails due to deprecation warning
	rm "testsuite/test_shell.py" || die
	sed -i "s/test_api, test_parser, test_shell, test_util/test_api, test_parser, test_util/g" testsuite/test_all.py || die
	sed -i "/suite.addTest(unittest.makeSuite(test_shell.ShellTestCase))/d" testsuite/test_all.py || die
	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	PYTHONPATH="${S}" "${PYTHON}" pep8.py -v --statistics pep8.py || die
	PYTHONPATH="${S}" "${PYTHON}" pep8.py -v --testsuite=testsuite || die
	PYTHONPATH="${S}" "${PYTHON}" pep8.py --doctest -v || die
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
