#!/bin/bash

### Requirements: app-portage/pkg-testing-tools
### Recommended: a container.
### With these settings, you'll need "test.conf" and "test-lto.conf" files.
### Make your own or get them from:
###  https://github.com/juippis/incus-gentoo-github-pullrequest-tester/tree/master/container/etc/portage/env
###   (https://wiki.gentoo.org/wiki/Incus/Gentoo_Github_pullrequest_testing)
###
### Input: test_mozilla_thunderbird_gentoo.sh app-category/package-version
### Example: test_mozilla_thunderbird_gentoo.sh mail-client/thunderbird-128.5.0

### PGO is not supported in Thunderbird, and since TB is based on Firefox-ESR
### which is always thoroughly tested before a new version of TB is out, we 
### can reduce runs needed for TB.

# Recently (105+) had some clang segfaults randomly when this was not set.
echo "sys-libs/compiler-rt clang" >> /etc/portage/package.use/compiler-rt
echo "sys-libs/compiler-rt-sanitizers clang" >> /etc/portage/package.use/compiler-rt

# With clang, get dependencies right on the first run.
export USE="clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-clang.json \
	--append-required-use '!pgo' --max-use-combinations 0 -p "=${1}"
unset USE

# With gcc.
export USE="-clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-gcc.json \
	--append-required-use '!pgo' --max-use-combinations 0 -p "=${1}"
unset USE

# With gcc+lto.
export USE="-clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test-lto.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-gcc-lto.json \
	--append-required-use '!pgo' --max-use-combinations 0 -p "=${1}"
unset USE

# With clang+lto.
export USE="clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test-lto.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-clang-lto.json \
	--append-required-use '!pgo' --max-use-combinations 0 -p "=${1}"
unset USE

# Test with random use flags - no lto.
export USE="X"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-misc.json \
	--append-required-use '!pgo' --max-use-combinations 4 -p "=${1}"
unset USE

gentoo_pkg_errors_and_qa_notices.sh
grep -r exit_code /var/tmp/portage/vbslogs/ | grep "1,"
