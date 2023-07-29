# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake llvm prefix

LLVM_MAX_SLOT=16

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/"
	inherit git-r3
	S="${WORKDIR}/${P}/lib/comgr"
else
	SRC_URI="https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/ROCm-CompilerSupport-rocm-${PV}/lib/comgr"
	KEYWORDS="~amd64"
fi

IUSE="test"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${PN}-5.1.3-rocm-path.patch"
	"${FILESDIR}/0001-Specify-clang-exe-path-in-Driver-Creation.patch"
	"${FILESDIR}/0001-Find-CLANG_RESOURCE_DIR-using-clang-print-resource-d.patch"
	"${FILESDIR}/${PN}-5.3.3-HIPIncludePath-not-needed.patch"
	"${FILESDIR}/${PN}-5.3.3-fno-stack-protector.patch"
	"${FILESDIR}/${PN}-9999-fix-tests.patch"
	"${FILESDIR}/b582dfb33fdb51065c22800fe02dd83207185664.patch"
	"${FILESDIR}/271fddf65f43675e675f0cb4e9aaa3d27d34c58a.patch"
	"${FILESDIR}/f4ae37553ce016b6a8e9e8d9515c241ec061d0bb.patch"
	"${FILESDIR}/5963c2969184364ec69f0ff73849f44e6ea2901c.patch"
	"${FILESDIR}/278f8517a768f34914fef4cb941528ca44dd7787.patch"
	"${FILESDIR}/e1da67c6acb2b0e4a8f9c05c89e3778252ea5aa7.patch"
	"${FILESDIR}/48c682d577a7955256d0bfac5d497b3feebff11c.patch"
	"${FILESDIR}/79948e1807bca7108722982b9018d61dde9420f2.patch"
)

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/RadeonOpenCompute/ROCm-CompilerSupport"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND=">=dev-libs/rocm-device-libs-${PV}
	sys-devel/clang:${LLVM_MAX_SLOT}=
	sys-devel/clang-runtime:=
	sys-devel/lld:${LLVM_MAX_SLOT}="
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

src_prepare() {
	sed '/sys::path::append(HIPPath/s,"hip","",' -i src/comgr-env.cpp || die
	sed "/return LLVMPath;/s,LLVMPath,llvm::SmallString<128>(\"$(get_llvm_prefix ${LLVM_MAX_SLOT})\")," \
		-i src/comgr-env.cpp || die
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-5.0-rocm_path.patch)
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-9999-hip-test-add-rocm-path.patch)
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_DIR="$(get_llvm_prefix ${LLVM_MAX_SLOT})"
		-DCMAKE_STRIP=""  # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}
