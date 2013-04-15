ChannelsPanel = 
{

bShowName = true,

bMakeSure = true,

Group = {"Ren", "Du", "Dai", "Chong"},

Ren = 
{
	Huiyin = 60,
	Yutang = 77,
	Zigong = 78,
	Yinjiao = 86,
	Duiduan = 84,
	Chengjiang = 85,
	Xuanji = 80,
	Lianquan = 83,
	Huagai = 79,
	Tiantu = 82,
	Shuigou = 1196,
	Shenting = 88,
	Shangxing = 89,
	Suliao = 87,
	Qianding = 90,
	Yankou = 1571,
	QixueQiduan = 40,
	Jianli = 70,
	Yinjiao2 = 66,
	Shimen = 65,
	Guanyuan = 64,
	Dihe = 1572,
	Sanxiao = 1573,
	Xiawan = 1961,
	Zhongwan = 1962,
	Jiuwei = 1965,
	Tanzhong = 1966,
	Qugu = 1960,
	Juque = 1964,
	Shangwan = 1963,
	QixueChonggu = 1206,
	Shuifen = 68,
	Zhongji = 1958,
	Zhongting = 75,
	Shenque = 1959,
	QixueXiajiyu = 9,	
},

Du = 
{
	Yaoyu = 92,
	Changqiang = 91,
	Zhiyang = 98,
	Jingsuo = 97,
	Zhongshu = 96,
	Fengfu = 114,
	Baihui = 117,
	QixueQingzhong = 43,
	Mingmen = 93,
	Taodao = 1949,
	Xinhui = 1950,
	Qiangjian = 1951,
	Qianding = 1952,
	Shendao = 110,
	Yamen = 113,
	Houding = 116,
	QixueTaijian = 42,
	Shenzhu = 111,
	Jizhong = 95,
	Lingtai = 99,
	Dazhui = 112,
	Naonu = 115,
	QixueYaoyan = 41,
},

Dai = 
{
	Wushu = 118,
	Tianchong = 126,
	Muchuang = 120,
	Chengling = 128,
	Guangming = 153,
	Xuanzhong = 155,
	QixueLongxuan = 45,
	Weidao = 127,
	Fubai = 121,
	Wangu = 122,
	Benshen = 123,
	Yangbai = 124,
	Zhengying = 119,
	Naokong = 129,
	Waiqiu = 154,
	QixueQuquan = 44,
},

Chong =
{
	Qichong = 156,
	Dahe = 163,
	Shangqu = 158,
	Yindu = 165,
	Youmen = 167,
	Taiyi = 169,
	QixueHeyang = 170,
	Henggu = 164,
	Mangyu = 162,
	Zhongzhu = 161,
	Siman = 160,
	Qixue = 159,
	Siguan = 157,
	Tonggu = 166,
	Guanmen = 168,
	QixueJiquan = 46,
},

}

RegisterCustomData("ChannelsPanel.bShowName")
RegisterCustomData("ChannelsPanel.bMakeSure")

function ChannelsPanel.OnFrameCreate()
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("UI_TRAIN_VALUE_UPDATE")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("ON_OPEN_VENATION_RETCODE")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ON_GET_SKILL_LEVEL_RESULT")
	this:RegisterEvent("ON_GET_TRAIN_RESULT")
	this:RegisterEvent("UI_SCALED")
	
	local c = this:Lookup("CheckBox_ShowAll")
	if c then
		c:Check(ChannelsPanel.bShowName)
	end	
	
	c = this:Lookup("CheckBox_Sure")
	if c then
		c:Check(ChannelsPanel.bMakeSure)
	end
	
	ChannelsPanel.OnEvent("UI_SCALED")
end

