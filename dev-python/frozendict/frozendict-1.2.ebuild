# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# https://github.com/slezica/python-frozendict/pull/23
PYTHON_COMPAT=( python{2_7,3_{5,6,7,8}} )
inherit distutils-r1

DESCRIPTION="An immutable dictionary"
HOMEPAGE="https://pypi.python.org/pypi/frozendict https://github.com/slezica/python-frozendict"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""
RESTRICT="mirror"
