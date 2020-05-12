<img src="https://i.imgur.com/iEv1PXO.png">

## About
Minecraft mobs were remade in blender! Amazing!
## depends on -[ Blender](https://www.blender.org/)

<img src="https://avatars1.githubusercontent.com/u/17874916?v=4&u=ab21dbc761d43b8a6569431ac00c1b1738aefbf3&s=400" width="25"> [amc](https://github.com/22i/amc) - test mob looks <br /> <img src="https://avatars0.githubusercontent.com/u/10661113?v=4&s=400" width="25"> [mobs_mc](https://github.com/maikerumine/mobs_mc) - test minecraft mob abilities
<br /> <img src="http://repo.or.cz/MineClone/MineClone2.git/blob_plain/e2442a6283e164fa0c259edcad9f0928000103db:/menu/icon.png" width="32"> [MineClone2](https://forum.minetest.net/viewtopic.php?t=16407) - test epic Minecraft
- [How to recreate mobs from textures with Blender and Gimp](http://imgur.com/a/Iqg88)
- [mob blender pictures](https://imgur.com/a/FJXeT)
- get Minecraft [hmcl](http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-tools/1265720-hello-minecraft-launcher-2-6-0-4-forge-liteloader), [tlauncher](https://tlauncher.org/en/), [linux](https://rutracker.org/forum/viewtopic.php?t=4891689)

## Blender Setup
to make the model textures clearer in blender check the upper left menu bar - file - user preferences... <br /> on the system tab uncheck Mipmaps, set Anisotropic Filtering to Off and save user settings button in the lower left.

## Checking if texture mapping is correct
- get Minecraft [hmcl](http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-tools/1265720-hello-minecraft-launcher-2-6-0-4-forge-liteloader), [tlauncher](https://tlauncher.org/en/), [linux](https://rutracker.org/forum/viewtopic.php?t=4891689) you need java installed start it up in creative and spawn the mob you want by pressing T and pasting this command /summon pig ~ ~ ~ {NoAI:1} [usefull minecraft commands](https://github.com/22i/minecraft-voxel-blender-models/blob/master/usefull%20minecraft%20commands)
- open the blender model you want to test
- when in default view or animation view find the outliner window in the top right
- there should be armature click on the eye icon to hide the bones
- switch to UV editing view in the upper top menu bar
- have the same view over the mob in blender and minecraft to see if anything is off

### Exporting is complex and best be automated so if you know blender scripting post [here](https://github.com/22i/minecraft-voxel-blender-models/issues/2)

## Exporting 180 degress rotated

- dont forget to be in object mode and press SHIFT-C
- double press A to select everything then press SHIFT-CTRL-ALT-C origin to 3D cursor
- press 7 to switch to top view rotate with R for 180 degress CTRL-J to join all the objects together
- test animation by pressing ALT-A and export using [special minetest B3D exporter](https://github.com/minetest/B3Dexport)

## Exporting without rotation

- dont forget to be in object mode and press SHIFT-C
- double press A to select everything then press CTRL-J to join all the objects together
- test animation by pressing ALT-A and export using [special minetest B3D exporter](https://github.com/minetest/B3Dexport)

## Exporting tips for sheep

- join all the objects with fur in their name together with CTRL-J
- join all the objects with sheep in their name together with CTRL-J
- keep all the other objects separete
- dont forget to be in object mode and press SHIFT-C
- double press A to select everything then press SHIFT-CTRL-ALT-C origin to 3D cursor
- press 7 to switch to top view rotate with R for 180 degress
- test animation by pressing ALT-A and export using [special minetest B3D exporter](https://github.com/minetest/B3Dexport)

## Exporting tips for Enderman

- join both objects with 45flower in their name together with CTRL-J
- join both objects with 90flower in their name together with CTRL-J
- join all the objects with end in their name together with CTRL-J
- keep all the other objects and objects with cube in their name separete
- dont forget to be in object mode and press SHIFT-C
- double press A to select everything then press SHIFT-CTRL-ALT-C origin to 3D cursor
- press 7 to switch to top view rotate with R for 180 degress
- test animation by pressing ALT-A and export using [special minetest B3D exporter](https://github.com/minetest/B3Dexport)

## Exporting tips for Snowman

- join all the objects without pumpkin in their name together with CTRL-J
- dont forget to be in object mode and press SHIFT-C
- double press A to select everything then press SHIFT-CTRL-ALT-C origin to 3D cursor
- press 7 to switch to top view rotate with R for 180 degress
- test animation by pressing ALT-A and export using [special minetest B3D exporter](https://github.com/minetest/B3Dexport)

## Exporting tips for Mooshroom

- join all the objects named mooshrooom together with CTRL-J
- join all objects without mooshroom in name together with CTRL-J
- dont forget to be in object mode and press SHIFT-C
- double press A to select everything then press SHIFT-CTRL-ALT-C origin to 3D cursor
- press 7 to switch to top view rotate with R for 180 degress
- test animation by pressing ALT-A and export using [special minetest B3D exporter](https://github.com/minetest/B3Dexport)

## Exporting tips for mobs that hold items

- when exporting mobs that hold items like: zombie pigman. baby zombie pigman, vex, skeleton, stray, wither skeleton, illusioner and vindicator you have a choice between minecraft default item or pixel perfection item. If you want pp then delete the other holdable item without pp in the name.

## If exporting goes wrong

- if something is off, some cube is in wrong location or if animation is broken like with wither, enderdragon, wolf and skeleton reopen that .blend skip origin to 3D cursor part and put model into middle manualy.

<img src="https://i.imgur.com/Gr0ZUqy.png">

## Thanks to:
<img src="https://avatars0.githubusercontent.com/u/16853304?v=4&s=400" width="45"> [toby109tt](https://github.com/tobyplowy) mapping fixes - help with backface culling

<img src="https://avatars0.githubusercontent.com/u/10661113?v=4&s=400" width="45"> [maikerumine](https://github.com/maikerumine) making mobs_mc

<img src="https://avatars1.githubusercontent.com/u/1675853?v=4&s=400" width="45"> [Wuzzy](https://github.com/Wuzzy2) making MineClone2

<img src="https://avatars0.githubusercontent.com/u/8145060?v=4&s=400" width="45"> [Tenplus1](https://github.com/tenplus1) making Mobs Redo

<img src="https://i.imgur.com/MQtbnhd.png" width="45"> [XSSheep](http://www.minecraftforum.net/forums/mapping-and-modding/resource-packs/1242533-pixel-perfection-now-with-polar-bears-1-11) making Pixel Perfection

<img src="https://yt3.ggpht.com/-bbfDEHNw0jk/AAAAAAAAAAI/AAAAAAAAAAA/DhO39YPMYhw/s288-c-k-no-mo-rj-c0xffffff/photo.jpg" width="45"> [Nathan](https://www.youtube.com/channel/UCdiuryhdSBUxQse2rarVqPg/videos) making Minetest Blender tutorials [1](https://www.youtube.com/watch?v=1h6mozr0p0Y&list=PL-uTdq9t8wyyJWzahSrnCqmMz9lgUnuVF)

<img src="https://i.imgur.com/kHWR9cW.png" width="45"> [Mojang](https://mojang.com/) making Minecraft

<img src="https://avatars3.githubusercontent.com/u/2624745?v=4&s=200" width="45"> [Minetest team](https://github.com/minetest) making Minetest

<img src="https://avatars3.githubusercontent.com/u/1088750?v=4&s=400" width="45"> [Jordan4Ibanez](https://www.youtube.com/user/313hummer/videos) making OpenAi

<img src="https://forum.minetest.net/download/file.php?avatar=11478_1492572385.png" width="45"> [Christian9](https://forum.minetest.net/search.php?author_id=11478&sr=posts) help with 2 different textures on 1 mob

<img src="https://avatars1.githubusercontent.com/u/29333817?v=4&s=400" width="45"> [kingofscargames](https://github.com/kingoscargames) making new mob textures