function ChannelsPanel.OnEvent(event)
	if event == "SKILL_UPDATE" then
		if this:IsVisible() and VenationType[arg0] then
			ChannelsPanel.Update(this)
		end
	elseif event == "UI_TRAIN_VALUE_UPDATE" then
		if this:IsVisible() then
			ChannelsPanel.Update(this)
		end
	elseif event == "PLAYER_LEVEL_UPDATE" then
		if this:IsVisible() and arg0 == GetClientPlayer().dwID then
			ChannelsPanel.Update(this)
		end
	elseif event == "ON_OPEN_VENATION_RETCODE" then
		if this:IsVisible() then
			ChannelsPanel.Update(this)
		end
	elseif event == "CUSTOM_DATA_LOADED" then
		local c = this:Lookup("CheckBox_ShowAll")
		if c then
			c:Check(ChannelsPanel.bShowName)		
		end
		c = this:Lookup("CheckBox_Sure")
		if c then
			c:Check(ChannelsPanel.bMakeSure)
		end		
		if this:IsVisible() then
			ChannelsPanel.Update(this)
		end
	elseif event == "ON_GET_SKILL_LEVEL_RESULT" then
		if arg0 == ChannelsPanel.dwPlayerID then
			ChannelsPanel.aSkill = ChannelsPanel.aSkill or {}
			local t = arg1 or {}
			for k, v in pairs(t) do
				ChannelsPanel.aSkill[k] = v
			end
			if this:IsVisible() then
				ChannelsPanel.Update(this)
			end
		end
	elseif event == "ON_GET_TRAIN_RESULT" then
		if arg0 == ChannelsPanel.dwPlayerID then
			ChannelsPanel.nCurrentTrainValue, ChannelsPanel.nMaxTrainValue, ChannelsPanel.nUsedTrainValue, ChannelsPanel.nMaxUsedTrainValue, ChannelsPanel.nGongliValue = arg1, arg2, arg3, arg4, arg5 
			if this:IsVisible() then
				ChannelsPanel.Update(this)
			end
		end
		
	elseif event == "UI_SCALED" then
--[[	
		local wC, hC = Station.GetClientSize(false)
		local w, h = this:GetSize()
		local wFact, hFact = Station.OriginalToAdjustPos(w, h)
		
		local fScale = wC / wFact
		if hFact * fScale > hC then
			fScale = hC / hFact
		end
		if wFact * fScale > 1280 then
			fScale = 1280 / wFact
		end
		if fScale ~= 1 then
			this:Scale(fScale, fScale)
		end	
]]
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function ChannelsPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseChannelsPanel()
	elseif this.dwID then
		if IsCtrlKeyDown() then
		 	local dwID = this.dwID
		 	local player = GetClientPlayer()
		 	local dwLevel = player.GetSkillLevel(dwID)
		 	if dwLevel == 0 then
		 		dwLevel = 1
		 	end
			if IsGMPanelReceiveSkill() then
				GMPanel_LinkSkill(dwID, dwLevel)
			else
				EditBox_AppendLinkSkill(player.GetSkillRecipeKey(dwID, dwLevel))
			end
		elseif not this.bMax then
			if this.bCanOpen then
				if ChannelsPanel.bMakeSure then
				 	local dwID = this.dwID
				 	local player = GetClientPlayer()
				 	local dwLevel = player.GetSkillLevel(dwID) + 1
				 	local skill = GetSkill(dwID, dwLevel)
			 		local szDesc = g_tStrings.STR_TWO_CHINESE_SPACE..Table_GetSkillName(dwID, dwLevel)..FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL1, dwLevel)
							 	
					if VenationCost[dwID] and VenationCost[dwID][dwLevel] then
						local nCost = GetActualCostTrain(player, VenationCost[dwID][dwLevel])
						nCost = math.floor(nCost)
						szDesc = szDesc..g_tStrings.STR_COMMA..g_tStrings.STR_LEARN_COST_VENATION..nCost..g_tStrings.STR_COMMA
					end
						
					szDesc = szDesc.."\n"..g_tStrings.MSG_VENATION_GET_SURE
					
					local dwID = this.dwID
					local msg = 
					{
						szMessage = szDesc, 
						szName = "OpenVenationSure", 
						fnAutoClose = function() return not IsChannelsPanelOpened() end,
						{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().OpenVenation(dwID) end},
						{szOption = g_tStrings.STR_HOTKEY_CANCEL }
					}
					MessageBox(msg)
				else
					local dwID = this.dwID
					GetClientPlayer().OpenVenation(dwID)
				end
			else
				local szMsg = g_tStrings.ERR_OPEN_VENATION_GET_NOT_SATISFLED
				if this.nError == ERR_OPEN_VENATION_LEVEL_LOWER then
					szMsg = g_tStrings.ERR_OPEN_VENATION_LEVEL_LOWER
				elseif this.nError == ERR_OPEN_VENATION_NOT_ENOUGH_TRAIN then
					szMsg = g_tStrings.ERR_OPEN_VENATION_NOT_ENOUGH_TRAIN
				elseif this.nError == ERR_OPEN_VENATION_NOT_OPEN then
					szMsg = g_tStrings.ERR_OPEN_VENATION_NOT_OPEN
				elseif this.nError == ERR_OPEN_VENATION_LIMIT_TRAIN then
					szMsg = g_tStrings.ERR_OPEN_VENATION_LIMIT_TRAIN
				end
				OutputMessage("MSG_ANNOUNCE_RED", szMsg)
			end
		end
	end
