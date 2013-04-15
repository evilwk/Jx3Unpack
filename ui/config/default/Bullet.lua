Bullet = {}
Bullet.dwBulletTabType = 6
Bullet.dwBulletIndex = 4000
Bullet.bShowPanel = true

Bullet.aItem = 
{
	["NUO_JIAN"] = {dwTabType = 6, dwIndex=4000}, --åó¼ý
	["JI_GUAN"] = {dwTabType = 6, dwIndex=4014}, --»ú¹Ø
}

Bullet.DefaultAnchor = {s = "CENTER", r = "CENTER",  x = -140, y = 50}
Bullet.Anchor = {s = "CENTER", r = "CENTER", x = -140, y =50}
	
RegisterCustomData("Bullet.Anchor")
RegisterCustomData("Bullet.bShowPanel")

local tBulletInfo

local hFrame
local hAnimateBullet
local hAnimateNoBullet
local aBulletText = {}

local function IsBulletItem(dwTabType, dwIndex, szType)
	local aItem = Bullet.aItem[szType]
	if not aItem then
		return false
	end
	
	if dwTabType == aItem.dwTabType and dwIndex == aItem.dwIndex then
		return true
	end
	return false
end

function SetBulletShow(bShow)
	Bullet.bShowPanel = bShow
end

function IsCanBulletShow()
	local player = GetClientPlayer()
	local Kungfu = player.GetKungfuMount()
	if Kungfu and Kungfu.dwMountType == 10 and IsCanWeaponBagOpen() then -- ÌÆÃÅ
		return true
	end
	return false
end

function Bullet.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("BULLET_ANCHOR_CHANGED")
	this:RegisterEvent("BULLET_COST_ONE")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("EXCHANGE_ITEM")
	this:RegisterEvent("BULLET_UPDATE_STATE")
	this:RegisterEvent("DESTROY_ITEM")
	
	Bullet.InitBullet()
	
	Bullet.UpdateAnchor(this)
	UpdateCustomModeWindow(this, "", false)	
end

function Bullet.InitBullet()
	tBulletInfo = {}
	local player = GetClientPlayer()
	Bullet.aBulletCount = {}
	Bullet.aBulletCount["NUO_JIAN"] = 0
	Bullet.aBulletCount["JI_GUAN"] = 0
	local nBoxSize = player.GetBoxSize(INVENTORY_INDEX.BULLET_PACKAGE)
	for i=1, nBoxSize, 1 do
		tBulletInfo[i-1] = {nStackNum = 0}
		local item = GetPlayerItem(player, INVENTORY_INDEX.BULLET_PACKAGE, i - 1)
		if item then
			tBulletInfo[i-1].dwTabType = item.dwTabType
			tBulletInfo[i-1].dwIndex = item.dwIndex
			tBulletInfo[i-1].nStackNum = item.nStackNum
			
			for szType, _ in pairs(Bullet.aItem) do
				if IsBulletItem(item.dwTabType, item.dwIndex, szType) then
					Bullet.aBulletCount[szType] = Bullet.aBulletCount[szType] + item.nStackNum
					break
				end
			end
		end
	end
		
	hAnimateBullet = this:Lookup("", "Animate_Bullet")
	hAnimateNoBullet = this:Lookup("", "Animate_Not")
	aBulletText["NUO_JIAN"] = this:Lookup("", "Text_Bullet")
	aBulletText["JI_GUAN"] = this:Lookup("", "Text_BulletJG")
	
	hAnimateBullet:SetLoopCount(1)
	hAnimateNoBullet:Hide()
	hAnimateNoBullet.nW, hAnimateNoBullet.nH = hAnimateNoBullet:GetSize()
	Bullet.UpdateState()
end

