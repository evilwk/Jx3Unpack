---------------------------------------
------Kiko�ĳɾ�Զ�̵����ļ�-----------
------Created by Hu Chang Yin----------
---			ɽ�Һ컨����ͷ			---
---			�񽭴�ˮ��ɽ��			---
---			������˥������			---
---			ˮ��������ٯ��			---
---------------------------------------

-------------װ���������--------------
local OnMountEquip = function(event)
	if event ~= "EQUIP_ITEM_UPDATE" or arg0 ~= INVENTORY_INDEX.EQUIP then
		return
	end
	
	local player = GetClientPlayer()
	if arg1 >= EQUIPMENT_INVENTORY.PACKAGE1 and arg1 <= EQUIPMENT_INVENTORY.PACKAGE4 then --װ�������ɾ�
		
		local item = GetPlayerItem(player, arg0, arg1)
		if item then
			if not player.IsAchievementAcquired(711) then
				RemoteCallToServer("OnClientAddAchievement", "first_equip_package")
			end
			
			local b = 
			{
				[1] = {24, "Package_Mine"},
				[2] = {23, "Package_Grass"},
				[3] = {25, "Package_Fur"},
				[4] = {22, "Package_Book"},
			}
			local v = b[item.nDetail]
			if v then
				if not player.IsAchievementAcquired(v[1]) then
					RemoteCallToServer("OnClientAddAchievement", v[2])
				end
			end
		end
		
		local a = 
		{
			[6] = {14, "Package_6"},
			[8] = {15, "Package_8"},
			[10] = {16, "Package_10"},
			[12] = {17, "Package_12"},
			[14] = {18, "Package_14"},
			[16] = {19, "Package_16"},
			[18] = {20, "Package_18"},
			[20] = {21, "Package_20"},
			[22] = {2334, "Package_22"},
		}
			
		local dwSize = player.GetBoxSize(INVENTORY_INDEX.PACKAGE1)
		local v = a[dwSize]
		if v and GetBagContainType(INVENTORY_INDEX.PACKAGE1) == 0 and
			dwSize == player.GetBoxSize(INVENTORY_INDEX.PACKAGE2) and GetBagContainType(INVENTORY_INDEX.PACKAGE2) == 0 and
			dwSize == player.GetBoxSize(INVENTORY_INDEX.PACKAGE3) and GetBagContainType(INVENTORY_INDEX.PACKAGE3) == 0 and 
			dwSize == player.GetBoxSize(INVENTORY_INDEX.PACKAGE4) and GetBagContainType(INVENTORY_INDEX.PACKAGE4) == 0 then
			if not player.IsAchievementAcquired(v[1]) then 
				RemoteCallToServer("OnClientAddAchievement", v[2])
			end
		end
	end
	
	if tEquipAchievementItemList then --װ����װ�ɾ�
		local item = GetPlayerItem(player, arg0, arg1)
		if item and item.dwTabType == 7 and tEquipAchievementItemList[item.dwIndex] then
			local t = tEquipAchievementItemList[item.dwIndex]
			local dwAchievement = t[EQUIPMENT_INVENTORY.TOTAL]
			if not player.IsAchievementAcquired(dwAchievement) then
				local bFinish = true
				for k, v in pairs(t) do
					if k ~= EQUIPMENT_INVENTORY.TOTAL then
						local item = GetPlayerItem(player, INVENTORY_INDEX.EQUIP, k)
						if not item or item.dwIndex ~= v then
							bFinish = false
							break
						end
					end
				end
				if bFinish then
					RemoteCallToServer("OnAcquireEquip", dwAchievement)
				end
			end
		end
	end
	
	if tSetEquipAchievementList then
		local item = GetPlayerItem(player, arg0, arg1)
		if item then
			local t = tSetEquipAchievementList[item.dwSetID]
			if t and not player.IsAchievementAcquired(t.dwAchievementID) and player.GetEquipSetItemCount(item.dwSetID) >= t.nCount then
				RemoteCallToServer("OnAcquireSetEquip", item.dwSetID)
			end
		end
	end
	
	if tEquipQualityList[arg1] then
		if not player.IsAchievementAcquired(131) then
			if IsAllEquipQuality(player, 3) then
				RemoteCallToServer("OnClientAddAchievement", "ItemQuality_3")
			end
		end
	

		if not player.IsAchievementAcquired(132) then
			if IsAllEquipQuality(player, 4) then
				RemoteCallToServer("OnClientAddAchievement", "ItemQuality_4")
			end
		end

		if not player.IsAchievementAcquired(35) then
			if IsAllEquipLevel(player, 120) then
				RemoteCallToServer("OnClientAddAchievement", "ItemQuality_120")
			end
		end

		if not player.IsAchievementAcquired(90) then
			if IsAllEquipLevel(player, 140) then
				RemoteCallToServer("OnClientAddAchievement", "ItemQuality_140")
			end
		end

		if not player.IsAchievementAcquired(374) then
			if IsAllEquipLevel(player, 160) then
				RemoteCallToServer("OnClientAddAchievement", "ItemQuality_160")
			end
		end
	end
	local aEquipScore =
	{
		{nAchievementID = 2902, key="EQUIP_SCORE1000"},	
		{nAchievementID = 2903, key="EQUIP_SCORE2000"},	
		{nAchievementID = 2904, key="EQUIP_SCORE3000"},	
		{nAchievementID = 2905, key="EQUIP_SCORE3500"},	
		{nAchievementID = 2906, key="EQUIP_SCORE4000"},	
		{nAchievementID = 2907, key="EQUIP_SCORE5000"},	
	}
	local nScores = player.GetTotalEquipScore()
	local nLevel  = GetEquipScoresLevel(nScores)
	if nLevel > 0 then
		for i=1, nLevel, 1 do
			if not player.IsAchievementAcquired(aEquipScore[i].nAchievementID) then
				RemoteCallToServer("OnClientAddAchievement", aEquipScore[i].key)
			end
		end
	end
