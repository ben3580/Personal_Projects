from colorama import init, Fore, Back, Style # Colors text in console window
import random # RNG. An integral feature of any RPG
import pickle # To store objects in a save file
import time # To add delays to text display
import logging # To log error messages
from classes.game import Person, Spell, Item, Travel

# initialization for colorama
init(convert = True, autoreset = True)
# initialization for logging
logging.basicConfig(filename='error_log.log', filemode='a',\
                    format='%(name)s - %(levelname)s - %(message)s')

######################################### Setup ############################################

# These variables help draw the stat bars
hp_bar = ""
mp_bar = ""
attack_bar = ""
defense_bar = ""
mg_bar = ""

# EXP and Gold
exp = 0
next_lv = 100
gold = 0
area = 1

# Create magic
fireball = Spell("Fireball", 5, 25, "burn", 0)
eruption = Spell("Eruption", 10, 30, "burn", 15)
inferno = Spell("Inferno", 12, 60, "burn", 33)
zap = Spell("Zap", 4, 20, "shock", 0)
storm = Spell("Storm", 6, 20, "shock", 0)
thunder = Spell("Thunder", 8, 50, "shock", 0)
water_gun = Spell("Water gun", 3, 20, "freeze", 0)
freeze = Spell("Freeze", 7, 5, "freeze", 90)
blizzard = Spell("Blizzard", 10, 40, "freeze", 20)
heal_lv1 = Spell("Heal LV1", 5, 50, "heal", 100)
heal_lv2 = Spell("Heal LV2", 10, 200, "heal", 100)

# Create some items
HP_potion_s = Item("Small HP Potion", "HP potion", "Heals 50% HP", 0.5, 30)
HP_potion_l = Item("Large HP Potion", "HP potion", "Heals 100% HP", 1, 75)
MP_potion_s = Item("Small MP Potion", "MP potion", "Heals 50% MP", 0.5, 40)
MP_potion_l = Item("Large MP Potion", "MP potion", "Heals 100% MP", 1, 100)
throwing_knife = Item("Throwing Knife", "attack", "Does 50% damage to one enemy", 0.5, 30)
explosive_concoction = Item("Explosive Concoction", "attack",\
                            "Does 50% damage to all enemies", 0.5, 100)

# Magic and item list/dictionary
player_spells = [fireball, zap, water_gun, heal_lv1, heal_lv2]
player_items = [{"item": HP_potion_s, "quantity": 3},\
                {"item": HP_potion_l, "quantity": 0},\
                {"item": MP_potion_s, "quantity": 3},\
                {"item": MP_potion_l, "quantity": 0},\
                {"item": throwing_knife, "quantity": 0},\
                {"item": explosive_concoction, "quantity": 0}]

# player lists
players = []
dead_players = []
############################################################################################
# if statement variables
CONTINUE_MESSAGE = False
PLAYER1_WENT = False
PLAYER2_WENT = False
BATTLE_INITIATE = True
TRAVEL_INITIATE = True
PLAYER2_ON = False
PLAYER3_ON = False
TIER2_UNLOCK = False
TIER3_UNLOCK = False
baby_dragon_ending = ""
player_3_ending = ""
dragon_ending = ""

# loop variables
running = True
start = True
battle = False
travel = False

player1 = 0
player2 = 0
player3 = 0

########################### Instantiation function definitions #############################
def create_player_2():
    global PLAYER2_ON
    PLAYER2_ON = True
    print("\nRebekah has joined the party!\n")
    return Person("Rebekah", 90 + (10 * len(hp_bar)), 15 + int(2.5 * len(mp_bar)),\
                  20 + int(3 * len(attack_bar) / 2), 5 + (len(defense_bar)),\
                  80 + (10 * len(mg_bar)), [zap, storm], "nothing")

def create_player_3():
    global PLAYER3_ON
    PLAYER3_ON = True
    print("\nAdrian has joined the party!\n")
    return Person("Adrian", 70 + (10 * len(hp_bar)), 25 + int(2.5 * len(mp_bar)),\
                  12 + int(3 * len(attack_bar) / 2), 2 + (len(defense_bar)),\
                  150 + (10 * len(mg_bar)),\
                  [water_gun, freeze, blizzard, heal_lv1, heal_lv2], "nothing")

def create_player_3_enemy():
    return Person("Adrian", 200, 50, 20, 2, 120,\
                  [water_gun, freeze, blizzard, heal_lv2], "nothing")

# The "area" variable is used to progressively make the enemies stronger
def create_imp(area):
    area = area / 100 + 1
    return Person("Imp", round(area*40), 10, round(area*10), round(area*1),\
                  round(area*75), [fireball], "nothing")

def create_slime(area):
    area = area / 100 + 1
    return Person("Slime", round(area*50), 10, round(area*5), round(area*0),\
                  round(area*80), [heal_lv1], "nothing")

def create_skeleton(area):
    area = area / 100 + 1
    return Person("Skeleton", round(area*75), 0, round(area*12), round(area*3),\
                  round(area*100), [], "nothing")

def create_golem(area):
    area = area / 100 + 1
    return Person("Golem", round(area*100), 0, round(area*8), round(area*5),\
                  round(area*100), [], "nothing")

def create_goblin(area):
    area = area / 100 + 1
    return Person("Goblin", round(area*60), 10, round(area*7), round(area*1),\
                  round(area*80), [zap], "nothing")

def create_orc(area):
    area = area / 100 + 1
    return Person("Orc", round(area*70), 0, round(area*15), round(area*2),\
                  round(area*100), [], "nothing")

def create_kobold(area):
    area = area / 100 + 1
    return Person("Kobold", round(area*60), 10, round(area*8), round(area*1),\
                  round(area*75), [fireball], "nothing")

def create_giant_bat(area):
    area = area / 100 + 1
    return Person("Giant Bat", round(area*30), 10, round(area*7), round(area*0),\
                  round(area*100), [water_gun], "nothing")

def create_giant_rat(area):
    area = area / 100 + 1
    return Person("Giant Rat", round(area*50), 10, round(area*11), round(area*2),\
                  round(area*80), [zap], "nothing")

def create_giant_spider(area):
    area = area / 100 + 1
    return Person("Giant Spider", round(area*60), 10, round(area*12), round(area*2),\
                  round(area*100), [freeze], "nothing")

def create_ghoul(area):
    area = area / 100 + 1
    return Person("Ghoul", round(area*60), 10, round(area*10), round(area*1),\
                  round(area*75), [fireball], "nothing")

