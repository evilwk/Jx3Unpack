-----------------说明-----------------------------
UI_OBJECT_ITEM = 0  --身上有的物品。nUiId, dwBox, dwX, nItemVersion, nTabType, nIndex
UI_OBJECT_SHOP_ITEM = 1 --商店里面出售的物品 nUiId, dwID, dwShopID, dwIndex
UI_OBJECT_OTER_PLAYER_ITEM = 2 --其他玩家身上的物品 nUiId, dwBox, dwX, dwPlayerID
UI_OBJECT_ITEM_ONLY_ID = 3  --只有一个ID的物品。比如装备链接之类的。nUiId, dwID, nItemVersion, nTabType, nIndex
UI_OBJECT_ITEM_INFO = 4 --类型物品 nUiId, nItemVersion, nTabType, nIndex
UI_OBJECT_SKILL = 5	--技能。dwSkillID, dwSkillLevel
UI_OBJECT_CRAFT = 6	--技艺。dwProfessionID, dwBranchID, dwCraftID
UI_OBJECT_SKILL_RECIPE = 7	--配方dwID, dwLevel
UI_OBJECT_SYS_BTN = 8 --系统栏快捷方式dwID
UI_OBJECT_MACRO = 9 --宏
UI_OBJECT_MOUNT = 10 --镶嵌
UI_OBJECT_ENCHANT = 11 --附魔
UI_OBJECT_NOT_NEED_KNOWN = 15 --不需要知道类型
---------------------------------------------------

INVENTORY_GUILD_BANK = INVENTORY_INDEX.TOTAL + 1 --帮会仓库界面虚拟一个背包位置

INVENTORY_GUILD_PAGE_SIZE = 100

-- \represent\common\global_effect.txt
TITLE_EFFECT_NONE = 0
PARTY_TITLE_MARK_EFFECT_LIST = { 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}	
PARTY_TITLE_MARK_EFFECT_LIST[0] = TITLE_EFFECT_NONE	-- none effect

PARTY_MARK_ICON_PATH = "ui\\Image\\button\\FrendNPartyButton.UITex"
PARTY_MARK_ICON_FRAME_LIST = {66, 67, 73, 74, 75, 76, 77, 78, 81, 82}


function GetGuildBankBagPos(nPage, nIndex)
	return INVENTORY_GUILD_BANK, nPage * INVENTORY_GUILD_PAGE_SIZE + nIndex
end

function GetGuildBankPagePos(dwBox, dwX)
	return math.floor(dwX / INVENTORY_GUILD_PAGE_SIZE), dwX % INVENTORY_GUILD_PAGE_SIZE
end

function SetParyMarkImage(hImageMark, nMarkID)
	assert(hImageMark)
	assert(nMarkID >= 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)

	if nMarkID ~= 0 then
		hImageMark:FromUITex(PARTY_MARK_ICON_PATH, PARTY_MARK_ICON_FRAME_LIST[nMarkID])
		hImageMark:Show()
	else
		hImageMark:Hide()
	end
end

function GetCampImageFrame(eCamp, bFight)	-- ui\Image\UICommon\CommonPanel2.UITex
	local nFrame = nil
	if eCamp == CAMP.GOOD then
		if bFight then
			nFrame = 117
		else
			nFrame = 7
		end
	elseif eCamp == CAMP.EVIL then
		if bFight then
			nFrame = 116
		else
			nFrame = 5
		end
	end
	return nFrame
end

function SetImage(hImage, nFrame)
	assert(hImage)
	if nFrame then
		hImage:SetFrame(nFrame)
		hImage:Show()
	else
		hImage:Hide()
	end
end

SHOW_TARGET_LEVEL_LIMITS = 10

function GetStateString(nCurValue, nMaxValue, bDanger, bIngore)
	local szState1 =  math.floor(100 * nCurValue / nMaxValue) .. "%"
	local szState2 = ""
	
	if bDanger and (nCurValue == nMaxValue or nCurValue > 9999) then
		szState2 = "????/????"
	else
		szState2 = nCurValue .. "/" .. nMaxValue
	end
		
	if IsShowStateValueTwoFormat() and not bIngore then
		local szState = szState2 .. "("..szState1..")"
		return szState
	end
	
	if IsShowStateValueByPercentage() then
		return szState1
	else
		return szState2
	end
	
	return ""
end

function IsObjectItem(dwType)
	return (dwType == UI_OBJECT_ITEM or dwType == UI_OBJECT_SHOP_ITEM or dwType == UI_OBJECT_OTER_PLAYER_ITEM or dwType == UI_OBJECT_ITEM_ONLY_ID or dwType == UI_OBJECT_ITEM_INFO )
end

g_bDebugMode = true --内部使用的调试版本

function IsObjectFromBag(dwBox)
 	if dwBox == INVENTORY_INDEX.EQUIP then
 		return false
 	elseif dwBox == INVENTORY_INDEX.PACKAGE then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE1 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE2 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE3 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE4 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.BANK then
 		return true
 	elseif dwBox == INVENTORY_INDEX.BANK_PACKAGE1 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.BANK_PACKAGE2 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.BANK_PACKAGE3 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.BANK_PACKAGE4 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.BANK_PACKAGE5 then
 		return true
	elseif dwBox == INVENTORY_INDEX.SOLD_LIST then
		return false
	end
 	return false
 end
 
 function IsObjectFromPackage(dwBox)
 	if dwBox == INVENTORY_INDEX.PACKAGE then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE1 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE2 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE3 then
 		return true
 	elseif dwBox == INVENTORY_INDEX.PACKAGE4 then
 		return true
    end
 	return false
 end
 