JingBar = {}

function JingBar.OnFrameCreate()
--	Trace("Created\n")
	this:RegisterEvent("PLAYER_EXPERIENCE_UPDATE")
	ExpBar.OnEvent("PLAYER_EXPERIENCE_UPDATE")
end

function JingBar.OnEvent(event)
	if event == "PLAYER_EXPERIENCE_UPDATE" then
		local player = GetClientPlayer()
		if not player or player.dwID ~= arg0 then
			return
	  end
	  
	  local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
	  if not levelUp then
			return
		end
		
		local nDoubleExp = player.nDoubleExp;
		local nMaxDoubleExp = levelUp['MaxDoubleExp'];
		local nExpPerEnergy = levelUp['ExpPerEnergy'];
		
		local nPercentage = nDoubleExp * 100 / nMaxDoubleExp
    if nPercentage > 100 then
    	nPercentage = 100
    end
    
    if nPercentage < 0 then
    	nPercentage = 0
    end

--    Trace("nDoubleExp :"..nDoubleExp.."\n")
--    Trace("nMaxDoubleExp :"..nMaxDoubleExp.."\n")
--    Trace("nExpPerEnergy :"..nExpPerEnergy.."\n")
    
    local nEnergy = math.floor(nDoubleExp / nExpPerEnergy);
    local nMaxEnergy = math.floor(nMaxDoubleExp / nExpPerEnergy);
    
--    Trace("nEnergy :"..nEnergy.."\n")
--    Trace("nMaxEnergy :"..nMaxEnergy.."\n")
    
    local szText = nEnergy.."/"..nMaxEnergy;
		local text = this:Lookup("", "Text_JingBar");
    if text then
    	text:SetText(szText)
    end
    
		local image = this:Lookup("", "Image_JingBar");
		if image then
			image:SetPercentage(nPercentage / 100);
		end
	end
end
