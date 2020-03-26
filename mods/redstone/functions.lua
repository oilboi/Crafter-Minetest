--this converts a vector into absolute value
function vector.abs(v)
	return {
		x = math.abs(v.x),
		y = math.abs(v.y),
		z = math.abs(v.z)
	}
end
