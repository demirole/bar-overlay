# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/net-print/cnijfilter/cnijfilter-3.50.ebuild,v 1.1 2012/05/26 12:12:43 -tclover Exp $

EAPI=4

inherit eutils autotools rpm flag-o-matic

DESCRIPTION="Canon InkJet Printer Driver for Linux (Pixus/Pixma-Series)."
HOMEPAGE="http://software.canon-europe.com/software/0040869.asp"
RESTRICT="nomirror confcache"

SRC_URI="http://files.canon-europe.com/files/soft40869/software/cnijfilter-source-3.50-1.tar.gz"
LICENSE="UNKNOWN" # GPL-2 source and proprietary binaries

WANT_AUTOCONF=2.59
WANT_AUTOMAKE=1.9.5

SLOT="3.50"
KEYWORDS="~x86 ~amd64"
IUSE="amd64
	servicetools
	cnijnet
	mx360
	mx410
	mx420
	mx880
	ix6550
"
REQUIRED_USE="amd64? ( !servicetools )"
DEPEND="app-text/ghostscript-gpl
	>=net-print/cups-1.1.14
	!amd64? ( sys-libs/glibc
		>=dev-libs/popt-1.6
		>=media-libs/tiff-3.4
		>=media-libs/libpng-1.0.9 )
	amd64? ( >=app-emulation/emul-linux-x86-bjdeps-0.1
		app-emulation/emul-linux-x86-compat
		app-emulation/emul-linux-x86-baselibs )
	servicetools? ( 
		!amd64? ( >=gnome-base/libglade-0.6
			>=dev-libs/libxml2-2.7.3-r2
			=x11-libs/gtk+-1.2* )
		amd64? ( >=app-emulation/emul-linux-x86-bjdeps-0.1
			app-emulation/emul-linux-x86-gtklibs )
	)
"

S="${WORKDIR}"/${PN}-source-${PV}-1

