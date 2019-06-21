import finalfusion

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

def test_analogies():
    embeds = finalfusion.Embeddings('tests/analogy.fifu')
    for idx, analogy in enumerate(embeds.analogy("Paris", "Frankreich", "Berlin", 40)):
        assert ANALOGY_ORDER[idx] == analogy.word

    assert embeds.analogy("Paris", "Frankreich", "Paris", 1, (True, False, True))[0].word == "Frankreich"
    assert embeds.analogy("Paris", "Frankreich", "Paris", 1, (True, True, True))[0].word != "Frankreich"
    assert embeds.analogy("Frankreich", "Frankreich", "Frankreich", 1, (False, False, False))[0].word == "Frankreich"
    assert embeds.analogy("Frankreich", "Frankreich", "Frankreich", 1, (False, False, True))[0].word != "Frankreich"
    try:
        embeds.analogy("Paris", "Frankreich", "Paris", 1, (True, True))
        assert True == False
    except:
        ()
    try:
        embeds.analogy("Paris", "Frankreich", "Paris", 1, (True, True, True, True))
        assert True == False
    except:
        ()
