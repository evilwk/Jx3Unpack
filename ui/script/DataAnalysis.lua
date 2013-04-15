local tTimeSection = {5, 10, 30, 60, 120, 300}

local function GetTimeSetcion(dwTime)
	local nSection = #tTimeSection + 1
	for k, v in ipairs(tTimeSection) do
		if dwTime < v then
			nSection = k
			break
		end
	end
	
	return nSection
end

local function OnDragSkill(tInfo, dwType, dwSkillID)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	
	if not tData or dwType ~= UI_OBJECT_SKILL then
		return
	end
	
  	if szKey == "DRAG_NEWBIE_SKILL" and  (dwSkillID == 49 or dwSkillID == 58) then -- ���ּ��� �ط�ɨҶ���ͻ���ɽ
		RemoteCallToServer("OnUpdateStatData", szKey.."|"..dwSkillID, tData.nValue)
	elseif szKey == "FIRST_DRAG_SKILL" then
		if tData.nAchievementID and player.IsAchievementAcquired(tData.nAchievementID) then   
			return
		end
		RemoteCallToServer("OnClientAddAchievement", szKey)
	end
end

local function OnMendShortCut(tInfo, tOldKeys)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	 
	if not tData then
		return
	end	
	
	if tData.nAchievementID and player.IsAchievementAcquired(tData.nAchievementID) then   
		return
	end
	
	local tCurKeys = Hotkey.GetBinding(false)
	local bMend = false
	
	for k, v in pairs(tOldKeys) do
		local tCur = tCurKeys[k]
		v.Hotkey1 = v.Hotkey1 or {}
		v.Hotkey2 = v.Hotkey2 or {}
		tCur.Hotkey1 = tCur.Hotkey1 or {}
		tCur.Hotkey2 = tCur.Hotkey2 or {}
		
		if v.Hotkey1.nKey ~= tCur.Hotkey1.nKey or 
		   v.Hotkey1.bShift ~= tCur.Hotkey1.bShift or 
		   v.Hotkey1.bCtrl ~= tCur.Hotkey1.bCtrl or 
		   v.Hotkey1.bAlt ~= tCur.Hotkey1.bAlt then
		   	bMend = true
		   	break
		end
	
		if v.Hotkey2.nKey ~= tCur.Hotkey2.nKey or 
		   v.Hotkey2.bShift ~= tCur.Hotkey2.bShift or 
		   v.Hotkey2.bCtrl ~= tCur.Hotkey2.bCtrl or 
		   v.Hotkey2.bAlt ~= tCur.Hotkey2.bAlt then
		   	bMend = true
		   	break
		end
	end
	
	if bMend then
		if tData.nAchievementID then
			RemoteCallToServer("OnClientAddAchievement", szKey)
		else
			RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
		end
		
	end
end

