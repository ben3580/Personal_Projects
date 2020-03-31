from colorama import init, Fore, Back, Style
import random

init(convert = True, autoreset = True)

def print_line():
    print("========================================" +\
          "========================================")
    
class Person:
    
    def __init__(self, name, hp, mp, atk, df, mg, magic, status):
        self.maxhp = hp
        self.hp = hp
        self.maxmp = mp
        self.mp = mp
        self.atk = atk
        self.df = df
        self.mg = mg
        self.magic = magic
        self.action = ["Attack", "Magic", "Items"]
        self.name = name
        self.status = status

    def update_status(self, status):
        self.status = status

    def update_magic(self, magic):
        self.magic = magic
        
    def generate_damage(self):
        low = round(self.atk - 0.1 * self.atk)
        high = round(self.atk + 0.1 * self.atk)
        return random.randrange(low, high)

    def take_damage(self, dmg):
        self.hp -= dmg
        if self.hp < 0:
            self.hp = 0
        return self.hp

    def heal(self, dmg):
        self.hp += dmg
        if self.hp > self.maxhp:
            self.hp = self.maxhp

    def recover(self, dmg):
        self.mp += dmg
        if self.mp > self.maxmp:
            self.mp = self.maxmp

    def get_hp(self):
        return self.hp

    def get_maxhp(self):
        return self.maxhp

    def get_mp(self):
        return self.mp

    def get_maxmp(self):
        return self.maxmp

    def reduce_mp(self, cost):
        self.mp -= cost

    def get_df(self):
        return self.df

    def choose_action(self):
        i = 1
        print("\n" + self.name)
        print(Back.BLUE + "\tACTIONS")
        for item in self.action:
            print("\t\t" + str(i) + ". " + item)
            i += 1

    def choose_magic(self):
        i = 1
        print(Back.BLUE + "\tMAGIC")
        for spell in self.magic:
            print("\t\t" + str(i) + ". " + spell.name +\
                  " (mp: " + Fore.BLUE + str(spell.cost) + Fore.WHITE + ")")
            i += 1
        print("\n\t\t0. Go back")

    def choose_item(player_items):
        i = 1
        print(Back.BLUE + "\tITEMS: ")
        for item in player_items:
            print("\t\t" + str(i) + ". " + Fore.YELLOW + item["item"].name +\
                  Fore.WHITE + ": " + item["item"].description + " (x" +\
                  str(item["quantity"]) + ")")
            i += 1
        print("\n\t\t0. Go back")

    def choose_target(self, people):
        i = 1
        print(Back.RED + "\n\tTARGET:")
        for person in people:
            if person.get_hp() != 0:
                print("\t\t" + str(i) + ". " + person.name)
                i += 1
        print("\n\t\t0. Go back")
        choice = int(input("\nChoose target: ")) - 1
        return choice

    def get_enemy_stats(self):
        HP_bar = ""
        HP_bar_ticks = round(self.hp / self.maxhp * 25)
        
        while HP_bar_ticks > 0:
            HP_bar += "█"
            HP_bar_ticks -= 1

        while len(HP_bar) < 25:
            HP_bar += " "
        hp_string = str(self.hp) + "/" + str(self.maxhp)
        
        print("\t\t\t _________________________")
        if len(self.name) <= 7:
            print(self.name + "\t\t" + hp_string +\
                  Fore.WHITE + "\t|" + Fore.RED + HP_bar + Fore.WHITE +\
                  "|")
        else:
            print(self.name + "\t" + hp_string +\
                  Fore.WHITE + "\t|" + Fore.RED + HP_bar + Fore.WHITE +\
                  "|")
        
    def get_stats(self):
        HP_bar = ""
        HP_bar_ticks = round(self.hp / self.maxhp * 25)

        MP_bar = ""
        MP_bar_ticks = round(self.mp / self.maxmp * 10)
        
        while HP_bar_ticks > 0:
            HP_bar += "█"
            HP_bar_ticks -= 1

        while len(HP_bar) < 25:
            HP_bar += " "

        while MP_bar_ticks > 0:
            MP_bar += "█"
            MP_bar_ticks -= 1

        while len(MP_bar) < 10:
            MP_bar += " "

        hp_string = str(self.hp) + "/" + str(self.maxhp)
        
        mp_string = str(self.mp) + "/" + str(self.maxmp)
        
        print("\t\t\t _________________________ \t\t" +\
              " __________ ")
        if len(self.name) <= 7:
            print(self.name + "\t\t" + hp_string +\
                  Fore.WHITE + "\t|" + Fore.RED + HP_bar + Fore.WHITE +\
                  "|\t" + mp_string + Fore.WHITE + "\t|" +\
                  Fore.BLUE + MP_bar + Fore.WHITE + "|")
        else:
            print(self.name + "\t" + hp_string +\
                  Fore.WHITE + "\t|" + Fore.RED + HP_bar + Fore.WHITE +\
                  "|\t" + mp_string + Fore.WHITE + "\t|" +\
                  Fore.BLUE + MP_bar + Fore.WHITE + "|")

    def enemy_choose_magic(self):
        magic_choice = random.randrange(0, len(self.magic))
        spell = self.magic[magic_choice]
        magic_dmg = spell.generate_damage(self.mg)
        return spell, magic_dmg

    def increase_hp(self):
        self.maxhp += 20

    def increase_mp(self):
        self.maxmp += 5

    def increase_attack(self):
        self.atk += 3

    def increase_defense(self):
        self.df += 2

    def increase_magic(self):
        self.mg += 20