def create_cyclop(area):
    area = area / 100 + 1
    return Person("Imp", round(area*70), 10, round(area*6), round(area*1),\
                  round(area*75), [fireball], "nothing")

def create_fire_elemental(area):
    area = area / 100 + 1
    return Person("Fire Elemental", round(area*30), 50, round(area*5), round(area*0),\
                  round(area*120), [fireball, eruption], "nothing")

def create_water_elemental(area):
    area = area / 100 + 1
    return Person("Water Elemental", round(area*30), 50, round(area*5), round(area*0),\
                  round(area*100), [water_gun, freeze], "nothing")

def create_wind_elemental(area):
    area = area / 100 + 1
    return Person("Wind Elemental", round(area*30), 50, round(area*5), round(area*0),\
                  round(area*100), [zap, storm], "nothing")

def create_goblin_king():
    return Person("Goblin King", 200, 20, 20, 5, 150,\
                  [fireball, zap, water_gun, heal_lv1], "nothing")

def create_baby_dragon():
    return Person("Baby Dragon", 150, 20, 20, 0, 175,\
                  [fireball, heal_lv1], "nothing")

def create_mega_elemental():
    return Person("Mega Elemental", 300, 100, 35, 5, 200,\
                  [eruption, inferno, storm, thunder, freeze,\
                   blizzard, heal_lv2], "nothing")

def create_dragon():
    return Person("Dragon", 999, 100, 50, 0, 200,\
                  [fireball, eruption, inferno], "nothing")

############################### Battle function definitions ################################
def print_line():
    print("========================================" +\
          "========================================")

def print_stats():# Displays HP and MP bars
    print_line()
    print("\n")
    print("NAME\t\tHP\t\t\t\t\tMP")
    for player in players:
        player.get_stats()
    print("\n\n")
    for enemy in enemies:
        enemy.get_enemy_stats()
    print("\n")
    print_line()
        
def check_turn(): # This will tell the program that a player has completed their turn
    global PLAYER1_WENT
    global PLAYER2_WENT
    if not(PLAYER1_WENT):
        PLAYER1_WENT = True
    else:
        PLAYER2_WENT = True

def chose_attack(): # Code that runs when the player chooses to attack
    global CONTINUE_MESSAGE
    target_enemy = player.choose_target(enemies) # Choose the target enemy
    if target_enemy == -1: # If the player selects "go back"
        CONTINUE_MESSAGE = True
    else:
        player_dmg = player.generate_damage() - enemies[target_enemy].get_df()
        enemies[target_enemy].take_damage(player_dmg) # Enemy will take damage
        # Print the results to the window
        print("\n" + player.name + " attacks " +\
              enemies[target_enemy].name +\
              " for " + Fore.RED + str(player_dmg) + Fore.WHITE + " damage")
        print_line()
        # If enemy dies, delete the enemy
        if enemies[target_enemy].get_hp() == 0:
            enemy_died(target_enemy)
        check_turn()
    

def chose_magic(player): # Code that runs when the player chooses to use magic
    global CONTINUE_MESSAGE
    player.choose_magic()
    magic_choice = int(input("Choose a spell: ")) - 1
    # Allows the user to go back menus - this will exit the function and then
    # exit the loop (at the bottom of the program)
    if magic_choice == -1:
        CONTINUE_MESSAGE = True

    else:
        spell = player.magic[magic_choice] # user input
        # Displays error message of they don't have enough MP
        current_mp = player.get_mp()
        if spell.cost > current_mp:
            print(Fore.RED + "\nMot enough MP\n")
            CONTINUE_MESSAGE = True
            
        else:
            # If the spell is a healing spell
            if spell.status_type == "heal":
                target = player.choose_target(players) # user input
                if target == -1:
                    CONTINUE_MESSAGE = True
                else:
                    player.reduce_mp(spell.cost)
                    magic_dmg = spell.generate_damage(player.mg)
                    players[target].heal(magic_dmg)
                    print("\n" + spell.name + " heals " + players[target].name +\
                          " for " + Fore.RED + str(magic_dmg) + Fore.WHITE + " HP")
                    print_line()
                    check_turn()
            # If the spell has AOE damage
            elif spell.name == "Eruption" or spell.name == "Storm" or spell.name == "Blizzard":
                player.reduce_mp(spell.cost)
                i = 0
                enemy_dead = [False, False, False, False, False]
                for enemy in enemies:
                    magic_dmg = spell.generate_damage(player.mg) - enemy.get_df()
                    enemy.take_damage(magic_dmg)
                    print("\n" + spell.name + " deals " + Fore.RED + str(magic_dmg) +\
                          Fore.WHITE + " damage to " + enemy.name)
                    # Uses RNG to determine whether the enemy gets a negative status effect
                    if spell.status_type == "burn" and spell.generate_status_chance():
                        enemy.update_status("burn")
                        print(enemy.name + " has been burned")
                    if spell.status_type == "freeze" and spell.generate_status_chance():
                        enemy.update_status("freeze")
                        print(enemy.name + " has been frozen")
                    if enemy.get_hp() == 0:
                        enemy_dead[i] = True
                    i += 1
                i = 0
                index = 0
                enemies_length = len(enemies)
                while i < enemies_length:
                    if enemy_dead[index] == True:
                        enemy_died(i)
                        index += 1
                    else:
                        i += 1
                        index += 1
                print_line()
                check_turn()
            # If the spell is just a normal spell
            else:
                target_enemy = player.choose_target(enemies)
                if target_enemy == -1:
                    CONTINUE_MESSAGE = True
                else:
                    player.reduce_mp(spell.cost)
                    magic_dmg = spell.generate_damage(player.mg) - enemies[target_enemy].get_df()
                    enemies[target_enemy].take_damage(magic_dmg)
                    print("\n" + spell.name + " deals " + Fore.RED + str(magic_dmg) +\
                          Fore.WHITE + " damage to " +\
                          enemies[target_enemy].name)
                    if spell.status_type == "burn" and spell.generate_status_chance():
                        enemies[target_enemy].update_status("burn")
                        print(enemies[target_enemy].name + " has been burned")
                    if spell.status_type == "freeze" and spell.generate_status_chance():
                        enemies[target_enemy].update_status("freeze")
                        print(enemies[target_enemy].name + " has been frozen")
                    print_line()
                    if enemies[target_enemy].get_hp() == 0:
                        enemy_died(target_enemy)
                    check_turn()

