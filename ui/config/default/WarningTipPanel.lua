
tWarningTiptAnchor = {
    {s = "TOPCENTER", r = "TOPCENTER",  x = 0, y = 245},
    {s = "CENTER", r = "CENTER", x = 0, y = 245},
}

WarningTipPanel_Base = class()

local WARNING_TIP_PANEL_STARNING_TIME = 40
local WARNING_TIP_PANEL_DEFAULT_TIME = 4000
local tStarningAlpha = {255, 255, 255, 255, 255}
local nAlpha = 255
while true do
	nAlpha = nAlpha - 8
	if nAlpha < 64 then
		break
	end
	table.insert(tStarningAlpha, nAlpha)
end
local tWarningType = 
{
    ["MSG_WARNING_RED"] = {1, 0}, -- nWarningWindow, nWarningFrame -- 警告类
    ["MSG_WARNING_YELLOW"] = {1, 1}, -- nWarningWindow, nWarningFrame -- 警告类
    ["MSG_WARNING_GREEN"] = {1, 2}, -- nWarningWindow, nWarningFrame -- 警告类
    ["MSG_ADVERT_RED"] = {2, 6}, -- 推送类
    ["MSG_ADVERT_YELLOW"] = {2, 7}, -- 推送类
    ["MSG_ADVERT_GREEN"] = {2, 8}, -- 推送类
    ["MSG_REWARD_RED"] = {2, 9}, -- 嘉奖类
    ["MSG_REWARD_YELLOW"] = {2, 10}, -- 嘉奖类
    ["MSG_REWARD_GREEN"] = {2, 11}, -- 嘉奖类
    ["MSG_NOTICE_RED"] = {2, 3}, -- 提示类
    ["MSG_NOTICE_YELLOW"] = {2, 4}, -- 提示类
    ["MSG_NOTICE_GREEN"] = {2, 5}, -- 提示类
}

function WarningTipPanel_Base.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:GetSelf().OnEvent("UI_SCALED")
end

function WarningTipPanel_Base.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:GetSelf().UpdatePos(this)
	end
end

function WarningTipPanel_Base.UpdatePos(hFrame)
    local szName = hFrame:GetName()
    local szIndex = string.match(szName, "WarningTipPanel([%d]+)")
    local nIndex = tonumber(szIndex)
    local tAnchor = tWarningTiptAnchor[nIndex]
    
    hFrame:SetPoint(tAnchor.s, 0, 0, tAnchor.r, tAnchor.x, tAnchor.y)
	hFrame:CorrectPos()
end

function WarningTipPanel_Base.OnFrameBreathe()
	local dwTime = GetTickCount()
	if not this.dwStartTime then
		return
	end

	if dwTime - this.dwAlphaTime >= WARNING_TIP_PANEL_STARNING_TIME then
		this.dwAlphaTime = dwTime
		if not this.nAlphaIndex then
			this.nAlphaIndex = 0
		end
		this.nAlphaIndex = this.nAlphaIndex + 1
		if this.nAlphaIndex > #tStarningAlpha then
			this.nAlphaIndex = this.nAlphaIndex - #tStarningAlpha
		end
		this:GetSelf().UpdateHandleAlpha(this, tStarningAlpha[this.nAlphaIndex])
	end
    
	local szName = this:GetName()
    local szIndex = string.match(szName, "WarningTipPanel([%d]+)")
    local nIndex = tonumber(szIndex)
	if this.nLiveTime then
		if dwTime - this.dwStartTime > this.nLiveTime then
			CloseWarningTipPanel(nIndex)
			return
		end
	end
end

function WarningTipPanel_Base.UpdateText(hFrame, szText)
	local hText = hFrame:Lookup("", "Text_Tip")
	if not szText then
		szText = ""
	end
	hText:SetText(szText)
end

function WarningTipPanel_Base.UpdateHandleAlpha(hFrame, nAlpha)
	local hHandle = hFrame:Lookup("", "")
	hHandle:SetAlpha(nAlpha)
end

function WarningTipPanel_Base.UpdateBgImage(hFrame, nFrame)
	local hImage = hFrame:Lookup("", "Image_Bg1")
	hImage:SetFrame(nFrame)
end

function OpenWarningTipPanel(i)
	if not IsWarningTipPanelOpened(i) then
		Wnd.OpenWindow("WarningTipPanel", "WarningTipPanel" .. i)
	end
end

function OutputWarningMessage(szWarningType, szText, nTime)
    local nPanelIndex = tWarningType[szWarningType][1]
    local nFrame = tWarningType[szWarningType][2]
    OpenWarningTipPanel(nPanelIndex)
    local hFrame = Station.Lookup("Topmost/WarningTipPanel" .. nPanelIndex)
    if nTime then
        if nTime < 0 then
            hFrame.nLiveTime = nil
        else
            hFrame.nLiveTime = nTime * 1000
        end
    else
        hFrame.nLiveTime = WARNING_TIP_PANEL_DEFAULT_TIME
	end
	hFrame:GetSelf().UpdateText(hFrame, szText)
	hFrame:GetSelf().UpdateBgImage(hFrame, nFrame)
	hFrame.dwStartTime = GetTickCount()
	hFrame.dwAlphaTime = hFrame.dwStartTime
	hFrame:GetSelf().UpdateHandleAlpha(hFrame, 255)
	hFrame.nAlphaIndex = nil
end

--[[
function OutputWarningTip(nWarningType, nTextID, nTime)
	OpenWarningTipPanel("MSG_WARNING")
	local hFrame = Station.Lookup("Topmost/WarningTipPanel1")
	if hFrame.nTextID == nTextID and hFrame.nWarningType == nWarningType then
		return
	end
	hFrame.nTextID = nTextID
	hFrame.nWarningType = nWarningType
	hFrame.nLiveTime = nil
	if nTime then
		hFrame.nLiveTime = nTime * 1000
	end
	local szText = g_tStrings.tWarningTipText[nTextID]
	if not szText then
		szText = ""
	end
	hFrame:GetSelf().UpdateText(hFrame, szText)
	local nFrame = tWarningColorFrame[nWarningType]
	hFrame:GetSelf().UpdateBgImage(hFrame, nFrame)
	hFrame.dwStartTime = GetTickCount()
	hFrame.dwAlphaTime = hFrame.dwStartTime
	hFrame:GetSelf().UpdateHandleAlpha(hFrame, 255)
	hFrame.nAlphaIndex = nil
end
--]]
function CloseWarningMessage(szWarningType)
    local nPanelIndex = tWarningType[szWarningType][1]
    CloseWarningTipPanel(nPanelIndex)
end

function CloseWarningTipPanel(i, bDisableSound)
	if not IsWarningTipPanelOpened(i) then
		return
	end
	
	Wnd.CloseWindow("WarningTipPanel" .. i)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsWarningTipPanelOpened(i)
	local hFrame = Station.Lookup("Topmost/WarningTipPanel" .. i)
	if hFrame then
		return true
	end
	
	return false
end