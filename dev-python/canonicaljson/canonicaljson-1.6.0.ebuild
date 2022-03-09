# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{7,8,9,10} pypy3 )
inherit distutils-r1

DESCRIPTION="Unpadded Base64"
HOMEPAGE="https://github.com/matrix-org/python-canonicaljson https://pypi.python.org/pypi/canonicaljson"
SRC_URI="https://github.com/matrix-org/python-canonicaljson/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/python-${P}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc64"
RESTRICT="mirror"
IUSE="test"

RDEPEND=">=dev-python/simplejson-3.14.0[${PYTHON_USEDEP}]
		>=dev-python/frozendict-1.0[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
		dev-python/nose[${PYTHON_USEDEP}]"

python_test() {
	nosetests || die
}
