#!/bin/bash

### Usage: gentoo_mozilla_products_vbump_differ.sh product-ver1 product-ver2
### Examples: 
###   gentoo_mozilla_products_vbump_differ.sh firefox-91.5.3 firefox-91.6.0
###   gentoo_mozilla_products_vbump_differ.sh nss 3.68.3 nss-3.68.4
###   gentoo_mozilla_products_vbump_differ.sh nss-3.76 nss-3.77
###   gentoo_mozilla_products_vbump_differ.sh spidermonkey-91.6.0 spidermonkey-91.7.0
###   gentoo_mozilla_products_vbump_differ.sh thunderbird-91.6.2 thunderbird-91.7.0
### 
### Note: 
###   You can set your portage's DISTDIR like this:
###     DISTDIR=/my/custom/distdir gentoo_mozilla_products_vbump_differ.sh ...
###
###   by default, `portageq envvar 'DISTDIR'` will be used.
###

: "${DISTDIR:=$(portageq envvar 'DISTDIR')}"


firefoxbump=0
nssbump=0
nsprbump=0
spidermonkeybump=0
thunderbirdbump=0


product=$(echo "${1}" | cut -d "-" -f1)
ver1=$(echo "${1}" | cut -d "-" -f2)
ver2=$(echo "${2}" | cut -d "-" -f2)


firefoxdiffarray=(
	browser/locales/all-locales
	mach
	Makefile.in
	aclocal.m4
	build/build_virtualenv_packages.txt
	build/common_virtualenv_packages.txt
	build/mach_initialize.py
	build/mach_virtualenv_packages.txt
	build/moz.configure
	build/moz.configure/bootstrap.configure
	build/zstandard_requirements.in
	build/zstandard_requirements.txt
	config/Makefile.in
	config/baseconfig.mk
	config/config.mk
	nsprpub/configure
	old-configure.in
	python/docs/index.rst
	python/mach/mach/site.py
	python/mozboot/mozboot/base.py
	python/mozboot/mozboot/util.py
	python/mozbuild/mozbuild/base.py
	python/mozbuild/mozbuild/mozinfo.py
	python/mozbuild/mozbuild/nodeutil.py
	taskcluster/ci/build/kind.yml
	taskcluster/ci/build/linux-base-toolchains.yml
	taskcluster/ci/build/linux.yml
	taskcluster/ci/instrumented-build/kind.yml
	taskcluster/docker/debian-base/Dockerfile
	taskcluster/docker/fetch/Dockerfile
	taskcluster/scripts/builder/build-l10n.sh
	taskcluster/scripts/builder/build-linux.sh
	tools/mach_initialize.py
	browser/app/moz.build
	browser/base/moz.build
	browser/branding/official/locales/moz.build
	browser/components/build/moz.build
	browser/components/moz.build
	browser/extensions/moz.build
	browser/extensions/translations/moz.build
	browser/fonts/moz.build
	browser/locales/moz.build
	browser/modules/moz.build
	browser/moz.build
	browser/moz.configure
	browser/tools/mozscreenshots/moz.build
	build/moz.build
	build/unix/elfhack/moz.build
	build/unix/moz.build
	build/moz.configure/flags.configure
	build/moz.configure/headers.configure
	build/moz.configure/init.configure
	build/moz.configure/lto-pgo.configure
	build/moz.configure/nspr.configure
	build/moz.configure/nss.configure
	build/moz.configure/old.configure
	build/moz.configure/toolchain.configure
	build/moz.configure/update-programs.configure
	chrome/moz.build
	config/external/icu/moz.build
	config/external/moz.build
	config/external/nspr/moz.build
	config/external/sqlite/moz.build
	config/external/zlib/moz.build
	config/moz.build
	dom/media/eme/moz.build
	dom/moz.build
	gfx/cairo/cairo/src/moz.build
	gfx/cairo/moz.build
	gfx/moz.build
	gfx/skia/moz.build
	image/encoders/moz.build
	image/moz.build
	js/moz.build
	js/moz.configure
	js/src/moz.build
	js/src/util/moz.build
	media/ffvpx/libavcodec/moz.build
	media/ffvpx/libavutil/moz.build
	media/ffvpx/moz.build
	media/libaom/moz.build
	media/libvpx/moz.build
	media/libwebp/moz.build
	media/libwebp/src/moz/moz.build
	media/moz.build
	memory/build/moz.build
	memory/moz.build
	memory/moz.configure
	mobile/android/moz.configure
	modules/moz.build
	moz.build
	moz.configure
	other-licenses/moz.build
	python/moz.build
	security/apps/moz.build
	security/moz.build
	servo/moz.build
	storage/build/moz.build
	storage/moz.build
	third_party/moz.build
	toolkit/components/build/moz.build
	toolkit/components/moz.build
	toolkit/moz.build
	toolkit/moz.configure
	tools/crashreporter/injector/moz.configure
	tools/crashreporter/moz.configure
	tools/moz.build
	tools/rusttests/moz.configure
	tools/update-packaging/moz.configure
	tools/update-programs/moz.configure
	widget/gtk/moz.build
	widget/gtk/mozgtk/moz.build
	widget/gtk/mozwayland/moz.build
	widget/gtk/wayland/moz.build
	widget/moz.build
	widget/x11/moz.build
)

