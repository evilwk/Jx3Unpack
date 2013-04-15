local lc_szType = "bank"
local tRemoteFun = 
{
		Set="OnSetBankPassword", 
		Modify = "OnModifyBankPassword",
		Reset = "OnResetBankPassword",
		Verify = "OnVerifyBankPassword",
		ModifyInfo = "OnModifyBankPasswordInfo",
		ModifyChoice = "OnModifySafeLockOption",
}

function Lock_SetType(szType)
	lc_szType = szType
end

local function GetLockResetEndTime()
	local player = GetClientPlayer()
	if lc_szType == "bank" then
		return player.nBankPasswordResetEndTime
	end
end

local function IsPasswordExist()
	local player = GetClientPlayer()
	if lc_szType == "bank" then
		return player.bBankPasswordExist
	end
end

local function IsPasswordVerified()
	local player = GetClientPlayer()
	if lc_szType == "bank" then
		return player.bIsBankPasswordVerified
	elseif lc_szType == "tong" then
	
	end
end

function Lock_State(szType, state)
	local nResetEndTime = GetLockResetEndTime()
	local nLeftTime = nResetEndTime - GetCurrentTime() 
	if nLeftTime > 0 then
		return "PASSWORD_RESETING", nResetEndTime
	end
	
	local bBankPasswordExist = IsPasswordExist()
	local bIsBankPasswordVerified = IsPasswordVerified()
	
	if not bBankPasswordExist then
		return "NO_PASSWORD"
	end
	
	if not bIsBankPasswordVerified then
		return "PASSWORD_LOCK"
	end
	
	if bIsBankPasswordVerified then
		return "PASSWORD_UNLOCK"
	end
end

function LockChoice_State(ChoiceType, state)
	local bBankPasswordExist = IsPasswordExist()
	
	local player = GetClientPlayer()
	local tInfo = player.GetSafeLockMaskInfo()
	local bChoice = tInfo[ChoiceType]
	if not bBankPasswordExist then
		return "NO_PASSWORD"
	end
	
	if bChoice then
		return "CHOICE_LOCK_SELECT"
	end

	if not bChoice then
		return "CHOICE_LOCK_UNSELECT"
	end
end

function Lock_UpdateState(hBtnLock, hBtnUnLock, hText)
	local state, nResetEndTime = Lock_State()
	if not state then
		hBtnLock:Hide()
		hBtnUnLock:Hide()
		if hText then
			hText:Hide()
		end
		return nResetEndTime
	end
	
	if hText then
		hText:Show()
	end
	if state == "NO_PASSWORD" then
		hBtnLock:Hide()
		hBtnUnLock:Show()
		
		if hText then
			hText:SetText(g_tStrings.STR_LOACK_BANK)
		end
	elseif state == "PASSWORD_UNLOCK" then
		hBtnLock:Hide()
		hBtnUnLock:Show()
		
		if hText then
			hText:SetText(g_tStrings.STR_BACK_UNLOCK)
		end
	elseif state == "PASSWORD_LOCK" then
		hBtnLock:Show()
		hBtnUnLock:Hide()
		if hText then
			hText:SetText(g_tStrings.STR_BACK_LOCK)
		end
		
	elseif state == "PASSWORD_RESETING" then
		hBtnLock:Show()
		hBtnUnLock:Hide()
		
		local nLeftTime = nResetEndTime - GetCurrentTime()
		if nLeftTime > 0 then
			nResetEndTime = nResetEndTime
			if hText then
				local szTime = GetTimeText(nLeftTime, false, true)
				hText:SetText(FormatString(g_tStrings.STR_PASSWORD_RESET_TIME, szTime))
			end
		else
			nResetEndTime = 0
		end
		--Bank_LockClick()
	end
	return state, (nResetEndTime or 0)
end

function Lock_Click()
	local state = Lock_State()
	if state == "PASSWORD_LOCK" or state == "PASSWORD_RESETING" then
		local menu = {}
		local tMenu = { 
			szOption = g_tStrings.STR_OPEN_UNLOCK,
			fnAction = function() 
				OpenBankUnlock()
			end,
		}
		table.insert(menu, tMenu)
		--[[
		tMenu = {
			szOption = g_tStrings.STR_OPEN_CHOICE,
			fnAction = function()
				OpenBankPasswordChoice()
			end,
		}
		table.insert(menu, tMenu)
		]]
		tMenu = {
			szOption = g_tStrings.STR_MODIFY_PASSWORD,
			fnAction = function()
				OpenModifyPassword()
			end,
		}
		table.insert(menu, tMenu)
		
		PopupMenu(menu)
	end
end
		
function UnLock_Click()
	local state = Lock_State()
	
	if state == "NO_PASSWORD" then
		OpenBankPasswordSet()
		return 
	else
	--[[
		local menu = {}
		local tMenu = {
			szOption = g_tStrings.STR_OPEN_CHOICE,
			fnAction = function()
				OpenBankPasswordChoice()
			end,
		}
		table.insert(menu, tMenu)
		
		tMenu = {
			szOption = g_tStrings.STR_MODIFY_PASSWORD,
			fnAction = function()
				OpenModifyPassword()
			end,
		}
		
		table.insert(menu, tMenu)
		PopupMenu(menu)
		]]
		OpenModifyPassword()
	end
	
	--OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_AUTO_EXIST_LOCK)
	--OutputMessage("MSG_SYS", g_tStrings.STR_AUTO_EXIST_LOCK.."\n")
