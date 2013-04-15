ShenBar = {}

function ShenBar.OnFrameCreate()
--	Trace("Created\n")
	this:RegisterEvent("PLAYER_EXPERIENCE_UPDATE")
	
	ExpBar.OnEvent("PLAYER_EXPERIENCE_UPDATE")
end

function ShenBar.OnEvent(event)
	if event == "PLAYER_EXPERIENCE_UPDATE" then
		local player = GetClientPlayer()
		if not player then
			Trace("[UI ExpBar] Error: get player failed when Player_Shen_OnEvent!\n")
			return
	  end
	  
	  local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
	  if not levelUp then
			Trace("[UI ExpBar] Error: GetLevelUpData failed when Player_Shen_OnEvent!\n")
			return
		end
		
		local nMaxStamina = levelUp['MaxStamina'];
		local nCurrentStamina = player.nCurrentStamina;
		
		local nPercentage = nCurrentStamina * 100 / nMaxStamina
    if nPercentage > 100 then
    	nPercentage = 100
    end
    
    if nPercentage < 0 then
    	nPercentage = 0
    end	
			
		local szText = nCurrentStamina.."/"..nMaxStamina;
		local text = this:Lookup("", "Text_ShenBar");
    if text then
    	text:SetText(szText)
    end
    
		local image = this:Lookup("", "Image_ShenBar");
		if image then
			image:SetPercentage(nPercentage / 100);
		end
	end
end
