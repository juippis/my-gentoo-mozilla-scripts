#!/bin/bash

### Reorders modified patch set numerically.
### 
### Usage: 
###   cd /tmp
###   tar xf /var/cache/distfiles/firefox-91esr-patches-06j.tar.xz
###   cd firefox-patches/
###   rm 00xx*.patch
###   gentoo_firefox_patch_order.sh .
### 

i=0
for f in $(ls *.patch | sort -u); do
    i=$((i+1));
	filename=$(echo "${f}" | cut -d"-" -f2-)
    mv "${f}" "$(printf %04d ${i})-"${filename}"";
done