end

function ChannelsPanel.OnMouseEnter()
	if this.dwID then
	 	local szTip = ""
	 	local x, y = this:GetAbsPos()
	 	local w, h = this:GetSize()
	 	local dwID = this.dwID
	 	local player = GetClientPlayer()
	 	local dwLevel = player.GetSkillLevel(dwID)
	 	if ChannelsPanel.dwPlayerID then
	 		dwLevel = ChannelsPanel.aSkill[dwID] or 0
	 	end
	 	local dwShowLevel = dwLevel
	 	if dwShowLevel == 0 then
	 		dwShowLevel = 1
	 	end
	 	local skill = GetSkill(dwID, dwShowLevel)
	 	
		szTip = szTip.."<text>text="..EncodeComponentsString(Table_GetSkillName(dwID, dwShowLevel)).." font=31 </text><text>text="
		
		if ChannelsPanel.dwPlayerID then
			szTip = szTip..EncodeComponentsString(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, dwLevel.."/"..skill.dwMaxLevel)).." font=61 </text><text>text="
				..EncodeComponentsString(FormatString(g_tStrings.STR_MY_LEVEL, player.GetSkillLevel(dwID).."/"..skill.dwMaxLevel)).." font=61 </text>"
				.."<text>text="..EncodeComponentsString(g_tStrings.STR_NEXT_LEVEL).." font=106 </text>"
		else
			szTip = szTip..EncodeComponentsString(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL, dwShowLevel.."/"..skill.dwMaxLevel)).." font=61 </text>"
		end
		
		if dwLevel ~= 0 then
			local skillkey = player.GetSkillRecipeKey(dwID, dwLevel)
			local skillInfo = GetSkillInfo(skillkey)
			local szDesc = GetSkillDesc(dwID, dwLevel, skillkey, skillInfo)
			if szDesc ~= "" then
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.CURRENT_LEVEL).." font=106 </text>"
				szTip = szTip.."<text>text="..EncodeComponentsString(szDesc.."\n").." font=100 </text>"
			end
			if dwLevel == skill.dwMaxLevel then
				szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.STR_SKILL_H_TOP_LEAVEL).." font=106 </text>"
				OutputTip(szTip, 300, {x, y, w, h})
				return
			end
			szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.STR_NEXT_LEVEL).." font=106 </text>"
		end
		
		dwLevel = dwLevel + 1

		if VenationRequireLevel[dwID] then
			local nFont = 106
			if VenationRequireLevel[dwID] > player.nLevel then
				nFont = 102
			end
			szTip = szTip.."<text>text="..EncodeComponentsString(g_tStrings.STR_LEARN_NEED_LEVEL1).." font=106</text>"
			szTip = szTip.."<text>text="..EncodeComponentsString(VenationRequireLevel[dwID]).." font="..nFont.."</text>"
		end
		if VenationCost[dwID] and VenationCost[dwID][dwLevel] then
			local nFont = 106
			local nCost = math.floor(GetActualCostTrain(player, VenationCost[dwID][dwLevel]))
			if nCost > player.nCurrentTrainValue then
				nFont = 102
			end
			if VenationRequireLevel[dwID] then
				szTip = szTip.."<text>text=\"\\\t\" font=106 </text>"
			end
			szTip = szTip.."<handle>handletype=3<text>text="..EncodeComponentsString(g_tStrings.STR_LEARN_COST_VENATION).." font=106</text>"
				.."<text>text="..EncodeComponentsString(nCost.."\n").." font="..nFont.."</text></handle>"
		end
		szTip = szTip.."<text>text=\"\\\n\" font=106 </text>"
		
		if VenationRequireGongli[dwID] and VenationRequireGongli[dwID] ~= 0 then			
			local nFont = 106
			if VenationRequireGongli[dwID] > GetGongliCount(player) then
				nFont = 102
			end
			szTip = szTip.."<handle>handletype=3<text>text="..EncodeComponentsString(g_tStrings.STR_NEED_GONGLI).." font=106</text>"
				.."<text>text="..EncodeComponentsString(VenationRequireGongli[dwID]).." font="..nFont.."</text></handle><text>text=\"\\\n\" font=106 </text>"
		end

		if VenationRequirement[dwID] and #(VenationRequirement[dwID]) ~= 0 then
			local v = VenationRequirement[dwID]
			local szMsg = g_tStrings.STR_NEED_GET_THROUGH
			szTip = szTip.."<text>text="..EncodeComponentsString(szMsg).." font=106 </text>"
			local szNeed = ""
			local nFont = 102
			for i, vSkill in ipairs(v) do
				if i ~= 1 then
					szNeed = szNeed..g_tStrings.STR_COMMA
				end
				if player.GetSkillLevel(vSkill.ID) >= vSkill.Level then
					nFont = 106
				end
				szNeed = szNeed..FormatString(g_tStrings.STR_LEARN_SKILL_LEVEL, Table_GetSkillName(vSkill.ID, vSkill.Level), vSkill.Level)
			end
			if #v > 1 then
				szNeed = szNeed..g_tStrings.STR_ONE_OF
			end
			if szNeed ~= "" then
				szTip = szTip.."<text>text="..EncodeComponentsString(szNeed.."\n").." font="..nFont.." </text>"
			end
		end
				
		local skillkey = player.GetSkillRecipeKey(dwID, dwLevel)
		local skillInfo = GetSkillInfo(skillkey)
		local szDesc = GetSkillDesc(dwID, dwLevel, skillkey, skillInfo)
		if szDesc ~= "" then
			szTip = szTip.."<text>text="..EncodeComponentsString(szDesc).." font=100 </text>"
		end
		OutputTip(szTip, 300, {x, y, w, h})
	end
