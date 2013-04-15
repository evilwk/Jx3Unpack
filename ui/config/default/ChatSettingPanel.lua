local CHATSETTING_PANEL_PATH = "UI/Config/default/ChatSettingPanel.ini"
local SCROLL_STEP_SIZE = 10
local EXTEND_SIZE = 20
local INTERVAL_SIZE = 10

ChatSettingPanel = {}

local tFontSizeMenu = 
{
	10,
	12,
	14,
	16,
	18,
	20,
	22,
	24,
	26,
	28,
	30,
}

local tChannels = 
{
	[1] = 
	{
		Name = g_tStrings.CHANNEL_CHANNEL,
		Group = 
		{
			"MSG_NORMAL", "MSG_PARTY", "MSG_MAP", "MSG_BATTLE_FILED", "MSG_GUILD", "MSG_SCHOOL", "MSG_WORLD",
			 "MSG_TEAM", "MSG_CAMP", "MSG_GROUP", "MSG_WHISPER", "MSG_MENTOR", "MSG_SEEK_MENTOR", "MSG_FRIEND", "MSG_SYS"
		},
	},
	[2] = 
	{
		Name = g_tStrings.FIGHT_CHANNEL,
		Group = 
		{
			[g_tStrings.STR_NAME_OWN] = 
			{
				"MSG_SKILL_SELF_SKILL", "MSG_SKILL_SELF_BUFF", "MSG_SKILL_SELF_DEBUFF", 
				"MSG_SKILL_SELF_MISS", "MSG_SKILL_SELF_FAILED"
			},
			[g_tStrings.TEAMMATE] = {"MSG_SKILL_PARTY_SKILL", "MSG_SKILL_PARTY_BUFF", "MSG_SKILL_PARTY_DEBUFF", "MSG_SKILL_PARTY_MISS"},
			[g_tStrings.OTHER_PLAYER] = {"MSG_SKILL_OTHERS_SKILL", "MSG_SKILL_OTHERS_MISS"},
			["NPC"] = {"MSG_SKILL_NPC_SKILL", "MSG_SKILL_NPC_MISS"},
			[g_tStrings.OTHER] = {"MSG_OTHER_DEATH", "MSG_OTHER_ENCHANT", "MSG_OTHER_SCENE"},
		}
	},
	[3] = 
	{
		Name = g_tStrings.CHANNEL_COMMON,
		Group = 
		{
			[g_tStrings.ENVIROMENT] = {"MSG_NPC_NEARBY", "MSG_NPC_YELL", "MSG_NPC_PARTY", "MSG_NPC_WHISPER"},
			[g_tStrings.EARN] = {"MSG_MONEY", "MSG_EXP", "MSG_ITEM", "MSG_REPUTATION", "MSG_CONTRIBUTE", "MSG_ATTRACTION", "MSG_PRESTIGE", "MSG_TRAIN", "MSG_DESGNATION", "MSG_ACHIEVEMENT", "MSG_MENTOR_VALUE", "MSG_DEVELOPMENT_POINT", "MSG_THEW_STAMINA"},
		}
	}
}

function ChatSettingPanel.OnFrameCreate()	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CHAT_PANEL_INFO_UPDATE")
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	
	ChatSettingPanel.Init(this)
end

function ChatSettingPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif szEvent == "CHAT_PANEL_INFO_UPDATE" then
		ChatSettingPanel.Init(this)
	end
end

function ChatSettingPanel.Init(hFrame)
	ChatSettingPanel.tColorCollapse = {}
	ChatSettingPanel.tChannelColor = {}
	ChatSettingPanel.InitPageSetting(hFrame)
	ChatSettingPanel.UpdateChannelSetting(hFrame)
	local hPage = hFrame:Lookup("PageSet_Total/Page_page", "Handle_List"):Lookup(0)
	ChatSettingPanel.SelectPageSetting(hPage)
	ChatSettingPanel.PageSettingChanged(hFrame, false)
	local hTotalPage = hFrame:Lookup("PageSet_Total")
	hTotalPage:ActivePage("Page_page")
	
	ChatSettingPanel.bDisabledEdit = false
	ChatSettingPanel.tCheckCollapse = {}
	ChatSettingPanel.tChatChannels = ChatPanel_GetChatPanel()
	ChatSettingPanel.nChatIndex = nil
	ChatSettingPanel.UpdateChatWindowList(hFrame)
	ChatSettingPanel.OnEnableNewChat(hFrame)
	ChatSettingPanel.WindowSettingChanged(hFrame, false)
end 

function ChatSettingPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Page" then
		local hPage = this:GetRoot():Lookup("PageSet_Total/Page_page", "Handle_List"):Lookup(0)
		ChatSettingPanel.SelectPageSetting(hPage)
	elseif szName == "CheckBox_Window" then
		local hSelect = this:GetRoot():Lookup("PageSet_Total/Page_Window", "Handle_WindowList"):Lookup(0)
		ChatSettingPanel.SelectChatWindowList(hSelect)
	elseif szName == "CheckBox_BGColor" then
		ChatSettingPanel.bBgShow = not this:IsCheckBoxChecked()
		ChatSettingPanel.PageSettingChanged(this:GetRoot(), true)
	end
end

function ChatSettingPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_BGColor" then
		ChatSettingPanel.bBgShow = not this:IsCheckBoxChecked()
		ChatSettingPanel.PageSettingChanged(this:GetRoot(), true)
	end
end

