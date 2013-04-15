UserActionChoose = {}

function UserActionChoose.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	UserActionChoose.UpdatePos(this)
	--[[
	local bMouseMove = IsMouseMove()
	this:Lookup("CheckBox_Mouse"):Check(bMouseMove)
	this:Lookup("CheckBox_KeyBoard"):Check(false)
	
	if not bMouseMove then
		this:Lookup("CheckBox_KeyBoard"):Check(true)
	end
	--]]
end

function UserActionChoose.OnCheckBoxCheck()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "CheckBox_KeyBoard" then
		hFrame:Lookup("CheckBox_Mouse"):Check(false)
	elseif szName == "CheckBox_Mouse" then
		hFrame:Lookup("CheckBox_KeyBoard"):Check(false)
	end
end

function UserActionChoose.OnLButtonClick()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	local hCheckMouse = hFrame:Lookup("CheckBox_Mouse")
	
	if szName == "Btn_Sure" then
		--SetMouseMove(hCheckMouse:IsCheckBoxChecked())
		CloseUserActionChoose()
	end
end

function UserActionChoose.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		UserActionChoose.UpdatePos(this)
	end
end

function UserActionChoose.UpdatePos(hFrame)
	hFrame:SetPoint("CENTER", 0, 0, "CENTER", -200, 50)
end

function OpenUserActionChoose(bDisableSound)
	if IsUserActionChooseOpened() then
		return
	end
	Wnd.OpenWindow("UserActionChoose")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsUserActionChooseOpened()
	local hFrame = Station.Lookup("Normal/UserActionChoose")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	return false
end

function CloseUserActionChoose(bDisableSound)
	if not IsUserActionChooseOpened() then
		return
	end
	Wnd.CloseWindow("UserActionChoose")
	FireHelpEvent("OnClosePanel", "UserActionChoose")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end