end

RegisterEvent("EQUIP_ITEM_UPDATE", OnMountEquip)

-------------------��ý�Ǯ-------------------
local OnMoneyUpdate = function(event)
	
	local a = 
	{
		{371, 10000000, "Get1000G"},
		{372, 30000000, "Get3000G"},
		{373, 50000000, "Get5000G"},
		{890, 80000000, "Get8000G"},
		{891, 100000000, "Get10000G"},
	}
	
	local player = GetClientPlayer()
	local nMoney = player.GetMoney()
	for k, v in pairs(a) do
		if nMoney >= v[2] then
			if not player.IsAchievementAcquired(v[1]) then 
				RemoteCallToServer("OnClientAddAchievement", v[3])
			end
		else
			break
		end
	end
end

RegisterEvent("MONEY_UPDATE", OnMoneyUpdate)

-------------����������سɾ�-----------------
local OnReputationLevelUpdate = function(event)
	local a =
	{
		{35, 7, 503, "Luoyang_Zunjin"}, 		-- ������������
		{36, 7, 504, "Changan_Zunjin"}, 	   	-- ������������
		{34, 7, 505, "Yangzhou_Zunjin"}, 	   	-- ������������
		{11, 7, 506, "Shaolin_Zunjin"}, 	   	-- ������������
		{14, 7, 507, "Chunyang_Zunjin"}, 	   	-- ������������
		{12, 7, 508, "Wanhua_Zunjin"}, 	   		-- ����������
		{15, 7, 509, "Qixiu_Zunjin"}, 	   		-- ������������
		{13, 7, 510, "Tiance_Zunjin"}, 	   		-- �����������
		{18, 7, 1346, "Cangjian_Zunjin"}, 	   		-- �ؽ���������
		{50, 7, 511, "Haoqimeng_Zunjin"},		-- ��������������
		{49, 7, 512, "Erengu_Zunjin"}, 	   		-- ���˹���������
		--{38, 3, 513, "Hongyijiao_Zhongli"}, 	-- ���½�����������
		{38, 4, 514, "Hongyijiao_Youshan"},		-- ���½��������Ѻ�
		{46, 4, 815, "Kunlun_Youshan"}, 	   	-- �����������Ѻ�
		{47, 4, 816, "Daozong_Youshan"}, 	   	-- �����������Ѻ�
		{46, 5, 817, "Kunlun_qinmi"}, 	   		-- ��������������
		{47, 5, 818, "Daozong_qinmi"}, 	   		-- ��������������
		{45, 7, 819, "Changgemen_Zunjin"}, 	   	-- ��������������
		{44, 7, 820, "Donglizhai_Zunjin"}, 	   	-- ����կ����������
		{48, 7, 821, "Yingyuanhui_Zunjin"}, 	-- ��Ԫ������������
		{43, 7, 822, "Shanghui_Zunjin"}, 	   	-- �̻�����������
		{42, 7, 823, "Biaoju_Zunjin"}, 	   		-- �ھ�����������
		{16, 7, 1881, "Wudu_Zunjin"}, 	   		-- �嶾����������
		{83, 7, 1879, "Cangjingge_Zunjin"}, 	   		-- �ؾ�������������
		{84, 7, 1880, "Badao_Zunjin"}, 	   		-- �Ե�����������
		{85, 7, 1882, "Daligong_Zunjin"}, 	   		-- ��������������
		{86, 7, 1883, "Tana_Zunjin"}, 	   		-- ��������������
		{87, 7, 1884, "Zhurongdian_Zunjin"}, 	   		-- ף�ڵ�����������
		{88, 7, 1885, "Tiannanwangjia_Zunjin"}, 	   		-- ������������������
		{89, 7, 1886, "Baihuojiao_Zunjin"}, 	   		-- �ݻ������������
		{90, 7, 1887, "Jiulizu_Zunjin"}, 	   		-- ����������������
		{91, 7, 1888, "Zhennanbiaoju_Zunjin"}, 	   		-- �����ھ�����������
		{82, 7, 2396, "Xuanyuanshe_Zunjin"}, 	   		-- ��ԯ������������
		{17, 7, 2708, "Tangmen_Zunjin"}, 	   		-- ��������������
	}
	
	local player = GetClientPlayer()
	for k, v in ipairs(a) do
		if not player.IsReputationHide(v[1]) and player.GetReputeLevel(v[1]) >= v[2] then
			if not player.IsAchievementAcquired(v[3]) then
				RemoteCallToServer("OnClientAddAchievement", v[4])
			end
		end
	end
end

RegisterEvent("REPUTATION_LEVEL_UPDATE", OnReputationLevelUpdate)

