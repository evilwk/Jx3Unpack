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
	
  	if szKey == "DRAG_NEWBIE_SKILL" and  (dwSkillID == 49 or dwSkillID == 58) then -- 新手技能 回风扫叶，猛虎下山
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

-- {fnAction=需要特殊处理的函数， nAchievementID=统计第一次的，走成就流程的， nValue = 触发一次统计累加的数值},	
local DataAnalysis  = 
{
	["DRAG_NEWBIE_SKILL"]             		= {fnAction=OnDragSkill, nValue = 1},				--拖动技能”猛虎下山“,“回风扫落叶”到快捷栏 58,49
	["FONT_ZOOM"]                     		= {nValue = 1}, 	  								--字体缩放到-2 -1, 1, 2
	["UI_ZOOM"]                    	  		= {fnAction=OnUseDefaultOrNot, nValue = 1},			--第一次ui缩放异于默认 -1, 1
	                                  		                                                	
	["SELECT_MOUSE_MOVE"]             		= {nValue = 1},										--勾选鼠标走路
	["DROP_NEW_HELP"]                 		= {nValue = 1},										--勾掉新手帮助
	["DROP_NEW_HELP_HANDLE"] 	      		= {nValue = 1},										--勾掉新手帮助控件																				
	["LOOK_SUBMIT_QUEST_POINT"]       		= {nValue = 1},										--使用任务终止点																				
	["LOOK_ACCEPT_QUEST_POINT"]       		= {nValue = 1},										--使用任务起始点																				
	["MEND_SHOTCUT"] 			      		= {fnAction=OnMendShortCut, nValue = 1},    		--修改快捷键\
	                                  		                                                	
	["CHAT_CHANNEL_BACKGROUND_COLOR"] 		= {fnAction=OnMendMsgColor, nValue=1}, 	  			--聊天频道背景颜色设置
	["CHAT_CHANNEL_FONT"]			  		= {fnAction=OnChangeFontInfo, nValue=1},    		--聊天频道字体设
	["CHAT_MSG_COLOR"] 	     		  		= {fnAction=OnMendMsgColor, nValue=1}, 	  			--聊天频道颜色设置 频道数量              
	                                  		                                                	         
	["MYSTIQUE_ACTIVE"]               		= {nValue=1}, 	  									--秘笈界面激活秘笈人数
	["NOT_BIG_BAG"]                   		= {nValue=1},       								--没有使用整合背包
	["FIRST_SET_SHOTCUT"]             		= {fnAction=OnMendShortCut, nAchievementID=1071},	--设置快捷键 各等级
	["USE_PLUGIN"]                    		= {fnAction=OnUsePlugin, nValue=1},     			--使用插件总人数 
	["KEY_NOTES_TIME"]                		= {fnAction=OnKeyNotesCloseTime, nValue=1},			--上线提示关闭时间统计 各时段
	                                  		                                                	
	["KEY_NOTES_QUEST"]               		= {nValue=1},   	  								--使用上线提示总人数 任务
	["KEY_NOTES_SKILL"]               		= {nValue=1},   	  								--使用上线提示总人数 技能
	["KEY_NOTES_XIUWEI"]              		= {nValue=1},   	  								--使用上线提示总人数 修为
	["KEY_NOTES_TILI"]                		= {nValue=1},   	  								--使用上线提示总人数 体力
	["KEY_NOTES_JINLI"]               		= {nValue=1},   	  								--使用上线提示总人数 精力
	["KEY_NOTES_MAIL"]                		= {nValue=1},   	  								--使用上线提示总人数 邮件
	["KEY_NOTES_FRIEND"]              		= {nValue=1},   	  								--使用上线提示总人数 好友
	                                                                                        	
	["FIRST_DRAG_SKILL"]              		= {fnAction=OnDragSkill, nAchievementID=1072},		--第一次拖动技能 
	["UI_CUSTOM_MODE"]                		= {nValue=1},  	  									--使用自定义模式 
	["CANCEL_AUTO_TRACE_QUEST"]       		= {nValue=1}, 	  									--不使用自动追踪任务
	["SHARE_QUEST"] 				  		= {nValue=1}, 	  									--使用共享任务
	["FIRST_USE_CHARACTER_PROPERTY_FILTER"] = {nAchievementID=1073},							--第一次人物界面属性筛选  各等级
	                                                                                        	
	["SET_CHARACTER_BASIS"] 		  		= {nValue=1}, 	  									--人物界面选定属性  各属性
	["SET_CHARACTER_PHYSICS_DAMAGE"]  		= {nValue=1}, 	  									--人物界面选定属性  各属性
	["SET_CHARACTER_MAGIC_DAMAGE"] 	  		= {nValue=1}, 	  									--人物界面选定属性  各属性
	["SET_CHARACTER_SHIELD"] 		  		= {nValue=1}, 	  									--人物界面选定属性  各属性
	["SET_CHARACTER_SURVIVE"] 		  		= {nValue=1}, 	  									--人物界面选定属性  各属性
	["SET_CHARACTER_OVERCOME"] 		  		= {nValue=1}, 	  									--人物界面选定属性  各属性
	                                                                                        	
	["FIRST_READ_FILTER"] 			  	    = {nAchievementID=1074}, 							--第一次使用阅读筛选属性 各等级
	["FIRST_READ_SELECT_MORAL_OR_BUDDHISM"] = {nAchievementID=1075}, 							--第一次选择道学 佛学    各等级
	["FIRST_READ_SEARCH"]  				    = {nAchievementID=1076},							--第一次使用阅读搜索
	["FIRST_OPEN_DUNGEON_PANEL"] 			= {nAchievementID=1077}, 							--第一次打开武林秘境界面 各等级
	["FIRST_OPEN_DUNGEON_OTHER_TAG"]        = {nAchievementID=1078}, 							--第一次打开武林秘境其他分页 各等级
	["FIRST_OPEN_CHARACTER_PROPERTY"] 		= {nAchievementID=1079}, 							--第一次点开任务属性界面 各等级
	["FIRST_OPEN_REPUTATION_PANEL"] 		= {nAchievementID=1080}, 							--第一次点开坐骑界面 各等级
	["FIRST_OPEN_HORSE_PANEL"]              = {nAchievementID=1081}, 							--第一次点开坐骑界面 各等级
	["FIRST_OPEN_CAMP_PANEL"]               = {nAchievementID=1082},							--第一次点开阵营界面 各等级
	["CLICK_CAMP"]            				= {nValue=1}, 	  									--阵营中有多少人点了阵营界面总人数
	["CLOSE_SOUND"]                  		= {nValue=1},	  	  								--开启静音																																																														
	["CLOSE_BACKGROUND_MUSIC"]       		= {nValue=1}, 	  									--关掉背景音乐																																																														
	["CLOSE_CHARACTER_SFX"]          		= {nValue=1}, 	  									--关掉主角音效																																																														
	["CLOSE_3D_SFX"]                 		= {nValue=1}, 	  									--关掉3D音效                     																																																														
	["CLOSE_UI_SFX"]                 		= {nValue=1}, 	  									--关掉界面音效																																																														
	["CLOSE_ERROR_TIP_SFX"]          		= {nValue=1}, 	  									--关掉错误提示音效																																																														
	["ADJUST_MAIN_VOLUME"]           		= {fnAction=OnUseDefaultOrNot, nValue=1},			--调节主音量 大于默认 小于默认																																																														
	["ADJUST_BACKGROUND_MUSIC"]      		= {fnAction=OnUseDefaultOrNot, nValue=1},			--调节背景音乐																																																														
	["ADJUST_SCENE_SFX"]             		= {fnAction=OnUseDefaultOrNot, nValue=1},			--调节场景音效																																																														
	["ADJUST_CHARACTER_SFX"]         		= {fnAction=OnUseDefaultOrNot, nValue=1},			--调节主角音效																																																														
	["ADJUST_UI_SFX"]                		= {fnAction=OnUseDefaultOrNot, nValue=1},			--调节界面音效																																																														
	["ADJUST_ERROR_TIP_SFX"]         		= {fnAction=OnUseDefaultOrNot, nValue=1},			--调节错误提示音效																																																														
	                                 																																																																	
	["ADJUST_MIDDLE_MAP_DIAPHANEITY"]		= {fnAction=OnAdjustMapDiaphaneity, nValue=1},		--调节地图透明度  透明度等级（7）																																																														
	["ADJUST_WORLD_MAP_DIAPHANEITY"] 		= {fnAction=OnAdjustMapDiaphaneity, nValue=1},		--调节地图透明度  透明度等级（7）																																																														
	                                 																																																																	
	["FIRST_USE_MINIMAP_RADAR"]      		= {nAchievementID=1083}, 	  						--第一次使用小地图雷达																																																														
	["FIRST_USE_MINIMAP_GUIDE"]      		= {nAchievementID=1084}, 	  						--第一次使用了小地图司	
	
	["CAREER_PANEL_OPEN"]                   = {fnAction=OnCareerClick, nValue=1},               --打开历程提示界面
	["CAREER_PANEL_TAB_CLICK"]              = {fnAction=OnCareerClick, nValue=1},				--历程界面的左侧标签页点击次数
	
	["CYCLOPAEDIA_PANEL_OPEN"]              = {nValue=1},                                       --江湖指南打开次数
	["CYCLOPAEDIA_CAREER_OPEN"]             = {nValue=1},                                       --江湖指南的历程分页打开次数
	["CYCLOPAEDIA_CLOSE_TIME"]              = {fnAction=OnCyclopaediaCloseTime, nValue=1},	    --江湖指南的关闭时间统计
	["CYCLOPAEDIA_HOME_LEFT_TRAIN"]         = {nValue=1},  										--江湖指南的左侧修为查看功能点击使用总人数																																			
	["CYCLOPAEDIA_HOME_LEFT_PARTY"]         = {nValue=1},  										--江湖指南的左侧好友和仇人查看功能点击使用总人数
	["CYCLOPAEDIA_HOME_LEFT_QUEST"]         = {nValue=1},  										--江湖指南的左侧任务查看功能使用总人数
	["CYCLOPAEDIA_HOME_LEFT_JX3DAILY"]      = {nValue=1},  										--江湖指南的左侧日常查看功能使用总人数
	["CYCLOPAEDIA_HOME_LEFT_STAMINA_THEW"]  = {nValue=1},  										--江湖指南的左侧精力体力查看功能使用总人数
	["PLAYER_AUTO_EXIT"]                    = {fnAction=OnPlayerAutoExit, nValue=1},            --40分钟自动断线各等级地图的人数
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