local function OnMendMsgColor(tInfo, tOldColor, tNewColor, szChannel)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	local tMsg = 
	{
		["MSG_NORMAL"] 	     = true,
		["MSG_MAP"] 	     = true,
		["MSG_BATTLE_FILED"] = true,
		["MSG_PARTY"] 	     = true,
		["MSG_SCHOOL"] 	     = true,
		["MSG_GUILD"] 	     = true,
		["MSG_WHISPER"] 	 = true,
		["MSG_GROUP"] 		 = true,
		["MSG_OFFICIAL"] 	 = true,
		["MSG_WORLD"] 	     = true,
		["MSG_TEAM"] 	     = true,
		["MSG_CAMP"] 	     = true,
		
		["MSG_NPC_NEARBY"]   = true,
		["MSG_NPC_YELL"]     = true,
		["MSG_NPC_PARTY"]    = true,
		["MSG_NPC_WHISPER"]  = true,       
		                                                       
		["MSG_SYS"]		     = true,
	}                         
	              
	if not tData or (szChannel and not tMsg[szChannel]) then
		return
	end
	
	if not tOldColor.r or not tOldColor.g or not tOldColor.b then
		return
	end
	
	if tOldColor.r == tNewColor.r and tOldColor.g == tNewColor.g and tOldColor.b == tNewColor.b then
		return
	end
	
	if szChannel then
		szKey = szKey.."|"..szChannel
	end
	local nIndex = ColorTablePanel_GetColorIndex(tNewColor.r, tNewColor.g, tNewColor.b)
	szKey = szKey .."|"..nIndex
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnUseDefaultOrNot(tInfo, nDefaultValue, nNewValue)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	
	if not tData then
		return
	end
	
	local nStatus
	if (math.abs(nNewValue - nDefaultValue) < 0.01) then
		nStatus = 0
	elseif nNewValue > nDefaultValue then
		nStatus = 1
	else
		nStatus = -1
	end
	szKey = szKey.."|"..nStatus
	
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnAdjustMapDiaphaneity(tInfo, nNewValue)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	
	if not tData then
		return
	end
	
	local nValue = math.floor(100 * nNewValue / 255)
	local nLevel = ""
	if nValue >= 50 then
		nLevel = (math.floor((nValue - 40) / 20) + 4)
	else
		nLevel = (math.floor(nValue / 20) + 1)
	end 
	szKey = szKey.."|"..nLevel
	
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnKeyNotesCloseTime(tInfo, nOpenTime, nNowTime)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	
	if not tData then
		return
	end
	
	local nInterval = math.floor((nNowTime  - nOpenTime) / 1000)
	local nStep = GetTimeSetcion(nInterval)  
	szKey = szKey.."|"..nStep
	
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnChangeFontInfo(tInfo, tOldFont, tNewFont)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	local tFontNameMap = 
	{
		[g_tStrings.FONT_XINGKAI]= "XINGKAI",
		[g_tStrings.FONT_JIANZHI]= "JIANZHI",
		[g_tStrings.FONT_HEITI] = "HEITI",
	}
	
	if not tData then
		return
	end
	
	if not tFontNameMap[tNewFont.szName] then
		return
	end
	
	if tOldFont.szName == nil or tOldFont.nSize == nil then
		return
	end
	
	if tOldFont.szName == tNewFont.szName and tOldFont.nSize == tNewFont.nSize then
		return
	end
	
	szKey = szKey.."|".. tFontNameMap[tNewFont.szName].."|"..tNewFont.nSize
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnUsePlugin(tInfo, bAddon)
	local tData = tInfo.tData
	if not tData then
		return
	end
	
	tData.nAddonCount = tData.nAddonCount or 0
	if bAddon then
		tData.nAddonCount = tData.nAddonCount + 1
	else
		tData.nAddonCount = tData.nAddonCount - 1
	end
end

local function OnCareerClick(tInfo, nLevel) 
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	if not tData then
		return
	end

	szKey = szKey .. "|" .. nLevel
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnCyclopaediaCloseTime(tInfo, nOpenTime, nNowTime)
	local player = GetClientPlayer()
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	
	if not tData then
		return
	end
	
	local nTime = math.floor((nNowTime - nOpenTime) / 1000)
	local nSection = GetTimeSetcion(nTime)
	szKey = szKey.."|"..nSection
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

local function OnPlayerAutoExit(tInfo)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local szKey = tInfo.szKey
	local tData = tInfo.tData
	
	if not tData then
		return
	end
	local hScene = hPlayer.GetScene()
	
	szKey = szKey .. "|" .. hScene.dwMapID .. "|" .. hPlayer.nLevel
	RemoteCallToServer("OnUpdateStatData", szKey, tData.nValue)
end

