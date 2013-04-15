local COURES_PANEL_PATH = "UI/Config/default/Coures.ini"
local CAREER_COMMENT_DELAY_TIME = 10
local CAREER_DISABLE_TIME = 10 * 1000

local tTabContent = {"Left", "Mid", "Right"}
local tLinkCount, tLinkDefaultMap = Table_GetLinkCount()
local nCurEventLeven = nil

Coures = {}

local function OpenCharaterRide()
	OpenCharacterPanel(nil, "RIDE")
end

local tLinkPanel 

local function InitLinkPanel()
	local tLink = 
	{
		["characterPanel/Ride"] = OpenCharaterRide, --角色坐骑界面
		["ChannelsPanel"] = OpenChannelsPanel, --"经脉界面"
		["MiddleMap"] = OpenMiddleMap, --"大地图"，
		["ZhenPaiSkill"] = OpenZhenPaiSkill, --"镇派界面"
		["SkillPanel"] = OpenSkillPanel,--"武学界面"
		["GuildPanel"] = OpenGuildPanel,--"帮会界面"
		["GuildListPanel"] = OpenGuildListPanel,--"帮会推荐界面"
	}
	return tLink
end

local function ONOpenLinkPanel(szPanel)
	if not tLinkPanel then
		tLinkPanel = InitLinkPanel()
	end

	tLinkPanel[szPanel]()
end

function Coures.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	Coures.UpdateSize(this)
	
	SetCanCloseCouresPanel(false)
	this.dwStartTime = GetTickCount()
end

function Coures.OnFrameBreathe()
	if not this.dwStartTime then
		return
	end
	local hBtnClose = this:Lookup("Wnd_Content/Btn_Close")
	
	local dwTime = GetTickCount() - this.dwStartTime
	if this.bCountTime and dwTime < CAREER_DISABLE_TIME then
		local szTime = FixFloat((CAREER_DISABLE_TIME - dwTime)/1000, 0)
		hBtnClose:Lookup("", "Text_Close"):SetText(g_tStrings.STR_CLOSE .. " " .. szTime)
		hBtnClose:Enable(false)
		SetCanCloseCouresPanel(false)
		return
	end
	
	if CanCloseCouresPanel() then
		return	
	end
	
	hBtnClose:Lookup("", "Text_Close"):SetText(g_tStrings.STR_CLOSE)
	hBtnClose:Enable(true)
	this.dwStartTime = nil
	SetCanCloseCouresPanel(true)
end

function Coures.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		Coures.UpdateSize(this)
	end
end

function Coures.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "HI_List" then
		Coures.SelectTab(this)
		local nLevel = this:GetRoot().nLevel
		if nLevel then
			FireDataAnalysisEvent("CAREER_PANEL_TAB_CLICK", {nLevel})
		end
	elseif szName == "NPCGuide" then
		local dwLinkID = this:GetUserData()
		OnLinkNpc(dwLinkID)
	else
		local szPanelLink = szName:match("PanelLink/(.*)")
		if szPanelLink then
			ONOpenLinkPanel(szPanelLink)
		end
	end
end

