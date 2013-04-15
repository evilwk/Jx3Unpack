Matrix = 
{
	
	Path = "ui/Image/Matrix/",
	aInfo =
	{ 	--参见school表
		[1] = {aBg = {"tiance.tga", "tiance.tga", "tiance.tga", "tiance2.tga", "tiance2.tga", "tiance3.tga", "tiance3.tga"}, bAnimateBg = false, BoxPos = {70, 63}, AnimateBgPos = {1, 2}, AnimatePos = {49, 41}, aPoint = {{85, 32}, {17, 88}, {155, 88}, {48, 33}, {124, 33}}},
		[2] = {aBg = {"wanhua.tga", "wanhua.tga", "wanhua.tga", "wanhua2.tga", "wanhua2.tga", "wanhua3.tga", "wanhua3.tga"}, bAnimateBg = false, BoxPos = {42, 76}, AnimateBgPos = {1, 2}, AnimatePos = {21, 53}, aPoint = {{36, 114}, {115, 33}, {156, 79}, {95, 29}, {135, 70}}},
		[3] = {aBg = {"chunyang.tga", "chunyang.tga", "chunyang.tga", "chunyang2.tga", "chunyang2.tga", "chunyang3.tga", "chunyang3.tga"}, bAnimateBg = true, BoxPos = {70, 46}, AnimateBgPos = {45, 21}, AnimatePos = {49, 23}, aPoint = {{21, 72}, {92, 85}, {150, 111}, {72, 41}, {122, 106}}},
		[4] = {aBg = {"qixiu.tga", "qixiu.tga", "qixiu.tga", "qixiu2.tga", "qixiu2.tga", "qixiu3.tga", "qixiu3.tga"}, bAnimateBg = false, BoxPos = {72, 62}, AnimateBgPos = {1, 2}, AnimatePos = {51, 39}, aPoint = {{88, 104}, {38, 49}, {138, 49}, {65, 39}, {110, 39}}},
		[5] = {aBg = {"shaolin.tga", "shaolin.tga", "shaolin.tga", "shaolin2.tga", "shaolin2.tga", "shaolin3.tga", "shaolin3.tga"}, bAnimateBg = true, BoxPos = {68, 79}, AnimateBgPos = {45, 19}, AnimatePos = {48, 57}, aPoint = {{86, 33}, {59, 70}, {111, 70}, {61, 47}, {108, 47}}},
		[6] = {aBg = {"cangjian.tga", "cangjian.tga", "cangjian.tga", "cangjian2.tga", "cangjian2.tga", "cangjian3.tga", "cangjian3.tga"}, bAnimateBg = false, BoxPos = {70, 60}, AnimateBgPos = {45, 19}, AnimatePos = {51, 39}, aPoint = {{36, 6}, {139, 6}, {87, 23}, {46, 63}, {127, 63}}},
		[9] = {aBg = {"wudu.tga", "wudu.tga", "wudu.tga", "wudu.tga", "wudu.tga", "wudu.tga", "wudu.tga"}, bAnimateBg = false, BoxPos = {72, 88}, AnimateBgPos = {48, 61}, AnimatePos = {52, 66}, aPoint = {{25, 41}, {148, 41}, {132, 86}, {43, 87}, {87, 23}}},
		[10] = {aBg = {"tangmen1.tga", "tangmen.tga", "tangmen.tga", "tangmen.tga", "tangmen.tga", "tangmen.tga", "tangmen.tga"}, bAnimateBg = false, BoxPos = {72, 60}, AnimateBgPos = {48, 36}, AnimatePos = {52, 37}, aPoint = {{30, 42}, {64, 6}, {148, 42}, {88, 120}, {110, 6}}},
	},
    
	aAnimate =
	{
		"MatrixAni.UITex",
		"MatrixAni.UITex",
		"MatrixAni.UITex",
		"MatrixAni_1.UITex",
		"MatrixAni_1.UITex",
		"MatrixAni_2.UITex",
		"MatrixAni_2.UITex",
	},
	bShowMatrix = true,
	DefaultAnchor = {s = "BOTTOMLEFT", r = "BOTTOMLEFT", x = 5, y = -330},
	Anchor = {s = "BOTTOMLEFT", r = "BOTTOMLEFT", x = 5, y = -330},
}

