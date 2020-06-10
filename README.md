<img src="https://github.com/oilboi/Crafter/blob/master/menu/header.png">

> Designed for Minetest 5.3.0-DEV

>Built using textures from <a href="https://forum.minetest.net/viewtopic.php?t=16407">Mineclone 2</a> 

---

## Be sure to install the clientside mod for this game mode: <a href="https://github.com/oilboi/crafter_client">Download here</a>




## If you want to run this on a server you must add this to your server minetest.conf:

```
enable_client_modding = true
csm_restriction_flags = 0
enable_mod_channels = true
secure.http_mods = skins
```



## This game is in early alpha and uses a lot of experimental features in the engine

---

# ALPHA STATE CHANGELOG

> <a href="https://github.com/oilboi/Crafter/blob/master/old_changelog.md">Old Version Changelogs</a>

## Alpha 0.05

> Multiplayer Polishing Update
- Fixed only one player being able to run on a server
- Fixed only one person being able to teleport in the same server step
- Players now use the same damage mechaninism as mobs
- Fixed wrong variable for durability assigned to all swords
- Fix bug in experience
- Fully implemented bows and arrows
- Tuned the bow and arrows even further
- Snowmen now drop a carrot, coal, stick, or snowball
- Added in armor
- Tuned a lot of things
- Made armor work
- Added in Krock's awesome Colored Names mod for csm chat
- Added sheep
- Fixed global mob handling
- Added in better fire
- Overhauled weather effects
- Added in clientside modchannel lockout to check if server sending message
- Added in capes
- Overhauled client mod version checking
- Overhauled mob pathfinding AI
- Overhauled fire
- Fixed Crafter Client from crashing if joining a non-crafter server
- Heavily optimized network usage with player mechanics to client mod
- Updated player_api for next step in optimization
---


# IDEAS:

## jetpack:
- equipped like armor
- uses XP


## REDSTONE:
- breaker (mines whatever is in front of it)
- dispenser (shoots out first item in inventory, or shoots item into pipe)
- piston in general (if node is falling and piston is pointing up then FLING IT, if detects falling node entity FLING IT)


---



## BUILDTEST:
- quarry
- filter
- siv
- mining lazer
- trains



---


## MOBS:

> #1 idea: weakness items, items that damage the mob more than diamond swords

### snowman
- you can put a pumpkin on it's head to make it survive when it's not snowing out
- drops snowballs, coal, or carrot

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



---


## Game Mechanics:
- brewing
- enchanting/upgrading
- magic (wands, spells, etc)
- better combat ( sweep hit enemies, falling while hitting deals more damage )
- Enchanting food - gives buffs
- LATE effects https://forum.minetest.net/viewtopic.php?t=20724


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
- enchanted fish
- player casts out a better lure if on a boat


---


## New Items

> These don't seem to fit into any theme so list them all here

- rope and tnt arrows
- vehicles (car, powered minecarts, trains)
- hitscan flintlocks


---


## Ideas

> These ideas are all over the place but are good for future updates

- make pistons able to push and pull any node that does not use meta or inv
- make pistons able to push and pull deactivated pistons
- upgrade minecart physics even more 
- make torches abm that checks if player in area
- make furnace abm that checks if player in area
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