end

function CheckHaveLocked(ChoiceType, szMsg)
	local state = LockChoice_State(ChoiceType)
	local state1 = Lock_State(ChoiceType)
	local player = GetClientPlayer()
	
	if state == "CHOICE_LOCK_SELECT" and state1 ~= "PASSWORD_UNLOCK" then
		OpenBankUnlock()
		return true
	end
	return false
end

function Lock_GetTip()
	local szTip = ""
	local state, nResetEndTime = Lock_State()
	if state == "PASSWORD_RESETING" then
		local nLeftTime = nResetEndTime - GetCurrentTime()
		if nLeftTime > 0 then
			szTip = szTip .. g_tStrings.STR_PASSWORD_RESETING..GetFormatText("\n")
			local szTime = GetTimeText(nLeftTime, false, true)
			szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_PASSWORD_RESET_TIME, szTime))
		end
	else
		szTip = GetString("STR_MINIMAP_CIPHERLOCK")
	end
	return szTip
end

local function GetMenuCurrentValue(hBtn)
	return hBtn:Lookup("", ""):Lookup(0).MenuValue
end

--===========BankPasswordSet==================================
BankPasswordSet = {}
local tLockSet_Config = 
{
	[SAFE_LOCK_EFFECT_TYPE.TRADE] = true, 
	[SAFE_LOCK_EFFECT_TYPE.AUCTION] = true, 
	[SAFE_LOCK_EFFECT_TYPE.SHOP] = true, 
	[SAFE_LOCK_EFFECT_TYPE.MAIL] = true, 
	[SAFE_LOCK_EFFECT_TYPE.TONG_DONATE] = true, 
	[SAFE_LOCK_EFFECT_TYPE.TONG_PAY_SALARY] = true, 
	[SAFE_LOCK_EFFECT_TYPE.EQUIP] = true, 
	[SAFE_LOCK_EFFECT_TYPE.BANK] = true, 
	[SAFE_LOCK_EFFECT_TYPE.TONG_REPERTORY] = true, 
}

function BankPasswordSet.OnFrameCreate()
	this:RegisterEvent("BANK_LOCK_RESPOND")
	this:RegisterEvent("UI_SCALED")
	
	BankPasswordSet.OnEvent("UI_SCALED")
	Station.SetFocusWindow(this:Lookup("Edit_Password0"))
	
	local text = this:Lookup("Btn_Quiz"):Lookup("", ""):Lookup(0)
	
	text.MenuValue = -1
	text:SetText(g_tStrings.STR_SELECT_QUESTION)
	
	this.nInitW, this.nInitH = this:GetSize()
	local hImage = this:Lookup("", "Image_BgTop")
	hImage.nInitW, hImage.nInitH = hImage:GetSize()
	
	local hList = this:Lookup("Wnd_Range", "Handle_Locks")
	hList:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Locks", "BankPasswordSet", true)
end

function BankPasswordSet.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "CENTER", 0, -300)
		
	elseif event == "BANK_LOCK_RESPOND" then
		local szResult = arg0
		if szResult == "SET_BANK_PASSWORD_SUCCESS" then
			CloseBankPasswordSet();
		end
	end
end

