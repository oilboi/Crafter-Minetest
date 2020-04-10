--this converts a vector into absolute value
function vector.abs(v)
	return {
		x = math.abs(v.x),
		y = math.abs(v.y),
		z = math.abs(v.z)
	}
end

--add a power signal to the position (i) that doesn't actually exist
redstone.inject_power_signal = function(i)
	if not r_index[i.x] then r_index[i.x] = {} end
	if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
	r_index[i.x][i.y][i.z] = {torch = true,power=9}
end
