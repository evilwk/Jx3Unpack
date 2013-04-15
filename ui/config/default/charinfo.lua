CharInfo = 
{
	nShowType = 6,
	pointCenter = {x = 88, y = 93, r = 56, g = 81, b = 94, a  = 180 },
	point = 
	{
		{x = 88, y = 14, r = 239, g = 55, b = 12, a  = 180 },
		{x = 159, y = 68, r = 239, g = 225, b = 9, a  = 180 },
		{x = 130, y = 154, r = 76, g = 223, b = 21, a  = 180 },
		{x = 44, y = 154, r = 223, g = 17, b = 201, a  = 180 },
		{x = 13, y = 68, r = 19, g = 77, b = 232, a  = 180 },
	},
}

RegisterCustomData("CharInfo.nShowType")

function CharInfo.OnFrameCreate()
	this:Lookup("", "Shadow_Info"):SetTriangleFan(true)
	this.nLoopCount = 0
	
	this:RegisterEvent("CORRECT_AUTO_POS")
	this:RegisterEvent("CHARACTER_PANEL_BRING_TOP")
end

function CharInfo.OnEvent(event)
	if event == "CORRECT_AUTO_POS" then
		if arg0 == "CharacterPanel" then
			CharInfo.OnCorrectPos(this)
		end
	elseif event == "CHARACTER_PANEL_BRING_TOP" then
		this:BringToTop()
	end
end

function CharInfo.OnSetFocus()
	FireEvent("CHARACTER_PANEL_BRING_TOP")
end

function CharInfo.OnCorrectPos(frame)
	frame:SetPoint("TOPLEFT", 0, 0, GetCharacterPanelPath(), "TOPLEFT", 380, 0)
end

function CharInfo.OnFrameBreathe()
	this.nLoopCount = this.nLoopCount + 1
	if this.nLoopCount >= 4 then
		this.nLoopCount = 0
		CharInfo.UpdateShowValue(this)
	end
end

function CharInfo.CalculatePoinShowPos(point)
	point.showX = CharInfo.pointCenter.x + (point.x - CharInfo.pointCenter.x) * point.p
	point.showY = CharInfo.pointCenter.y + (point.y - CharInfo.pointCenter.y) * point.p
end

function CharInfo.UpdateShadowShow(frame)
	local handle = frame:Lookup("", "")
	local s = handle:Lookup("Shadow_Info")
	s:ClearTriangleFanPoint()
	s:AppendTriangleFanPoint(CharInfo.pointCenter.x, CharInfo.pointCenter.y, CharInfo.pointCenter.r, CharInfo.pointCenter.g, CharInfo.pointCenter.b, CharInfo.pointCenter.a)
	for k, v in ipairs(CharInfo.point) do
		s:AppendTriangleFanPoint(v.showX, v.showY, v.r, v.g, v.b, v.a)
	end
	s:AppendTriangleFanPoint(CharInfo.point[1].showX, CharInfo.point[1].showY, CharInfo.point[1].r, CharInfo.point[1].g, CharInfo.point[1].b, CharInfo.point[1].a)
end