function OnLinkNpc(dwLinkID, dwMapID)
	if not tLinkCount[dwLinkID] then
		return
	end
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return 
	end
	
	local hScene = hPlayer.GetScene()

	local tNpcInfo = nil
	local nIndex = 0
	if not dwMapID and tLinkCount[dwLinkID] == 1 then
		tNpcInfo = Table_GetCareerLinkNpcInfo(dwLinkID)
	else
		if not dwMapID then
			dwMapID = hScene.dwMapID
		end
		tNpcInfo = Table_GetCareerLinkNpcInfo(dwLinkID, dwMapID)
		if not tNpcInfo then
			dwMapID = tLinkDefaultMap[dwLinkID]
			tNpcInfo = Table_GetCareerLinkNpcInfo(dwLinkID, dwMapID)
		end
	end
	if not tNpcInfo then
		return
	end
	
	if tNpcInfo.dwMapID == hScene.dwMapID then
		local x, y, z = Scene_GameWorldPositionToScenePosition(tNpcInfo.fX, tNpcInfo.fY, tNpcInfo.fZ, 0)
		local nArea = GetRegionInfo(hScene.dwID, x, y, z)
		nIndex = MiddleMap.GetMapMiddleMapIndex(hScene.dwMapID, nArea)
	else
		for _, tMap in pairs(g_aCityPoint) do
			if tMap.mapid == tNpcInfo.dwMapID then
				nIndex = tMap.middlemapindex
				break
			end
		end
	end
	if not nIndex then 
		nIndex = 0
	end
	
	OpenMiddleMap(tNpcInfo.dwMapID, nIndex)
	local argSave0, argSave1, argSave2, argSave3, argSave4 = arg0, arg1, arg2, arg3 ,arg4
	arg0 = tNpcInfo.dwNpcID
	arg1 = tNpcInfo.szNpcName
	arg2 = tNpcInfo.fX
	arg3 = tNpcInfo.fY
	arg4 = tNpcInfo.szKind
	FireEvent("MARK_NPC")
	arg0, arg1, arg2, arg3, arg4 = argSave0, argSave1, argSave2, argSave3, argSave4
end

function Coures.UpdateSize(hFrame)
	local fWidthAll, fHeightAll = Station.GetClientSize()
	local fPosX, fPosY = hFrame:GetAbsPos()
	local fWidth, fHight = hFrame:GetSize()
	
	hFrame:SetRelPos((fWidthAll - fWidth) / 2, fPosY)
	hFrame:SetAbsPos((fWidthAll - fWidth) / 2, fPosY)
	
end

function Coures.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCoures()
	elseif szName == "Btn_Link" then
		OpenCyclopaediaCareer()
	end
end

function Coures.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "HI_List" then
		this.bMouse = true
		Coures.UpdateTabTitle(this)
	elseif szName == "NPCGuide" then
		local nFont = this:GetFontScheme()
		this.nNormalFont = nFont
		this:SetFontScheme(31)
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	else
		local nFont = this:GetFontScheme()
		this.nNormalFont = nFont
		local szPanelLink = szName:match("PanelLink/(.*)")
		if szPanelLink then
			this:SetFontScheme(31)
		end
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	end
end

function Coures.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "HI_List" then
		this.bMouse = false
		Coures.UpdateTabTitle(this)
	elseif szName == "NPCGuide" then
		this:SetFontScheme(this.nNormalFont)
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	else
		local szPanelLink = szName:match("PanelLink/(.*)")
		if szPanelLink then
			this:SetFontScheme(this.nNormalFont)
		end
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	end
end

function Coures.UpdateList(hFrame, nLevel)
	local tEvent = Table_GetCareerEvent(nLevel)
	
	local hList = hFrame:Lookup("Wnd_Content", "Handle_List")
	hList:Lookup("Text_Title"):SetText(tEvent.szTitle)
	
	local hTabList = hList:Lookup("Handle_TabList")	
	hTabList:Clear()
	
	for k , v in ipairs(tEvent.tTab) do
		local hTab = hTabList:AppendItemFromIni(COURES_PANEL_PATH, "HI_List")
		if k == 1 then
			hTab.bHomePage = true
		end
		hTab.nTabID = v
		local szName = Table_GetCareerTabName(v)
		hTab:Lookup("Text_List"):SetText(szName)
	end
	hTabList:FormatAllItemPos()
	Coures.SelectTab(hTabList:Lookup(0))
end

function Coures.SelectTab(hSelect)
	local hTabList = hSelect:GetParent()
	local nCount = hTabList:GetItemCount()
	for i = 0, nCount - 1 do
		local hChild = hTabList:Lookup(i)
		if hChild.bSelect then
			hChild.bSelect = false
			Coures.UpdateTabTitle(hChild)
		end
	end
	
	hSelect.bSelect = true
	Coures.UpdateTabTitle(hSelect)
	if hSelect.bHomePage then
		Coures.UpdateHomePage(hSelect:GetRoot(), hSelect.nTabID)
	else
		Coures.UpdateTabInfo(hSelect:GetRoot(), hSelect.nTabID)
	end
