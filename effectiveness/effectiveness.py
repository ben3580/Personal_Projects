import csv
def main():
    pokemon = load_pokemon("pokemon.csv")
    types = load_types("types.csv")
    name = input("Enter a Pokemon (enter \"exit\" to exit): ").lower()
    while name != "exit":
        current_types = find_info(name, pokemon)
        if current_types != None:
            calculate_effectiveness(current_types, types)
        name = input("\nEnter a Pokemon (enter \"exit\" to exit): ")

def load_pokemon(filename):
    data = dict()
    with open(filename) as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row["Name"].lower()
            data[name] = {
                "Name": row["Name"],
                "Type 1": row["Type 1"] or None,
                "Type 2": row["Type 2"] or None
            }
    return data

def load_types(filename):
    data = dict()
    with open(filename) as f:
        reader = csv.DictReader(f)
        for row in reader:
            type_ = row["ï»¿type"]
            strengths = []
            weaknesses = []
            immunity = []
            for i in range(1, 6):
                strengths.append(row["strong" + str(i)] or None)
            for i in range(1, 8):
                weaknesses.append(row["weak" + str(i)] or None)
            immunity.append(row["immune"] or None)
            data[type_] = {
                "Type": type_,
                "Strengths": strengths,
                "Weaknesses": weaknesses,
                "Immunity": immunity
            }
    return data

def find_info(name, pokemon):
    try:
        current_pokemon = pokemon[name]
        current_types = []
        current_types.append(current_pokemon["Type 1"])
        print("Type(s): " + current_types[0], end="")
        if current_pokemon["Type 2"] != None:
            current_types.append(current_pokemon["Type 2"])
            print(", " + current_types[1])
        return current_types
    except KeyError:
        print("Cannot find Pokemon in database")
        return None

def calculate_effectiveness(current_types, types):
    scores = {"normal": 0, "fire": 0, "water": 0, "grass": 0, "electric": 0,\
              "ice": 0, "fighting": 0, "poison": 0, "ground": 0, "flying": 0,\
              "psychic": 0, "bug": 0, "rock": 0, "ghost": 0, "dragon": 0,\
              "dark": 0, "steel": 0, "fairy": 0}
    for type1 in current_types:
        type1 = type1.lower()
        for type2 in types:
            if type1 in types[type2]["Strengths"]:
                scores[type2] += 1
            elif type1 in types[type2]["Weaknesses"]:
                scores[type2] -= 1
            elif type1 in types[type2]["Immunity"]:
                scores[type2] -= 10
    strengths = []
    weaknesses = []
    immunities = []
    for s in scores:
        if scores[s] > 0:
            strengths.append(s)
        elif scores[s] < -5:
            immunities.append(s)
        elif scores[s] < 0:
            weaknesses.append(s)
    print("\nWeak to:")
    for type_ in strengths:
        print(type_ + " x" + str(scores[type_] * 2))
    print("\nResistant to:")
    for type_ in weaknesses:
        print(type_ + " x1/" + str(scores[type_] * -2))
    print("\nImmune to:")
    for type_ in immunities:
        print(type_)
    
main()
