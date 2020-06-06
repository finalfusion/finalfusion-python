#!/usr/bin/env bash
set -eu
tmp_dir=$(mktemp -d /tmp/run_select.XXXXXX)

function finish() {
  rm -rf "$tmp_dir"
}

trap finish EXIT

TESTDIR="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

function select_and_verify() {
    echo ffp-select "${2}" "${tmp_dir}/ff_buckets_selected.fifu" >&2
    ffp-select "${2}" "${3}" < "${1}" >&2
    python "${TESTDIR}"/check_select.py "${1}" "${2}" "${3}"
}

WORDS="${TESTDIR}"/select_buckets.txt
EMBEDS="${TESTDIR}/../data/ff_buckets.fifu"
OUTPUT="${tmp_dir}/ff_buckets_selected.fifu"
select_and_verify "${WORDS}" "${EMBEDS}" "${OUTPUT}"

WORDS=${tmp_dir}/one.txt
echo "one" > "${WORDS}"
echo "two" >> "${WORDS}"
EMBEDS="${TESTDIR}/../data/embeddings.fifu"
OUTPUT="${tmp_dir}/simple_selected.fifu"
select_and_verify "${WORDS}" "${EMBEDS}" "${OUTPUT}"
