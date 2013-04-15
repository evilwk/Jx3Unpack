----------------------------------------------------------------------
-- 活动农场界面
-- Date:	2010.06.01
-- Author:	Danexx
-- Comment:	我在黄昏的堤岸来回踱步. 我想回忆起我曾经丢掉的日记. 

--《绝世小攻》

-- 一朝离了课堂 为勾引大叔装纯良 
-- 无奈他刚转性向 就引来耽美狼一筐 
-- 柔弱却假装刚强 精明外表是包装 
-- 看我玩转各手段 吃干抹尽在床上 

-- 我是可爱小攻我怕谁 邪恶腹黑假善良 
-- 脸蛋够清纯 手段够YD 
-- 千方百计折腾你到泪汪汪 

-- 春药我偷偷藏 万里追踪到你身旁 
-- 故意跌倒喊受伤 无辜眼神让你心慌 

-- 受：你。。你。。你要干什么 
-- 攻：哈哈哈哈 别怕 难道不知道现在流行年下么 

-- 话说我褪去纯情的伪装 只把大叔到床中央 
-- 一步一压倒 欲望我眼中烧 
-- 衣衫凌乱黑发飞散风情饶 
-- 别说你什么步骤都不知晓 H就要H到腰腿都酸掉 
-- 反攻太遥远 乖乖配合好 
-- 春光无限春意盎然春色无止休 

-- 小受一落入我手 乖乖屈服眼泪流 
-- 欺负从没有尽头 手铐皮鞭暖炕头 

-- 受：这就是所谓的真攻不露相 露相非真攻么？ 
-- 攻：哈哈哈哈哈 顺我者娼 逆我者亡 

-- 我是可爱小攻我怕谁 邪恶腹黑假善良 
-- 脸蛋够清纯 手段够YD 
-- 千方百计折腾你到泪汪汪 

-- 床上偶尔兽性狂 床下阳光少年郎 
-- 可爱无敌外表装 小恶魔本质被隐藏 
-- 年下诱惑功力谁能比我强 
-- 想要拜师学艺只需呈上三百两
----------------------------------------------------------------------

FarmPanel = FarmPanel or {}
FarmPanel.frameSelf = nil;
FarmPanel.handleAttentionList = nil
FarmPanel.handleRandomList = nil
FarmPanel.handleLastSelectTong = nil;
FarmPanel.dwLastSelectTongID = nil;

FarmPanel.tFarmBuffInfo = {}
FarmPanel.tAttentionTongIDList = {}
FarmPanel.tRandomTongIDList = {}
FarmPanel.bShowTip = true					RegisterCustomData("FarmPanel.bShowTip")

local FARMBUFF = {}
FARMBUFF.KEEPTIME = GLOBAL.GAME_FPS * 3600 * 72
local FARM_MAPID = 58
local REF_CD_MAX = 16 * 60 + 1
local SEED_IMAGE_LIST = {
	{18, 17, 25},
	{20, 16, 21},
	{19, 15, 22},
	{26, 24, 23},
}