end

function ChannelsPanel.OnMouseLeave()
	HideTip()
end

function ChannelsPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_ShowAll" then
		ChannelsPanel.bShowName = true
		ChannelsPanel.Update(this:GetRoot())
	elseif szName == "CheckBox_Sure" then
		ChannelsPanel.bMakeSure = true
	end
end

function ChannelsPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_ShowAll" then
		ChannelsPanel.bShowName = false
		ChannelsPanel.Update(this:GetRoot())
	elseif szName == "CheckBox_Sure" then
		ChannelsPanel.bMakeSure = false
	end
end

function ChannelsPanel.Update(frame)
	if ChannelsPanel.dwPlayerID then
		ChannelsPanel.UpdateChannelsOther(frame)
		ChannelsPanel.UpdateTrainValueOther(frame)
		
		local c = frame:Lookup("CheckBox_Sure")
		if c then
			c:Hide()
		end
	else
		ChannelsPanel.UpdateChannels(frame)
		ChannelsPanel.UpdateTrainValue(frame)
		
		local c = frame:Lookup("CheckBox_Sure")
		if c then
			c:Show()
			c:Check(ChannelsPanel.bMakeSure)
		end
	end
end

function ChannelsPanel.UpdateChannels(frame)	
	local player = GetClientPlayer()
	
	local handle = frame:Lookup("", "")
	local hName = handle:Lookup("Handle_Name")
	if hName then
		hName:Show(ChannelsPanel.bShowName)
	end	
	
	local aGroup = ChannelsPanel.Group or {}
	for i, szGroupName in ipairs(aGroup) do
		local aChannel = ChannelsPanel[szGroupName] or {}
		local hGroup = handle:Lookup("Handle_"..szGroupName)
		for szChannel, dwID in pairs(aChannel) do
			local szPosfix = szGroupName..szChannel
			local btn = frame:Lookup("Btn_"..szPosfix)
			local text = hGroup:Lookup("Text_"..szPosfix)
			local bShowImage = false
			btn.dwID = dwID
			local nLevel = player.GetSkillLevel(btn.dwID)
			btn.bCanOpen, btn.nError = CanOpenVenation(player, btn.dwID)
			btn.bMax = false
			if nLevel >= 1 or btn.bCanOpen then
				btn:Enable(true)
				if text then
					text:Show()
					text:SetText(nLevel)
				end
				if nLevel == 0 then
					if text then
						text:SetFontScheme(186)
					end
				else
					local skill = GetSkill(btn.dwID, nLevel)
					if nLevel == skill.dwMaxLevel then
						btn.bMax = true
						if text then
							text:SetFontScheme(185)
						end
					else
						if text then
							text:SetFontScheme(186)
						end
					end
					bShowImage = true
				end
			else
				btn:Enable(false)
				if text then
					text:Hide()
				end
			end
			local szPrefix = "Image_"..szPosfix.."0"
			for n = 1, 9 do
				local img = hGroup:Lookup(szPrefix..n)
				if img then
					img:Show(bShowImage)
				else
					break
				end
			end
		end	
	end 	
