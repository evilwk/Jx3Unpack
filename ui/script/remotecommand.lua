local RemoteFunction = {}

function OnRemoteCall(szFunction, ...)
	if RemoteFunction[szFunction] then 
		RemoteFunction[szFunction](...)
	end
end

function RemoteFunction.OpenCreateTongPanel(dwID)
	local fnInput = function(szTongName)
		-- 请求创建帮会
		-- \client\scripts\script_server.lua
		RemoteCallToServer("OnCreateTongRespond", dwID, szTongName)
	end

	local CloseWindow = function()
		local npc = GetNpc(dwID)
		if not npc or not npc.CanDialog(GetClientPlayer()) then
			return true
		end
	end

	GetUserInput(g_tStrings.INPUT_GUILD_NAME, fnInput, nil, CloseWindow, nil, nil, 31)
end

function RemoteFunction.OnResetMapRespond(data)
	UpdateDungeonInfo("OnResetMapRespond", data)
end

function RemoteFunction.OnApplyPlayerSavedCopysRespond(data)
	UpdateDungeonInfo("OnApplyPlayerSavedCopysRespond", data)
	arg0 = data
	FireEvent("ON_APPLY_PLAYER_SAVED_COPY_RESPOND")
end

function RemoteFunction.OnApplyEnterMapInfoRespond(tData, tData1)
	-- arg2 为下次重置时间
	UpdateDungeonInfo("OnApplyEnterMapInfoRespond", tData, tData1)
end

-- 增加新手帮助的远程调用
function RemoteFunction.FireHelpEvent(data1, data2)
	FireHelpEvent(data1, data2)
end

-- 帮会操作做事件通知
function RemoteFunction.OnSendTongEvent(data1, data2)
	arg0, arg1 = data1, data2
	FireEvent("TONG_EVENT_NOTIFY")
end

-- 奖励物品面板
function RemoteFunction.OpenActivityPanel(szTitle, szMessage, tItemList, fnSureAction)
	OpenItemBox(szTitle, szMessage, tItemList, fnSureAction)
end

function RemoteFunction.OnItemBoxResult()
	if IsItemBoxOpened() then
		CloseItemBox()
	end
end

-- 请求成就排名响应
function RemoteFunction.OnSyncRankingInfo(data1, data2, data3)
	arg0, arg1, arg2 = data1, data2, data3
	FireEvent("ON_SYNC_RANKING_INFO")
end

-- 礼品卡输入密码
-- RemoteCallToClient(player.dwID, "OpenActivityPasswordPanel", "请输入活动发放的礼品序列号：")
function RemoteFunction.OpenActivityPasswordPanel(szTitle)
	local SendPassword = function(szPassword)
		if szPassword and szPassword:sub(1, 5):lower() == "ksjx3" then
			RemoteCallToServer("OnActivityPasswordReceived", szPassword)
		end
	end
	GetUserInput(szTitle, SendPassword, nil, function() end, nil, nil, 31)
end

function RemoteFunction.OnGetTongMemberSalaryRespond(nGold)
	arg0 = nGold
	FireEvent("ON_GET_GUILD_SALARY")
end

-- 打开 内嵌IE
function RemoteFunction.OpenIE(szAddr, bDisableSound)
	if szAddr and type(szAddr) == "string" and szAddr ~= "" then
		OpenInternetExplorer(szAddr, bDisableSound)		
	end
end

function RemoteFunction.GMTransferToPlayer()
	-- 玩家输入一个角色名szDest, 传送到szDest那里去
	-- 然后远程调用: RemoteCallToServer("OnGMTransferToPlayer", szDest);
	

	OpenGMCheck()
end

function RemoteFunction.GMSendSystemMessage()
	-- 玩家输入一个角色名szDest, 一段字符串szMsg, 将szMsg作为系统消息发送给szDest
	-- 然后远程调用: RemoteCallToServer("GMClientSendMsgToPlayer", szDest, szMsg);
end

function RemoteFunction.OnGM2PlayerMsgRequest(data1, data2)
	GMMessage_ReceiveGMMsg(data1, data2)
	-- 打开GM会话面板
	-- ...
	-- 玩家回复: RemoteCallToServer("OnPlayer2GMMsgRequest", dwGM, szMsg);
end

function RemoteFunction.OnPlayer2GMMsgRequest(data1, data2)
	-- 玩家回复GM消息,打开面板
	GMMessage_ReceivePlayerMsg(data1, data2)
end

function RemoteFunction.OnGetGlobalRanking(szType, tMsg, bSuccess, nStartIndex, nNextStartIndex, eQueryer)
	-- 参数nNextStartIndex等于0表示szType全部同步完了
	if eQueryer == 1 then
		FireUIEvent("ON_FENGYUNLU_GET_RANKING", szType, tMsg, bSuccess, nStartIndex, nNextStartIndex)
	elseif eQueryer == 2 then
		FireUIEvent("ON_MENTORSTONE_GET_RANKING", szType, tMsg, bSuccess, nStartIndex, nNextStartIndex)
	end
end

-- RemoteCallToClient(player.dwID, "OnSendSystemAnnounce", szAnnounce, szColor)
function RemoteFunction.OnSendSystemAnnounce(szAnnounce, szColor)
	if not szColor or type(szColor) ~= "string" then
		return
	end
	szColor = szColor:lower()
	if szColor == "red" then
		OutputMessage("MSG_ANNOUNCE_RED", szAnnounce)
	elseif szColor == "yellow" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", szAnnounce)
	end
end

-- 师徒系统相关 -------------------------------------------<
function RemoteFunction.OnQueryMentor(szApprenticeName)
	local Accept = function()
		RemoteCallToServer("OnAnswerMentor", szApprenticeName, "YES")
		local msg = 
		{
			szMessage = FormatString(g_tStrings.MENTOR_ADD_FRIEND, szApprenticeName), 
			szName = "MenterAddFriend", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().AddFellowship(szApprenticeName) AddContactPeople(szApprenticeName) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL },
		}
		MessageBox(msg)
	end
	local msg = 
	{
		szMessage = FormatString(g_tStrings.MENTOR_AGREE_1, szApprenticeName), 
		szName = "A_M_"..szApprenticeName, 
		{szOption = g_tStrings.STR_ACCEPT, fnAction = Accept},
		{szOption = g_tStrings.STR_REFUSE, fnAction = function() RemoteCallToServer("OnAnswerMentor", szApprenticeName, "NO") end},
	}
	MessageBox(msg)
end

function RemoteFunction.OnQueryDirectMentor(szApprenticeName)
	local Accept = function()
		RemoteCallToServer("OnAnswerDirectMentor", szApprenticeName, "YES")
		local msg = 
		{
			szMessage = FormatString(g_tStrings.DIRECT_MENTOR_ADD_FRIEND, szApprenticeName), 
			szName = "MenterAddFriend", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().AddFellowship(szApprenticeName) AddContactPeople(szApprenticeName) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL },
		}
		MessageBox(msg)
	end
	local msg = 
	{
		szMessage = FormatString(g_tStrings.DIRECT_MENTOR_AGREE_1, szApprenticeName), 
		szName = "A_M_"..szApprenticeName, 
		{szOption = g_tStrings.STR_ACCEPT, fnAction = Accept},
		{szOption = g_tStrings.STR_REFUSE, fnAction = function() RemoteCallToServer("OnAnswerDirectMentor", szApprenticeName, "NO") end},
	}
	MessageBox(msg)
end