function BankPasswordSet.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard1" then
		OpenKeyboard(nil, "BankPasswordSet_CheckBox_Keyboard1")
		Station.SetFocusWindow(frame:Lookup("Edit_Password0"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard2"):Check(false)
		frame.bIniting = false
		
	elseif szName == "CheckBox_Keyboard2" then
		OpenKeyboard(nil, "BankPasswordSet_CheckBox_Keyboard2")
		Station.SetFocusWindow(frame:Lookup("Edit_Password1"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard1"):Check(false)
		frame.bIniting = false
	end
end

function BankPasswordSet.OnCheckBoxUncheck()
	if this:GetRoot().bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard1" then
		CloseKeyboard()
	elseif szName == "CheckBox_Keyboard2" then
		CloseKeyboard()
	end
end

function BankPasswordSet.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		local szPassword0 = "Topmost/BankPasswordSet/Edit_Password0"
		local szPassword1 = "Topmost/BankPasswordSet/Edit_Password1"
		if not IsPasswordSame(szPassword0, szPassword1) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BANK_PASSWORD_NOT_SAME)
			return
		end
		local frame = this:GetRoot()
		local nQuestionID = GetMenuCurrentValue(frame:Lookup("Btn_Quiz"))
		if nQuestionID == -1 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASSWORD_MUST_QUESTION)
			return
		end
		
		local szAnswer = frame:Lookup("Edit_Answer"):GetText()
		if not szAnswer or szAnswer == "" then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BANK_PASSWORD_QESTION)
			return 
		end
		
		if nQuestionID >= 1 and nQuestionID <= #g_tStrings.tBankQuestion then
			RemoteOperatePassword(tRemoteFun.Set, szPassword1, nQuestionID, szAnswer, tLockSet_Config)
		end
		
	elseif szName == "Btn_Cancel" then
		CloseBankPasswordSet()
	elseif szName == "Btn_Quiz" then
		local tData = {}
		for k, v in ipairs(g_tStrings.tBankQuestion) do
			table.insert(tData, {name=v, value=k})
		end
		PopupMenuEx(this, tData, IsBankPasswordSetOpened)
	end
end

function BankPasswordSet.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Image_RankTitle" then
		BankPasswordSet.bOpenIntroduce = not BankPasswordSet.bOpenIntroduce
		BankPasswordSet.AdjustSize(this:GetRoot())
	end
end

BankPasswordSet.bOpenIntroduce = true
function BankPasswordSet.AdjustSize(frame)
	local hRange = frame:Lookup("Wnd_Range")
	local hImage = frame:Lookup("", "Image_BgTop")
	local nWR, nHR = hRange:GetSize()
	if BankPasswordSet.bOpenIntroduce then
		hRange:Show()
		frame:SetSize(frame.nInitW, frame.nInitH)
		hImage:SetSize(hImage.nInitW, hImage.nInitH)
	else
		hRange:Hide()
		frame:SetSize(frame.nInitW, frame.nInitH - nHR + 30)
		hImage:SetSize(hImage.nInitW, hImage.nInitH - nHR + 30)
	end
	
	if BankPasswordSet.bOpenIntroduce then
		frame:Lookup("Wnd_Title", "Image_RankMinimize"):SetFrame(12)
	else
		frame:Lookup("Wnd_Title", "Image_RankMinimize"):SetFrame(8)
	end
	local nW, nH = frame:GetSize()
	local nX, nY = frame:GetAbsPos()
	frame:Lookup("Btn_OK"):SetAbsPos(nX + 73, nY + nH - 53);
	frame:Lookup("Btn_Cancel"):SetAbsPos(nX + nW - 165, nY + nH - 53);
end

local function TabFocusEdit(frame, tTabEdit)

	local focusEdit = Station.GetFocusWindow()
	local szName = nil
	if focusEdit then
		szName = focusEdit:GetName()
	end
				
	local nIndex = -1
	local nSize = #tTabEdit
	for k, v in ipairs(tTabEdit) do
		if v == szName then
			nIndex = k + 1
			if nIndex > nSize then
				nIndex = 1
			end
			break;
		end
	end
	if nIndex == -1 then
		nIndex = 1
	end
	
	local edit = frame:Lookup(tTabEdit[nIndex]);
	edit:SelectAll()
	Station.SetFocusWindow(edit)
end

function BankPasswordSet.OnEditSpecialKeyDown()
    local tTabEdit = 
    {
        "Edit_Password0",
        "Edit_Password1",
		"Edit_Answer",
    }
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szKey == "Tab" then
		TabFocusEdit(this:GetRoot(), tTabEdit)
		return 1
	elseif szKey == "Enter" then
		return BankPasswordSet.OnFrameKeyDown()
	end
	
	return 0
end

function BankPasswordSet.OnFrameKeyDown()
    local tTabEdit = 
    {
        "Edit_Password0",
        "Edit_Password1",
		"Edit_Answer",
    }
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		local btn  =  this:GetRoot():Lookup("Btn_OK")
		local thisSave = this
		this = btn
		if btn:IsEnabled() then
			BankPasswordSet.OnLButtonClick()
		end
		this = thisSave
		return 1
	
	elseif szKey == "Tab" then 
		TabFocusEdit(this, tTabEdit)
		return 1
	end
	return 0
end

function IsBankPasswordSetOpened()
	local frame = Station.Lookup("Topmost/BankPasswordSet")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenBankPasswordSet(bDisableSound)
	if IsBankPasswordSetOpened() then
		return
	end
	
	CloseBankUnlock()
	CloseBankForgetPassword();
	Wnd.OpenWindow("BankPasswordSet")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseBankPasswordSet(bDisableSound)
	if not IsBankPasswordSetOpened() then
		return
	end
	CloseKeyboard()
	CloseModifyPassword()
	Wnd.CloseWindow("BankPasswordSet")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

--================BankForgetPassword==============================================

BankForgetPassword = {}

function BankForgetPassword.OnFrameCreate()
	this:RegisterEvent("BANK_LOCK_RESPOND")
	this:RegisterEvent("UI_SCALED")
	
	BankForgetPassword.OnEvent("UI_SCALED")
	
	Station.SetFocusWindow(this:Lookup("Edit_Answer"))
	
	local nBankPasswordQuestionID = GetClientPlayer().nBankPasswordQuestionID
	if nBankPasswordQuestionID == 0 then
		CloseBankForgetPassword()
	end
	
	local hBtn = this:Lookup("Btn_Quiz")
	local text = hBtn:Lookup("", ""):Lookup(0)
	hBtn:Enable(false)
	text.MenuValue = nBankPasswordQuestionID
	text:SetText(g_tStrings.tBankQuestion[nBankPasswordQuestionID])
end

function BankForgetPassword.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "CENTER", 0, -300)
	elseif event == "BANK_LOCK_RESPOND" then
		local szResult = arg0
		if szResult == "MODIFY_BANK_PASSWORD_SUCCESS" then
			CloseBankForgetPassword();
		end
	end
