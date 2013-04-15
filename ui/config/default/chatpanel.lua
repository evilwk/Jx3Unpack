g_tChatPanelData = {}

local tDefaultMsg = 
{
	[g_tStrings.SYNTHESIS] = {"MSG_NORMAL", "MSG_WHISPER", "MSG_PARTY", "MSG_MAP", "MSG_NPC_DIALOG", "MSG_GROUP", "MSG_FACE", "MSG_SYS", "MSG_GUILD", "MSG_SCHOOL", "MSG_WORLD", "MSG_TEAM", "MSG_CAMP", "MSG_MENTOR",
		"MSG_BATTLE_FILED", "MSG_NOTICE", "MSG_MONEY", "MSG_EXP", "MSG_ITEM", "MSG_REPUTATION", "MSG_CONTRIBUTE", "MSG_PRESTIGE", "MSG_ATTRACTION", "MSG_TRAIN", "MSG_DESGNATION", "MSG_ACHIEVEMENT", "MSG_MENTOR_VALUE",
		"MSG_NPC_YELL", "MSG_NPC_NEARBY", "MSG_NPC_WHISPER", "MSG_NPC_FACE", "MSG_FRIEND", "MSG_DEVELOPMENT_POINT", "MSG_THEW_STAMINA"},
			
	[g_tStrings.FIGHT_CHANNEL] = {"MSG_EXP", "MSG_REPUTATION", "MSG_CONTRIBUTE", "MSG_PRESTIGE", "MSG_ATTRACTION", "MSG_TRAIN", "MSG_DESGNATION", "MSG_ACHIEVEMENT", "MSG_MENTOR_VALUE",
		"MSG_SKILL_SELF_SKILL", "MSG_SKILL_SELF_BUFF", "MSG_SKILL_SELF_DEBUFF", "MSG_SKILL_SELF_MISS", "MSG_OTHER_DEATH", "MSG_OTHER_ENCHANT", "MSG_OTHER_SCENE", "MSG_DEVELOPMENT_POINT"},
			
	[g_tStrings.CHANNEL_CHANNEL] = {"MSG_PARTY", "MSG_WHISPER", "MSG_NPC_NEARBY", "MSG_SYS", "MSG_GUILD", "MSG_TEAM", "MSG_NORMAL", "MSG_MENTOR", "MSG_FRIEND"},
	[g_tStrings.OTHER] = {"MSG_CAMP", "MSG_SCHOOL", "MSG_WHISPER", "MSG_NORMAL", "MSG_MAP"},
	[g_tStrings.CHANNEL_MENTOR] = {"MSG_SEEK_MENTOR", "MSG_MENTOR", "MSG_MENTOR_VALUE"},
    [g_tStrings.STR_SAY_SECRET] = {"MSG_WHISPER"},
}	

local tFontPathList = Font.GetFontPathList() or {}

local tDefaultSize = {w = 370, h = 140}
local tDefaultBgInfo = {bBgShow = true, rBg = 0, gBg = 0, bBg = 0, aBg = 120}
local tDefaultFontInfo = {Font.GetFont(0)}
local bChatPanelInitFlag = false

local szCurrentChatPannelVersion = "0.2"

RegisterCustomData("g_tChatPanelData")

function NewChatPanelMsgMonitor(nIndex)
	return function(szMsg, nFont, bRich, r, g, b)
		local t = GetGlobal("ChatPanel"..nIndex)
		if t then
			t:AppendMsg(szMsg, nFont, bRich, r, g, b)
		end
	end
end

function GetChatPanelDefaultAnchor()
	return {s = "BOTTOMLEFT", r = "BOTTOMLEFT",  x = 5, y = -165}
end

ChatPanel_Base = class()
function ChatPanel_Base:ctor(nIndex, szName, nBufferSize, nMainGroupIndex, msg, Anchor, tOffMsg)
	self.Data = GetChatData("ChatPanel"..nIndex)
	self.Data.nIndex = nIndex
	self.Data.szName = szName
	self.Data.nBufferSize = nBufferSize
	self.Data.nMainGroupIndex = nMainGroupIndex
	self.Data.msg = clone(msg)
	self.Monitor = NewChatPanelMsgMonitor(nIndex)
	self.Data.tOffMsg = tOffMsg
	if Anchor then
		self.Data.Anchor = Anchor
	else
		self.Data.Anchor = GetChatPanelDefaultAnchor()
	end
end

function ChatPanel_Base:GetCInstance()
	local hFrame = Station.Lookup("Lowest2/ChatPanel" .. self.Data.nIndex)
	return hFrame
end

function ChatPanel_Base.OnFrameCreate()
	local self = this:GetSelf()
	
	if self.Data.nMainGroupIndex and self.Data.nMainGroupIndex == 1 then
		this:RegisterEvent("WM_QUIT")
		this:RegisterEvent("PLAYER_EXIT_GAME")
		this:RegisterEvent("EDIT_BOX_ON_FOCUS")
		this:RegisterEvent("EDIT_BOX_MOUSE_ENTER")
	end
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	
	local wnd = this:Lookup("Wnd_Message")
	local handle = wnd:Lookup("", "Handle_Message")
	handle:EnableFormatWhenAppend(1)
	handle.nBufferSize = self.Data.nBufferSize
	handle.bEnd = true
	
	wnd:Lookup("Btn_DragTop"):RegisterLButtonDrag()
	wnd:Lookup("Btn_DragTopRight"):RegisterLButtonDrag()
	wnd:Lookup("Btn_DragRight"):RegisterLButtonDrag()
	if self.Data.nMainGroupIndex then
		wnd:Hide()
		this:Lookup("Btn_ChatSetting"):Hide()
	end
	
	this:Lookup("CheckBox_Title", "Text_TitleName"):SetText(self.Data.szName)
	--this:Lookup("CheckBox_Title"):Hide()
	self:UpdateCustomModeWindow()
	
	RegisterMsgMonitor(self.Monitor, self.Data.msg)
	self:UpdateAnchor()
end

function ChatPanel_Base.OnEvent(event)
	if event == "EDIT_BOX_ON_FOCUS" then
		if not IsEditBoxOnFocus() and  not IsEditBoxMouseEnter() then
			ChatPanel_Base_AjustMgTitleShow(false)
		else
			ChatPanel_Base_AjustMgTitleShow(true)
		end
	elseif event == "EDIT_BOX_MOUSE_ENTER" then
		if not IsEditBoxOnFocus() and  not IsEditBoxMouseEnter() then
			ChatPanel_Base_AjustMgTitleShow(false)
		else
			ChatPanel_Base_AjustMgTitleShow(true)
		end
	elseif event == "UI_SCALED" then
		this:GetSelf():UpdateAnchor()
		this:GetSelf():UpdateScrollInfo(this:Lookup("Wnd_Message", "Handle_Message"))
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		this:GetSelf():UpdateCustomModeWindow()
	end
end

function ChatPanel_Base:UpdateAnchor()
	local frame = self:GetCInstance()
	if not frame then
		return
	end
	
	frame:SetPoint(self.Data.Anchor.s, 0, 0, self.Data.Anchor.r, self.Data.Anchor.x, self.Data.Anchor.y)
	frame:CorrectPos()
	if self.Data.nMainGroupIndex then
		local x, y = frame:GetAbsPos()
		local w, h = frame:GetSize()
		local wA, hA = Station.GetClientSize()
		if y + h + 23 > hA then
			y = hA - h - 23
			frame:SetAbsPos(x, y)
		end
		ChatPanel_Base_AjustMgPanelPos()
	end
	
	if self.Data.nMainGroupIndex and self.Data.nMainGroupIndex == 1 then
		FireEvent("CHAT_PANEL_POS_CHANGED")
	end
	
end

function ChatPanel_Base:UpdateCustomModeWindow()
	local frame = self:GetCInstance()
	if not frame then
		return
	end
	local checkBox = frame:Lookup("CheckBox_Title")
	local szName = checkBox:Lookup("", "Text_TitleName"):GetText()
	if self.Data.nMainGroupIndex then
		local bIn = UpdateCustomModeWindow(frame, szName, nil, self.Data.nMainGroupIndex ~= 1)
		if bIn then
			ChatPanel_Base_SelMgTitle(1)
		else
			frame:EnableDrag(not frame.bLocked and checkBox:IsVisible())
			local x, y = checkBox:GetRelPos()
			local w, h = checkBox:GetSize()
			frame:SetDragArea(x, y, w, h)
		end
	else
		local bIn = UpdateCustomModeWindow(frame, szName)
		if not bIn then
			frame:EnableDrag(not frame.bLocked and checkBox:IsVisible())
			local x, y = checkBox:GetRelPos()
			local w, h = checkBox:GetSize()
			frame:SetDragArea(x, y, w, h)
		end
	end
end