function RemoteFunction.OnMentorNotify(szEvent, param)
	local szMsg = g_tStrings.MENTOR_MSG[szEvent] or ""
	local szChannel = "MSG_SYS"
	local szFont = GetMsgFontString(szChannel)
	local bRich = false
	if szEvent == "TAKE_APPRENTICE_SUCCESS" then -- 收徒成功
		FireEvent("NEED_REQUAIRE_APPRENTICE_LIST")
	elseif szEvent == "TAKE_MENTOR_SUCCESS" then -- 拜师成功
		FireEvent("NEED_REQUAIRE_MENTOR_LIST")
	elseif szEvent == "BREAK_MENTOR_RESULT" then -- 解除师父结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_BREAK_MENTOR_RESULT")
		FireEvent("NEED_REQUAIRE_MENTOR_LIST")
	elseif szEvent == "BREAK_APPRENTICE_RESULT" then -- 解除徒弟结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_BREAK_APPRENTICE_RESULT")
		FireEvent("NEED_REQUAIRE_APPRENTICE_LIST")
	elseif szEvent == "BREAK_MENTOR_NOTIFY" then -- 解除师傅通知（通知师傅）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
        FireEvent("NEED_REQUAIRE_APPRENTICE_LIST")
	elseif szEvent == "BREAK_APPRENTICE_NOTIFY" then -- 解除徒弟通知 （通知徒弟）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
        FireEvent("NEED_REQUAIRE_MENTOR_LIST")
	elseif szEvent == "CANCEL_BREAK_MENTOR_RESULT" then -- 取消解除师父结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_CANCEL_BREAK_MENTOR_RESULT")
	elseif szEvent == "CANCEL_BREAK_APPRENTICE_RESULT" then -- 取消解除徒弟结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_CANCEL_BREAK_APPRENTICE_RESULT")
	elseif szEvent == "CANCEL_BREAK_MENTOR_NOTIFY" then -- 取消解除师傅通知（通知师傅）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "CANCEL_BREAK_APPRENTICE_NOTIFY" then -- 取消解除徒弟通知（通知徒弟）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_MAP_LIMIT" then -- 师父处在副本中，不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_MOVE_STATE_LIMIT" then -- 师父当前的状态不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_INFIGHT" then -- 师傅处在战斗状态，不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_IN_TASK_DAOBAOZEI" then -- 师傅在追捕盗宝贼，不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_IN_TASK_CHUANGONG" then -- 师傅在被传功，不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_GRADUATED_NOTIFY" then
		arg0 = GetClientPlayer().dwID
		FireEvent("UPDATE_MENTOR_DATA")
	elseif szEvent == "APPRENTICE_GRADUATED_NOTIFY" then -- 徒弟出师通知
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
		arg0 = GetClientPlayer().dwID
		FireEvent("UPDATE_APPRENTICE_DATA")
	elseif szEvent == "APPRENTICE_GRADUATED_NOTIFY_ADD_NUM" then -- 徒弟毕业级可带徒弟数+1通知
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
		arg0 = GetClientPlayer().dwID
		FireEvent("UPDATE_APPRENTICE_DATA")
	elseif szEvent == "ON_APPRENTICE_LEVELUP" then -- 徒弟升级啦 param = {szName, nLevel}
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.szName.."]", szFont), param.nLevel), true
		arg0 = GetClientPlayer().dwID
		FireEvent("UPDATE_APPRENTICE_DATA")
	elseif szEvent == "ON_APPRENTICE_LEVELUP_TO_GRADUATE" then -- 徒弟升到了80级，可以去做出师任务了
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ACQUIRE_MENTOR_VALUE_SUCCEED" then -- 师徒值转帮贡成功 param = nMentorValue
		szMsg = FormatString(szMsg, param, param * 5)
		FireEvent("NEED_REQUAIRE_MENTOR_LIST")
	elseif szEvent == "ON_MENTOR_OFFLINE" then -- 师徒下线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_APPRENTICE_OFFLINE" then -- 徒弟下线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_APPRENTICE_ONLINE" then -- 徒弟上线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_MENTOR_ONLINE" then -- 师父上线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_YOU_BREAK_APPRENTICE" then -- 师父上线时 自己正和param徒弟解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_APPRENTICE_BREAK_YOU" then -- 师父上线时 param徒弟正和自己解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_MENTOR_BREAK_YOU" then -- 徒弟上线时 param徒弟正和自己解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_YOU_BREAK_MENTOR" then -- 徒弟上线时 自己正和param徒弟解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "EVOKE_TONG_NOT_AGREE" then -- 召唤帮众 对方拒绝了
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "EVOKE_QINGMINGJIE_ZUIYUAN_EVOKE_MSG_MSG" then -- 打醉猴召唤队友 对方拒绝了
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	end
	
	if szMsg and szMsg ~= "" then
		OutputMessage(szChannel, szMsg, bRich)
	end
	
end

function RemoteFunction.OnDirectMentorNotify(szEvent, param)
	local szMsg = g_tStrings.DIRECT_MENTOR_MSG[szEvent] or ""
	local szChannel = "MSG_SYS"
	local szFont = GetMsgFontString(szChannel)
	local bRich = false
	if szEvent == "TAKE_APPRENTICE_SUCCESS" then -- 收徒成功
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	elseif szEvent == "TAKE_MENTOR_SUCCESS" then -- 拜师成功
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "BREAK_MENTOR_RESULT" then -- 解除师父结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_BREAK_DIRECT_MENTOR_RESULT")
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "BREAK_APPRENTICE_RESULT" then -- 解除徒弟结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_BREAK_DIRECT_APPRENTICE_RESULT")
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "BREAK_MENTOR_NOTIFY" then -- 解除师傅通知（通知师傅）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	elseif szEvent == "BREAK_APPRENTICE_NOTIFY" then -- 解除徒弟通知 （通知徒弟）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "CANCEL_BREAK_MENTOR_RESULT" then -- 取消解除师父结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_CANCEL_BREAK_DIRECT_MENTOR_RESULT")
	elseif szEvent == "CANCEL_BREAK_APPRENTICE_RESULT" then -- 取消解除徒弟结果 param = {dwID, nState, nEndTime}
		arg0 = param
		FireEvent("ON_CANCEL_BREAK_DIRECT_APPRENTICE_RESULT")
	elseif szEvent == "CANCEL_BREAK_MENTOR_NOTIFY" then -- 取消解除师傅通知（通知师傅）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "CANCEL_BREAK_APPRENTICE_NOTIFY" then -- 取消解除徒弟通知（通知徒弟）
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_MAP_LIMIT" then -- 师父处在副本中，不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_MOVE_STATE_LIMIT" then -- 师父当前的状态不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "MENTOR_INFIGHT" then -- 师傅处在战斗状态，不能被召请
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "APPRENTICE_GRADUATED_NOTIFY" then -- 徒弟毕业通知
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "APPRENTICE_GRADUATED_NOTIFY_ADD_NUM" then -- 徒弟毕业可带徒弟数+1通知
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true		
	elseif szEvent == "ON_APPRENTICE_LEVELUP" then -- 徒弟升级啦 param = {szName, nLevel}
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.szName.."]", szFont), param.nLevel), true
	elseif szEvent == "ON_APPRENTICE_LEVELUP_TO_GRADUATE" then -- 徒弟升到了70级，可以去做出师任务了
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ACQUIRE_MENTOR_VALUE_SUCCEED" then -- 师徒值转帮贡成功 param = nMentorValue
		szMsg = FormatString(szMsg, param, param * 5)
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "ON_MENTOR_OFFLINE" then -- 师徒下线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_APPRENTICE_OFFLINE" then -- 徒弟下线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_APPRENTICE_ONLINE" then -- 徒弟上线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_MENTOR_ONLINE" then -- 师父上线了 param = szName
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_YOU_BREAK_APPRENTICE" then -- 师父上线时 自己正和param徒弟解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_APPRENTICE_BREAK_YOU" then -- 师父上线时 param徒弟正和自己解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_MENTOR_BREAK_YOU" then -- 徒弟上线时 param徒弟正和自己解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "ON_YOU_BREAK_MENTOR" then -- 徒弟上线时 自己正和param徒弟解除关系
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "EVOKE_TONG_NOT_AGREE" then -- 召唤帮众 对方拒绝了
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "EVOKE_QINGMINGJIE_ZUIYUAN_EVOKE_MSG_MSG" then -- 打醉猴召唤队友 对方拒绝了
		szMsg, bRich = FormatLinkString(szMsg, szFont, MakeNameLink("["..param.."]", szFont)), true
	elseif szEvent == "GRADUATE_BY_DIRECT_APPRENTICE_RESULT" then -- 徒弟提出出师结果 param = {dwID, nState, nEndTime}
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "GRADUATE_BY_DIRECT_APPRENTICE_NOTIFY" then -- 徒弟提出出师通知（通知师傅）param = {szName}
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	elseif szEvent == "GRADUATE_BY_DIRECT_MENTOR_RESULT" then -- 师傅提出出师结果 param = {dwID, nState, nEndTime}
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	elseif szEvent == "GRADUATE_BY_DIRECT_MENTOR_NOTIFY" then -- 师傅提出出师通知 （通知徒弟）param = {szName}
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "CANCEL_GRADUATE_BY_DIRECT_APPRENTICE_RESULT" then --徒弟取消出师结果 param = {dwID, nState, nEndTime}
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "CANCEL_GRADUATE_BY_DIRECT_APPRENTICE_NOTIFY" then --徒弟取消出师通知 (通知师傅) param = {dwID, nState, nEndTime}
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	elseif szEvent == "CANCEL_GRADUATE_BY_DIRECT_MENTOR_RESULT" then --师傅取消出师结果 param = {dwID, nState, nEndTime}
		FireEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	elseif szEvent == "CANCEL_GRADUATE_BY_DIRECT_MENTOR_NOTIFY" then --师傅取消出师通知 (通知徒弟) param = {dwID, nState, nEndTime}
		FireEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	elseif szEvent == "MENTOR_NO_RIGHT" then -- 师傅没有资格
		
	end
	
	if szMsg and szMsg ~= "" then
		OutputMessage(szChannel, szMsg, bRich)
	end
end