def choose_item(): # Prints the item menu
    i = 1
    print(Back.BLUE + "\tITEMS: ")
    for item in player_items:
        print("\t\t" + str(i) + ". " + Fore.YELLOW + item["item"].name +\
              Fore.WHITE + ": " + item["item"].description + " (x" +\
              str(item["quantity"]) + ")")
        i += 1
    print("\n\t\t0. Go back")
    
def chose_item(): # If the player chooses to uses an item
    global CONTINUE_MESSAGE
    Person.choose_item(player_items)
    item_choice = int(input("Choose item: ")) - 1 # User input
    if item_choice == -1:
        CONTINUE_MESSAGE = True
    else:
        item = player_items[item_choice]["item"] # Identifies the item the player chose
        # If the player has no items left
        if player_items[item_choice]["quantity"] == 0:
            print(Fore.RED + "\nNone left...")
            CONTINUE_MESSAGE = True
        else:
            player_items[item_choice]["quantity"] -= 1 # Take away an item
             
            if item.item_type == "HP potion":
                target = player.choose_target(players)
                if target == -1:
                    CONTINUE_MESSAGE = True
                else:
                    heal = round(item.prop * players[target].get_maxhp())
                    players[target].heal(heal)
                    print("\n" + players[target].name + " recovers " + Fore.RED +\
                          str(heal) + Fore.WHITE + " HP")
                    print_line()
                    check_turn()
            elif item.item_type == "MP potion":
                target = player.choose_target(players)
                if target == -1:
                    CONTINUE_MESSAGE = True
                else:
                    recover = round(item.prop * players[target].get_maxmp())
                    players[target].recover(recover)
                    print("\n" + players[target].name + " recovers " + Fore.BLUE +\
                          str(recover) + Fore.WHITE + " MP")
                    print_line()
                    check_turn()
            elif item.item_type == "attack":
                if item.name == "Explosive Concoction":
                    i = 0
                    enemy_dead = [False, False, False, False, False]
                    for enemy in enemies:
                        dmg = round(item.prop * enemy.get_maxhp() - enemy.get_df())
                        enemy.take_damage(dmg)
                        print("\n" + item.name + " deals " + Fore.RED + str(dmg) +\
                              Fore.WHITE + " damage to " + enemy.name)
                        if enemy.get_hp() == 0:
                            enemy_dead[i] = True
                        i += 1
                    i = 0
                    index = 0
                    enemies_length = len(enemies)
                    while i < enemies_length:
                        if enemy_dead[index] == True:
                            enemy_died(i)
                            index += 1
                        else:
                            i += 1
                            index += 1
                    print_line()
                    check_turn()
                else:
                    target_enemy = player.choose_target(enemies)
                    if target_enemy == -1:
                        CONTINUE_MESSAGE = True
                    else:
                        dmg = round(item.prop * enemies[target_enemy].get_maxhp() - enemies[target_enemy].get_df())
                        enemies[target_enemy].take_damage(dmg) 
                        print("\n" + item.name + " deals " + Fore.RED +\
                              str(dmg) + Fore.WHITE + " damage to " +\
                              enemies[target_enemy].name)
                        print_line()
                        if enemies[target_enemy].get_hp() == 0:
                            enemy_died(target_enemy)
                        check_turn()

def enemy_died(target_enemy):
    print(enemies[target_enemy].name +\
          " has been deafeated")
    del enemies[target_enemy]

def player_died(target):
    print(players[target].name +\
          " has been deafeated")
    dead_players.append(players[target])
    del players[target]
    
def enemy_attack(enemy): # If the enemy chose to attack. Everything is random
    target = random.randrange(0, len(players))
    enemy_dmg = enemy.generate_damage() - players[target].get_df()
    if enemy_dmg <= 0:
        enemy_dmg = 1
    players[target].take_damage(enemy_dmg)
    print(enemy.name + "'s attack deals " +\
          Fore.RED + str(enemy_dmg) + Fore.WHITE + " damage to " +\
          players[target].name)
    if players[target].get_hp() == 0:
        player_died(target)

def enemy_magic(enemy):# If the enemy chose to use magic
    global players
    spell, magic_dmg = enemy.enemy_choose_magic()
    if spell.status_type == "heal":
        enemy.reduce_mp(spell.cost)
        enemy.heal(magic_dmg)
        print(enemy.name + " heals for " +\
              Fore.RED + str(magic_dmg) + Fore.WHITE + " HP")
    elif spell.name == "Eruption" or spell.name == "Storm" or spell.name == "Blizzard":
        enemy.reduce_mp(spell.cost)
        i = 0
        enemy_dead = [False, False, False]
        for player in players:
            magic_dmg = spell.generate_damage(enemy.mg) - player.get_df()
            player.take_damage(magic_dmg)
            print("\n" + enemy.name + "'s " + spell.name + " deals " + Fore.RED + str(magic_dmg) +\
                  Fore.WHITE + " damage to " +\
                  player.name)
            # Uses RNG to determine whether the enemy gets a negative status effect
            if spell.status_type == "burn" and spell.generate_status_chance():
                player.update_status("burn")
                print(player.name + " has been burned")
            if spell.status_type == "freeze" and spell.generate_status_chance():
                player.update_status("freeze")
                print(player.name + " has been frozen")
            if player.get_hp() == 0:
                enemy_dead[i] = True
            i += 1
        i = 0
        index = 0
        enemies_length = len(players)
        while i < enemies_length:
            if enemy_dead[index] == True:
                player_died(i)
                index += 1
            else:
                i += 1
                index += 1
    else:
        enemy.reduce_mp(spell.cost)
        target = random.randrange(0, len(players))
        magic_dmg -= players[target].get_df()
        players[target].take_damage(magic_dmg)
        print(enemy.name + "'s " + \
              spell.name + " deals " + Fore.RED + str(magic_dmg) +\
              Fore.WHITE + " damage to " +\
              players[target].name)
        if spell.status_type == "burn" and spell.generate_status_chance():
            players[target].update_status("burn")
            print(players[target].name + " has been burned")
        if spell.status_type == "freeze" and spell.generate_status_chance():
            players[target].update_status("freeze")
            print(players[target].name + " has been frozen")

        if players[target].get_hp() == 0:
            player_died(target)
    

