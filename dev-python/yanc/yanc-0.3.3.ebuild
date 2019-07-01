# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_{6,7} python3_{2,3,4,5,6,7} )
inherit distutils-r1

DESCRIPTION="Yet another nose colorer"
HOMEPAGE="https://github.com/0compute/yanc"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"
# disable tests on python3_{5,6,7}
# https://github.com/0compute/yanc/issues/10
# https://github.com/NixOS/nixpkgs/pull/49409/files#diff-0d17b395f76404037f9ac9466fe2bf6e
RESTRICT="mirror
		python_targets_python3_5? ( test )
		python_targets_python3_6? ( test )
		python_targets_python3_7? ( test )"

DEPEND="test? ( dev-python/nose )"

python_test() {
	nosetests || die "Tests failed under ${EPYTHON}"
}
