import pytest

ANALOGY_ORDER = [
    "Deutschland",
    "Westdeutschland",
    "Sachsen",
    "Mitteldeutschland",
    "Brandenburg",
    "Polen",
    "Norddeutschland",
    "Dänemark",
    "Schleswig-Holstein",
    "Österreich",
    "Bayern",
    "Thüringen",
    "Bundesrepublik",
    "Ostdeutschland",
    "Preußen",
    "Deutschen",
    "Hessen",
    "Potsdam",
    "Mecklenburg",
    "Niedersachsen",
    "Hamburg",
    "Süddeutschland",
    "Bremen",
    "Russland",
    "Deutschlands",
    "BRD",
    "Litauen",
    "Mecklenburg-Vorpommern",
    "DDR",
    "West-Berlin",
    "Saarland",
    "Lettland",
    "Hannover",
    "Rostock",
    "Sachsen-Anhalt",
    "Pommern",
    "Schweden",
    "Deutsche",
    "deutschen",
    "Westfalen",
]


def test_analogies(analogy_fifu):
    for idx, analogy in enumerate(
        analogy_fifu.analogy("Paris", "Frankreich", "Berlin", 40)
    ):
        assert ANALOGY_ORDER[idx] == analogy.word

    assert (
        analogy_fifu.analogy("Paris", "Frankreich", "Paris", 1, (True, False, True))[
            0
        ].word
        == "Frankreich"
    )
    assert (
        analogy_fifu.analogy("Paris", "Frankreich", "Paris", 1, (True, True, True))[
            0
        ].word
        != "Frankreich"
    )
    assert (
        analogy_fifu.analogy(
            "Frankreich", "Frankreich", "Frankreich", 1, (False, False, False)
        )[0].word
        == "Frankreich"
    )
    assert (
        analogy_fifu.analogy(
            "Frankreich", "Frankreich", "Frankreich", 1, (False, False, True)
        )[0].word
        != "Frankreich"
    )

    with pytest.raises(ValueError):
        analogy_fifu.analogy("Paris", "Frankreich", "Paris", 1, (True, True))
    with pytest.raises(ValueError):
        analogy_fifu.analogy(
            "Paris", "Frankreich", "Paris", 1, (True, True, True, True)
        )
    with pytest.raises(KeyError):
        analogy_fifu.analogy("Paris", "OOV", "Paris", 1, (True, True, True))
