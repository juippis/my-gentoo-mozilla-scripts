#!/bin/bash

### Requirements: app-portage/pkg-testing-tools
### Recommended: a container.
###   (https://wiki.gentoo.org/wiki/User:Juippis/The_ultimate_testing_system_with_lxd)
###
### Input: test_mozilla_products-x86.sh app-category/package-version
### Example: test_mozilla_products-x86.sh www-client/firefox-90.0.1

### PGO is not supported in x86, and skip lto due to the memory requirements and 
### intensive swapping it causes.

# With GCC
export USE="-clang"
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
	--report /var/tmp/portage/vbslogs/mzllprdcts-gcc.json \
	--append-required-use '!lto !pgo' --max-use-combinations 1 -p "=${1}"
unset USE

# With clang
export USE="clang"
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope never \
	--report /var/tmp/portage/vbslogs/mzllprdcts-clang.json \
	--append-required-use '!lto !pgo' --max-use-combinations 1 -p "=${1}"
unset USE

# With randomized USE flags
pkg-testing-tool --extra-env-file 'test.conf' --test-feature-scope once \
	--report /var/tmp/portage/vbslogs/mzllprdcts-misc.json \
	--append-required-use '!lto !pgo' --max-use-combinations 4 -p "=${1}"

errors_and_qa_notices.sh
grep -r exit_code /var/tmp/portage/vbslogs/ | grep "1,"