function RemoteFunction.OnQueryApprentice(szMentorName)
	local Accept = function()
		RemoteCallToServer("OnAnswerApprentice", szMentorName, "YES")
		local msg = 
		{
			szMessage = FormatString(g_tStrings.APPRENTICE_ADD_FRIEND, szMentorName), 
			szName = "MenterAddFriend", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().AddFellowship(szMentorName) AddContactPeople(szMentorName) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL },
		}
		MessageBox(msg)		
	end

	local msg = 
	{
		szMessage = FormatString(g_tStrings.MENTOR_AGREE_2, szMentorName), 
		szName = "A_A_"..szMentorName, 
		{szOption = g_tStrings.STR_ACCEPT, fnAction = Accept},
		{szOption = g_tStrings.STR_REFUSE, fnAction = function() RemoteCallToServer("OnAnswerApprentice", szMentorName, "NO") end},
	}
	MessageBox(msg)
end

function RemoteFunction.OnQueryDirectApprentice(szMentorName)
	local Accept = function()
		RemoteCallToServer("OnAnswerDirectApprentice", szMentorName, "YES")
		local msg = 
		{
			szMessage = FormatString(g_tStrings.DIRECT_APPRENTICE_ADD_FRIEND, szMentorName), 
			szName = "MenterAddFriend", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().AddFellowship(szMentorName) AddContactPeople(szMentorName) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL },
		}
		MessageBox(msg)		
	end

	local msg = 
	{
		szMessage = FormatString(g_tStrings.DIRECT_MENTOR_AGREE_2, szMentorName), 
		szName = "A_A_"..szMentorName, 
		{szOption = g_tStrings.STR_ACCEPT, fnAction = Accept},
		{szOption = g_tStrings.STR_REFUSE, fnAction = function() RemoteCallToServer("OnAnswerDirectApprentice", szMentorName, "NO") end},
	}
	MessageBox(msg)
end

function RemoteFunction.OnGetMentorListRespond(dwDstPlayerID, MentorList)
	arg0, arg1 = dwDstPlayerID, MentorList
	FireEvent("ON_GET_MENTOR_LIST")
end

function RemoteFunction.OnGetDirectMentorListRespond(dwDstPlayerID, MentorList)
	arg0, arg1 = dwDstPlayerID, MentorList
	FireEvent("ON_GET_DIRECT_MENTOR_LIST")
end

function RemoteFunction.OnGetApprenticeListRespond(dwDstPlayerID, ApprenticeList)
	arg0, arg1 = dwDstPlayerID, ApprenticeList
	FireEvent("ON_GET_APPRENTICE_LIST")
end

function RemoteFunction.OnGetDirApprenticeListRespond(dwDstPlayerID, ApprenticeList)
	arg0, arg1 = dwDstPlayerID, ApprenticeList
	FireEvent("ON_GET_DIRECT_APPRENTICE_LIST")
end

function RemoteFunction.OnSyncMentorData(szType, param)
	if szType == "ALL" then
		-- player.nMaxApprenticeNum    = param[1];
		-- player.nAcquiredMentorValue = param[2];
		-- player.nLastEvokeMentorTime = param[3];
		-- player.nEvokeMentorCount    = param[4];
		-- player.nUsableMentorValue   = param[5];
		-- player.dwTAEquipsScore      = param[6];
		FireUIEvent("ON_SYNC_MENTOR_DATA", param[1], param[2], param[3], param[4], param[5])
		FireUIEvent("ON_SYNC_TA_EQUIPS_SCORE", param[6])
	elseif szType == "ACQUIRED_MVALUE" then
		-- player.nAcquiredMentorValue = param;
		FireUIEvent("ON_SYNC_ACQUIRED_MVALUE", param)
	elseif szType == "LEFT_EVOKE_NUM" then
		-- player.nEvokeMentorCount = param;
		FireUIEvent("ON_SYNC_LEFT_EVOKE_NUM", param)
	elseif szType == "MAX_APPRENTICE_NUM" then
		-- player.nMaxApprenticeNum = param;
		FireUIEvent("ON_SYNC_MAX_APPRENTICE_NUM", param)
	elseif szType == "USABLE_MVALUE" then 
		-- player.nUsableMentorValue = param;
		FireUIEvent("ON_SYNC_USABLE_MVALUE", param)
	elseif szType == "TA_EQUIPS_SCORE" then
		-- player.dwTAEquipsScore = param;
		FireUIEvent("ON_SYNC_TA_EQUIPS_SCORE", param)
	end
end

function RemoteFunction.OnQueryEvoke(dwSrcPlayerID, szSrcPlayerName, dwMapID, szRelation)
	-- 询问是否接受传送到dwMapID的地图
	local player = GetClientPlayer();
	
	local szMsg = "";
	if szRelation == "A2M" then
		szMsg = g_tStrings.MENTOR_APPRENTICE_EVOKE_MSG;
	elseif szRelation == "M2A" then
		szMsg = g_tStrings.MENTOR_MENTOR_EVOKE_MSG;
	elseif szRelation == "FRIEND" then
		szMsg = g_tStrings.MENTOR_FRIEND_EVOKE_MSG;
	elseif szRelation == "TONG" then
		szMsg = g_tStrings.MENTOR_TONG_EVOKE_MSG;
	elseif szRelation == "TONGALL" then
		szMsg = g_tStrings.MENTOR_TONGALL_EVOKE_MSG;
	elseif szRelation == "ZUIYUAN" then
		szMsg = g_tStrings.MENTOR_QINGMINGJIE_ZUIYUAN_EVOKE_MSG_MSG;
	else
		return;
	end
	
	local msg = 
	{
		szMessage = FormatString(szMsg, szSrcPlayerName), 
		szName = "A_E_M_"..szSrcPlayerName,
		{szOption = g_tStrings.STR_ACCEPT, fnAction = function() RemoteCallToServer("OnAnswerEvoke", dwSrcPlayerID, "YES") end},
		{szOption = g_tStrings.STR_REFUSE, fnAction = function() RemoteCallToServer("OnAnswerEvoke", dwSrcPlayerID, "NO") end},
	}
	MessageBox(msg)
end

function RemoteFunction.OnApprenticeLevelupPriseNotify(nLevel, szMentorName)
	local player = GetClientPlayer();
	if not player then
		return;
	end
	
	local NotifyContent = {{type = "text", text = FormatString(g_tStrings.LEVELUP_PRISE_NOTIFY, nLevel)}};
	
	player.Talk(PLAYER_TALK_CHANNEL.WHISPER, szMentorName, NotifyContent);
end

-- 召唤符 好友列表
function RemoteFunction.OnSyncFriendEvokeList(dwItemID, tEvokeList)
	OpenCallFriendPannel(dwItemID, tEvokeList)
end

-- 召唤符 帮众列表
function RemoteFunction.OnSyncTongMemberEvokeList(dwItemID, tEvokeList)
	OpenCallGuildMemberPannel(dwItemID, tEvokeList)
end

-- 师徒系统相关 ------------------------------------------->

-- 日历相关 -------------------------------------------<
function RemoteFunction.OnSyncStoredGmAnnouncement(tGmAnnouncement)
	for k, v in ipairs(tGmAnnouncement) do
		local argSave0 = arg0
		local argSave1 = arg1
		arg0 = v[2]
		arg1 = v[1]
		FireEvent("CHANNEL_GM_ANNOUNCE")
		arg0 = argSave0
		arg1 = argSave1
	end
end
-- 日历相关 ------------------------------------------->

function RemoteFunction.TimeLimitationBindItemChanged(dwItemID, nLeftTime, players)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local scene = player.GetScene()
	if not scene then
		return
	end
	
	scene.TimeLimitationBindItemDelItem(dwItemID)
	scene.TimeLimitationBindItemAddItem(dwItemID, player.dwID, nLeftTime)
	
	for i,v in pairs(players) do
		scene.TimeLimitationBindItemAddPlayer(v, dwItemID)
	end
end

function RemoteFunction.CloseCampFlagResult(bResult, nLeftSeconds)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	if bResult then
		player.nCloseCampFlagTime = 0;
		if nLeftSeconds > 0 then
			local nCurrentTime = GetCurrentTime();
			player.nCloseCampFlagTime = nLeftSeconds + nCurrentTime;
		end
	end
	
	WaitCloseCampFlag(bResult, nLeftSeconds)
end

function RemoteFunction.OpenBoxRespond(bResult, dwBoxIndex, dwPos)
	OpenItemBoxByItem(bResult, dwBoxIndex, dwPos)
end

function RemoteFunction.DoClientScript(szScript)
	local f = loadstring(szScript)
	if f then 
		f()
	end
end
-- 许愿签相关
-- scripts/Map/节日春节/item/许愿笺.lua
-- RemoteCallToClient(player.dwID, "OnWishPanelRequest")
function RemoteFunction.OnWishPanelRequest(dwIndex)
	if WishPanel then	
		WishPanel.Open(dwIndex)
	end