---------------����������-----------------
local OnPrestigeUpdate = function(event)
	local a = 
	{
		{840, 9000, "Prestige9000"},
		{841, 12000, "Prestige12000"},
		{549, 15000, "Prestige15000"},
		{550, 20000, "Prestige20000"},
		{551, 50000, "Prestige50000"},
	}
	
	local player = GetClientPlayer()	
	for k, v in pairs(a) do
		if player.nCurrentPrestige >= v[2] then
			if not player.IsAchievementAcquired(v[1]) then 
				RemoteCallToServer("OnClientAddAchievement", v[3])
			end
		else
			break
		end
	end
end
	
RegisterEvent("UPDATE_PRESTIGE", OnPrestigeUpdate)

--------------���ְ���-----------------------
local OnOutPutComment = function(event)
	local player = GetClientPlayer()
	if player then
		if not player.IsAchievementAcquired(8) then
			RemoteCallToServer("OnClientAddAchievement", "OutputComment")
		end
	end
end

RegisterEvent("ON_OUT_PUT_COMMENT", OnOutPutComment)


--------------ʹ������-----------------------
local OnUseChat = function(event)	
	if arg0 == PLAYER_TALK_CHANNEL.WHISPER then
		if not GetClientPlayer().IsAchievementAcquired(11) then
			RemoteCallToServer("OnClientAddAchievement", "Chat_Whisper")
		end		
	elseif arg0 == PLAYER_TALK_CHANNEL.SENCE then
		if not GetClientPlayer().IsAchievementAcquired(13) then
			RemoteCallToServer("OnClientAddAchievement", "Chat_Yell")
		end
	elseif arg0 == PLAYER_TALK_CHANNEL.TONG then
		if not GetClientPlayer().IsAchievementAcquired(709) then
			RemoteCallToServer("OnClientAddAchievement", "Chat_Tong")
		end
	elseif arg0 == PLAYER_TALK_CHANNEL.WORLD then
		if not GetClientPlayer().IsAchievementAcquired(12) then
			RemoteCallToServer("OnClientAddAchievement", "Chat_World")
		end
	elseif arg0 == PLAYER_TALK_CHANNEL.CAMP then
		if not GetClientPlayer().IsAchievementAcquired(710) then
			RemoteCallToServer("OnClientAddAchievement", "Chat_Camp")
		end		
	end
end

RegisterEvent("ON_USE_CHAT", OnUseChat)


-------------------���׶����-------------------
OnContributionUpdate = function(event)
	local a = 
	{
		{543, 10000, "Contribution10000"},
		{544, 35000, "Contribution35000"},
		{545, 70000, "Contribution70000"},
	}
	local player = GetClientPlayer()	
	for k, v in pairs(a) do
		if player.nContribution >= v[2] then
			if not player.IsAchievementAcquired(v[1]) then 
				RemoteCallToServer("OnClientAddAchievement", v[3])
			end
		else
			break
		end
	end
end
		
RegisterEvent("CONTRIBUTION_UPDATE", OnContributionUpdate)

-------------------�ȼ�����-------------------
local OnPlayerLevelUp = function()
	local a = 
	{
		{5, 706, "Level_5"},
		{10, 1, "Level_10"},
		{20, 2, "Level_20"},
		{30, 3, "Level_30"},
		{40, 4, "Level_40"},
		{50, 5, "Level_50"},
		{60, 6, "Level_60"},
		{70, 7, "Level_70"},
		{80, 1877, "Level_80"},
	}
	
	local player = GetClientPlayer()
	for k, v in ipairs(a) do
		if player.nLevel >= v[1] then
			if not player.IsAchievementAcquired(v[2]) then 
				RemoteCallToServer("OnClientAddAchievement", v[3])
			end
		else
			break
		end
	end
end

RegisterEvent("PLAYER_LEVEL_UP", OnPlayerLevelUp)

-----------------������-------------------
local OnPartyMsgNotify = function(event)
    if arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_CREATED or arg0 == PARTY_NOTIFY_CODE.PNC_PARTY_JOINED then
		if not GetClientPlayer().IsAchievementAcquired(708) then
			RemoteCallToServer("OnClientAddAchievement", "MakeParty")
		end
	end	
end

RegisterEvent("PARTY_MESSAGE_NOTIFY", OnPartyMsgNotify)

----------------�����Ʒ---------------------
local OnAcquireItem = function(event)
	if arg0 ~= GetClientPlayer().dwID then
		return
	end
	local item = GetItem(arg1)
	if not item then
		return
	end
	
	local player = GetClientPlayer()
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		if item.nSub == EQUIPMENT_SUB.HORSE then
			if not player.IsAchievementAcquired(10) then
				RemoteCallToServer("OnAcquireItem", item.dwTabType, item.dwIndex, "horse") --��
			end
--[[		elseif item.nSub == EQUIPMENT_SUB.WAIST_EXTEND or item.nSub == EQUIPMENT_SUB.BACK_EXTEND then --�Ҽ�
			local tExtendList = {
				["Extend_1"] = 730,
				["Extend_5"] = 731,
				["Extend_10"] = 732,
				["Extend_20"] = 733,
				["Extend_30"] = 1903,
				["Extend_50"] = 1904,
				["Extend_70"] = 1905,
				["Extend_80"] = 1906,
				["Extend_100"] = 1907,
				["Extend_150"] = 1908,
			}
			for k, v in pairs(tExtendList) do
				if not player.IsAchievementAcquired(v) then
					RemoteCallToServer("OnClientAddAchievement", k)
				end
			end--]]
		end
	end
	
	local tAchievementInfo = tItemAcquireAchievementList[item.dwIndex]
	if not tAchievementInfo then
		return
	end
	
	if player.IsAchievementAcquired(tAchievementInfo.dwAchievementID) then
		return
	end
	
	if tAchievementInfo.nType ~= item.dwTabType then
		return
	end

	RemoteCallToServer("OnAcquireItem", item.dwTabType, item.dwIndex)