function CharInfo.UpdateShowLabel(frame)
	local handle = frame:Lookup("", "")
	if CharInfo.nShowType == 1 then
		handle:Lookup("Text_Class"):SetText(g_tStrings.MSG_PHYSICS_DAMAGE)
		
		handle:Lookup("Text_ClassInfoLabel01"):SetText(g_tStrings.MSG_PHYSICS_ATK)
		handle:Lookup("Text_ClassInfoLabel02"):SetText(g_tStrings.MSG_PHYSICS_HIT)
		handle:Lookup("Text_ClassInfoLabel03"):SetText(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE)
		handle:Lookup("Text_ClassInfoLabel04"):SetText(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE_DAMAGE)
		handle:Lookup("Text_ClassInfoLabel05"):SetText(g_tStrings.MSG_PHYSICS_SPEED)
		
		handle:Lookup("Text_InfoText01"):SetText(g_tStrings.MSG_PHYSICS_ATK)
		handle:Lookup("Text_InfoText02"):SetText(g_tStrings.MSG_PHYSICS_HIT)
		handle:Lookup("Text_InfoText03"):SetText(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE)
		handle:Lookup("Text_InfoText04"):SetText(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE_DAMAGE)
		handle:Lookup("Text_InfoText05"):SetText(g_tStrings.MSG_PHYSICS_SPEED)
	elseif CharInfo.nShowType == 2 then
		handle:Lookup("Text_Class"):SetText(g_tStrings.MSG_OVERCOME)
		handle:Lookup("Text_ClassInfoLabel01"):SetText(g_tStrings.MSG_OVERCOME_PHYSICS)
		handle:Lookup("Text_ClassInfoLabel02"):SetText(g_tStrings.MSG_OVERCOME_SOLAR_MAGIC)
		handle:Lookup("Text_ClassInfoLabel03"):SetText(g_tStrings.MSG_OVERCOME_NEUTRAL_MAGIC)
		handle:Lookup("Text_ClassInfoLabel04"):SetText(g_tStrings.MSG_OVERCOME_LUNAR_MAGIC)
		handle:Lookup("Text_ClassInfoLabel05"):SetText(g_tStrings.MSG_OVERCOME_POISON)

		handle:Lookup("Text_InfoText01"):SetText(g_tStrings.MSG_OVERCOME_PHYSICS)
		handle:Lookup("Text_InfoText02"):SetText(g_tStrings.MSG_OVERCOME_SOLAR_MAGIC)
		handle:Lookup("Text_InfoText03"):SetText(g_tStrings.MSG_OVERCOME_NEUTRAL_MAGIC)
		handle:Lookup("Text_InfoText04"):SetText(g_tStrings.MSG_OVERCOME_LUNAR_MAGIC)
		handle:Lookup("Text_InfoText05"):SetText(g_tStrings.MSG_OVERCOME_POISON)
	elseif CharInfo.nShowType == 3 then
		handle:Lookup("Text_Class"):SetText(g_tStrings.MSG_MAGIC_DAMAGE)
		handle:Lookup("Text_ClassInfoLabel01"):SetText(g_tStrings.MSG_MAGIC_ATTACK)
		handle:Lookup("Text_ClassInfoLabel02"):SetText(g_tStrings.MSG_MAGIC_HIT)
		handle:Lookup("Text_ClassInfoLabel03"):SetText(g_tStrings.MSG_MAGIC_CRITICALSTRIKE)
		handle:Lookup("Text_ClassInfoLabel04"):SetText(g_tStrings.MSG_MAGIC_CRITICALSTRIKE_DAMAGE)
		handle:Lookup("Text_ClassInfoLabel05"):SetText(g_tStrings.MSG_MAGIC_SPEED)

		handle:Lookup("Text_InfoText01"):SetText(g_tStrings.MSG_MAGIC_ATTACK)
		handle:Lookup("Text_InfoText02"):SetText(g_tStrings.MSG_MAGIC_HIT)
		handle:Lookup("Text_InfoText03"):SetText(g_tStrings.MSG_MAGIC_CRITICALSTRIKE)
		handle:Lookup("Text_InfoText04"):SetText(g_tStrings.MSG_MAGIC_CRITICALSTRIKE_DAMAGE)
		handle:Lookup("Text_InfoText05"):SetText(g_tStrings.MSG_MAGIC_SPEED)
	elseif CharInfo.nShowType == 4 then
		handle:Lookup("Text_Class"):SetText(g_tStrings.MSG_SURVIVE)
		handle:Lookup("Text_ClassInfoLabel01"):SetText(g_tStrings.MSG_THERAPY)
		handle:Lookup("Text_ClassInfoLabel02"):SetText(g_tStrings.MSG_LIFE_REPLENISH)
		handle:Lookup("Text_ClassInfoLabel03"):SetText(g_tStrings.MSG_MANA_REPLENISH)
		handle:Lookup("Text_ClassInfoLabel04"):SetText(g_tStrings.MSG_RUN_SPEED)
		handle:Lookup("Text_ClassInfoLabel05"):SetText(g_tStrings.MSG_STRAIN)

		handle:Lookup("Text_InfoText01"):SetText(g_tStrings.MSG_THERAPY)
		handle:Lookup("Text_InfoText02"):SetText(g_tStrings.MSG_LIFE_REPLENISH)
		handle:Lookup("Text_InfoText03"):SetText(g_tStrings.MSG_MANA_REPLENISH)
		handle:Lookup("Text_InfoText04"):SetText(g_tStrings.MSG_RUN_SPEED)
		handle:Lookup("Text_InfoText05"):SetText(g_tStrings.MSG_STRAIN)
	elseif CharInfo.nShowType == 5 then
		handle:Lookup("Text_Class"):SetText(g_tStrings.MSG_SHIELD)
		handle:Lookup("Text_ClassInfoLabel01"):SetText(g_tStrings.STR_MSG_DODGE)
		handle:Lookup("Text_ClassInfoLabel02"):SetText(g_tStrings.STR_MSG_COUNTERACT)
		handle:Lookup("Text_ClassInfoLabel03"):SetText(g_tStrings.STR_MSG_DEFENCE)
		handle:Lookup("Text_ClassInfoLabel04"):SetText(g_tStrings.MSG_TOUGHNESS)
		handle:Lookup("Text_ClassInfoLabel05"):SetText(g_tStrings.MSG_HUAJING)

		handle:Lookup("Text_InfoText01"):SetText(g_tStrings.STR_MSG_DODGE)
		handle:Lookup("Text_InfoText02"):SetText(g_tStrings.STR_MSG_COUNTERACT)
		handle:Lookup("Text_InfoText03"):SetText(g_tStrings.STR_MSG_DEFENCE)
		handle:Lookup("Text_InfoText04"):SetText(g_tStrings.MSG_TOUGHNESS)
		handle:Lookup("Text_InfoText05"):SetText(g_tStrings.MSG_HUAJING)	
	elseif CharInfo.nShowType == 6 then
		handle:Lookup("Text_Class"):SetText(g_tStrings.MSG_BASIS)
		handle:Lookup("Text_ClassInfoLabel01"):SetText(g_tStrings.MSG_VIGOR)
		handle:Lookup("Text_ClassInfoLabel02"):SetText(g_tStrings.MSG_SPIRIT)
		handle:Lookup("Text_ClassInfoLabel03"):SetText(g_tStrings.MSG_STRENGTH)
		handle:Lookup("Text_ClassInfoLabel04"):SetText(g_tStrings.MSG_AGILITY)
		handle:Lookup("Text_ClassInfoLabel05"):SetText(g_tStrings.MSG_SPUNK)
		
		handle:Lookup("Text_InfoText01"):SetText(g_tStrings.MSG_OVERCOME)
		handle:Lookup("Text_InfoText02"):SetText(g_tStrings.MSG_MAGIC_DAMAGE)
		handle:Lookup("Text_InfoText03"):SetText(g_tStrings.MSG_SURVIVE)
		handle:Lookup("Text_InfoText04"):SetText(g_tStrings.MSG_SHIELD)
		handle:Lookup("Text_InfoText05"):SetText(g_tStrings.MSG_PHYSICS_DAMAGE)
	end
end