end
-- 弹出的砸金蛋确认框
-- RemoteCallToClient(player.dwID, "OnMessageBoxRequest", nMessageID, szMessage, szOKText, szCancelText, param1)
function RemoteFunction.OnMessageBoxRequest(nMessageID, szMessage, szOKText, szCancelText, param1)
	local tOKOption = {
		szOption = szOKText or g_tStrings.STR_HOTKEY_SURE,
		fnAction = function()
			RemoteCallToServer("OnMessageBoxRequest", nMessageID, true, param1)
		end,
		szSound = nil,
	}
	local tCancelOption = {
		szOption = szCancelText or g_tStrings.STR_HOTKEY_CANCEL,
		fnAction = function()
			RemoteCallToServer("OnMessageBoxRequest", nMessageID, false, param1)
		end,
		szSound = nil,
	}
	local tMessageInfo = {
		szMessage = szMessage, 
		szName = "PlayerMessageBoxCommon", 
		fnAutoClose = nil,
		tOKOption,
		tCancelOption,
	}
	MessageBox(tMessageInfo)
end

function RemoteFunction.OnSpringCompassReceive(bIsNpcRequest, tLoc)
	if CompassPanel and CompassPanel.RemoteReceiveLoc then
		CompassPanel.RemoteReceiveLoc(bIsNpcRequest, tLoc)
	end
end

function RemoteFunction.OpenSpringCompass()
	if CompassPanel.IsOpened() then
		CompassPanel.ClosePanel()
	else
		CompassPanel.OpenPanel()
	end
end

function RemoteFunction.OnRollCall(dwLeaderID)
	arg0 = dwLeaderID
	FireEvent("RIAD_READY_CONFIRM_RECEIVE_QUESTION")
end

function RemoteFunction.OnBeAllSet(dwPlayerID, nReadyState)
	arg0, arg1 = dwPlayerID, nReadyState
	FireEvent("RIAD_READY_CONFIRM_RECEIVE_ANSWER")
end

function RemoteFunction.OnItemTransferToCity(nItemID, tCanTrafficMapList)
	OpenWorldMapByItem(true, nItemID, tCanTrafficMapList or {})
end

function RemoteFunction.OnGetSkillLevelRespond(dwPlayerID, tResult)
	arg0, arg1 = dwPlayerID, tResult
	FireEvent("ON_GET_SKILL_LEVEL_RESULT")
end

function RemoteFunction.OnGetTerainRequestRespond(dwPlayerID, nCurrentTrainValue, nMaxTrainValue, nUsedTrainValue, nMaxUsedTrainValue, nGongliValue)
	arg0, arg1, arg2, arg3, arg4, arg5 = dwPlayerID, nCurrentTrainValue, nMaxTrainValue, nUsedTrainValue, nMaxUsedTrainValue, nGongliValue
	FireEvent("ON_GET_TRAIN_RESULT")
end

function RemoteFunction.OnOpenExamPanel(szQuestionList, nPromoteTime, nTestType)
	if not ExaminationPanel.IsOpened() then
		ExaminationPanel.OpenPanel(szQuestionList, nPromoteTime, nTestType)
	end
end

function RemoteFunction.OnCloseExamPanel()
	if ExaminationPanel.IsOpened() then
		ExaminationPanel:ClosePanel()
	end
end

function RemoteFunction.SynExamContent(nQuestionIndex, tExamContents)
	if not ExaminationPanel.tExamContentList or nQuestionIndex > #ExaminationPanel.tExamContentList then
		return
	end
	if ExaminationPanel.nLastQuestionIndex == nQuestionIndex then
		ExaminationPanel.tExamContentList[nQuestionIndex] = tExamContents
		local image = ExaminationPanel.handleIconList:Lookup(("Image_List%02d"):format(nQuestionIndex))
		ExaminationPanel.UpdateExamContent(image)
		ExaminationPanel.UpdateTitle()
	end
end

function RemoteFunction.SendExamAnswer()
	if ExaminationPanel then
		RemoteCallToServer("OnReceiveExamAnswer", ExaminationPanel.CloneAnswerTable())
	end
end

function RemoteFunction.OnHoroSysDataUpdate(tHoroSysData)
	if CompassPanel then
		CompassPanel.OnHoroSysDataUpdate(tHoroSysData)
	end
end

function RemoteFunction.StartFilterMask(nFadeOutTime, nFadeInTime, nKeepTime, tFadeColor, bRENDER, bHideUI, tText)
	--OpenFilterMask(nFadeOutTime, nFadeInTime, nKeepTime, tFadeColor, bRENDER, bHideUI, tText)
end

function RemoteFunction.MakeQuestionnaire(szQuestionnaire)
	MakeQuestionnaire(szQuestionnaire)
end

function RemoteFunction.CloseDialogPanel(bDisableSound)
	CloseDialoguePanel(bDisableSound)
end

function RemoteFunction.OnCanEnterDungeon(dwMapID, nCopyIndex)
	CanEnterPartyRecruitDungeon(dwMapID, nCopyIndex)
end

function RemoteFunction.OnResponseFindTeamDungeonInfo(nDungeonType, dwMapID, tData)
	OnPartyRecruitMapDataNotify(nDungeonType, dwMapID, tData)
end

function RemoteFunction.OnFindTeamDungeonFinished(dwPQID, tResult)
	 OnPartyRecruitDungeonFinished(tResult)
end

function RemoteFunction.OnResponseFindTeamRequest(nParam1, nParam2, nParam3)
	OnPartyRecruitResponse(nParam1, nParam2, nParam3)
end

function RemoteFunction.OnResponseFindTeamDungeonPQ(dwPQID, tResult, nEndFrame)
	PartyRecruitRequestPQInfo()
	OnFindTeamPQUpdate(dwPQID, tResult, nEndFrame)
end

function RemoteFunction.OnResponseGetPlayerQueueIDList(tQueueID)
	OnResponseQueryQueueState(tQueueID)
end

function RemoteFunction.OnCharacterHeadTip(dwCharacterID, szTip, szParam)
	OnCharacterHeadLog(dwCharacterID, szTip, szParam)
end

function RemoteFunction.OnFindTeamStartGame(nEndFrame)
	FindTeamPQObjective.OnFindTeamStartGame(nEndFrame)
end

function RemoteFunction.OnResponseIsPlayerInWaitConfirm(dwMapID, nCopyIndex, nLeftTime)
	local player = GetClientPlayer()
	local scene = player.GetScene()
	if scene.dwMapID == dwMapID then
		return
	end
	
	if nLeftTime then
		nLeftTime = nLeftTime - 30
		if nLeftTime < 0 then
			nLeftTime = 0
		end
		
		local nCurrentTime = GetTickCount()
		nLeftTime = nCurrentTime + nLeftTime * 1000
	end
	
	CanEnterPartyRecruitDungeon(dwMapID, nCopyIndex, nLeftTime)
end

-- 弹出通用的 3道具 填入功能面板
-- RemoteCallToClient(player.dwID, "OnOpenIrrigatePanel", nPanelIndex, szTipText, bDisableSound)
-- RemoteCallToClient(player.dwID, "OnOpenIrrigatePanel", 1, "<G><F172 HELLO WORLD>")
function RemoteFunction.OnOpenIrrigatePanel(nPanelIndex, szTipText, bDisableSound)
	if Station.Lookup("Topmost/IrrigatePanel") then
		IrrigatePanel.ClosePanel()
	end
	IrrigatePanel.OpenPanel(nPanelIndex, szTipText, bDisableSound)
end

-- 获得服务器传递下来的农场面板的基本信息
function RemoteFunction.OnFarmPanelDataRecive(tFarmBuffInfo, tAllowableAttentionTongIDList, tBanAttentionTongIDList)
	FarmPanel.BaseDataRecive(tFarmBuffInfo, tAllowableAttentionTongIDList, tBanAttentionTongIDList)
end

-- 获得来自服务器的随机帮会列表
function RemoteFunction.OnFarmPanelRandomTongRecive(tRandomTongIDList)
	FarmPanel.RandomTongListRecive(tRandomTongIDList)
end

-- 获得添加关注帮会的结果
function RemoteFunction.OnFarmPanelAddTongRecive(nEmptySlot, dwTongID, szTongName)
	FarmPanel.AddAttentionTongRecive(nEmptySlot, dwTongID, szTongName)
end

-- 获得添加关注帮会的结果
function RemoteFunction.OnFarmPanelChangeScoreRecord(nScore, nOldScore)
	FarmPanel.ChangeScoreRecord(nScore, nOldScore)
end

