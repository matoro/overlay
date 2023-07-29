# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10,11,12} )
inherit distutils-r1 pypi

DESCRIPTION="Generator of ANSI C tracers which output CTF data streams"
HOMEPAGE="
	https://barectf.org/
	https://pypi.org/project/barectf/
"
SRC_URI="
	https://github.com/efficios/barectf/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/termcolor-1.1
	>=dev-python/pyyaml-5.3
	>=dev-python/jsonschema-3.2
	>=dev-python/jinja-3.0
"
BDEPEND="
	test? (
		>=dev-python/pytest-6
		>=dev-python/pytest-xdist-2
	)
"

distutils_enable_tests pytest