end

RegisterEvent("LOOT_ITEM", OnAcquireItem)


--------------ʹ�ñ������---------------------	
local aEmotionAchievementPlayer = 
{
	["/����"] = 
	{
		{26, "Emotion_YanZou"},						--�����ʹ������
	},
	
	["all"] = 
	{
		{27, "Emotion_Player"},						--�����ʹ�ñ���
	},
}

local aEmotionAchievementNpc = 	
{
	["/��Ҿ"] = 
	{
		[640] = {641, "Emotion_XuanZheng"},				-- ����
		["����"] = {641, "Emotion_XuanZheng"}, 			-- ��������
		[715] = {642, "Emotion_LiWangSheng"},			-- ������
		["������"] = {642, "Emotion_LiWangSheng"}, 	-- ����������
		[2131] = {643, "Emotion_YeZhiQing"},			-- Ҷ����
		["Ҷ����"] = {643, "Emotion_YeZhiQing"},		-- ����Ҷ����
		[96] = {644, "Emotion_DongFang"},				-- ��������
		["��������"] = {644, "Emotion_DongFang"},				-- ���񶫷�����
		[1641] = {645, "Emotion_LiChengEn"},			-- ��ж�
		["��ж�"] = {645, "Emotion_LiChengEn"},			-- ������ж�
		
		[5308] = {658, "Emotion_XieYuan"},				-- лԨ
		[7776] = {658, "Emotion_XieYuan"},				-- лԨ
		
		[5193] = {659, "Emotion_ZhangZhiYuan"},			-- ����ԯ
		[7767] = {659, "Emotion_ZhangZhiYuan"},			-- ����ԯ
		[5870] = {659, "Emotion_ZhangZhiYuan"},			-- ����ԯ
		["����ԯ"] = {659, "Emotion_ZhangZhiYuan"},			-- ����ԯ
		
		[5194] = {660, "Emotion_ZhaiJiZhen"},			-- �Լ���
		[7769] = {660, "Emotion_ZhaiJiZhen"},			-- �Լ���
		
		[5195] = {661, "Emotion_YueNongHen"},			-- ��Ū��
		[7770] = {661, "Emotion_YueNongHen"},			-- ��Ū��
		
		[4803] = {662, "Emotion_KangXueZhu"},			-- ��ѩ��
		[7782] = {662, "Emotion_KangXueZhu"},			-- ��ѩ��
		
		[4822] = {663, "Emotion_MiLiGuLi"},				-- ��������
		[7779] = {663, "Emotion_MiLiGuLi"},				-- ��������
		
		[4842] = {664, "Emotion_ShenMianFeng"},			-- ���߷�
		[7781] = {664, "Emotion_ShenMianFeng"},			-- ���߷�
		
		[6073] = {665, "Emotion_MoYu"},					-- Ī��
		[7785] = {665, "Emotion_MoYu"},					-- Ī��
		
		["���ŷ�"] = {636, "Emotion_WangYiFeng"},		-- ���ŷ�
		["Фҩ��"] = {637, "Emotion_XiaoYaoEr"},		-- Фҩ��
		["�º���"] = {648, "Emotion_ChenHeShang"},		-- �º���
		["�պ�ͤ"] = {649, "Emotion_TaoHanTing"},		-- �պ�ͤ
		["������"] = {650, "Emotion_LiuGongZi"},		-- ������
		["����"] = {651, "Emotion_KeRen"},				-- ����
		["˾����ƽ"] = {652, "Emotion_SiKongZhongPin"},	-- ˾����ƽ
		["Ӱ"] = {653, "Emotion_Ying"},					-- Ӱ
		["�Ÿ�"] = {654, "Emotion_DuFu"},				-- �Ÿ�
		["ɽʯ����"] = {655, "Emotion_ShanShiDaoRen"},	-- ɽʯ����
		["������"] = {656, "Emotion_YanZhenQin"},		-- ������
		["���"] = {657, "Emotion_LiBai"},				-- ���
		["��"] = {666, "Emotion_Yan"},					-- ��
		[7008] = {1302, "Emotion_SongChong"},			-- Ҧ��
		[7009] = {1303, "Emotion_SongJing"},			-- �έZ
		[7010] = {1304, "Emotion_zhangJiuLing"},		-- �ž���
		[6627] = {1340, "Emotion_yeying"},				-- ҶӢ	
		[6628] = {1341, "Emotion_yehui"},				-- Ҷ��
		[6629] = {1342, "Emotion_yewei"},				-- Ҷ�	
		[6625] = {1343, "Emotion_yemeng"},				-- Ҷ��
		[6630] = {1344, "Emotion_yefan"},				-- Ҷ��
		["�����"] = {1683, "Emotion_ShaoQingCheng"}, 	-- �����
		["�߾���"] = {1684, "Emotion_GaoJiuWen"}, 	-- �߾���
		["³ӡ"] = {1685, "Emotion_LuYin"}, 	-- ³ӡ
		["�ղ���"] = {1686, "Emotion_SuBuChen"}, 	-- �ղ���
		["������"] = {1687, "Emotion_XinSanJin"}, 	-- ������
		["�η�"] = {1688, "Emotion_HeFei"}, 	-- �η�
		["������"] = {1689, "Emotion_HanFeiZi"}, 	-- ������
		[8840] = {1815, "Emotion_WangZhaoNan"},				-- ������
		[11598] = {1870, "Emotion_HuWang"},				-- ����
		[11626] = {1871, "Emotion_LangWang"},				-- ����
		[10016] = {1872, "Emotion_LuWang"},				-- ¹��
		[11601] = {1873, "Emotion_YangWang"},				-- ����
		[9331] = {1895, "Emotion_QuYun"},				-- ����
		["����̫̫"] = {2706, "Emotion_TangLaoTaiTai"}, 	-- ����̫̫
	},
	
	["/��"] = 
	{
		["�����"] = {486, "Emotion_FengDaoRen"},		-- �����
	},

	["/֧��"] = 
	{
		[3454] = {489, "Emotion_GeNv"},					-- �����ĸ�Ů
	},

	["/����"] = 
	{
		[90] = {490, "Emotion_SuYuLuan"},				-- ����ʥ
	},
	
	["/˵��"] = 
	{
		[5222] = {832, "Emotion_Child"},				-- ���������С��
		[3267] = {488, "Emotion_LaoQiGai"},				-- ��ˮ������ؤ
		["��С��"] = {487, "Emotion_ChuXiaoMei"},		-- ��С��
	}
}
	