-- 礼品卡输入密码
-- RemoteCallToClient(player.dwID, "OpenFortunetellingPanel", dwTargetID, "请输入一个名字，将为你计算命运：")
function RemoteFunction.OpenFortunetellingPanel(dwTargetID, szTitle)
	local SendName = function(szName)
		if dwTargetID and szName and #szName > 0 then
			if TextFilterCheck(szName) then
				RemoteCallToServer("OnFortunetellingReceived", dwTargetID, szName)
			else
				OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.FAMR_PANEL.FORTUNETELLING_ERROR)
				OutputMessage("MSG_NPC_NEARBY", g_tStrings.FAMR_PANEL.FORTUNETELLING_FILTER)
			end
		end
	end
	GetUserInput(szTitle, SendName, nil, function() end, nil, nil, 31)
end

function RemoteFunction.OnAddWaistPendent(nRepresentID)
	FireEvent("ON_PENDANT_LIST_CHANGED")
end

function RemoteFunction.OnAddBackPendent(nRepresentID)
	FireEvent("ON_PENDANT_LIST_CHANGED")
end

function RemoteFunction.SetWaistPendentBoxSize(nBoxSize)	
	FireEvent("ON_PENDANT_SIZE_CHANGED")
end

function RemoteFunction.SetBackPendentBoxSize(nBoxSize)
	FireEvent("ON_PENDANT_SIZE_CHANGED")
end

function RemoteFunction.OnSelectWaistPendent(nRepresentID)
	arg0 = nRepresentID	
	FireEvent("ON_SLECT_WAIST_PENDANT")
end

function RemoteFunction.OnSelectBackPendent(nRepresentID)
	arg0 = nRepresentID
	FireEvent("ON_SLECT_BACK_PENDANT")
end

function RemoteFunction.OnRemoveWaistPendent(nRepresentID)
	FireEvent("ON_PENDANT_LIST_CHANGED")
end

function RemoteFunction.OnRemoveBackPendent(nRepresentID)
	FireEvent("ON_PENDANT_LIST_CHANGED")
end

function RemoteFunction.OnInscriptionNameClientRecive(dwTargetID, tInscriptionID, tInscriptionName)
	if not dwTargetID or not tInscriptionID or not tInscriptionName then
		return
	end
	
	Player.tInscriptionList = Player.tInscriptionList or {}
	Player.tInscriptionList[dwTargetID] = {
		{dwID = tInscriptionID[1], szName = tInscriptionName[1]},
		{dwID = tInscriptionID[2], szName = tInscriptionName[2]},
		{dwID = tInscriptionID[3], szName = tInscriptionName[3]},
		{dwID = tInscriptionID[4], szName = tInscriptionName[4]},
	}
end

function RemoteFunction.OnActivityRemind(nCouresID)
	if nCouresID then
		OpenCoures(nCouresID)
		return
	end
end

function RemoteFunction.ShowPlugWarningDialog()
	OpenCheatWarningPanel()
end
function RemoteFunction.OnWillBeAddFoeNotify(szSrcName, nLeftSeconds)
	arg0 = szSrcName
	arg1 = nLeftSeconds
	
	if nLeftSeconds > 0 then
		FireEvent("PLAYER_APPLY_BE_ADD_FOE")
	else
		FireEvent("PLAYER_HAS_BE_ADD_FOE")
	end
end

function RemoteFunction.OnWillAddFoeNotify(szDestName, nLeftSeconds)
	arg0 = szDestName
	arg1 = nLeftSeconds
	
	if nLeftSeconds > 0 then
		FireEvent("PLAYER_ADD_FOE_BEGIN")
	else
		FireEvent("PLAYER_ADD_FOE_END")
	end
end

function RemoteFunction.OnPrepareAddFoeResult(nResult)
    arg0 = nResult
    FireEvent("PREPARE_ADD_FOE_RESULT")
end

function RemoteFunction.ShowGuildCampReverse(nCamp, nCountDownTime)
	OpenGuildCampReverse(nCamp, nCountDownTime)
end
function RemoteFunction.SetTitlePoint(nNewTitlePoint, nAddTitlePoint)
	if nAddTitlePoint > 0 then
		FireUIEvent("TITLE_POINT_UPDATE", nNewTitlePoint, nAddTitlePoint)
	end
end

function RemoteFunction.SetTitleInfo(nNewTitle, nNewTitlePoint)
end

function RemoteFunction.OnSetMiniAvatar(dwMiniAvatarID)
	local player = GetClientPlayer();
	if not player then
		return;
	end
	
	player.SetMiniAvatar(dwMiniAvatarID)
	
	arg0 = dwMiniAvatarID
    FireEvent("SET_MINI_AVATAR")
end

function RemoteFunction.OnKillPlayerWithHighestTitle(dwPlayerID)
	arg0 = dwPlayerID
	FireEvent("KILL_PLAYER_HIGHEST_TITLE")
end

function RemoteFunction.StrengthEquipRespond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("FE_STRENGTH_EQUIP")
	arg0 = argBack
end

function RemoteFunction.BreakEquipRespond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("FE_BREAK_EQUIP")
	arg0 = argBack
end

function RemoteFunction.OnClintBeforeBreakEquip()
	OnBreakEquip()
end

function RemoteFunction.OnUpdateDiamond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("DIAMON_UPDATE")
	arg0 = argBack
end

function RemoteFunction.OnUnMountAllDiamonds(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("EQUIP_UNMOUNT")
	arg0 = argBack
end

function RemoteFunction.UnStrengthEquipRespond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("EQUIP_UNSTRENGTH")
	arg0 = argBack
end

function RemoteFunction.OnMountDiamond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("MOUNT_DIAMON")
	arg0 = argBack
end

function RemoteFunction.QuickUpdateDiamondRespond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("QUICK_UPDATE_DIAMOND")
	arg0 = argBack
end

function RemoteFunction.ChangeColorDiamondRespond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("CHANGE_COLOR_DIAMOND_RESPOND")
	arg0 = argBack
end

function RemoteFunction.UpdateColorDiamondRespond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("UPDATE_COLOR_DIAMOND_RESPOND")
	arg0 = argBack
end

function RemoteFunction.OnMountColorDiamond(nResult)
	local argBack = arg0
	arg0 = nResult
	FireEvent("MOUNT_COLOR_DIAMON")
	arg0 = argBack
end

function RemoteFunction.OnBattleFieldLowMinLimit(dwMapID, nTime)
    BattleField_SetCloseMapInfo(dwMapID, nTime)
end

function RemoteFunction.OnSendMessage(szMsgType, szMsg)
    OutputMessage(szMsgType, szMsg)
end

function RemoteFunction.OnExchangeEquipBackUp(nResult)
	arg0 = nResult
	FireEvent("EQUIP_CHANGE")
end

function RemoteFunction.OnUnEquipAll(nResult)
	arg0 = nResult
	FireEvent("UNEQUIPALL")
end

function RemoteFunction.OnSyncEquipIDArray()
	FireEvent("SYNC_EQUIPID_ARRAY")
end

function RemoteFunction.OnSetPetTemplateID(dwNpcTemplateID)
	OpenPetActionBar(dwNpcTemplateID)
end

function RemoteFunction.OnRemovePetTemplateID(dwNpcTemplateID)
	FireEvent("REMOVE_PET_TEMPLATEID")
end

function RemoteFunction.OnSetPuppetTemplateID(dwNpcTemplateID)
	OpenPuppetActionBar(dwNpcTemplateID)
end

function RemoteFunction.OnRemovePuppetTemplateID(dwNpcTemplateID)
	FireEvent("REMOVE_PUPPET_TEMPLATEID")
end

function RemoteFunction.OnPQQuestPanelVisible(bVisible)
    FireUIEvent("PQTIME_PANEL_VISIBLE", bVisible)
end

function RemoteFunction.OnPQTimeChanged(nDeltaTime)
    FireUIEvent("PQTIME_TIME_CHANGED", nDeltaTime)
end

function RemoteFunction.OnPQQuestProgressUpdate(nCurrent, nTotal)
    FireUIEvent("PQTIME_PROGRESS_UPDATE", nCurrent, nTotal)
end

function RemoteFunction.OnPQQuestState(nState)
    FireUIEvent("PQQUEST_STATE_UPDATE", nState)
end

function RemoteFunction.OnPQSetEndTime(nEndTime)
    FireUIEvent("PQQUEST_END_TIME_UPDATE", nEndTime)
end

function RemoteFunction.OnPQQuestLeftTimeUpdate(nLeftTime)
    FireUIEvent("PQQUEST_LEFT_TIME_UPDATE", nLeftTime)
end

function RemoteFunction.StopBgMusic(szAnnounce, szColor)
	StopBgMusic()
	if not szColor or type(szColor) ~= "string" then
		return
	end
	szColor = szColor:lower()
	if szColor == "red" then
		OutputMessage("MSG_ANNOUNCE_RED", szAnnounce)
	elseif szColor == "yellow" then
		OutputMessage("MSG_ANNOUNCE_YELLOW", szAnnounce)
	end
end

function RemoteFunction.FieldPQStateUpdate(dwPQTemplateID, nStepID, nState, nTime, tPQTrace, tPQStatistic, nScore, nNextTime)
	OpenFieldPQPanel(dwPQTemplateID, nStepID, nState, nTime, tPQTrace, tPQStatistic, nScore, nNextTime, true)
end

function RemoteFunction.CloseFieldPQPanel(dwPQTemplateID)
	CloseFieldPQPanel(dwPQTemplateID)
end

local bOldPostEffectEnable 
function RemoteFunction.EnableColorShift(bEnable) --true 开启偏色， false 关闭偏色
    local a3DEngineOption = KG3DEngine.Get3DEngineOption()
    
    if bEnable then
        bOldPostEffectEnable = a3DEngineOption.bPostEffectEnable
        a3DEngineOption.bPostEffectEnable = true
    else
        a3DEngineOption.bPostEffectEnable = bOldPostEffectEnable
    end
    
    a3DEngineOption.bCurveCMYK = bEnable
    KG3DEngine.Set3DEngineOption(a3DEngineOption)
end

function RemoteFunction.SetColorShift(dwID) --1,2,3,4,5,6,7,8  设置偏色
   	local a3DEngineOption = KG3DEngine.Get3DEngineOption()
    
    a3DEngineOption.nActiveCurveStype = dwID
    KG3DEngine.Set3DEngineOption(a3DEngineOption)    
end

function RemoteFunction.OnSetTongTechTreeRespond(nNodeIndex, nValue, bResult, nError)
	local argSave0, argSave1, argSave2, argSave3 = arg0, arg1, arg2, arg3
	arg0, arg1, arg2, arg3 = nNodeIndex, nValue, bResult, nError
	FireEvent("SET_TONG_TECH_TREE_RESPOND")
	arg0, arg1, arg2, arg3 = argSave0, argSave1, argSave2, argSave3
end

--------- 钓鱼相关
function RemoteFunction.OnOpenFishPanel()
	OpenFishPanel()
end

function RemoteFunction.OnFishHarvest(dwDoodadID)
	local hPlayer = GetClientPlayer()
	
	if hPlayer then
		local hDoodad = GetDoodad(dwDoodadID)
		if hDoodad then
			hPlayer.Open(dwDoodadID)
		end
	end
end

function RemoteFunction.OnFishProcessBreak()
	FireEvent("FISH_PROCESS_BREAK")	
end

function RemoteFunction.OnCloseFishPanel()
	FireEvent("CLOSE_FISH_PANEL")
end

function RemoteFunction.OnApplyFishRespond()
	FireEvent("FISH_START_PROCESS_BAR")
end

function RemoteFunction.OnOpenTongFarmPanel(dwNpcID, bEmpty, dwOwnerID, nHealth, nMature, nSeedItemID, nSoilLevel, nSoilExperience)
	OpenTongFarmPanel(dwNpcID, bEmpty, dwOwnerID, nHealth, nMature, nSeedItemID, nSoilLevel, nSoilExperience)
end

function RemoteFunction.OnGetTongPayTime(nWeekday)
	local argSave = arg0
	arg0 = nWeekday
	FireEvent("ON_GET_TONG_PAY_TIME")
	arg0 = argSave
end

function RemoteFunction.OnSetTongPayTimeResult(nWeekday, bSucess)
	local argSave0, argSave1 = arg0, arg1
	arg0, arg1 = nWeekday, bSucess
	FireEvent("ON_SET_TONG_PAY_TIME_RESULT")
	arg0, arg1 = argSave0, argSave1
	if bSucess then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.GUILD_SET_PAY_DAY_SUCESS)
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_SET_PAY_DAY_FAILED)
	end