function ChatPanel_Base.OnFrameDestroy()
	local self = this:GetSelf()
	
	if self.Data.nMainGroupIndex then
		local nIndex = self.Data.nMainGroupIndex
		ChatPanel_Base_AddMgIndexAfter(self.Data.nMainGroupIndex, -1)
		self.Data.nMainGroupIndex = nil
		ChatPanel_Base_AjustMgTitlePos()
		if nIndex > 1 then
			ChatPanel_Base_SelMgTitle(nIndex - 1)
		end
	end
	
	if self.Monitor then
		UnRegisterMsgMonitor(self.Monitor)
		SetGlobal(this:GetName(), nil)
	end
	
	g_tChatPanelData[this:GetName()] = nil
end

function ChatPanel_Base.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Home" or szName == "Btn_End" then
		this:GetRoot():GetSelf().OnLButtonDown()
	end
end

function ChatPanel_Base.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Home" then
		this:GetParent():Lookup("Scroll_Msg"):ScrollHome()
	elseif szName == "Btn_End" then
		this:GetParent():Lookup("Scroll_Msg"):ScrollEnd()
	elseif szName == "Btn_PageUp" then
	  this:GetParent():Lookup("Scroll_Msg"):ScrollPagePrev()
	elseif szName == "Btn_PageDown" then
    	this:GetParent():Lookup("Scroll_Msg"):ScrollPageNext()
    elseif szName == "Btn_ChatSetting" then
    	if IsChatSettingPanelOpened() then
    		CloseChatSettingPanel()
    	else
    		OpenChatSettingPanel()
    	end
	elseif this:GetRoot() == this then
		this:GetSelf().OnMouseHover()
		return 1
	end
end

--[[
function ChatPanel_Base.OnItemMouseEnter()
	local szName = this:GetName()
    if szName == "Handle_Message" then
        this.bMouseOver = true
    end
end

function ChatPanel_Base.OnItemMouseLeave()
	local szName = this:GetName()
      if szName == "Handle_Message" then
        this.bMouseOver = false
    end
end
--]]
function ChatPanel_Base.OnMouseWheel()
	local nDelta = Station.GetMessageWheelDelta()
	local frame = this:GetRoot()
	frame:Lookup("Wnd_Message/Scroll_Msg"):ScrollNext(nDelta)
	return 1
end

function ChatPanel_Base.OnScrollBarPosChanged()
	
	if this.bNoUpdate then
		return
	end
	
	local nCurrentValue = this:GetScrollPos()
	
	local handle = this:GetParent():Lookup("", "Handle_Message")
	if nCurrentValue == 0 then
		this:GetParent():Lookup("Btn_Home"):Enable(0)
		this:GetParent():Lookup("Btn_PageUp"):Enable(0)
	else
		this:GetParent():Lookup("Btn_Home"):Enable(1)
		this:GetParent():Lookup("Btn_PageUp"):Enable(1)
	end
	
	if nCurrentValue == this:GetStepCount() then
		this:GetParent():Lookup("Btn_End"):Enable(0)
		this:GetParent():Lookup("Btn_PageDown"):Enable(0)
		handle.bEnd = true
	else
		this:GetParent():Lookup("Btn_End"):Enable(1)
		this:GetParent():Lookup("Btn_PageDown"):Enable(1)
		handle.bEnd = false
	end
	
	if handle.bEnd then
		local w, h = handle:GetSize()
		local wA, hA = handle:GetAllItemSize()	
		handle:SetItemStartRelPos(0, h - hA)
	else
		handle:SetItemStartRelPos(0, - nCurrentValue * 10)
	end
end

function ChatPanel_Base:UpdateScrollInfo(handle)
	local w, h = handle:GetSize()
	local wA, hA = handle:GetAllItemSize()
	local scroll = handle:GetParent():GetParent():Lookup("Scroll_Msg")
	
	scroll.bNoUpdate = true
	scroll:SetStepCount((hA - h) / 10)
	if handle.bEnd then
		scroll:ScrollEnd()
	end
	scroll.bNoUpdate = false
	
	local thisSave = this
	this = scroll
	self.OnScrollBarPosChanged()
	this = thisSave	
end

function ChatPanel_Base:AppendMsg(szMsg, nFont, bRich, r, g, b)
	if szMsg == "" then
		return
	end
	
	local frame = self:GetCInstance()
	if not frame then
		return
	end
	local handle = frame:Lookup("Wnd_Message", "Handle_Message")
	if bRich then
		handle:AppendItemFromString(szMsg)
	else
		local szF = "font="..nFont
		if r and g and b then
			szF = szF.." r="..r.." g="..g.." b="..b
		end
		handle:AppendItemFromString("<text>text="..EncodeComponentsString(szMsg)..szF.."</text>")
	end
	if handle:GetItemCount() > handle.nBufferSize then
		handle:RemoveItemUntilNewLine()
	end	
	
    handle:FormatAllItemPos()
	self:UpdateScrollInfo(handle)
end

function ChatPanel_Base.OnDragButtonBegin()
	this.fDragX, this.fDragY = Station.GetMessagePos()
	this:GetRoot().bOnDraging = true
	this.bOnDraging = true
	this.fDragW, this.fDragH = this:GetParent():Lookup("", ""):GetSize()
end

function ChatPanel_Base.OnDragButton()
	local x, y = Station.GetMessagePos()
	local w, h = Station.GetClientSize()
	if x > w - 20 or y < 50 then
		return
	end
	
	local self = this:GetRoot():GetSelf()
	local szName = this:GetName()
	local bAdjustOther = false
	if szName == "Btn_DragTop" then
		self:Resize(this.fDragW, this.fDragH + this.fDragY - y)
		bAdjustOther = true
	elseif szName == "Btn_DragTopRight" then
		self:Resize(this.fDragW - this.fDragX + x, this.fDragH + this.fDragY - y)
		bAdjustOther = true
	elseif szName == "Btn_DragRight" then
		self:Resize(this.fDragW - this.fDragX + x, this.fDragH)
	end
	
	if bAdjustOther and self.Data.nMainGroupIndex then
		local x, y = this:GetRoot():Lookup("CheckBox_Title"):GetAbsPos()
		ChatPanel_Base_AdjustMgDragTitlePos(self.Data.nMainGroupIndex, y)
	end	
end

function ChatPanel_Base.OnDragButtonEnd()
	local x, y = Station.GetMessagePos()
	local frame = this:GetRoot()
	frame.bOnDraging = false
	local self = frame:GetSelf()
	self.OnDragButton()
	if self.Data.nMainGroupIndex then
		local handle = frame:Lookup("Wnd_Message", "Handle_Message")
		local w, h = handle:GetSize()	
		ChatPanel_Base_MgDragEnd(self.Data.nMainGroupIndex, w, h)
	end
	this.bOnDraging = false
	if not this.bMouseOver then
		local szName = this:GetName()
		if szName == "Btn_DragTop" then
			if Cursor.GetCurrentIndex() == CURSOR.TOP_BOTTOM then
				Cursor.Switch(CURSOR.NORMAL)
			end	
		elseif szName == "Btn_DragTopRight" then
			if Cursor.GetCurrentIndex() == CURSOR.RIGHTTOP_LEFTBOTTOM then
				Cursor.Switch(CURSOR.NORMAL)
			end			
		elseif szName == "Btn_DragRight" then
			if Cursor.GetCurrentIndex() == CURSOR.LEFT_RIGHT then
				Cursor.Switch(CURSOR.NORMAL)
			end
		end		
	end
end

function ChatPanel_Base:GetChatAreaSize()
	local w, h = 0, 0
	local frame = self:GetCInstance()
	if frame then
		local handle = frame:Lookup("Wnd_Message", "Handle_Message")
		w, h = handle:GetSize()
	end
	return w, h
end