end

function BankForgetPassword.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		local szPassword0 = "Topmost/BankForgetPassword/Edit_Password0"
		local szPassword1 = "Topmost/BankForgetPassword/Edit_Password1"
		if not IsPasswordSame(szPassword0, szPassword1) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BANK_PASSWORD_NOT_SAME)
			return
		end
		local frame = this:GetRoot()
		local szAnswer = frame:Lookup("Edit_Answer"):GetText()
		if szAnswer == nil or szAnswer == "" then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BANK_PASSWORD_QESTION)
			return 
		end
		
		local nQuestionID = GetMenuCurrentValue(frame:Lookup("Btn_Quiz"))
		if nQuestionID >= 1 and nQuestionID <= #g_tStrings.tBankQuestion then
			RemoteOperatePassword(tRemoteFun.Modify, szAnswer, szPassword1)
		end
		
	elseif szName == "Btn_Cancel" then
		CloseBankForgetPassword()
	elseif szName == "Btn_Quiz" then
		local tData = {}
		for k, v in ipairs(g_tStrings.tBankQuestion) do
			table.insert(tData, {name=v, value=k})
		end
		PopupMenuEx(this, tData, IsBankForgetPasswordOpened)
		return true
	elseif szName == "Btn_Reset" then
		RemoteCallToServer(tRemoteFun.Reset)
		CloseBankForgetPassword()
	end
end