end

-- 打开帮会天工树面板
function RemoteFunction.OnOpenTongTechTreePanel(dwNpcID)
    OpenTongTechTreePanel(dwNpcID)
end

function RemoteFunction.OnGetTongSceneExist(bMapExist)
	local argS = arg0
	arg0 = bMapExist
	FireEvent("ON_GET_TONG_SCENE_EXIST")
	arg0 = argS	
end

function RemoteFunction.OnTongArenaAngleRespond(nCamp, tData)
    FireUIEvent("TONG_AREAN_ANGLE_DATA", nCamp, tData)
end

function RemoteFunction.OnTongArenaGameRespond(nCamp, nGameType, nNumber, tData)
    FireUIEvent("TONG_AREAN_GAME_DATA", nCamp, nGameType, nNumber, tData)
end

function RemoteFunction.OnTongArenaVoteRankRespond(nCamp, tData)
    FireUIEvent("TONG_AREAN_VOTE_DATA", nCamp, tData)
end

function RemoteFunction.OnTongArenaVotePlayerRespond(dwTargetID, nScore, nResult)
    FireUIEvent("TONG_AREAN_VOTE_PLAYER_RESPOND", dwTargetID, nScore, nResult)
end

function RemoteFunction.OnTongArenaFinalWarRespond(nNumber, tData)
    FireUIEvent("TONG_AREAN_FINAL_WAR_DATA", nNumber, tData)
end

function RemoteFunction.OnTongArenaFinalRankRespond(nNumber, tData)
    FireUIEvent("TONG_AREAN_FINAL_RANK_DATA", nNumber, tData)
end

function RemoteFunction.OnTongArenaChampionRespond(szPlayerName, bCurrentChampion)
    FireUIEvent("TONG_AREAN_CHAMPION", szPlayerName, bCurrentChampion)
end

function RemoteFunction.OnTongArenaCampMVPRespond(tData)
    FireUIEvent("TONG_AREAN_CAMP_MVP", tData)
end

function RemoteFunction.OnTongArenaVoteChampionRespond(nResult)
    FireUIEvent("TONG_AREAN_VOTE_CHAMPOIN", nResult)
end

function RemoteFunction.OnRewardStateRespond(nState, szVotePlayer, nReward)
    FireUIEvent("TONG_AREAN_REWARD_STATE", nState, szVotePlayer, nReward)
end

function RemoteFunction.OnTongArenaTimeRespond(nWeek, nDay)
    FireUIEvent("TONG_AREAN_TIME", nWeek, nDay)
end

function RemoteFunction.OnOpenWarningPanel(nWarningType, nTextID, nTime)
	--OutputWarningTip(nWarningType, nTextID, nTime)
end

function RemoteFunction.OnOutputWarningMessage(szWarningType, szText, nTime)
	OutputWarningMessage(szWarningType, szText, nTime)
end

function RemoteFunction.OnCloseWarningMessage(szWarningType)
	CloseWarningMessage(szWarningType)
end

function RemoteFunction.On_Tong_DeclareWarRespond(nRetCode)
	OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tXuanRequestResult[nRetCode])
end

function RemoteFunction.On_Tong_AddTopTenRespond(nRetCode)
	-- 出Log
	if nRetCode == TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_SUCCESS then
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.tTongAddTopTongReult[nRetCode])
		OutputMessage("MSG_SYS", g_tStrings.tTongAddTopTongReult[nRetCode] .. g_tStrings.STR_FULL_STOP .. "\n")
	else
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.tTongAddTopTongReult[nRetCode])
		OutputMessage("MSG_SYS", g_tStrings.tTongAddTopTongReult[nRetCode] .. g_tStrings.STR_FULL_STOP .. "\n")
	end
	FireUIEvent("ON_TONG_TOP_TEN_RESPOND", nRetCode)
	
	--[[
	TONG_PUBLICITY_RESULT_CODE.INVALID							// 默认未知错误
	TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_SUCCESS		// 成功
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_FAILED		// 失败
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_NOTMEMBER		// 不是帮会成员
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_OPERATOR		// 无权限
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_NOTENOUGHFUNC	// 帮会资金不足
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_LOWERFUNC		// 出价太低
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_MAXCOUNT		// 已达上限
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_COOLDOWN		// CD中
    TONG_PUBLICITY_RESULT_CODE.COMPETITIVERANKING_HAD			// 已存在
	--]]
end

function RemoteFunction.On_Tong_GetTopTenTongList(nCount, tTongIDList)
	local bRetCode = CheckHaveAllTongSimpleInfo(nCount, tTongIDList)
	FireUIEvent("ON_GET_TOPTEN_TONGLIST", bRetCode, nCount, tTongIDList)
end

function RemoteFunction.On_Tong_GetADTongList(nTotalCount, nCount, tTongIDList)
	local bRetCode = CheckHaveAllTongSimpleInfo(nCount, tTongIDList)
	arg0, arg1, arg2, arg3 = bRetCode, nTotalCount, nCount, tTongIDList
	FireUIEvent("ON_GET_AD_TONGLIST", bRetCode, nTotalCount, nCount, tTongIDList)
end


