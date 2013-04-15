g_tHelpData = {}
g_tHelpData.tRemindedHelper = {}
g_tHelpData.bHelpPanelShow = true

RegisterCustomData("g_tHelpData")

local HELPPANEL_HOLD_TIME = 15 * 1000
local HELPPANEL_SHOW_MAX_NUMBER = 3
local HELPPANEL_DEFAULT_OFFSET_X = -40
local HELPPANEL_DEFAULT_OFFSET_Y = 240
local REMINDED_HELPER_MAX_SIZE = 20

local nHelpPanelCount = 0
local tHelpPanelMap = {}
for i = 0, HELPPANEL_SHOW_MAX_NUMBER - 1 do
	tHelpPanelMap[i] = 0
end

HelpPanel_Base = class()

function HelpPanel_Base.OnFrameCreate()
	this:RegisterEvent("HELP_PANEL_SHOW_INFO_CHANGED")
	this:RegisterEvent("UI_SCALED")
end

function HelpPanel_Base.UpdateAnchor(hFrame)
	local nWidth, nHeight = hFrame:GetSize()
	local nOffsetY = HELPPANEL_DEFAULT_OFFSET_Y  + hFrame.ID * nHeight
	hFrame:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", HELPPANEL_DEFAULT_OFFSET_X , nOffsetY)
	hFrame:CorrectPos()
end

function HelpPanel_Base.OnEvent(szEvent)
	if szEvent == "HELP_PANEL_SHOW_INFO_CHANGED" then
		if not IsShowHelpPanel() then
			this:Hide()
		end
	elseif szEvent == "UI_SCALED" then
		this:GetSelf().UpdateAnchor(this)
	end
end

function HelpPanel_Base.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseHelpPanel(this:GetRoot(), true)
	elseif szName == "Btn_Search" then
		OpenGMPanel("Helper")
	end
end

function HelpPanel_Base.OnFrameBreathe()
	if GetTickCount() - this.dwStartTime > HELPPANEL_HOLD_TIME then
		 CloseHelpPanel(this)
	end
end

function HelpPanel_Base.OutPutMessage(hFrame, szMsg)
	local hHandle = hFrame:Lookup("", "Handle_Message")
	hHandle:Clear()
	hHandle:AppendItemFromString(szMsg)
	hHandle:FormatAllItemPos()
	if IsShowHelpPanel() then
		hFrame:Show()
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame) 
	else
		hFrame:Hide() 
	end	
	local tRemindedHelper = GetRemindedHelper()
	table.insert(tRemindedHelper, 1, szMsg)
	if #tRemindedHelper > REMINDED_HELPER_MAX_SIZE then
		table.remove(tRemindedHelper)
	end
end

function PopHelp(szMsg)
	local hFrame = CreateHelpFrame()
	hFrame:GetSelf().OutPutMessage(hFrame, szMsg)
	
	FireEvent("ON_OUT_PUT_COMMENT")
end

function CreateHelpFrame()
	local hFrame = Wnd.OpenWindow("HelpPanel", "HelpPanel"..nHelpPanelCount)
	assert(hFrame)
	hFrame.ID = GetHelpPanelMiniCountIndex()
	tHelpPanelMap[hFrame.ID] = tHelpPanelMap[hFrame.ID] + 1
	nHelpPanelCount = nHelpPanelCount + 1	
	
	hFrame.dwStartTime = GetTickCount()
	
	hFrame:GetSelf().UpdateAnchor(hFrame)
	
	return hFrame	
end

function CloseHelpPanel(hFrame, bDisableSound)
	local fStartX , fStartY = hFrame:GetAbsPos()
	local fWidth , fHeight = hFrame:GetSize()
	local hGMBtn = Station.Lookup("Topmost/SystemMenu/Wnd_Menu/Btn_GM")
	if hGMBtn and IsElemVisible(hGMBtn) then
		local fEndX, fEndY = hGMBtn:GetAbsPos()
		local fBtnWidth, fBtnHeight = hGMBtn:GetSize()
		CreateMinimizeEffect(fStartX, fStartY, fWidth, fHeight, fEndX, fEndY, fBtnWidth, fBtnHeight)
	end
		
	Wnd.CloseWindow(hFrame)
	tHelpPanelMap[hFrame.ID] = tHelpPanelMap[hFrame.ID] - 1
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end

function IsShowHelpPanel()
	return g_tHelpData.bHelpPanelShow
end

function SetShowHelpPanel(bShow)
	g_tHelpData.bHelpPanelShow = bShow
	FireEvent("HELP_PANEL_SHOW_INFO_CHANGED")
end

function GetHelpPanelMiniCountIndex()
	local nMiniCount = nil
	local nMiniIndex = nil
	for i = 0, HELPPANEL_SHOW_MAX_NUMBER - 1 do
		if not nMiniCount or not nMiniIndex or nMiniCount > tHelpPanelMap[i] then
			nMiniCount = tHelpPanelMap[i]
			nMiniIndex = i
		end
	end
	return nMiniIndex
end

function GetRemindedHelper()
	return g_tHelpData.tRemindedHelper
end

function LoadHelpPanelSetting()
	local szIniFilePath = GetUserDataPath()
	if szIniFilePath == "" then
		OpenDebuffList()
		return
	end
	szIniFilePath = szIniFilePath.."\\PannelSave.ini"

	local hIniFile = Ini.Open(szIniFilePath)
	if not hIniFile then
		OpenDebuffList()
		return
	end
	
	local szSection = "HelpPanel"
	
	local nShow = hIniFile:ReadInteger(szSection, "Show", 0)
	SetShowHelpPanel(not nShow or nShow ~= 0)
	
	hIniFile:Close()
end

RegisterLoadFunction(LoadHelpPanelSetting)

