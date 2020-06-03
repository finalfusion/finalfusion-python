#!/usr/bin/env bash
set -eu

TESTDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ -v OS ] && [ "${OS}" = Windows_NT ]; then
    export PYTHONIOENCODING=utf-8
    export PYTHONUTF8=1
fi

echo conversions >&2
"${TESTDIR}"/conversion.sh

echo bucket-to-explicit >&2
"${TESTDIR}"/bucket_to_explicit.sh

echo similarity >&2
"${TESTDIR}"/similarity.sh

echo analogy >&2
"${TESTDIR}"/analogy.sh
