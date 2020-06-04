#!/usr/bin/env bash
set -eu
tmp_dir=$(mktemp -d /tmp/run_analogy.XXXXXX)

function finish() {
  rm -rf "$tmp_dir"
}

trap finish EXIT

TESTDIR="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

EXPECTED="Deutschland
Westdeutschland
Sachsen
Mitteldeutschland
Brandenburg
Polen
Norddeutschland
Dänemark
Schleswig-Holstein
Österreich
Bayern
Thüringen
Bundesrepublik
Ostdeutschland
Preußen
Deutschen
Hessen
Potsdam
Mecklenburg
Niedersachsen
Hamburg
Süddeutschland
Bremen
Russland
Deutschlands
BRD
Litauen
Mecklenburg-Vorpommern
DDR
West-Berlin
Saarland
Lettland
Hannover
Rostock
Sachsen-Anhalt
Pommern
Schweden
Deutsche
deutschen
Westfalen"

diff <(echo Paris Frankreich Berlin | \
      ffp-analogy "${TESTDIR}/../data/simple_vocab.fifu" -k 40 | \
      cut -f 1 -d " ") \
      <(echo "${EXPECTED}")

diff <(echo Paris Frankreich Paris | \
      ffp-analogy "${TESTDIR}/../data/simple_vocab.fifu" -k 1 -i a b c | \
       cut -f 1 -d " ") \
     <(echo "Frankreich")

diff <(echo Paris Frankreich Paris | \
       ffp-analogy "${TESTDIR}/../data/simple_vocab.fifu" -k 1 -i a c | \
       cut -f 1 -d " ") \
     <(echo "Russland")

diff <(echo Frankreich Frankreich Frankreich | \
      ffp-analogy "${TESTDIR}/../data/simple_vocab.fifu" -k 1 -i a b c | \
      cut -f 1 -d " ") \
     <(echo "Frankreich")

diff <(echo Frankreich Frankreich Frankreich | \
      ffp-analogy "${TESTDIR}/../data/simple_vocab.fifu" -k 1 | \
      cut -f 1 -d " ") \
     <(echo "Russland")
