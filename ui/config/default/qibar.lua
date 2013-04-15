QiBar = {}

function QiBar.OnFrameCreate()
	this:RegisterEvent("PLAYER_QI_UPDATE", GetClientPlayer().dwID)
	QiBar.OnEvent("PLAYER_QI_UPDATE")
end

function QiBar.OnEvent(event)
if event == "PLAYER_QI_UPDATE" then
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
		
		local nCurrentQi = player.nCurrentQi;
		local nMaxQi = levelUp['MaxQi'];
		local nPercentage = nCurrentQi * 100 / nMaxQi
    local szText = nCurrentQi.."/"..nMaxQi
		local text = this:Lookup("", "Text_QiBar")
    if text then
    	text:SetText(szText)
    end
    
		local image = this:Lookup("", "Image_QiBar")
		if image then
			image:SetPercentage(nPercentage / 100)
		end
	end
end