local tSoilPos = {							-- 30个编号对应的三维坐标和朝向 
	[1] = {nX = 14616, nY = 7645, nZ = 1139393, nFace = 65}, 
	[2] = {nX = 14619, nY = 8037, nZ = 1139393, nFace = 65}, 
	[3] = {nX = 14616, nY = 8425, nZ = 1139393, nFace = 65}, 
	[4] = {nX = 14616, nY = 8799, nZ = 1139393, nFace = 65}, 
	[5] = {nX = 14616, nY = 9191, nZ = 1139393, nFace = 65}, 
	[6] = {nX = 15177, nY = 9191, nZ = 1139393, nFace = 65}, 
	[7] = {nX = 15177, nY = 8799, nZ = 1139393, nFace = 65}, 
	[8] = {nX = 15177, nY = 8425, nZ = 1139393, nFace = 65}, 
	[9] = {nX = 15177, nY = 8037, nZ = 1139393, nFace = 65}, 
	[10] = {nX = 15177, nY = 7645, nZ = 1139393, nFace = 65}, 
	
	[11] = {nX = 8242, nY = 9684, nZ = 1144000, nFace = 125}, 
	[12] = {nX = 7852, nY = 9684, nZ = 1144000, nFace = 125}, 
	[13] = {nX = 7475, nY = 9684, nZ = 1144000, nFace = 125}, 
	[14] = {nX = 7071, nY = 9684, nZ = 1144000, nFace = 125}, 
	[15] = {nX = 6675, nY = 9684, nZ = 1144000, nFace = 125}, 
	[16] = {nX = 6675, nY = 10214, nZ = 1144000, nFace = 125}, 
	[17] = {nX = 7071, nY = 10214, nZ = 1144000, nFace = 125}, 
	[18] = {nX = 7475, nY = 10214, nZ = 1144000, nFace = 125}, 
	[19] = {nX = 7852, nY = 10214, nZ = 1144000, nFace = 125}, 
	[20] = {nX = 8242, nY = 10214, nZ = 1144000, nFace = 125}, 
		
	[21] = {nX = 24669, nY = 4761, nZ = 1124416, nFace = 132},
	[22] = {nX = 24299, nY = 4761, nZ = 1124416, nFace = 132}, 	
	[23] = {nX = 23895, nY = 4761, nZ = 1124416, nFace = 132},
	[24] = {nX = 23525, nY = 4761, nZ = 1124416, nFace = 132}, 	
	[25] = {nX = 23135, nY = 4761, nZ = 1124416, nFace = 132},
	[26] = {nX = 23135, nY = 4271, nZ = 1124416, nFace = 132}, 	
	[27] = {nX = 23525, nY = 4271, nZ = 1124416, nFace = 132},
	[28] = {nX = 23895, nY = 4271, nZ = 1124416, nFace = 132},
	[29] = {nX = 24299, nY = 4271, nZ = 1124416, nFace = 132}, 	
	[30] = {nX = 24669, nY = 4271, nZ = 1124416, nFace = 132},	
}

local nCDLeft = 0
local nSteper = -1

function FarmPanel.OnFrameCreate()
	--this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("PLAYER_ENTER_SCENE")
end

function FarmPanel.OnEvent(event)
	if event == "PLAYER_ENTER_SCENE" then
		local player = GetClientPlayer()
		if player and player.dwID == arg0 then
			local scene = player.GetScene()
			if scene and scene.nType == 4 then
				--local bIsVisible = FarmPanel.frameSelf:IsVisible()
				--FarmPanel.OpenPanel()
				--if not bIsVisible then
					FarmPanel.ClosePanel()
				--end
			end
		end
	end
end

function FarmPanel.OnFrameBreathe()
	nCDLeft = nCDLeft - 1
	nSteper = nSteper + 1

	FarmPanel.UpdateButtonState()
	FarmPanel.UpdateSoilList()			-- 更新土地信息
end

function FarmPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_ShowTip" then
		FarmPanel.bShowTip = true
	end
end

function FarmPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_ShowTip" then
		FarmPanel.bShowTip = false
	end
end

function FarmPanel.OnMouseEnter()
	local szName = this:GetName()
	if FarmPanel.bShowTip then
		if szName == "Btn_Cancel" or szName == "Btn_Close" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_CLOSE)
		elseif szName == "Btn_Refresh" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_REFRESH)
		elseif szName == "Btn_ApplyAttention" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_APPLYATTENTION)
		elseif szName == "Btn_Enter" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_ENTER)
		elseif szName == "Btn_EnterMyGuild" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_ENTERMYGUILD)
		elseif szName:match("Btn_EnterF%d*") then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_ENTERFN)
		elseif szName == "Btn_CustomEnter" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_CUSTOMENTER)
		elseif szName == "Btn_Leave" then
			FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_LEAVE)
		end
	end
end

function FarmPanel.OnMouseLeave()
	HideTip()
end

function FarmPanel.OnItemLButtonDBClick()
	local szName = this:GetName()
	if szName:match("^HI_([AR])List(%d*)") and FarmPanel.dwLastSelectTongID and FarmPanel.dwLastSelectTongID > 0 then
		FarmPanel.TryEnterFarmByID(FarmPanel.dwLastSelectTongID)
	end
end

