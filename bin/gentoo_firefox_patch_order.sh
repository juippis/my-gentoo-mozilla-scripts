#!/bin/bash

i=0
for f in $(ls *.patch | sort -u); do
    i=$((i+1));
	filename=$(echo "${f}" | cut -d"-" -f2-)
    mv "${f}" "$(printf %04d ${i})-"${filename}"";
done