function CharInfo.UpdateShowValue(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local nCof = 1
	if player.nLevel > 70 then
		nCof = (63 * player.nLevel^2 - 13260 * player.nLevel + 718400)/100000
	end
	
	local vA = 
	{
		player.nPhysicsAttackPower,
		player.nPhysicsHitBaseRate + 10000 * player.nPhysicsHitValue * 3.95 / (95 * player.nLevel) * nCof,
		player.nPhysicsCriticalStrikeBaseRate + 10000 * player.nPhysicsCriticalStrike * 5 / (74 * player.nLevel + 320) * nCof,
		player.nPhysicsCriticalDamagePowerBaseKiloNumRate/10 + 150 + 100 * player.nPhysicsCriticalDamagePower * 5/ (74 * player.nLevel + 320) * nCof,
		player.nMeleeWeaponAttackSpeedAdditional / 16,
		
		player.nPhysicsOvercome,
		player.nSolarOvercome,
		player.nNeutralOvercome,
		player.nLunarOvercome,
		player.nPoisonOvercome,
		
		math.max(player.nSolarAttackPower, player.nNeutralAttackPower, player.nLunarAttackPower, player.nPoisonAttackPower),
		math.max(
			player.nSolarHitBaseRate + 10000 * player.nSolarHitValue * 3.95 / (95 * player.nLevel) * nCof,
			player.nNeutralHitBaseRate + 10000 * player.nNeutralHitValue * 3.95 / (95 * player.nLevel) * nCof, 
			player.nLunarHitBaseRate + 10000 * player.nLunarHitValue * 3.95 / (95 * player.nLevel) * nCof, 
			player.nPoisonHitBaseRate + 10000 * player.nPoisonHitValue * 3.95 / (95 * player.nLevel) * nCof
		),
		math.max(
			player.nSolarCriticalStrikeBaseRate + 10000 * player.nSolarCriticalStrike * 5 / (74 * player.nLevel + 320) * nCof, 
			player.nNeutralCriticalStrikeBaseRate + 10000 * player.nNeutralCriticalStrike * 5 / (74 * player.nLevel + 320) * nCof, 
			player.nLunarCriticalStrikeBaseRate + 10000 * player.nLunarCriticalStrike * 5 / (74 * player.nLevel + 320) * nCof, 
			player.nPoisonCriticalStrikeBaseRate + 10000 * player.nPoisonCriticalStrike * 5 / (74 * player.nLevel + 320)*nCof
		),
		math.max(
			player.nSolarCriticalDamagePowerBaseKiloNumRate/10 + 150 + 100 * player.nSolarCriticalDamagePower * 5 / (74 * player.nLevel + 320)*nCof,
			player.nNeutralCriticalDamagePowerBaseKiloNumRate/10 + 150 + 100 * player.nNeutralCriticalDamagePower * 5 / (74 * player.nLevel + 320)*nCof,
			player.nLunarCriticalDamagePowerBaseKiloNumRate/10 + 150 + 100 * player.nLunarCriticalDamagePower * 5 / (74 * player.nLevel + 320)*nCof,
			player.nPoisonCriticalDamagePowerBaseKiloNumRate/10 + 150 + 100 * player.nPoisonCriticalDamagePower * 5 / (74 * player.nLevel + 320)*nCof
		),
		0,

		player.nTherapyPower,
		player.nLifeReplenish * (1024 + player.nLifeReplenishCoefficient) / 1024 + player.nLifeReplenishExt + player.nMaxLife * player.nLifeReplenishPercent / 1024,
		player.nManaReplenish * (1024 + player.nManaReplenishCoefficient) / 1024 + player.nCurrentSpunk * player.nSpunkToManaReplenishCof / 1024 + player.nManaReplenishExt + player.nMaxMana * player.nManaReplenishPercent / 1024,
		player.nRunSpeed,
		10000 * player.nStrain *1.2/ (27 * player.nLevel)*nCof,
		
		player.nDodgeBaseRate + 10000 * player.nDodge *3.25/ (59 * player.nLevel + 380)*nCof,
		player.nParryBaseRate + 10000 * player.nParry *1.3/ (30 * player.nLevel + 50)*nCof,
		player.nParryValue + player.nCurrentStrength / 4,
		player.nToughnessBaseRate + 10000 * player.nToughness *0.55*3.9/ (74 * player.nLevel + 320)*nCof,
		player.nDecriticalDamagePowerBaseKiloNumRate *10 + 10000 * player.nDecriticalDamagePower *0.9*3.5/ (74 * player.nLevel + 320)*nCof,
		
		player.nCurrentVitality,
		player.nCurrentSpirit,
		player.nCurrentStrength,
		player.nCurrentAgility,
		player.nCurrentSpunk
	}
	
	local vAP =
	{
		vA[1],
		KeepTwoByteFloat(vA[2]/100).."%",
		KeepTwoByteFloat(vA[3]/100).."%",
		KeepTwoByteFloat(vA[4]).."%",
		KeepOneByteFloat(player.nMeleeWeaponAttackSpeed / 16),
		
		vA[6],
		vA[7],
		vA[8],
		vA[9],
		vA[10],
		
		vA[11],
		KeepTwoByteFloat(vA[12]/100).."%",
		KeepTwoByteFloat(vA[13]/100).."%",
		KeepTwoByteFloat(vA[14]).."%",
		0,
		
		vA[16],
		math.floor(vA[17]),
		math.floor(vA[18]),
		vA[19],
		KeepTwoByteFloat(vA[20] / 100).."%",
		
		KeepTwoByteFloat(vA[21] / 100).."%",
		KeepTwoByteFloat(vA[22] / 100).."%",
		math.floor(vA[23]),
		KeepTwoByteFloat(vA[24] / 100).."%",
		KeepTwoByteFloat(vA[25] / 100).."%",
		
		vA[26],
		vA[27],
		vA[28],
		vA[29],
		vA[30],
	}
	
	local vAM = PlayerAbilityTable[player.nLevel]
	if not vAM then
		vAM = PlayerAbilityTable[#PlayerAbilityTable]
	end
	
	local vT = 
	{
		handle:Lookup("Text_ClassInfoValue01"),
		handle:Lookup("Text_ClassInfoValue02"),
		handle:Lookup("Text_ClassInfoValue03"),
		handle:Lookup("Text_ClassInfoValue04"),
		handle:Lookup("Text_ClassInfoValue05"),
	}
	
	local nShowType = CharInfo.nShowType

	--[[
	local value = KeepTwoByteFloat(100 * player.nPhysicsShield *12/ (270 + player.nPhysicsShield)*nCof)
	handle:Lookup("Text_DefendValue"):SetText(value)	
	--]]

	-- 属性面板属性值显示
	for i, text in ipairs(vT) do
		text:SetText(vAP[5 * (nShowType - 1) + i])
	end
	
	-- 基础属性:外防与外伤
	handle:Lookup("Text_DefendValue"):SetText(player.nPhysicsShield)
	
	local fMin, fMax
	if player.GetEquipItem(EQUIPMENT_INVENTORY.MELEE_WEAPON) then
		-- 武器伤害 = （武器基础伤害+武器浮动伤害（随机）） * 武器伤害百分比修正
		fMin = math.floor(player.nMeleeWeaponDamageBase + player.nPhysicsAttackPower * player.nMeleeWeaponAttackSpeed / (10 * 16))
		fMax = math.floor(fMin + player.nMeleeWeaponDamageRand)
	else
		-- 武器伤害 = （角色力量/10 + 角色精神/12 + 3）* 武器伤害百分比修正
		fMin = math.floor(player.nCurrentStrength / 10 + player.nCurrentSpunk /12 + 3 + player.nPhysicsAttackPower * player.nNoneWeaponAttackSpeedBase / (10 * 16))
		fMax = fMin
	end
	
	handle:Lookup("Text_DamageValue"):SetText(fMin.."-"..fMax)

	-- 五边形
	if CharInfo.nShowType == 6 then
		local p = (vA[6] / vAM[6] + vA[7] / vAM[7] + vA[8] / vAM[8] + vA[9] / vAM[9] + vA[10] / vAM[10]) / 5
		if p > 1 then
			p = 1
		end
		p = math.pow(p * 0.9, 1/2)		-- 曲线调整
		CharInfo.point[1].p = math.max(p, 0.33)
		CharInfo.CalculatePoinShowPos(CharInfo.point[1])

		local p = (vA[11] / vAM[11] + vA[12] / vAM[12] + vA[13] / vAM[13] + vA[14] / vAM[14] + vA[15] / vAM[15]) / 4
		if p > 1 then
			p = 1
		end
		p = math.pow(p * 0.9, 1/2)		-- 曲线调整
		CharInfo.point[2].p = math.max(p, 0.33)
		CharInfo.CalculatePoinShowPos(CharInfo.point[2])

		local p = (vA[16] / vAM[16] + vA[17] / vAM[17] + vA[18] / vAM[18] + vA[19] / vAM[19] + vA[20] / vAM[20]) / 5
		if p > 1 then
			p = 1
		end
		p = math.pow(p * 0.9, 1/2)		-- 曲线调整
		CharInfo.point[3].p = math.max(p, 0.33)
		CharInfo.CalculatePoinShowPos(CharInfo.point[3])

		local p = (vA[21] / vAM[21] + vA[22] / vAM[22] + vA[23] / vAM[23] + vA[24] / vAM[24] + vA[25] / vAM[25]) / 5
		if p > 1 then
			p = 1
		end
		p = math.pow(p * 0.9, 1/2)		-- 曲线调整
		CharInfo.point[4].p = math.max(p, 0.33)
		CharInfo.CalculatePoinShowPos(CharInfo.point[4])

		local p = (vA[1] / vAM[1] + vA[2] / vAM[2] + vA[3] / vAM[3] + vA[4] / vAM[4] + vA[5] / vAM[5]) / 5
		if p > 1 then
			p = 1
		end
		p = math.pow(p * 0.9, 1/2)		-- 曲线调整
		CharInfo.point[5].p = math.max(p, 0.33)
		CharInfo.CalculatePoinShowPos(CharInfo.point[5])
	else
		for i, vP in ipairs(CharInfo.point) do
			local nPos = (CharInfo.nShowType - 1) * 5 + i
			vP.p = vA[nPos] / vAM[nPos]
			if vP.p > 1 then
				vP.p = 1
			end
			vP.p = math.pow(vP.p * 0.9, 1/2)		-- 曲线调整
			vP.p = math.max(vP.p, 0.1)
			CharInfo.CalculatePoinShowPos(vP)
		end
	end
	CharInfo.UpdateShadowShow(frame)
end

function CharInfo.OnItemMouseEnter()
	this.bOver = true
	
	local player = GetClientPlayer()
	
	local nCof = 1
	if player.nLevel > 70 then
		nCof = (63 * player.nLevel^2 - 13260 * player.nLevel + 718400)/100000
	end
	
	local szName = this:GetName()
	local nIndex = 1
	if szName == "Text_ClassInfoLabel01" or szName == "Text_ClassInfoValue01" then
		nIndex = 1
	elseif szName == "Text_ClassInfoLabel02" or szName == "Text_ClassInfoValue02" then
		nIndex = 2
	elseif szName == "Text_ClassInfoLabel03" or szName == "Text_ClassInfoValue03" then
		nIndex = 3
	elseif szName == "Text_ClassInfoLabel04" or szName == "Text_ClassInfoValue04" then
		nIndex = 4
	elseif szName == "Text_ClassInfoLabel05" or szName == "Text_ClassInfoValue05" then
		nIndex = 5
	else
		local szTip = ""
		if szName == "Image_Solar" then
			local value = KeepTwoByteFloat(100 * player.nSolarMagicShield *0.55/ (9 * player.nLevel)*nCof).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_MAGIC_SHIELD, player.nSolarMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_MAGIC_DAMAGE_DWON, player.nSolarMagicShield, value)).."</text>"
		elseif szName == "Image_Neutral" then
			local value = KeepTwoByteFloat(100 * player.nNeutralMagicShield *0.55/ (9 * player.nLevel)*nCof).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_NEUTRAL_MAGIC_SHIELD, player.nNeutralMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_NEUTRAL_MAGIC_DAMAGE_DWON, player.nNeutralMagicShield, value)).."</text>"
		elseif szName == "Image_Lunar" then
			local value = KeepTwoByteFloat(100 * player.nLunarMagicShield *0.55/ (9 * player.nLevel)*nCof).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LUNAR_MAGIC_SHIELD, player.nLunarMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LUNAR_MAGIC_DAMAGE_DWON, player.nLunarMagicShield, value)).."</text>"
		elseif szName == "Image_Poison" then
			local value = KeepTwoByteFloat(100 * player.nPoisonMagicShield *0.55/ (9 * player.nLevel)*nCof).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_POISON_SHIELD, player.nPoisonMagicShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_POISON_DAMAGE_DWON, player.nPoisonMagicShield, value)).."</text>"
		elseif szName == "Text_DamageLabel" or szName == "Text_DamageValue" then
			local fMeleeMin, fMeleeMax, szMeleeMin, szMeleeMax, szMeleeDps
			if player.GetEquipItem(EQUIPMENT_INVENTORY.MELEE_WEAPON) then
				fMeleeMin = math.floor(player.nMeleeWeaponDamageBase + player.nPhysicsAttackPower * player.nMeleeWeaponAttackSpeed/ (10 * 16))
				fMeleeMax = math.floor(fMeleeMin + player.nMeleeWeaponDamageRand)
				szMeleeMin = fMeleeMin
				szMeleeMax = fMeleeMax
				szMeleeDps = math.floor((fMeleeMin + fMeleeMax) * 16 / (2 * player.nMeleeWeaponAttackSpeed))
			else
				-- -- 武器伤害 = （角色力量/10 + 角色精神/12 + 3）* 武器伤害百分比修正
				fMeleeMin = math.floor(player.nCurrentStrength / 10 + player.nCurrentSpunk /12 + 3 + player.nPhysicsAttackPower * player.nNoneWeaponAttackSpeedBase / (10 * 16))
				fMeleeMax = fMeleeMin
				szMeleeMin = fMeleeMin
				szMeleeMax = fMeleeMax
				szMeleeDps = KeepOneByteFloat((fMeleeMin + fMeleeMax) * 16 / (2 * player.nNoneWeaponAttackSpeedBase))
			end
			
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_DAMAGE_HURT, szMeleeMin.."-"..szMeleeMax)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_DAMAGE_MELEE, szMeleeMin.."-"..szMeleeMax, szMeleeDps)).."</text>"
			
			local fRangeMin, fRangeMax, fRangeDps
			if player.GetEquipItem(EQUIPMENT_INVENTORY.RANGE_WEAPON) then
				fRangeMin = player.nRangeWeaponDamageBase + player.nPhysicsAttackPower * player.nRangeWeaponAttackSpeed/ (10 * 16)
				fRangeMax = fMeleeMin + player.nRangeWeaponDamageRand
				fRangeDps = (fRangeMin + fRangeMax) * 16 / (2 * player.nRangeWeaponAttackSpeed)
				
				local szRangeMin = math.floor(fRangeMin)
				local szRangeMax = math.floor(fRangeMax)
				local szRangeDps = KeepOneByteFloat(fRangeDps)
				
				szTip = szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_DAMAGE_RANGE, szRangeMin.."-"..szRangeMax, szRangeDps)).."</text>"
			else
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.MSG_PHYSICS_DAMAGE_RANGE_NON).."</text>"
			end
		elseif szName == "Text_DefendLabel" or szName == "Text_DefendValue" then
			local value = KeepTwoByteFloat(100 * player.nPhysicsShield *12/ (player.nLevel * 270)*nCof).."%"
			szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_SHIELD, player.nPhysicsShield)).."font=32</text>"
				.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_DAMAGE_DWON, player.nPhysicsShield, value)).."</text>"
		end
		
		if szTip ~= "" then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputTip(szTip, 400, {x, y, w, h})
		end
		return
	end

	local szLable = this:GetParent():Lookup("Text_ClassInfoLabel0"..nIndex):GetText()
	local szValue = this:GetParent():Lookup("Text_ClassInfoValue0"..nIndex):GetText()
	local szTitle = "<text>text="..EncodeComponentsString(szLable..szValue.."\n").."font=32</text>"
	
	nIndex = (CharInfo.nShowType - 1) * 5 + nIndex
			
	local szTip = ""
	if nIndex == 1 then
		local szDps = KeepOneByteFloat(player.nPhysicsAttackPower / 10)
		szTip = szTitle..szTip.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_DPS_UP, szDps)).."</text>"
	elseif nIndex == 2 then
		szValue = KeepTwoByteFloat(100 * player.nPhysicsHitValue *3.95/ (95 * player.nLevel)*nCof).."%"
		local szlevel1= KeepTwoByteFloat(player.nLevel+1)
		local szlevel2= KeepTwoByteFloat(player.nLevel+2)
		local szlevel3= KeepTwoByteFloat(player.nLevel+3)
		local szlevel4= KeepTwoByteFloat(player.nLevel+4)
		
		local szValueBase = KeepTwoByteFloat(100 * player.nPhysicsHitValue*3.95 / (95 * player.nLevel)*nCof+player.nPhysicsHitBaseRate / 100)
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATE, szValueBase.."%")).."font=32</text>"
		
		local szValueBase0 = string.format("%.2f",KeepTwoByteFloat(szValueBase)).."%"
		local szValueBase1 = string.format("%.2f",KeepTwoByteFloat(szValueBase-2.5)).."%"
		local szValueBase2 = string.format("%.2f",KeepTwoByteFloat(szValueBase-5)).."%"
		local szValueBase3 = string.format("%.2f",KeepTwoByteFloat(szValueBase-10)).."%"
		local szValueBase4 = string.format("%.2f",KeepTwoByteFloat(szValueBase-20)).."%"
		szTip =szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_VALUE, player.nPhysicsHitValue, szValue)).."</text>"..
						"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATETip, player.nPhysicsHitValue)).."</text>"..
						"<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=24</image>"..
						"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATE0, player.nLevel,szValueBase0)).."</text>"..
						"<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=24</image>"..
						"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATE1, szlevel1,szValueBase1)).."</text>"..
						"<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=24</image>"..
						"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATE2, szlevel2,szValueBase2)).."</text>"..
						"<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=25</image>"..
						"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATE3, szlevel3,szValueBase3)).."</text>"..
                        "<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=25</image>"..
						"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_HIT_RATE4, szlevel4,szValueBase4)).."</text>"
	elseif nIndex == 3 then
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE_RATE, szValue)).."font=32</text>"
		szValue = KeepTwoByteFloat(100 * player.nPhysicsCriticalStrike *5/ (74 * player.nLevel + 320)*nCof).."%"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE_VALUE, player.nPhysicsCriticalStrike, szValue)).."</text>"
	elseif nIndex == 4 then
		local nPhysicsCriticalDamageRateAdd = KeepTwoByteFloat(100 * player.nPhysicsCriticalDamagePower *5/ (74 * player.nLevel + 320)*nCof).."%"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_CRITICALSTRIKE_DAMAGE_POWER, player.nPhysicsCriticalDamagePower, nPhysicsCriticalDamageRateAdd)).."</text>"
	elseif nIndex == 5 then
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_COMMON_ATTACK_SPEED, szValue)).."font=32</text>"
		local nSpeedAdd
		if player.nMeleeWeaponAttackSpeedAdditional == 0 then
			nSpeedAdd = 0
		else
			nSpeedAdd = KeepOneByteFloat(player.nMeleeWeaponAttackSpeedAdditional / 16)
		end
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_SPEED_UP, player.nMeleeWeaponAttackSpeedAdditional, nSpeedAdd)).."</text>"
	elseif nIndex == 6 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_OVERCOME_DOWN, player.nPhysicsOvercome)).."</text>"
	elseif nIndex == 7 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_OVERCOME_DOWN, player.nSolarOvercome)).."</text>"
	elseif nIndex == 8 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_NEUTRAL_OVERCOME_DOWN, player.nNeutralOvercome)).."</text>"
	elseif nIndex == 9 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LUNAR_OVERCOME_DOWN, player.nLunarOvercome)).."</text>"
	elseif nIndex == 10 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_POISON_OVERCOME_DOWN, player.nPoisonOvercome)).."</text>"
	elseif nIndex == 11 then
		szTitle = "<text>text="..EncodeComponentsString(szLable.."\n").."font=32</text>"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_ATTACK_POWER, player.nSolarAttackPower, player.nNeutralAttackPower, player.nLunarAttackPower, player.nPoisonAttackPower)).."</text>"
	elseif nIndex == 12 then
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_MAGIC_HIT_SAME_VALUE_RATE, szValue)).."font=32</text>"
  		local nSolarHitRate = KeepTwoByteFloat(player.nSolarHitBaseRate / 100 + 100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nSolarHitRateAdd = KeepTwoByteFloat(100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nNeutralHitRate = KeepTwoByteFloat(player.nNeutralHitBaseRate / 100 + 100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nNeutralHitRateAdd = KeepTwoByteFloat(100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nLunarHitRate = KeepTwoByteFloat(player.nLunarHitBaseRate / 100 + 100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nLunarHitRateAdd = KeepTwoByteFloat(100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nPoisonHitRate = KeepTwoByteFloat(player.nPoisonHitBaseRate / 100 + 100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		local nPoisonHitRateAdd = KeepTwoByteFloat(100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof).."%"
		szSolarHitRateBase0   = string.format("%.2f",KeepTwoByteFloat(player.nSolarHitBaseRate / 100 + 100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof)).."%"
        szSolarHitRateBase1   = string.format("%.2f",KeepTwoByteFloat(player.nSolarHitBaseRate / 100 + 100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof-2.5)).."%"
        szSolarHitRateBase2   = string.format("%.2f",KeepTwoByteFloat(player.nSolarHitBaseRate / 100 + 100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof-5)).."%"
        szSolarHitRateBase3   = string.format("%.2f",KeepTwoByteFloat(player.nSolarHitBaseRate / 100 + 100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof-10)).."%"
        szSolarHitRateBase4   = string.format("%.2f",KeepTwoByteFloat(player.nSolarHitBaseRate / 100 + 100 * player.nSolarHitValue*3.95/ (95 * player.nLevel)*nCof-20)).."%"

		szNeutralHitRateBase0 = string.format("%.2f",KeepTwoByteFloat(player.nNeutralHitBaseRate / 100 + 100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof)).."%"
        szNeutralHitRateBase1 = string.format("%.2f",KeepTwoByteFloat(player.nNeutralHitBaseRate / 100 + 100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof-2.5)).."%"
        szNeutralHitRateBase2 = string.format("%.2f",KeepTwoByteFloat(player.nNeutralHitBaseRate / 100 + 100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof-5)).."%"
        szNeutralHitRateBase3 = string.format("%.2f",KeepTwoByteFloat(player.nNeutralHitBaseRate / 100 + 100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof-10)).."%"
        szNeutralHitRateBase4 = string.format("%.2f",KeepTwoByteFloat(player.nNeutralHitBaseRate / 100 + 100 * player.nNeutralHitValue*3.95/ (95 * player.nLevel)*nCof-20)).."%"

		szLunarHitRateBase0   = string.format("%.2f",KeepTwoByteFloat(player.nLunarHitBaseRate / 100 + 100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof)).."%"
        szLunarHitRateBase1   = string.format("%.2f",KeepTwoByteFloat(player.nLunarHitBaseRate / 100 + 100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof-2.5)).."%"
        szLunarHitRateBase2   = string.format("%.2f",KeepTwoByteFloat(player.nLunarHitBaseRate / 100 + 100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof-5)).."%"
        szLunarHitRateBase3   = string.format("%.2f",KeepTwoByteFloat(player.nLunarHitBaseRate / 100 + 100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof-10)).."%"
        szLunarHitRateBase4   = string.format("%.2f",KeepTwoByteFloat(player.nLunarHitBaseRate / 100 + 100 * player.nLunarHitValue*3.95/ (95 * player.nLevel)*nCof-20)).."%"

        szPoisonHitRateBase0  = string.format("%.2f",KeepTwoByteFloat(player.nPoisonHitBaseRate / 100 + 100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof)).."%"
        szPoisonHitRateBase1  = string.format("%.2f",KeepTwoByteFloat(player.nPoisonHitBaseRate / 100 + 100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof-2.5)).."%"
        szPoisonHitRateBase2  = string.format("%.2f",KeepTwoByteFloat(player.nPoisonHitBaseRate / 100 + 100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof-5)).."%"
        szPoisonHitRateBase3  = string.format("%.2f",KeepTwoByteFloat(player.nPoisonHitBaseRate / 100 + 100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof-10)).."%"
        szPoisonHitRateBase4  = string.format("%.2f",KeepTwoByteFloat(player.nPoisonHitBaseRate / 100 + 100 * player.nPoisonHitValue*3.95/ (95 * player.nLevel)*nCof-20)).."%"

		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_RATEBase, player.nSolarHitValue,nSolarHitRateAdd)).."</text>"..
		"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_NEUTRAL_RATEBase, player.nNeutralHitValue,nNeutralHitRateAdd)).."</text>"..
		"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LUNAR_RATEBase, player.nLunarHitValue,nLunarHitRateAdd)).."</text>"..
		"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_POISON_RATEBase, player.nPoisonHitValue,nPoisonHitRateAdd)).."</text>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATETip, szValue)).."</text>"..
                                        "<image>path=\"UI/Image/Common/MainPanel_1.UITex\" frame=38</image>"..
                                        "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATETip1, szValue)).."</text>"..
                                        "<image>path=\"UI/Image/Common/MainPanel_1.UITex\" frame=37</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATETip2, szValue)).."</text>"..
                                        "<image>path=\"UI/Image/Common/MainPanel_1.UITex\" frame=39</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATETip3, szValue)).."</text>"..
                                        "<image>path=\"UI/Image/Common/MainPanel_1.UITex\" frame=36</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATETip4, szValue)).."</text>"..
        								"<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=24</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATE,
																			player.nLevel,szSolarHitRateBase0, szNeutralHitRateBase0, szLunarHitRateBase0,szPoisonHitRateBase0)).."</text>"..
                                        "<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=24</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATE,
																			player.nLevel+1,szSolarHitRateBase1, szNeutralHitRateBase1, szLunarHitRateBase1,szPoisonHitRateBase1)).."</text>"..
                                        "<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=24</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATE,
																			player.nLevel+2,szSolarHitRateBase2, szNeutralHitRateBase2, szLunarHitRateBase2,szPoisonHitRateBase2)).."</text>"..
                                        "<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=25</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATE,
																			player.nLevel+3,szSolarHitRateBase3, szNeutralHitRateBase3, szLunarHitRateBase3,szPoisonHitRateBase3)).."</text>"..
                                        "<image>path=\"UI/Image/Common/DialogueLabel.UITex\" frame=25</image>"..
										"<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_HIT_VALUE_RATE,
																			player.nLevel+4,szSolarHitRateBase4, szNeutralHitRateBase4, szLunarHitRateBase4,szPoisonHitRateBase4)).."</text>"
	elseif nIndex == 13 then
		local nSolarCriticalStrikeRate = KeepTwoByteFloat(player.nSolarCriticalStrikeBaseRate/100 + 100 * player.nSolarCriticalStrike*5 / (74 * player.nLevel + 320)*nCof).."%"
		local nSolarCriticalStrikeRateAdd = KeepTwoByteFloat(100 * player.nSolarCriticalStrike *5/ (74 * player.nLevel + 320)*nCof).."%"
		local nNeutralCriticalStrikeRate = KeepTwoByteFloat(player.nNeutralCriticalStrikeBaseRate/100 + 100 * player.nNeutralCriticalStrike*5/ (74 * player.nLevel + 320)*nCof).."%"
		local nNeutralCriticalStrikeRateAdd = KeepTwoByteFloat(100 * player.nNeutralCriticalStrike*5/ (74 * player.nLevel + 320)*nCof).."%"
		local nLunarCriticalStrikeRate = KeepTwoByteFloat(player.nLunarCriticalStrikeBaseRate/100 + 100 * player.nLunarCriticalStrike*5/ (74 * player.nLevel + 320)*nCof).."%"
		local nLunarCriticalStrikeRateAdd = KeepTwoByteFloat(100 * player.nLunarCriticalStrike*5/ (74 * player.nLevel + 320)*nCof).."%"
		local nPoisonCriticalStrikeRate = KeepTwoByteFloat(player.nPoisonCriticalStrikeBaseRate/100 + 100 * player.nPoisonCriticalStrike*5/ (74 * player.nLevel + 320)*nCof).."%"
		local nPoisonCriticalStrikeRateAdd = KeepTwoByteFloat(100 * player.nPoisonCriticalStrike*5/ (74 * player.nLevel + 320)*nCof).."%"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_CRITICALSTRIKE_VALUE_RATE,
																			nSolarCriticalStrikeRate, player.nSolarCriticalStrike, nSolarCriticalStrikeRateAdd,
																			nNeutralCriticalStrikeRate, player.nNeutralCriticalStrike, nNeutralCriticalStrikeRateAdd,
																			nLunarCriticalStrikeRate, player.nLunarCriticalStrike, nLunarCriticalStrikeRateAdd,
																			nPoisonCriticalStrikeRate, player.nPoisonCriticalStrike, nPoisonCriticalStrikeRateAdd)).."</text>"			
	elseif nIndex == 14 then
		local nSolarCriticalDamageRateAdd = KeepTwoByteFloat(100 * player.nSolarCriticalDamagePower *5/ (74 * player.nLevel + 320)*nCof).."%"
		local nNeutralCriticalDamageRateAdd = KeepTwoByteFloat(100 * player.nNeutralCriticalDamagePower*5 / (74 * player.nLevel + 320)*nCof).."%"
		local nLunarCriticalDamageRateAdd = KeepTwoByteFloat(100 * player.nLunarCriticalDamagePower *5/ (74 * player.nLevel + 320)*nCof).."%"
		local nPoisonCriticalDamageRateAdd = KeepTwoByteFloat(100 * player.nPoisonCriticalDamagePower *5/ (74 * player.nLevel + 320)*nCof).."%"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SOLAR_NEUTRAL_LUNAR_POISON_CRITICALSTRIKE_DAMAGE_POWER, 
			player.nSolarCriticalDamagePower, nSolarCriticalDamageRateAdd,
			player.nNeutralCriticalDamagePower, nNeutralCriticalDamageRateAdd,
			player.nLunarCriticalDamagePower, nLunarCriticalDamageRateAdd,
			player.nPoisonCriticalDamagePower, nPoisonCriticalDamageRateAdd
			)).."</text>"
	elseif nIndex == 15 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(g_tStrings.MSG_SKILL_CAST_SPEED_UP).."</text>"
	elseif nIndex == 16 then
		local szHps = KeepOneByteFloat(player.nTherapyPower / 10)
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_THERAPY_PER_SECOND_UP, szHps)).."</text>"
	elseif nIndex == 17 then
		local nLifeReplenishInFight = player.nLifeReplenish * player.nLifeReplenishCoefficient / 1024 + player.nLifeReplenishExt + player.nMaxLife * player.nLifeReplenishPercent / 1024
		local nLifeReplenishOufOfFight = player.nLifeReplenish * (1024 + player.nLifeReplenishCoefficient) / 1024 + player.nLifeReplenishExt + player.nMaxLife * player.nLifeReplenishPercent / 1024
		nLifeReplenishInFight = math.floor(nLifeReplenishInFight)
		nLifeReplenishOufOfFight = math.floor(nLifeReplenishOufOfFight)
		szTitle = "<text>text="..EncodeComponentsString(g_tStrings.MSG_LIFE_REPLENISH_PER_SECOND).."font=32</text>"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LIFE_REPLENISH_UP_PER_SECOND, nLifeReplenishOufOfFight, nLifeReplenishInFight)).."</text>"
	elseif nIndex == 18 then
		--local nManaReplenish = player.nManaReplenish * (1 + player.nManaReplenishCoefficient / 1024)
		local nManaReplenishInFight = player.nManaReplenish * player.nManaReplenishCoefficient / 1024 + player.nCurrentSpunk * player.nSpunkToManaReplenishCof / 1024 + player.nManaReplenishExt + player.nMaxMana * player.nManaReplenishPercent / 1024
		local nManaReplenishOufOfFight = player.nManaReplenish + nManaReplenishInFight
		nManaReplenishInFight = math.floor(nManaReplenishInFight)
		nManaReplenishOufOfFight = math.floor(nManaReplenishOufOfFight)
		szTitle = "<text>text="..EncodeComponentsString(g_tStrings.MSG_MANA_REPLENISH_PER_SECOND).."font=32</text>"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_MANA_REPLENISH_UP_PER_SECOND, nManaReplenishOufOfFight, nManaReplenishInFight)).."</text>"
	elseif nIndex == 19 then
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_RUN_SPEED, szValue)).."font=32</text>"
		local nRunSpeed = KeepOneByteFloat(player.nRunSpeed * 16 / 64)
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_RUN_SPEED_PER_SECOND, nRunSpeed)).."</text>"
	elseif nIndex == 20 then
		szTitle = "<text>text="..EncodeComponentsString(szLable.."\n").."font=32</text>"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_STRAIN_VALUE, player.nStrain, szValue)).."</text>"
	elseif nIndex == 21 then
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_DODGE_RATE, szValue)).."font=32</text>"
		local nDodgeRateAdd = KeepTwoByteFloat(100 * player.nDodge *3.25/ (59 * player.nLevel + 380)*nCof).."%"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_DODGE_VALUE, player.nDodge, nDodgeRateAdd)).."</text>"
	elseif nIndex == 22 then
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_PARRY_RATE, szValue)).."font=32</text>"
		local nParryRateAdd = KeepTwoByteFloat(100 * player.nParry *1.3/ (30 * player.nLevel + 50)*nCof).."%"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PARRY_VALUE, player.nParry, nParryRateAdd)).."</text>"
	elseif nIndex == 23 then
		szTitle = "<text>text="..EncodeComponentsString(szLable.."\n").."font=32</text>"
		local nParryValue = math.floor(player.nParryValue + (player.nCurrentStrength / 4))
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_DAMAGE_DOWN_AFTER_SUCCEED_PARRY, nParryValue)).."</text>"
	elseif nIndex == 24 then
		local nToughnessRateAdd = KeepTwoByteFloat(100 * player.nToughness *0.55*3.9/ (74 * player.nLevel + 320)*nCof).."%"
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_BE_CRITICALSTRIKE_RATE_DOWN, nToughnessRateAdd)).."font=32</text>"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_TOUGHNESS_VALUE, player.nToughness, nToughnessRateAdd)).."</text>"
	elseif nIndex == 25 then
		--local nDecriticalDamagePowerKiloNumRateAdd = KeepTwoByteFloat(100 * player.nDecriticalDamagePower *1.8*3.5/ (74 * player.nLevel + 320)*nCof).."%"
		local nDecriticalDamagePowerKiloNumRateAddHalf = KeepTwoByteFloat(100 * player.nDecriticalDamagePower *0.9*3.5/ (74 * player.nLevel + 320)*nCof).."%"
		szTitle = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_DAMAGE_DOWN_AFTER_CRITICALSTRIKE, nDecriticalDamagePowerKiloNumRateAddHalf)).."font=32</text>"
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_HUAJING_VALUE, player.nDecriticalDamagePower, nDecriticalDamagePowerKiloNumRateAddHalf)).."</text>"
	elseif nIndex == 26 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_LIFE_UP, player.nCurrentVitality * 10)).."</text>"
	elseif nIndex == 27 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_SPIRIT_UP, player.nCurrentSpirit * 10, math.floor(player.nCurrentSpirit*0.2/10+0.5), math.floor(player.nCurrentSpirit/10))).."</text>"
	elseif nIndex == 28 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_PHYSICS_UP, player.nCurrentStrength * 1, math.floor(player.nCurrentStrength/4))).."</text>"
	elseif nIndex == 29 then
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_AGILITY_UP, math.floor(player.nCurrentAgility * 3/10+0.5), math.floor(player.nCurrentAgility * 0.1/5+0.5), math.floor(player.nCurrentAgility * 2/10))).."</text>"
	elseif nIndex == 30 then	
		local value0 = player.nCurrentSpunk * 2
		local value1 = KeepTwoByteFloat(player.nCurrentSpunk * 0.005)
		local value2 = KeepTwoByteFloat(player.nCurrentSpunk * 0.002)
		szTip = szTitle.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_MAGIC_MANA_REPLENISH_UP, value0, value1, value2)).."</text>"
	end
	
	if szTip ~= "" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(szTip, 400, {x, y, w, h})
	end