# Arrays of supported Printers, there IDs and compatible models
_pruse=("mx360" "mx410" "mx420" "mx880" "ix6550")
_prname=(${_pruse[@]})
_prid=("380" "381" "382" "383" "384")
_prcomp=("mx360series" "mx410series" "mx420series" "mx880series" "ix6500series")
_max=$((${#_pruse[@]}-1)) # used for iterating through these arrays

pkg_setup() {

	if [ -z "$LINGUAS" ]; then
		ewarn "You didn't specify 'LINGUAS' in your make.conf. Assuming"
		ewarn "english localisation, i.e. 'LINGUAS=\"en\"'."
		LINGUAS="en"
	fi

	use amd64 && multilib_toolchain_setup x86
	use cnijnet && _backend+=" backendnet"
	
	_autochoose="true"
	for i in `seq 0 ${_max}`; do
		einfo " ${_pruse[$i]}\t${_prcomp[$i]}"
		if (use ${_pruse[$i]}); then
			_autochoose="false"
		fi
	done
	einfo ""
	if (${_autochoose}); then
		ewarn "You didn't specify any driver model (set it's USE-flag)."
		einfo ""
		einfo "As example:\tbasic MX360 support without maintenance tools"
		einfo "\t\t -> USE=\"mx360\""
		einfo ""
		einfo "Press Ctrl+C to abort"
		echo
		ebeep

		n=15
		while [[ $n -gt 0 ]]; do
			echo -en "  Waiting $n seconds...\r"
			sleep 1
			(( n-- ))
		done
	fi
}

src_prepare() {
	epatch ${FILESDIR}/${PN}-${PV/50/20}-4-cups_ppd.patch || die
	epatch ${FILESDIR}/${P%-r*}-1-ldl.patch || die
	epatch ${FILESDIR}/${PN}-${PV/50/20}-4-libpng15.patch || die

	for dir in libs backend ${_backend} pstocanonij; do
		cd ${dir} || die
		libtoolize --force || die
		local amflags="$(eaclocal_amflags)"
		eaclocal ${amflags}
		eautoheader
		eautomake
		eautoreconf
		cd ..
	done

	for i in $(seq 0 ${_max}); do
		if use ${_pruse[$i]} || ${_autochoose}; then
			_pr=${_prname[$i]} _prid=${_prid[$i]}
			src_prepare_pr
		fi
	done
}

src_configure() {
	for dir in libs backend ${_backend} pstocanonij; do
		cd ${dir} || die
		econf
		cd ..
	done

	if use servicetools; then
		for dir in cngpij{,mon}; do
			cd ${dir} || die
			econf
			cd ..
		done
	fi

	for i in $(seq 0 ${_max}); do
		if use ${_pruse[$i]} || ${_autochoose}; then
			_pr=${_prname[$i]} _prid=${_prid[$i]}
			src_configure_pr
		fi
	done
}

src_compile() {
	for dir in libs backend ${_backend} pstocanonij; do
		cd ${dir} || die
		emake
		cd ..
	done

	if use servicetools; then
		for dir in cngpij{,mon}; do
			cd ${dir} || die
			emake
			cd ..
		done
	fi

	for i in $(seq 0 ${_max}); do
		if use ${_pruse[$i]} || ${_autochoose}; then
			_pr=${_prname[$i]} _prid=${_prid[$i]}
			src_compile_pr
		fi
	done
}

src_install() {
	local _cupsdir=/usr/libexec/cups/filter _ppddir=/usr/share/cups/model
	local _libdir=/usr/$(get_libdir)
	mkdir -p "${D}$(get_bindir)" || die
	mkdir -p "${D}${_libdir}"/cups/filter || die
	mkdir -p "${D}${_libdir}"/cnijlib || die
	mkdir -p "${D}${_cupsdir}" || die
	mkdir -p "${D}${_ppddir}"
	for dir in libs backend ${_backend} pstocanonij; do
		cd ${dir} || die
		emake DESTDIR="${D}" install || die
		cd ..
	done

	if use servicetools; then
		for dir in cngpij{,mon}; do
			cd ${dir} || die
			emake DESTDIR="${D}" || die
			cd ..
		done
	fi

	for i in $(seq 0 ${_max}); do
		if use ${_pruse[$i]} || ${_autochoose}; then
			_pr=${_prname[$i]} _prid=${_prid[$i]}
			src_install_pr
		fi
	done

	# fix directory structure and slot
	mv "${D}${_libdir}"/cups/filter/pstocanonij "${D}${_cupsdir}${SLOT}" || die
}

pkg_postinst() {
	einfo ""
	einfo "For installing a printer:"
	einfo " * Restart CUPS: /etc/init.d/cupsd restart"
	einfo " * Go to http://127.0.0.1:631/"
	einfo "   -> Printers -> Add Printer"
	einfo ""
	einfo "If you experience any problems, please visit:"
	einfo " http://forums.gentoo.org/viewtopic-p-3217721.html"
	einfo "https://bugs.gentoo.org/show_bug.cgi?id=258244"
}

src_prepare_pr() {
	mkdir ${_pr}
	cp -a ${_prid} ${_pr} || die
	cp -a cnijfilter ${_pr} || die
	cp -a printui ${_pr} || die
	cp -a lgmon ${_pr} || die
#	cp -a stsmon ${_pr} || die

	cd ${_pr}/cnijfilter || die
	libtoolize --force
	amflags="$(eaclocal_amflags)"
	eaclocal ${amflags}
	eautoheader
	eautomake
	eautoreconf
	cd ..

	if use servicetools; then
		for dir in printui logmon; do
			cd ${dir} || die
			libtoolize --force --copy
			amflags="$(eaclocal_amflags)"
			eaclocal ${amflags}
			eautoheader
			eautomake
			eautoreconf
			cd ..
		done
	fi
	cd ..
}

src_configure_pr() {
	cd ${_pr}/cnijfilter || die
	econf --program-suffix=${_pr}
	cd ..

	if use servicetools; then
		for dir in printui logmon; do
			cd ${dir} || die
			econf --program-suffix=${_pr}
			cd ..
		done
	fi
	cd ..
}

src_compile_pr() {
	cd ${_pr}/cnijfilter || die
	emake || die "couldn't make ${_pr}/cnijfilter"
	cd ..

	if use servicetools; then
		for dir in printui logmon; do
			cd ${dir} || die
			emake || die "couldn't make ${_pr}/${dir}"
			cd ..
		done
	fi
	cd ..
}

src_install_pr() {
	cd ${_pr}/cnijfilter || die
	emake DESTDIR="${D}" install || die "couldn't make install ${_pr}/cnijfilter"
	cd ..

	if use servicetools; then
		for dir in printui logmon; do
			cd ${dir} || die
			emake DESTDIR="${D}" install || die "couldn't make install ${_pr}/${dir}"
			cd ..
		done
	fi
	cd ..

	cp -a ${_prid}/libs_bin/* "${D}${_libdir}" || die
	cp -a ${_prid}/database/* "${D}${_libdir}"/cnijlib || die
	cp -a ppd/canon${_pr}.ppd "${D}${_ppddir}" || die
}