function ChatSettingPanel.OnItemLButtonClick()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Text_Filter" then
		ChatSettingPanel.PopFontFileMenu(this)
		ChatSettingPanel.PageSettingChanged(hFrame, true)
	elseif szName == "Text_Filter1" then
		ChatSettingPanel.PopFontSizeMenu(this)
		ChatSettingPanel.PageSettingChanged(hFrame, true)
	elseif szName == "Image_so" then
		local fnChangeColor = function(r, g, b)
			ChatSettingPanel.tBGColor.r = r
			ChatSettingPanel.tBGColor.g = g
			ChatSettingPanel.tBGColor.b = b
		end
		OpenColorTablePanel(fnChangeColor)
		ChatSettingPanel.PageSettingChanged(hFrame, true)
	end
end

function ChatSettingPanel.PopFontFileMenu(hText)
	local nPosX, nPosY = hText:GetAbsPos()
	local nWidth, nHeight = hText:GetSize()
	nPosY = nPosY + nHeight
	local szFont = ChatSettingPanel.szFontName
	tMenu = 
	{
		nMiniWidth = nWidth,
		x = nPosX,
		y = nPosY,
	}
	local fnSelectFontFile = function(UserData, bCkeck)
		hText:SetText(UserData.szName)
		ChatSettingPanel.szFontName = UserData.szName
		ChatSettingPanel.szFontFile = UserData.szFile
		GetPopupMenu():Hide()
	end
	
	local tFontPathList = Font.GetFontPathList() or {}
	
	for _, tFontFile in ipairs(tFontPathList) do
		local tMenuItem = 
		{
			szOption = tFontFile.szName,
			bMCheck = true,
			bChecked = (szFont == tFontFile.szName),
			fnAction = fnSelectFontFile,
			UserData = tFontFile,
			fnAutoClose = function() return true end,
		}
		table.insert(tMenu, tMenuItem)
	end
	PopupMenu(tMenu)
end

function ChatSettingPanel.PopFontSizeMenu(hText)
	local nPosX, nPosY = hText:GetAbsPos()
	local nWidth, nHeight = hText:GetSize()
	nPosY = nPosY + nHeight
	local nFont = ChatSettingPanel.nFontSize
	
	local fnSelectFontSize = function(UserData, bCkeck)
		hText:SetText(UserData)
		ChatSettingPanel.nFontSize = UserData
		GetPopupMenu():Hide()
	end
	local tMenu = 
	{
		nMiniWidth = nWidth,
		x = nPosX,
		y = nPosY,
	}
	for _, nFontSize in ipairs(tFontSizeMenu) do
		local tMenuItem = 
		{
			szOption = nFontSize .. g_tStrings.FONT_SIZE_WHAT,
			bMCheck = true,
			bChecked = (nFont	== nFontSize),
			fnAction = fnSelectFontSize,
			UserData = nFontSize,
			fnAutoClose = function() return true end,
		}
		table.insert(tMenu, tMenuItem)
	end
	PopupMenu(tMenu)
end

function ChatSettingPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "HI_Page_Page" then
		ChatSettingPanel.SelectPageSetting(this)
	elseif szName == "HI_Color" then
		ChatSettingPanel.SelectPageSetting(this)
	elseif szName == "HI_ChatWindow" then
		ChatSettingPanel.SelectChatWindowList(this)
	elseif szName == "Handle_Image" then
		local hOneChannel = this:GetParent()
		
		if hOneChannel.szMsg == "MSG_SYS" and ChatSettingPanel.nChatIndex == 1 then
			return
		end
		
		if hOneChannel.bCheck then
			hOneChannel.bCheck = false
		else
			hOneChannel.bCheck = true
		end
		ChatSettingPanel.UpdatChannelCheck(hOneChannel)
		ChatSettingPanel.WindowSettingChanged(this:GetRoot(), true)
		
		if hOneChannel:GetParent():GetName() == "Handle_GroupChannel" then
			local hGroup = hOneChannel:GetParent():GetParent()
			bCheck = ChatSettingPanel.IsGroupCheckAll(hGroup)
			hGroup.bCheck = bCheck
			ChatSettingPanel.UpdateGroupCheck(hGroup)
		end	
	elseif szName == "Handle_Image_Group" then
		local hGroup = this:GetParent()
		if hGroup.bCheck then
			hGroup.bCheck = false
			ChatSettingPanel.CheckAllGroup(hGroup, false)
		else
			hGroup.bCheck = true
			ChatSettingPanel.CheckAllGroup(hGroup, true)
		end
		ChatSettingPanel.UpdateGroupCheck(hGroup)
		ChatSettingPanel.WindowSettingChanged(this:GetRoot(), true)
	elseif szName == "Shadow_Color_Channel" then
		local hShadow = this
		local fnChangeColor = function(r, g, b)
			if not ChatSettingPanel.tChannelColor[hShadow.szMsg] then
				ChatSettingPanel.tChannelColor[hShadow.szMsg] = {}
			end
			ChatSettingPanel.tChannelColor[hShadow.szMsg].r = r
			ChatSettingPanel.tChannelColor[hShadow.szMsg].g = g
			ChatSettingPanel.tChannelColor[hShadow.szMsg].b = b
			hShadow:SetColorRGB(r, g, b)
		end
		OpenColorTablePanel(fnChangeColor)
		ChatSettingPanel.PageSettingChanged(this:GetRoot(), true)
	elseif szName == "Handle_SectionTitle" then
		if this.bPage then
			if ChatSettingPanel.tColorCollapse[this.nIndex] then
				ChatSettingPanel.tColorCollapse[this.nIndex] = false
			else
				ChatSettingPanel.tColorCollapse[this.nIndex] = true
			end
			ChatSettingPanel.UpdateChannelSetting(this:GetRoot())
		elseif this.bWindow then
			local tCollapse = ChatSettingPanel.tCheckCollapse[ChatSettingPanel.nChatIndex]
			if tCollapse[this.nIndex] then
				tCollapse[this.nIndex] = false
			else
				tCollapse[this.nIndex] = true
			end
			ChatSettingPanel.UpdateChatWindowInfo(this:GetRoot(), ChatSettingPanel.nChatIndex)
		end
	end