RegisterCustomData("Matrix.bShowMatrix")
RegisterCustomData("Matrix.Anchor")

function Matrix.OnFrameCreate()
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("MATRIX_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	this:RegisterEvent("PARTY_UPDATE_MEMBER_INFO")
	this:RegisterEvent("PARTY_DISBAND")
	this:RegisterEvent("PARTY_DELETE_MEMBER")
	this:RegisterEvent("PARTY_SET_FORMATION_LEADER")
	
	Matrix.TestLearnedFormation(this)
	
	Matrix.UpdateAnchor(this)
	Matrix.UpdateCustomModeWindow(this)
end

function Matrix.UpdateCustomModeWindow(this)
	UpdateCustomModeWindow(this, g_tStrings.MATRIX)
	this:EnableDrag(true)
end

function Matrix.OnFrameDrag()
end

function Matrix.OnFrameDragSetPosEnd()
end

function Matrix.OnFrameDragEnd()
	this:CorrectPos()
	Matrix.Anchor = GetFrameAnchor(this)
end

function Matrix.UpdateAnchor(frame)
	frame:SetPoint(Matrix.Anchor.s, 0, 0, Matrix.Anchor.r, Matrix.Anchor.x, Matrix.Anchor.y)
	frame:CorrectPos()
end

function Matrix.OnEvent(event)
	if event == "SKILL_UPDATE" then
		Matrix.TestLearnedFormation(this)
	elseif event == "SYNC_ROLE_DATA_END" then
		Matrix.TestLearnedFormation(this)
	elseif event == "UI_SCALED" then
		Matrix.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		Matrix.UpdateCustomModeWindow(this)
	elseif event == "MATRIX_ANCHOR_CHANGED" then
		Matrix.UpdateAnchor(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		Matrix.UpdateAnchor(this)
	elseif event == "PARTY_DISBAND" then
		this.dwFormationLeader = nil
	elseif event == "PARTY_DELETE_MEMBER" then
		local hPlayer = GetClientPlayer()
		if arg1 == hPlayer.dwID then
			this.dwFormationLeader = nil
		end
	elseif event == "PARTY_UPDATE_MEMBER_INFO"
	or event == "PARTY_SET_FORMATION_LEADER" then
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.IsInParty() then
			local hTeam = GetClientTeam()
			local nGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
			local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
			this.dwFormationLeader = tGroupInfo.dwFormationLeader
		else
			this.dwFormationLeader = nil
		end
	end
end

function Matrix.TestLearnedFormation(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local aSkill = player.GetAllSkillList()
	if not aSkill then
		return
	end
	
	for k, v in pairs(aSkill) do
		local skill = GetSkill(k, v)
		if skill.dwBelongKungfu ~= 0 and Table_IsSkillFormationCaster(k, v) then
			frame.bLearn = true
			return
		end
	end
	frame.bLearn = false
end

function Matrix.OnFrameBreathe()
	if not Matrix.bShowMatrix or not this.dwFormationLeader then
		this:Hide()
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local dwSchool = nil
	if this.dwFormationLeader == player.dwID then --如果自己是阵眼
		if not this.bLearn then
		elseif player.dwFormationEffectID == 0 then
			local skillKungfu = player.GetKungfuMount()
			dwSchool = skillKungfu.dwBelongSchool
		else
			local skill = GetSkill(player.dwFormationEffectID, 1)
			if skill then
				dwSchool = skill.dwBelongSchool
			else
				local skillKungfu = player.GetKungfuMount()
				dwSchool = skillKungfu.dwBelongSchool
			end
		end
	else
		if player.dwFormationEffectID ~= 0 then
			local skill = GetSkill(player.dwFormationEffectID, 1)
			if skill then
				dwSchool = skill.dwBelongSchool
			end
		end
	end
	
	if not dwSchool or not Matrix.aInfo[dwSchool] then
		this:Hide()
		return
	end
	this:Show()
	
	local handle = this:Lookup("", "")
	local nSize = GetClientTeam().GetTeamOnlineMemberCount()
	if nSize ~= handle.nSize then
		handle.nSize = nSize
		for i = 1, nSize, 1 do
			local ani = handle:Lookup("Animate_P"..i)
			if ani then
				ani:Show()
			end
		end
		for i = nSize + 1, 5, 1 do
			local ani = handle:Lookup("Animate_P"..i)
			if ani then
				ani:Hide()
			end
		end
	end
	
	if dwSchool ~= handle.dwSchool or player.nFormationEffectLevel ~= handle.nFormationEffectLevel then
		handle.dwSchool = dwSchool
		handle.nFormationEffectLevel = player.nFormationEffectLevel
		local aInfo = Matrix.aInfo[dwSchool]
		local szPath = aInfo.aBg[player.nFormationEffectLevel] or aInfo.aBg[1]
		local szAnimate = Matrix.aAnimate[player.nFormationEffectLevel] or Matrix.aAnimate[1]
		handle:Lookup("Image_Bg"):FromTextureFile(Matrix.Path..szPath)
		local a = handle:Lookup("Animate_Bg")
		if aInfo.bAnimateBg then
			a:Show()
		else
			a:Hide()
		end
		local nLoop = -1
		if player.dwFormationEffectID == 0 then
			nLoop = 0 
		end
		a:SetAnimate("ui/Image/Common/"..szAnimate, 1, nLoop)
		a:SetRelPos(aInfo.AnimateBgPos[1], aInfo.AnimateBgPos[2])
		a = handle:Lookup("Animate_Skill")
		a:SetAnimate("ui/Image/Common/"..szAnimate, 0, -1)
		a:AutoSize()
		a:SetRelPos(aInfo.AnimatePos[1], aInfo.AnimatePos[2])
		handle:Lookup("Box_Skill"):SetRelPos(aInfo.BoxPos[1], aInfo.BoxPos[2])
		handle:Lookup("Image_Over"):SetRelPos(aInfo.BoxPos[1], aInfo.BoxPos[2])
		for i = 1, 5, 1 do
			local animateP = handle:Lookup("Animate_P"..i)
			if animateP then
				local nFrame = nil
				if i == 1 then
					nFrame = 2
				else
					nFrame = 3
				end
				animateP:SetRelPos(aInfo.aPoint[i][1], aInfo.aPoint[i][2])
				animateP:SetAnimate("ui/Image/Common/"..szAnimate, nFrame, -1)
				animateP:AutoSize()
			end
		end
		handle:FormatAllItemPos()
	end
	
	if player.dwFormationEffectID ~= handle.dwID then
		handle.dwID = player.dwFormationEffectID
		if player.dwFormationEffectID == 0 then
			handle:Lookup("Box_Skill"):ClearObject()
			handle:Lookup("Animate_Bg"):SetLoopCount(0)
			handle:Lookup("Animate_Skill"):Hide()
		else
			local box = handle:Lookup("Box_Skill")
			box.dwID, box.dwLevel = player.dwFormationEffectID, 1
			box:SetObject(UI_OBJECT_SKILL, box.dwID, box.dwLevel)
			box:SetObjectIcon(Table_GetSkillIconID(box.dwID, box.dwLevel))
			handle:Lookup("Animate_Bg"):SetLoopCount(-1)
			handle:Lookup("Animate_Skill"):Show()
		end
	end
	
	if dwFormation == player.dwID then -- 自己是阵眼
		local hBox = handle:Lookup("Box_Skill")
		FireHelpEvent("OnOpenpanel", "MATRIX", hBox)
	end
end

function Matrix.OnItemMouseEnter()
	if this:GetRoot().dwFormationLeader == GetClientPlayer().dwID then
		this:GetParent():Lookup("Image_Over"):Show()
	end

	if not this:IsEmpty() then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		if player then
			local szTip = "<text>text="..EncodeComponentsString(Table_GetSkillName(player.dwFormationEffectID, 1).."\n").." font=31 </text>" 
			
			szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.SCHOOL_FORMATION.."\n").." font=31 </text>" 
			for i = 1, 7, 1 do
				local szDesc = Table_GetSkillDesc(player.dwFormationEffectID, i)
				local nFont = 107
				if i <= player.nFormationEffectLevel then
					nFont = 100
				end
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.tFormationTitle[i]..szDesc.."\n").." font="..nFont.." </text>"
			end
			
			local szDesc = Table_GetSkillDesc(player.dwMentorFormationEffectID, 1)
			if szDesc and szDesc ~= "" then
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.FORMATION_SPLIT.."\n").." font=31 </text>" 
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.MENTOR_FORMATION.."\n").." font=31 </text>" 
				local nFont = 107
				if player.nMentorFormationEffectLevel >= 1 then
					nFont = 100
				end
				szTip = szTip.."<text>text="..EncodeComponentsString(szDesc.."\n").." font="..nFont.." </text>"				
			end
			
			OutputTip(szTip, 10000, {x, y, w, h})
		end
	end
