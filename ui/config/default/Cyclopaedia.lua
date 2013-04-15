local CYCLOPAEDIA_GUIDE_MIN_lEVEL = 10
local CYCLOPAEDIA_GUIDE_MAX_lEVEL = 80

Cyclopaedia = {}

function Cyclopaedia.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("QUEST_ACCEPTED")
	this:RegisterEvent("QUEST_CANCELED")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("CURRENT_PLAYER_FORCE_CHANGED")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("INTERACTION_REQUEST_RESULT")
	
	Cyclopaedia.OnEvent("UI_SCALED")
	Cyclopaedia_Home.Update(this)	
end


function Cyclopaedia.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
	Cyclopaedia_Home.OnEvent(this, szEvent)
	Cyclopaedia_Log.OnEvent(this, szEvent)
end

function Cyclopaedia.OnEditSpecialKeyDown()
	Cyclopaedia_JX3Library.OnEditSpecialKeyDown(this)
	Cyclopaedia_Active.OnEditSpecialKeyDown(this)
	
	return 1
end

function Cyclopaedia.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" or szName == "Btn_Cancel" then
		CloseCyclopaedia()
		return
    elseif szName == "Btn_Equipment" then
        if not IsEquipInquireOpened() then
            OpenEquipInquire()
        else
            CloseEquipInquire()
        end
    elseif szName == "Btn_XoyoAsk" then
        OpenSelfXoyoAsk()
        return
	end
	Cyclopaedia_Home.OnLButtonClick(this)
	Cyclopaedia_JX3Library.OnLButtonClick(this)
	Cyclopaedia_Active.OnLButtonClick(this)
end

function Cyclopaedia.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Head" then
		return
	end

	local szFix = szName:match("CheckBox_(.*)")
	local hPage = this:GetParent():Lookup("Page_" .. szFix)
	local hWnd = hPage:GetFirstChild()
	if not hWnd then
		local hFrame = Wnd.OpenWindow("Cyclopaedia_" .. szFix)
		hWnd = hFrame:Lookup("Wnd_" .. szFix)
		hWnd:ChangeRelation(hPage, true, true)
		hWnd:SetRelPos(0, 0)
		Wnd.CloseWindow("Cyclopaedia_" .. szFix)
	end
	
	_G["Cyclopaedia_" .. szFix].Update(hWnd)
end



function Cyclopaedia.OnLButtonHold()
	Cyclopaedia.OnLButtonDown()
end

function Cyclopaedia.OnItemMouseEnter()

	local szType = this:GetType()
	if szType == "Text" and this:IsLink() then
		local nFont = this:GetFontScheme()
		this.nFont = nFont
		this:SetFontScheme(164)
		local hHandle = this:GetParent()
		hHandle:FormatAllItemPos()
	end
	
	Cyclopaedia_Home.OnItemMouseEnter(this)
	Cyclopaedia_Career.OnItemMouseEnter(this)
	Cyclopaedia_JX3Library.OnItemMouseEnter(this)
	Cyclopaedia_Active.OnItemMouseEnter(this)
	Cyclopaedia_FAQ.OnItemMouseEnter(this)
end

function Cyclopaedia.OnItemMouseLeave()
	
	local szType = this:GetType()
	if szType == "Text" and this:IsLink() then
		if this.nFont then
			this:SetFontScheme(this.nFont)
			local hHandle = this:GetParent()
			hHandle:FormatAllItemPos()
		end
	end
	
	Cyclopaedia_Home.OnItemMouseLeave(this)
	Cyclopaedia_Career.OnItemMouseLeave(this)
	Cyclopaedia_JX3Library.OnItemMouseLeave(this)
	Cyclopaedia_Active.OnItemMouseLeave(this)
	Cyclopaedia_FAQ.OnItemMouseLeave(this)
end