end

function ChatSettingPanel.OnLButtonClick()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_Close" or szName == "Btn_Cancel" or szName == "Btn_Cancel1" then
		CloseChatSettingPanel()
	elseif szName == "Btn_Default" then
		local fnMessageBoxAutoClose = function()
			if not IsChatSettingPanelOpened() then
				return true
			end
			return false
		end
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg = 
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = g_tStrings.RESET_CHAT_PAGE_SETTING,
			szName = "ResetChatPageSetting",
			fnAutoClose = fnMessageBoxAutoClose,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() ChatSettingPanel.ResetPageSetting(hFrame) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() end}
		}
		MessageBox(tMsg)
	elseif szName == "Btn_Sure" or szName == "Btn_Use" then
		ChatSettingPanel.ApplyPageSetting(hFrame)
		if szName == "Btn_Sure" then
			CloseChatSettingPanel()
		end
	elseif szName == "Btn_Sure1" or szName == "Btn_Use1" then
		ChatSettingPanel.ApplyWindowSetting(hFrame)
		if szName == "Btn_Sure1" then
			CloseChatSettingPanel()
		end
	elseif szName == "Btn_New" then
		ChatSettingPanel.NewChatWindow(hFrame)
	elseif szName == "Btn_Back" then
		local fnMessageBoxAutoClose = function()
			if not IsChatSettingPanelOpened() then
				return true
			end
			return false
		end
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg = 
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = g_tStrings.RESET_CHAT_WINDOW_SETTING,
			szName = "ResetChatWindowSetting",
			fnAutoClose = fnMessageBoxAutoClose,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() ChatSettingPanel.ResetWindowSetting(hFrame) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() end}
		}
		MessageBox(tMsg)
	elseif szName == "Btn_Delete" then
		local Chat = ChatSettingPanel.tChatChannels[ChatSettingPanel.nChatIndex]
		local fnMessageBoxAutoClose = function()
			if not IsChatSettingPanelOpened() then
				return true
			end
			return false
		end
		local nWidth, nHeight = Station.GetClientSize()
		local tMsg = 
		{
			x = nWidth / 2, y = nHeight / 2,
			szMessage = FormatString(g_tStrings.DELETE_CHAT_WINDOW, Chat.szName),
			szName = "DeleteChatWindow",
			fnAutoClose = fnMessageBoxAutoClose,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() ChatSettingPanel.DeleteChatWindow(hFrame) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, fnAction = function() end}
		}
		MessageBox(tMsg)
	end
end

function ChatSettingPanel.OnLButtonDown()
	ChatSettingPanel.OnLButtonHold()
end