end

function ChannelsPanel.GetOtherPlayerChannelInfo()
	local aSkill = {}
	local aGroup = ChannelsPanel.Group or {}
	for i, szGroupName in ipairs(aGroup) do
		local aChannel = ChannelsPanel[szGroupName] or {}
		for szChannel, dwID in pairs(aChannel) do
			table.insert(aSkill, dwID)
		end
	end
	RemoteCallToServer("OnGetSkillLevelRequest", ChannelsPanel.dwPlayerID, aSkill)
end

function ChannelsPanel.UpdateChannelsOther(frame)
	local player = GetClientPlayer()
	
	local handle = frame:Lookup("", "")
	local hName = handle:Lookup("Handle_Name")
	if hName then
		hName:Show(ChannelsPanel.bShowName)
	end	
	
	local aSkill = ChannelsPanel.aSkill
	
	local aGroup = ChannelsPanel.Group or {}
	for i, szGroupName in ipairs(aGroup) do
		local aChannel = ChannelsPanel[szGroupName] or {}
		local hGroup = handle:Lookup("Handle_"..szGroupName)
		for szChannel, dwID in pairs(aChannel) do
			local szPosfix = szGroupName..szChannel
			local btn = frame:Lookup("Btn_"..szPosfix)
			local text = hGroup:Lookup("Text_"..szPosfix)
			local bShowImage = false
			btn.dwID = dwID
			local nLevel = ChannelsPanel.aSkill[btn.dwID] or 0
			btn.bCanOpen, btn.nError = false, 0
			btn.bMax = false
			if nLevel >= 1 or btn.bCanOpen then
				btn:Enable(true)
				if text then
					text:Show()
					text:SetText(nLevel.."("..player.GetSkillLevel(btn.dwID)..")")
				end
				if nLevel == 0 then
					if text then
						text:SetFontScheme(186)
					end
				else
					local skill = GetSkill(btn.dwID, nLevel)
					if nLevel == skill.dwMaxLevel then
						btn.bMax = true
						if text then
							text:SetFontScheme(185)
						end
					else
						if text then
							text:SetFontScheme(186)
						end
					end
					bShowImage = true
				end
			else
				btn:Enable(false)
				if text then
					text:Show()
					text:SetText(nLevel.."("..player.GetSkillLevel(btn.dwID)..")")
					text:SetFontScheme(186)
				end
			end
			local szPrefix = "Image_"..szPosfix.."0"
			for n = 1, 9 do
				local img = hGroup:Lookup(szPrefix..n)
				if img then
					img:Show(bShowImage)
				else
					break
				end
			end
		end
	end
end

