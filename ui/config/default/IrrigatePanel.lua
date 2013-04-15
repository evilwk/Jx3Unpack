----------------------------------------------------------------------
-- �����ͺϳ�
-- Date:	2010.06.01
-- Author:	Danexx
-- Comment: �ĺ�������Ҫ���ཻ�����������Ҹ��ġ��ðɣ������ֻ�ǰ����ǵ���·�˼��ұ������������ָ�����ô���ı�����������أ� 

--���¸�һ�㡷

-- �ǲ��Ǽ򵥵ĺ��ҡ��Ͳ���д�������ĸ�
-- �ǲ����ҵ����������������Ͳ��ܴ�����
-- �ǲ��Ǳ��˵İ��顡�ҾͲ��ܸ���
-- �ǲ��Ǹ��������ǡ�Ҳ�����˺�����ӵ

-- �ǲ��ǹ��ڵ�ţ�̡��Ͳ��ܺ�
-- �ǲ��ǹ��ڵİ��顡��������������
-- �ǲ��������ս������������Ͷ��
-- �ǲ��Ƕ�ѡһ����ȶ�ѡ�������˻���

-- û�д𰸡�Ҳ����Ҫ
-- û�����ǡ���������ҫ
-- �����ð��顡���һ������
-- �����ڱ��ܵ�ʱ��
-- ��ȥ���Ժ�
-- �ò���

-- PS: ��Ȼ��ϲ�������Ķ���, �Ǿͽ��۰�!
----------------------------------------------------------------------

IrrigatePanel = {}
IrrigatePanel.frameSelf = nil;
IrrigatePanel.handleTextTip = nil;
IrrigatePanel.nPanelIndex = nil;
IrrigatePanel.tBoxes = {};
IrrigatePanel.tSeedsRange = {6941, 6959}
IrrigatePanel.tBonusList = {
	[1830] = 2,		-- �ɹ���
	[1829] = 2,		-- ��Ҷ��
	[1832] = 2,		-- ��ˮ
	[1831] = 2,		-- ����ǻ

	[3010] = 2,		-- ¶ˮ
	[979] = 2,		-- ����Ȫ
	[974] = 2,		-- ��ͻȪ
	[972] = 2,		-- ����Ȫ
	[973] = 2,		-- ����Ȫ
	[3302] = 2,		-- ǧ���о
	[3288] = 2,		-- ����׺��

	[975] = 2,		-- �ž�Ȫ
	[976] = 2,		-- ��ɽѩˮ

	[3544] = 2,		-- ��ľ��
	[977] = 2,		-- ��ľ
	[982] = 2,		-- ̴ľ
	[980] = 2,		-- ͩľ
	[981] = 2,		-- ��ľ
	[983] = 2,		-- ����ľ

	[3022] = 2,		-- ����
	[3551] = 2,		-- �ػ�
	[3283] = 2,		-- ����
	[3549] = 2,		-- ����ĸ
	[3300] = 2,		-- ����
	[3548] = 2,		-- ��ʵ
	[3550] = 2,		-- ���
	[3547] = 2,		-- ����
}

local tLastActPos = {nX = 0, nY = 0}

function IrrigatePanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or not Station.Lookup("Topmost/IrrigatePanel") then
		return
	end
	if math.abs(tLastActPos.nX - player.nX) > 128 or math.abs(tLastActPos.nY - player.nY) > 128 then
		IrrigatePanel.ClosePanel()
	end
end

function IrrigatePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local tItemList = {}
		for i = 1, 3 do
			local boxLoop = IrrigatePanel.tBoxes[i]
			local dwLoopType, nLoopData1, nLoopData2, nLoopData3, nLoopData4, dwLoopItemType, dwLoopItemIndex = boxLoop:GetObject() 
			if not boxLoop:IsEmpty() and dwLoopType == UI_OBJECT_ITEM then
				local tItemInfo = {dwIndex = dwLoopItemIndex, nStackNum = (tonumber(boxLoop:GetOverText(0)) or 1)}
				table.insert(tItemList, tItemInfo)
			end
		end
		if #tItemList > 0 then
			RemoteCallToServer("OnIrrigatePanelRequest", IrrigatePanel.nPanelIndex, tItemList)
		end
		IrrigatePanel.ClosePanel()
	elseif szName == "Btn_Cancel" then
		IrrigatePanel.ClosePanel()
	end
end

function IrrigatePanel.OnItemMouseEnter()
	local szName = this:GetName()
	if not szName:match("^Box_Box%d") then
		return
	end
	this:SetObjectMouseOver(1)
	
	IrrigatePanel.ShowItemBoxTip(this)