-- {fnAction=��Ҫ���⴦��ĺ����� nAchievementID=ͳ�Ƶ�һ�εģ��߳ɾ����̵ģ� nValue = ����һ��ͳ���ۼӵ���ֵ},	
local DataAnalysis  = 
{
	["DRAG_NEWBIE_SKILL"]             		= {fnAction=OnDragSkill, nValue = 1},				--�϶����ܡ��ͻ���ɽ��,���ط�ɨ��Ҷ��������� 58,49
	["FONT_ZOOM"]                     		= {nValue = 1}, 	  								--�������ŵ�-2 -1, 1, 2
	["UI_ZOOM"]                    	  		= {fnAction=OnUseDefaultOrNot, nValue = 1},			--��һ��ui��������Ĭ�� -1, 1
	                                  		                                                	
	["SELECT_MOUSE_MOVE"]             		= {nValue = 1},										--��ѡ�����·
	["DROP_NEW_HELP"]                 		= {nValue = 1},										--�������ְ���
	["DROP_NEW_HELP_HANDLE"] 	      		= {nValue = 1},										--�������ְ����ؼ�																				
	["LOOK_SUBMIT_QUEST_POINT"]       		= {nValue = 1},										--ʹ��������ֹ��																				
	["LOOK_ACCEPT_QUEST_POINT"]       		= {nValue = 1},										--ʹ��������ʼ��																				
	["MEND_SHOTCUT"] 			      		= {fnAction=OnMendShortCut, nValue = 1},    		--�޸Ŀ�ݼ�\
	                                  		                                                	
	["CHAT_CHANNEL_BACKGROUND_COLOR"] 		= {fnAction=OnMendMsgColor, nValue=1}, 	  			--����Ƶ��������ɫ����
	["CHAT_CHANNEL_FONT"]			  		= {fnAction=OnChangeFontInfo, nValue=1},    		--����Ƶ��������
	["CHAT_MSG_COLOR"] 	     		  		= {fnAction=OnMendMsgColor, nValue=1}, 	  			--����Ƶ����ɫ���� Ƶ������              
	                                  		                                                	         
	["MYSTIQUE_ACTIVE"]               		= {nValue=1}, 	  									--���Ž��漤����������
	["NOT_BIG_BAG"]                   		= {nValue=1},       								--û��ʹ�����ϱ���
	["FIRST_SET_SHOTCUT"]             		= {fnAction=OnMendShortCut, nAchievementID=1071},	--���ÿ�ݼ� ���ȼ�
	["USE_PLUGIN"]                    		= {fnAction=OnUsePlugin, nValue=1},     			--ʹ�ò�������� 
	["KEY_NOTES_TIME"]                		= {fnAction=OnKeyNotesCloseTime, nValue=1},			--������ʾ�ر�ʱ��ͳ�� ��ʱ��
	                                  		                                                	
	["KEY_NOTES_QUEST"]               		= {nValue=1},   	  								--ʹ��������ʾ������ ����
	["KEY_NOTES_SKILL"]               		= {nValue=1},   	  								--ʹ��������ʾ������ ����
	["KEY_NOTES_XIUWEI"]              		= {nValue=1},   	  								--ʹ��������ʾ������ ��Ϊ
	["KEY_NOTES_TILI"]                		= {nValue=1},   	  								--ʹ��������ʾ������ ����
	["KEY_NOTES_JINLI"]               		= {nValue=1},   	  								--ʹ��������ʾ������ ����
	["KEY_NOTES_MAIL"]                		= {nValue=1},   	  								--ʹ��������ʾ������ �ʼ�
	["KEY_NOTES_FRIEND"]              		= {nValue=1},   	  								--ʹ��������ʾ������ ����
	                                                                                        	
	["FIRST_DRAG_SKILL"]              		= {fnAction=OnDragSkill, nAchievementID=1072},		--��һ���϶����� 
	["UI_CUSTOM_MODE"]                		= {nValue=1},  	  									--ʹ���Զ���ģʽ 
	["CANCEL_AUTO_TRACE_QUEST"]       		= {nValue=1}, 	  									--��ʹ���Զ�׷������
	["SHARE_QUEST"] 				  		= {nValue=1}, 	  									--ʹ�ù�������
	["FIRST_USE_CHARACTER_PROPERTY_FILTER"] = {nAchievementID=1073},							--��һ�������������ɸѡ  ���ȼ�
	                                                                                        	
	["SET_CHARACTER_BASIS"] 		  		= {nValue=1}, 	  									--�������ѡ������  ������
	["SET_CHARACTER_PHYSICS_DAMAGE"]  		= {nValue=1}, 	  									--�������ѡ������  ������
	["SET_CHARACTER_MAGIC_DAMAGE"] 	  		= {nValue=1}, 	  									--�������ѡ������  ������
	["SET_CHARACTER_SHIELD"] 		  		= {nValue=1}, 	  									--�������ѡ������  ������
	["SET_CHARACTER_SURVIVE"] 		  		= {nValue=1}, 	  									--�������ѡ������  ������
	["SET_CHARACTER_OVERCOME"] 		  		= {nValue=1}, 	  									--�������ѡ������  ������
	                                                                                        	
	["FIRST_READ_FILTER"] 			  	    = {nAchievementID=1074}, 							--��һ��ʹ���Ķ�ɸѡ���� ���ȼ�
	["FIRST_READ_SELECT_MORAL_OR_BUDDHISM"] = {nAchievementID=1075}, 							--��һ��ѡ���ѧ ��ѧ    ���ȼ�
	["FIRST_READ_SEARCH"]  				    = {nAchievementID=1076},							--��һ��ʹ���Ķ�����
	["FIRST_OPEN_DUNGEON_PANEL"] 			= {nAchievementID=1077}, 							--��һ�δ������ؾ����� ���ȼ�
	["FIRST_OPEN_DUNGEON_OTHER_TAG"]        = {nAchievementID=1078}, 							--��һ�δ������ؾ�������ҳ ���ȼ�
	["FIRST_OPEN_CHARACTER_PROPERTY"] 		= {nAchievementID=1079}, 							--��һ�ε㿪�������Խ��� ���ȼ�
	["FIRST_OPEN_REPUTATION_PANEL"] 		= {nAchievementID=1080}, 							--��һ�ε㿪������� ���ȼ�
	["FIRST_OPEN_HORSE_PANEL"]              = {nAchievementID=1081}, 							--��һ�ε㿪������� ���ȼ�
	["FIRST_OPEN_CAMP_PANEL"]               = {nAchievementID=1082},							--��һ�ε㿪��Ӫ���� ���ȼ�
	["CLICK_CAMP"]            				= {nValue=1}, 	  									--��Ӫ���ж����˵�����Ӫ����������
	["CLOSE_SOUND"]                  		= {nValue=1},	  	  								--��������																																																														
	["CLOSE_BACKGROUND_MUSIC"]       		= {nValue=1}, 	  									--�ص���������																																																														
	["CLOSE_CHARACTER_SFX"]          		= {nValue=1}, 	  									--�ص�������Ч																																																														
	["CLOSE_3D_SFX"]                 		= {nValue=1}, 	  									--�ص�3D��Ч                     																																																														
	["CLOSE_UI_SFX"]                 		= {nValue=1}, 	  									--�ص�������Ч																																																														
	["CLOSE_ERROR_TIP_SFX"]          		= {nValue=1}, 	  									--�ص�������ʾ��Ч																																																														
	["ADJUST_MAIN_VOLUME"]           		= {fnAction=OnUseDefaultOrNot, nValue=1},			--���������� ����Ĭ�� С��Ĭ��																																																														
	["ADJUST_BACKGROUND_MUSIC"]      		= {fnAction=OnUseDefaultOrNot, nValue=1},			--���ڱ�������																																																														
	["ADJUST_SCENE_SFX"]             		= {fnAction=OnUseDefaultOrNot, nValue=1},			--���ڳ�����Ч																																																														
	["ADJUST_CHARACTER_SFX"]         		= {fnAction=OnUseDefaultOrNot, nValue=1},			--����������Ч																																																														
	["ADJUST_UI_SFX"]                		= {fnAction=OnUseDefaultOrNot, nValue=1},			--���ڽ�����Ч																																																														
	["ADJUST_ERROR_TIP_SFX"]         		= {fnAction=OnUseDefaultOrNot, nValue=1},			--���ڴ�����ʾ��Ч																																																														
	                                 																																																																	
	["ADJUST_MIDDLE_MAP_DIAPHANEITY"]		= {fnAction=OnAdjustMapDiaphaneity, nValue=1},		--���ڵ�ͼ͸����  ͸���ȵȼ���7��																																																														
	["ADJUST_WORLD_MAP_DIAPHANEITY"] 		= {fnAction=OnAdjustMapDiaphaneity, nValue=1},		--���ڵ�ͼ͸����  ͸���ȵȼ���7��																																																														
	                                 																																																																	
	["FIRST_USE_MINIMAP_RADAR"]      		= {nAchievementID=1083}, 	  						--��һ��ʹ��С��ͼ�״�																																																														
	["FIRST_USE_MINIMAP_GUIDE"]      		= {nAchievementID=1084}, 	  						--��һ��ʹ����С��ͼ˾	
	
	["CAREER_PANEL_OPEN"]                   = {fnAction=OnCareerClick, nValue=1},               --��������ʾ����
	["CAREER_PANEL_TAB_CLICK"]              = {fnAction=OnCareerClick, nValue=1},				--���̽��������ǩҳ�������
	
	["CYCLOPAEDIA_PANEL_OPEN"]              = {nValue=1},                                       --����ָ�ϴ򿪴���
	["CYCLOPAEDIA_CAREER_OPEN"]             = {nValue=1},                                       --����ָ�ϵ����̷�ҳ�򿪴���
	["CYCLOPAEDIA_CLOSE_TIME"]              = {fnAction=OnCyclopaediaCloseTime, nValue=1},	    --����ָ�ϵĹر�ʱ��ͳ��
	["CYCLOPAEDIA_HOME_LEFT_TRAIN"]         = {nValue=1},  										--����ָ�ϵ������Ϊ�鿴���ܵ��ʹ��������																																			
	["CYCLOPAEDIA_HOME_LEFT_PARTY"]         = {nValue=1},  										--����ָ�ϵ������Ѻͳ��˲鿴���ܵ��ʹ��������
	["CYCLOPAEDIA_HOME_LEFT_QUEST"]         = {nValue=1},  										--����ָ�ϵ��������鿴����ʹ��������
	["CYCLOPAEDIA_HOME_LEFT_JX3DAILY"]      = {nValue=1},  										--����ָ�ϵ�����ճ��鿴����ʹ��������
	["CYCLOPAEDIA_HOME_LEFT_STAMINA_THEW"]  = {nValue=1},  										--����ָ�ϵ���ྫ�������鿴����ʹ��������
	["PLAYER_AUTO_EXIT"]                    = {fnAction=OnPlayerAutoExit, nValue=1},            --40�����Զ����߸��ȼ���ͼ������
}                                     																																																														

