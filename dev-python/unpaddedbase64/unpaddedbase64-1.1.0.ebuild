# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6,7,8} pypy{,3} )
inherit distutils-r1

DESCRIPTION="Unpadded Base64"
HOMEPAGE="https://github.com/matrix-org/python-unpaddedbase64 https://pypi.python.org/pypi/unpaddedbase64"
SRC_URI="https://github.com/matrix-org/python-unpaddedbase64/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/python-${P}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"
RESTRICT="mirror"

DEPEND="${RDEPEND}
		dev-python/pytest[${PYTHON_USEDEP}]"

python_test() {
	"${EPYTHON}" -m pytest || die
}