def player_win(): # If the player won the battle
    global gold
    global exp
    global area
    global PLAYER1_WENT
    global PLAYER2_WENT
    global battle
    global travel
    global TRAVEL_INITIATE
    # Ben's horrible attempt at block letters
    print_line()
    print("\n")
    print(Fore.GREEN + "█   █  █████  █   █     █   █  █████  █   █  █")
    print(Fore.GREEN + " █ █   █   █  █   █     █   █    █    ██  █  █")
    print(Fore.GREEN + "  █    █   █  █   █     █   █    █    █ █ █  █")
    print(Fore.GREEN + "  █    █   █  █   █     █ █ █    █    █  ██   ")
    print(Fore.GREEN + "  █    █████  █████     ██ ██  █████  █   █  █")
    # Get some gold and exp
    gold_gain = random.randrange(5, 10)
    exp_gain = random.randrange(15, 25)
    gold += gold_gain
    exp += exp_gain
    print("\nYou found " + Fore.YELLOW + str(gold_gain) + Fore.WHITE +\
          " gold")
    print("You got " + Fore.CYAN + str(exp_gain) + Fore.WHITE + " EXP")
    print_line()
    PLAYER1_WENT = False
    PLAYER2_WENT = False
    battle = False
    travel = True
    TRAVEL_INITIATE = True

def burn_effect(player): # If the player/enemy is burned, take some damgae
    player.hp -= round(0.1 * player.maxhp)
    print(player.name + " is on fire and took " + format(0.1 * player.maxhp, '.0f') +\
          " damage")
    if player.hp == 0:
        player_died(player)

def freeze_effect(player): # If the player/enemy is frozen, skip the turn
    global CONTINUE_MESSAGE
    print(player.name + " is frozen")
    player.update_status("nothing")
    CONTINUE_MESSAGE = True

def spawn_enemies(): # Will randomly spawn some enemies at the start of each battle
    global area
    enemies = []
    for i in range(random.randrange(1, round(2 + area / 50))):
        which_enemy = random.randrange(1, 16)
        if which_enemy == 1:
            enemies.append(create_imp(area))
        elif which_enemy == 2:
            enemies.append(create_slime(area))
        elif which_enemy == 3:
            enemies.append(create_skeleton(area))
        elif which_enemy == 4:
            enemies.append(create_golem(area))
        elif which_enemy == 5:
            enemies.append(create_goblin(area))
        elif which_enemy == 6:
            enemies.append(create_orc(area))
        elif which_enemy == 7:
            enemies.append(create_kobold(area))
        elif which_enemy == 8:
            enemies.append(create_giant_bat(area))
        elif which_enemy == 9:
            enemies.append(create_giant_rat(area))
        elif which_enemy == 10:
            enemies.append(create_giant_spider(area))
        elif which_enemy == 11:
            enemies.append(create_ghoul(area))
        elif which_enemy == 12:
            enemies.append(create_cyclop(area))
        elif which_enemy == 13:
            enemies.append(create_fire_elemental(area))
        elif which_enemy == 14:
            enemies.append(create_water_elemental(area))
        elif which_enemy == 15:
            enemies.append(create_wind_elemental(area))
    return enemies
################################# Start function definitions ###############################
def start_screen(): # prints the start screen menu
    print("\n")
    print("\t███   ████  █   █ ██ ████     ████  ████  ████")
    print("\t█  █  █     ██  █  █ █        █  █  █  █  █   ")
    print("\t█ █   ████  █ █ █    ████     ████  ████  █ ██")
    print("\t█  █  █     █  ██       █     █ █   █     █  █")
    print("\t███   ████  █   █    ████     █  █  █     ████")
    print("\n\t1. New game")
    print("\t2. Load game")
    print("\t3. Tutorial (Not coded)")
    print("\t4. Exit")

def choose_load():
    global CONTINUE_MESSAGE
    print("\n\t0. Autosave")
    print("\t1. Save 1")
    print("\t2. Save 2")
    print("\t3. Save 3")
    print("\n\t4. Go back")
    choice = int(input("\nChoose option: "))
    while choice != 0 and choice != 1 and choice != 2 and choice != 3 and choice != 4:
        print("Error. Please choose again")
        choice = int(input("\nChoose option: "))
    try:
        if choice == 0:
            txt_file = open("saves/autosave.txt", "r")
            load_save_txt(txt_file)
            dat_file = open("saves/autosave.dat", "rb")
            load_save_dat(dat_file)
        elif choice == 1:
            txt_file = open("saves/save1.txt", "r")
            load_save_txt(txt_file)
            dat_file = open("saves/save1.dat", "rb")
            load_save_dat(dat_file)
        elif choice == 2:
            txt_file = open("saves/save2.txt", "r")
            load_save_txt(txt_file)
            dat_file = open("saves/save2.dat", "rb")
            load_save_dat(dat_file)
        elif choice == 3:
            txt_file = open("saves/save3.txt", "r")
            load_save_txt(txt_file)
            dat_file = open("saves/save3.dat", "rb")
            load_save_dat(dat_file)
        elif choice == 4:
          CONTINUE_MESSAGE = True

    except FileNotFoundError:
        print("Save file does not exist")
        choose_load()
            
def load_save_txt(txt_file):
    global name
    global hp_bar
    global mp_bar
    global attack_bar
    global defense_bar
    global mg_bar
    global exp
    global gold
    global next_lv
    global area
    global PLAYER2_ON
    global PLAYER3_ON
    global baby_dragon_ending
    name = txt_file.readline()
    name = name.rstrip("\n")
    hp_bar = txt_file.readline()
    hp_bar = int(hp_bar.rstrip("\n")) * "█ "
    mp_bar = txt_file.readline()
    mp_bar = int(mp_bar.rstrip("\n")) * "█ "
    attack_bar = txt_file.readline()
    attack_bar = int(attack_bar.rstrip("\n")) * "█ "
    defense_bar = txt_file.readline()
    defense_bar = int(defense_bar.rstrip("\n")) * "█ "
    mg_bar = txt_file.readline()
    mg_bar = int(mg_bar.rstrip("\n")) * "█ "
    exp = txt_file.readline()
    exp = int(exp.rstrip("\n"))
    next_lv = txt_file.readline()
    next_lv = int(next_lv.rstrip("\n"))
    gold = txt_file.readline()
    gold = int(gold.rstrip("\n"))
    area = txt_file.readline()
    area = int(area.rstrip("\n"))
    PLAYER2_ON = str_to_bool(txt_file.readline())
    PLAYER3_ON = str_to_bool(txt_file.readline())
    TIER2_UNLOCK = str_to_bool(txt_file.readline())
    TIER3_UNLOCK = str_to_bool(txt_file.readline())
    baby_dragon_ending = txt_file.readline()
    baby_dragon_ending = baby_dragon_ending.rstrip("\n")
    txt_file.close()