nssdiffarray=(
	nss/Makefile
	nss/build.sh
	nss/exports.gyp
	nss/mach
	nss/nss.gyp
	nss/coreconf/Linux.mk
	nss/coreconf/Makefile
	nss/coreconf/README
	nss/coreconf/arch.mk
	nss/coreconf/config.mk
)

nsprdiffarray=()

spidermonkeydiffarray=(
	js/moz.build
	js/moz.configure
	js/src/configure.in
	js/src/doc/build.rst
	js/src/moz.build
	js/src/old-configure.in
	js/src/util/moz.build
)

thunderbirddiffarray=(
	comm/moz.build
	comm/build/mach_initialize.py
	comm/build/moz.configure/gecko_source.configure
	comm/calendar/base/backend/moz.build
	comm/calendar/base/moz.build
	comm/calendar/base/src/moz.build
	comm/calendar/moz.build
	comm/chat/modules/moz.build
	comm/chat/moz.build
	comm/ldap/modules/moz.build
	comm/ldap/moz.build
	comm/mail/app/moz.build
	comm/mail/base/moz.build
	comm/mail/moz.build
	comm/mail/moz.configure
	comm/mailnews/addrbook/moz.build
	comm/mailnews/base/moz.build
	comm/mailnews/base/src/moz.build
	comm/mailnews/build/moz.build
	comm/mailnews/compose/moz.build
	comm/mailnews/compose/src/moz.build
	comm/mailnews/db/moz.build
	comm/mailnews/mime/moz.build
	comm/mailnews/mime/src/moz.build
	comm/mailnews/moz.build
	comm/mailnews/moz.configure
	comm/mailnews/news/moz.build
	comm/python/moz.build
	comm/suite/app/moz.build
	comm/suite/base/moz.build
	comm/suite/browser/moz.build
	comm/suite/extensions/moz.build
	comm/suite/locales/moz.build
	comm/suite/mailnews/moz.build
	comm/suite/modules/moz.build
	comm/suite/moz.build
	comm/suite/moz.configure
	comm/third_party/moz.build
)


if grep -q "firefox" <<< "${product}"; then
	echo "DEBUG: firefox"
	firefoxbump=1

elif grep -q "nss" <<< "${product}"; then
	echo "DEBUG: nss"
	nssbump=1

elif grep -q "nspr" <<< "${product}"; then
	echo "DEBUG: nspr"
	nsprbump=1

elif grep -q "spidermonkey" <<< "${product}"; then
	echo "DEBUG: spidermonkey"
	spidermonkeybump=1

elif grep -q "thunderbird" <<< "${product}"; then
	echo "DEBUG: thunderbird"
	thunderbirdbump=1

else
	echo "Can't figure out what to do! Exiting."
	exit
fi


mkdir -p /tmp/mozillaproducts || exit
cd /tmp/mozillaproducts || exit


if [[ ${firefoxbump} -eq 1 ]]; then
	if [[ ! -f ./${1}.source.tar.xz ]] && 
	[[ ! -f ./${1}esr.source.tar.xz ]]; then
		if [[ -f ${DISTDIR}/${1}.source.tar.xz ]]; then
			cp "${DISTDIR}"/${1}.source.tar.xz .
		elif [[ -f ${DISTDIR}/${1}esr.source.tar.xz ]]; then
			cp "${DISTDIR}"/${1}esr.source.tar.xz .
		else
			wget https://archive.mozilla.org/pub/firefox/releases/${ver1}/source/firefox-${ver1}.source.tar.xz
			wget https://archive.mozilla.org/pub/firefox/releases/${ver1}esr/source/firefox-${ver1}esr.source.tar.xz
		fi
	fi
	
    if [[ ! -f ./${2}.source.tar.xz ]] && 
    [[ ! -f ./${2}esr.source.tar.xz ]]; then
        if [[ -f ${DISTDIR}/${2}.source.tar.xz ]]; then
            cp "${DISTDIR}"/${2}.source.tar.xz .
        elif [[ -f ${DISTDIR}/${2}esr.source.tar.xz ]]; then
            cp "${DISTDIR}"/${2}esr.source.tar.xz .
        else
            wget https://archive.mozilla.org/pub/firefox/releases/${ver2}/source/firefox-${ver2}.source.tar.xz
            wget https://archive.mozilla.org/pub/firefox/releases/${ver2}esr/source/firefox-${ver2}esr.source.tar.xz
		fi
	fi

	if [[ ! -d ${1} ]]; then
		tar xf ./${1}.source.tar.xz || tar xf ./${1}esr.source.tar.xz
	fi
	if [[ ! -d ${2} ]]; then
		tar xf ./${2}.source.tar.xz || tar xf ./${2}esr.source.tar.xz
	fi

	rm ./${1}_vs_${2}.txt
	touch ./${1}_vs_${2}.txt

	for i in "${firefoxdiffarray[@]}"; do
		diff -Naur ${1}/"${i}" ${2}/"${i}" >> ./${1}_vs_${2}.txt
	done

	echo "./${1}_vs_${2}.txt was made for later reviewing."
	less ./${1}_vs_${2}.txt
