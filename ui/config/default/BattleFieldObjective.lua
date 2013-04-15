
BattleFieldObjective = {}

local INI_FILE_PATH = "UI/Config/Default/BattleFieldPanel.ini"

function BattleFieldObjective.OnFrameCreate()
	this:RegisterEvent("BATTLE_FIELD_UPDATE_OBJECTIVE")
	this:RegisterEvent("UI_SCALED")
end

function BattleFieldObjective.OnEvent(szEvent)
	if szEvent == "BATTLE_FIELD_UPDATE_OBJECTIVE" then
		BattleFieldObjective.UpateFrame(this)
	elseif szEvent == "UI_SCALED" then
		BattleFieldObjective.UpdateAnchor(this)
	end
end

function BattleFieldObjective.UpateFrame(hFrame)
	local hObjective = hFrame:Lookup("", "Handle_Objective")
	hObjective:Clear()
	
	local tObjective = GetBattleFieldObjective()
	if not tObjective then
		return
	end
	
	local _, dwPQTemplateID = GetBattleFieldPQInfo()
	if not dwPQTemplateID or dwPQTemplateID == 0 then
		return
	end
	
	local tObjectiveInfo = g_tTable.PQObjective:Search(dwPQTemplateID)
	assert(tObjectiveInfo)
	
	local szText = ""
	for nIndex, tData in ipairs(tObjective) do
		local szTitle = tObjectiveInfo["szObjective" .. nIndex]
		if szTitle and #szTitle > 0 then
			szText = szText .. szTitle
			szText = szText .. "<text>text=\"" .. tData[1] .. " / " .. tData[2] .. "\" font=187</text>"
			szText = szText .. "<text>text=\"\n\" font=187</text>"
		end
	end
	
	hObjective:AppendItemFromString(szText)
	hObjective:FormatAllItemPos()
	
	BattleFieldObjective.UpdateAnchor(hFrame)
end

function BattleFieldObjective.UpdateAnchor(hFrame)
	hFrame:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -30, 280)
	hFrame:CorrectPos()
end

function BattleFieldObjective.OnPlayerEnterScene()
	local hPlayer = GetClientPlayer()
	if hPlayer and arg0 == hPlayer.dwID then
		local hScene = hPlayer.GetScene()
		
		local hFrame = Station.Lookup("Normal/BattleFieldObjective")
		if Table_IsBattleFieldMap(hScene.dwMapID) then
			if not hFrame then
				hFrame = Wnd.OpenWindow("BattleFieldObjective")
			end
			hFrame:Show()
			BattleFieldObjective.UpateFrame(hFrame)
		else
			if not hFrame then
				return
			end
			hFrame:Hide()
		end
	end
end

RegisterEvent("PLAYER_ENTER_SCENE", BattleFieldObjective.OnPlayerEnterScene)