def str_to_bool(string):
    if string == "True\n":
        return True
    else:
        return False

def load_save_dat(dat_file):
    global player_items
    global players
    global player1
    global player2
    global player3
    global PLAYER2_ON
    global PLAYER3_ON
    player_items = pickle.load(dat_file)
    players = pickle.load(dat_file)
    player1 = players[0]
    if PLAYER2_ON:
        player2 = players[1]
    if PLAYER3_ON:
        player3 = players[2]
    dat_file.close()

def choose_save():
    global CONTINUE_MESSAGE
    print("\n\tChoose a file to save to")
    print("\n\t1. Save 1")
    print("\t2. Save 2")
    print("\t3. Save 3")
    print("\n\t4. Go back")
    choice = int(input("\nChoose option: "))
    while choice != 1 and choice != 2 and choice != 3 and choice != 4:
        print("Error. Please choose again")
        choice = int(input("\nChoose option: "))
    if choice == 1:
        txt_file = open("saves/save1.txt", "w")
        save_txt(txt_file)
        dat_file = open("saves/save1.dat", "wb")
        save_dat(dat_file)
    elif choice == 2:
        txt_file = open("saves/save2.txt", "w")
        save_txt(txt_file)
        dat_file = open("saves/save2.dat", "wb")
        save_dat(dat_file)
    elif choice == 3:
        txt_file = open("saves/save3.txt", "w")
        save_txt(txt_file)
        dat_file = open("saves/save3.dat", "wb")
        save_dat(dat_file)
    elif choice == 4:
      CONTINUE_MESSAGE = True

def autosave():
    txt_file = open("saves/autosave.txt", "w")
    save_txt(txt_file)
    dat_file = open("saves/autosave.dat", "wb")
    save_dat(dat_file)

def save_txt(txt_file):
    global name
    global hp_bar
    global mp_bar
    global attack_bar
    global defense_bar
    global magic_bar
    global exp
    global gold
    global next_lv
    global area
    global PLAYER2_ON
    global PLAYER3_ON
    global baby_dragon_ending
    txt_file.write(name + "\n")
    txt_file.write(str(int(len(hp_bar) / 2)) + "\n")
    txt_file.write(str(int(len(mp_bar) / 2)) + "\n")
    txt_file.write(str(int(len(attack_bar) / 2)) + "\n")
    txt_file.write(str(int(len(defense_bar) / 2)) + "\n")
    txt_file.write(str(int(len(mg_bar) / 2)) + "\n")
    txt_file.write(str(exp) + "\n")
    txt_file.write(str(next_lv) + "\n")
    txt_file.write(str(gold) + "\n")
    txt_file.write(str(area) + "\n")
    txt_file.write(str(PLAYER2_ON) + "\n")
    txt_file.write(str(PLAYER3_ON) + "\n")
    txt_file.write(str(TIER2_UNLOCK) + "\n")
    txt_file.write(str(TIER3_UNLOCK) + "\n")
    txt_file.write(baby_dragon_ending + "\n")
    txt_file.close()

def save_dat(dat_file):
    global player_items
    global players
    pickle.dump(player_items, dat_file)
    pickle.dump(players, dat_file)
    dat_file.close()

####################################### Script #############################################
def get_name(): # Gets the user's name at the start of the game
    global players
    global player1
    global name
    name = input("What is your name? (Please limit name to 15 characters) ")
    while len(name) > 15:
        print("Name is too long")
        name = input("What is your name? (Please limit name to 15 characters) ")
    print("Welcome, " + name)
    player1 = Person(name, 100, 20, 15, 2, 100, [fireball, heal_lv1], "nothing")
    players = [player1]
    time.sleep(1)
    print("...")
    time.sleep(1)
    print("...")
    time.sleep(1)

def script_choose(): # Function for when a choice is needed to be made during the script
    good_input = False
    while good_input == False:
        try:
            choice = int(input("What is your choice? "))
            if choice != 1 and choice != 2:
                print("Error. Please choose again")
                continue
            good_input = True
        except ValueError:
            print("Error. Please choose again")
            continue
    return choice

def start_script():
    print("You wake up in the darkness.")
    time.sleep(2)
    print("\"Where am I?\" you wonder.")
    time.sleep(2)
    print("Footsteps echo in the distance")
    time.sleep(2)
    print("You look around")
    time.sleep(2)
    print("Your trusty sword and backback are lying nearby")
    time.sleep(2)
    print("You find 3 small HP potions and 3 small MP potions in your backpack")
    time.sleep(2)
    print("You stand up and begin to walk foward")
    time.sleep(2)
    print("Out of nowhere, a monster appears!")
    time.sleep(2)

def start_script_2():
    print("You seem to be in a cave, filled with monsters")
    time.sleep(2)
    print("The only option is to search until you find a way out")
    time.sleep(2)
    print("You must get back to your family in the capital")
    time.sleep(2)

def goblin_king_script():
    print("You finally see the light of the outside world")
    time.sleep(2)
    print("Soon, you will exit this wretched cave")
    time.sleep(2)
    print("However, the light of the entrance of the cave disappears,")
    print("blocked by a huge monster!")
    time.sleep(3)
    print("\"I am the goblin king!\"")
    time.sleep(2)
    print("\"You shall not escape the cave with my treasures\"")
    time.sleep(2)
    print("\"Give me all your gold or I will take it off your dead body\"")
    time.sleep(2)
    print("1. Give it 10,000 gold")
    print("2. No way! Prepare to fight")
    good_input = False
    while good_input == False:
        try:
            choice = int(input("What is your choice? "))
            if choice == 1:
                print("You don't have enough gold")
                continue
            elif choice != 2:
                print("Error. Please choose again")
                continue
            good_input = True
        except ValueError:
            print("Error. Please choose again")
            continue