fi


if [[ ${nssbump} -eq 1 ]]; then
	if [[ ! -f ./${1}.tar.gz ]]; then
		if [[ -f ${DISTDIR}/${1}.tar.gz ]]; then
			cp "${DISTDIR}"/${1}.tar.gz .
		else
			wget https://archive.mozilla.org/pub/security/nss/releases/NSS_${ver1//./_}_RTM/src/${1}.tar.gz
		fi
	fi

	if [[ ! -f ./${2}.tar.gz ]]; then
		if [[ -f ${DISTDIR}/${2}.tar.gz ]]; then
			cp "${DISTDIR}"/${2}.tar.gz .
		else
			wget https://archive.mozilla.org/pub/security/nss/releases/NSS_${ver2//./_}_RTM/src/${2}.tar.gz
		fi
	fi

	[[ ! -d ${1} ]] && tar -xzf ./${1}.tar.gz
	[[ ! -d ${2} ]] && tar -xzf ./${2}.tar.gz

	rm -f ./${1}_vs_${2}.txt
	touch ./${1}_vs_${2}.txt

	for l in "${nssdiffarray[@]}"; do
		diff -Naur ${1}/"${l}" ${2}/"${l}" >> ./${1}_vs_${2}.txt
	done

	echo "./${1}_vs_${2}.txt was made for later reviewing."
	less ./${1}_vs_${2}.txt
fi


if [[ ${spidermonkeybump} -eq 1 ]]; then
	if [[ ! -f ./firefox-${ver1}esr.source.tar.xz ]]; then
		if [[ -f ${DISTDIR}/firefox-${ver1}esr.source.tar.xz ]]; then
			cp "${DISTDIR}"/firefox-${ver1}esr.source.tar.xz .
		else
			wget https://archive.mozilla.org/pub/firefox/releases/${ver1}esr/source/firefox-${ver1}esr.source.tar.xz
		fi
	fi

	if [[ ! -f ./firefox-${ver2}esr.source.tar.xz ]]; then
		if [[ -f ${DISTDIR}/firefox-${ver2}.source.tar.xz ]]; then
			cp "${DISTDIR}"/firefox-${ver2}esr.source.tar.xz .
		else
			wget https://archive.mozilla.org/pub/firefox/releases/${ver1}esr/source/firefox-${ver2}esr.source.tar.xz
		fi
	fi

	[[ ! -d firefox-${ver1} ]] && tar xf ./firefox-${ver1}esr.source.tar.xz
	[[ ! -d firefox-${ver2} ]] && tar xf ./firefox-${ver2}esr.source.tar.xz

	rm -f ./${1}_vs_${2}.txt
	touch ./${1}_vs_${2}.txt

	for j in "${spidermonkeydiffarray[@]}"; do
		diff -Naur firefox-${ver1}/"${j}" firefox-${ver2}/"${j}" >> ./${1}_vs_${2}.txt
	done

	echo "./${1}_vs_${2}.txt was made for later reviewing."
	less ./${1}_vs_${2}.txt
fi


if [[ ${thunderbirdbump} -eq 1 ]]; then
	if [[ ! -f ./${1}.source.tar.xz ]]; then
		if [[ -f ${DISTDIR}/${1}.source.tar.xz ]]; then
			cp "${DISTDIR}"/${1}.source.tar.xz .
		else
			wget https://archive.mozilla.org/pub/thunderbird/releases/${ver1}/source/${1}.source.tar.xz
		fi
	fi

	if [[ ! -f ./${2}.source.tar.xz ]]; then
		if [[ -f ${DISTDIR}/${2}.source.tar.xz ]]; then
			cp "${DISTDIR}"/${2}.source.tar.xz .
		else
			wget https://archive.mozilla.org/pub/thunderbird/releases/${ver2}/source/${2}.source.tar.xz
		fi
	fi

	[[ ! -d ${1} ]] && tar xf ./${1}.source.tar.xz
	[[ ! -d ${2} ]] && tar xf ./${2}.source.tar.xz

	rm -f ./${1}_vs_${2}.txt
	touch ./${1}_vs_${2}.txt

	for k in "${thunderbirddiffarray[@]}"; do
		diff -Naur ${1}/"${k}" ${2}/"${k}" >> ./${1}_vs_${2}.txt
	done

	echo "./${1}_vs_${2}.txt was made for later reviewing."
	less ./${1}_vs_${2}.txt
fi