function ChatPanel_Base:Resize(w, h)	
	local frame = self:GetCInstance()
	if not frame then
		return
	end
	
	local wnd = frame:Lookup("Wnd_Message")
	local checkBox = frame:Lookup("CheckBox_Title")	
	
	if w < 200 then w = 200 end
	if h < 100 then h = 100 end
	
	if self.Data.nMainGroupIndex then
		local wM = ChatPanel_Base_GetMGPanelCount() * checkBox:GetSize() + 40
		if w < wM then
			w = wM
		end
	end
	
	local handle = wnd:Lookup("", "")
	local wO, hO = handle:GetSize()
	handle:SetSize(w, h)
	handle:Lookup("Shadow_Back"):SetSize(w, h)
	local handleM = handle:Lookup("Handle_Message")
	handleM:SetSize(w, h)
	
	local scroll = wnd:Lookup("Scroll_Msg")
	scroll:SetSize(24, h - 60)
	local hScroll = scroll:Lookup("", "")
	hScroll:SetSize(16, h - 60)
	hScroll:Lookup("Image_ScrollBg"):SetSize(10, h - 60)
	
	wnd:Lookup("Btn_End"):SetRelPos(4, h - 20)
	wnd:Lookup("Btn_PageDown"):SetRelPos(0, h - 38)
	
	wnd:Lookup("Btn_DragTop"):SetSize(w - 10 ,10)
	wnd:Lookup("Btn_DragTopRight"):SetRelPos(20 + w - 10, 0)
	wnd:Lookup("Btn_DragRight"):SetRelPos(20 + w - 10, 10)
	wnd:Lookup("Btn_DragRight"):SetSize(10, h -10)
	
	wnd:SetSize(w + 25, h)
	local x, y = frame:GetAbsPos()
	frame:SetRelPos(x, y + hO - h)
	x, y = wnd:GetRelPos()
	frame:SetSize(x + w + 25, y + h)
	
	x, y = checkBox:GetRelPos()
	checkBox:SetRelPos(x, 0)
	self:UpdateCustomModeWindow()
	
	handleM:FormatAllItemPos()
	self:UpdateScrollInfo(handleM)
	
	if not self.Data.size then
		self.Data.size = {}
	end
	self.Data.size.w = w
	self.Data.size.h = h
end

function ChatPanel_Base.OnMouseHover()
	local frame = this:GetRoot()
	frame:Lookup("CheckBox_Title"):Show()
	frame:GetSelf():UpdateCustomModeWindow()
	frame:Lookup("Wnd_Message"):SetSizeWithAllChild(0)
	if frame:GetSelf().Data.nMainGroupIndex then
		ChatPanel_Base_AjustMgTitleShow(true)
	end
	return 0
end

function ChatPanel_Base.OnMouseLeave()
	this:GetRoot().bLeaving = true
	
	local szName = this:GetName()
	if szName == "Btn_DragTop" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.TOP_BOTTOM then
			Cursor.Switch(CURSOR.NORMAL)
		end
		this.bMouseOver = false
	elseif szName == "Btn_DragTopRight" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.RIGHTTOP_LEFTBOTTOM then
			Cursor.Switch(CURSOR.NORMAL)
		end
		this.bMouseOver = false
	elseif szName == "Btn_DragRight" then
		if not this.bOnDraging and Cursor.GetCurrentIndex() == CURSOR.LEFT_RIGHT then
			Cursor.Switch(CURSOR.NORMAL)
		end
		this.bMouseOver = false
	end
	
	return 0
end

function ChatPanel_Base.OnMouseEnter()
	this:GetRoot().bLeaving = false
	this:GetRoot():BringToTop()
	
	local szName = this:GetName()
	if szName == "Btn_DragTop" then
		if Cursor.GetCurrentIndex() == CURSOR.NORMAL then
			Cursor.Switch(CURSOR.TOP_BOTTOM)
		end
		this.bMouseOver = true
	elseif szName == "Btn_DragTopRight" then
		if Cursor.GetCurrentIndex() == CURSOR.NORMAL then
			Cursor.Switch(CURSOR.RIGHTTOP_LEFTBOTTOM)
		end
		this.bMouseOver = true
	elseif szName == "Btn_DragRight" then
		if Cursor.GetCurrentIndex() == CURSOR.NORMAL then
			Cursor.Switch(CURSOR.LEFT_RIGHT)
		end
		this.bMouseOver = true
	end
	return 0
end

function ChatPanel_Base.OnFrameBreathe()
	if g_ChatPanel_OpenPopupMenu then
		g_ChatPanel_OpenPopupMenu = IsPopupMenuOpened()
		if g_ChatPanel_OpenPopupMenu then
			return
		end 
	end
	
	if this.bLeaving and not this.bOnDraging and not this.bDragingTitle then
    	local self = this:GetSelf()
		if not (_g_ChatPanel_On_Draging and self.Data.nMainGroupIndex) then
      	local xC, yC = Cursor.GetPos()
      	local x, y = this:GetAbsPos()
      	local w, h = this:GetSize()
			if self.Data.nMainGroupIndex then
				local wT = this:Lookup("CheckBox_Title"):GetSize()
				wT = 23 + (wT + 2) * ChatPanel_Base_GetMGPanelCount()
				if w < wT then
					w = wT
				end
			end
			if xC < x or xC > x + w or yC < y or yC > y + h then
				--this:Lookup("CheckBox_Title"):Hide()
				self:UpdateCustomModeWindow()
				this:Lookup("Wnd_Message"):SetSizeWithAllChild(1)
				if self.Data.nMainGroupIndex then
					ChatPanel_Base_AjustMgTitleShow(false)
					FireEvent("EDIT_BOX_ON_FOCUS")
				end
				this.bLeaving = false
			end
		end
	end
end

function ChatPanel_Base.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_TitleName" then
		local frame = this:GetRoot()
		local nMainIndex = frame:GetSelf().Data.nMainGroupIndex
		if nMainIndex then
			if not frame:Lookup("Wnd_Message"):IsVisible() then
				PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
			end
			ChatPanel_Base_SelMgTitle(nMainIndex)
		else
			frame:Lookup("CheckBox_Title"):Check(1)
		end
		return true
	else 
		OnItemLinkDown(this)
	end
end

function ChatPanel_Base:AddMonitorMsg(szMsg)
	for k, v in pairs(self.Data.msg) do
		if v == szMsg then
			return
		end
	end
	table.insert(self.Data.msg, szMsg)
	RegisterMsgMonitor(self.Monitor, {szMsg})
	
	self.Data.tOffMsg[szMsg] = false
end

function ChatPanel_Base:RemoveMonitorMsg(szMsg)
	for k, v in pairs(self.Data.msg) do
		if v == szMsg then
			table.remove(self.Data.msg, k)
			UnRegisterMsgMonitor(self.Monitor, {szMsg})	
			
			self.Data.tOffMsg[szMsg] = true
			
			return
		end
	end
end

function ChatPanel_Base:IsMonitorMsg(szMsg)
	for k, v in pairs(self.Data.msg) do
		if v == szMsg then
			return true
		end
	end
	return false
end

function ChatPanel_Base:Lock(bLock)
	local frame = self:GetCInstance()
	if frame then
		frame.bLocked = bLock
		self.Data.bLocked = bLock
		local wnd = frame:Lookup("Wnd_Message")
		if bLock then
			wnd:Lookup("Btn_DragTop"):Hide()
			wnd:Lookup("Btn_DragTopRight"):Hide()
			wnd:Lookup("Btn_DragRight"):Hide()
		else
			wnd:Lookup("Btn_DragTop"):Show()
			wnd:Lookup("Btn_DragTopRight"):Show()
			wnd:Lookup("Btn_DragRight"):Show()
		end
		self:UpdateCustomModeWindow()
	end
end

