

function RandomName(RoleType)
	local ts = g_tGlue.tSurname
	local tn = g_tGlue.tName[RoleType]

	if not ts then return "" end
	if not tn then return "" end

	local tbn = g_tGlue.tBadName

	while true do
		local n = ts[math.random(#ts)]..tn[math.random(#tn)]
		if not tbn[n] then
			return n
		end
	end
end;

