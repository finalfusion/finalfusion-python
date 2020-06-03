#!/usr/bin/env bash
set -eu

tmp_dir=$(mktemp -d /tmp/bucket_to_explicit.XXXXXX)

function finish() {
  rm -rf "$tmp_dir"
}

trap finish EXIT

TESTDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function convert_and_verify() {
  echo ffp-bucket-to-explicit "${1}" -f "${2}" "${3}" >&2
  ffp-bucket-to-explicit "${1}" -f "${2}" "${3}"
  python "${TESTDIR}"/bucket_to_explicit.py "${1}" "${2}" "${3}"
}

convert_and_verify "${TESTDIR}/../data/ff_buckets.fifu" finalfusion fifu_bucket_to_expl.fifu

convert_and_verify "${TESTDIR}/../data/fasttext.bin" fasttext fasttext_to_expl.fifu