end

function CharInfo.OnItemMouseLeave()
	this.bOver = false
	HideTip()
end

function CharInfo.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCharInfo()
	elseif szName == "Btn_Class" then
    end
end

function CharInfo.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Close" then
	elseif szName == "Btn_Class" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		if not this:IsEnabled() then
			return
		end
		
		local text = this:GetParent():Lookup("", "Text_Class")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Normal/CharInfo/Btn_Class") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAction = function(UserData, bCheck)
				CharInfo.nShowType = UserData
				local frame = Station.Lookup("Normal/CharInfo")
				CharInfo.UpdateShowLabel(frame)
				CharInfo.UpdateShowValue(frame)
			end,
			fnAutoClose = function() if IsCharInfoOpened() then return false else return true end end,
			
			{szOption = g_tStrings.MSG_BASIS, UserData = 6},
			{szOption = g_tStrings.MSG_PHYSICS_DAMAGE, UserData = 1},
			{szOption = g_tStrings.MSG_MAGIC_DAMAGE, UserData = 3},
			{szOption = g_tStrings.MSG_SHIELD, UserData = 5},
			{szOption = g_tStrings.MSG_SURVIVE, UserData = 4},
			{szOption = g_tStrings.MSG_OVERCOME, UserData = 2},
		}
		
		PopupMenu(menu)
		
		FireDataAnalysisEvent("FIRST_USE_CHARACTER_PROPERTY_FILTER")
		return true	
    end