function FarmPanel.OnLButtonClick()
	local szName = this:GetName()
	local player = GetClientPlayer()
	if not player then
		return
	end
	local scene = player.GetScene()
	if not scene then
		return
	end	
	
	if szName == "Btn_Cancel" or szName == "Btn_Close" then
		FarmPanel.ClosePanel()
	elseif szName == "Btn_Refresh" then
		if nCDLeft <= 0 then
			nCDLeft = REF_CD_MAX
			FarmPanel.RandomTongListRequest(10)
		end
	elseif szName == "Btn_ApplyAttention" then
		local editApplyAttention = FarmPanel.frameSelf:Lookup("Edit_ApplyAttention")
		local szTongName = editApplyAttention:GetText()
		if szTongName == "" then
			OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ENTER_TONG_NAME)
			return
		elseif szTongName:match("[%d%s_]") or #szTongName > 25 then
			OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_TONG_NAME)
			return
		end
		FarmPanel.TryAddAttentionTongRequest(szTongName)
	elseif szName == "Btn_Enter" then
		if FarmPanel.dwLastSelectTongID and FarmPanel.dwLastSelectTongID > 0 then
			FarmPanel.TryEnterFarmByID(FarmPanel.dwLastSelectTongID)
		end
	elseif szName == "Btn_EnterMyGuild" then
		if FarmPanel.tFarmBuffInfo[0] and FarmPanel.tFarmBuffInfo[0].nMapCopyID and FarmPanel.tFarmBuffInfo[0].nMapCopyID > 0 then
			FarmPanel.TryEnterFarmByID(FarmPanel.tFarmBuffInfo[0].nMapCopyID)
		end
	elseif szName:match("Btn_EnterF%d*") then
		local nIndex = tonumber(szName:match("Btn_EnterF(%d*)"))
		if nIndex and FarmPanel.tFarmBuffInfo[nIndex] and FarmPanel.tFarmBuffInfo[nIndex].nMapCopyID and FarmPanel.tFarmBuffInfo[nIndex].nMapCopyID > 0 then
			FarmPanel.TryEnterFarmByID(FarmPanel.tFarmBuffInfo[nIndex].nMapCopyID)
		end
	elseif szName == "Btn_CustomEnter" then
		local editCustomEnter = FarmPanel.frameSelf:Lookup("Edit_CustomEnter")
		local szTongName = editCustomEnter:GetText()
		if szTongName == "" then
			OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ENTER_TONG_NAME)
			return
		elseif szTongName:match("[%d%s_]") or #szTongName > 25 then
			OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_TONG_NAME)
			return
		end
		FarmPanel.TryEnterFarmByName(szTongName)
	elseif szName == "Btn_Leave" then
		if scene.dwMapID == FARM_MAPID then
			FarmPanel.TryLeaveFarm()
		end
	end
	
	-- 清除选择状态
	if szName == "Btn_Refresh" or szName == "Btn_ApplyAttention" or szName == "Btn_Enter" then
		FarmPanel.ClearLastSelectTong()
	end
end

function FarmPanel.OnItemMouseEnter()
	local szName = this:GetName()
	do
		if szName == "Text_MyState" then
			if FarmPanel.bShowTip then
				FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_SCORE)
			end
		end
	end
	do
		local szIndex = szName:match("^Image_Farm(%d*)CD")
		if szIndex then
			if FarmPanel.bShowTip then
				FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_CD)
			end
		end
	end
	do
		local szType, szIndex = szName:match("^HI_([AR])List(%d*)")
		if szType and szIndex then
			if FarmPanel.bShowTip then
				FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_TONG_LIST)
			end
			local cover = this:Lookup(("TN_%sListCover%s"):format(szType, szIndex))
			cover:Show()
		end
	end
	do
		local szIndex = szName:match("^Image_AListClose(%d*)")
		if szIndex then
			if FarmPanel.bShowTip then
				FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_TONG_LIST_DEL)
			end
			this:SetFrame(51)
		end
	end
	do
		local szIndex = szName:match("^Image_Add(%d*)")
		if szIndex then
			if FarmPanel.bShowTip then
				FarmPanel.OutputFormatedTips(g_tStrings.FAMR_PANEL.TIP_TONG_LIST_ADD)
			end
			this:SetFrame(43)
		end
	end
end

function FarmPanel.OnItemMouseLeave()
	local szName = this:GetName()
	do
		local szType, szIndex = szName:match("^HI_([AR])List(%d*)")
		if szType and szIndex then
			local cover = this:Lookup(("TN_%sListCover%s"):format(szType, szIndex))
			cover:Hide()
		end
	end
	do
		local szIndex = szName:match("^Image_AListClose(%d*)")
		if szIndex then
			this:SetFrame(49)
		end
	end
	do
		local szIndex = szName:match("^Image_Add(%d*)")
		if szIndex then
			this:SetFrame(42)
		end
	end
	
	HideTip()
