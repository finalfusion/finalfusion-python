#!/usr/bin/env bash
set -eu

TESTDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo conversions >&2
"${TESTDIR}"/conversion.sh

echo bucket-to-explicit >&2
"${TESTDIR}"/bucket_to_explicit.sh