function ChatPanel_Base.OnItemRButtonDown()
	local szName = this:GetName()
	if szName == "Handle_TitleName" then
		local frame = this:GetRoot()
		local szRoot = frame:GetName()
		local self = frame:GetSelf()
		local OnMonitorChanged = function(UserData, bCkeck)
			if not UserData then return end
			local t = GetGlobal(szRoot)
			if t then
				if bCkeck then
					t:AddMonitorMsg(UserData)
				else
					t:RemoveMonitorMsg(UserData)
				end
				FireUIEvent("CHAT_PANEL_INFO_UPDATE", "MSG_CHANGED", UserData, bCkeck)
			end
		end
		
		local OnLockWnd = function(UserData, bCheck)
			local t = GetGlobal(szRoot)
			if t then
				if t.Data.nMainGroupIndex then
					ChatPanel_Base_LockMgSizeAndPos(bCheck)
				else
					t:Lock(bCheck)
				end
			end
		end
		
		local OnNewWnd = function()
			GetUserInput(g_tStrings.CHAT_INPUT_NAME, UserNewChatPanel, nil, nil, nil, nil, 9)
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end
		
		local OnRenameWnd = function()
			local RenameChatPanel = function(szName)
				if szName and szName ~= "" then
					local t = GetGlobal(szRoot)
					if t then
						local frame = t:GetCInstance()
						if frame then
							frame:Lookup("CheckBox_Title", "Text_TitleName"):SetText(szName)
						end
					end					
				end
				FireEvent("CHAT_PANEL_INFO_UPDATE")
			end
			GetUserInput(g_tStrings.CHAT_INPUT_NAME, RenameChatPanel, nil, nil, nil, nil, 9)
		end
		
		local OnChangeColor = function(UserData, r, g, b)
			SetMsgFontColor(UserData, r, g, b)
			EditBox_OnMsgColorChanged()
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end
		
		local OnCloseWnd = function()
			Wnd.CloseWindow(szRoot)
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end
	
		local menu = {fnAction = OnMonitorChanged, fnChangeColor = OnChangeColor}
		if self.Data.nMainGroupIndex then 
			if self.Data.nMainGroupIndex == 1 then
				table.insert(menu, {szOption = g_tStrings.WINDOW_LOCK, bCheck = true, bChecked = frame.bLocked, fnAction = OnLockWnd})
				table.insert(menu, {szOption = g_tStrings.WINDOW_NEW, fnAction = OnNewWnd})
			else
				table.insert(menu, {szOption = g_tStrings.WINDOW_RENAME, fnAction = OnRenameWnd})
				table.insert(menu, {szOption = g_tStrings.WINDOW_CLOSE, fnAction = OnCloseWnd})
			end
		else
			table.insert(menu, {szOption = g_tStrings.WINDOW_LOCK, bCheck = true, bChecked = frame.bLocked, fnAction = OnLockWnd})
			table.insert(menu, {szOption = g_tStrings.WINDOW_RENAME, fnAction = OnRenameWnd})
			table.insert(menu, {szOption = g_tStrings.WINDOW_CLOSE, fnAction = OnCloseWnd})
		end
		
		local szCFName, szCFFile, nCFSize = Font.GetFont(Font.GetChatFontID())
		
		local OnSelFont = function(UserData, bCheck)
			local szName, szFile, nSize = Font.GetFont(Font.GetChatFontID())
			ChatPanel_Base_SetChatFont(UserData.szName, UserData.szFile, nSize)
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end

		local OnSelFontSize = function(UserData, bCheck)
			local szName, szFile, nSize = Font.GetFont(Font.GetChatFontID())
			ChatPanel_Base_SetChatFont(szName, szFile, UserData)
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end
		
		local OnChangeBgColor = function(UserData, r, g, b)
			ChatPanel_Base_OnSetBgInfo(nil, r, g, b, nil, true, nil, true)
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end
		
		local OnSelBgColor = function(UserData, bCheck)
			ChatPanel_Base_OnSetBgInfo(bCheck,nil, nil, nil, nil, nil, true, true)
			FireEvent("CHAT_PANEL_INFO_UPDATE")
		end
		
		local OnSelBgAlpha = function(UserData)
			local fnAction = function(f)
				ChatPanel_Base_OnSetBgInfo(nil, nil, nil, nil, (1 - f) * 255, true, true, nil)
				FireEvent("CHAT_PANEL_INFO_UPDATE")
			end
			local x, y = Cursor.GetPos()
			GetUserPercentage(fnAction, nil, 1 - UserData / 255, g_tStrings.WINDOW_ADJUST_BG_ALPHA, {x, y, x + 1, y + 1})
		end
		
		local tFontMenu = {szOption = g_tStrings.FONT}
		for _, tFontPath in ipairs(tFontPathList) do
			
			local tFontItem = 
			{
				szOption = tFontPath.szName,
				bMCheck = true, 
				bChecked = (szCFName == tFontPath.szName), 
				fnAction = OnSelFont, 
				UserData = tFontPath
			}
			table.insert(tFontMenu, tFontItem)
		end
		
		table.insert(menu, tFontMenu)
			
		table.insert(menu, {szOption = g_tStrings.FONT_SIZE, 
				{szOption = "10"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 10), fnAction = OnSelFontSize, UserData = 10 },
				{szOption = "12"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 12), fnAction = OnSelFontSize, UserData = 12 },
				{szOption = "14"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 14), fnAction = OnSelFontSize, UserData = 14 },
				{szOption = "16"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 16), fnAction = OnSelFontSize, UserData = 16 },
				{szOption = "18"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 18), fnAction = OnSelFontSize, UserData = 18 },
				{szOption = "20"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 20), fnAction = OnSelFontSize, UserData = 20 },
				{szOption = "22"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 22), fnAction = OnSelFontSize, UserData = 22 },
				{szOption = "24"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 24), fnAction = OnSelFontSize, UserData = 24 },
				{szOption = "26"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 26), fnAction = OnSelFontSize, UserData = 26 },
				{szOption = "28"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 28), fnAction = OnSelFontSize, UserData = 28 },
				{szOption = "30"..g_tStrings.FONT_SIZE_WHAT, bMCheck = true, bChecked = (nCFSize	== 30), fnAction = OnSelFontSize, UserData = 30 },
			})
		
		local sBg = frame:Lookup("Wnd_Message", "Shadow_Back")	
		table.insert(menu, {szOption = g_tStrings.BACK_COLOR, bCheck = true, bChecked = sBg:IsVisible(), fnAction = OnSelBgColor, bColorTable = true, bNotChangeSelfColor = true, fnChangeColor = OnChangeBgColor})
		table.insert(menu, {szOption = g_tStrings.WINDOW_ADJUST_BG_ALPHA1, fnAction = OnSelBgAlpha, UserData = sBg:GetAlpha()})
				
		table.insert(menu, {bDevide = true})
		table.insert(menu, {szOption = g_tStrings.CHANNE, 
				{szOption = g_tStrings.tChannelName.MSG_NORMAL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_NORMAL"), UserData = "MSG_NORMAL", bColorTable = true, rgb = GetMsgFontColor("MSG_NORMAL", true)},
				{szOption = g_tStrings.tChannelName.MSG_PARTY, bCheck = true, bChecked = self:IsMonitorMsg("MSG_PARTY"), UserData = "MSG_PARTY", bColorTable = true, rgb = GetMsgFontColor("MSG_PARTY", true)},
				{szOption = g_tStrings.tChannelName.MSG_MAP, bCheck = true, bChecked = self:IsMonitorMsg("MSG_MAP"), UserData = "MSG_MAP", bColorTable = true, rgb = GetMsgFontColor("MSG_MAP", true)},
				{szOption = g_tStrings.tChannelName.MSG_BATTLE_FILED, bCheck = true, bChecked = self:IsMonitorMsg("MSG_BATTLE_FILED"), UserData = "MSG_BATTLE_FILED", bColorTable = true, rgb = GetMsgFontColor("MSG_BATTLE_FILED", true)},
				{szOption = g_tStrings.tChannelName.MSG_GUILD, bCheck = true, bChecked = self:IsMonitorMsg("MSG_GUILD"), UserData = "MSG_GUILD", bColorTable = true, rgb = GetMsgFontColor("MSG_GUILD", true)},
				
				{szOption = g_tStrings.tChannelName.MSG_SCHOOL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SCHOOL"), UserData = "MSG_SCHOOL", bColorTable = true, rgb = GetMsgFontColor("MSG_SCHOOL", true)},
				
				{szOption = g_tStrings.tChannelName.MSG_WORLD, bCheck = true, bChecked = self:IsMonitorMsg("MSG_WORLD"), UserData = "MSG_WORLD", bColorTable = true, rgb = GetMsgFontColor("MSG_WORLD", true)},
				{szOption = g_tStrings.tChannelName.MSG_TEAM, bCheck = true, bChecked = self:IsMonitorMsg("MSG_TEAM"), UserData = "MSG_TEAM", bColorTable = true, rgb = GetMsgFontColor("MSG_TEAM", true)},
				{szOption = g_tStrings.tChannelName.MSG_CAMP, bCheck = true, bChecked = self:IsMonitorMsg("MSG_CAMP"), UserData = "MSG_CAMP", bColorTable = true, rgb = GetMsgFontColor("MSG_CAMP", true)},
				
				{szOption = g_tStrings.tChannelName.MSG_MENTOR, bCheck = true, bChecked = self:IsMonitorMsg("MSG_MENTOR"), UserData = "MSG_MENTOR", bColorTable = true, rgb = GetMsgFontColor("MSG_MENTOR", true)},
				{szOption = g_tStrings.tChannelName.MSG_SEEK_MENTOR, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SEEK_MENTOR"), UserData = "MSG_SEEK_MENTOR", bColorTable = true, rgb = GetMsgFontColor("MSG_SEEK_MENTOR", true)},
				{szOption = g_tStrings.tChannelName.MSG_FRIEND, bCheck = true, bChecked = self:IsMonitorMsg("MSG_FRIEND"), UserData = "MSG_FRIEND", bColorTable = true, rgb = GetMsgFontColor("MSG_FRIEND", true)},
				
				{szOption = g_tStrings.tChannelName.MSG_OFFICIAL, bCheck = true, bChecked = false, bDisable = true},
				{szOption = g_tStrings.tChannelName.MSG_GROUP, bCheck = true, bChecked = self:IsMonitorMsg("MSG_GROUP"), UserData = "MSG_GROUP", bColorTable = true, rgb = GetMsgFontColor("MSG_GROUP", true)},
				{szOption = g_tStrings.tChannelName.MSG_WHISPER, bCheck = true, bChecked = self:IsMonitorMsg("MSG_WHISPER"), UserData = "MSG_WHISPER", bColorTable = true, rgb = GetMsgFontColor("MSG_WHISPER", true)},
				--{szOption = g_tStrings.tChannelName.MSG_FACE, bCheck = true, bChecked = self:IsMonitorMsg("MSG_FACE"), UserData = "MSG_FACE", bColorTable = true, rgb = GetMsgFontColor("MSG_FACE", true)},
                
			})
		table.insert(menu, {szOption = g_tStrings.EARN, 
				{szOption = g_tStrings.tChannelName.MSG_MONEY, bCheck = true, bChecked = self:IsMonitorMsg("MSG_MONEY"), UserData = "MSG_MONEY", bColorTable = true, rgb = GetMsgFontColor("MSG_MONEY", true)},
				{szOption = g_tStrings.tChannelName.MSG_EXP, bCheck = true, bChecked = self:IsMonitorMsg("MSG_EXP"), UserData = "MSG_EXP", bColorTable = true, rgb = GetMsgFontColor("MSG_EXP", true)},
				{szOption = g_tStrings.tChannelName.MSG_ITEM, bCheck = true, bChecked = self:IsMonitorMsg("MSG_ITEM"), UserData = "MSG_ITEM", bColorTable = true, rgb = GetMsgFontColor("MSG_ITEM", true)},
				{szOption = g_tStrings.tChannelName.MSG_REPUTATION, bCheck = true, bChecked = self:IsMonitorMsg("MSG_REPUTATION"), UserData = "MSG_REPUTATION", bColorTable = true, rgb = GetMsgFontColor("MSG_REPUTATION", true)},
				{szOption = g_tStrings.tChannelName.MSG_CONTRIBUTE, bCheck = true, bChecked = self:IsMonitorMsg("MSG_CONTRIBUTE"), UserData = "MSG_CONTRIBUTE", bColorTable = true, rgb = GetMsgFontColor("MSG_CONTRIBUTE", true)},
				{szOption = g_tStrings.tChannelName.MSG_ATTRACTION, bCheck = true, bChecked = self:IsMonitorMsg("MSG_ATTRACTION"), UserData = "MSG_ATTRACTION", bColorTable = true, rgb = GetMsgFontColor("MSG_ATTRACTION", true)},
				{szOption = g_tStrings.tChannelName.MSG_PRESTIGE, bCheck = true, bChecked = self:IsMonitorMsg("MSG_PRESTIGE"), UserData = "MSG_PRESTIGE", bColorTable = true, rgb = GetMsgFontColor("MSG_PRESTIGE", true)},
				{szOption = g_tStrings.tChannelName.MSG_TRAIN, bCheck = true, bChecked = self:IsMonitorMsg("MSG_TRAIN"), UserData = "MSG_TRAIN", bColorTable = true, rgb = GetMsgFontColor("MSG_TRAIN", true)},							
				{szOption = g_tStrings.tChannelName.MSG_DESGNATION, bCheck = true, bChecked = self:IsMonitorMsg("MSG_DESGNATION"), UserData = "MSG_DESGNATION", bColorTable = true, rgb = GetMsgFontColor("MSG_DESGNATION", true)},
				{szOption = g_tStrings.tChannelName.MSG_ACHIEVEMENT, bCheck = true, bChecked = self:IsMonitorMsg("MSG_ACHIEVEMENT"), UserData = "MSG_ACHIEVEMENT", bColorTable = true, rgb = GetMsgFontColor("MSG_ACHIEVEMENT", true)},			
				{szOption = g_tStrings.tChannelName.MSG_MENTOR_VALUE, bCheck = true, bChecked = self:IsMonitorMsg("MSG_MENTOR_VALUE"), UserData = "MSG_MENTOR_VALUE", bColorTable = true, rgb = GetMsgFontColor("MSG_MENTOR_VALUE", true)},
				{szOption = g_tStrings.tChannelName.MSG_DEVELOPMENT_POINT, bCheck = true, bChecked = self:IsMonitorMsg("MSG_DEVELOPMENT_POINT"), UserData = "MSG_DEVELOPMENT_POINT", bColorTable = true, rgb = GetMsgFontColor("MSG_DEVELOPMENT_POINT", true)},
                {szOption = g_tStrings.tChannelName.MSG_THEW_STAMINA, bCheck = true, bChecked = self:IsMonitorMsg("MSG_THEW_STAMINA"), UserData = "MSG_THEW_STAMINA", bColorTable = true, rgb = GetMsgFontColor("MSG_THEW_STAMINA", true)},
			})
		table.insert(menu, {szOption = g_tStrings.FIGHT_MSG, 
				{szOption = g_tStrings.STR_NAME_OWN, 	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_SELF_SKILL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_SELF_SKILL"), UserData = "MSG_SKILL_SELF_SKILL", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_SELF_SKILL", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_SELF_BUFF, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_SELF_BUFF"), UserData = "MSG_SKILL_SELF_BUFF", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_SELF_BUFF", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_SELF_DEBUFF, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_SELF_DEBUFF"), UserData = "MSG_SKILL_SELF_DEBUFF", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_SELF_DEBUFF", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_SELF_MISS, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_SELF_MISS"), UserData = "MSG_SKILL_SELF_MISS", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_SELF_MISS", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_SELF_FAILED, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_SELF_FAILED"), UserData = "MSG_SKILL_SELF_FAILED", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_SELF_FAILED", true)},	
				},			
				
				{szOption = g_tStrings.TEAMMATE, 
						{szOption = g_tStrings.tChannelName.MSG_SKILL_PARTY_SKILL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_PARTY_SKILL"), UserData = "MSG_SKILL_PARTY_SKILL", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_PARTY_SKILL", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_PARTY_BUFF, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_PARTY_BUFF"), UserData = "MSG_SKILL_PARTY_BUFF", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_PARTY_BUFF", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_PARTY_DEBUFF, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_PARTY_DEBUFF"), UserData = "MSG_SKILL_PARTY_DEBUFF", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_PARTY_DEBUFF", true)},	
						{szOption = g_tStrings.tChannelName.MSG_SKILL_PARTY_MISS, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_PARTY_MISS"), UserData = "MSG_SKILL_PARTY_MISS", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_PARTY_MISS", true)},	
				},
				
				{szOption = g_tStrings.OTHER_PLAYER,
				        {szOption = g_tStrings.tChannelName.MSG_SKILL_OTHERS_SKILL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_OTHERS_SKILL"), UserData = "MSG_SKILL_OTHERS_SKILL", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_OTHERS_SKILL", true)},
				        {szOption = g_tStrings.tChannelName.MSG_SKILL_OTHERS_MISS, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_OTHERS_MISS"), UserData = "MSG_SKILL_OTHERS_MISS", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_OTHERS_MISS", true)},				
				},
				
				{szOption = "NPC",
				        {szOption = g_tStrings.tChannelName.MSG_SKILL_NPC_SKILL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_NPC_SKILL"), UserData = "MSG_SKILL_NPC_SKILL", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_NPC_SKILL", true)},
				        {szOption = g_tStrings.tChannelName.MSG_SKILL_NPC_MISS, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SKILL_NPC_MISS"), UserData = "MSG_SKILL_NPC_MISS", bColorTable = true, rgb = GetMsgFontColor("MSG_SKILL_NPC_MISS", true)},				
				},
				
				{szOption = g_tStrings.OTHER,
				        {szOption = g_tStrings.tChannelName.MSG_OTHER_DEATH, bCheck = true, bChecked = self:IsMonitorMsg("MSG_OTHER_DEATH"), UserData = "MSG_OTHER_DEATH", bColorTable = true, rgb = GetMsgFontColor("MSG_OTHER_DEATH", true)},
				        {szOption = g_tStrings.tChannelName.MSG_OTHER_ENCHANT, bCheck = true, bChecked = self:IsMonitorMsg("MSG_OTHER_ENCHANT"), UserData = "MSG_OTHER_ENCHANT", bColorTable = true, rgb = GetMsgFontColor("MSG_OTHER_ENCHANT", true)},				
				        {szOption = g_tStrings.tChannelName.MSG_OTHER_SCENE, bCheck = true, bChecked = self:IsMonitorMsg("MSG_OTHER_SCENE"), UserData = "MSG_OTHER_SCENE", bColorTable = true, rgb = GetMsgFontColor("MSG_OTHER_SCENE", true)},
				},						
			})
		table.insert(menu, {szOption = g_tStrings.ENVIROMENT, 
				{szOption = g_tStrings.tChannelName.MSG_NPC_NEARBY, bCheck = true, bChecked = self:IsMonitorMsg("MSG_NPC_NEARBY"), UserData = "MSG_NPC_NEARBY", bColorTable = true, rgb = GetMsgFontColor("MSG_NPC_NEARBY", true)},
				{szOption = g_tStrings.tChannelName.MSG_NPC_YELL, bCheck = true, bChecked = self:IsMonitorMsg("MSG_NPC_YELL"), UserData = "MSG_NPC_YELL", bColorTable = true, rgb = GetMsgFontColor("MSG_NPC_YELL", true)},
				{szOption = g_tStrings.tChannelName.MSG_NPC_PARTY, bCheck = true, bChecked = self:IsMonitorMsg("MSG_NPC_PARTY"), UserData = "MSG_NPC_PARTY", bColorTable = true, rgb = GetMsgFontColor("MSG_NPC_PARTY", true)},
				{szOption = g_tStrings.tChannelName.MSG_NPC_WHISPER, bCheck = true, bChecked = self:IsMonitorMsg("MSG_NPC_WHISPER"), UserData = "MSG_NPC_WHISPER", bColorTable = true, rgb = GetMsgFontColor("MSG_NPC_WHISPER", true)},
				{szOption = g_tStrings.tChannelName.MSG_NPC_FACE, bCheck = true, bChecked = false, bDisable = true},
			})
		if self.Data.nMainGroupIndex and self.Data.nMainGroupIndex == 1 then 
			table.insert(menu, {szOption = g_tStrings.tChannelName.MSG_SYS, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SYS"), UserData = "MSG_SYS", bColorTable = true, rgb = GetMsgFontColor("MSG_SYS", true), bDisable = true})
		else
			table.insert(menu, {szOption = g_tStrings.tChannelName.MSG_SYS, bCheck = true, bChecked = self:IsMonitorMsg("MSG_SYS"), UserData = "MSG_SYS", bColorTable = true, rgb = GetMsgFontColor("MSG_SYS", true)})
		end
		
		PopupMenu(menu)
		g_ChatPanel_OpenPopupMenu = true
	elseif this:GetName() == "namelink" then
		local szText = this:GetText()
		local hSelect = this
		if string.sub(szText, -1, -1) == "]" then
			szText = string.sub(szText, 2, -2)
		else
			szText = string.sub(szText, 2, -3)
		end
		
		local player = GetClientPlayer()
		
	
		function ReportPlayer()
			local szContent = GetChatContent(hSelect)
			GMPanel_ReportPlayer(szText, szContent)
		end
		
		local menu = 
		{
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szText) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szText) AddContactPeople(szText) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szText) AddContactPeople(szText) end},
		    {szOption = g_tStrings.STR_ADD_BLACKLIST, fnAction = function() GetClientPlayer().AddBlackList(szText) AddContactPeople(szText) if not GetClientPlayer().IsAchievementAcquired(981) then RemoteCallToServer("OnClientAddAchievement", "BlackList_First_Add") end end},
		    {szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = player.dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szText) AddContactPeople(szText) end},
		    {szOption = g_tStrings.MENTOR_GET_APPRENTICE, fnAction = function() RemoteCallToServer("OnApplyApprentice", szText) end},
		    {szOption = g_tStrings.MENTOR_GET_MASTER, fnAction = function() RemoteCallToServer("OnApplyMentor", szText) end},
