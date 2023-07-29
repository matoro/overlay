# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake flag-o-matic llvm rocm toolchain-funcs

LLVM_MAX_SLOT=16

# normally this comes straight from requirements.txt in MIOpen, but RDNA3 support
# is targeted for ROCm 5.6, so backport the earlist composable_kernel commit with it
# see https://github.com/ROCmSoftwarePlatform/MIOpen/pull/1957
_COMMIT="5f28614222bd590bc31d98838bc019e9c3a7ad45" # from requirements.txt in MIOpen
DESCRIPTION="Performance Portable Programming Model for Machine Learning Tensor Operators"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/composable_kernel"
SRC_URI="https://github.com/ROCmSoftwarePlatform/composable_kernel/archive/${_COMMIT}.tar.gz -> composable_kernel-${_COMMIT}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="dev-util/hip"
DEPEND="${RDEPEND}"
BDEPEND="dev-util/rocm-cmake"
S="${WORKDIR}/composable_kernel-${_COMMIT}"
PATCHES=( "${FILESDIR}/7613c1d9b9dc612a5de79ab968c534ea58e7cbe4.patch" )

pkg_pretend() {
	[[ "${MERGE_TYPE}" != "binary" ]] && tc-check-openmp
}

src_prepare() {
	cmake_src_prepare

	sed -e "s:/opt/rocm/llvm:$(get_llvm_prefix ${LLVM_MAX_SLOT}) NO_DEFAULT_PATH:" \
		-e "s:/opt/rocm/hip:$(hipconfig -p) NO_DEFAULT_PATH:" \
		-e "s:add_subdirectory(test)::" \
		-e "s:add_subdirectory(example)::" \
		-i CMakeLists.txt || die
	sed -e "s:-Werror::" \
		-i cmake/EnableCompilerWarnings.cmake || die
}

src_configure() {
	strip-flags
	filter-lto

	( use amdgpu_targets_gfx1100 || use amdgpu_targets_gfx1101 || use amdgpu_targets_gfx1102 ) \
		&& local rdna3="ON" || local rdna3="OFF"

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DUSE_OPT_NAVI3X="${rdna3}"
		-DUSE_BITINT_EXTENSION_INT4="ON"
		-DBUILD_DEV="OFF"
	)

	addpredict /dev/kfd
	addpredict /dev/dri/
	append-cxxflags "--rocm-path=$(hipconfig -R)"
	append-cxxflags "--hip-device-lib-path=${EPREFIX}/usr/lib/amdgcn/bitcode"
	CXX="hipcc" cmake_src_configure
}