local OnUseEmotion = function(event)
	local dwTargetType, dwTargetID, szEmotion = arg0, arg1, arg2
	
	local player = GetClientPlayer()
	
	if dwTargetType == TARGET.PLAYER and GetPlayer(dwTargetID) and dwTargetID ~= player.dwID then
		local a = aEmotionAchievementPlayer[szEmotion]
		if a then
			for k, v in ipairs(a) do
				if not player.IsAchievementAcquired(v[1]) then
					RemoteCallToServer("OnClientAddAchievement", v[2])
				end
			end
		end
		a = aEmotionAchievementPlayer["all"]
		if a then
			for k, v in ipairs(a) do
				if not player.IsAchievementAcquired(v[1]) then
					RemoteCallToServer("OnClientAddAchievement", v[2])
				end
			end
		end
	elseif dwTargetType == TARGET.NPC then
		local a = aEmotionAchievementNpc[szEmotion]
		if a then
			local npc = GetNpc(dwTargetID)
			if npc then
				local v = a[npc.dwTemplateID]
				if v then
					if not player.IsAchievementAcquired(v[1]) then
						RemoteCallToServer("OnClientAddAchievement", v[2])
					end
				end
				v = a[npc.szName]
				if v then
					if not player.IsAchievementAcquired(v[1]) then
						RemoteCallToServer("OnClientAddAchievement", v[2])
					end
				end
			end
		end
	end	
end	

RegisterEvent("ON_USE_EMOTION", OnUseEmotion)


----------------������ؼ�----------------
local OnActiveSkillRecipe = function(event)
	if not GetClientPlayer().IsAchievementAcquired(719) then
		RemoteCallToServer("OnClientAddAchievement", "AcitveRecipe")
	end
end

RegisterEvent("ON_ACTIVE_SKILL_RECIPE", OnActiveSkillRecipe)


---------------���Ѫ������������---------------
local OnUpdatePlayerState = function(event)
	local player = GetClientPlayer()
	if arg0 == player.dwID and player.nCurrentMana <= 1 and player.nMoveState ~= MOVE_STATE.ON_DEATH then
		if not GetClientPlayer().IsAchievementAcquired(168) then --��һ�������þ�
			RemoteCallToServer("OnClientAddAchievement", "ManaLow")
		end
	end
end

RegisterEvent("PLAYER_STATE_UPDATE", OnUpdatePlayerState)

-------------�����Ծ-------------------------
local OnPlayerJump = function(event)
	local player = GetClientPlayer()
	if player.nMoveState == MOVE_STATE.ON_JUMP or player.nMoveState == MOVE_STATE.ON_SWIM_JUMP then
		if not GetClientPlayer().IsAchievementAcquired(707) then --��һ�ζ�����
			RemoteCallToServer("OnClientAddAchievement", "TwoTimeJump")
		end		
	end
end

RegisterEvent("ON_PLAYER_JUMP", OnPlayerJump)


---------------��ȡ�ƺ�----------------------
local OnAquireDesignation = function()
	local player = GetClientPlayer()
	local nCount = player.GetAcquiredDesignationCount()
	if not player.IsAchievementAcquired(713) and nCount >= 1 then
		RemoteCallToServer("OnClientAddAchievement", "Designation_1")
	end
	if not player.IsAchievementAcquired(712) and nCount >= 10 then
		RemoteCallToServer("OnClientAddAchievement", "Designation_10")
	end
	if not player.IsAchievementAcquired(151) and nCount >= 20 then
		RemoteCallToServer("OnClientAddAchievement", "Designation_20")
	end
	if not player.IsAchievementAcquired(152) and nCount >= 50 then
		RemoteCallToServer("OnClientAddAchievement", "Designation_50")
	end