def player_2_join_script():
    global players
    print("As you emerge from the cave, a woman wielding a fiercesome axe approaches you")
    time.sleep(3)
    print("\"Why did you go down there you stupid? That's where the monster came from.\"")
    time.sleep(3)
    print("Wait, monsters came from here?")
    time.sleep(2)
    print("\"Of all the place to be during a monster invasion, you go there?! With that flimsy sword?\"")
    time.sleep(3)
    print("\"Wait, there's a monster invasion?\" You ask")
    time.sleep(2)
    print("\"Have you been living under a rock? Well, I suppose you were.\"")
    time.sleep(2)
    print("\"Well, I'm Rebekah, and you better come with me if you don't want to get killed.\"")
    time.sleep(3)
    print("You and Rebekah walk across the field to a farmhouse")
    time.sleep(2)
    print("\"Tell you what. I need a partner to go slay the dragon in the capital\"")
    time.sleep(3)
    print("\"It's been causing all sorts of trouble, from burning fields to tearing down buildings\"")
    time.sleep(3)
    print("\"Since, you sooomehow emerged from that cave in one piece, you must be able to fight\"")
    time.sleep(3)
    print("\"What do you say?\"")
    time.sleep(2)
    print("Dragons!")
    time.sleep(2)
    print("A mythical creature known for its ability to decimate an army")
    time.sleep(2)
    print("While they have a short temper, they are not naturally violent")
    time.sleep(2)
    print("Dragons haven't been spotted in the last one hundred years")
    time.sleep(2)
    print("Now, one is destroying your city")
    time.sleep(2)
    print("You think of your family. Are they still alive?")
    time.sleep(2)
    print("1. Join Rebekah")
    print("2. Refuse")
    choice = script_choose()
    if choice == 1:
        print("\"Alright! Let's go!\"")
        players.append(create_player_2())
    else:
        print("\"I don't need you to slay the dragon,\" you say")
        time.sleep(2)
        print("My family is more important")
        time.sleep(2)
        
def baby_dragon_script():
    global PLAYER2_ON
    print("You arrive at a small town")
    time.sleep(2)
    print("Well, not much of a town. More like an intersection with a couple" +\
          " of buildings")
    time.sleep(3)
    if PLAYER2_ON:
        print("You and Rebekah approach the town, thankful for a break from the monsters")
    else:
        print("You approach the town, thankful for a break from the monsters")
    time.sleep(3)
    print("However, you soon notice a commotion outside of the inn")
    time.sleep(2)
    print("You approach the commotion")
    time.sleep(2)
    print("It seems that someone is being shouted at")
    time.sleep(2)
    print("When you get closer, however, you realize it's not a person being heckled" +\
          " - it's a dragon!")
    time.sleep(3)
    print("You know the full size of a dragon - this one is just a juvenile")
    time.sleep(2)
    print("The baby dragon is holding a gold-filled pouch in its mouth")
    print("and the people are trying to grab it back, weapons drawn")
    time.sleep(3)
    print("While the people can't get the pouch, the dragon can't fly away either")
    time.sleep(2)
    print("It's up to you to break the stalemate")
    time.sleep(2)
    print("\"Hey you! Help us get our gold back from this filthy animal,\" one of" +\
          " the men shout")
    time.sleep(3)
    print("\"Damn dragons have been robbing us more and more these days\"")
    time.sleep(2)
    print("You look at the dragon")
    time.sleep(2)
    print("It growls at you, but you can see that it's reluctant to fight")
    time.sleep(2)
    print("While dragons can eaily decimate whole armies, a juvenile can only do so much")
    time.sleep(3)
    print("On the other hand, there is one in the capital that may have already killed your family")
    time.sleep(3)
    print("\"Well, are you going to help me or what?\"")
    time.sleep(2)
    print("1. Attack the baby dragon")
    print("2. Talk it out")
    choice = script_choose()
    if choice == 1:
        return "attack"
    else:
        print("\"Whose gold is this?\" you ask")
        time.sleep(2)
        print("The shouting stops")
        time.sleep(2)
        print("\"Mine,\" a burly man says as he approaches you")
        time.sleep(2)
        print("You examine him and the group of people")
        time.sleep(2)
        print("Their clothes are ripped and torn in many places")
        time.sleep(2)
        print("Their weapons are rusty")
        time.sleep(2)
        print("There is no way these people, in such a desolate town, would")
        print("be able to amass the small fortune contained in the pouch")
        time.sleep(4)
        print("You notice the innkeeper walk out - the perfect person to ask")
        time.sleep(2)
        print("\"Are these people your patrons?\"")
        time.sleep(2)
        print("\"No,\" he replies. \"But they were joking about robbing the merchant" +\
              " who brings food to me!\"")
        time.sleep(4)
        print("That's when you realize who these people really are - bandits!")
        time.sleep(3)
        print("You stand in between the bandits and the baby dragon")
        time.sleep(2)
        print("The bandits think they can easily beat you")
        time.sleep(2)
        print("However, they quickly escape the scene when you summon a fireball in your hand")
        time.sleep(3)
        print("You turn your attention back to the dragon - but it is already gone")
        time.sleep(2)
        print("The pouch lies on the ground. You return it to the innkeeper")
        time.sleep(2)
        print("The inkeeper thanks you, and invites you to his inn")
        time.sleep(2)
        return "peace"

