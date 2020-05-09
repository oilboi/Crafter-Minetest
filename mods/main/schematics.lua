--[[
left - > right
bottom - > top
front -> back

]]--

tree_big = {
	size = {x = 5, y = 6, z = 5},
	data = {
		-- The side of the bush, with the ignore on top
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "ignore"},      {name = "ignore"},      {name = "ignore"},      {name = "ignore"},      {name = "ignore"}, -- middle layer
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},      {name = "ignore"},      {name = "ignore"},-- top layer
		
		
		-- The side of the bush, with the ignore on top
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	     {name = "ignore"},
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	     {name = "ignore"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"},  {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"},  {name = "main:leaves"}, -- lower layer
		{name = "ignore"},      {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"},  {name = "ignore"}, -- middle layer
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},      {name = "ignore"},       {name = "ignore"},-- top layer
		
		
		
		-- The side of the bush, with the ignore on top
		{name = "ignore"},	    {name = "ignore"},	    {name = "main:tree"},	{name = "ignore"},	    {name = "ignore"},
		{name = "ignore"},	    {name = "ignore"},	    {name = "main:tree"},	{name = "ignore"},	    {name = "ignore"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:tree"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:tree"},   {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "ignore"},      {name = "main:leaves"}, {name = "main:leaves"},   {name = "main:leaves"}, {name = "ignore"}, -- middle layer
		{name = "ignore"},	    {name = "ignore"},	    {name = "main:leaves"}, {name = "ignore"},      {name = "ignore"},-- top layer
		
		
		
		-- The other side of the bush, same as first side
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	     {name = "ignore"},
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	     {name = "ignore"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"},  {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"},  {name = "main:leaves"}, -- lower layer
		{name = "ignore"},      {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"},  {name = "ignore"}, -- middle layer
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},      {name = "ignore"},       {name = "ignore"},-- top layer
		
		
		
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "ignore"},      {name = "ignore"},      {name = "ignore"},      {name = "ignore"},      {name = "ignore"}, -- middle layer
		{name = "ignore"},	    {name = "ignore"},	    {name = "ignore"},      {name = "ignore"},      {name = "ignore"},-- top layer
		}
		}

tree_small = {
	size = {x = 3, y = 5, z = 3},
	data = {
		-- The side of the bush, with the air on top
		{name = "air"},	        {name = "air"},	        {name = "air"},
		{name = "air"},	        {name = "air"},	        {name = "air"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- middle layer
		{name = "air"},	        {name = "air"},	        {name = "air"}, -- top layer
		-- The center of the bush, with stem at the base and a pointy leave 2 nodes above
		{name = "air"},	        {name = "main:tree"},	   {name = "air"},
		{name = "air"},	        {name = "main:tree"},	   {name = "air"},
		{name = "main:leaves"}, {name = "main:tree"},	   {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"},      {name = "main:leaves"}, -- middle layer
		{name = "air"},	        {name = "main:leaves"},    {name = "air"}, -- top layer
		-- The other side of the bush, same as first side
		{name = "air"},	        {name = "air"},	        {name = "air"},
		{name = "air"},	        {name = "air"},	        {name = "air"},
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- lower layer
		{name = "main:leaves"}, {name = "main:leaves"}, {name = "main:leaves"}, -- middle layer
		{name = "air"},	        {name = "air"},	        {name = "air"}, -- top layer
		}
		}
