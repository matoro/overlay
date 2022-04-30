# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8,9,10} pypy3 )
inherit distutils-r1

DESCRIPTION="A Python Macaroon Library"
HOMEPAGE="https://github.com/ecordell/pymacaroons https://pymacaroons.readthedocs.org"
SRC_URI="https://github.com/ecordell/pymacaroons/archive/v${PV}.tar.gz -> ${P}.tar.gz"
# pypi missing tests
# SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
RESTRICT="mirror test" # tests depend on a very old version of hypothesis. being looked at upstream

RDEPEND=">=dev-python/six-1.8.0[${PYTHON_USEDEP}]
		>=dev-python/pynacl-1.1.2[${PYTHON_USEDEP}]
		!>=dev-python/pynacl-2.0[${PYTHON_USEDEP}]
		!dev-python/pymacaroons-pynacl[${PYTHON_USEDEP}]"

distutils_enable_sphinx docs