def player_3_join_script(baby_dragon_ending):
    global players
    print("You enter the inn")
    time.sleep(2)
    print("You innkeeper offers you a meal, and you accept")
    time.sleep(2)
    print("While you eat, you notice a cloaked figure in the corner of the inn")
    time.sleep(2)
    print("After you finish your meal, the cloaked figure approaches you")
    time.sleep(2)
    print("\"Are the bandits still outside?\" He asks")
    time.sleep(2)
    print("\"Wait, you knew they were bandits?\" You say")
    time.sleep(2)
    print("\"Are the bandits still outside?\" He asks again, ignoring your question")
    time.sleep(2)
    print("\"The bandits are gone.\"")
    time.sleep(2)
    print("Without a word, he leaves the inn")
    time.sleep(4)
    print("After a while, he comes back in")
    time.sleep(2)
    print("\"Where's the dragon?\" He asks")
    time.sleep(2)
    print("\"If you knew about the bandits and the dragon, why didn't you do something?\" You ask")
    time.sleep(2)
    print("\"The bandits chased me away. Where's the dragon?\"")
    time.sleep(2)
    print("1. Tell him you spared the dragon")
    print("2. Tell him you killed the dragon")
    choice = script_choose()
    if choice == 1:
        if baby_dragon_ending == "peace":
            print("\"Thank you!\" My name is Adrian")
            time.sleep(2)
            print("\"I had wanted to help the dragon, since he was only trying to help the defenseless\"")
            time.sleep(3)
            print("\"But, the bandits chased me away\"")
            time.sleep(2)
            print("\"You see, I worked with dragons before\"")
            time.sleep(2)
            print("\"I was tasked with protecting their eggs - it often takes over two years for one to hatch\"")
            time.sleep(2)
            print("\"Very few people get this privelege\"")
            time.sleep(2)
            print("\"I did this for ten years\"")
            time.sleep(2)
            print("\"But one day, bandits came and tried to steal an egg\"")
            time.sleep(2)
            print("\"I stopped them, but in doing so, I broke the egg - instantly killing the baby inside\"")
            time.sleep(2)
            print("\"I was lucky the dragon let me keep my life after that\"")
            time.sleep(4)
            print("\"Anyways, enough about me. Let's go see that dragon, shall we?\"")
            time.sleep(2)
            print("You wonder how Adrian knew your intentions")
            time.sleep(2)
            print("1. Let Adrian join the party")
            print("2. Don't let Adrian join the party")
            choice = script_choose()
            if choice == 1:
                players.append(create_player_3())
            return ""
        else:
            print("\"So...can you explain the blood on your clothes?\"")
            time.sleep(2)
            print("\"I'd recognize dragon blood anywhere. Liar!\"")
            time.sleep(2)
            print("Adrian draws his sword")
            time.sleep(2)
            return "attack"
    else:
        print("\"You are a terrible person,\" He says")
        time.sleep(2)
        print("He walks away")
        time.sleep(2)
        return ""

def mega_elemental_script():
    print("As you crest a hill, a massive elemental appears")
    time.sleep(2)
    print("The little ones are common, but this is like nothing you've ever seen before")
    time.sleep(3)
    print("It seems like the elemental contains all three elements: fire, wind, and water")
    time.sleep(3)
    print("As it rapidly approaches, you prepare to fight!")
    time.sleep(2)

def capital_script():
    print("You finally arrive at the gates of the capital")
    time.sleep(2)
    print("You have never seen the normally busy city so deserted")
    time.sleep(2)
    print("You realize that monsters have gotten into the city as well")
    time.sleep(2)
    print("You will have to fight a little longer before you get to the dragon")
    time.sleep(3)

def dragon_script(baby_dragon_ending):
    print("You arrive at the spire where the dragon resides")
    time.sleep(2)
    print("You climb the many flights of stairs to get the top")
    time.sleep(2)
    print("This is it. This is where you confront the dragon that has been terrorizing your city")
    time.sleep(3)
    print("The dragon stares at you as you open the door to its residence")
    time.sleep(2)
    print("\"You're not the first one to try to kill me,\" it says")
    time.sleep(2)
    print("\"It's not me that's setting fire to your city")
    time.sleep(2)
    print("\"But if it's a fight you want, it's a fight you'll get\"")
    time.sleep(2)
    print("1. Fight")
    print("2. Talk")
    choice = script_choose()
    if choice == 1:
        return "attack"
    else:
        print("\"What is there to talk about?\"")
        time.sleep(2)
        print("\"I told you already. I'm not setting fire to this city\"")
        time.sleep(2)
        print("\"Your soldier are the ones doing it\"")
        time.sleep(2)
        print("\"They set fire to any building they suspect has a monster in it\"")
        time.sleep(2)
        print("\"You humans are the ones that stole my child!\"")
        time.sleep(2)
        if baby_dragon_ending == "peace":
            print("\"But...\"")
            time.sleep(2)
            print("The dragon leaps in to attack")
            time.sleep(2)
            print("You raise your sword, ready to defend yourself")
            time.sleep(5)
            print("But the attack never comes")
            time.sleep(2)
            print("The dragon is nuzzling the baby dragon you saved")
            time.sleep(2)
            print("\"Thank you\"")
            time.sleep(2)
            return "peace"
        else:
            print("The dragon leaps in to attack")
            time.sleep(2)
            return "attack"

def ending_script(dragon_ending):
    global travel
    global start
    if dragon_ending == "attack":
        print("You have slain the dragon")
        time.sleep(2)
        print("You search for the family, and eventually you find them")
        time.sleep(2)
        print("You return to a normal life in the capital")
        time.sleep(2)
    print("\n")
    print("\t█████  █   █  █████     █████  █   █  ████ ")
    print("\t  █    █   █  █         █      ██  █  █   █")
    print("\t  █    █████  █████     █████  █ █ █  █   █")
    print("\t  █    █   █  █         █      █  ██  █   █")
    print("\t  █    █   █  █████     █████  █   █  ████ ")
    time.sleep(5)
    travel = False
    start = True

while running:
    try:
########################################## Start ###########################################
        while start:
            CONTINUE_MESSAGE = False
            start_screen()
            try:
                choice = int(input("\nChoose option: "))
                while choice != 1 and choice != 2 and choice != 3 and choice != 4:
                    print("Error. Please Choose again")
                    choice = int(input("\nChoose option: "))
                if choice == 1:
                    get_name()
                    #####start_script()
                    start = False
                    battle = True
                if choice == 2:
                    choose_load()
                    if CONTINUE_MESSAGE:
                        continue
                    start = False
                    travel = True
                if choice == 3:
                    x = 1
                if choice == 4:
                    exit()
            except ValueError:
                print("Error. Please choose again")
                continue