function Bullet.OnEvent(event)
	if event == "UI_SCALED" then
		Bullet.UpdateAnchor(this)
	elseif event == "BULLET_COST_ONE" then
		Bullet.PlayAnimate()

	elseif event == "EXCHANGE_ITEM" then
		if arg0 == INVENTORY_INDEX.BULLET_PACKAGE or arg2 == INVENTORY_INDEX.BULLET_PACKAGE then
			Bullet.UpdateState()
		end
	elseif event == "DESTROY_ITEM" then
		if arg0 == INVENTORY_INDEX.BULLET_PACKAGE then
			Bullet.UpdateState()
		end
		
	elseif event == "BULLET_UPDATE_STATE" then
		 Bullet.UpdateState()
		
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, "", false)
	elseif event == "BULLET_ANCHOR_CHANGED" then
		Bullet.UpdateAnchor(this)
	end
end

function Bullet.OnFrameDragEnd()
	this:CorrectPos()
	Bullet.Anchor = GetFrameAnchor(this)
end

function Bullet.UpdateAnchor(frame)
	frame:SetPoint(Bullet.Anchor.s, 0, 0, Bullet.Anchor.r, Bullet.Anchor.x, Bullet.Anchor.y)
	frame:CorrectPos()
end

function Bullet.IsShowRedTip()
	if Bullet.aBulletCount["NUO_JIAN"] == 0 then
		local kungfu = GetClientPlayer().GetKungfuMount()
		if kungfu.dwSkillID == 10224 then
			return true
		end
	end
	
	if Bullet.aBulletCount["JI_GUAN"] == 0 then
		local kungfu = GetClientPlayer().GetKungfuMount()
		if kungfu.dwSkillID == 10225 then
			return true
		end
	end
	
	return false;
end

function Bullet.UpdateState()
	hAnimateNoBullet:Hide()
	hAnimateNoBullet:SetSize(0, 0)
	
	if Bullet.IsShowRedTip() then
		hAnimateNoBullet:Show()
		hAnimateNoBullet:SetSize(hAnimateNoBullet.nW, hAnimateNoBullet.nH)
	end
		
	for szType, nValue in pairs(Bullet.aBulletCount) do
		aBulletText[szType]:SetText(g_tStrings.STR_TM_BULLET[szType]..g_tStrings.STR_COLON..nValue)
		--[[
		if nValue == 0 then
			aBulletText[szType]:SetFontScheme(137)
		else
			aBulletText[szType]:SetFontScheme(27)
		end
		]]
	end
end

function Bullet.PlayAnimate()
	hAnimateBullet:Replay()
end

function Bullet.GetBulletCount(szType)
	local nTotalBullet = 0
	local player = GetClientPlayer()
	local nBoxSize = player.GetBoxSize(INVENTORY_INDEX.BULLET_PACKAGE)
	for i=1, nBoxSize, 1 do
		local item = GetPlayerItem(player, INVENTORY_INDEX.BULLET_PACKAGE, i - 1)
		if item and IsBulletItem(item.dwTabType, item.dwIndex, szType) then
			nTotalBullet = nTotalBullet + item.nStackNum
		end
	end
	return nTotalBullet
end

function Bullet.OnLButtonClick()
	local szName = this:GetName()

end

function Bullet.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Animate_Bullet" or szName == "Animate_Not" then
		if not IsCanWeaponBagOpen() then
			return
		end
		if not IsWeaponBagOpen() then
			OpenWeaponBag()
		else
			CloseWeaponBag()
		end
	end
end

function Bullet.OnItemRButtonClick()
	Bullet.OnItemLButtonClick()
end

function Bullet.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Animate_Not" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
				
		local szTip = ""
		for szType, nValue in pairs(Bullet.aBulletCount) do
			if nValue == 0 then
				if szTip ~= "" then
					szTip =  szTip .. g_tStrings.STR_PAUSE
				end
				szTip = szTip .. g_tStrings.STR_TM_BULLET[szType]
			end
		end
		szTip = FormatString(g_tStrings.STR_ADD_BULLET, szTip)
		OutputTip(GetFormatText(szTip), 400, {x, y, w, h})
	end
end

function Bullet.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Animate_Not" then
		HideTip()
	end
