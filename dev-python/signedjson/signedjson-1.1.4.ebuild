# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8,9,10} pypy3 )
inherit distutils-r1

DESCRIPTION="Sign JSON objects with ED25519 signatures"
HOMEPAGE="https://github.com/matrix-org/python-signedjson https://pypi.python.org/pypi/signedjson"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
RESTRICT="mirror"

RDEPEND=">=dev-python/canonicaljson-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/unpaddedbase64-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/pynacl-0.3.0[${PYTHON_USEDEP}]"
BDEPEND="dev-python/setuptools_scm[${PYTHON_USEDEP}]"

distutils_enable_tests nose
