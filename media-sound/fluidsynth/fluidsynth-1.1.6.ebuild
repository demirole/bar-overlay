# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/fluidsynth/fluidsynth-1.1.6.ebuild,v 1.3 2014/10/10 17:43:49 -tclover Exp $

EAPI=5

inherit autotools-utils

DESCRIPTION="Fluidsynth is a software real-time synthesizer based on the Soundfont 2 specifications."
HOMEPAGE="http://www.fluidsynth.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="+alsa dbus debug doc +jack ladspa +lash portaudio pulseaudio readline sndfile"
REQUIRE_USE="lash? ( alsa )"

RDEPEND=">=dev-libs/glib-2.6.5:2
	alsa? ( >=media-libs/alsa-lib-0.9.1 )
	lash? ( virtual/liblash )
	dbus? ( >=sys-apps/dbus-1.0.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	ladspa? ( >=media-libs/ladspa-sdk-1.12
		>=media-libs/ladspa-cmt-1.15 )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.8 )
	portaudio? ( >=media-libs/portaudio-19_pre )
	readline? ( sys-libs/readline )
	sndfile? ( >=media-libs/libsndfile-1.0.18 )"

DEPEND="${RDEPEND}
	app-doc/doxygen
	virtual/pkgconfig"

DOCS=( AUTHORS NEWS README THANKS TODO )

PATCHES=(
	"${FILESDIR}"/configure.ac.patch
)

AUTOTOOLS_IN_SOURCE_BUILD=1

src_configure()
{
	local -a myeconfargs=(
		$(use_enable alsa alsa-support)
		$(use_enable dbus dbus-support)
		$(use_enable debug)
		$(use_enable jack jack-support)
		--disable-ladcca
		$(use_enable ladspa)
		$(use_enable lash)
		$(use_enable sndfile libsndfile-support)
		$(use_enable portaudio portaudio-support)
		$(use_enable pulseaudio pulse-support)
		$(use_with readline)
	)
	autotools-utils_src_configure
}

src_install()
{
	default

	if use doc; then
		insinto /usr/share/doc/${PF}/pdf
		doins doc/FluidSynth-LADSPA.pdf
		insinto /usr/share/doc/${PF}/src
		doins doc/*.c
		dodoc doc/{xtrafluid,fluidsynth-v11-devdoc}.txt
	fi
}