end

function IsBulletOpen()
	local hFrame = Station.Lookup("Normal/Bullet")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function OpenBullet()
	if IsBulletOpen() then
		return
	end

	hFrame = Wnd.OpenWindow("Bullet")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseBullet()
	if not IsBulletOpen() then
		return
	end
	
	Wnd.CloseWindow("Bullet")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local function OnBulletBackupItemUpdate()
	if arg0 == INVENTORY_INDEX.BULLET_PACKAGE and tBulletInfo then
		local dwX = arg1
		local player = GetClientPlayer()
		local tInfo = tBulletInfo[dwX]
		local item = GetPlayerItem(player, INVENTORY_INDEX.BULLET_PACKAGE, dwX)
		local nDeltaNJ = 0
		local nDeltaJG = 0
		local aDelta = {}
		if item then 
			local function fn(szType)
				local nItemCount = 0
				local nDelta = 0
				if IsBulletItem(item.dwTabType, item.dwIndex, szType) then
					Bullet.aBulletCount[szType] = Bullet.aBulletCount[szType] + item.nStackNum
					nItemCount = item.nStackNum
				end
				
				if IsBulletItem(tInfo.dwTabType, tInfo.dwIndex, szType) then			
					nDelta = nItemCount - tInfo.nStackNum
					Bullet.aBulletCount[szType] = Bullet.aBulletCount[szType] - tInfo.nStackNum
				end
				return nDelta
			end
			
			for szType, _ in pairs(Bullet.aItem) do
				aDelta[szType] = fn(szType)
			end
			
			tInfo.dwTabType = item.dwTabType
			tInfo.dwIndex = item.dwIndex
			tInfo.nStackNum = item.nStackNum
		else
			local function fn(szType)
				local nDelta = 0
				if IsBulletItem(tInfo.dwTabType, tInfo.dwIndex, szType) and tInfo.nStackNum > 0 then
					nDelta = 0 - tInfo.nStackNum
					Bullet.aBulletCount[szType] = Bullet.aBulletCount[szType] - tInfo.nStackNum
				end
				return nDelta
			end
			
			for szType, _ in pairs(Bullet.aItem) do
				aDelta[szType] = fn(szType)
			end
			
			tInfo.dwTabType = nil
			tInfo.dwIndex = nil
			tInfo.nStackNum = 0
		end
		
		for _, nValue in pairs(aDelta) do
			if nValue == -1 then
				FireUIEvent("BULLET_COST_ONE")
				break;
			end
		end
		FireEvent("BULLET_UPDATE_STATE")
	end
end

local function SetAnchorDefault()
	Bullet.Anchor.s = Bullet.DefaultAnchor.s
	Bullet.Anchor.r = Bullet.DefaultAnchor.r
	Bullet.Anchor.x = Bullet.DefaultAnchor.x
	Bullet.Anchor.y = Bullet.DefaultAnchor.y
	FireEvent("BULLET_ANCHOR_CHANGED")
end

local function OnEquipUpdate()
	if arg1 ~= EQUIPMENT_SUB.MELEE_WEAPON then
		return
	end
	
	if IsCanBulletShow() and Bullet.bShowPanel then
		OpenBullet()
	else
		CloseBullet()
	end
end

local function OnUpdateKungfu()
	if IsCanBulletShow() and Bullet.bShowPanel then
		OpenBullet()
	else
		CloseBullet()
	end
end


RegisterEvent("BULLETBACKUP_ITEM_UPDATE", OnBulletBackupItemUpdate)
RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", SetAnchorDefault)
RegisterEvent("EQUIP_ITEM_UPDATE", OnEquipUpdate)
RegisterEvent("LOADING_END", function() if IsCanBulletShow() and Bullet.bShowPanel then OpenBullet() end end)

RegisterEvent("SKILL_MOUNT_KUNG_FU", OnUpdateKungfu)
RegisterEvent("SKILL_UNMOUNT_KUNG_FU", OnUpdateKungfu)