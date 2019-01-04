# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )
PYTHON_REQ_USE='threads(+)'
WAF_VERSION=1.9.8

case "${PV}" in
	(9999*)
	KEYWORDS=""
	VCS_ECLASS=git-2
	EGIT_REPO_URI="git://github.com/mpv-player/${PN}.git"
	EGIT_PROJECT="${PN}.git"
	;;
	(*)
	KEYWORDS="~alpha ~amd64 ~arm ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux"
	VCS_ECLASS=vcs-snapshot
	SRC_URI="https://github.com/mpv-player/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	;;
esac
inherit eutils python-any-r1 waf-utils pax-utils fdo-mime gnome2-utils ${VCS_ECLASS}

DESCRIPTION="Video player based on MPlayer/mplayer2"
HOMEPAGE="http://mpv.io/"
SRC_URI+=" http://ftp.waf.io/pub/release/waf-${WAF_VERSION}"

LICENSE="GPL-2+ LGPL-2.1+ BSD MIT ISC samba? ( GPL-3+ )"
SLOT="0/${PV}"
IUSE="+alsa bluray cdda +drm dvb +dvd dvdnav +egl encode +gbm
+iconv jack javascript jpeg lcms libarchive +libass libcaca +lua luajit openal
+opengl oss pulseaudio rubberband samba sdl selinux static static-libs uchardet
v4l vaapi vapoursynth vdpau wayland +X xinerama +xscreensaver +xv zlib
zsh-completion"

REQUIRED_USE="
	dvdnav? ( dvd )
	gbm? ( egl drm )
	lcms? ( opengl )
	luajit? ( lua )
	opengl? ( || ( wayland X ) )
	uchardet? ( iconv )
	v4l? ( || ( alsa oss ) )
	vaapi? ( || ( X wayland drm ) )
	vdpau? ( X )
	wayland? ( egl )
	xinerama? ( X )
	xscreensaver? ( X )
	xv? ( X )"
RDEPEND+="
	|| (
		>=media-video/libav-12:=[encode?,threads,vaapi?,vdpau?]
		>=media-video/ffmpeg-3.2.2:0=[encode?,threads,vaapi?,vdpau?]
	)
	sys-libs/ncurses
	zlib? ( sys-libs/zlib )
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXxf86vm
		opengl? ( virtual/opengl )
		lcms? ( >=media-libs/lcms-2.6:2 )
		vaapi? ( <=x11-libs/libva-2.0.0:0[X?,drm?,wayland?] )
		vdpau? ( >=x11-libs/libvdpau-0.2 )
		xinerama? ( x11-libs/libXinerama )
		xscreensaver? ( x11-libs/libXScrnSaver )
		xv? ( x11-libs/libXv )
	)
	alsa? ( media-libs/alsa-lib )
	bluray? ( >=media-libs/libbluray-0.3.0 )
	cdda? (
		dev-libs/libcdio
		dev-libs/libcdio-paranoia
	)
	drm? ( x11-libs/libdrm )
	dvb? ( virtual/linuxtv-dvb-headers )
	dvd? (
		>=media-libs/libdvdread-4.1.3
		dvdnav? ( >=media-libs/libdvdnav-4.2.0
			>=media-libs/libdvdread-4.1.0 )
	)
	iconv? ( virtual/libiconv )
	jack? ( media-sound/jack-audio-connection-kit )
	javascript? ( >=dev-lang/mujs-1.0.0 )
	jpeg? ( virtual/jpeg:0 )
	libarchive? ( >=app-arch/libarchive-3.0 )
	libass? (
		>=media-libs/libass-0.12.1:=[fontconfig]
		virtual/ttf-fonts
	)
	libcaca? ( >=media-libs/libcaca-0.99_beta18 )
	lua? (
		!luajit? ( <dev-lang/lua-5.3 >=dev-lang/lua-5.1 )
		luajit? ( dev-lang/luajit:2 )
	)
	openal? ( >=media-libs/openal-1.13 )
	pulseaudio? ( media-sound/pulseaudio )
	rubberband? ( >=media-libs/rubberband-1.8.0 )
	samba? ( net-fs/samba )
	sdl? ( media-libs/libsdl2[threads] )
	selinux? ( sec-policy/selinux-mplayer )
	uchardet? ( dev-libs/uchardet )
	v4l? ( media-libs/libv4l )
	vapoursynth? ( media-video/vapoursynth )
	wayland? (
		>=dev-libs/wayland-1.6.0
		dev-libs/wayland-protocols
		>=x11-libs/libxkbcommon-0.3.0
	)"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
	>=dev-lang/perl-5.8
	dev-python/docutils
	X? ( x11-base/xorg-proto )"
