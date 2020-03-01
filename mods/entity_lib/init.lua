--these are helpers to create entities

entity = {}


entity.move = function(self)
      if self.path then
            local vel = self.object:getvelocity()
            local pos = self.object:getpos()
            pos.y = 0
            local goal = table.copy(self.path[1])
            goal.y = 0
            
            local dir = vector.normalize(vector.subtract(goal,pos))
            local goal = vector.multiply(dir,2)
            
            local acceleration = vector.new(goal.x-vel.x,0,goal.z-vel.z)
            
            self.object:add_velocity(acceleration)
      end
end


entity.jump = function(self)
      if self.path then
            local pos = vector.floor(vector.add(self.object:getpos(), 0.5))
            local pos2  = self.path[1]
            
            print("-----------")
            
            print(dump(pos))
            
            print(dump(pos2))
            
            if pos2.y > pos.y then
                  print("jump")
                  local vel = self.object:getvelocity()
                  local goal = 5
                  local acceleration = vector.new(0,goal-vel.y,0)
                  self.object:add_velocity(acceleration)
            end
      end
end


entity.delete_path_node = function(self)
      local pos = vector.floor(vector.add(self.object:getpos(), 0.5))
      local goalnode = self.path[1]
      local at_goal = vector.equals(pos, goalnode)
      
      
      if at_goal then
            print("deleting path node")
            table.remove(self.path, 1)
      end 
      
      if table.getn(self.path) == 0 then
            self.path = nil
      end
end
