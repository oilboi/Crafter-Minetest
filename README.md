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
```



## This game is in early alpha and uses a lot of experimental features in the engine

---

# ALPHA STATE CHANGELOG

> <a href="https://github.com/oilboi/Crafter/blob/master/old_changelog.md">Old Version Changelogs</a>

## 0.04
> Endless Horizons Update

- Added in prototype for new mechanics built ontop of the engine
- Added cactus
- Make cactus hurt player when they touch it using touch_hurt group
- Added aether portals
- Make flying pigs drop 1-6 gold
- Make mobs use builtin minetest.throw_item function (custom)
- Double flying pigs sight radius
- Add hurt_inside group
- Add lava and fire to hurt_inside group
- Make mobs get damaged in fire and lava
- Add prototype mining lazer
- Add prototype gravity gun
- Added ice
- Make players get suffocated inside solid nodes
- Ice now breaks into water
- Ice spawns when snowing, replaces water under air
- Players sneaking hide nametag
- Updated main menu texture to have better brightness/contrast
- Turned mobs into API
- Added creepig
- Flying Pig now throws TNT at player
- Redid fishing mechanics
- Redid bows and arrows
- Added collision detection to mobs
- Add fall damage to mobs
- Make fishing work
- Ice now breaks into water
- Added FOV fade
- Add experience
- Added in shadow to heart statbar
- Added enchanting
- Add cake and cursed cake
- Prevent player from getting suffocated while teleporting
- Added in custom breath handling
- Made drowning slower
- Stopped infinite drowning death
- Merged drowning functions with new player functions
- Added in gerold55 bubble texture with countdown
- Swapped bubble direction
- Added in hunger
- Tuned hunger
- Added block breaking induced hunger exhaustion
- Fixed dead players collecting xp
- Overhauled hunger
- Optimized hunger health regen
- Overhauled farming and plants
- Fire now uses node timers to run even faster and prevent forest fires from becoming extreme
- Crops are now easier to grow
- Various farming improvements
- Optimized snow to the extreme
- Added in broken nether trees
- Added in melons and stem growth type plants
- Make saplings use node timers with catchup
- Made rain look even better
- Stop FOV fading from causing motion sickness
- Crops are now destroyed if not enough light
- Begin experimental treecapitator test
- Revert experimental treecapitator test and release experiment as mod
- Add in xp debug test
- Made minecarts work even "better"
- Added in clientside WAILA
- Fixed vignette having a streak of pixels across top of screen
- Add in 22i's MC mobs
- Overhaul mobs and make them use bone based head movement
- Add in group_attack setting for mobs
- Readded in creeper, phyg, and pig
- Fix a lot of things
- Fix a lot of deprecated calls
- Fixed stone hoes actually being made out of stone
- Add in better arrow hit sounds
- Overhauled arrows
- Added WAIH
- Overhaul mobs damage color modifier
- Make exploding mobs flash while charging
- Fix more deprecated calls
- Overhauled spawn command for mobs to use raycasting
- Overhaul mobs again
- Explosions now fling and hurt mobs
- Phygs now flap wings and do not take fall damage
- More deprecated call fixed for 3d noise in aether, void, and nether
- Fix WAIH crashing with tool that has no tooldef
- Fixed boat scaling
- Use gerold55's nice xp orb texture
- Updated readme.md
- Added nitro creeper and it spawns in the nether
- Added damage texture modifier
- Add in custom explodey mob color modifier
- Add in custom blink timer for explodey mobs
- Overhauled drowning
- Drowning now takes away a full heart
- Overhauled mob jumping
- Added in 22i's slime model
- Exploding mobs now instantly dissapear when detonated
- Added in gunpowder and tnt is now made from it
- Added in spider
- Improved mob jumping
- Added in string
- Added in fishing - Fishing poles are made from sticks and string
- Fixed raw porkchops not being edible
- Fixed xp level number scaling huge
- Added in cool spider sounds
- Snow and ice now melts when not snowing
- Implemented mob pathfinding
- Add in snowman with 22i's model redesigned by ElCeejo
- Add in better particles for eating and treecapitator
- Make player model's head pitch follow the player's look pitch
- Make music play during certain parts of the day/night
- Tweaked collision detection for mobs and make slime collision radius fit their size
- FINALLY fix client not initializing properly in the world - fixes clientmods not loading on first startup and randomly failing to load :D :D :D
- Add in safety net to client not initializing clientmods from game memory leak
- Made chickens spawn
- Tuned chicken
- Made experience drop on mob death based on their hp
- Added lag correction to boats
- You no longer get hurt in nether lava when in an iron boat
- Boats now throw players up so they can make it to land
- Nether songs play 3-6 seconds after entering the nether
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