function RemoteFunction.On_Tong_ApplyJoinRespond(nRetCode)
	local szChannel = "MSG_ANNOUNCE_RED"
	if nRetCode == TONG_APPLY_JOININ_RESULT_CODE.SUCCESS then
		szChannel = "MSG_ANNOUNCE_YELLOW"
	end
	
	local szMsg = g_tStrings.tTongApplyJoininResult[nRetCode]
	if szMsg then
		OutputMessage(szChannel, szMsg)
		OutputMessage("MSG_SYS", szMsg .. g_tStrings.STR_FULL_STOP .. "\n")
	end
	
	-- 出Log
	--Output("On_Tong_ApplyJoinRespond " .. nRetCode)
	--[[
	TONG_APPLY_JOININ_RESULT_CODE.INVALID		// 默认未知错误
	TONG_APPLY_JOININ_RESULT_CODE.SUCCESS		// 成功
	TONG_APPLY_JOININ_RESULT_CODE.FAILED 		// 失败
	TONG_APPLY_JOININ_RESULT_CODE.NOT_MEMBER	// 不是帮会成员
	TONG_APPLY_JOININ_RESULT_CODE.NOT_TONG		// 帮会不存在
	TONG_APPLY_JOININ_RESULT_CODE.OPERATOR		// 无权限操作
	TONG_APPLY_JOININ_RESULT_CODE.MAX_COUNT		// 已达上限
	TONG_APPLY_JOININ_RESULT_CODE.IN_TONG		// 已入帮
	TONG_APPLY_JOININ_RESULT_CODE.IN_LIST		// 已入名单
	--]]
end

function RemoteFunction.On_Tong_DelApplyJoin(nRetCode)
	-- 出Log
	--Output("On_Tong_DelApplyJoin " .. nRetCode)
	--[[
	TONG_APPLY_JOININ_RESULT_CODE.INVALID		// 默认未知错误
	TONG_APPLY_JOININ_RESULT_CODE.SUCCESS		// 成功
	TONG_APPLY_JOININ_RESULT_CODE.FAILED 		// 失败
	TONG_APPLY_JOININ_RESULT_CODE.NOT_MEMBER	// 不是帮会成员
	TONG_APPLY_JOININ_RESULT_CODE.NOT_TONG		// 帮会不存在
	TONG_APPLY_JOININ_RESULT_CODE.OPERATOR		// 无权限操作
	TONG_APPLY_JOININ_RESULT_CODE.MAX_COUNT		// 已达上限
	TONG_APPLY_JOININ_RESULT_CODE.IN_TONG		// 已入帮
	TONG_APPLY_JOININ_RESULT_CODE.IN_LIST		// 已入名单
	TONG_APPLY_JOININ_RESULT_CODE.CAMP          // 阵营冲突
	--]]
end

function RemoteFunction.On_Tong_ClearApplyJoin(nRetCode)
	-- 出Log
	--Output("On_Tong_ClearApplyJoin " .. nRetCode)
	--[[
	TONG_APPLY_JOININ_RESULT_CODE.INVALID		// 默认未知错误
	TONG_APPLY_JOININ_RESULT_CODE.SUCCESS		// 成功
	TONG_APPLY_JOININ_RESULT_CODE.FAILED 		// 失败
	TONG_APPLY_JOININ_RESULT_CODE.NOT_MEMBER	// 不是帮会成员
	TONG_APPLY_JOININ_RESULT_CODE.NOT_TONG		// 帮会不存在
	TONG_APPLY_JOININ_RESULT_CODE.OPERATOR		// 无权限操作
	TONG_APPLY_JOININ_RESULT_CODE.MAX_COUNT		// 已达上限
	TONG_APPLY_JOININ_RESULT_CODE.IN_TONG		// 已入帮
	TONG_APPLY_JOININ_RESULT_CODE.IN_LIST		// 已入名单
	--]]
end

function RemoteFunction.On_Tong_GetApplyJoinInList(tPlayerInfoList)
	arg0 = tPlayerInfoList
	FireEvent("ON_GET_APPLY_JOININ_TONGLIST")
end

function RemoteFunction.On_Tong_GetTopTenCost(nLastCost, nMyTongCost, nRanking)
	-- 出Log
	FireUIEvent("ON_GET_TOP_TEN_COST", nLastCost, nMyTongCost, nRanking)
end

-- 开启中地图，帮会旗帜与匾额使用
function RemoteFunction.OnOpenMiddleMap()
	OpenMiddleMap()
end


function RemoteFunction.OnAddDevelopmentPointNotify(nPoint)
	local argSave0 = arg0
	arg0 = nPoint
    FireEvent("ON_ADD_DEVELOPMENT_POINT_NOTIFY")
    arg0 = argSave0
end

-------- 激活码相关
function RemoteFunction.OnActivityPasswordResult(szResult)
	arg0 = szResult
	FireEvent("ACTIVITY_PASSWORD_RESULT")
end

function RemoteFunction.OnActivityPasswordUrlRecive(szUrl)
	arg0 = szUrl
	FireEvent("ACTIVITY_PASSWORD_URL_RECIVE")
end

function RemoteFunction.OnOpennActivityPasswordPanel()
	OpenKeyPanel();
end

function RemoteFunction.OnActivitySymbolRespond(dwMapID, dwSymbol)
	local argSave0, argSave1 = arg0, arg1
	arg0, arg1 = dwMapID, dwSymbol
	FireEvent("ACTIVITY_SYMBOL_RESPOND")
	arg0, arg1 = argSave0, argSave1
end

function RemoteFunction.GetTongWeeklyPointRespond(nWeeklyDevelopmentRemain)
	local argSave0 = arg0
	arg0 = nWeeklyDevelopmentRemain
    FireEvent("ON_GET_TONG_WEEKLY_POINT")
    arg0 = argSave0
end

function RemoteFunction.OnOpenGuildListPanel(dwNpcID, bADList)
	OpenGuildListPanel(dwNpcID, bADList)
end

function RemoteFunction.OnBattleFieldRewardRespond(nEnterTime, dwMapID, tResult)
    FireUIEvent("ON_BATTLEFIELD_REWARD_DATA", nEnterTime, tResult, dwMapID)
end

function RemoteFunction.CallUIGlobalFunction(szFunction, param1, param2, param3, param4, param5)
    if _G[szFunction] then
        _G[szFunction](param1, param2, param3, param4, param5)
    end
end

function RemoteFunction.GetTodayZhanchangRespond(tResult)
    FireUIEvent("GET_TODAY_ZHANCHANG_RESPOND", tResult)
end

function RemoteFunction.OnFieldMarkStateUpdate(tMark)
	FireUIEvent("ON_FIELD_MARK_STATE_UPDATE", tMark)
end

function RemoteFunction.OnGetTongBuildLevelRespond(szGongFangName, szDanFangName, bGongFangBuilding, bDanFangBuilding, nGongFangTotalTimes, nDanFangTotalTimes, nGongBuildTimes, nDanBuildTimes)
	local tParam = {
		szGongFangName = szGongFangName, 
		bGongFangBuilding = bGongFangBuilding,
		nGongFangTotalTimes = nGongFangTotalTimes,
		nGongBuildTimes = nGongBuildTimes,
		szDanFangName = szDanFangName,
		bDanFangBuilding = bDanFangBuilding,
		nDanFangTotalTimes = nDanFangTotalTimes,
		nDanBuildTimes = nDanBuildTimes,
	}
	FireUIEvent("ON_TONG_BUILD_LEVEL_RESPOND", tParam)
end

function RemoteFunction.OnSwitchMapFailed(dwSwitchMapID, nSwitchMpaCopyIndex, dwMoveMapID, nResultCode)
	local fun = function()
		RemoteCallToServer("OnSwitchMapFailed", dwSwitchMapID, nSwitchMpaCopyIndex)
	end
	
	local szMapName = Table_GetMapName(dwMoveMapID) or ""
	local msg =
	{
		szMessage = FormatString(g_tStrings.STR_SWITCHMAP_TIP, szMapName),
		szName = "SwtichMapTip",
		{ szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fun},
		{ szOption = g_tStrings.STR_HOTKEY_CANCEL},		
	}
	
	MessageBox(msg)
	CloseDialoguePanel()
end

function RemoteFunction.OnCanJoinGongFangMap(dwMoveMapID)
	FireUIEvent("CMAP_QUEUE_OVER")
	if not CampQueue_IsShowSureNotcie() then
		RemoteCallToServer("OnCanJoinGongFangMap", dwMoveMapID)
		return
	end
	
	local fun = function()
		RemoteCallToServer("OnCanJoinGongFangMap", dwMoveMapID)
	end
	
	local nCountTime = 30
	local nTimeEnd = GetTickCount() + nCountTime * 1000
	local funClose = function()
		local dwCurrentTime = GetTickCount()
		if nTimeEnd <= dwCurrentTime then
			return true
		end
		return false
	end
	
	local szMapName = Table_GetMapName(dwMoveMapID) or ""
	local msg =
	{
		szMessage = FormatString(g_tStrings.STR_SWITCHMAP_GFZ_TIP, szMapName),
		szName = "CanJoinGongFangMapTip",
		fnAutoClose = funClose,
		{ szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fun, nCountDownTime = nCountTime},
		{ szOption = g_tStrings.STR_HOTKEY_CANCEL},		
	}
	
	MessageBox(msg)
