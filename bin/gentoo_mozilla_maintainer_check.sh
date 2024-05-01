#!/bin/bash

###
### Depends on app-portage/gentoolkit and net-misc/curl.
###
### "emerge --sync" before running this!
###
### Usage: 
### DEVREPO=~/git/gentoo gentoo_mozilla_maintainer_check.sh
###  where DEVREPO is the location to your development repository with git history present.
###  defaults to `pwd`.


: "${DEVREPO:=$(pwd)}"


# Declare colours.
DEF='\033[0m'
RED='\033[0;31m'

# Declare the default output message.
OUT="${RED}out of date, visit${DEF}"

# Declare arrays.
outdatedarray=()
pkgcheckscanpackages=()

# Curl arguments, where user agent needs to be changed.
curlagentargs="-A \"Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0\""

# Basic function to cover most cases. Strip out:
#  - any *9999* versions,
#  - "[I]" which means the version is currently installed in host system,
#  - -rX Gentoo-specific ebuild revisions.

gentooVersionCheck() {
    local versionResult
    versionResult=$(equery y "${1}" | sed -e '/.*9999.*/d' -e 's/\[I\]//g' -e 's/\[M\]//g' -e 's/-r[0-9]*//' | tail -n1 | cut -d "|" -f 1 | sed 's/ //g')
    echo "${versionResult}"
}

# Basic
cbindgengentoo=$(gentooVersionCheck "dev-util/cbindgen")
firefoxrapidgentoo=$(gentooVersionCheck "www-client/firefox")
geckodrivergentoo=$(gentooVersionCheck "net-misc/geckodriver")
librnpgentoo=$(gentooVersionCheck "dev-util/librnp")
nsprgentoo=$(gentooVersionCheck "dev-libs/nspr")
nssgentoo=$(gentooVersionCheck "dev-libs/nss")
nsspemgentoo=$(gentooVersionCheck "dev-libs/nss-pem")
nvidiavaapidrivergentoo=$(gentooVersionCheck "media-libs/nvidia-vaapi-driver")
openh264gentoo=$(gentooVersionCheck "media-libs/openh264")
sexppgentoo=$(gentooVersionCheck "dev-libs/sexpp")
spidermonkeygentoo=$(gentooVersionCheck "dev-lang/spidermonkey")
thunderbirdgentoo=$(gentooVersionCheck "mail-client/thunderbird")

# Temporary workarounds
# openh264gentoo=$(gentooVersionCheck "media-libs/openh264" | sed 's/_p.*//')