class Item:
    def __init__(self, name, item_type, description, prop, price):
        self.name = name
        self.item_type = item_type
        self.description = description
        self.prop = prop
        self.price = price

class Spell:
    def __init__(self, name, cost, dmg, status_type, status_chance):
        self.name = name
        self.cost = cost
        self.dmg = dmg
        self.status_type = status_type
        self.status_chance = status_chance

    def generate_damage(self, mg):
        low = round(self.dmg * mg / 100 - 0.1 * self.dmg)
        high = round(self.dmg * mg / 100 + 0.1 * self.dmg)
        return random.randrange(low, high)

    def generate_status_chance(self):
        if self.status_chance >= random.randrange(1, 101):
            return True
        else:
            return False

class Travel:

    def choose_action():
        actions = ["Continue to next area", "Party", "Items", "Autoheal",\
                   "Save & Exit"]
        i = 1
        print(Back.BLUE + "\n\tACTIONS")
        for item in actions:
            print("\t\t" + str(i) + ". " + item)
            i += 1

    def battle_end():
        next_event = random.randrange(1, 101)
        if next_event > 90:
            return "chest"
        elif next_event > 80:
            return "shop"
        elif next_event > 70:
            return "fountain"
        else:
            return ""
        
    def print_stats(players, exp, gold, next_lv):
        print_line()
        print("\n")
        # Displays HP and MP bars
        print("NAME\t\tHP\t\t\t\t\tMP")
        for player in players:
            player.get_stats()
        print("\nEXP: " + Fore.CYAN + str(exp) + Fore.WHITE + " / " +\
              str(next_lv) + "\n")
        print("Gold: " + Fore.YELLOW + str(gold) + "\n")
        print_line()
        input("Press any key to go back")
      
    def autoheal(players, player1):
        total_mp = 0
        for player in players:
            total_mp += player.maxhp - player.hp
            if player1.mp <= 0:
                print("\nNot enough MP\n")
                break
            player.hp = player.maxhp
        player1.mp -= round(total_mp / 20)
        if player1.mp <= 0:
            player1.mp = 0
        print("\nHP restored for all party members\n")
        print_line()

    def chest_event(player_items):
        print("You find a chest!")
        input("Press any key to open")
        for i in range(random.randrange(1, 4)):
            got_item = random.randrange(0, 5)
            player_items[got_item]["quantity"] += 1
            print("You found a " + Fore.YELLOW + player_items[got_item]["item"].name +\
                  Fore.WHITE + " in the chest")
        input("Press any key to continue")
        print_line()
        return player_items

    def fountain_event(players):
        for player in players:
            player.hp = player.maxhp
            player.mp = player.maxmp
        print("You find a magical fountain!")
        print("HP and MP restored for all party members")
        input("Press any key to continue")
        print_line()

    def shop_event(player_items, gold):
        item_number = []
        in_shop = True
        print("\nYou find a cozy little shop")
        print("Items for sale:")
        for i in range(5):
            item_number.append(random.randrange(0, 6))
        while in_shop:
            for i in range(len(item_number)):
                print("\n" + str(i + 1) + ". " + Fore.YELLOW +\
                      player_items[item_number[i]]["item"].name + Fore.WHITE + " (" +\
                      player_items[item_number[i]]["item"].description + ") (price: " +\
                      Fore.YELLOW + str(player_items[item_number[i]]["item"].price) +\
                      Fore.WHITE + " gold)")
            print("\nYou have " + Fore.YELLOW + str(gold) + Fore.WHITE + " gold")
            choice = int(input("\nEnter the item's number to buy items " +\
                               "(or enter 0 to exit the shop): ")) - 1
            if choice == -1:
                break
            player_items[item_number[choice]]["quantity"] += 1
            if gold < player_items[item_number[choice]]["item"].price:
                print("Not enough gold")
            else:
                gold -= player_items[item_number[choice]]["item"].price
                print(Fore.YELLOW + player_items[item_number[choice]]["item"].name +\
                      Fore.WHITE + " added to inventory")
                item_number.remove(item_number[choice])
                go_again = int(input("\nDo you want to buy another item?" +\
                                 "(Press 1 for YES, anything else for NO) "))
                print_line()
                if go_again != 1 or len(item_number) == 0:
                    break
        print("You exit the shop")
        input("\nPress any key to continue")
        return player_items, gold

    def check_item(player_items, players, player1):
        Person.choose_item(player_items)
        item_choice = int(input("Choose item: ")) - 1
        if item_choice != -1:
            item = player_items[item_choice]["item"]

            if player_items[item_choice]["quantity"] == 0:
                print(Fore.RED + "\nNone left...")
            else:
                player_items[item_choice]["quantity"] -= 1
                 
                if item.item_type == "HP potion":
                    target = player1.choose_target(players)
                    if target != -1:
                        heal = round(item.prop * players[target].get_maxhp())
                        players[target].heal(heal)
                        print("\n" + players[target].name + " recovers " + Fore.RED +\
                              str(heal) + " HP")
                elif item.item_type == "MP potion":
                    target = player1.choose_target(players)
                    if target != -1:
                        recover = round(item.prop * players[target].get_maxmp())
                        players[target].recover(recover)
                        print("\n" + players[target].name + " recovers " + Fore.RED +\
                              str(recover) + " MP")
                elif item.item_type == "attack":
                    print("There are no enemies")
        return player_items

    def level_up(players, hp_bar, mp_bar, attack_bar, defense_bar, mg_bar):
        print("\nLEVEL UP!")
        print("Choose a stat to upgrade")
        print("\n\t1. HP      |" + hp_bar)
        print("\n\t2. MP      |" + mp_bar)
        print("\n\t3. ATTACK  |" + attack_bar)
        print("\n\t4. DEFENSE |" + defense_bar)
        print("\n\t5. MAGIC   |" + mg_bar)
        choice = int(input("\nEnter a number to upgrade stat: "))
        while choice != 1 and choice != 2 and choice != 3 and choice != 4 and choice != 5:
            print("Error. Please Choose again")
            choice = int(input("\nEnter a number to upgrade stat: "))
        if choice == 1:
            for player in players:
                player.increase_hp()
            hp_bar += "█ "
        elif choice == 2:
            for player in players:
                player.increase_mp()
            mp_bar += "█ "
        elif choice == 3:
            for player in players:
                player.increase_attack()
            attack_bar += "█ "
        elif choice == 4:
            for player in players:
                player.increase_defense()
            defense_bar += "█ "
        elif choice == 5:
            for player in players:
                player.increase_magic()
            mg_bar += "█ "

        for player in players:
            player.hp = player.maxhp
            player.mp = player.maxmp
        print("\nStat increased")
        return hp_bar, mp_bar, attack_bar, defense_bar, mg_bar