end

function RemoteFunction.OnCanJoinNormalMap(dwMoveMapID, nMoveX, nMoveY, nMoveZ)
	local fun = function()
		RemoteCallToServer("OnCanJoinNormalMap", dwMoveMapID, nMoveX, nMoveY, nMoveZ)
	end
	
	local nCountTime = 30
	local nTimeEnd = GetTickCount() + nCountTime * 1000
	local funClose = function()
		local dwCurrentTime = GetTickCount()
		if nTimeEnd <= dwCurrentTime then
			return true
		end
		return false
	end
	
	local szMapName = Table_GetMapName(dwMoveMapID) or ""
	local msg =
	{
		szMessage = FormatString(g_tStrings.STR_SWITCHMAP_GFZ_TIP, szMapName),
		szName = "CanJoinNormalMapTip"..dwMoveMapID,
		fnAutoClose = funClose,
		{ szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = fun, nCountDownTime = nCountTime},
		{ szOption = g_tStrings.STR_HOTKEY_CANCEL},		
	}
	
	MessageBox(msg)
end

function RemoteFunction.OnJoinGongFangMapListSuccess(dwMapID)
	local szMapName = Table_GetMapName(dwMapID) or ""
	local msg =
	{
		szMessage = FormatString(g_tStrings.STR_JOIN_GFZ_MAP_LIST_SUCCESS_TIP, szMapName),
		szName = "JoinGongFangMapListSuccessTip",
		{ szOption = g_tStrings.STR_HOTKEY_SURE },
	}
	
	MessageBox(msg)
end

function RemoteFunction.OnJoinGongFangMapListAgain(dwMapID)
	local szMapName = Table_GetMapName(dwMapID) or ""
	local msg =
	{
		szMessage = FormatString(g_tStrings.STR_JOIN_GFZ_MAP_LIST_AGAIN_TIP, szMapName),
		szName = "JoinGongFangMapListAgainTip",
		{ szOption = g_tStrings.STR_HOTKEY_SURE },
	}
	
	MessageBox(msg)
end

function RemoteFunction.OnJoinGongFangMapListRanking(nRanking)
	FireUIEvent("CMAP_QUEUE_POS_UPDATE", nRanking)
end

function RemoteFunction.OnHairShopRespond(nResult)
    if nResult == HAIR_SHOP_RESPOND_CODE.BUYING then
        return
    end
	local szChannel = "MSG_ANNOUNCE_RED"
    SetHairShopWainting(false)
	if nResult == HAIR_SHOP_RESPOND_CODE.BUY_SUCCESS then
		szChannel = "MSG_ANNOUNCE_YELLOW"
        local szMsg = g_tStrings.HAIR_SHOP_RESPOND_SUCCESS
        local tMsg = 
        {
            szName = "hair_shop_respond_success",
            szMessage = szMsg,
            {szOption = g_tStrings.STR_HOTKEY_SURE},
        }
        MessageBox(tMsg)
		CloseHairShop()
		rlcmd("play sfx 1 0 0 0")
    else
        local szMsg = g_tStrings.HAIR_SHOP_RESPOND_FAILED
        local tMsg = 
        {
            bModal = true,
            szName = "hair_shop_respond_failed",
            szMessage = szMsg,
            {szOption = g_tStrings.STR_HOTKEY_SURE},
        }
        MessageBox(tMsg)
	end
	local szMsg = g_tStrings.tHairShopResult[nResult]
	--OutputMessage(szChannel, szMsg)
	OutputMessage("MSG_SYS", szMsg)
end

function RemoteFunction.OnBankPasswordNotify(szEvent)
	FireUIEvent("BANK_LOCK_RESPOND", szEvent)
end

function RemoteFunction.OnBattleFiledMarkDataNotify(tData)
	FireUIEvent("ON_BATTLE_FIELD_MAKR_DATA_NOTIFY", tData)
end

function RemoteFunction.OnBattleFiledGainDataNotify(tData)
	FireUIEvent("ON_BATTLE_FIELD_GAIN_DATA_NOTIFY", tData)
end

function RemoteFunction.OnActivityTipUpdate(dwActivityID, nTime, tValue)
    FireUIEvent("ACTIVITY_TIP_UPDATE", dwActivityID, nTime, tValue)
end

function RemoteFunction.OnActivityTipClose(dwActivityID)
    CloseActivityTipPanel(dwActivityID)
end

function RemoteFunction.OnGetDirectMentorRight(bCanBeDirectMentor, bCanBeDirectApprentice)
    FireUIEvent("ON_GET_DIRECT_MENTOR_RIGHT", bCanBeDirectMentor, bCanBeDirectApprentice)
end

function RemoteFunction.OnArenaEventNotify(szEvent, tData, tData1)
	FireUIEvent("OnArenaEventNotify", szEvent, tData, tData1)
end

function RemoteFunction.OnBattleTipNotify(param0, param1, param2)
	FireUIEvent("OnBattleTipNotify", param0, param1, param2)
end

function RemoteFunction.OnIsAccountDirectApprentice(bApprentice)
    FireUIEvent("ON_IS_ACCOUNT_DIRECT_APPRENTICE", bApprentice)
end

function RemoteFunction.OnMapDynamicDataNotify(dwMapID, tData)
	FireUIEvent("ON_MAP_DYNAMIC_DATA_NOTIFY", dwMapID, tData)
end

function RemoteFunction.CountDown(dwLeftTime, szPanelName)
	CountDownPanel.UpdateCountDown(dwLeftTime, szPanelName)
end

function RemoteFunction.OnPlayerUIMovie(szPath, nFadeInTime, bCanNotCanel)
	PlayUIMovie(szPath, nFddeInTime, bCanNotCanel)
end

function RemoteFunction.OnStopUIMovie()
	StopUIMovie()
end

function RemoteFunction.OnFightProgressNotify(szType, fPercent)
	FireUIEvent("OnFightProgressNotify", szType, fPercent)
end

function RemoteFunction.OnSprintHelp(dwID)
    OpenSprintHelp(dwID)
end

function RemoteFunction.OnExteriorRespond(nResult)
    if nResult == EXTERIOR_BUY_RESPOND_CODE.BUYING then
        return
    end
    local szChannel = "MSG_ANNOUNCE_RED"
    ExteriorBuy_SetWaitting(false)
    ExteriorRenew_SetWaitting(false)
    if nResult == EXTERIOR_BUY_RESPOND_CODE.BUY_SUCCESS then
        szChannel = "MSG_ANNOUNCE_YELLOW"
        CloseExteriorBuy()
        CloseExteriorRenew()
    end
    OutputMessage(szChannel, g_tStrings.tExteriorBuyRespond[nResult])
    OutputMessage("MSG_SYS", g_tStrings.tExteriorBuyRespond[nResult])
    FireUIEvent("ON_EXTERIOR_BUY_RESPOND", nResult)
end

function RemoteFunction.OnSetExteriorSet(nResult)
    local szChannel = "MSG_ANNOUNCE_RED"
    if nResult == EXTERIOR_APPLY_RESPOND_CODE.SUCCESS or 
    nResult == EXTERIOR_APPLY_RESPOND_CODE.YOU_DONOT_HAVE then
        szChannel = "MSG_ANNOUNCE_YELLOW"
    end
    OutputMessage(szChannel, g_tStrings.tExteriorSetCurrentSetRespond[nResult])
    OutputMessage("MSG_SYS", g_tStrings.tExteriorSetCurrentSetRespond[nResult])
    FireUIEvent("ON_SET_EXTERIOR_SET_RESPOND", nResult)
end

function RemoteFunction.OnChangeHair(nResult)
     local szChannel = "MSG_ANNOUNCE_RED"
    if nResult == HAIR_CHANGE_RESPOND_CODE.SUCCESS or 
    nResult == HAIR_CHANGE_RESPOND_CODE.YOU_DONOT_HAVE then
        szChannel = "MSG_ANNOUNCE_YELLOW"
    end
    OutputMessage(szChannel, g_tStrings.tExteriorChangeHairRespond[nResult])
    OutputMessage("MSG_SYS", g_tStrings.tExteriorChangeHairRespond[nResult])
    FireUIEvent("ON_HAIR_CHANGE_RESPOND", nResult)
    
end

function RemoteFunction.OnOpenChapters(dwChapterID, tTime1, tTime2, tTime3, tTime4, tTime5, nAlpha)
	OpenChapters(dwChapterID, tTime1, tTime2, tTime3, tTime4, tTime5, nAlpha)
end