local function OnUsePlugin_UpdateData()
	local nAddonCount = DataAnalysis["USE_PLUGIN"].nAddonCount
	if nAddonCount and nAddonCount > 0  then
		RemoteCallToServer("OnUpdateStatData", "USE_PLUGIN", 1)
	end
end
RegisterEvent("LOADING_END", OnUsePlugin_UpdateData)

function FireDataAnalysisEvent(szEvent, tArg)
	tArg = tArg or {}
	local player = GetClientPlayer()
	
	if DataAnalysis[szEvent] and DataAnalysis[szEvent].fnAction then
		DataAnalysis[szEvent].fnAction({szKey=szEvent, tData=DataAnalysis[szEvent]}, tArg[1], tArg[2], tArg[3], tArg[4])
	else
		local tInfo = DataAnalysis[szEvent] 
		if not tInfo then
			return
		end
		
		if tInfo.nAchievementID and player.IsAchievementAcquired(tInfo.nAchievementID) then
			return
		end
		
		local szKey = szEvent
		if tArg[1] then
			szKey = szKey.."|"..tArg[1]
		end
		
		if tInfo.nAchievementID then
			RemoteCallToServer("OnClientAddAchievement", szKey)
		else
			RemoteCallToServer("OnUpdateStatData", szKey, tInfo.nValue)
		end
	end
end