function BankForgetPassword.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard1" then
		OpenKeyboard(nil, "BankForgetPassword_CheckBox_Keyboard1")
		Station.SetFocusWindow(frame:Lookup("Edit_Password0"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard2"):Check(false)
		frame.bIniting = false
		
	elseif szName == "CheckBox_Keyboard2" then
		OpenKeyboard(nil, "BankForgetPassword_CheckBox_Keyboard2")
		Station.SetFocusWindow(frame:Lookup("Edit_Password1"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard1"):Check(false)
		frame.bIniting = false
	end
end

function BankForgetPassword.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard1" then
		CloseKeyboard()
	elseif szName == "CheckBox_Keyboard2" then
		CloseKeyboard()
	end
end

function BankForgetPassword.OnEditSpecialKeyDown()
    local tTabEdit = 
    {
		"Edit_Answer",
        "Edit_Password0",
        "Edit_Password1",
    }
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szKey == "Tab" then
		TabFocusEdit(this:GetRoot(), tTabEdit)
		return 1
	elseif szKey == "Enter" then
		return BankForgetPassword.OnFrameKeyDown()
	end
	
	return 0
end

function BankForgetPassword.OnFrameKeyDown()
    local tTabEdit = 
    {
		"Edit_Answer",
        "Edit_Password0",
        "Edit_Password1",
    }
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		local btn  =  this:GetRoot():Lookup("Btn_OK")
		local thisSave = this
		this = btn
		if btn:IsEnabled() then
			BankForgetPassword.OnLButtonClick()
		end
		this = thisSave
		return 1
	
	elseif szKey == "Tab" then 
		TabFocusEdit(this, tTabEdit)
		return 1
	end
	return 0
end

function IsBankForgetPasswordOpened()
	local frame = Station.Lookup("Topmost/BankForgetPassword")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenBankForgetPassword(bDisableSound)
	if IsBankForgetPasswordOpened() then
		return
	end
	
	CloseKeyboard()
	CloseBankUnlock()
	CloseBankPasswordSet()
	CloseModifyPassword()
	Wnd.OpenWindow("BankForgetPassword")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end


function CloseBankForgetPassword(bDisableSound)
	if not IsBankForgetPasswordOpened() then
		return
	end
	CloseKeyboard()
	Wnd.CloseWindow("BankForgetPassword")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

--==================BankUnlocking============================================

BankUnlock = {nResetEndTime = 0}

function BankUnlock.OnFrameCreate()
	this:RegisterEvent("BANK_LOCK_RESPOND")
	this:RegisterEvent("UI_SCALED")
	
	BankUnlock.OnEvent("UI_SCALED")
	
	BankUnlock.UpdateState(this)
	Station.SetFocusWindow(this:Lookup("Edit_Password"))
	
	BankUnlock.Init(this)
end

function BankUnlock.Init(frame)
	BankUnlock.bOpenIntroduce = false
	frame.nInitW, frame.nInitH = frame:GetSize()
	local hImage = frame:Lookup("", "Image_BgTop")
	hImage.nInitW, hImage.nInitH = hImage:GetSize()
	
	--frame:Lookup("Wnd_Range"):Hide()
	BankUnlock.AdjustSize(frame)
	
	local hList = frame:Lookup("Wnd_Range", "Handle_Locks")
	hList:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_Locks", "BankUnlock", true)
end

function BankUnlock.OnFrameBreathe()
	if not this.nCount or this.nCount == 8 then
		this.nCount = 0
	end
	
	if this.nCount == 0 and BankUnlock.nResetEndTime > 0 then
		local nLeftTime = BankUnlock.nResetEndTime - GetCurrentTime();
		if nLeftTime > 0 then
			local szTime = GetTimeText(nLeftTime, false, true)
			this:Lookup("", "Text_Information"):SetText(FormatString(g_tStrings.STR_PASSWORD_RESET_TIME, szTime))
		else
			CloseBankUnlock()
		end
	end
	this.nCount = this.nCount + 1
end

function BankUnlock.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "CENTER", 0, -300)
	elseif event == "BANK_LOCK_RESPOND" then
		--PASSWORD_CANNOT_BE_EMPTY
		--VERIFY_BANK_PASSWORD_SUCCESS
		--VERIFY_Bank_PASSWORD_FAILED
		local szResult = arg0
		if szResult == "VERIFY_BANK_PASSWORD_SUCCESS" then
			CloseBankUnlock();
		elseif szResult == "CANCEL_RESET_BANK_PASSWORD_SUCCESS" then
			BankUnlock.UpdateState(this)
		elseif szResult == "RESET_BANK_PASSWORD_SUCCESS" then
			BankUnlock.UpdateState(this)
		end
	
	end
end

function BankUnlock.UpdateState(frame)
	BankUnlock.nResetEndTime = 0
	local player = GetClientPlayer()
	local nLeftTime = player.nBankPasswordResetEndTime - GetCurrentTime()
	local hBtn = frame:Lookup("Btn_CancelReset")
	
	frame:Lookup("Btn_ForgetPassword"):Enable(player.nBankPasswordQuestionID ~= 0)
	
	if nLeftTime > 0 then
		BankUnlock.nResetEndTime = player.nBankPasswordResetEndTime
		local szTime = GetTimeText(nLeftTime, false, true)
		frame:Lookup("", "Text_Information"):SetText(FormatString(g_tStrings.STR_PASSWORD_RESET_TIME, szTime))
		hBtn:Lookup("", ""):Lookup(0):SetText(GetString("STR_CANCEL_RESET"))
		hBtn.bCanCancel = true
		frame:Lookup("Btn_OK"):Enable(false)
		frame:Lookup("Btn_ForgetPassword"):Enable(false)
	else
		frame:Lookup("", "Text_Information"):SetText("")
		hBtn:Lookup("", ""):Lookup(0):SetText(GetString("STR_RESET_PASSWORD"))
		hBtn.bCanCancel = false
		frame:Lookup("Btn_OK"):Enable(true)
	end
end

function BankUnlock.AdjustSize(frame)
	local hRange = frame:Lookup("Wnd_Range")
	local hImage = frame:Lookup("", "Image_BgTop")
	local nWR, nHR = hRange:GetSize()
	if BankUnlock.bOpenIntroduce then
		hRange:Show()
		frame:SetSize(frame.nInitW, frame.nInitH)
		hImage:SetSize(hImage.nInitW, hImage.nInitH)
	else
		hRange:Hide()
		frame:SetSize(frame.nInitW, frame.nInitH - nHR + 30)
		hImage:SetSize(hImage.nInitW, hImage.nInitH - nHR + 30)
	end
	
	if BankUnlock.bOpenIntroduce then
		frame:Lookup("Wnd_Title", "Image_RankMinimize"):SetFrame(12)
	else
		frame:Lookup("Wnd_Title", "Image_RankMinimize"):SetFrame(8)
	end
	local nW, nH = frame:GetSize()
	local nX, nY = frame:GetAbsPos()
	frame:Lookup("Btn_OK"):SetAbsPos(nX + 73, nY + nH - 53);
	frame:Lookup("Btn_Cancel"):SetAbsPos(nX + nW - 165, nY + nH - 53);
end

function BankUnlock.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Image_RankTitle" then
		BankUnlock.bOpenIntroduce = not BankUnlock.bOpenIntroduce
		BankUnlock.AdjustSize(this:GetRoot())
	end
end

function BankUnlock.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		local szPassword = "Topmost/BankUnlock/Edit_Password"
		RemoteOperatePassword(tRemoteFun.Verify, szPassword)
		
		--CloseBankUnlock()
	elseif szName == "Btn_Cancel" then
		CloseBankUnlock()
		
	elseif szName == "Btn_ForgetPassword" then
		OpenBankForgetPassword()
		
	elseif szName == "Btn_CancelReset" then
		if this.bCanCancel then
			RemoteCallToServer("OnCancelResetBankPassword")
		else
			RemoteCallToServer("OnResetBankPassword")
		end
	end
end

function BankUnlock.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard" then
		OpenKeyboard(nil, "BankUnlock_CheckBox_Keyboard")
		Station.SetFocusWindow(this:GetRoot():Lookup("Edit_Password"))
	end
end

function BankUnlock.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard" then
		CloseKeyboard()
	end
end


function BankUnlock.OnEditSpecialKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szName == "Edit_Password" then
		if szKey == "Enter" then
			return BankUnlock.OnFrameKeyDown()
		end
	end
	
	return 0
end

function BankUnlock.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		local btn  =  this:GetRoot():Lookup("Btn_OK")
		local thisSave = this
		this = btn
		if btn:IsEnabled() then
			BankUnlock.OnLButtonClick()
		end
		this = thisSave
		return 1
	end
	return 0
end
	
function IsBankUnlockOpened()
	local frame = Station.Lookup("Topmost/BankUnlock")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenBankUnlock(bDisableSound)
	if IsBankUnlockOpened() then
		return
	end
	
	CloseBankPasswordChoice()
	CloseBankForgetPassword()
	CloseBankPasswordSet()
	CloseModifyPassword();
	Wnd.OpenWindow("BankUnlock")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end


function CloseBankUnlock(bDisableSound)
	if not IsBankUnlockOpened() then
		return
	end
	
	CloseKeyboard()
	Wnd.CloseWindow("BankUnlock")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

--==================BankUnlocking end============================================

--==================ModifyPassword ============================================

ModifyPassword = {}

function ModifyPassword.Init(frame)
	Station.SetFocusWindow(frame:Lookup("Edit_OldPassword"))
	
	local text = frame:Lookup("Btn_Quiz"):Lookup("", ""):Lookup(0)
	
	text.MenuValue = -1
	text:SetText(g_tStrings.STR_SELECT_QUESTION)
end

function ModifyPassword.OnFrameCreate()
	this:RegisterEvent("BANK_LOCK_RESPOND")
	this:RegisterEvent("UI_SCALED")
	
	ModifyPassword.OnEvent("UI_SCALED")
	
	ModifyPassword.Init(this)
end

function ModifyPassword.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPCENTER", 0, 0, "CENTER", 0, -300)
		
	elseif event == "BANK_LOCK_RESPOND" then
		local szResult = arg0
		if szResult == "MODIFY_BANK_PASSWORD_SUCCESS" then
			CloseModifyPassword();
		end
	end
end

function ModifyPassword.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		local frame = this:GetRoot()
		local szOldPassword = "Topmost/ModifyPassword/Edit_OldPassword"
		local szNewPassword = "Topmost/ModifyPassword/Edit_Password"
		local szNewPassword1 = "Topmost/ModifyPassword/Edit_Confirmation"
		local szAnswer = frame:Lookup("Edit_Answer"):GetText()
		local nQuestionID = GetMenuCurrentValue(frame:Lookup("Btn_Quiz"))
		
		if not IsPasswordSame(szNewPassword, szNewPassword1) then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BANK_PASSWORD_NOT_SAME)
			return
		end
		
		if nQuestionID == -1 then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASSWORD_MUST_QUESTION)
			return
		end
		
		if nQuestionID >=1 and nQuestionID <= #g_tStrings.tBankQuestion then
			RemoteOperatePassword(tRemoteFun.ModifyInfo, szOldPassword, nQuestionID, szAnswer, szNewPassword)
			--CloseModifyPassword();
		end
	elseif szName == "Btn_Cancel" then
		CloseModifyPassword()
	elseif szName == "Btn_Quiz" then
		local tData = {}
		for k, v in ipairs(g_tStrings.tBankQuestion) do
			table.insert(tData, {name=v, value=k})
		end
		PopupMenuEx(this, tData, IsModifyPasswordOpened)
		return true
	end
end

function ModifyPassword.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard1" then
		OpenKeyboard(nil, "ModifyPassword_CheckBox_Keyboard1")
		Station.SetFocusWindow(frame:Lookup("Edit_OldPassword"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard2"):Check(false)
		frame:Lookup("CheckBox_Keyboard3"):Check(false)
		frame.bIniting = false
		
	elseif szName == "CheckBox_Keyboard2" then
		OpenKeyboard(nil, "ModifyPassword_CheckBox_Keyboard2")
		Station.SetFocusWindow(frame:Lookup("Edit_Password"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard1"):Check(false)
		frame:Lookup("CheckBox_Keyboard3"):Check(false)
		frame.bIniting = false
	elseif szName == "CheckBox_Keyboard3" then
		OpenKeyboard(nil, "ModifyPassword_CheckBox_Keyboard3")
		Station.SetFocusWindow(frame:Lookup("Edit_Confirmation"))
		
		frame.bIniting = true
		frame:Lookup("CheckBox_Keyboard1"):Check(false)
		frame:Lookup("CheckBox_Keyboard2"):Check(false)
		frame.bIniting = false
	end
end

function ModifyPassword.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_Keyboard1" then
		CloseKeyboard()
	elseif szName == "CheckBox_Keyboard2" then
		CloseKeyboard()
	end
end

function ModifyPassword.OnEditSpecialKeyDown()
    local tTabEdit = 
    {
		"Edit_OldPassword",
		"Edit_Password",
		"Edit_Confirmation",
        "Edit_Answer",
    }
	local szKey = GetKeyName(Station.GetMessageKey())
	local szName = this:GetName()
	if szKey == "Tab" then
		TabFocusEdit(this:GetRoot(), tTabEdit)
		return 1
	elseif szKey == "Enter" then
		return ModifyPassword.OnFrameKeyDown()
	end
	
	return 0
end

function ModifyPassword.OnFrameKeyDown()
    local tTabEdit = 
    {
		"Edit_OldPassword",
		"Edit_Password",
        "Edit_Answer",
    }
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Enter" then
		local btn  =  this:GetRoot():Lookup("Btn_OK")
		local thisSave = this
		this = btn
		if btn:IsEnabled() then
			ModifyPassword.OnLButtonClick()
		end
		this = thisSave
		return 1
	
	elseif szKey == "Tab" then 
		TabFocusEdit(this, tTabEdit)
		return 1
	end
	return 0
end

function IsModifyPasswordOpened()
	local frame = Station.Lookup("Topmost/ModifyPassword")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenModifyPassword(bDisableSound)
	if IsModifyPasswordOpened() then
		return
	end
	
	CloseBankPasswordChoice()
	CloseKeyboard()
	CloseBankForgetPassword()
	CloseBankPasswordSet()
	CloseBankUnlock()
	Wnd.OpenWindow("ModifyPassword")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end


function CloseModifyPassword(bDisableSound)
	if not IsModifyPasswordOpened() then
		return
	end
	
	CloseKeyboard()
	Wnd.CloseWindow("ModifyPassword")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

--============BankPasswordChoice===============================================
local tLockChoice_Config = 
{
	[SAFE_LOCK_EFFECT_TYPE.TRADE] = true, 
	[SAFE_LOCK_EFFECT_TYPE.AUCTION] = true, 
	[SAFE_LOCK_EFFECT_TYPE.SHOP] = false, 
	[SAFE_LOCK_EFFECT_TYPE.MAIL] = true, 
	[SAFE_LOCK_EFFECT_TYPE.TONG_DONATE] = true, 
	[SAFE_LOCK_EFFECT_TYPE.TONG_PAY_SALARY] = true, 
	[SAFE_LOCK_EFFECT_TYPE.EQUIP] = true, 
	[SAFE_LOCK_EFFECT_TYPE.BANK] = true, 
	[SAFE_LOCK_EFFECT_TYPE.TONG_REPERTORY] = true, 
}

BankPasswordChoice = {}
BankPasswordChoice.bModify = false
function BankPasswordChoice.OnFrameCreate()

	BankPasswordChoice.Init(this)
end

function BankPasswordChoice.Init(frame)
	BankPasswordChoice.bModify = false
	
	--local player = GetClientPlayer()
	--Output(player.GetSafeLockMaskInfo())
	local state = LockChoice_State(SAFE_LOCK_EFFECT_TYPE.SHOP)
	local hWnd = frame:Lookup("Wnd_Range")
	if state == "CHOICE_LOCK_SELECT" then
		tLockChoice_Config[SAFE_LOCK_EFFECT_TYPE.SHOP] = true
		hWnd:Lookup("", "Animate_ShopOn"):Show()
		hWnd:Lookup("", "Animate_ShopOff"):Hide()
	else
		tLockChoice_Config[SAFE_LOCK_EFFECT_TYPE.SHOP] = false
		hWnd:Lookup("", "Animate_ShopOn"):Hide()
		hWnd:Lookup("", "Animate_ShopOff"):Show()
	end
end

function BankPasswordChoice.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_OK" then
		if BankPasswordChoice.bModify then
			RemoteCallToServer(tRemoteFun.ModifyChoice, tLockChoice_Config)
		end
		CloseBankPasswordChoice();
	elseif szName == "Btn_Cancel" then
		CloseBankPasswordChoice();
	end
end

function BankPasswordChoice.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Animate_ShopOff" then
		local state = Lock_State()
		if state ~= "PASSWORD_UNLOCK" then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_NEED_UNLOCK)
			return
		end
		
		local hShopOn = this:GetParent():Lookup("Animate_ShopOn")
		hShopOn:Show()
		this:Hide()
		
		tLockChoice_Config[SAFE_LOCK_EFFECT_TYPE.SHOP] = true
		BankPasswordChoice.bModify = true
	elseif szName == "Animate_ShopOn" then
		local state = Lock_State()
		if state ~= "PASSWORD_UNLOCK" then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_NEED_UNLOCK)
			return
		end
		
		local hShopOff = this:GetParent():Lookup("Animate_ShopOff")
		hShopOff:Show()
		this:Hide()
		tLockChoice_Config[SAFE_LOCK_EFFECT_TYPE.SHOP] = false
		BankPasswordChoice.bModify = true
	end
end

function IsBankPasswordChoiceOpened()
	local frame = Station.Lookup("Topmost/BankPasswordChoice")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenBankPasswordChoice(bDisableSound)
	if IsBankPasswordChoiceOpened() then
		return
	end
	
	CloseModifyPassword()
	CloseBankUnlock()
	Wnd.OpenWindow("BankPasswordChoice")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end


function CloseBankPasswordChoice(bDisableSound)
	if not IsBankPasswordChoiceOpened() then
		return
	end
	
	Wnd.CloseWindow("BankPasswordChoice")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end
--==================ModifyPassword end============================================

local function OnBackLockRespond(szEvent)

	if szEvent == "PASSWORD_EXIST" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASSWORD_EXIST)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASSWORD_EXIST.."\n")
		
	elseif szEvent == "PASSWORD_CANNOT_BE_EMPTY" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASWORD_EMPTY)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASWORD_EMPTY.."\n")
		
	elseif szEvent == "SET_BANK_PASSWORD_SUCCESS" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_PASWORD_SET_SUCCESS)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASWORD_SET_SUCCESS.."\n")
		
	elseif szEvent == "SET_BANK_PASSWORD_FAILED" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASWORD_SET_FAIL)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASWORD_SET_FAIL.."\n")
		
	elseif szEvent == "RESET_BANK_PASSWORD_SUCCESS" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_PASWORD_RETSET_SUCCESS)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASWORD_RETSET_SUCCESS.."\n")
		
	elseif szEvent == "CANCEL_RESET_BANK_PASSWORD_SUCCESS" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_CANCEL_RETSET_SUCCESS)
		OutputMessage("MSG_SYS", g_tStrings.STR_CANCEL_RETSET_SUCCESS.."\n")
		
	elseif szEvent == "VERIFY_BANK_PASSWORD_SUCCESS" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_PASWORD_VERIFY_SUCCESS)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASWORD_VERIFY_SUCCESS.."\n")
		
	elseif szEvent == "VERIFY_BANK_PASSWORD_FAILED" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASWORD_VERIFY_FAIL)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASWORD_VERIFY_FAIL.."\n")
		
	elseif szEvent == "MODIFY_BANK_PASSWORD_SUCCESS" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_PASSWORD_MODIFY_SUCCESS)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASSWORD_MODIFY_SUCCESS.."\n")
		
	elseif szEvent == "BANK_PASSWORD_ANSWER_IS_WRONG" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASSWORD_MODIFY_FAILED)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASSWORD_MODIFY_FAILED.."\n")
		
	elseif szEvent == "VERIFY_BANK_PASSWORD_FAILED" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_PASSWORD_INFO_MODIFY_FAILED)
		OutputMessage("MSG_SYS", g_tStrings.STR_PASSWORD_INFO_MODIFY_FAILED.."\n")
		
	elseif szEvent == "ANSWER_CANNOT_BE_EMPTY" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_BANK_PASSWORD_QESTION)
		OutputMessage("MSG_SYS", g_tStrings.STR_BANK_PASSWORD_QESTION.."\n")
	
	elseif szEvent == "NEED_UNLOCK_FIRST" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CHOICE_ERROR_UNLOCK)
		OutputMessage("MSG_SYS", g_tStrings.STR_CHOICE_ERROR_UNLOCK.."\n")
	
	elseif szEvent == "SET_OPTION_SUCCESS" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_CHOICE_MODIFY_SUCCESS)
		OutputMessage("MSG_SYS", g_tStrings.STR_CHOICE_MODIFY_SUCCESS.."\n")
		
	elseif szEvent == "UNLOCK_TIME_LIMIT" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_TIME_UNLOCK)
		OutputMessage("MSG_SYS", g_tStrings.STR_TIME_UNLOCK.."\n")
	end