end

function OpenCharInfo(bDisableSound)
	if IsCharInfoOpened() then
		return
	end
	local frame = Wnd.OpenWindow("CharInfo")
	frame:Show()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end

	CharInfo.UpdateShowLabel(frame)
	CharInfo.UpdateShowValue(frame)
	FireEvent("OPEN_CHAR_INFO")
	
	CharInfo.OnCorrectPos(frame)
	
	CharInfo.nLastShowType = CharInfo.nShowType
end

function IsCharInfoOpened()
	local frame = Station.Lookup("Normal/CharInfo")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseCharInfo(bDisableSound, bIgnor)
	if not IsCharInfoOpened() then
		return
	end

	local frame = Station.Lookup("Normal/CharInfo")
	frame:Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	local argS = arg0
	arg0 = not bIgnor
	FireEvent("CLOSE_CHAR_INFO")
	arg0 = argS
	
	--数据统计
	if CharInfo.nLastShowType ~= CharInfo.nShowType then	
		if CharInfo.nShowType == 6 then
			FireDataAnalysisEvent("SET_CHARACTER_BASIS")
		elseif CharInfo.nShowType == 1 then
			FireDataAnalysisEvent("SET_CHARACTER_PHYSICS_DAMAGE")
		elseif CharInfo.nShowType == 2 then
			FireDataAnalysisEvent("SET_CHARACTER_MAGIC_DAMAGE")
		elseif CharInfo.nShowType == 3 then
			FireDataAnalysisEvent("SET_CHARACTER_SHIELD")
		elseif CharInfo.nShowType == 4 then
			FireDataAnalysisEvent("SET_CHARACTER_SURVIVE")
		elseif CharInfo.nShowType == 5 then
			FireDataAnalysisEvent("SET_CHARACTER_OVERCOME")
		end
	end
end

function CharInfo_GetPage()
	return CharInfo.nShowType
end

function CharInfo_SetPage(nPage)
	if nPage >= 1 and nPage <= 6 then
		CharInfo.nShowType = nPage
	end
end