function ChannelsPanel.UpdateTrainValue(frame)
	local handle = frame:Lookup("", "Handle_Train")
	local player = GetClientPlayer()
	handle:Lookup("Text_QH_Value"):SetText(player.nCurrentTrainValue.."/"..player.nMaxTrainValue)
	handle:Lookup("Image_QH"):SetPercentage(player.nCurrentTrainValue / player.nMaxTrainValue)
	local nMin, nMax = CalcVenationTrainvalue(player)
	handle:Lookup("Text_DT_Value"):SetText(nMin.."/"..nMax)
	handle:Lookup("Image_DT"):SetPercentage(nMin / nMax)
	handle:Lookup("Text_GL_Value"):SetText(GetGongliCount(player))
	--handle:Lookup("Image_GL"):SetPercentage()
end

function ChannelsPanel.UpdateTrainValueOther(frame)
	local nCurrentTrainValue, nMaxTrainValue, nUsedTrainValue, nMaxUsedTrainValue, nGongliValue = 
		ChannelsPanel.nCurrentTrainValue, ChannelsPanel.nMaxTrainValue, ChannelsPanel.nUsedTrainValue, ChannelsPanel.nMaxUsedTrainValue, ChannelsPanel.nGongliValue
	if not nCurrentTrainValue or not nMaxTrainValue or not nUsedTrainValue or not nMaxUsedTrainValue or not nGongliValue then
		RemoteCallToServer("GetTerainRequest", ChannelsPanel.dwPlayerID)
		nCurrentTrainValue, nMaxTrainValue, nUsedTrainValue, nMaxUsedTrainValue, nGongliValue = 0, 0, 0, 0, 0
	end

	local handle = frame:Lookup("", "Handle_Train")
	local player = GetClientPlayer()
	handle:Lookup("Text_QH_Value"):SetText(nCurrentTrainValue.."/"..nMaxTrainValue.."\n("..player.nCurrentTrainValue.."/"..player.nMaxTrainValue..")")
	handle:Lookup("Image_QH"):SetPercentage(nCurrentTrainValue / nMaxTrainValue)
	local nMin, nMax = CalcVenationTrainvalue(player)
	handle:Lookup("Text_DT_Value"):SetText(nUsedTrainValue.."/"..nMaxUsedTrainValue.."\n("..nMin.."/"..nMax..")")
	handle:Lookup("Image_DT"):SetPercentage(nUsedTrainValue / nMaxUsedTrainValue)
	handle:Lookup("Text_GL_Value"):SetText(nGongliValue.."\n("..GetGongliCount(player)..")")
	--handle:Lookup("Image_GL"):SetPercentage()
end

function IsChannelsPanelOpened()
	local frame = Station.Lookup("Normal/ChannelsPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenChannelsPanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	ChannelsPanel.dwPlayerID = nil
	ChannelsPanel.aSkill = {}
	ChannelsPanel.nCurrentTrainValue = nil
	ChannelsPanel.nMaxTrainValue = nil
	ChannelsPanel.nUsedTrainValue = nil
	ChannelsPanel.nMaxUsedTrainValue = nil
	ChannelsPanel.nCurrentGongliValue = nil
	ChannelsPanel.nMaxGongliValue = nil	

	local frame = Wnd.OpenWindow("ChannelsPanel")
	frame:Show()
	frame:CorrectPos()
	frame:BringToTop()
	ChannelsPanel.Update(frame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseChannelsPanel(bDisableSound)
	if not IsChannelsPanelOpened() then
		return
	end
	
	local frame = Station.Lookup("Normal/ChannelsPanel")
	frame:Hide()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function ViewOtherPlayerChannels(dwPlayerID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end
	
	ChannelsPanel.dwPlayerID = dwPlayerID
	ChannelsPanel.aSkill = {}
	ChannelsPanel.nCurrentTrainValue = nil
	ChannelsPanel.nMaxTrainValue = nil
	ChannelsPanel.nUsedTrainValue = nil
	ChannelsPanel.nMaxUsedTrainValue = nil
	ChannelsPanel.nCurrentGongliValue = nil
	ChannelsPanel.nMaxGongliValue = nil
		
	local frame = Wnd.OpenWindow("ChannelsPanel")
	frame:Show()
	ChannelsPanel.Update(frame)
	ChannelsPanel.GetOtherPlayerChannelInfo()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end
