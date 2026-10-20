#!/usr/bin/env bash

# Vendored third-party cookbooks. This list matches the root .ignore file.
# jscpd reads .ignore while scanning the workspace. Super-linter applies
# FILTER_REGEX_EXCLUDE to every other validator's file list.
set -euo pipefail

if [[ -z "${GITHUB_ENV:-}" ]]; then
	exit 0
fi

filter='cookbooks/(chef_handler|krb5|motd|ntp|ohai|selinux|sssd_ldap|yum-fedora|yum)/'
printf 'FILTER_REGEX_EXCLUDE=%s\n' "${filter}" >>"${GITHUB_ENV}"