cbindgenlatest=$(curl -s https://api.github.com/repos/mozilla/cbindgen/tags | grep -oP '([0-9]+\.?)+' | head -n1)
[[ $cbindgenlatest != "$cbindgengentoo" ]] &&
	outdatedarray+=( "cbindgen ${OUT} https://github.com/mozilla/cbindgen/tags" )

# Match Firefox-ESR to packaged one in repo:
# firefoxesrlatest=$(curl -s https://archive.mozilla.org/pub/firefox/releases/ | grep "esr/" | tail -2 | head -1 | grep -oP '(?<=esr/">).*(?=/</a>)' | cut -d"e" -f1)
firefoxesrlatest=$(curl -sL https://www.mozilla.org/en-US/firefox/organizations/notes/ | grep -oP '(?<=data-esr-versions=").*(?=" data-gtm-cont)')
if ! grep -q "${firefoxesrlatest}" < <(equery y www-client/firefox); then
	outdatedarray+=( "Firefox-ESR ${OUT} https://archive.mozilla.org/pub/firefox/releases/ ${firefoxesrlatest}/esr" )
	outdatedarray+=( "	https://www.mozilla.org/en-US/firefox/${firefoxesrlatest}/releasenotes/" ) && 
	outdatedarray+=( "	https://github.com/mozilla/release-notes/blob/master/releases/firefox-${firefoxesrlatest}-esr.json" )
fi

firefoxrapidlatest=$(curl "${curlagentargs}" -s "https://repology.org/project/firefox/history" | grep -oP '(?<=class="version version-big version-newest">).*(?=</span>)' | head -n1)
[[ $firefoxrapidlatest != "$firefoxrapidgentoo" ]] && 
	outdatedarray+=( "Firefox-rapid ${OUT} https://archive.mozilla.org/pub/firefox/releases/ ${firefoxrapidlatest}" ) &&
	outdatedarray+=( "	https://www.mozilla.org/en-US/firefox/${firefoxrapidlatest}/releasenotes/" ) && 
	outdatedarray+=( "	https://github.com/mozilla/release-notes/blob/master/releases/firefox-${firefoxrapidlatest}-release.json" )

geckodriverlatest=$(curl -s https://api.github.com/repos/mozilla/geckodriver/tags | grep -oP '([0-9]+\.?)+' | head -n1)
[[ $geckodriverlatest != "$geckodrivergentoo" ]] &&
	outdatedarray+=( "Geckodriver ${OUT} https://github.com/mozilla/geckodriver/releases" )

librnplatest=$(curl -s https://api.github.com/repos/rnpgp/rnp/releases/latest | grep -o "\"tag_name\".*" | grep -oP '([0-9]+\.?)+')
[[ $librnplatest != "$librnpgentoo" ]] &&
	outdatedarray+=( "librnp ${OUT} https://github.com/rnpgp/rnp/tags" )

nsprlatest=$(curl "${curlagentargs}" -s "https://repology.org/project/nspr/history" | grep -oP '(?<=class="version version-big version-newest">).*(?=</span>)' | head -n1)
[[ $nsprlatest != "$nsprgentoo" ]] &&
	outdatedarray+=( "NSPR ${OUT} https://archive.mozilla.org/pub/nspr/releases/ ${nsprlatest}" )

nssesrlatest=$(curl -s https://firefox-source-docs.mozilla.org/security/nss/releases/index.html | grep "latest ESR" | grep -oP '([0-9]+\.?)+')
if ! grep -q "${nssesrlatest}" < <(equery y dev-libs/nss); then
	outdatedarray+=( "NSS (ESR) ${OUT} https://wiki.mozilla.org/NSS:Release_Versions ${nssesrlatest}" ) && 
	outdatedarray+=( "  https://hg.mozilla.org/projects/nss/file/tip/doc/rst/releases" )
fi

nsslatest=$(curl "${curlagentargs}" -s "https://repology.org/project/nss/history" | grep -oP '(?<=class="version version-big version-newest">).*(?=</span>)' | head -n1)
[[ $nsslatest != "$nssgentoo" ]] &&
	outdatedarray+=( "NSS ${OUT} https://archive.mozilla.org/pub/security/nss/releases/ ${nsslatest}" ) && 
	outdatedarray+=( "  https://hg.mozilla.org/projects/nss/file/tip/doc/rst/releases" )

nsspemlatest=$(curl -s https://api.github.com/repos/kdudka/nss-pem/tags | grep -o "\"name\".*" | head -n1 | grep -oP '([0-9]+\.?)+')
[[ $nsspemlatest != "$nsspemgentoo" ]] &&
	outdatedarray+=( "nss-pem ${OUT} https://github.com/kdudka/nss-pem/tags" )

nvidiavaapidriverlatest=$(curl -s https://api.github.com/repos/elFarto/nvidia-vaapi-driver/tags | grep -o "\"name\".*" | head -n1 | grep -oP '([0-9]+\.?)+')
[[ $nvidiavaapidriverlatest != "$nvidiavaapidrivergentoo" ]] &&
	outdatedarray+=( "nvidia-vaapi-driver ${OUT} https://github.com/elFarto/nvidia-vaapi-driver" )

openh264latest=$(curl -s https://api.github.com/repos/cisco/openh264/releases/latest | grep -o "\"tag_name\".*" | grep -oP '([0-9]+\.?)+')
[[ $openh264latest != "$openh264gentoo" ]] &&
	outdatedarray+=( "openh264 ${OUT} https://github.com/cisco/openh264/releases" ) &&
	outdatedarray+=( "	https://github.com/mozilla/gmp-api/tags" )

sexpplatest=$(curl -s https://api.github.com/repos/rnpgp/sexpp/releases/latest | grep -o "\"tag_name\".*" | grep -oP '([0-9]+\.?)+')
[[ $sexpplatest != "$sexppgentoo" ]] &&
	outdatedarray+=( "sexpp ${OUT} https://github.com/rnpgp/sexpp/releases" )

spidermonkeylatest=$(curl "${curlagentargs}" -s "https://repology.org/project/spidermonkey/history" | grep -oP '(?<=class="version version-big version-newest">).*(?=</span>)' | head -n1)
[[ $spidermonkeylatest != "$spidermonkeygentoo" ]] &&
	outdatedarray+=( "Spidermonkey ${OUT} https://repology.org/project/spidermonkey/history" )

thunderbirdlatest=$(curl -s https://raw.githubusercontent.com/mozilla-releng/product-details/production/public/1.0/thunderbird_versions.json | grep "LATEST_THUNDERBIRD_VERSION" | cut -d \" -f4)
[[ $thunderbirdlatest != "$thunderbirdgentoo" ]] &&
	outdatedarray+=( "Thunderbird ${OUT} https://archive.mozilla.org/pub/thunderbird/releases/ ${thunderbirdlatest}" ) &&
	outdatedarray+=( "	https://www.thunderbird.net/en-US/thunderbird/${thunderbirdlatest}/releasenotes/" )

echo ""

if [[ ${#outdatedarray[@]} -eq 0 ]]; then
    echo "(all up-to-date)"
else
    for i in "${outdatedarray[@]}"; do echo -e "${i}"; done
fi


# pkgcheck checks

cd "${DEVREPO}" || exit
mapfile -t pkgcheckscanpackages < <(git grep -l mozilla@gentoo.org '**/metadata.xml' |  cut -d/ -f1-2)

echo ""
echo "--------------------"
echo ""
echo ""
sleep 1
echo "Package version checks:"
echo ""

for j in "${pkgcheckscanpackages[@]}"; do
    pkgcheck --color true scan "${j}" -c RedundantVersionCheck,StableRequestCheck
done

sleep 1
echo ""
echo "--------------------"
echo ""
echo ""
sleep 1
echo "Packages that have PYTHON_COMPAT available:"
echo ""

for l in "${pkgcheckscanpackages[@]}"; do
    pkgcheck --color true scan "${l}" -k PythonCompatUpdate -f latest
done

sleep 1
echo ""
echo "--------------------"

cd ~ || exit