function Cyclopaedia.OnItemMouseWheel()
	Cyclopaedia_Home.OnItemMouseWheel(this)
	Cyclopaedia_Career.OnItemMouseWheel(this)
	Cyclopaedia_JX3Library.OnItemMouseWheel(this)
	Cyclopaedia_Active.OnItemMouseWheel(this)
	Cyclopaedia_FAQ.OnItemMouseWheel(this)
	Cyclopaedia_Log.OnItemMouseWheel(this)
	return 1
end

function Cyclopaedia.OnMouseWheel()
	if this:GetName() == "Cyclopaedia"	then
		return 1
	end
end

function Cyclopaedia.OnLButtonDown()
	Cyclopaedia_Home.OnLButtonDown(this)
	Cyclopaedia_Career.OnLButtonDown(this)
	Cyclopaedia_JX3Library.OnLButtonDown(this)
	Cyclopaedia_Active.OnLButtonDwon(this)
	Cyclopaedia_FAQ.OnLButtonDown(this)
	Cyclopaedia_Log.OnLButtonDown(this)
end

function Cyclopaedia.OnItemLButtonDown()
	Cyclopaedia_Home.OnItemLButtonDown(this)
	Cyclopaedia_Career.OnItemLButtonDown(this)
	Cyclopaedia_JX3Library.OnItemLButtonDown(this)
	Cyclopaedia_Active.OnItemLButtonDown(this)
	Cyclopaedia_FAQ.OnItemLButtonDown(this)
end

function Cyclopaedia.OnItemLButtonClick()
	local szType = this:GetType()
	if szType == "Text" and this:IsLink() and IsCtrlKeyDown() then
		szText = this:GetText()
		szLinkInfo = this:GetLinkInfo()
		EditBox_AppendEventLink(szText, szLinkInfo)
	end
	Cyclopaedia_Career.OnItemLButtonClick(this)
end


function Cyclopaedia.OnScrollBarPosChanged()
	Cyclopaedia_Home.OnScrollBarPosChanged(this)
	Cyclopaedia_Career.OnScrollBarPosChanged(this)
	Cyclopaedia_JX3Library.OnScrollBarPosChanged(this)
	Cyclopaedia_Active.OnScrollBarPosChanged(this)
	Cyclopaedia_FAQ.OnScrollBarPosChanged(this)
	Cyclopaedia_Log.OnScrollBarPosChanged(this)
end

function OpenCyclopaedia(bDisableSound)
	if not IsCyclopaediaOpened() then
		Wnd.OpenWindow("Cyclopaedia")
	end
	local hFrame = Station.Lookup("Normal/Cyclopaedia")
	hFrame:BringToTop()
	Cyclopaedia.dwOpenTime = GetTickCount()
	
	FireDataAnalysisEvent("CYCLOPAEDIA_PANEL_OPEN")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IsCyclopaediaOpened()
	local hFrame = Station.Lookup("Normal/Cyclopaedia")
	if hFrame then
		return true
	end
	
	return false
end

function CloseCyclopaedia(bDisableSound)
	if not IsCyclopaediaOpened() then
		return
	end
	
	Wnd.CloseWindow("Cyclopaedia")
	
	local dwNowTime = GetTickCount()
	FireDataAnalysisEvent("CYCLOPAEDIA_CLOSE_TIME", {Cyclopaedia.dwOpenTime, dwNowTime})
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function OpenCyclopaediaCareer()
	OpenCyclopaedia()
	
	local hFrame = Station.Lookup("Normal/Cyclopaedia")
	local hPageSet = hFrame:Lookup("PageSet_Total")
	hPageSet:ActivePage("Page_Career")
end