end
RegisterAutoClose_Topmost("BankPasswordSet", IsBankPasswordSetOpened, CloseBankPasswordSet)
RegisterAutoClose_Topmost("BankForgetPassword", IsBankForgetPasswordOpened, CloseBankForgetPassword)
RegisterAutoClose_Topmost("BankUnlock", IsBankUnlockOpened, CloseBankUnlock)
RegisterAutoClose_Topmost("ModifyPassword", IsModifyPasswordOpened, CloseModifyPassword)

RegisterEvent("BANK_LOCK_RESPOND", function() OnBackLockRespond(arg0) end)
Keyboard_Register("BankPasswordSet_".."CheckBox_Keyboard1", "Topmost/BankPasswordSet/Edit_Password0")
Keyboard_Register("BankPasswordSet_".."CheckBox_Keyboard2", "Topmost/BankPasswordSet/Edit_Password1")
Keyboard_Register("BankForgetPassword_".."CheckBox_Keyboard1", "Topmost/BankForgetPassword/Edit_Password0")
Keyboard_Register("BankForgetPassword_".."CheckBox_Keyboard2", "Topmost/BankForgetPassword/Edit_Password1")

Keyboard_Register("ModifyPassword_".."CheckBox_Keyboard1", "Topmost/ModifyPassword/Edit_OldPassword")
Keyboard_Register("ModifyPassword_".."CheckBox_Keyboard2", "Topmost/ModifyPassword/Edit_Password")
Keyboard_Register("ModifyPassword_".."CheckBox_Keyboard3", "Topmost/ModifyPassword/Edit_Confirmation")
Keyboard_Register("BankUnlock_".."CheckBox_Keyboard", "Topmost/BankUnlock/Edit_Password")

do
    RegisterScrollEvent("BankPasswordSet")
    
    UnRegisterScrollAllControl("BankPasswordSet")
        
    local szFramePath = "Topmost/BankPasswordSet"
    local szWndPath = "Wnd_Range"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_UpDis", szWndPath.."/Btn_DownDis", 
        szWndPath.."/Scroll_Dis", 
        {szWndPath, "Handle_Locks"})
		
	RegisterScrollEvent("BankUnlock")
    
    UnRegisterScrollAllControl("BankUnlock")
	
	szFramePath = "Topmost/BankUnlock"
    szWndPath = "Wnd_Range"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_UpDis", szWndPath.."/Btn_DownDis", 
        szWndPath.."/Scroll_Dis", 
        {szWndPath, "Handle_Locks"})
end