<img src="https://github.com/oilboi/Crafter/blob/master/menu/header.png">

> Designed for Minetest 5.3.0-DEV

>Built using textures from <a href="https://forum.minetest.net/viewtopic.php?t=16407">Mineclone 2</a> 

---

## Be sure to install the clientside mod for this game mode: <a href="https://github.com/oilboi/crafter_client">Download here</a>

---

# ALPHA STATE CHANGELOG

> <a href="https://github.com/oilboi/Crafter/blob/master/old_changelog.md">Old Version Changelogs</a>

## 0.03
> It's A Real Game! Update
- make grass spread
- water buckets
- buckets water farmland
- pickaxe required to mine stone based nodes
- Crafting bench
- Farming with hoes, grass drops seeds, bread, etc
- simplify mobs ai
- running out of a node when placing tries to replace it with another of the same item in inventory
- crafting bench
- add in default furnace
- add backgrounds to all gui elements
- make furnaces drop all items on destroy instead of not allowing you to mine them
- added glass - smelt sand
- added boat 
- rightclicking with tool places torch
- add chest
- make chest drop all items when you mine them
- add in redstone:
- torch, repeater, comparator, inverter, piston, player detector,light,
- redstone ore - drops 4,5 redstone dust, turns on when punched
- pressure plate, detects players (output max), detects items (output based on number of items)
- fix item size based on number of items in stack to fixed size
- add hoppers
- Add TooManyItems
- add function to check which nodes drop the item
- fix hoppers not activating furnace
- make pigs head turn smoothly
- Add in fences, walls, windows
- Overhaul doors
- Add credits screen
- Add stairs
- Add slabs
- 2 Music tracks (day and morning)
- Add snow
- Fix bed placement
- Add snow and snowballs
- Make snow falling node
- Add creative mode
- Add trap chest and sticky piston
- Added Et QtFunny font info
- Added footers and books
- Added rain 
- Added Book sounds
- Changed TNT sound
- Overhauled eating
- Add in client weather handling
- Add in client movement handling
- Made sapling fuel
- Fix bed bed, boat, book, sapling, wood, minecart, rail, redstone, and boat placement
- Add sounds to redstone dust
- make redstone dust an attached node
- Fixed treecaptitator not cutting down part of tree when lever is powering one of it's nodes
- Added command for users with "server" privelage to control weather
- Added craft recipe to shears
- Moved to Minetest Engine Version 5.3.0 - DEV
- Added slimes
- Added mob criticals and client effects
- Added stream and river sound effect to client
- Moved underground cave noises to client
- Add line_of_sight so mobs can't hit you through walls
- Add nether prototype
- Fix water animation and add default Minetest water texture
- Tweak mob direct chase AI
---


# IDEAS:



## REDSTONE:
- breaker (mines whatever is in front of it)
- dispenser (shoots out first item in inventory, or shoots item into pipe)
- sticky piston (pulls node in front of it)
- piston in general (if node is falling and piston is pointing up then FLING IT, if detects falling node entity FLING IT)


---


## MOBS:

> #1 idea, - make mobs pathfind


### sheep
- sheep can be punched to drop wool without damage
- you can dye a sheep with colored dye and it will change color, then will drop the color you dyed it


### pig
- disable pig aggression
- make porkchop look nicer


### ghosts
- make the default player model whited out
- ghosts can pass through any nodes
- ghosts fly around
- will follow you groaning about "diamonds", "need food", and "join us"
- they will fling you up in the air or punch you
- ghosts can drag you down into nodes and suffocate you
- spawn with cave sounds
- drop soul


### node monster
- gets built out of nodes in the area
- will probabaly destroy you
- drops all nodes that it's made of when killed


### Exploder
- sneaks up on you and then explodes
- drops gun powder


---


## Game Mechanics:
- xp (edit the node drops code to check if node has tag for xp)
- brewing
- enchanting/upgrading
- magic (wands, spells, etc)
- better combat ( sweep hit enemies, falling while hitting deals more damage )


---


## New Themes

### mechanics (mechanical tools and machines)
- compressor (compresses nodes down)
- auto miner (digs whatever is in front of it)
- decompressor (opposite of compressor


### automation 
- pipes
- pumps
- fluid  transfer
- fluid storage
- pipes should be able to move objects quickly


### HALLOWEEN!
- pumpkins
- Jack O'Lanterns
- corn and corn stalks
- decorations
- cobwebs
- costumes (somehow?)
- candy
- make grass and leaves orange during the month of October
- (Use a simple date check and override nodes)
- Gravestones
- Graveyards
- Candles
- candy apples
- Soul cake, make with cake and soul


### Farming
- add fertilizer (pig drops bone randomly) 
- fertilizer is made out of bone - 
- fertilizer can make tall grass grow on regular grass
- bread - 3 bread in a row
- make sandwich with bread and cooked porkchop
- fertilizer used on saplings randomly make tree grow (make sapling growth a function)


### Fishing
- have a rod that you can cast into water
- bobber entity which goes under water when fish on line


---


## New Items

> These don't seem to fit into any theme so list them all here

- sugar and sugar cane (grow near water on sand)
- rope and tnt arrows
- vehicles (car, powered minecarts, trains)
- hitscan flintlocks
- bows


---


## Ideas

> These ideas are all over the place but are good for future updates

- make pistons able to push and pull any node that does not use meta or inv
- make pistons able to push and pull deactivated pistons
- upgrade minecart physics even more 
- make torches abm that checks if player in area
- make furnace abm that checks if player in area
- 3d character
- make tnt hurt player
- rewrite minecart
- fix tool rightclick torch placement to replace buildable to nodes
- if placed last node put another stack into hand
- have falling node hurt player?
- add a function to set a velocity goal to entities and then implement it with all entities
- ^make a value if below then stop?
- colored chat messages
- check if everyone is in bed before going to next night
- also lock player in bed until they get out or daytime
- create a function to check if a node or group is below
- ^ set meta for player so that all mods can use it without calculating it
- ^ over and over again (saves cpu cycles)
- cars buildable in crafting table
- require gas pumps refine oil
- drive next to gas pump and car will fill with gas
- maybe have pump be rightclickable and then manually fill with gass using nozel
- minecart car train? - off rail use
- automatic step height for off rail use
- make cars follow each other
- oil which spawns underground in pools
- powered minecart car (engine car)
- chest minecart car
- player controls engine car
- make entities push against players


---


## Possible Applications

> causes object to magnetize towards player or other objects and stop after an inner radius
> use for better item magnet?
```
if object:is_player() and object:get_player_name() ~= self.rider then
      local player_pos = object:getpos()
      pos.y = 0
      player_pos.y = 0
      
      local currentvel = self.object:getvelocity()
      local vel = vector.subtract(pos, player_pos)
      vel = vector.normalize(vel)
      local distance = vector.distance(pos,player_pos)
      distance = (1-distance)*10
      vel = vector.multiply(vel,distance)
      local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
      
      
      if self.axis == "x"      then
            self.object:add_velocity(vector.new(acceleration.x,0,0))
      elseif self.axis == "z" then
            self.object:add_velocity(vector.new(0,0,acceleration.z))
      else
            self.object:add_velocity(acceleration)
      end
      
      - acceleration = vector.multiply(acceleration, -1)
      - object:add_player_velocity(acceleration)
end
```
