#!/usr/bin/env bash
set -eu

tmp_dir=$(mktemp -d /tmp/run_conversion.XXXXXX)

function finish() {
  rm -rf "$tmp_dir"
}

trap finish EXIT

TESTDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function convert_and_verify() {
  echo ffp-convert "${1}" -f "${2}" "${3}" -t "${4}" >&2
  ffp-convert "${1}" -f "${2}" "${3}" -t "${4}"
  python "${TESTDIR}"/conversion.py "${1}" "${2}" "${3}" "${4}"
}

function verify_all_conversions() {
  local input=${1}
  local in_format=${2}
  local out_path_prefix=${tmp_dir}/${in_format}
  convert_and_verify "${input}" "${in_format}" "${out_path_prefix}_to_fifu.fifu" finalfusion
  convert_and_verify "${input}" "${in_format}" "${out_path_prefix}_to_w2v.w2v" word2vec
  convert_and_verify "${input}" "${in_format}" "${out_path_prefix}_to_ft.bin" fasttext
  convert_and_verify "${input}" "${in_format}" "${out_path_prefix}_to_text.txt" text
  convert_and_verify "${input}" "${in_format}" "${out_path_prefix}_to_text.dims.txt" textdims
}

# txt dims
input="${TESTDIR}/../data/embeddings.dims.txt"
verify_all_conversions "${input}" textdims

# txt
input="${TESTDIR}/../data/embeddings.txt"
verify_all_conversions  "${input}" text

# w2v
input="${TESTDIR}/../data/embeddings.w2v"
verify_all_conversions  "${input}" word2vec

# fifu
input="${TESTDIR}/../data/embeddings.fifu"
verify_all_conversions  "${input}" finalfusion

# fasttext doesn't support fifu bucket indexers
# so we're making explicit calls for the other formats
input="${TESTDIR}/../data/ff_buckets.fifu"
convert_and_verify "${input}" finalfusion \
  "${tmp_dir}/fifu_buckets_to_fifu.fifu" finalfusion
convert_and_verify "${input}" finalfusion \
  "${tmp_dir}/fifu_buckets_to_w2v.w2v" word2vec
convert_and_verify "${input}" finalfusion \
  "${tmp_dir}/fifu_buckets_to_text.txt" text
convert_and_verify "${input}" finalfusion \
  "${tmp_dir}/fifu_buckets_to_text.dims.txt" textdims

input="${TESTDIR}/../data/fasttext.bin"
verify_all_conversions  "${input}" fasttext