end

function Matrix.OnItemMouseLeave()
	this:GetParent():Lookup("Image_Over"):Hide()
	HideTip()
end

function Matrix.OnItemLButtonDown()
end

function Matrix.OnItemLButtonUp()
end

function Matrix.OnItemLButtonClick()
	if this:GetRoot().dwFormationLeader == GetClientPlayer().dwID then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OpenFormationPanel({x, y, w, h})
	end
end

function Matrix.OnItemRButtonDown()
	Matrix.OnItemLButtonDown()
end

function Matrix.OnItemRButtonUp()
	Matrix.OnItemLButtonUp()
end

function Matrix.OnItemRButtonClick()
	Matrix.OnItemLButtonClick()
end

function IsShowMatrix()
	return Matrix.bShowMatrix
end

function SetShowMatrix(bShow)
	Matrix.bShowMatrix = bShow
end

function Matrix_SetAnchorDefault()
	Matrix.Anchor.s = Matrix.DefaultAnchor.s
	Matrix.Anchor.r = Matrix.DefaultAnchor.r
	Matrix.Anchor.x = Matrix.DefaultAnchor.x
	Matrix.Anchor.y = Matrix.DefaultAnchor.y
	FireEvent("MATRIX_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", Matrix_SetAnchorDefault)

function Matrix_Load()
	local szIniFile = GetUserDataPath()
	if szIniFile == "" then
		return
	end
	szIniFile = szIniFile.."\\PannelSave.ini"

	local iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end
	
	local szSection = "MatrixPanel"	
	
	local value = iniS:ReadString(szSection, "SelfSide", Matrix.Anchor.s)
	if value then
		Matrix.Anchor.s = value
	end
	value = iniS:ReadString(szSection, "RelSide", Matrix.Anchor.r)
	if value then
		Matrix.Anchor.r = value
	end
	value = iniS:ReadInteger(szSection, "RelX", Matrix.Anchor.x)
	if value then
		Matrix.Anchor.x = value
	end
	value = iniS:ReadInteger(szSection, "RelY", Matrix.Anchor.y)
	if value then
		Matrix.Anchor.y = value
	end
	
	value = iniS:ReadInteger(szSection, "ShowMatrix", 1)
	SetShowMatrix(value and value ~= 0)
		
	iniS:Close()
end

RegisterLoadFunction(Matrix_Load)