--		    {szOption = g_tStrings.MENTOR_GET_DIRECT_APPRENTICE, fnAction = function() RemoteCallToServer("OnApplyDirectApprentice", szText) end},
		    {szOption = g_tStrings.MENTOR_GET_DIRECT_MASTER, fnAction = function() RemoteCallToServer("OnApplyDirectMentor", szText) end},
			{szOption = g_tStrings.STR_ARENA_INVITE_TARGET, 
				{szOption = g_tStrings.tCorpsType[ARENA_TYPE.ARENA_2V2], fnDisable = function() return (not Arena_IsCorpsCreate(ARENA_TYPE.ARENA_2V2)) end, fnAction = function() InvitationJoinCorps(szText, GetCorpsID(ARENA_TYPE.ARENA_2V2, GetClientPlayer().dwID)) end},
				{szOption = g_tStrings.tCorpsType[ARENA_TYPE.ARENA_3V3], fnDisable = function() return (not Arena_IsCorpsCreate(ARENA_TYPE.ARENA_3V3)) end, fnAction = function() InvitationJoinCorps(szText, GetCorpsID(ARENA_TYPE.ARENA_3V3, GetClientPlayer().dwID)) end},
				{szOption = g_tStrings.tCorpsType[ARENA_TYPE.ARENA_5V5], fnDisable = function() return (not Arena_IsCorpsCreate(ARENA_TYPE.ARENA_5V5)) end, fnAction = function() InvitationJoinCorps(szText, GetCorpsID(ARENA_TYPE.ARENA_5V5, GetClientPlayer().dwID)) end},
			},
		    {bDevide = true},
		    {szOption = g_tStrings.REPORT_PLAYER, fnAction = ReportPlayer},
		}
		local dwReportID = BattleField_IsCanReportPlayer(szText)
		if dwReportID then
			table.insert(menu, {szOption = g_tStrings.STR_REPORT_GUAJI, fnAction = function() BattleField_ReprotRobot(dwReportID) end})
		end
		PopupMenu(menu)
	end