end

function FarmPanel.OnItemLButtonClick()
	local szName = this:GetName()
	do
		local szType, szIndex = szName:match("^HI_([AR])List(%d*)")
		if szType and szIndex then
			local nIndex = tonumber(szIndex)
			if nIndex  then
				FarmPanel.ClearLastSelectTong()
				FarmPanel.handleLastSelectTong = this;
				FarmPanel.handleLastSelectTong.szTextName = ("Text_%sListName%s"):format(szType, szIndex)
				local text = FarmPanel.handleLastSelectTong:Lookup(FarmPanel.handleLastSelectTong.szTextName)
				text:SetFontColor(255, 255, 0)
				if szType == "A" and FarmPanel.tAttentionTongIDList[nIndex] then
					FarmPanel.dwLastSelectTongID = FarmPanel.tAttentionTongIDList[nIndex].dwTongID;
				elseif szType == "R" and FarmPanel.tRandomTongIDList[nIndex] then
					FarmPanel.dwLastSelectTongID = FarmPanel.tRandomTongIDList[nIndex].dwTongID;
				end
			end
		end
	end
	do
		local szIndex = szName:match("^Image_AListClose(%d*)")
		if szIndex then
			local nIndex = tonumber(szIndex)
			if nIndex and FarmPanel.tAttentionTongIDList[nIndex] then
				local dwTongID = FarmPanel.tAttentionTongIDList[nIndex].dwTongID
				if dwTongID and dwTongID > 0 then
					FarmPanel.ClearLastSelectTong()
					FarmPanel.TryDelAttentionTongRequest(dwTongID)
				end
			end			
		end
	end
	do
		local szIndex = szName:match("^Image_Add(%d*)")
		if szIndex then
			local nIndex = tonumber(szIndex)
			if nIndex and FarmPanel.tRandomTongIDList[nIndex] then
				local dwTongID = FarmPanel.tRandomTongIDList[nIndex].dwTongID
				if dwTongID and dwTongID > 0 then
					FarmPanel.ClearLastSelectTong()
					FarmPanel.TryAddAttentionTongRequest(FarmPanel.tRandomTongIDList[nIndex].szTongName)
				end
			end
		end
	end
