
FindTeamPQObjective = {}

local INI_FILE_PATH = "UI/Config/Default/FindTeamPQObjective.ini"

local function GetFormatTime(nTime, bFrame)
	if bFrame then
		nTime = math.floor(nTime / GLOBAL.GAME_FPS)
	end
	
	local nH = math.floor(nTime / 3600 % 24)
	local nM = math.floor((nTime % 3600) / 60)
	local nS = math.floor((nTime % 3600) % 60)
	local szTimeText = ""
	
	if nH < 10 then
		szTimeText = szTimeText.."0"
	end
	szTimeText= szTimeText..nH..":"

	if nM < 10 then
		szTimeText = szTimeText.."0"
	end
	szTimeText= szTimeText..nM..":"
	
	if nS < 10 then
		szTimeText = szTimeText.."0"
	end
	szTimeText= szTimeText..nS
	
	return szTimeText
end

function FindTeamPQObjective.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
end

function FindTeamPQObjective.OnFrameBreathe()
	if not this:IsVisible() then
		return
	end
	
	if this.nEndFrame then
		local hObjective = this:Lookup("", "Handle_Objective")
		local hText = hObjective:Lookup("PQTime")
		if hText then
			local nLeftTime = this.nEndFrame - GetLogicFrameCount()
			if nLeftTime < 0 then
				nLeftTime = 0
				this.nEndFrame = nil
			end
			hText:SetText(g_tStrings.STR_BATTLEFIELD_TIME_LEFT..GetFormatTime(nLeftTime, true))
			
			hText:AutoSize()
			hObjective:FormatAllItemPos()
		end
	end
end

function FindTeamPQObjective.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		FindTeamPQObjective.UpdateAnchor(this)
	end
end

function FindTeamPQObjective.UpateFrame(hFrame)
	local hObjective = hFrame:Lookup("", "Handle_Objective")
	hObjective:Clear()
	
	local tObjective = FindTeamPQObjective.tPQData
	if not tObjective then
		return
	end
	
	local dwPQTemplateID = FindTeamPQObjective.dwPQTemplateID
	if not dwPQTemplateID or dwPQTemplateID == 0 then
		return
	end
	
	local tObjectiveInfo = g_tTable.PQObjective:Search(dwPQTemplateID)
	assert(tObjectiveInfo)
	
	local szText = ""
	for nIndex, nValue in ipairs(tObjective) do
		local szTitle = tObjectiveInfo["szObjective" .. nIndex]
		if szTitle and #szTitle > 0 then
			szText = szText .. szTitle
			szText = szText .. "<text>text="..EncodeComponentsString(nValue).." font=187</text>"
			szText = szText .. "<text>text=\"\n\" font=187</text>"
		end
	end
	
	szText = szText.."<text>text=\"\" name=\"PQTime\" font=163</text>"
	
	hObjective:AppendItemFromString(szText)
	hObjective:FormatAllItemPos()
	
	FindTeamPQObjective.UpdateAnchor(hFrame)
end

function FindTeamPQObjective.UpdateAnchor(hFrame)
	hFrame:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -30, 280)
	hFrame:CorrectPos()
end

function FindTeamPQObjective.OnPlayerEnterScene()
	local hPlayer = GetClientPlayer()
	if hPlayer and hPlayer.dwID == arg0 then
		FindTeamPQObjective.OnRecruityDataUpdate()
	end
end

function FindTeamPQObjective.OnRecruityDataUpdate()
	local hPlayer = GetClientPlayer()
	local hScene = hPlayer.GetScene()
	local szState = GetPartyRecruitState()

	local hFrame = Station.Lookup("Normal/FindTeamPQObjective")
	if szState == "InFTDungeon" then
		if not hFrame then
			hFrame = Wnd.OpenWindow("FindTeamPQObjective")
		end
		hFrame:Show()
		FindTeamPQObjective.UpateFrame(hFrame)
	else
		if not hFrame then
			return
		end
		hFrame.nEndFrame = nil
		hFrame:Hide()
	end
end

--OnFindTeamPQUpdate(19, {10,20,30,40})
function OnFindTeamPQUpdate(dwPQTemplateID, tData, nEndFrame)
	local hFrame = Station.Lookup("Normal/FindTeamPQObjective")
	if not hFrame then
		hFrame = Wnd.OpenWindow("FindTeamPQObjective")
	end
	
	FindTeamPQObjective.dwPQTemplateID = dwPQTemplateID
	FindTeamPQObjective.tPQData = tData
	if nEndFrame then
		hFrame.nEndFrame = nEndFrame
	end
	
	FindTeamPQObjective.UpateFrame(hFrame)
end

function FindTeamPQObjective.OnFindTeamStartGame(nEndFrame)
	local hFrame = Station.Lookup("Normal/FindTeamPQObjective")
	if not hFrame then
		hFrame = Wnd.OpenWindow("FindTeamPQObjective")
	end
	
	local hObjective = hFrame:Lookup("", "Handle_Objective")
	local hText = hObjective:Lookup("PQTime")
	
	hFrame.nEndFrame = nEndFrame
	local nLogicFrame = GetLogicFrameCount()
	local nLeftTime = (nEndFrame - nLogicFrame)
	
	if nLeftTime < 0 then
		nLeftTime = 0 
	end
	
	hText:SetText(g_tStrings.STR_BATTLEFIELD_TIME_LEFT..GetFormatTime(nLeftTime))
	hText:AutoSize()
	hObjective:FormatAllItemPos()
	
	FindTeamPQObjective.UpdateAnchor(hFrame)
end

function FindTeamPQObjective.GetPQEndFrame()
	local hFrame = Station.Lookup("Normal/FindTeamPQObjective")
	if hFrame then
		return hFrame.nEndFrame
	end
end

RegisterEvent("PLAYER_ENTER_SCENE", FindTeamPQObjective.OnPlayerEnterScene)
RegisterEvent("PARTY_RECRUITY_DATA_UPDATE", FindTeamPQObjective.OnRecruityDataUpdate)