end

function ChatPanel_Base.OnFrameDrag()
	if this:GetName() == "ChatPanel1" then
		_g_ChatPanel_On_Draging = true
		return 0
	end

	if not this.bDragingTitle then
		this.bDragingTitle = true
		local self = this:GetSelf()
		if self.Data.nMainGroupIndex then
			ChatPanel_Base_AddMgIndexAfter(self.Data.nMainGroupIndex, -1)
			self.Data.nMainGroupIndex = nil
			
			local checkBox = this:Lookup("CheckBox_Title")
			local x, y = checkBox:GetAbsPos()
			checkBox:SetRelPos(25, 0)
			self:UpdateCustomModeWindow()
			this:SetRelPos(x - 25, y)
			this:Lookup("Wnd_Message"):Show()
			this:Lookup("Btn_ChatSetting"):Hide()
			ChatPanel_Base_SelMgTitle(1)
			ChatPanel_Base_AjustMgTitlePos()
		end
		ChatPanel_Base_AjustMgTitleShow(true)
		_g_ChatPanel_On_Draging = true
		return 1
	end
	
	return 0
end

function ChatPanel_Base.OnFrameDragSetPosEnd()
	if this:GetName() == "ChatPanel1" then
		ChatPanel_Base_AjustMgPanelPos()
		FireEvent("CHAT_PANEL_POS_CHANGED")
	end
end

function ChatPanel_Base.OnFrameDragEnd()
	
	if this:GetName() == "ChatPanel1" then
		_g_ChatPanel_On_Draging = false
		
		this:CorrectPos()
		this:GetSelf().Data.Anchor = GetFrameAnchor(this)
		this:GetSelf():UpdateAnchor()
		return
	end

	local x, y = Station.GetMessagePos()

	this.bDragingTitle = nil
	_g_ChatPanel_On_Draging = false
	
	local self = this:GetSelf()
	local bIn, nIndex = ChatPanel_Base_PtInMgTitleIndex(x, y)
	if bIn then
		ChatPanel_Base_AddMgIndexAfter(nIndex, 1)
		self:AddToMainGroup(nIndex)
		ChatPanel_Base_SelMgTitle(self.Data.nMainGroupIndex)
	else
		ChatPanel_Base_AjustMgTitleShow(false)
	end
	
	this:CorrectPos()
	this:GetSelf().Data.Anchor = GetFrameAnchor(this)	
end

function ChatPanel_Base:AddToMainGroup(nIndex)
	local frame = self:GetCInstance()
	if not frame then
		return
	end
	self.Data.nMainGroupIndex = nIndex
	ChatPanel_Base_AjustMgTitlePos()
	if ChatPanel1 then
		local frame1 = ChatPanel1:GetCInstance()
		if frame1 then
			local x, y = frame1:GetAbsPos()
			local w, h = frame1:Lookup("Wnd_Message", "Handle_Message"):GetSize()
			self:Resize(w, h)
			frame:SetRelPos(x, y)
			if frame1.bLocked then
				self:Lock(true)
			end
		end
	end
end

----------------------------------------------------------------------------------------------
function ChatPanel_Base_GetMGPanelCount()
	local nCount = 0
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			nCount = nCount + 1
		end
	end
	return nCount
end

function ChatPanel_Base_LockMgSizeAndPos(bLock)
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			t:Lock(bLock)
		end
	end	
end

function ChatPanel_Base_PtInMgTitleIndex(x, y)
	if not ChatPanel1 then
		return false
	end
	local frame = ChatPanel1:GetCInstance()
	if not frame then
		return false
	end
	
	local nCount = 0
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			nCount = nCount + 1
		end
	end
	
	local xF, yF = frame:GetAbsPos()
	local wF, hF = frame:GetSize()
	local checkBox = frame:Lookup("CheckBox_Title")
	local wC, hC = checkBox:GetSize()
	local xC, yC = frame:GetAbsPos()
	
	local w = (wC + 2) * (nCount + 1)
	if wF > w then
		w = wF
	end
	
	if x < xC or x > xC + w or y < yC or y > yC + hC then
		return false
	end
	
	local nIndex = nCount + 1
	for i = 1, nCount, 1 do
		if x - xC < (i - 1) * (wC + 2) + (wC + 2) / 2 then
			nIndex = i
			break
		end
	end
	if nIndex == 1 then
		nIndex = 2
	end
	return true, nIndex