DOCS=( Copyright README.md )

pkg_setup()
{
	if use !libass; then
		ewarn
		ewarn "You've disabled the libass flag. No OSD or subtitles will be displayed."
	fi

	einfo "For additional format support you need to enable the support on your"
	einfo "libavcodec/libavformat provider:"
	einfo "    media-video/libav or media-video/ffmpeg"

	python-any-r1_pkg_setup
}

src_unpack()
{
	default
	cp "${DISTDIR}"/waf-${WAF_VERSION} "${S}"/waf &&
	chmod 0755 "${S}"/waf || die
}

src_prepare()
{
	epatch_user
}

src_configure()
{
	# keep build reproducible
	# do not add -g to CFLAGS
	# SDL output is fallback for platforms where nothing better is available
	# media-sound/rsound is in pro-audio overlay only
	local mywconfargs=(
		${EXTRA_MPV_CONF}
		--disable-build-date
		--disable-debug-build
		--disable-sdl1
		--disable-optimize
		$(use_enable sdl sdl2)
		--disable-rsound
		--disable-vapoursynth
		$(usex egl "$(use_enable X egl-x11)" '--disable-egl-x11')
		$(usex egl "$(use_enable gbm egl-drm)" '--disable-egl-drm')
		$(use_enable encode encoding)
		$(use_enable bluray libbluray)
		$(use_enable samba libsmbclient)
		$(use_enable lua)
		$(usex luajit '--lua=luajit' '')
		$(use_enable javascript)
		$(use_enable cdda)
		$(use_enable drm)
		$(use_enable dvd dvdread)
		$(use_enable dvdnav)
		$(use_enable gbm)
		$(use_enable iconv)
		$(use_enable libarchive)
		$(use_enable libass)
		$(use_enable dvb dvbin)
		$(use_enable uchardet)
		$(use_enable v4l libv4l2)
		$(use_enable v4l tv)
		$(use_enable v4l tv-v4l2)
		$(use_enable jpeg)
		$(use_enable libcaca caca)
		$(use_enable alsa)
		$(use_enable jack)
		$(use_enable openal)
		$(use_enable oss oss-audio)
		$(use_enable pulseaudio pulse)
		$(use_enable rubberband)
		$(usex static '--enable-static-build' '')
		$(usex static-libs '--enable-libmpv-static' '--enable-libmpv-shared')
		$(use_enable X x11)
		$(use_enable vaapi)
		$(usex vaapi "$(use_enable X vaapi-x11)" '--disable-vaapi-x11')
		$(usex vaapi "$(use_enable wayland vaapi-wayland)" '--disable-vaapi-wayland')
		$(usex vaapi "$(use_enable gbm vaapi-drm)" '--disable-vaapi-drm')
		$(use_enable vdpau)
		$(usex vdpau "$(use_enable opengl vdpau-gl-x11)" '--disable-vdpau-gl-x11')
		$(use_enable vapoursynth)
		$(use_enable wayland)
		$(use_enable xv)
		$(use_enable opengl gl)
		$(usex opengl "$(use_enable X gl-x11)" '--disable-gl-x11')
		$(usex opengl "$(use_enable wayland gl-wayland)" '--disable-gl-wayland')
		$(use_enable lcms lcms2)
		$(use_enable zlib)
		$(use_enable zsh-completion zsh-comp)
		--confdir="${EPREFIX}"/etc/${PN}
		--mandir="${EPREFIX}"/usr/share/man
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
	)
	waf-utils_src_configure "${mywconfargs[@]}"
}

src_install()
{
	waf-utils_src_install

	if use lua; then
		insinto /usr/share/${PN}
		doins -r TOOLS/lua
	fi

	if use luajit; then
		pax-mark -m "${ED}"usr/bin/mpv
	fi
	dodoc etc/*.conf
}

pkg_preinst()
{
	gnome2_icon_savelist
}

pkg_postinst()
{
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm()
{
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