end

function Coures.UpdateTabTitle(hSelect)
	if hSelect.bSelect then
		hSelect:Lookup("Text_List"):SetFontScheme(22)
		hSelect:Lookup("Image_Select"):Show()
		hSelect:Lookup("Image_Mouse"):Hide()
		hSelect:Lookup("Image_List"):Hide()
	elseif hSelect.bMouse then
		hSelect:Lookup("Image_Select"):Hide()
		hSelect:Lookup("Image_Mouse"):Show()
		hSelect:Lookup("Image_List"):Hide()
	else
		hSelect:Lookup("Text_List"):SetFontScheme(5)
		hSelect:Lookup("Image_Select"):Hide()
		hSelect:Lookup("Image_Mouse"):Hide()
		hSelect:Lookup("Image_List"):Show()
	end
end

function Coures.UpdateHomePage(hFrame, nTabID)
	local tCareerTab = Table_GetCareerTab(nTabID)
	local hHandleAll = hFrame:Lookup("Wnd_Content", "")
	hHandleAll:Lookup("Handle_Tittle/Text_Tittle"):SetText(tCareerTab.szTitle)
	for k, v in ipairs(tTabContent) do
		local hContent = hHandleAll:Lookup("Handle_" .. v)
		hContent:Hide()
	end
	
	local hHandleCap = hHandleAll:Lookup("Handle_Cap")
	hHandleCap:Show()
	local hImage = hHandleCap:Lookup("Image_Cap")
	hImage:FromTextureFile(tCareerTab.tContent[1].szImage)
	local hText = hHandleCap:Lookup("Handle_CapText")
	hText:Clear()
	local szDescription = Coures.GetFormatNote(tCareerTab.szDescription, 135, 136)
	hText:AppendItemFromString(szDescription)
	hText:FormatAllItemPos()
	hText:Show()
end

function Coures.UpdateTabInfo(hFrame, nTabID)
	
	local tCareerTab = Table_GetCareerTab(nTabID)
	local hHandleAll = hFrame:Lookup("Wnd_Content", "")
	hHandleAll:Lookup("Handle_Tittle/Text_Tittle"):SetText(tCareerTab.szTitle)
	
	hHandleAll:Lookup("Handle_Cap"):Hide()
	hHandleAll:Lookup("Handle_Right/Image_Right"):Hide()
	local hText = hHandleAll:Lookup("Handle_Right/Handle_Text")
	hText:Hide()
	
	for k , v in ipairs(tTabContent) do
		local hContent = hHandleAll:Lookup("Handle_" .. v)
		hContent:Show()
		local hImage = hContent:Lookup(0)
		local hNote = hContent:Lookup(1)
		hNote:Clear()
		hImage:Hide()
	end
	
	for i = 1, #tCareerTab.tContent do
		local tContent = tCareerTab.tContent[i]
		local hContent = hHandleAll:Lookup("Handle_" .. tTabContent[i])
		local hImage = hContent:Lookup(0)
		hImage:FromTextureFile(tContent.szImage)
		hImage:Show()
		local szFormatNote = Coures.GetFormatNote(tContent.szNote, 162, 163)
		local hNote = hContent:Lookup(1)
		hNote:Clear()
		hNote:AppendItemFromString(szFormatNote)
		hNote:FormatAllItemPos()
	end
	
	if tCareerTab.szDescription and tCareerTab.szDescription ~= "" then
		local szDescription = Coures.GetFormatNote(tCareerTab.szDescription, 135, 136)
		hText:Clear()
		hText:AppendItemFromString(szDescription)
		hText:FormatAllItemPos()
		hText:Show()
	end
end

