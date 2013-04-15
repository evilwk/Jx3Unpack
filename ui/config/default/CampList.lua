CampList = 
{
	bExpand = true,
	bShowSureNotice = true,
}

local lc_hFrame

function CampList.OnFrameCreate()
	lc_hFrame = this
	CampList.Init(this)
end

function CampList.Init(frame)
	CampList.ExpandFrame(CampList.bExpand)
end

function CampList.PopupMenu()
	local tMenu = 
	{
		{szOption = g_tStrings.STR_CAMP_SURE_TITLE, bCheck=true, bChecked = CampList.bShowSureNotice, fnAction=function() CampQueue_SetSureNotcieShow(not CampList.bShowSureNotice) end },
	}
	PopupMenu(tMenu)
end

function CampList.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Setting" then
		CampList.PopupMenu()
		return true
	end
end

function CampList.OnCheckBoxCheck()
	if lc_hFrame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		CampList.ExpandFrame()
	end
end

function CampList.OnCheckBoxUncheck()
	if lc_hFrame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Minimize" then
		CampList.ExpandFrame()
	end
end

function CampList.ExpandFrame(bExpand)
	if bExpand ~= nil then
		CampList.bExpand = not bExpand
	end
	
	if CampList.bExpand then
		lc_hFrame:SetSize(234, 32)	
		lc_hFrame:Lookup("Wnd_List"):Hide()
		lc_hFrame:Lookup("Wnd_Title"):Lookup("CheckBox_Minimize"):Check(true)
	else
		lc_hFrame:SetSize(234, 84)
		lc_hFrame:Lookup("Wnd_List"):Show()
		lc_hFrame:Lookup("Wnd_Title"):Lookup("CheckBox_Minimize"):Check(false)
	end
	
	CampList.bExpand = not CampList.bExpand
end

function IsCampListOpen()
	local hFrame = Station.Lookup("Normal/CampList")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function OpenCampList(bDisableSound)
	lc_hFrame = Wnd.OpenWindow("CampList")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseCampList(bDisableSound)
	Wnd.CloseWindow("CampList")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local function UpdateQueuePos(nRank)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if not IsCampListOpen() then
		OpenCampList()
	end
	
	if not lc_hFrame then 
		return
	end
	local szCamp = g_tStrings.STR_CAMP_TITLE[player.nCamp]
	local szText = FormatString(g_tStrings.STR_CAMP_QUEUE, szCamp, nRank)
	local hContent = lc_hFrame:Lookup("Wnd_List", "Handle_Content")
	hContent:Clear()
	hContent:AppendItemFromString(szText)
	hContent:FormatAllItemPos()
end

function CampQueue_SetSureNotcieShow(bShow)
	CampList.bShowSureNotice = bShow
end

function CampQueue_IsShowSureNotcie()
	return CampList.bShowSureNotice
end

RegisterCustomData("CampList.bShowSureNotice")
RegisterEvent("CMAP_QUEUE_OVER", function() if IsCampListOpen() then CloseCampList() end  end)
RegisterEvent("CMAP_QUEUE_POS_UPDATE", function() UpdateQueuePos(arg0) end)