end

function ChatPanel_Base_AddMgIndexAfter(nIndex, nDelta)
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex and t.Data.nMainGroupIndex >= nIndex then
			t.Data.nMainGroupIndex = t.Data.nMainGroupIndex + nDelta
		end
	end
end

function ChatPanel_Base_AdjustMgDragTitlePos(nIndex, absY)
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex and t.Data.nMainGroupIndex ~= nIndex then
			local frame = t:GetCInstance()
			if frame then
				local checkBox = frame:Lookup("CheckBox_Title")
				local x, y = checkBox:GetAbsPos()
				local deltaY = absY - y
				x, y = checkBox:GetRelPos()
				checkBox:SetRelPos(x, y + deltaY)
			end
		end
	end
end

function ChatPanel_Base_MgDragEnd(nIndex, w, h)
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex and t.Data.nMainGroupIndex ~= nIndex then
			t:Resize(w, h)
		end
	end	
end

function ChatPanel_Base_AjustMgTitlePos()
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			local frame = t:GetCInstance()
			if frame then
				local checkBox = frame:Lookup("CheckBox_Title")
				if checkBox then
					local w, h = checkBox:GetSize()
					local x = 23 + (t.Data.nMainGroupIndex - 1) * (w + 2)
					checkBox:SetRelPos(x, 0)
					t:UpdateCustomModeWindow()
				end
			end
		end
	end		
end

function ChatPanel_Base_AjustMgTitleShow(bShow)
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			local frame = t:GetCInstance()
			if frame then
				local checkBox = frame:Lookup("CheckBox_Title")
				local wnd = frame:Lookup("Wnd_Message")
				if bShow then
					--checkBox:Show()
					wnd:SetSizeWithAllChild(0)
				else
					--checkBox:Hide()
					wnd:SetSizeWithAllChild(1)
				end
				t:UpdateCustomModeWindow()
			end
		end
	end			
end

function ChatPanel_Base_SelMgTitle(nIndex)
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			local frame = t:GetCInstance()
			local check = frame:Lookup("CheckBox_Title")
			local wnd = frame:Lookup("Wnd_Message")
			local btn = frame:Lookup("Btn_ChatSetting")
			if check and wnd then
				if t.Data.nMainGroupIndex == nIndex then
					check:Check(1)
					wnd:Show()
					btn:Show()
				else
					check:Check(0)
					wnd:Hide()
					btn:Hide()
				end
			end
		end
	end
end

function ChatPanel_Base_AjustMgPanelPos()
	if ChatPanel1 then
		local frame = ChatPanel1:GetCInstance()
		if frame then
			local x, y = frame:GetAbsPos()
			for i = 0, MAX_CHAT_PANEL_COUNT, 1 do
				local t = GetGlobal("ChatPanel"..i)
				if t and t.Data.nMainGroupIndex then
					frame = t:GetCInstance()
					if frame then
						frame:SetRelPos(x, y)
					end
				end				
			end
		end
	end
end

function ChatPanel_Base_OnChatFontChanged()
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t then
			local frame = t:GetCInstance()
			if frame then
				local handle = frame:Lookup("Wnd_Message", "Handle_Message")
				if handle then
					handle:FormatAllItemPos()
					t:UpdateScrollInfo(handle)
				end
			end
		end
	end
end

function ChatPanel_Base_GetMgFrame()
	if ChatPanel1 then
		return ChatPanel1:GetCInstance()
	end
	return nil
end

function ChatPanel_Base_OnSetBgInfo(bBg, r, g, b, a, bIgnorVisible, bIgnoreColor, bIgnoreAlpha)
	if not g_tChatPanelData.tBgColor then
		g_tChatPanelData.tBgColor = {}
	end
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t then
			local frame = t:GetCInstance()
			if frame then
				local sBg = frame:Lookup("Wnd_Message", "Shadow_Back")
				if sBg then
					if not bIgnorVisible then
						if bBg then
							sBg:Show()
						else
							sBg:Hide()
						end
						g_tChatPanelData.bBgShow = bBg
					end
					
					if not bIgnoreColor then
						if IsChatPanelInit() then
							FireDataAnalysisEvent("CHAT_CHANNEL_BACKGROUND_COLOR", {g_tChatPanelData.tBgColor, {r=r,g=g,b=b}})
						end
						
						sBg:SetColorRGB(r, g, b)
						g_tChatPanelData.tBgColor.r = r
						g_tChatPanelData.tBgColor.g = g
						g_tChatPanelData.tBgColor.b = b
					end
					
					if not bIgnoreAlpha then
						sBg:SetAlpha(a)
						g_tChatPanelData.tBgColor.a = a
					end
				end
			end
		end
	end
end

function ChatPanel_Base_GetFreeMGIndex()
	local nMainGroupIndex = 1
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t and t.Data.nMainGroupIndex then
			if nMainGroupIndex then
				if t.Data.nMainGroupIndex >= nMainGroupIndex then
					nMainGroupIndex = t.Data.nMainGroupIndex + 1
				end
			else
				nMainGroupIndex = t.Data.nMainGroupIndex + 1
			end
		end
	end	
	return nMainGroupIndex
end

function ChatPanel_Base_SetChatFont(szName, szFile, nSize)
	if IsChatPanelInit() then
		FireDataAnalysisEvent("CHAT_CHANNEL_FONT", {{szName=g_tChatPanelData.szFontName, nSize=g_tChatPanelData.nFontSize}, {szName=szName, nSize=nSize}})
	end
	
	g_tChatPanelData.szFontName = szName
	g_tChatPanelData.szFontFile = szFile
	g_tChatPanelData.nFontSize = nSize 
	Font.SetFont(Font.GetChatFontID(), szName, szFile, nSize)
	ChatPanel_Base_OnChatFontChanged()
end

function ChatPanel_Base_ChatReName(hChat, szName)
	if szName and szName ~= "" then
		local hFrame = hChat:GetCInstance()
		if hFrame then
			hFrame:Lookup("CheckBox_Title", "Text_TitleName"):SetText(szName)
			hChat.Data.szName = szName
		end
	end			
end

function ChatPanel_Base_OnChatMonitorChanged(hChat, szMsg, bCheck)
	if bCheck then
		hChat:AddMonitorMsg(szMsg)
	else
		hChat:RemoveMonitorMsg(szMsg)
	end
end

function ChatPanel_Base_CloseChatWindow(hChat)
	local hFrame = hChat:GetCInstance()
	Wnd.CloseWindow(hFrame)
end

function ChatPanel_Base_SetDefaultBgInfo()
	ChatPanel_Base_OnSetBgInfo(tDefaultBgInfo.bBgShow, tDefaultBgInfo.rBg, tDefaultBgInfo.gBg, tDefaultBgInfo.bBg, tDefaultBgInfo.aBg)
end

function ChatPanel_Base_SetDefaultChatFont()
	ChatPanel_Base_SetChatFont(tDefaultFontInfo[1], tDefaultFontInfo[2], tDefaultFontInfo[3])
end

function ChatPanel_Base_SetDefaultChatWindow()
	--delete all chat window but ChatPanel1
	for i = 2, MAX_CHAT_PANEL_COUNT do
		local tChat = GetGlobal("ChatPanel"..i)
		if tChat then
			ChatPanel_Base_CloseChatWindow(tChat)
		end
	end
	local tChat = GetGlobal("ChatPanel"..1)
	UnRegisterMsgMonitor(tChat.Monitor)
	tChat.Monitor = NewChatPanelMsgMonitor(tChat.Data.nIndex)
	tChat.Data.msg = clone(tDefaultMsg[g_tStrings.SYNTHESIS])
	RegisterMsgMonitor(tChat.Monitor, tChat.Data.msg)
	tChat:Resize(tDefaultSize.w, tDefaultSize.h)
	ChatPanel_SetAnchorDefault()
	
	NewChatPanel(g_tStrings.FIGHT_CHANNEL, 150, true, tDefaultMsg[g_tStrings.FIGHT_CHANNEL])
	NewChatPanel(g_tStrings.CHANNEL_CHANNEL, 150, true, tDefaultMsg[g_tStrings.CHANNEL_CHANNEL])
	NewChatPanel(g_tStrings.OTHER, 150, true, tDefaultMsg[g_tStrings.OTHER])
	NewChatPanel(g_tStrings.CHANNEL_MENTOR, 150, true, tDefaultMsg[g_tStrings.CHANNEL_MENTOR])
    NewChatPanel(g_tStrings.STR_SAY_SECRET, 150, true, tDefaultMsg[g_tStrings.STR_SAY_SECRET])
		
	ChatPanel_Base_SetChatFont(g_tChatPanelData.szFontName, g_tChatPanelData.szFontFile, g_tChatPanelData.nFontSize)
	ChatPanel_Base_OnSetBgInfo(g_tChatPanelData.bBgShow, g_tChatPanelData.tBgColor.r, g_tChatPanelData.tBgColor.g, g_tChatPanelData.tBgColor.b, g_tChatPanelData.tBgColor.a)
	ChatPanel_Base_AjustMgPanelPos()
	ChatPanel_Base_SelMgTitle(ChatPanel1.Data.nMainGroupIndex)
	
	FireEvent("CHAT_PANEL_POS_CHANGED")
