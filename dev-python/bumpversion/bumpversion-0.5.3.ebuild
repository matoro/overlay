# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{2,3,4,5,6,7} pypy{,3} )

inherit distutils-r1

DESCRIPTION="Version-bump your software with a single command!"
HOMEPAGE="http://pypi.python.org/pypi/bumpversion https://github.com/peritus/bumpversion"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86 ~arm"
SLOT="0"
IUSE="test"
RESTRICT="mirror"

# tests are still wip :(
# TypeError: param_extract_id() got an unexpected keyword argument 'reason'
RESTRICT="${RESTRICT} test"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-vcs/mercurial
	)"


DOCS=( README.rst )

# https://docs.pytest.org/en/latest/deprecations.html#marks-in-pytest-mark-parametrize
python_prepare() {
	sed -i "s/pytest.mark.xfail/pytest.param/g" "tests.py" || die
	sed -i "s/reason=\"git is not installed\"/marks=pytest.mark.xfail(reason=\"git is not installed\")/g" "tests.py" || die
	sed -i "s/reason=\"hg is not installed\"/marks=pytest.mark.xfail(reason=\"hg is not installed\")/g" "tests.py" || die
}

python_test() {
	py.test || die "Tests fail with ${EPYTHON}"
}
