# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_{6,7} python3_{2,3,4,5,6,7} pypy{,3} )
inherit distutils-r1

DESCRIPTION="A library for property based testing"
HOMEPAGE="https://github.com/drmaciver/hypothesis"
SRC_URI="https://github.com/drmaciver/hypothesis/archive/hypothesis-python-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"
RESTRICT="mirror"
PYTHON_REQ_USE="sqlite(-)"
S="${WORKDIR}/hypothesis-hypothesis-python-${PV}"

# working on getting tests working, currently stuck on pytest plugin
RESTRICT="${RESTRICT} test"

RDEPEND="$(python_gen_cond_dep 'dev-python/importlib[${PYTHON_USEDEP}]' python2_6)
		$(python_gen_cond_dep 'dev-python/ordereddict[${PYTHON_USEDEP}]' python2_6)
		$(python_gen_cond_dep 'dev-python/Counter[${PYTHON_USEDEP}]' python2_6)"
DEPEND="${RDEPEND}
		test? (
			dev-python/pytest[${PYTHON_USEDEP}]
			dev-python/flake8[${PYTHON_USEDEP}]
			dev-python/pytz[${PYTHON_USEDEP}]
			>=dev-python/django-1.7[${PYTHON_USEDEP}]
			>=dev-python/numpy-1.9.0[${PYTHON_USEDEP}]
		)"

python_compile() {
	distutils-r1_python_compile
	cd "hypothesis-extra/hypothesis-pytest"
	distutils-r1_python_compile
}

python_test() {
	DJANGO_SETTINGS_MODULE="tests.django.toys.settings" pytest || die "Tests failed under ${EPYTHON}"
}

pkg_postinst() {
	optfeature "datetime support" "dev-python/pytz"
	optfeature "django support" "dev-python/pytz" ">=dev-python/django-1.7"
	optfeature "numpy support" ">=dev-python/numpy-1.9.0"
}