end

RegisterEvent("ACQUIRE_DESIGNATION", OnAquireDesignation)

---------------��ȡ����----------------------
local function OnUpdatePrestige()
	local hPlayer = GetClientPlayer()
	local a = 
	{
		{840, 1000, "Prestige1000"},
		{841, 2000, "Prestige2000"},
		{549, 5000, "Prestige5000"},
		{550, 20000, "Prestige20000"},
		{551, 50000, "Prestige50000"},
	}
	local player = GetClientPlayer()	
	for k, v in pairs(a) do
		if hPlayer.nCurrentPrestige >= v[2] then
			if not player.IsAchievementAcquired(v[1]) then 
				RemoteCallToServer("OnClientAddAchievement", v[3])
			end
		else
			break
		end
	end
end

RegisterEvent("UPDATE_PRESTIGE", OnUpdatePrestige)

--------------��һ�ν��׳ɹ�----------------------
local OnFirstTimeTradingSuccess = function()
	if arg0 == "UI_OME_TRADING_RESPOND" then
		if arg1 == TRADING_RESPOND_CODE.SUCCESS then
			local pClientPlayer = GetClientPlayer()
			if not pClientPlayer.IsAchievementAcquired(985) then
				RemoteCallToServer("OnClientAddAchievement", "Trading_Success_1")
			end
			return
		end
	end
end

RegisterEvent("SYS_MSG", OnFirstTimeTradingSuccess)

------------��һ�β鿴�����Ķ�----------------------

local OnFirstTimePeekRead = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(986) then
		RemoteCallToServer("OnClientAddAchievement", "Peek_Book_1")
	end
end

RegisterEvent("PEEK_PLAYER_BOOK_STATE", OnFirstTimePeekRead)

------------��һ�β鿴��������----------------------

local OnFirstTimePeekQuest = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(987) then
		RemoteCallToServer("OnClientAddAchievement", "Peek_Quest_1")
	end
end

RegisterEvent("PEEK_PLAYER_QUEST", OnFirstTimePeekQuest)

------------��һ��ɾ������----------------------
local OnFirstTimeDelFriend = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(988) then
		RemoteCallToServer("OnClientAddAchievement", "Delete_Friend_1")
	end
end

RegisterEvent("DELETE_FELLOWSHIP", OnFirstTimeDelFriend)

------------��һ�δ򿪽�����----------------------

local OnFirstTimeOpenAuction = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(990) then
		RemoteCallToServer("OnClientAddAchievement", "Open_Auction_1")
	end
end

RegisterEvent("OPEN_AUCTION", OnFirstTimeOpenAuction)

------------��һ�ι���������Ʒ----------------------
local OnFirstTimeBuyAuctionItem = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(991) then
		RemoteCallToServer("OnClientAddAchievement", "Buy_Auction_Item_1")
	end
end

RegisterEvent("BUY_AUCTION_ITEM", OnFirstTimeBuyAuctionItem)

------------��һ�γ��۽�������Ʒ----------------------
local OnFirstTimeSellAuctionItem = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(992) then
		RemoteCallToServer("OnClientAddAchievement", "Sell_Auction_Item_1")
	end
end

RegisterEvent("SELL_AUCTION_ITEM", OnFirstTimeSellAuctionItem)

------------��һ�ν�����--------------------------------

local OnFirstAcceptQuest = function()
	local pClientPlayer = GetClientPlayer()
	if not pClientPlayer.IsAchievementAcquired(980) then
		RemoteCallToServer("OnClientAddAchievement", "Accept_Quest_1")
	end
end

RegisterEvent("QUEST_ACCEPTED", OnFirstAcceptQuest)


