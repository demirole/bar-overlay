# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: x11-themes/efenniht/efenniht-9999.ebuild,v 1.2 2014/12/01 11:27:05 -tclover Exp $

EAPI=5

inherit eutils git-2

DESCRIPTION="A nice dark EFL theme derived from gtk-engines-equinox"
EGIT_REPO_URI="http://git.enlightenment.org/themes/efenniht.git"

IUSE="gtk"
EGTK=efenniht-gtk-theme-0.1.tar.gz
SRC_URI=" gtk? ( http://gnome-look.org/CONTENT/content-files/142710-Efenniht-gtk2.tar.gz -> ${EGTK} )"
SLOT=0

RDEPEND=""
DEPEND="dev-libs/efl
	virtual/pkgconfig"

src_compile()
{
	sed -e 's,E_DESTDIR := ,E_DESTDIR := \${DESTDIR}/,' \
	    -e 's,ELM_DESTDIR := ,ELM_DESTDIR := \${DESTDIR}/,' \
	    -e '/asdf/d' -e 's,all: .*$,all: efenniht.edj,' -i Makefile || die
	emake all
}

src_install()
{
	insinto /usr/share/enlightenment/data/themes
	doins efenniht.edj
	if use gtk; then
		mv {../Efenniht-gtk2,efenniht}
		insinto /usr/share/themes
		doins -r efenniht
	fi
}

