# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Free RDP client version 1.1.0 with Ubuntu bionic patches"
HOMEPAGE="http://www.freerdp.com/"
VER_HASH="440916eae2e07463912d5fe507677e67096eb083"
SRC_URI="https://github.com/freerdp/freerdp/archive/${VER_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/1"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="alsa +client cpu_flags_arm_neon cups debug doc +ffmpeg gstreamer jpeg libav libressl openh264 pulseaudio server smartcard systemd test usb wayland X xinerama xv"
RESTRICT="!test? ( test ) mirror"
S="${WORKDIR}/FreeRDP-${VER_HASH}"

# needs openssl-1.0 branch
# https://github.com/FreeRDP/FreeRDP-WebConnect/issues/187
RDEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	sys-libs/zlib:0
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	client? (
		usb? (
			virtual/libudev:0=
			sys-apps/util-linux:0=
			dev-libs/dbus-glib:0=
			virtual/libusb:1=
		)
		X? (
			x11-libs/libXcursor
			x11-libs/libXext
			x11-libs/libXi
			x11-libs/libXrender
			xinerama? ( x11-libs/libXinerama )
			xv? ( x11-libs/libXv )
		)
	)
	ffmpeg? (
		libav? ( media-video/libav:0= )
		!libav? ( media-video/ffmpeg:0= )
	)
	!ffmpeg? (
		x11-libs/cairo:0=
	)
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		x11-libs/libXrandr
	)
	jpeg? ( virtual/jpeg:0 )
	openh264? ( media-libs/openh264 )
	pulseaudio? ( media-sound/pulseaudio )
	server? (
		X? (
			x11-libs/libXcursor
			x11-libs/libXdamage
			x11-libs/libXext
			x11-libs/libXfixes
			x11-libs/libXrandr
			x11-libs/libXtst
			xinerama? ( x11-libs/libXinerama )
		)
	)
	smartcard? ( sys-apps/pcsc-lite )
	systemd? ( sys-apps/systemd:0= )
	wayland? (
		dev-libs/wayland
		x11-libs/libxkbcommon
	)
	X? (
		x11-libs/libX11
		x11-libs/libxkbfile
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	client? ( X? ( doc? (
		app-text/docbook-xml-dtd:4.1.2
		app-text/xmlto
	) ) )
"

PATCHES=(
		"${FILESDIR}/0001_fix-cmdline-parser.patch"
		"${FILESDIR}/0002_handle-old-style-cmdline-options.patch"
		"${FILESDIR}/0003_copy-data-when-adding-glyph-to-cache.patch"
		"${FILESDIR}/0004_build-cmake-3.1-compatibility.patch"
		"${FILESDIR}/0005_release-keys-when-xfreerdp-is-unfocused-to-prevent-s.patch"
		"${FILESDIR}/0006_fix-null-cert-that-is-not-an-error.patch"
		"${FILESDIR}/0007_Fix-build-failure-on-x32.patch"
		"${FILESDIR}/0008-Fix-multiple-security-issues.patch"
		"${FILESDIR}/0009-enable-TLS-12.patch"
		"${FILESDIR}/1001_hide-internal-symbols.patch"
		"${FILESDIR}/1002_update-pkg-config-file.patch"
		"${FILESDIR}/1003_multi-arch-include-path.patch"
		"${FILESDIR}/1004_64-bit-architectures.patch"
		"${FILESDIR}/1005_parse-buffer-endianess.patch"
		"${FILESDIR}/1006_test-unicode-endianess.patch"
		"${FILESDIR}/1007_detect-arm-arch-correctly.patch"
		"${FILESDIR}/1008_gcc-fPIC-on-arm64.patch"
		"${FILESDIR}/1009_libusb-debug.patch"
		"${FILESDIR}/1010_libudev-link.patch"
		"${FILESDIR}/1011_ffmpeg-2.9.patch"
		"${FILESDIR}/1012_typo-fix.patch"
		"${FILESDIR}/1013_aligned_meminfo_alignment.patch"
		"${FILESDIR}/2001_detect-ffmpeg-on-Debian.patch"
		"${FILESDIR}/CVE-2014-0791.patch"
		"${FILESDIR}/CVE-2018-8786.patch"
		"${FILESDIR}/CVE-2018-8787.patch"
		"${FILESDIR}/CVE-2018-8788.patch"
		"${FILESDIR}/CVE-2018-8789.patch"
		"${FILESDIR}/tsmf_ffmpeg.patch"
		"${FILESDIR}/openssl-1.1.patch"
)

src_prepare() {
	# https://github.com/FreeRDP/FreeRDP/issues/2181#issuecomment-62178341
	# https://bugs.gentoo.org/527700#c2
	# https://github.com/FreeRDP/FreeRDP/commit/a668a644889bd58405b92c72a91c308c2bad8022
	# https://public.kitware.com/Bug/view.php?id=13796#c31892
	sed -i "s/include(CMakeDetermineSystem)//g" CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
		-DCHANNEL_URBDRC=$(usex usb ON OFF)
		-DWITH_ALSA=$(usex alsa ON OFF)
		-DWITH_CCACHE=OFF
		-DWITH_CLIENT=$(usex client ON OFF)
		-DWITH_CUPS=$(usex cups ON OFF)
		-DWITH_DEBUG_ALL=$(usex debug ON OFF)
		-DWITH_MANPAGES=$(usex doc ON OFF)
		-DWITH_FFMPEG=$(usex ffmpeg ON OFF)
		-DWITH_SWSCALE=$(usex ffmpeg ON OFF)
		-DWITH_CAIRO=$(usex ffmpeg OFF ON)
		-DWITH_DSP_FFMPEG=$(usex ffmpeg ON OFF)
		-DWITH_GSTREAMER=$(usex gstreamer ON OFF)
		-DWITH_JPEG=$(usex jpeg ON OFF)
		-DWITH_NEON=$(usex cpu_flags_arm_neon ON OFF)
		-DWITH_OPENH264=$(usex openh264 ON OFF)
		-DWITH_PULSE=$(usex pulseaudio ON OFF)
		-DWITH_SERVER=$(usex server ON OFF)
		-DWITH_PCSC=$(usex smartcard ON OFF)
		-DWITH_LIBSYSTEMD=$(usex systemd ON OFF)
		-DWITH_X11=$(usex X ON OFF)
		-DWITH_XINERAMA=$(usex xinerama ON OFF)
		-DWITH_XV=$(usex xv ON OFF)
		-DWITH_WAYLAND=$(usex wayland ON OFF)
	)
	cmake_src_configure
}
