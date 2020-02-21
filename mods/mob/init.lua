--this is where mobs are defined


local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path.."/spawning.lua")
dofile(path.."/items.lua")

local max_speed = 0.5

minetest.register_entity("mob:pig", {
      initial_properties = {
            hp_max = 1,
            physical = true,
            collide_with_objects = false,
            collisionbox = {-0.45, -0.01, -0.45, 0.45, 0.865, 0.45},
            visual = "mesh",
            visual_size = {x = 3, y = 3},
            mesh = "pig.b3d",
            textures = {
                  "nothing.png", -- baby
                  "pig.png", -- base
                  "nothing.png", -- saddle
            },
            is_visible = true,
            pointable = true,
            automatic_face_movement_dir = -90.0,
            automatic_face_movement_max_rotation_per_sec = 300,
      },

      timer = 0,
      hp = 5,
      direction_timer = 0,
      direction_timer_goal = 0,
      direction_change = false,
      change_direction = false,
      speed = 0,
      direction_goal = vector.new(0,0,0),
      mob = true,
      hostile = false,


      get_staticdata = function(self)
            return minetest.serialize({
                  --range = self.range,
                  hp = self.hp,            
            })
      end,
      
      on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1})
            --self.object:set_velocity({x = math.random(-5,5), y = 5, z = math.random(-5,5)})
            self.object:set_acceleration({x = 0, y = -9.81, z = 0})
            if string.sub(staticdata, 1, string.len("return")) == "return" then
                  local data = minetest.deserialize(staticdata)
                  if data and type(data) == "table" then
                        --self.range = data.range
                        self.hp = data.hp
                  end
            end
            self.object:set_animation({x=0,y=40}, 20, 0, true)
            self.object:set_hp(self.hp)
      end,
            
      on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            self.jump(self,true)
            local hurt = tool_capabilities.damage_groups.fleshy
            if not hurt then
                  hurt = 1
            end
            local hp = self.object:get_hp()
            self.object:set_hp(hp-hurt)
            if hp > 1 then
                  minetest.sound_play("hurt", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
            end
            self.hp = hp-hurt
      end,
      
      on_death = function(self, killer)
            local pos = self.object:getpos()
            pos.y = pos.y + 0.4
            minetest.sound_play("mob_die", {pos = pos, gain = 1.0})
            minetest.add_particlespawner({
                  amount = 40,
                  time = 0.001,
                  minpos = pos,
                  maxpos = pos,
                  minvel = vector.new(-5,-5,-5),
                  maxvel = vector.new(5,5,5),
                  minacc = {x=0, y=0, z=0},
                  maxacc = {x=0, y=0, z=0},
                  minexptime = 1.1,
                  maxexptime = 1.5,
                  minsize = 1,
                  maxsize = 2,
                  collisiondetection = false,
                  vertical = false,
                  texture = "smoke.png",
            })
            local obj = minetest.add_item(pos,"mob:raw_porkchop")
            obj:get_luaentity().collection_timer = 2
      end,
      
      --repel from players
      push = function(self)
            local pos = self.object:getpos()
            local radius = 1
            for _,object in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
                  if object:is_player() or object:get_luaentity().mob == true then
                        local player_pos = object:getpos()
                        pos.y = 0
                        player_pos.y = 0
                        
                        local currentvel = self.object:getvelocity()
                        local vel = vector.subtract(pos, player_pos)
                        vel = vector.normalize(vel)
                        local distance = vector.distance(pos,player_pos)
                        distance = (radius-distance)*10
                        vel = vector.multiply(vel,distance)
                        local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
                        
                        
                        self.object:add_velocity(acceleration)
                        
                        acceleration = vector.multiply(acceleration, -0.5)
                        object:add_player_velocity(acceleration)
                  end
            end
      end,
      
      --this makes the mob change it's direction when aimlessly walking
      direction = function(self,dtime)
            self.direction_timer = self.direction_timer + dtime
            
            self.change_direction = false
            
            --change direction
            if self.direction_timer >= self.direction_timer_goal then
                  --print("changing direction")
                  self.direction_timer = 0
                  self.direction_timer_goal = math.random(2,4)
                  self.change_direction = true
            end
      end,
      
      --this sets a random direction and speed when walking
      walk_random = function(self)
            if self.change_direction == true then
                  self.direction_goal = vector.new(math.random(-2,2),0,math.random(-2,2))
                  self.speed = math.random(1,2)
                  
                  --print(dump(self.direction_goal))
            end
      end,
      
      
      --This makes the mob walk at a certain speed
      move = function(self)
            local vel = self.object:getvelocity()
            local goal = self.direction_goal
            local acceleration = vector.new(goal.x-vel.x,0,goal.z-vel.z)
            self.object:add_velocity(acceleration)
      end,
      
      --make the mob jump
      jump = function(self,punched)
            local pos = self.object:getpos()
            local ray = Raycast(pos, vector.add(pos,self.direction_goal), false, false)
            local vel = self.object:getvelocity()
            
            if (punched or ray:next()) and minetest.get_node(vector.new(pos.x,pos.y-0.02,pos.z)).name ~= "air" and self.swimming == false then
                  --print("jump")
                  local vel = self.object:getvelocity()
                  local goal = 5
                  local acceleration = vector.new(0,goal-vel.y,0)
                  self.object:add_velocity(acceleration)
            end
      end,

      --makes the mob swim
      swim = function(self)
            local pos = self.object:getpos()
            pos.y = pos.y + 0.7
            local node = minetest.get_node(pos).name
            local vel = self.object:getvelocity()
            local goal = 3
            local acceleration = vector.new(0,goal-vel.y,0)
            self.swimming = false
            
            if node == "main:water" or node =="main:waterflow" then
                  self.swimming = true
                  self.object:add_velocity(acceleration)
            end
      end,
      
      --sets the mob animation and speed
      set_animation = function(self)
            local distance = vector.distance(vector.new(0,0,0), self.direction_goal)
            self.object:set_animation_frame_speed(distance*20)
      end,

      on_step = function(self, dtime)
            self.push(self)
            self.direction(self,dtime)
            if not self.path then
                  self.walk_random(self)
            end
            
            self.move(self)
            self.swim(self)
            self.jump(self,false)
            self.set_animation(self)
      end,
})