end
-- ----------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------
-- szTips 格式如: <F100 这里是黄色><F106 这里是白色>
function FarmPanel.OutputFormatedTips(szTips, bDisable)
	local szFormated = ""
	if not szTips then
		return szFormated
	end
	
	local nFontGrayID = 110
	local nFontWhiteID = 106
	if not szTips:match("%b<>") then
		szFormated = szFormated .. "<Text>text=" .. EncodeComponentsString(szTips) .. " font=" .. nFontWhiteID .. " </text>"
	else
		for szTag in szTips:gmatch("%b<>") do
			if szTag:match("^<(%bF )") then
				local szFontStr = szTag:match("^<(%bF )")
				local nFontID = tonumber(szFontStr:sub(2, -2))
				if bDisable then
					nFontID = nFontGrayID
				end
				if nFontID then
					local szContent = szTag:sub(#szFontStr + 2, -2)
					szFormated = szFormated .. "<Text>text=" .. EncodeComponentsString(szContent) .. " font=" .. nFontID .. " </text>"
				end
			end
		end
	end
	
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(szFormated, 600, {x, y, w, h})
end

function FarmPanel.UpdateButtonState()
	local bShow = FarmPanel.frameSelf:IsVisible()
	if not bShow then
		return
	end

	local player = GetClientPlayer()
	if not player then
		return
	end
	local scene = player.GetScene()
	if not scene then
		return
	end

	local buttonApplyAttention = FarmPanel.frameSelf:Lookup("Btn_ApplyAttention")
	local editApplyAttention = FarmPanel.frameSelf:Lookup("Edit_ApplyAttention")
	if #FarmPanel.tAttentionTongIDList >= 10 or editApplyAttention:GetText() == "" then
		buttonApplyAttention:Enable(false)
	else
		buttonApplyAttention:Enable(true)
	end
	
	local tButtonEnters = {
		FarmPanel.frameSelf:Lookup("Btn_EnterF01"),
		FarmPanel.frameSelf:Lookup("Btn_EnterF02"),
		FarmPanel.frameSelf:Lookup("Btn_EnterF03"),
		FarmPanel.frameSelf:Lookup("Btn_EnterF04"),
		FarmPanel.frameSelf:Lookup("Btn_EnterF05"),
		FarmPanel.frameSelf:Lookup("Btn_EnterMyGuild"),
		FarmPanel.frameSelf:Lookup("Btn_CustomEnter"),
		FarmPanel.frameSelf:Lookup("Btn_Enter"),
	}
	for i = 1, #tButtonEnters do
		if not player.bFightState and (scene.nType == MAP_TYPE.NORMAL_MAP or scene.nType == MAP_TYPE.BIRTH_MAP or scene.dwMapID == FARM_MAPID) then
			if i <= 5 then
				if FarmPanel.tFarmBuffInfo[i] and FarmPanel.tFarmBuffInfo[i].bCanCreateSelfFarm then
					tButtonEnters[i]:Enable(true)
				else
					tButtonEnters[i]:Enable(false)
				end
			elseif i == 6 then
				if player.dwTongID and player.dwTongID > 0 and FarmPanel.tFarmBuffInfo[0] and FarmPanel.tFarmBuffInfo[0].bCanCreateSelfFarm then
					tButtonEnters[i]:Enable(true)
				else
					tButtonEnters[i]:Enable(false)
				end
			else
				tButtonEnters[i]:Enable(true)
			end
		else
			tButtonEnters[i]:Enable(false)
		end
	end
	
	local buttonLeave = FarmPanel.frameSelf:Lookup("Btn_Leave")
	if scene.dwMapID == FARM_MAPID then
		buttonLeave:Enable(true)
	else
		buttonLeave:Enable(false)
	end
	
	local buttonRefresh = FarmPanel.frameSelf:Lookup("Btn_Refresh")
	if nCDLeft <= 0 then
		buttonRefresh:Enable(true)
		if nCDLeft > -16 then
			local szText = buttonRefresh:Lookup("", "Text_Refresh"):GetText()
			szText = szText:gsub("%b()", "")
			buttonRefresh:Lookup("", "Text_Refresh"):SetText(szText)
		end
	else
		buttonRefresh:Enable(false)
		if nCDLeft % 16 == 0 then
			local szText = buttonRefresh:Lookup("", "Text_Refresh"):GetText()
			local nSec = ("(%d)"):format(math.ceil(nCDLeft / 16))
			if szText:match("%b()") then
				szText = szText:gsub("%b()", nSec)
			else
				szText = szText .. nSec
			end
			buttonRefresh:Lookup("", "Text_Refresh"):SetText(szText)
		end
	end
end

function FarmPanel.ClearLastSelectTong()
	if FarmPanel.handleLastSelectTong then
		local text = FarmPanel.handleLastSelectTong:Lookup(FarmPanel.handleLastSelectTong.szTextName)
		text:SetFontColor(255, 255, 255)
	end
	FarmPanel.dwLastSelectTongID = nil;
	FarmPanel.handleLastSelectTong = nil;
end
-- ----------------------------------------------------------------------------
-- 数据或者远程调用相关
-- ----------------------------------------------------------------------------
function FarmPanel.RandomTongListRequest(nTongCount)
	RemoteCallToServer("OnFarmPanelRandomTongRequest", nTongCount)
end

function FarmPanel.TryEnterFarmByID(dwTongID)
	local player = GetClientPlayer()
	if not player then
		return
	end
	if player.bFightState then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.nMoveState == MOVE_STATE.ON_DEATH then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.nMoveState == MOVE_STATE.ON_AUTO_FLY then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.nCurrentKillPoint >= 300 then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.IsOnSlay() then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	
	RemoteCallToServer("OnFarmPanelEnterFarmByID", dwTongID)
end

function FarmPanel.TryEnterFarmByName(szTongName)
	local player = GetClientPlayer()
	if not player then
		return
	end
	if player.bFightState then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.nMoveState == MOVE_STATE.ON_DEATH then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.nCurrentKillPoint >= 300 then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	if player.IsOnSlay() then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_SWITCHMAP)
		return
	end
	RemoteCallToServer("OnFarmPanelEnterFarmByName", szTongName)
end

