--this converts a vector into absolute value
function vector.abs(vector)
	vector.x = math.abs(vector.x)
	vector.y = math.abs(vector.y)
	vector.z = math.abs(vector.z)
	return(vector)
end
