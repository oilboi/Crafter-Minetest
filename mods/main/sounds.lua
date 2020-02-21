function main.stoneSound(table)
      table = table or {}
      table.dig = table.dig or
                  {name = "stone",gain=0.3}
      table.footstep = table.footstep or
                  {name = "stone", gain = 0.2}
      table.dug = table.dug or
                  {name = "stone", gain = 1.0}
      table.place = table.place or
                  {name = "stone", gain = 1.0}
      --default.node_sound_defaults(table)
      return table
end

function main.woodSound(table)
      table = table or {}
      table.dig = table.dig or
                  {name = "wood",gain=0.3}
      table.footstep = table.footstep or
                  {name = "wood", gain = 0.2}
      table.dug = table.dug or
                  {name = "wood", gain = 1.0}
      table.place = table.place or
                  {name = "wood", gain = 1.0}
      --default.node_sound_defaults(table)
      return table
end


function main.sandSound(table)
      table = table or {}
      table.dig = table.dig or
                  {name = "sand",gain=0.3}
      table.footstep = table.footstep or
                  {name = "sand", gain = 0.2}
      table.dug = table.dug or
                  {name = "sand", gain = 0.3}
      table.place = table.place or
                  {name = "sand", gain = 0.3}
      --default.node_sound_defaults(table)
      return table
end

function main.grassSound(table)
      table = table or {}
      table.dig = table.dig or
                  {name = "leaves",gain=0.3}
      table.footstep = table.footstep or
                  {name = "leaves", gain = 0.2}
      table.dug = table.dug or
                  {name = "leaves", gain = 1.0}
      table.place = table.place or
                  {name = "leaves", gain = 0.5}
      --default.node_sound_defaults(table)
      return table
end
function main.dirtSound(table)
      table = table or {}
      table.dig = table.dig or
                  {name = "dirt",gain=0.5}
      table.footstep = table.footstep or
                  {name = "dirt", gain = 0.3}
      table.dug = table.dug or
                  {name = "dirt", gain = 1.0}
      table.place = table.place or
                  {name = "dirt", gain = 0.5}
      --default.node_sound_defaults(table)
      return table
end
