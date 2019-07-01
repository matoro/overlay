# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )
inherit distutils-r1

DESCRIPTION="Python interface to coveralls.io API"
HOMEPAGE="https://github.com/z4r/python-coveralls"
SRC_URI="https://github.com/z4r/python-coveralls/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
# tests require weird git fork
# https://github.com/z4r/python-coveralls/blob/master/test_requirements.txt
RESTRICT="mirror test"

RDEPEND="dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=dev-python/coverage-4.0.3[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/argparse[${PYTHON_USEDEP}]' python2_7)
		$(python_gen_cond_dep 'dev-python/subprocess32[${PYTHON_USEDEP}]' python2_7)"