end

function IsChatPanelInit()
	return bChatPanelInitFlag
end

function SetChatPanelInitFlag(bInit)
	bChatPanelInitFlag = true
end

------------------------------------------------------------------------------------------------------------
MAX_CHAT_PANEL_COUNT = 10
function NewChatPanel(szName, nBufferSize, bInMainGroup, msg, size, Anchor, tOffMsg, nMainGroupIndex, nIndex)
	if not size then
		size = tDefaultSize
	end
	
	if not nMainGroupIndex then
		if bInMainGroup then
			nMainGroupIndex = ChatPanel_Base_GetFreeMGIndex()
		end
	end
	
	if not nIndex then		
		for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
			if not GetGlobal("ChatPanel"..i) then
				nIndex = i
				break
			end
		end 
	end
	
	if not nIndex then
		return
	end
	if not tOffMsg then
		tOffMsg = {}
	end
	local t = ChatPanel_Base.new(nIndex, szName, nBufferSize, nMainGroupIndex, msg, Anchor, tOffMsg)
	SetGlobal("ChatPanel"..nIndex, t)
	Wnd.OpenWindow("ChatPanel", "ChatPanel"..nIndex)
	if size then
		t:Resize(size.w, size.h)
	end
	
	local hFrame = t:GetCInstance()
	
	if nMainGroupIndex then
		ChatPanel_Base_MgDragEnd(nMainGroupIndex, size.w, size.h)
		ChatPanel_Base_AjustMgTitlePos()
	end	
	return t
end

function UserNewChatPanel(szName)
	if not szName or szName == "" then
		return
	end
	
	local aSize = nil
	if ChatPanel1 then
		aSize = {}
		aSize.w, aSize.h = ChatPanel1:GetChatAreaSize()
	end
	
	local t = NewChatPanel(szName, 150, true, {}, aSize)
	if not t or not ChatPanel1 then
		return
	end
	local frame = ChatPanel1:GetCInstance()
	if frame then
		t:Lock(frame.bLocked)
		ChatPanel_Base_AjustMgPanelPos()
		ChatPanel_Base_SelMgTitle(t.Data.nMainGroupIndex)
		
		local fMe = t:GetCInstance()
		if fMe then
			local sBgM = frame:Lookup("Wnd_Message", "Shadow_Back")
			local sBg = fMe:Lookup("Wnd_Message", "Shadow_Back")
			if sBgM:IsVisible() then
				sBg:Show()
			else
				sBg:Hide()
			end
			local r, g, b = sBgM:GetColorRGB()
			sBg:SetColorRGB(r, g, b)
			sBg:SetAlpha(sBgM:GetAlpha())
		end
	end
	
	return t
end

function ChatPanel_SetAnchorDefault()
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t then
			if not t.Data.nMainGroupIndex then
				t:AddToMainGroup(ChatPanel_Base_GetFreeMGIndex())
			end
			t.Data.Anchor = GetChatPanelDefaultAnchor()
			t:UpdateAnchor()
		end
	end
end

function ChatPanel_GetChatPanel()
	local tChats = {}
	for i = 1, MAX_CHAT_PANEL_COUNT, 1 do
		local t = GetGlobal("ChatPanel"..i)
		if t then
			local tChannel = {}
			tChannel.hWindow = t
			tChannel.szName = t.Data.szName
			tChannel.tMsg = {}
			for k ,v in pairs(t.Data.msg) do 
				tChannel.tMsg[v] = true
			end
			table.insert(tChats, tChannel)
		end
	end
	return tChats
end

function ChatPanel_GetChatBgInfo()
	local tBgColor = clone(g_tChatPanelData.tBgColor)
	return g_tChatPanelData.bBgShow, tBgColor
end

function ChatPanel_GetMaxChatCount()
	return MAX_CHAT_PANEL_COUNT
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", ChatPanel_SetAnchorDefault)

function GetChatData(szName)
	if not g_tChatPanelData[szName] then
		g_tChatPanelData[szName] = {}
	end
	
	return g_tChatPanelData[szName]
end

function GetChatContent(hSelect)
	local hMessage = hSelect:GetParent()
	local nIndex = hSelect:GetIndex()
	local nCount = hMessage:GetItemCount()
	local szMessage = ""
	
	for i = nIndex, 0, -1 do
		local hText = hMessage:Lookup(i)
		local szText = hText:GetText()
		local nLength = szText:len()
		local szEnd = szText:sub(nLength)
		if szEnd == "\n" then
			break
		end
		if i < nIndex then
			szMessage = szText .. szMessage
		end 
	end

	for i = nIndex, nCount - 1 do
		local hItem = hMessage:Lookup(i)
		if hItem:GetType() == "Text" then
			local szText = hItem:GetText()
			local nLength = szText:len()
			local szEnd = szText:sub(nLength)
			szMessage = szMessage .. szText
			if szEnd == "\n" then
				break
			end
		end
	end
	
	nLength = #szMessage
	szMessage = szMessage:sub(0, nLength - 1)
	return szMessage
end
function InitChatPanel()
	if arg0 ~= "Role" then
		return
	end
	
	if g_tChatPanelData and g_tChatPanelData.szVersion and g_tChatPanelData.szVersion == szCurrentChatPannelVersion then
		for i = 1, MAX_CHAT_PANEL_COUNT do
			local tChat =  g_tChatPanelData["ChatPanel" .. i]
			if tChat then
				if tDefaultMsg[tChat.szName] then
					for _, v in pairs(tDefaultMsg[tChat.szName]) do
						local bSelect = false
						for _, Msg in pairs(tChat.msg) do
							if v == Msg then
								bSelect = true
							end
						end
						if not bSelect and not tChat.tOffMsg[v] then
							table.insert(tChat.msg, v)
						end
					end
				end
				local hChatPanel = NewChatPanel(tChat.szName, tChat.nBufferSize, nil, tChat.msg, tChat.size, tChat.Anchor, tChat.tOffMsg, tChat.nMainGroupIndex, tChat.nIndex)
				if hChatPanel then
					hChatPanel:Lock(tChat.bLocked)
				end
			end
		end
	else
		SetDefaultMsgFontColor()
		g_tChatPanelData = {}
		g_tChatPanelData.szVersion = szCurrentChatPannelVersion		
	end
	
	if not ChatPanel1 then
		ChatPanel_Base_SetDefaultChatFont()
		
		NewChatPanel(g_tStrings.SYNTHESIS, 200, true, tDefaultMsg[g_tStrings.SYNTHESIS])
		NewChatPanel(g_tStrings.FIGHT_CHANNEL, 150, true, tDefaultMsg[g_tStrings.FIGHT_CHANNEL])
		NewChatPanel(g_tStrings.CHANNEL_CHANNEL, 150, true, tDefaultMsg[g_tStrings.CHANNEL_CHANNEL])
		NewChatPanel(g_tStrings.OTHER, 150, true, tDefaultMsg[g_tStrings.OTHER])
		NewChatPanel(g_tStrings.CHANNEL_MENTOR, 150, true, tDefaultMsg[g_tStrings.CHANNEL_MENTOR])
        NewChatPanel(g_tStrings.STR_SAY_SECRET, 150, true, tDefaultMsg[g_tStrings.STR_SAY_SECRET])
        
		ChatPanel_Base_SetDefaultBgInfo()
	else
		ChatPanel_Base_SetChatFont(g_tChatPanelData.szFontName, g_tChatPanelData.szFontFile, g_tChatPanelData.nFontSize)
		ChatPanel_Base_OnSetBgInfo(g_tChatPanelData.bBgShow, g_tChatPanelData.tBgColor.r, g_tChatPanelData.tBgColor.g, g_tChatPanelData.tBgColor.b, g_tChatPanelData.tBgColor.a)
	end
		
	ChatPanel_Base_SelMgTitle(ChatPanel1.Data.nMainGroupIndex)

	FireEvent("CHAT_PANEL_POS_CHANGED")
	if not IsChatPanelInit() then
		SetChatPanelInitFlag(true)
		FireEvent("CHAT_PANEL_INIT")
	end
end

RegisterEvent("CUSTOM_DATA_LOADED", function() InitChatPanel() end)
