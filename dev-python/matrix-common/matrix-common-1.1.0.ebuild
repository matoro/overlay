# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{6,7,8,9,10} pypy3 )
inherit distutils-r1

DESCRIPTION="Common code for Synapse, Sydent, and Sygnal"
HOMEPAGE="https://pypi.org/project/matrix-common/"
SRC_URI="https://github.com/matrix-org/matrix-python-common/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64"
IUSE="test"
RESTRICT="mirror"
S="${WORKDIR}/matrix-python-common-${PV}"

BDEPEND="
	test? (
		dev-python/twisted[${PYTHON_USEDEP}]
		dev-python/aiounittest[${PYTHON_USEDEP}]
	)
"

python_test() {
	"${EPYTHON}" -m twisted.trial tests || die
}
