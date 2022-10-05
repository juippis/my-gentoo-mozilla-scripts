#!/bin/bash

### Requirements: app-portage/pkg-testing-tools
### Recommended: a container.
###   (https://wiki.gentoo.org/wiki/User:Juippis/The_ultimate_testing_system_with_lxd)
###
### Input: test_mozilla_products-amd64.sh app-category/package-version
### Example: test_mozilla_products-amd64.sh www-client/firefox-90.0.1

### 
### Since 'lto' and 'pgo' are usually the cause for any breakage, split runs to 
### focus on them explicitly, and ignore 'pgo' for "regular" runs.
###

# Recently (105+) had some clang segfaults randomly when this was not set.
echo "sys-libs/compiler-rt clang" >> /etc/portage/package.use/compiler-rt
echo "sys-libs/compiler-rt-sanitizers clang" >> /etc/portage/package.use/compiler-rt

# With clang, get dependencies installed right on the first run
export USE="clang X wayland"
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
	--report /var/tmp/portage/vbslogs/mzllprdcts-clang.json \
	--append-required-use '!lto !pgo' --max-use-combinations 1 -p "=${1}"
unset USE

# With gcc
export USE="-clang X wayland"
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
	--report /var/tmp/portage/vbslogs/mzllprdcts-gcc.json \
	--append-required-use '!lto !pgo' --max-use-combinations 1 -p "=${1}"
unset USE

# With gcc+lto+pgo
export USE="-clang lto pgo"
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
    --report /var/tmp/portage/vbslogs/mzllprdcts-gcc-ltopgo.json \
    --max-use-combinations 1 -p "=${1}"
unset USE

# with clang+lto+pgo
export USE="clang lto pgo"
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
    --report /var/tmp/portage/vbslogs/mzllprdcts-clang-ltopgo.json \
    --max-use-combinations 1 -p "=${1}"
unset USE

# With randomized USE flags, usually lto gets tested without pgo here.
# Skip +pgo since it's been tested already, and to save time.
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope once \
	--report /var/tmp/portage/vbslogs/mzllprdcts-misc.json \
	--append-required-use '!pgo' --max-use-combinations 6 -p "=${1}"

errors_and_qa_notices.sh
grep -r exit_code /var/tmp/portage/vbslogs/ | grep "1,"