function FarmPanel.TryLeaveFarm()
	RemoteCallToServer("OnFarmPanelLeaveFarm")
end

function FarmPanel.TryDelAttentionTongRequest(dwTongID)
	local bHasTongID = false
	for i = 1, 10 do
		if FarmPanel.tAttentionTongIDList[i] then
			if dwTongID == FarmPanel.tAttentionTongIDList[i].dwTongID then
				bHasTongID = true
				break
			end
		end
	end
	if not bHasTongID then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_DEL_TONGNAME)
		return
	end
	
	RemoteCallToServer("OnFarmPanelDelTongRequest", dwTongID)
end

function FarmPanel.TryAddAttentionTongRequest(szTongName)
	if #FarmPanel.tAttentionTongIDList >= 10 then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_ADD_TONGNAME_FULL)
		return
	end
	for i = 1, 10 do
		if FarmPanel.tAttentionTongIDList[i] then
			if szTongName == FarmPanel.tAttentionTongIDList[i].szTongName then
				OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_ADD_TONGNAME_DUMPED)
				return
			end
		end
	end
	RemoteCallToServer("OnFarmPanelAddTongRequest", szTongName)
end

function FarmPanel.AddAttentionTongRecive(nEmptySlot, dwTongID, szTongName)
	if not dwTongID then
		OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_ADD_TONGNAME_NOTONG)
		return
	end
	
	local bAddOK = false
	for i = 1, 10 do
		if not FarmPanel.tAttentionTongIDList[i] then
			FarmPanel.tAttentionTongIDList[i] = {dwTongID = dwTongID, szTongName = szTongName}
			bAddOK = true
			break
		end
	end
	if bAddOK then
		FarmPanel.UpdateAttentionTongList()
		return
	end
	OutputMessage("MSG_SYS", g_tStrings.FAMR_PANEL.ERROR_ADD_TONGNAME_FULL)
end

function FarmPanel.ChangeScoreRecord(nScore, nOldScore)
	local text = FarmPanel.frameSelf:Lookup("", "Text_Sate")
	if text then
		text:SetText(nScore .. " / 10000")
	end
end

function FarmPanel.BaseDataRecive(tFarmBuffInfo, tAllowableAttentionTongIDList, tBanAttentionTongIDList)
	FarmPanel.tFarmBuffInfo = tFarmBuffInfo
	FarmPanel.tAttentionTongIDList = tAllowableAttentionTongIDList
	if tBanAttentionTongIDList and #tBanAttentionTongIDList > 0 then
		for i = 1, #tBanAttentionTongIDList do
			OutputMessage("MSG_SYS", (g_tStrings.FAMR_PANEL.DEL_TONGNAME):format(tostring(tBanAttentionTongIDList[i].szTongName)))
		end
	end
	
	FarmPanel.UpdateCurrentTongName()
	FarmPanel.UpdateSoilList(true)
	FarmPanel.UpdateAttentionTongList()
end

function FarmPanel.RandomTongListRecive(tRandomTongIDList)
	FarmPanel.tRandomTongIDList = tRandomTongIDList
	
	FarmPanel.UpdateRandomTongList()
end

function FarmPanel.UpdateCurrentTongName()
	local tFarmBuffInfo = FarmPanel.tFarmBuffInfo
	if not tFarmBuffInfo or not tFarmBuffInfo[0] or not FarmPanel.frameSelf then
		return
	end
	local player = GetClientPlayer()
	if not player then
		return
	end
	local scene = player.GetScene()
	if not scene then
		return
	end
	tFarmBuffInfo[0].szCurrentMapTongName = tFarmBuffInfo[0].szCurrentMapTongName or ""

	textTitle = FarmPanel.frameSelf:Lookup("", "Text_Title")
	if not textTitle then
		return
	end
	local szMapName = textTitle:GetText():sub(-6, -1)
	local szTitle = tFarmBuffInfo[0].szCurrentMapTongName .. szMapName
	textTitle:SetText(szTitle)
end