end

function IrrigatePanel.OnItemMouseLeave()
	local szName = this:GetName()
	if not szName:match("^Box_Box%d") then
		return
	end
	this:SetObjectMouseOver(0)
	HideTip()
end

function IrrigatePanel.OnItemLButtonDown()
	local szName = this:GetName()
	if not szName:match("^Box_Box%d") then
		return
	end
	this:SetObjectPressed(1)
end

function IrrigatePanel.OnItemLButtonUp()
	local szName = this:GetName()
	if not szName:match("^Box_Box%d") then
		return
	end
	this:SetObjectPressed(0)
end

function IrrigatePanel.OnItemLButtonClick()
	IrrigatePanel.OnChangeHandAndBoxItem(this)
end

function IrrigatePanel.OnItemLButtonDrag()
	if not Hand_IsEmpty() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_DROP_HAND_OBJ_WHEN_DRAG)
		PlayTipSound("001")
		return
	end
	if this:IsEmpty() then
		return
	end
	if IsCursorInExclusiveMode() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
		PlayTipSound("010")
		return
	end
	
	Hand_Pick(this, nil, true)
	this:SetOverText(0, "")
	this:SetOverText(1, "")
	this:ClearObject()
	this:SetUserData(-1)
	UpdateItemBoxExtend(this)
	HideTip()
end

function IrrigatePanel.OnItemLButtonDragEnd()
	IrrigatePanel.OnChangeHandAndBoxItem(this)
end

function IrrigatePanel.ShowItemBoxTip(box)
	local player = GetClientPlayer()
	if not box or box:IsEmpty() or not player then
		return
	end
	local x, y = box:GetAbsPos()
	local w, h = box:GetSize()
	local dwType, nData1, nData2, nData3, nData4, dwItemType, dwItemIndex = box:GetObject()
	if dwType == UI_OBJECT_ITEM then		
		OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, dwItemType, dwItemIndex, {x, y, w, h})
	end
end

function IrrigatePanel.OnChangeHandAndBoxItem(box)
	local player = GetClientPlayer()
	if not player then
		return
	end
	if Hand_IsEmpty() then
		if not box:IsEmpty() then
			Hand_Pick(box, nil, true)
			box:SetOverText(0, "")
			box:SetOverText(1, "")
			box:ClearObject()
			this:SetUserData(-1)
			UpdateItemBoxExtend(box)
			return
		else
			return
		end
	end
	
	local boxHand = Hand_Get()
	local dwType, nData1, nData2, nData3, nData4, nData5, nData6 = boxHand:GetObject()
	local nIconID = boxHand:GetObjectIcon()
	if dwType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_ERROR_CANNOT_DRAG_NON_MATERIAL)
		return
	end
	local item = GetPlayerItem(player, nData2, nData3)
	if not item or item.nGenre ~= ITEM_GENRE.MATERIAL or not item.bCanTrade then
		if item.dwIndex ~= 2269 then				-- �����Ǹ�����
			OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_ERROR_CANNOT_DRAG_NON_MATERIAL)
			return
		end
	end

	local nCurrentIndex = tonumber(box:GetName():match("^Box_Box(%d)")) or 0
	for i = 1, 3 do
		local boxLoop = IrrigatePanel.tBoxes[i]
		local dwLoopType, nLoopData1, nLoopData2, nLoopData3, nLoopData4, dwLoopItemType, dwLoopItemIndex = boxLoop:GetObject() 
		if i ~= nCurrentIndex then
			if dwLoopType == dwType and dwLoopItemType == nData5 and dwLoopItemIndex == nData6 then
				OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_ERROR_CANNOT_DRAG_SAME_MATERIAL)
				return
			end
			
			local bSeed = item.dwIndex >= IrrigatePanel.tSeedsRange[1] and item.dwIndex <= IrrigatePanel.tSeedsRange[2]
			if bSeed and (dwLoopItemIndex >= IrrigatePanel.tSeedsRange[1] and dwLoopItemIndex <= IrrigatePanel.tSeedsRange[2]) then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_ERROR_CANNOT_DRAG_SAME_SEED)
				return
			end
		end
	end
	
	if box:IsEmpty() then
		Hand_Clear()
	else
		Hand_Pick(box, nil, true)
	end	

	box:SetObject(dwType, nData1, nData2, nData3, nData4, nData5, nData6)
	box:SetObjectIcon(nIconID)
	if item.bCanStack and item.nStackNum > 0 then
		if item.dwIndex == 6993 then
			box:SetOverText(0, math.min(item.nStackNum, 2))
		else
			box:SetOverText(0, item.nStackNum)
		end
	else
		box:SetOverText(0, "")
	end
	box:SetOverText(1, tostring(IrrigatePanel.CalculateNutrientScore(item)))
	UpdateItemBoxExtend(box, item, item.nQuality)
	
	IrrigatePanel.ShowItemBoxTip(box)