function Coures.GetFormatNote(szNote, nFont, nLinkFont)
	local szResult = ""
	szNote = string.gsub(szNote, "\\n", "\n")
	local nStart, nEnd, szLinkType, szLink = szNote:find("<(%a) ([^<]*)>")
	while nStart do 
		local szPrev = szNote:sub(1, nStart - 1)
		szResult = szResult .. GetFormatText(szPrev, nFont)	
		if szLinkType == "L" then
			local dwLinkID = tonumber(szLink)
			szResult = szResult .. MakeNPCGuideLink(g_tStrings.CAREER_GUIDE_NPC, nLinkFont, dwLinkID)
		elseif szLinkType == "P" then
			szResult = szResult .. MakePanelLink(g_tStrings.CAREER_GUIDE_OPEN_PANEL, nLinkFont, szLink)
		end
		
		szNote = szNote:sub(nEnd + 1)
		nStart, nEnd, szLinkType, szLink = szNote:find("<(%a) ([^<]*)>")
	end
	if szNote and szNote ~= "" then
		szResult = szResult .. GetFormatText(szNote, nFont)	
	end

	return szResult
end

function OpenCoures(nLevel, bCountTime, bDisableSound)
	if not IsCouresOpened() then
		Wnd.OpenWindow("Coures")
	end
	
	FireDataAnalysisEvent("CAREER_PANEL_OPEN", {nLevel})
	local hFrame = Station.Lookup("Normal/Coures")
	hFrame:BringToTop()
	hFrame.bCountTime = bCountTime
	hFrame.nLevel = nLevel
	Coures.UpdateList(hFrame, nLevel)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsCouresOpened()
	local hFrame = Station.Lookup("Normal/Coures")
	if hFrame then
		return true
	end
	
	return false
end

function CloseCoures(bDisableSound)
	if not IsCouresOpened() then
		return 
	end
	
	Wnd.CloseWindow("Coures")
	
	FireEvent("CLOSE_COURES")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function OnCareerComment()
	local dwPlayerID = arg0
	local hPlayer = GetClientPlayer()
	
	if dwPlayerID ~= hPlayer.dwID then
		return
	end
	
	if not Tagle_IsExitCareerEvent(hPlayer.nLevel) then
		return 
	end
	
	nCurLevel = hPlayer.nLevel
	local fnDelayComment
	fnDelayComment = function()
		local hClientPlayer = GetClientPlayer()
		if not hClientPlayer then
			DelayCall(CAREER_COMMENT_DELAY_TIME, fnDelayComment)
			return
		end
		local tCareerMap = Table_GetCareerMap(nCurLevel)
		local bInProperMap = false
		local dwPlayerMap = hClientPlayer.GetMapID() 
		for i = 1, #tCareerMap do
			if dwPlayerMap == tCareerMap[i] or (dwPlayerMap > 1 and tCareerMap[i] == 0)then
				bInProperMap = true
				break
			end
		end
		
		local _, nMapType = GetMapParams(dwPlayerMap)

		if not bInProperMap or hClientPlayer.bFightState or hClientPlayer.nMoveState == MOVE_STATE.ON_DEATH or nMapType ~= 0 then
			DelayCall(CAREER_COMMENT_DELAY_TIME, fnDelayComment)
			return
		end
		OpenCoures(nCurLevel, true)
	end
	
	fnDelayComment()
end

function MakeNPCGuideLink(szContent, nFont, dwLinkID, dwMapID)
	--[[
	local szLink = "<text>text="..EncodeComponentsString(szContent)..
		" font=".. nFont.." name=\"NPCGuide\" eventid=257 userdata="..dwLinkID.."</text>"
	--]]
	local szScript = nil
	if dwMapID then
		szScript = "this.dwMapID=" .. dwMapID
	end
	local szLink = GetFormatText(szContent, nFont, nil, nil, nil, 257, szScript, "NPCGuide", dwLinkID)
	return szLink
end

function MakePanelLink(szContent, nFont, szKey)
	local szName = "PanelLink/" .. szKey
	local szLink = "<text>text="..EncodeComponentsString(szContent)..
	" font=".. nFont.." name=\"" .. szName .. "\" eventid=257 </text>"
	return szLink
end

function SetCanCloseCouresPanel(bCanClose)
	Coures.bCanClose = bCanClose
end

function CanCloseCouresPanel()
	return Coures.bCanClose
end
RegisterEvent("PLAYER_LEVEL_UPDATE", function() OnCareerComment() end)
