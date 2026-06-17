#!/bin/bash

# Run full tests for Mozilla Thunderbird with multiple different configurations. 
# Recommended to use for every major release, like, 152.0, 153.0, etc.

### Requirements: app-portage/pkg-testing-tools
### Recommended: a container.
### With these settings, you'll need "test.conf" and "test-lto.conf" files.
### Make your own or get them from:
###  https://github.com/juippis/incus-gentoo-github-pullrequest-tester/tree/master/container/etc/portage/env
###   (https://wiki.gentoo.org/wiki/Incus/Gentoo_Github_pullrequest_testing)
###
### Usage: test_mozilla_thunderbird_gentoo.sh package-version [level (optional)]
### Example: test_mozilla_thunderbird_gentoo-max.sh 152.0 
###          test_mozilla_thunderbird_gentoo-max.sh 152.0 1
###          test_mozilla_thunderbird_gentoo-max.sh 152.0 2
###          test_mozilla_thunderbird_gentoo-max.sh 152.0 3
### Level options:
###   1: Compile with default use flags, test with clang and gcc.
###   2: Include LTO with default use flags.
###   3: Run every test - with default use flags, lto, and few sets of tests with random use flags.
### Default: level 3
### 
### For new major releases (152.0, 153.0) it's good to test everything (level 3, default).
### For minor releases (152.0.1, 152.0.2) it's enough to test with default use flags, but include 
###  lto (level 2).
### When just adding a patch or making a tiny edit to the ebuild, it's enough to test it with 
###  level 1.
###
### Thunderbird doesn't have tests enabled, and doesn't support pgo, so we can reduce the amount of
### tests run. Thunderbird is also based on Firefox which always gets thoroughly tested before a
### new Thunderbird release.

if [ -z "${1}" ]; then
    echo "Usage: $0 <package-version> [level (optional)]"
    echo "Level: 1=basic (2 tests), 2=extended (4 tests), 3=full (5 tests, default)"
    exit 1
fi

pkg="mail-client/thunderbird-${1}"

# Default to level 3 if no other input
level=${2:-3}

# Recently (105+) had some clang segfaults randomly when this was not set.
echo "sys-libs/compiler-rt clang" >> /etc/portage/package.use/compiler-rt
echo "sys-libs/compiler-rt-sanitizers clang" >> /etc/portage/package.use/compiler-rt

# Test 1: With clang, get dependencies installed right on the first run.
# Run test phase once with default use flags.
export USE="clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-tb-clang.json \
	--append-required-use '!pgo' --max-use-combinations 0 -p "=${pkg}"
unset USE

# Test 2: With gcc.
export USE="-clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-tb-gcc.json \
	--append-required-use '!pgo' --max-use-combinations 0 -p "=${pkg}"
unset USE

[ "$level" -lt 2 ] && { exit 0; }

# Test 3: With gcc+lto
export USE="-clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test-lto.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-tb-gcc-lto.json \
	--max-use-combinations 0 -p "=${pkg}"
unset USE

# Test 4: With clang+lto
export USE="clang X wayland"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test-lto.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-tb-clang-lto.json \
	--max-use-combinations 0 -p "=${pkg}"
unset USE

[ "$level" -lt 3 ] && { exit 0; }

# Test 5: Test with random use flags - no lto.
export USE="X"
pkg-testing-tool --append-emerge '--autounmask=y --oneshot' --extra-env-file 'test.conf' \
	--test-feature-scope never --report /var/tmp/portage/vbslogs/mzllprdcts-tb-misc.json \
	--append-required-use '!pgo' --max-use-combinations 4 -p "=${pkg}"
unset USE

gentoo_pkg_errors_and_qa_notices.sh
grep -r exit_code /var/tmp/portage/vbslogs/ | grep "1,"