end

function IrrigatePanel.CalculateNutrientScore(item)
	local tScales = {[0] = 0, 0, 0.6, 2, 3}
	local nBase = 25
	if not item or (item.dwIndex >= IrrigatePanel.tSeedsRange[1] and item.dwIndex <= IrrigatePanel.tSeedsRange[2]) then
		return 0
	end

	local nBonus = IrrigatePanel.tBonusList[item.dwIndex] or 1
	local nMaxStackNum = math.max(item.nMaxStackNum, 10)
	local nQuality = item.nQuality
	local nNutrientScore = math.floor((nBase * nBonus * (tScales[item.nQuality] or 0) / nMaxStackNum) * item.nStackNum)

	if item.dwIndex == 6993 then
		nNutrientScore = math.min(item.nStackNum, 2) * 50
	elseif item.nQuality >= 3 and item.nMaxStackNum < 10 then
		nNutrientScore = math.floor(nNutrientScore / 3)
	end
	
	return nNutrientScore or 0
end

function IrrigatePanel.FillContent(szContents, handle)
	szContents = szContents or ""
	handle = handle or IrrigatePanel.handleTextTip
	if not handle then
		return
	end
	handle:Clear()
	handle:SetItemStartRelPos(0, 0)
	
	local _, tInfo = GWTextEncoder_Encode(szContents)
	for i = 1, #tInfo do
		local v = tInfo[i]
		if v.name == "text" then			--��ͨ�ı�
			handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(v.context) .. "font=15</text>")
		elseif v.name == "N" then			--�Լ�������
        	handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(GetClientPlayer().szName) .. "font=15</text>")
        elseif v.name == "C" then			--�Լ������Ͷ�Ӧ�ĳƺ�
        	handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(g_tStrings.tRoleTypeToName[GetClientPlayer().nRoleType]) .. "font=15</text>")
		elseif v.name == "F" then			--����
			handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(v.attribute.text) .. "font=" .. v.attribute.fontid .. "</text>")
		elseif v.name == "G" then			--4��Ӣ�Ŀո�
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if v.attribute.english then
				szSpace = "    "
			end
			handle:AppendItemFromString("<text>text=\"" .. szSpace .. "\" font=15</text>")
		else								--����Ľ�������ԭ�ı�
			if v.context then
				handle:AppendItemFromString("<text>text=" .. EncodeComponentsString("<" .. v.context.. ">") .. "font=15</text>")
			end
		end
	end
	handle:FormatAllItemPos()
end

function IrrigatePanel.OpenPanel(nPanelIndex, szTipText, bDisableSound)
	local player = GetClientPlayer()
	if not player then
		return
	end
	IrrigatePanel.nPanelIndex = nPanelIndex
	IrrigatePanel.frameSelf = Station.Lookup("Topmost/IrrigatePanel")
	if not IrrigatePanel.frameSelf then
		IrrigatePanel.frameSelf = Wnd.OpenWindow("IrrigatePanel")
	end
	
	IrrigatePanel.handleTextTip = IrrigatePanel.frameSelf:Lookup("", "Handle_Text_Tip")
	for i = 1, 3 do
		IrrigatePanel.tBoxes[i] = IrrigatePanel.frameSelf:Lookup("", "Box_Box" .. i)
		IrrigatePanel.tBoxes[i]:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		IrrigatePanel.tBoxes[i]:SetOverTextFontScheme(0, 15)
		IrrigatePanel.tBoxes[i]:SetOverTextPosition(1, ITEM_POSITION.LEFT_TOP)
		IrrigatePanel.tBoxes[i]:SetOverTextFontScheme(1, 167)
	end
	
	IrrigatePanel.FillContent(szTipText)
	IrrigatePanel.frameSelf:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	tLastActPos = {nX = player.nX, nY = player.nY}
	
	if FarmPanel and FarmPanel.frameSelf and FarmPanel.frameSelf:IsVisible() then
		FarmPanel.ClosePanel()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function IrrigatePanel.ClosePanel(bDisableSound)
	IrrigatePanel.frameSelf = nil;
	IrrigatePanel.handleTextTip:Clear();
	IrrigatePanel.nPanelIndex = nil;
	Wnd.CloseWindow("IrrigatePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end