function FarmPanel.UpdateSoilList(bInit)
	if not FarmPanel.tFarmBuffInfo then
		return
	end
	local bShow = FarmPanel.frameSelf:IsVisible()
	
	for i = 1, 5 do
		if bShow then
			if FarmPanel.tFarmBuffInfo[i] then
				FarmPanel.tFarmBuffInfo[i].nLeftFrame = FarmPanel.tFarmBuffInfo[i].nLeftFrame - 1
				if FarmPanel.tFarmBuffInfo[i].nLeftFrame <= 0 then
					FarmPanel.tFarmBuffInfo[i] = nil
					FarmPanel.ClearSoilInfo(i)
				end
			else
				FarmPanel.ClearSoilInfo(i)
			end
			if FarmPanel.tFarmBuffInfo[i] then
				local nRunoffFrame = FARMBUFF.KEEPTIME - FarmPanel.tFarmBuffInfo[i].nLeftFrame
				local nPhase = 3
				local nCDPercentage = 0
				local nPhase1Frame = GLOBAL.GAME_FPS * 3600 * 2
				local nPhase2Frame = nPhase1Frame * 2
				if nRunoffFrame < nPhase1Frame then				-- 第一阶段
					nPhase = 1
					nCDPercentage = nRunoffFrame / nPhase1Frame
				elseif nRunoffFrame < nPhase2Frame then			-- 第二阶段
					nPhase = 2
					nCDPercentage = (nRunoffFrame - nPhase1Frame) / (nPhase2Frame - nPhase1Frame)
				elseif nRunoffFrame < FARMBUFF.KEEPTIME then	-- 第三阶段
					nCDPercentage = (nRunoffFrame - nPhase2Frame) / (FARMBUFF.KEEPTIME - nPhase2Frame)
				end
				
				-- 更新CD
				local imageCD = FarmPanel.frameSelf:Lookup("", ("Image_Farm%sCD"):format(FarmPanel.FormatIndex(i)))
				imageCD:SetPercentage(nCDPercentage)
	
				if not FarmPanel.tFarmBuffInfo[i].nPhase or FarmPanel.tFarmBuffInfo[i].nPhase ~= nPhase then
					FarmPanel.tFarmBuffInfo[i].nPhase = nPhase
					local nLevel = math.min((FarmPanel.tFarmBuffInfo[i].nLevel or 1), 4)
					local nImageFrame = SEED_IMAGE_LIST[nLevel][nPhase]
					local image = FarmPanel.frameSelf:Lookup("", ("Image_Farm%s"):format(FarmPanel.FormatIndex(i)))
					image:SetFrame(nImageFrame)
					
					-- 公会名字更新
					local text = FarmPanel.frameSelf:Lookup("", ("Text_Farm%s"):format(FarmPanel.FormatIndex(i)))
					local szTongNameFixed = FarmPanel.tFarmBuffInfo[i].szTongName
					if #szTongNameFixed > 14 then
						szTongNameFixed = szTongNameFixed:sub(1, 14) .. "..."
					end
					text:SetText(szTongNameFixed)
				end
			end
		end
		
		-- 地图上标记点
		if FarmPanel.tFarmBuffInfo[i] and nSteper % 32 == 0 then
			local frame = Station.Lookup("Topmost/Minimap")
			if frame then
				local frameMap = frame:Lookup("Wnd_Minimap/Minimap_Map")
				if frameMap then
					local nSoilID = FarmPanel.tFarmBuffInfo[i].nSoilID
					local tPosInfo = tSoilPos[nSoilID]
					local scene = GetClientPlayer().GetScene()
					if tPosInfo and scene and scene.nCopyIndex == FarmPanel.tFarmBuffInfo[i].nMapCopyID then
						local nMiniMapScreenX, nMiniMapScreenY, nMiniMapScreenZ = Scene_GameWorldPositionToScenePosition(tPosInfo.nX, tPosInfo.nY, tPosInfo.nZ, 0)
						frameMap:UpdataArrowPoint(0, nSoilID, 2, 48, nMiniMapScreenX, nMiniMapScreenZ, 40)
					end
				end
			end
		end
	end
	
	if bShow and bInit and FarmPanel.tFarmBuffInfo[0] then
		local image = FarmPanel.frameSelf:Lookup("", "Image_MyGuild")
		local bCanCreateSelfFarm = FarmPanel.tFarmBuffInfo[0].bCanCreateSelfFarm
		if bCanCreateSelfFarm then
			image:SetFrame(27)
		else
			image:SetFrame(28)
		end

		local text = FarmPanel.frameSelf:Lookup("", "Text_MyGuild")
		local szTongNameFixed = FarmPanel.tFarmBuffInfo[0].szTongName or ""
		if #szTongNameFixed > 14 then
			szTongNameFixed = szTongNameFixed:sub(1, 14) .. "..."
		end
		text:SetText(szTongNameFixed)
		
		FarmPanel.ChangeScoreRecord(FarmPanel.tFarmBuffInfo[0].nFarmScore or 0)
	end