function ChatSettingPanel.OnLButtonHold()
	local szName = this:GetName()
	local hPage = this:GetParent()
	if szName == "Btn_Up1" then
		hPage:Lookup("Scroll_List1"):ScrollPrev(1)
	elseif szName == "Btn_Down1" then
		hPage:Lookup("Scroll_List1"):ScrollNext(1)
	elseif szName == "Btn_Up" then
		hPage:Lookup("Scroll_List"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		hPage:Lookup("Scroll_List"):ScrollNext(1)
	elseif szName == "Btn_Up2" then
		hPage:Lookup("Scroll_List2"):ScrollPrev(1)
	elseif szName == "Btn_Down2" then
		hPage:Lookup("Scroll_List2"):ScrollNext(1)
	end
end

function ChatSettingPanel.OnScrollBarPosChanged()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	if szName == "Scroll_VD" then
		ChatSettingPanel.tBGColor.a = (1 - nCurrentValue / 100) * 255
		
		local hAlphaText = this:GetParent():Lookup("", "Text_Num")
		hAlphaText:SetText(nCurrentValue .."%")
		ChatSettingPanel.PageSettingChanged(this:GetRoot(), true)
	elseif szName == "Scroll_List" then
		local hFrame = this:GetParent()
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up"):Enable(false)
		else
			hFrame:Lookup("Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_Down"):Enable(false)
		else
			hFrame:Lookup("Btn_Down"):Enable(true)
		end
		
		local hHandle = hFrame:Lookup("", "Handle_Right/Handle_Right_Color")
		hHandle:SetItemStartRelPos(0, - nCurrentValue * SCROLL_STEP_SIZE)
	elseif szName == "Scroll_List2" then
		local hFrame = this:GetParent()
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up2"):Enable(false)
		else
			hFrame:Lookup("Btn_Up2"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_Down2"):Enable(false)
		else
			hFrame:Lookup("Btn_Down2"):Enable(true)
		end
		
		local hHandle = hFrame:Lookup("", "Handle_Riight")
		hHandle:SetItemStartRelPos(0, - nCurrentValue * SCROLL_STEP_SIZE)
	elseif szName == "Scroll_List1" then
		local hFrame = this:GetParent()
		if nCurrentValue == 0 then
			hFrame:Lookup("Btn_Up1"):Enable(false)
		else
			hFrame:Lookup("Btn_Up1"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			hFrame:Lookup("Btn_Down1"):Enable(false)
		else
			hFrame:Lookup("Btn_Down1"):Enable(true)
		end
		
		local hHandle = hFrame:Lookup("PageSet_Total/Page_Window", "Handle_WindowList")
		hHandle:SetItemStartRelPos(0, - nCurrentValue * SCROLL_STEP_SIZE)
	end
	
end

function ChatSettingPanel.OnItemMouseEnter()
	local szName = this:GetName()
	
	if szName == "Handle_Image" then
		local hOneChannel = this:GetParent()
		
		if hOneChannel.szMsg == "MSG_SYS" and ChatSettingPanel.nChatIndex == 1 then
			return
		end
		
		hOneChannel.bMouse = true
		ChatSettingPanel.UpdatChannelCheck(hOneChannel)
	elseif szName == "Handle_Image_Group" then
		local hGroup = this:GetParent()
		hGroup.bMouse = true
		ChatSettingPanel.UpdateGroupCheck(hGroup)
	elseif string.find(szName, "HI_") then
		if not this.bSelect then
			this:Lookup(0):Show()
			this:Lookup(0):SetAlpha(127)
		end
	end
end

function ChatSettingPanel.OnItemMouseWheel()
	
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_WindowList" then
		this:GetRoot():Lookup("Scroll_List1"):ScrollNext(nDistance)
	elseif szName == "Handle_Right_Color" then
		this:GetParent():GetParent():GetParent():Lookup("Scroll_List"):ScrollNext(nDistance)
	elseif szName == "Handle_Riight" then
		this:GetParent():GetParent():Lookup("Scroll_List2"):ScrollNext(nDistance)
	end
	return 1
end

function ChatSettingPanel.OnItemMouseLeave()
	local szName = this:GetName()
	
	if szName == "Handle_Image" then
		local hOneChannel = this:GetParent()
		if hOneChannel.szMsg == "MSG_SYS" and ChatSettingPanel.nChatIndex == 1 then
			return
		end
		hOneChannel.bMouse = false
		ChatSettingPanel.UpdatChannelCheck(hOneChannel)
	elseif szName == "Handle_Image_Group" then
		local hGroup = this:GetParent()
		hGroup.bMouse = false
		ChatSettingPanel.UpdateGroupCheck(hGroup)
	elseif string.find(szName, "HI_") then
		if not this.bSelect then
			this:Lookup(0):Hide()
		end
	end
end

function ChatSettingPanel.OnEditChanged()
	if this:GetName() == "Edit_Name" then
		ChatSettingPanel.WindowSettingChanged(this:GetRoot(), true)
	end
end

function ChatSettingPanel.UpdateChatWindowList(hFrame)
	local hWindowList = hFrame:Lookup("PageSet_Total/Page_Window", "Handle_WindowList")
	hWindowList:Clear()
	local hWindowTitle = nil
	for nIndex, tChatPanel in ipairs(ChatSettingPanel.tChatChannels) do
		hWindowTitle = hWindowList:AppendItemFromIni(CHATSETTING_PANEL_PATH, "HI_ChatWindow")
		hWindowTitle.nIndex = nIndex
		hWindowTitle:Lookup("Text_ChatWindow"):SetText(tChatPanel.szName)
		ChatSettingPanel.tCheckCollapse[nIndex] = {}
	end
	hWindowList:FormatAllItemPos()
	
	ChatSettingPanel.UpdateChatWindowListScroll(hWindowList, true)	
end

function ChatSettingPanel.SelectChatWindowList(hSelect)
	local hWindowList = hSelect:GetParent()
	
	local nCount = hWindowList:GetItemCount()
	
	for i = 0, nCount - 1 do
		local hChat = hWindowList:Lookup(i)
		if hChat.bSelect then
			hChat:Lookup("TN_ChatWindow"):Hide()
			hChat.bSelect = false
		end
	end	
	
	hSelect:Lookup("TN_ChatWindow"):Show()
	hSelect:Lookup("TN_ChatWindow"):SetAlpha(255)
	hSelect.bSelect = true
	
	local hFrame = hSelect:GetRoot()
	ChatSettingPanel.UpdateChatWindowInfo(hFrame, hSelect.nIndex, true)
end

function ChatSettingPanel.UpdateChatWindowListScroll(hList, bHome)
	local hFrame = hList:GetRoot()
	local hScroll = hFrame:Lookup("Scroll_List1")
	local nWidthAll, nHeightAll = hList:GetAllItemSize()
	local nWidth, nHeight = hList:GetSize()
	
	local nStepCount =  math.ceil((nHeightAll - nHeight) / SCROLL_STEP_SIZE)
	if nStepCount > 0 then
		hScroll:Show()
		hFrame:Lookup("Btn_Up1"):Show()
		hFrame:Lookup("Btn_Down1"):Show()
	else
		hScroll:Hide()
		hFrame:Lookup("Btn_Up1"):Hide()
		hFrame:Lookup("Btn_Down1"):Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function ChatSettingPanel.UpdateChatWindowInfo(hFrame, nIndex, bHome)
	local tChat = ChatSettingPanel.tChatChannels[nIndex]
	local hBtnCancel = hFrame:Lookup("PageSet_Total/Page_Window/Btn_Delete")
	hBtnCancel:Enable(true)
	
	ChatSettingPanel.SaveLastChatName(hFrame)
	
	ChatSettingPanel.nChatIndex = nIndex
	local hChatName = hFrame:Lookup("PageSet_Total/Page_Window/Wnd_Colligate/Edit_Name")
	local hTextName = hFrame:Lookup("PageSet_Total/Page_Window/Wnd_Colligate", "Text_Name")

	ChatSettingPanel.bDisabledEdit = true
	hChatName:SetText(tChat.szName)
	ChatSettingPanel.bDisabledEdit = false
	if nIndex == 1 then
		hBtnCancel:Enable(false)
		hChatName:Enable(false)
		hTextName:SetText(g_tStrings.CHAT_NAME)
	else
		hChatName:Enable(true)
		hTextName:SetText(g_tStrings.CHAT_MODIFY_NAME)
	end

	local hWindow = hFrame:Lookup("PageSet_Total/Page_Window", "Handle_Riight")
	hWindow:Clear()
	
	local hSection = nil
	local hSectionTitle = nil
	local hTextTitle = nil
	local hChannel = nil
	local Image = nil
	local tCollapse = ChatSettingPanel.tCheckCollapse[nIndex]
	for k, tSection in ipairs(tChannels) do
		hSection = hWindow:AppendItemFromIni(CHATSETTING_PANEL_PATH, "Handle_Section")
		hSectionTitle = hSection:Lookup("Handle_SectionTitle")
		hSectionTitle:Lookup("Text_SectionTitle"):SetText(tSection.Name)
		local hChannel = hSection:Lookup("Handle_Channel")
		hSectionTitle.bWindow = true
		hSectionTitle.nIndex = k
		if tCollapse[k] then
			hSectionTitle:Lookup("Image_Collapse"):Hide()
			hSectionTitle:Lookup("Image_Expand"):Show()
			hChannel:SetSize(0, 0)
		else
			hSectionTitle:Lookup("Image_Collapse"):Show()
			hSectionTitle:Lookup("Image_Expand"):Hide()
			for GroupName, Group in pairs(tSection.Group) do
				if type(Group) == "table" then
					local hGroup = hChannel:AppendItemFromIni(CHATSETTING_PANEL_PATH, "Handle_Group")
					hGroup:Lookup("Text_Group"):SetText(GroupName)
					
					local hGroupChannel = hGroup:Lookup("Handle_GroupChannel")
					for _, szChannel in pairs(Group) do
						bCheck = ChatSettingPanel.AppendCheckChannel(hGroupChannel, szChannel)
					end
					
					local bAllCheck = ChatSettingPanel.IsGroupCheckAll(hGroup)
					hGroup.bCheck = bAllCheck
					ChatSettingPanel.UpdateGroupCheck(hGroup)
					hGroup:Lookup("Handle_Image_Group"):Show()
					
					hGroupChannel:FormatAllItemPos()
					local nWidth, nHeight = hGroupChannel:GetAllItemSize()
					hGroupChannel:SetSize(nWidth, nHeight)
					local nTextWidth, nTextHeight = hGroup:Lookup("Text_Group"):GetSize()
					hGroup:SetSize(nWidth, nHeight + nTextHeight + INTERVAL_SIZE)
					hGroup:FormatAllItemPos()
					hGroup:Show()
				else
					ChatSettingPanel.AppendCheckChannel(hChannel, Group)
				end
			end
			hChannel:FormatAllItemPos()
			local nWidth , nHeight = hChannel:GetAllItemSize()
			hChannel:SetSize(nWidth, nHeight)
			hChannel:Show()
		end
		
		local nTitleWidth, nTitleHeight = hSectionTitle:GetSize()
		local nChannelWidth, nChannelHeight = hChannel:GetSize()
		hSection:Lookup("Handle_BG"):SetSize(nTitleWidth, nTitleHeight + nChannelHeight + EXTEND_SIZE)
		hSection:Lookup("Handle_BG/Image_BG"):SetSize(nTitleWidth, nTitleHeight + nChannelHeight + EXTEND_SIZE)
		hSection:SetSize(nTitleWidth, nTitleHeight + nChannelHeight + EXTEND_SIZE)
		hSection:FormatAllItemPos()
		hSection:Show()
	end
	hWindow:FormatAllItemPos()
	hWindow:Show()
	ChatSettingPanel.UpdateChatWindowScroolInfo(hWindow, bHome)
	
end

function ChatSettingPanel.AppendCheckChannel(hList, szName)
	local tChat = ChatSettingPanel.tChatChannels[ChatSettingPanel.nChatIndex]
	local hOneChannel = hList:AppendItemFromIni(CHATSETTING_PANEL_PATH, "Handle_Check_OneChannel")
	hOneChannel:Lookup("Text_Check_OneChannel"):SetText(g_tStrings.tChannelName[szName])
	hOneChannel.szMsg = szName
	if tChat.tMsg[szName] then
			hOneChannel.bCheck = true
	end
	ChatSettingPanel.UpdatChannelCheck(hOneChannel)
	local r, g , b = nil, nil, nil
	local tColor = ChatSettingPanel.tChannelColor[szName]
	if tColor then
		r , g , b = tColor.r, tColor.g, tColor.b
	else
		r , g , b = GetMsgFontColor(szName)
	end
	local hShadow = hOneChannel:Lookup("Shadow_Check_OneChannel")
	hShadow:SetColorRGB(r, g , b)
end

function ChatSettingPanel.UpdateChatWindowScroolInfo(hInfo, bHome)
	local nWidthAll, nHeightAll = hInfo:GetAllItemSize()
	local nWidth, nHeight = hInfo:GetSize()
	
	local nStepCount = math.ceil((nHeightAll - nHeight) / SCROLL_STEP_SIZE)
	local hPage = hInfo:GetParent():GetParent()
	hScroll = hPage:Lookup("Scroll_List2")
	hScroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		hScroll:Show()
		hPage:Lookup("Btn_Up2"):Show()
		hPage:Lookup("Btn_Down2"):Show()
	else
		hScroll:Hide()
		hPage:Lookup("Btn_Up2"):Hide()
		hPage:Lookup("Btn_Down2"):Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function ChatSettingPanel.UpdatChannelCheck(hOneChannel)
	
	hOneChannel:Lookup("Handle_Image/Image_NoCheck"):Hide()
	hOneChannel:Lookup("Handle_Image/Image_NoCheck_Mouse"):Hide()
	hOneChannel:Lookup("Handle_Image/Image_Check_Mouse"):Hide()
	hOneChannel:Lookup("Handle_Image/Image_Check"):Hide()
	
	local tChat = ChatSettingPanel.tChatChannels[ChatSettingPanel.nChatIndex]
	if hOneChannel.bCheck then
		tChat.tMsg[hOneChannel.szMsg] = true
		if hOneChannel.bMouse then
			hOneChannel:Lookup("Handle_Image/Image_Check_Mouse"):Show()
		else
			hOneChannel:Lookup("Handle_Image/Image_Check"):Show()
		end
	else
		if hOneChannel.bMouse then
			hOneChannel:Lookup("Handle_Image/Image_NoCheck_Mouse"):Show()
		else
			hOneChannel:Lookup("Handle_Image/Image_NoCheck"):Show()
		end
		tChat.tMsg[hOneChannel.szMsg] = false
	end
end

function ChatSettingPanel.IsGroupCheckAll(hGroup)
	local hGroupChannel = hGroup:Lookup("Handle_GroupChannel")
	local nCount = hGroupChannel:GetItemCount()
	local bAllCheck = true
	for i = 0, nCount - 1 do
		local hOneChannel = hGroupChannel:Lookup(i)
		if not hOneChannel.bCheck then
			bAllCheck = false
			break
		end
	end	
	
	return bAllCheck
end

function ChatSettingPanel.CheckAllGroup(hGroup, bCheck)
	local hGroupChannel = hGroup:Lookup("Handle_GroupChannel")
	local nCount = hGroupChannel:GetItemCount()
	
	for i = 0, nCount - 1 do
		local hOneChannel = hGroupChannel:Lookup(i)
		hOneChannel.bCheck = bCheck
		ChatSettingPanel.UpdatChannelCheck(hOneChannel)
	end
end

function ChatSettingPanel.UpdateGroupCheck(hGroup)
	hGroup:Lookup("Handle_Image_Group/Image_NoCheck_Group"):Hide()
	hGroup:Lookup("Handle_Image_Group/Image_NoCheck_Mouse_Group"):Hide()
	hGroup:Lookup("Handle_Image_Group/Image_Check_Mouse_Group"):Hide()
	hGroup:Lookup("Handle_Image_Group/Image_Check_Group"):Hide()
	
	if hGroup.bCheck then
		if hGroup.bMouse then
			hGroup:Lookup("Handle_Image_Group/Image_Check_Mouse_Group"):Show()
		else
			hGroup:Lookup("Handle_Image_Group/Image_Check_Group"):Show()
		end
	else
		if hGroup.bMouse then
			hGroup:Lookup("Handle_Image_Group/Image_NoCheck_Mouse_Group"):Show()
		else
			hGroup:Lookup("Handle_Image_Group/Image_NoCheck_Group"):Show()
		end
	end
end

function ChatSettingPanel.InitPageSetting(hFrame)
	hWndPage = hFrame:Lookup("PageSet_Total/Page_Page/Wnd_Page")
	
	local szFontName, szFontFile, nFontSize = Font.GetFont(Font.GetChatFontID())
	ChatSettingPanel.szFontName = szFontName
	ChatSettingPanel.szFontFile = szFontFile
	ChatSettingPanel.nFontSize = nFontSize
	local hTextFontName = hWndPage:Lookup("", "Handle_Filter/Text_Filter")
	hTextFontName:SetText(szFontName)
	
	local hTextFontSize = hWndPage:Lookup("", "Handle_Filter1/Text_Filter1")
	hTextFontSize:SetText(nFontSize .. g_tStrings.FONT_SIZE_WHAT)
	
	local bBgShow, tBGColor = ChatPanel_GetChatBgInfo()
	ChatSettingPanel.bBgShow = bBgShow
	ChatSettingPanel.tBGColor = tBGColor
	local hCheckBGColor = hWndPage:Lookup("CheckBox_BGColor")
	hCheckBGColor:Check(not bBgShow)
	
	
	local hAlphaScroll = hWndPage:Lookup("Scroll_VD")
	hAlphaScroll:SetScrollPos(100 * (1 - tBGColor.a / 255))
	
	local hAlphaText = hWndPage:Lookup("", "Text_Num")
	hAlphaText:SetText(hAlphaScroll:GetScrollPos().."%")
end

function ChatSettingPanel.UpdateChannelSetting(hFrame, bHome)
	local hHandleColor = hFrame:Lookup("PageSet_Total/Page_Page", "Handle_Right/Handle_Right_Color")
	hHandleColor:Clear()
	local hSection = nil
	local hSectionTitle = nil
	local hTextTitle = nil
	local hChannel = nil
	local Image = nil
	for k, tSection in ipairs(tChannels) do
		hSection = hHandleColor:AppendItemFromIni(CHATSETTING_PANEL_PATH, "Handle_Section")
		hSectionTitle = hSection:Lookup("Handle_SectionTitle")
		hSectionTitle:Lookup("Text_SectionTitle"):SetText(tSection.Name)
		local hChannel = hSection:Lookup("Handle_Channel")
		hSectionTitle.bPage = true
		hSectionTitle.nIndex = k
		if ChatSettingPanel.tColorCollapse[k] then
			hSectionTitle:Lookup("Image_Collapse"):Hide()
			hSectionTitle:Lookup("Image_Expand"):Show()
			hChannel:SetSize(0, 0)
		else
			hSectionTitle:Lookup("Image_Collapse"):Show()
			hSectionTitle:Lookup("Image_Expand"):Hide()
			for GroupName, Group in pairs(tSection.Group) do
				if type(Group) == "table" then
					local hGroup = hChannel:AppendItemFromIni(CHATSETTING_PANEL_PATH, "Handle_Group")
					hGroup:Lookup("Text_Group"):SetText(GroupName)
					local hGroupChannel = hGroup:Lookup("Handle_GroupChannel")
					for _, szChannel in pairs(Group) do
						ChatSettingPanel.AppendColorChannel(hGroupChannel, szChannel)
					end
					hGroupChannel:FormatAllItemPos()
					local nWidth, nHeight = hGroupChannel:GetAllItemSize()
					hGroupChannel:SetSize(nWidth, nHeight)
					local nTextWidth, nTextHeight = hGroup:Lookup("Text_Group"):GetSize()
					hGroup:SetSize(nWidth, nHeight + nTextHeight + INTERVAL_SIZE)
					hGroup:FormatAllItemPos()
					hGroup:Show()
				else
					ChatSettingPanel.AppendColorChannel(hChannel, Group)
				end
			end
			hChannel:FormatAllItemPos()
			local nWidth , nHeight = hChannel:GetAllItemSize()
			hChannel:SetSize(nWidth, nHeight)
			hChannel:Show()
		end
		
		local nTitleWidth, nTitleHeight = hSectionTitle:GetSize()
		local nChannelWidth, nChannelHeight = hChannel:GetSize()
		hSection:Lookup("Handle_BG"):SetSize(nTitleWidth, nTitleHeight + nChannelHeight + EXTEND_SIZE)
		hSection:Lookup("Handle_BG/Image_BG"):SetSize(nTitleWidth, nTitleHeight + nChannelHeight + EXTEND_SIZE)
		hSection:SetSize(nTitleWidth, nTitleHeight + nChannelHeight + EXTEND_SIZE)
		hSection:FormatAllItemPos()
		hSection:Show()
	end
	hHandleColor:FormatAllItemPos()
	hHandleColor:Show()
	ChatSettingPanel.UpdateChannelSettingScrollInfo(hHandleColor, bHome)
end

function ChatSettingPanel.AppendColorChannel(hList, szName)
	local hOneChannel = hList:AppendItemFromIni(CHATSETTING_PANEL_PATH, "Handle_Color_OneChannel")
	hOneChannel:Lookup("Text_Color_Name"):SetText(g_tStrings.tChannelName[szName])
	local r, g , b = nil, nil, nil
	local tColor = ChatSettingPanel.tChannelColor[szName]
	if tColor then
		r , g , b = tColor.r, tColor.g, tColor.b
	else
		r , g , b = GetMsgFontColor(szName)
	end
	local hShadow = hOneChannel:Lookup("Shadow_Color_Channel")
	hShadow:SetColorRGB(r, g , b)
	hShadow.szMsg = szName
	
end

function ChatSettingPanel.UpdateChannelSettingScrollInfo(hFrame, bHome)
	local nWidthAll, nHeightAll = hFrame:GetAllItemSize()
	local nWidth, nHeight = hFrame:GetSize()
	
	local nStepCount = math.ceil((nHeightAll - nHeight) / SCROLL_STEP_SIZE)
	local hPage = hFrame:GetParent():GetParent():GetParent()
	hScroll = hPage:Lookup("Scroll_List")
	hScroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		hScroll:Show()
		hPage:Lookup("Btn_Up"):Show()
		hPage:Lookup("Btn_Down"):Show()
	else
		hScroll:Hide()
		hPage:Lookup("Btn_Up"):Hide()
		hPage:Lookup("Btn_Down"):Hide()
	end
	
	if bHome then
		hScroll:ScrollHome()
	end
end

function ChatSettingPanel.SelectPageSetting(hSelect)
	local szName = nil
	local hWnd = nil
	
	local hPageList = hSelect:GetParent()
	local nCount = hPageList:GetItemCount()
	for i = 0, nCount - 1 do
		local hPage = hPageList:Lookup(i)
		hPage:Lookup(0):Hide()
		hPage.bSelect = false
	end
	
	hSelect:Lookup(0):Show()
	hSelect:Lookup(0):SetAlpha(255)
	hSelect.bSelect = true
	szName = hSelect:GetName()
	local hPage = hPageList:GetParent():GetParent()
	local hScroll = hPageList:GetParent():GetParent():Lookup("Scroll_List")
	if szName == "HI_Page_Page" then
		hPage:Lookup("Wnd_Page"):Show()
		hPage:Lookup("", "Handle_Right"):Hide()
		hPage:Lookup("Btn_Up"):Hide()
		hPage:Lookup("Btn_Down"):Hide()
		hScroll:Hide()
	elseif szName == "HI_Color" then
		hPage:Lookup("Wnd_Page"):Hide()
		hPage:Lookup("", "Handle_Right"):Show()
		hScroll:Show()
		hPage:Lookup("Btn_Up"):Show()
		hPage:Lookup("Btn_Down"):Show()
		hScroll:ScrollHome()
	end
end

function ChatSettingPanel.SaveLastChatName(hFrame)
	local hChatName = hFrame:Lookup("PageSet_Total/Page_Window/Wnd_Colligate/Edit_Name")
	if ChatSettingPanel.nChatIndex then
		local tLastChat = ChatSettingPanel.tChatChannels[ChatSettingPanel.nChatIndex]
		local szName = hChatName:GetText()
		if szName ~= "" then
			tLastChat.szName = hChatName:GetText()
		end
	end
end

function ChatSettingPanel.NewChatWindow(hFrame)
	function fnNewChatWindow(szName)
		UserNewChatPanel(szName)
		
		ChatSettingPanel.tChatChannels = ChatPanel_GetChatPanel()
		ChatSettingPanel.UpdateChatWindowList(hFrame)
		
		local hWindowList = hFrame:Lookup("PageSet_Total/Page_Window", "Handle_WindowList")
		local nChatCount = hWindowList:GetItemCount()
		ChatSettingPanel.SelectChatWindowList(hWindowList:Lookup(nChatCount - 1))
		
		ChatSettingPanel.OnEnableNewChat(hFrame)
		ChatSettingPanel.WindowSettingChanged(hFrame, true)
	end
	
	GetUserInput(g_tStrings.CHAT_INPUT_NAME, fnNewChatWindow, nil, nil, nil, nil, 9)
end

function ChatSettingPanel.OnEnableNewChat(hFrame)
	local hBtnNewChat = hFrame:Lookup("PageSet_Total/Page_Window/Btn_New")
	
	local nMaxChatCount = ChatPanel_GetMaxChatCount()
	local nCurChatCount = #ChatSettingPanel.tChatChannels
	
	if nCurChatCount < nMaxChatCount then
		hBtnNewChat:Enable(true)
	else
		hBtnNewChat:Enable(false)
	end
end

function ChatSettingPanel.PageSettingChanged(hFrame, bChanged)
	local hBtnPageApply = hFrame:Lookup("PageSet_Total/Page_Page/Btn_Use")
	
	if bChanged then
		hBtnPageApply:Enable(true)
	else 
		hBtnPageApply:Enable(false)
	end
	
end

function ChatSettingPanel.WindowSettingChanged(hFrame, bChanged)
	if ChatSettingPanel.bDisabledEdit then
		return
	end
	
	local hBtnWindowApply = hFrame:Lookup("PageSet_Total/Page_Window/Btn_Use1")
	
	if bChanged then
		hBtnWindowApply:Enable(true)
	else 
		hBtnWindowApply:Enable(false)
	end
end

function ChatSettingPanel.DeleteChatWindow(hFrame)
	local tChat = ChatSettingPanel.tChatChannels[ChatSettingPanel.nChatIndex]
	ChatPanel_Base_CloseChatWindow(tChat.hWindow)
	ChatSettingPanel.tChatChannels = ChatPanel_GetChatPanel()
	ChatSettingPanel.nChatIndex = nil
	ChatSettingPanel.UpdateChatWindowList(hFrame)
	local hWindowList = hFrame:Lookup("PageSet_Total/Page_Window", "Handle_WindowList")
	ChatSettingPanel.SelectChatWindowList(hWindowList:Lookup(0))
	
	ChatSettingPanel.OnEnableNewChat(hFrame)
end

function ChatSettingPanel.ApplyPageSetting(hFrame)
	ChatPanel_Base_OnSetBgInfo(ChatSettingPanel.bBgShow, ChatSettingPanel.tBGColor.r, ChatSettingPanel.tBGColor.g, ChatSettingPanel.tBGColor.b, ChatSettingPanel.tBGColor.a)
	ChatPanel_Base_SetChatFont(ChatSettingPanel.szFontName, ChatSettingPanel.szFontFile, ChatSettingPanel.nFontSize)
	
	for szMsg, tColor in pairs(ChatSettingPanel.tChannelColor) do
		SetMsgFontColor(szMsg, tColor.r, tColor.g, tColor.b)
	end
	
	ChatSettingPanel.PageSettingChanged(hFrame, false)
	EditBox_OnMsgColorChanged()
end

function ChatSettingPanel.ApplyWindowSetting(hFrame)
	ChatSettingPanel.SaveLastChatName(hFrame)

	for nIndex, tChat in ipairs(ChatSettingPanel.tChatChannels) do
		ChatPanel_Base_ChatReName(tChat.hWindow, tChat.szName)
		for szMsg, bCheck in pairs(tChat.tMsg) do
			ChatPanel_Base_OnChatMonitorChanged(tChat.hWindow, szMsg, bCheck)
		end
	end
	ChatSettingPanel.WindowSettingChanged(hFrame, false)
	ChatSettingPanel.tChatChannels = ChatPanel_GetChatPanel()
	ChatSettingPanel.UpdateChatWindowInfo(hFrame, ChatSettingPanel.nChatIndex)
end

function ChatSettingPanel.ResetPageSetting(hFrame)
	ChatPanel_Base_SetDefaultBgInfo()
	ChatPanel_Base_SetDefaultChatFont()
	SetDefaultMsgFontColor()
	
	ChatSettingPanel.tColorCollapse = {}
	ChatSettingPanel.tChannelColor = {}
	ChatSettingPanel.InitPageSetting(hFrame)
	ChatSettingPanel.UpdateChannelSetting(hFrame)
	local hPage = hFrame:Lookup("PageSet_Total/Page_page", "Handle_List"):Lookup(0)
	ChatSettingPanel.SelectPageSetting(hPage)
	ChatSettingPanel.PageSettingChanged(hFrame, false)
end

function ChatSettingPanel.ResetWindowSetting(hFrame)
	ChatPanel_Base_SetDefaultChatWindow()
	
	ChatSettingPanel.tCheckCollapse = {}
	ChatSettingPanel.tChatChannels = ChatPanel_GetChatPanel()
	ChatSettingPanel.nChatIndex = nil
	ChatSettingPanel.UpdateChatWindowList(hFrame)
	local hWindowList = hFrame:Lookup("PageSet_Total/Page_Window", "Handle_WindowList")
	ChatSettingPanel.SelectChatWindowList(hWindowList:Lookup(0))
	
	ChatSettingPanel.WindowSettingChanged(hFrame, false)
	ChatSettingPanel.OnEnableNewChat(hFrame)
end

function OpenChatSettingPanel()
	if IsChatSettingPanelOpened() then
		return
	end
	CloseOptionAndOptionChildPanel()
	
	local hFrame = Wnd.OpenWindow("ChatSettingPanel")
end

function IsChatSettingPanelOpened()
	local hFrame = Station.Lookup("Normal/ChatSettingPanel")
	
	if hFrame then
		return true
	end
	return false
end

function CloseChatSettingPanel(bDisableSound) 
	if not IsChatSettingPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("ChatSettingPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end