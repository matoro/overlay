# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic fcaps

DESCRIPTION="The SoftDevLabs (SDL) version of the Hercules 4.x Hyperion Emulator"
HOMEPAGE="https://sdl-hercules-390.github.io/html/"
SRC_URI="https://github.com/SDL-Hercules-390/hyperion/archive/refs/tags/Release_${PV/.0/}.tar.gz -> ${P/.0/}.tar.gz"

LICENSE="QPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"
IUSE="bzip2 custom-cflags test"
RESTRICT="mirror !test? ( test )"
S="${WORKDIR}/hyperion-Release_${PV/.0/}"
FILECAPS=(
	cap_sys_nice\=eip usr/bin/hercules --
	cap_sys_nice\=eip usr/bin/herclin --
	cap_net_admin+ep usr/bin/hercifc
)

RDEPEND="
	dev-libs/libltdl:=
	net-libs/libnsl:0=
	sys-libs/zlib:=
	bzip2? ( app-arch/bzip2:= )"
DEPEND="${RDEPEND}
	app-emulation/hercules-sdl-crypto
	app-emulation/hercules-sdl-decnumber
	app-emulation/hercules-sdl-softfloat
	app-emulation/hercules-sdl-telnet"
BDEPEND="${RDEPEND}
	test? ( dev-lang/regina-rexx )"

PATCHES=( "${FILESDIR}"/${PN}-4.4.1-htmldir.patch )

src_prepare() {
	rm -rf crypto decNumber SoftFloat telnet || die
	sed -i 's#/lib${hc_cv_pkg_lib_subdir}#/lib#g' configure.ac || die
	sed -i 's#_pkgname}${hc_cv_pkg_lib_suffix}#_pkgname}#g' configure.ac || die

	default
	eautoreconf
}

src_configure() {
	use custom-cflags || strip-flags
	local -x ac_cv_lib_bz2_BZ2_bzBuffToBuffDecompress=$(usex bzip2)
	econf \
		$(use_enable bzip2 cckd-bzip2) \
		$(use_enable bzip2 het-bzip2) \
		--enable-custom="Gentoo ${PF}.ebuild" \
		--disable-optimization \
		--disable-setuid-hercifc \
		--disable-capabilities \
		--enable-extpkgs="${EROOT}/usr/$(get_libdir)/${PN}"
}

src_install() {
	default
	dodoc RELEASE.NOTES

	insinto /usr/share/hercules
	doins hercules.cnf

	# No static archives.  Have to leave .la files for modules. #720342
	find "${ED}/usr/$(get_libdir)" -name "*.la" -delete || die
}