end

function FarmPanel.ClearSoilInfo(nIndex)
	if not nIndex or nIndex < 1 or nIndex > 5 then
		return
	end
	local image = FarmPanel.frameSelf:Lookup("", ("Image_Farm%s"):format(FarmPanel.FormatIndex(nIndex)))
	image:SetFrame(28)
	
	local text = FarmPanel.frameSelf:Lookup("", ("Text_Farm%s"):format(FarmPanel.FormatIndex(nIndex)))
	text:SetText("")
	
	local imageCD = FarmPanel.frameSelf:Lookup("", ("Image_Farm%sCD"):format(FarmPanel.FormatIndex(nIndex)))
	imageCD:SetPercentage(0)
end

function FarmPanel.UpdateAttentionTongList()
	if not FarmPanel.tAttentionTongIDList then
		return
	end
	for i = 1, 10 do
		local handleA = FarmPanel.handleAttentionList:Lookup(i - 1)
		local text = handleA:Lookup("Text_AListName" .. FarmPanel.FormatIndex(i))
		if FarmPanel.tAttentionTongIDList[i] then
			local dwTongID = FarmPanel.tAttentionTongIDList[i].dwTongID
			local szTongName = FarmPanel.tAttentionTongIDList[i].szTongName
			text:SetText((g_tStrings.FAMR_PANEL.TONGNAME):format(szTongName))
			handleA:Show()
		else
			text:SetText("")
			handleA:Hide()
		end
	end	
end

function FarmPanel.UpdateRandomTongList()
	if not FarmPanel.tRandomTongIDList or #FarmPanel.tRandomTongIDList < 1 then
		return
	end
	for i = 1, 10 do
		local handleR = FarmPanel.handleRandomList:Lookup(i - 1)
		local text = handleR:Lookup("Text_RListName" .. FarmPanel.FormatIndex(i))
		if FarmPanel.tRandomTongIDList[i] then
			local dwTongID = FarmPanel.tRandomTongIDList[i].dwTongID
			local szTongName = FarmPanel.tRandomTongIDList[i].szTongName
			text:SetText((g_tStrings.FAMR_PANEL.TONGNAME):format(szTongName))
			handleR:Show()
		else
			text:SetText("")
			handleR:Hide()
		end
	end
end

-- ----------------------------------------------------------------------------
-- 工具或者其他
-- ----------------------------------------------------------------------------
function FarmPanel.FormatIndex(nNum)
	if not nNum or nNum < 0 or nNum > 99 then
		return "00"
	end
	if nNum < 10 then
		return "0" .. nNum
	else
		return tostring(nNum)
	end
end

function FarmPanel.OpenPanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	FarmPanel.frameSelf = Station.Lookup("Normal/FarmPanel")
	if not FarmPanel.frameSelf then
		FarmPanel.frameSelf = Wnd.OpenWindow("FarmPanel")
		FarmPanel.handleAttentionList = FarmPanel.frameSelf:Lookup("", "Handle_Attention"):Lookup("Handle_AList")
		FarmPanel.handleRandomList = FarmPanel.frameSelf:Lookup("", "Handle_Random"):Lookup("Handle_RList")
		for i = 1, 10 do
			FarmPanel.handleAttentionList:Lookup(i - 1):Hide()
			FarmPanel.handleRandomList:Lookup(i - 1):Hide()
		end
	end
	
	FarmPanel.frameSelf:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	FarmPanel.frameSelf:Show()
	FarmPanel.frameSelf:Lookup("CheckBox_ShowTip"):Check(FarmPanel.bShowTip)

	RemoteCallToServer("OnFarmPanelDataRequest")
	
	if IrrigatePanel and IrrigatePanel.frameSelf and IrrigatePanel.frameSelf:IsVisible() then
		IrrigatePanel.ClosePanel()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function FarmPanel.ClosePanel(bDisableSound)
	if FarmPanel.frameSelf then
		FarmPanel.frameSelf:Hide()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

FarmPanel.OpenPanel(true)
FarmPanel.ClosePanel(true)