---------- �Ķ��鼮-----------------------------------
local OnReadBook = function(event)
	local a = 
	{
		[1152] = {1063, "ReadBook_1152"},
		[1153] = {1064, "ReadBook_1153"},
		[1154] = {1065, "ReadBook_1154"},
		[1155] = {1066, "ReadBook_1155"},
		[1156] = {1067, "ReadBook_1156"},
		[1157] = {1068, "ReadBook_1157"},
		[1158] = {1069, "ReadBook_1158"},
		[1159] = {1070, "ReadBook_1159"},
		[1160] = {1172, "ReadBook_1160"},
		[1161] = {1173, "ReadBook_1161"},
		[1162] = {1174, "ReadBook_1162"},
		[1163] = {1175, "ReadBook_1163"},
		[1164] = {1176, "ReadBook_1164"},
		[1165] = {1177, "ReadBook_1165"},
		[1166] = {1178, "ReadBook_1166"},
		[1167] = {1179, "ReadBook_1167"},
		[1192] = {2072, "ReadBook_1192"}, -- �쳾��Թ����
		[1193] = {2073, "ReadBook_1193"},
		[1194] = {2074, "ReadBook_1194"},
		[1195] = {2075, "ReadBook_1195"},
		[1196] = {2076, "ReadBook_1196"},
		[1197] = {2077, "ReadBook_1197"},
		[1198] = {2078, "ReadBook_1198"},
    [1199] = {2079, "ReadBook_1199"},
		[1200] = {2081, "ReadBook_1200"},   -- Ѫ��֮��
		[1201] = {2082, "ReadBook_1201"},
		[1202] = {2083, "ReadBook_1202"},
		[1203] = {2084, "ReadBook_1203"},
		[1204] = {2085, "ReadBook_1204"},
		[1205] = {2086, "ReadBook_1205"},
		[1206] = {2087, "ReadBook_1206"},
		[1207] = {2088, "ReadBook_1207"},
		[1208] = {2090, "ReadBook_1208"},  -- Ѫ�����ţ���Ħ����
		[1209] = {2091, "ReadBook_1209"},
		[1210] = {2092, "ReadBook_1210"},
		[1211] = {2093, "ReadBook_1211"},
		[1212] = {2094, "ReadBook_1212"},
		[1213] = {2095, "ReadBook_1213"},
		[1214] = {2096, "ReadBook_1214"},
		[1215] = {2097, "ReadBook_1215"},
		[1216] = {2099, "ReadBook_1216"}, -- ���������
		[1217] = {2100, "ReadBook_1217"},
		[1218] = {2101, "ReadBook_1218"},
		[1219] = {2102, "ReadBook_1219"},
		[1220] = {2103, "ReadBook_1220"},
		[1221] = {2104, "ReadBook_1221"},
		[1222] = {2105, "ReadBook_1222"},
		[1223] = {2106, "ReadBook_1223"},   
		[1224] = {2108, "ReadBook_1224"}, --  ��������
		[1225] = {2109, "ReadBook_1225"},
		[1226] = {2110, "ReadBook_1226"},
		[1227] = {2111, "ReadBook_1227"},
		[1228] = {2112, "ReadBook_1228"},
		[1229] = {2113, "ReadBook_1229"},
		[1230] = {2114, "ReadBook_1230"},
		[1231] = {2115, "ReadBook_1231"},     
		[1232] = {2117, "ReadBook_1232"}, -- лԨ�д�
		[1233] = {2118, "ReadBook_1233"},
		[1234] = {2119, "ReadBook_1234"},
		[1235] = {2120, "ReadBook_1235"},
		[1236] = {2121, "ReadBook_1236"},
		[1237] = {2122, "ReadBook_1237"},
		[1238] = {2123, "ReadBook_1238"},
		[1239] = {2124, "ReadBook_1239"},
		[1240] = {2126, "ReadBook_1240"}, --  ��֮��Ұ
		[1241] = {2127, "ReadBook_1241"},
		[1242] = {2128, "ReadBook_1242"},
		[1243] = {2129, "ReadBook_1243"},
		[1244] = {2130, "ReadBook_1244"},
		[1245] = {2131, "ReadBook_1245"},
		[1246] = {2132, "ReadBook_1246"},
		[1248] = {2134, "ReadBook_1248"}, --  ��������
		[1249] = {2135, "ReadBook_1249"},
		[1250] = {2136, "ReadBook_1250"},
		[1251] = {2137, "ReadBook_1251"},
		[1252] = {2138, "ReadBook_1252"},
		[1253] = {2139, "ReadBook_1253"},
		[1254] = {2140, "ReadBook_1254"},       
		[1256] = {2142, "ReadBook_1256"}, --  �����ƹ�����
		[1257] = {2143, "ReadBook_1257"},
		[1258] = {2144, "ReadBook_1258"},
		[1259] = {2145, "ReadBook_1259"},
		[1260] = {2146, "ReadBook_1260"},
		[1261] = {2147, "ReadBook_1261"},
		[1264] = {2149, "ReadBook_1264"}, --   ǧ��
		[1265] = {2150, "ReadBook_1265"},
		[1266] = {2151, "ReadBook_1266"},
		[1267] = {2152, "ReadBook_1267"},
		[1268] = {2153, "ReadBook_1268"},
		[1272] = {2155, "ReadBook_1272"}, --   �����񻰹��´�˵
		[1273] = {2156, "ReadBook_1273"},
		[1274] = {2157, "ReadBook_1274"},
		[1275] = {2158, "ReadBook_1275"},
		[1276] = {2159, "ReadBook_1276"},
		[1277] = {2160, "ReadBook_1277"},
		[1280] = {2162, "ReadBook_1280"}, --  ���쾭�����ľ�
		[1281] = {2163, "ReadBook_1281"},
		[1282] = {2164, "ReadBook_1282"},
		[1283] = {2165, "ReadBook_1283"},     
		[1288] = {2167, "ReadBook_1288"}, --  ���ƾ�����¼����
		[1289] = {2168, "ReadBook_1289"},
		[1290] = {2169, "ReadBook_1290"},
		[1291] = {2170, "ReadBook_1291"},
		[1292] = {2171, "ReadBook_1292"},
		[1296] = {2173, "ReadBook_1296"}, -- �������
		[1297] = {2174, "ReadBook_1297"},
		[1298] = {2175, "ReadBook_1298"},
		[1299] = {2176, "ReadBook_1299"},
		[1300] = {2177, "ReadBook_1300"},
		[1301] = {2178, "ReadBook_1301"},
		[1302] = {2179, "ReadBook_1302"},
		[1303] = {2180, "ReadBook_1303"},
		[1304] = {2182, "ReadBook_1304"}, --  �쳾����
		[1305] = {2183, "ReadBook_1305"},
		[1306] = {2184, "ReadBook_1306"},
		[1307] = {2185, "ReadBook_1307"},
		[1308] = {2186, "ReadBook_1308"},
		[1309] = {2187, "ReadBook_1309"},
		[1310] = {2188, "ReadBook_1310"},
		[1311] = {2189, "ReadBook_1311"},
		[1312] = {2191, "ReadBook_1312"}, --   ����־��
		[1313] = {2192, "ReadBook_1313"},
		[1314] = {2193, "ReadBook_1314"},
		[1315] = {2194, "ReadBook_1315"},
		[1316] = {2195, "ReadBook_1316"},
		[1317] = {2196, "ReadBook_1317"},
		[1318] = {2197, "ReadBook_1318"},
		[1319] = {2198, "ReadBook_1319"},
		[1320] = {2200, "ReadBook_1320"}, --    ����ʥ��
		[1321] = {2201, "ReadBook_1321"},
		[1322] = {2202, "ReadBook_1322"},
		[1323] = {2203, "ReadBook_1323"},
		[1324] = {2204, "ReadBook_1324"},
		[1325] = {2205, "ReadBook_1325"},
		[1328] = {2207, "ReadBook_1328"},   --   ĵ��
		[1329] = {2208, "ReadBook_1329"},
		[1330] = {2209, "ReadBook_1330"},
		[1331] = {2210, "ReadBook_1331"},
		[1336] = {2212, "ReadBook_1336"}, --    ʥ�ߡ�����˫
		[1337] = {2213, "ReadBook_1337"},
		[1338] = {2214, "ReadBook_1338"},
		[1339] = {2215, "ReadBook_1339"},
		[1344] = {2217, "ReadBook_1344"}, --  Ľ��׷��
		[1345] = {2218, "ReadBook_1345"},
		[1346] = {2219, "ReadBook_1346"},
		[1347] = {2220, "ReadBook_1347"},
		[1352] = {2222, "ReadBook_1352"}, --   ������
		[1353] = {2223, "ReadBook_1353"},
		[1354] = {2224, "ReadBook_1354"},
		[1355] = {2225, "ReadBook_1355"},
		[1360] = {2227, "ReadBook_1360"}, --   ������
		[1361] = {2228, "ReadBook_1361"},
		[1362] = {2229, "ReadBook_1362"},
		[1363] = {2230, "ReadBook_1363"},
		[1364] = {2231, "ReadBook_1364"},
		[1368] = {2233, "ReadBook_1368"}, --  ɳ����
		[1369] = {2234, "ReadBook_1369"},
		[1370] = {2235, "ReadBook_1370"},
		[1371] = {2236, "ReadBook_1371"},
		[1376] = {2238, "ReadBook_1376"},  -- Ľ�ݷ���
		[1377] = {2239, "ReadBook_1377"},
		[1378] = {2240, "ReadBook_1378"},
		[1379] = {2241, "ReadBook_1379"},
		[1384] = {2243, "ReadBook_1384"}, -- ���ɹ�֮�걾��Ʒ��
		[1385] = {2244, "ReadBook_1385"},
		[1386] = {2245, "ReadBook_1386"},
		[1387] = {2246, "ReadBook_1387"},
		[1392] = {2248, "ReadBook_1392"}, -- �ɶ���һ��
		[1393] = {2249, "ReadBook_1393"},
		[1394] = {2250, "ReadBook_1394"},
		[1395] = {2251, "ReadBook_1395"},
		[1400] = {2253, "ReadBook_1400"}, --  ��Ԩ��2�ޡ��Ӻ�����
		[1401] = {2254, "ReadBook_1401"},
		[1402] = {2255, "ReadBook_1402"},
		[1403] = {2256, "ReadBook_1403"},
		[1408] = {2258, "ReadBook_1408"}, --  ��Ԩ��3�ޡ���ħ�ֵ�
		[1409] = {2259, "ReadBook_1409"},
		[1410] = {2260, "ReadBook_1410"},
		[1411] = {2261, "ReadBook_1411"},
		[1416] = {2263, "ReadBook_1416"}, -- ��Ԩ��4�ޡ���گ˫��
		[1417] = {2264, "ReadBook_1417"},
		[1418] = {2265, "ReadBook_1418"},
		[1419] = {2266, "ReadBook_1419"},
		[1424] = {2268, "ReadBook_1424"}, -- ��Ԩ��5������
		[1425] = {2269, "ReadBook_1425"},
		[1426] = {2270, "ReadBook_1426"},
		[1427] = {2271, "ReadBook_1427"},
		[1432] = {2606, "ReadBook_1432"}, -- �Ѿ�����
		[1433] = {2607, "ReadBook_1433"}, -- ���а��ɸ�
		[1434] = {2608, "ReadBook_1434"}, -- ��������
		[1435] = {2609, "ReadBook_1435"}, -- ����ȼ��
	}
	
	local v = a[arg0]
	local player = GetClientPlayer()
	if v and not player.IsAchievementAcquired(v[1]) then
		RemoteCallToServer("OnClientAddAchievement", v[2])
	end
end

RegisterEvent("ON_READ_BOOK", OnReadBook)

local function OnReadDailyNewsPaper(event)
	local player = GetClientPlayer()
	if not player.IsAchievementAcquired(1085) then
		RemoteCallToServer("OnClientAddAchievement", "Read_NewsPaper")
	end
end

RegisterEvent("OPEN_JX3DAILY", OnReadDailyNewsPaper)

