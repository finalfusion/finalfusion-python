#!/usr/bin/env bash
set -eu
tmp_dir=$(mktemp -d /tmp/run_similarity.XXXXXX)

function finish() {
  rm -rf "$tmp_dir"
}

trap finish EXIT

TESTDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

EXPECTED="Karlsruhe
Mannheim
München
Darmstadt
Heidelberg
Wiesbaden
Kassel
Düsseldorf
Leipzig
Berlin"

diff <(echo Stuttgart | ffp-similar "tests/data/similarity.fifu" | cut -f 1 -d " ") <(echo "${EXPECTED}")

EXPECTED="Potsdam
Hamburg
Leipzig
Dresden
München
Düsseldorf
Bonn
Stuttgart
Weimar
Berlin-Charlottenburg
Rostock
Karlsruhe
Chemnitz
Breslau
Wiesbaden
Hannover
Mannheim
Kassel
Köln
Danzig
Erfurt
Dessau
Bremen
Charlottenburg
Magdeburg
Neuruppin
Darmstadt
Jena
Wien
Heidelberg
Dortmund
Stettin
Schwerin
Neubrandenburg
Greifswald
Göttingen
Braunschweig
Berliner
Warschau
Berlin-Spandau"
diff <(echo Berlin | ffp-similar "tests/data/similarity.fifu" -k 40 | cut -f 1 -d " ") <(echo "${EXPECTED}")