function Cyclopaedia_OnEventLink(szEvent)
	if szEvent ~= "EVENT_LINK_NOTIFY" then
		return
	end
	
	if IsCtrlKeyDown() then
		return
	end
	
	local szLinkInfo = arg0
	local szLinkEvent, szLinkArg = szLinkInfo:match("(%w+)/(.*)")
	if not szLinkEvent then
		return
	end
	
	if szLinkEvent == "CalenderTip" then
		local dwID = tonumber(szLinkArg)
		if IsCtrlKeyDown() then
			local tActive = Table_GetCalenderActivity(dwID)
			local szName = FormatString(g_tStrings.CYCLOPAEDIA_LINK_FORMAT, tActive.szName)
			EditBox_AppendEventLink(szName, "CalenderTip/" .. dwID)
		else
			local x, y = Cursor.GetPos()
			OutputActivityTip(dwID, {x, y, 10, 20})
		end
	elseif szLinkEvent == "TongActivity" then
		local szClassID, szSubClassID, szID = szLinkArg:match("(%w+)/(%w+)/(%w+)")
		local dwClassID = tonumber(szClassID)
		local dwSubClassID = tonumber(szSubClassID)
		local dwID = tonumber(szID)
		GuildPanel_OnLinkTongActivity(dwClassID, dwSubClassID, dwID)
	elseif szLinkEvent == "NPCGuide" then
		local dwID = tonumber(szLinkArg)
		OnLinkNpc(dwID)
    elseif szLinkEvent == "ItemLinkInfo" then
        local szType, szID = szLinkArg:match("(%w+)/(%w+)")
		local dwType = tonumber(szType)
		local dwID = tonumber(szID)
        local x, y = Cursor.GetPos()
        OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, dwType, dwID, {x, y, 10, 20}, true)
	end
	
	if szLinkEvent~= "Career" 
	and szLinkEvent ~= "Library" 
	and szLinkEvent ~= "DungeonInfo" 
	and szLinkEvent ~= "Active" 
	and szLinkEvent ~= "QuestDaily" 
	and szLinkEvent ~= "FieldPQ" then
		return
	end
	
	if not IsCyclopaediaOpened() then
		OpenCyclopaedia()
	end
	
	local hFrame = Station.Lookup("Normal/Cyclopaedia")
	hFrame:BringToTop()
	local hPageSet = hFrame:Lookup("PageSet_Total")
	if szLinkEvent == "Career" then
		local nLevel = tonumber(szLinkArg)
		hPageSet:ActivePage("Page_Career")
		Cyclopaedia_LinkCareer(hFrame, nLevel)
	elseif szLinkEvent == "Library" then
		local szClassID, szSubClassID, szID = szLinkArg:match("(%w+)/(%w+)/(%w+)")
		local dwClassID = tonumber(szClassID)
		local dwSubClassID = tonumber(szSubClassID)
		local dwID = tonumber(szID)
		hPageSet:ActivePage("Page_JX3Library")
		Cyclopaedia_LinkJX3Library(hFrame, dwClassID, dwSubClassID, dwID)
	elseif szLinkEvent == "DungeonInfo" or szLinkEvent == "Active" 
	or szLinkEvent == "QuestDaily" or szLinkEvent == "FieldPQ" then
		local szClassID, szID = szLinkArg:match("(%w+)/(%w+)") 
		local dwClassID = tonumber(szClassID)
		local dwID = tonumber(szID)
		hPageSet:ActivePage("Page_Active")
		Cyclopaedia_LinkActive(hFrame, szLinkEvent, dwClassID, dwID)
	end
end

RegisterEvent("EVENT_LINK_NOTIFY", function(szEvent) Cyclopaedia_OnEventLink(szEvent) end)

function Cyclopaedia_OnGuide(szEvent)
	if szEvent ~= "LOGIN_GAME" then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	if hPlayer.nLevel < CYCLOPAEDIA_GUIDE_MAX_lEVEL then
		return
	end
	
	if ActivePopularize.bPopActivePopularize then
		OpenActivePopularize()
	end
end

RegisterEvent("LOGIN_GAME", function(szEvent) Cyclopaedia_OnGuide(szEvent) end)