########################################## Battle ##########################################
        while battle:
            if BATTLE_INITIATE == True:
                if area == 1:
                    enemies = [create_slime(area)]
                elif area == 2:
                    #####start_script_2()
                    enemies = spawn_enemies()
                elif area == 50:
                    goblin_king_script()
                    enemies = [create_goblin_king()]
                elif area == 100:
                    baby_dragon_ending = baby_dragon_script()
                    if baby_dragon_ending == "attack":
                        enemies = [create_baby_dragon()]
                    else:
                        battle = False
                        travel = True
                        TRAVEL_INITIATE == True
                        break
                elif player_3_ending == "attack":
                    enemies = [create_player_3_enemy()]
                elif area == 150:
                    mega_elemental_script()
                    enemies = [create_mega_elemental()]
                elif area == 200:
                    dragon_ending = dragon_script(baby_dragon_ending)
                    if dragon_ending == "attack":
                        enemies = [create_dragon()]
                    else:
                        battle = False
                        travel = True
                        TRAVEL_INITIATE == True
                        break
                else:
                    enemies = spawn_enemies()
                    
                print(Fore.RED + "\nAN ENEMY ATTACKS!")
                BATTLE_INITIATE = False
            if PLAYER1_WENT == False and PLAYER2_WENT == False:
                print_stats()
                
            # Player attack phase
            for player in players:
                if CONTINUE_MESSAGE:
                    continue
                try:
                    # Variables the establish whether a party member has acted
                    # Prevents abusing of the "continue" function
                    if player == player1:
                        if PLAYER1_WENT:
                            continue
                    if PLAYER2_ON == True:
                        if player == player2:
                            if PLAYER2_WENT:
                                continue

                    if player.status == "burn":
                        burn_effect(player)
                    if player.status == "freeze":
                        freeze_effect(player)
                        if CONTINUE_MESSAGE:
                            CONTINUE_MESSAGE = False
                            continue

                    player.choose_action()
                    choice = int(input("\nChoose action:")) - 1
                    
                    # Chose attack
                    if choice == 0:
                        chose_attack()
                        if CONTINUE_MESSAGE:
                            continue
                        
                    # Chose magic
                    elif choice == 1:
                        chose_magic(player)
                        if CONTINUE_MESSAGE:
                            continue
                        
                    # Chose item
                    elif choice == 2:
                        chose_item()
                        if CONTINUE_MESSAGE:
                            continue

                    elif choice == 3:
                        enemy_died(0)
                        enemy_died(0)
                        enemy_died(0)
                        enemy_died(0)
                        check_turn()
                    # Inputs something else
                    else:
                        print("Error. Please choose again")
                        CONTINUE_MESSAGE = True
                        continue

                    # Check if Player won
                    if len(enemies) == 0:
                        player_win()
                        break

                except ValueError:
                    print("Error. Please choose again")
                    CONTINUE_MESSAGE = True
                    continue

                except IndexError:
                    if len(enemies) == 0:
                        player_win()
                        break
                    print("Error. Please choose again")
                    CONTINUE_MESSAGE = True
                    continue
                            

            # Enemy attack phase
            for enemy in enemies:
                if CONTINUE_MESSAGE == True:
                    continue
                if len(enemy.magic) == 0:
                    enemy_choice = 0
                else:
                    enemy_choice = random.randrange(0, 2)
                # Reset the player turn check since the player has played properly
                # and the enemies get to attack
                PLAYER1_WENT = False
                PLAYER2_WENT = False
                if enemy.status == "burn":
                    burn_effect(enemy)
                if enemy.status == "freeze":
                    freeze_effect(enemy)
                    if CONTINUE_MESSAGE:
                        CONTINUE_MESSAGE = False
                        continue
                    
                if enemy_choice == 0: # Chose attack
                    enemy_attack(enemy)
                elif enemy_choice == 1: # Chose magic
                    if enemy.mp < 4:
                        enemy_attack(enemy)
                    else:
                        enemy_magic(enemy)

                # Check if Player lost
                if len(players) == 0:
                    print(Fore.RED + "You have been defeated...")
                    input()
                    battle = False
                    start = True

            CONTINUE_MESSAGE = False
            
########################################### Travel #########################################
        while travel:
            try:
                CONTINUE_MESSAGE = False
                if TRAVEL_INITIATE == True:
                    if player1 in dead_players:
                        i = dead_players.index(player1)
                        dead_players[i].hp = 20
                        players.append(dead_players[i])
                        del dead_players[i]
                    if PLAYER2_ON:
                        if player2 in dead_players:
                            i = dead_players.index(player2)
                            dead_players[i].hp = 20
                            players.append(dead_players[i])
                            del dead_players[i]
                    if PLAYER3_ON:
                        if player3 in dead_players:
                            i = dead_players.index(player3)
                            dead_players[i].hp = 20
                            players.append(dead_players[i])
                            del dead_players[i]
                    while exp >= next_lv:
                        hp_bar, mp_bar, attack_bar, defense_bar, mg_bar =\
                                Travel.level_up(players, hp_bar, mp_bar, attack_bar, defense_bar, mg_bar)
                        next_lv += 100
                        
                    if exp >= 1000:
                        if TIER2_UNLOCK == False:
                            print("Tier 2 spells unlocked")
                            player1.update_magic([fireball, eruption, heal_lv1])
                            TIER2_UNLOCK = True
                    if exp >= 2000:
                        if TIER3_UNLOCK == False:
                            print("Tier 3 spells unlocked")
                            player1.update_magic([fireball, eruption, inferno, heal_lv1])
                            player2.update_magic([zap, storm, thunder])
                            TIER3_UNLOCK = True
                            
                    if area == 50:
                        player_2_join_script()
                    elif area == 100:
                        player_3_ending = player_3_join_script(baby_dragon_ending)
                        if player_3_ending == "attack":
                            travel = False
                            BATTLE_INITIATE = True
                            battle = True
                    elif area == 180:
                        capital_script()
                    elif area == 200:
                        ending_script(dragon_ending)
                        break
                    event = Travel.battle_end()
                    if event == "chest":
                        player_items = Travel.chest_event(player_items)
                    elif event == "shop":
                        player_items, gold = Travel.shop_event(player_items, gold)
                    elif event == "fountain":
                        Travel.fountain_event(players)
                    else:
                        input("Press any key to continue")

                    TRAVEL_INITIATE = False
                autosave()
                if area == 49 or area == 99 or area == 149 or area == 199:
                    print(Fore.RED + "\nWARNING! BOSS INCOMING")
                print("\nYou are at area " + str(area))
                Travel.choose_action()
                choice = int(input("\nChoose action:")) - 1
                if choice == 0:
                    area += 1
                    travel = False
                    BATTLE_INITIATE = True
                    battle = True
                    continue
                elif choice == 1:
                    Travel.print_stats(players, exp, gold, next_lv)
                    continue
                elif choice == 2:
                    player_items = Travel.check_item(player_items, players, player1)
                    print_line()
                    continue
                elif choice == 3:
                    Travel.autoheal(players, player1)
                    continue
                elif choice == 4:
                    choose_save()
                    if CONTINUE_MESSAGE:
                        continue
                    print("File saved")
                    travel = False
                    start = True
                else:
                    print("Error. Please choose again")
                    continue

            except ValueError:
                print("Error. Please choose again")
                continue

            except IndexError:
                print("Error. Please choose again")
                continue
    except Exception as e:
        logging.exception("")
