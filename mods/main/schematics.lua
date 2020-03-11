--[[
left - > right
bottom - > top
front -> back

]]--

treeSchematic = {
	size = {x = 3, y = 6, z = 3},
	data = {
		-- The side of the bush, with the air on top
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- middle layer
		{name = "air"},	   {name = "air"},	   {name = "air"}, -- top layer
		-- The center of the bush, with stem at the base and a pointy leave 2 nodes above
		{name = "air"},	   {name = "main:tree"},	{name = "air"},
		{name = "air"},	   {name = "main:tree"},	{name = "air"},
		{name = "air"},	   {name = "main:tree"},	{name = "air"},
		{name = "main:leaves"}, {name = "main:tree"},	{name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:tree"},    {name = "main:leaves"}, -- middle layer
		{name = "air"},	   {name = "main:leaves"},    {name = "air"}, -- top layer
		-- The other side of the bush, same as first side
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "air"},	   {name = "air"},	   {name = "air"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- middle layer
		{name = "air"},	   {name = "air"},	   {name = "air"}, -- top layer
		}
		}
