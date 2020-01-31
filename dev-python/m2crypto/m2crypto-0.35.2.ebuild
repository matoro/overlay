# Copyright 2018-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{6..8})
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1 toolchain-funcs

MY_PN="M2Crypto"
DESCRIPTION="A Python crypto and SSL toolkit"
HOMEPAGE="https://gitlab.com/m2crypto/m2crypto https://pypi.org/project/M2Crypto/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE="libressl doc test"

RDEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	virtual/python-typing[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-lang/swig-2.0.9
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
"

S="${WORKDIR}/${MY_PN}-${PV}"

PATCHES=(
	"${FILESDIR}/${PN}-libressl-0.31.0.patch"
)

swig_define() {
	local x
	for x; do
		if tc-cpp-is-true "defined(${x})"; then
			SWIG_FEATURES+=" -D${x}"
		fi
	done
}

python_prepare_all() {
	# python 3.8 compat
	# https://bugs.python.org/issue34850
	sed -i "s/is not ''/!= ''/g" "${MY_PN}/X509.py" || die
	distutils-r1_python_prepare_all
}

python_compile() {
	# setup.py looks at platform.machine() to determine swig options.
	# For exotic ABIs, we need to give swig a hint.
	local -x SWIG_FEATURES=

	# https://bugs.gentoo.org/617946
	swig_define __ILP32__

	# https://bugs.gentoo.org/674112
	swig_define __ARM_PCS_VFP

	distutils-r1_python_compile --openssl="${ESYSROOT}"/usr

	use doc && emake -C doc html || die
}

python_install_all() {
	use doc && local HTML_DOCS=( "doc/html/." )
	distutils-r1_python_install_all
}

python_test() {
	esetup.py test
}
