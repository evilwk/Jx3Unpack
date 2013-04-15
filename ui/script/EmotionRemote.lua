-- �������������������ص�Զ�̵���
local OnUseEmotionForRemote = function(event)
	local szEmotion = arg2
	local player = GetClientPlayer()
	if not player then
		return
	end
	local dwTargetType, dwTargetID = player.GetTarget()
	local npc = GetNpc(dwTargetID)
	-- ʦͽϵͳ�ı�������, ����IDһ��Ϊ	: 
	local tMasterSysQuestID = {4676, 4687, 4688, 4689, 4690, 5336, 7152, 7910}
	if dwTargetType == 4 and dwTargetID ~= player.dwID and szEmotion == "/��Ҿ" then
		for i = 1, #tMasterSysQuestID do
			if player.GetQuestPhase(tMasterSysQuestID[i]) == 1 or player.GetQuestPhase(tMasterSysQuestID[i]) == 2 then
				RemoteCallToServer("OnClientUseEmotionForRemote", tMasterSysQuestID[i], dwTargetID, szEmotion)
				break;
			end
		end
	end
	
	if szEmotion == "/����" then
		if (player.GetQuestPhase(5099) == 1 and player.nFaceDirection > 40 and player.nFaceDirection < 80)
			or player.GetQuestPhase(5164) == 1 then
			RemoteCallToServer("EmotionForQuest", szEmotion)
		end	
	end
	
	if szEmotion == "/��Ҿ" then
		if player.GetQuestPhase(8338) == 1 then
			if npc.dwTemplateID == 9455 or npc.dwTemplateID == 9479 or npc.dwTemplateID == 9458 or npc.dwTemplateID == 9462 then
				RemoteCallToServer("EmotionForQuest", szEmotion)
			end
		end
		if player.GetQuestPhase(7052) == 1 and dwTargetType == 3 then
			RemoteCallToServer("EmotionForQuest", szEmotion)
		end
		if player.GetQuestPhase(6524) == 1 then
			RemoteCallToServer("EmotionForQuest", szEmotion)
		end
	end
	
	if dwTargetType == 4 and player.GetQuestPhase(7837) == 1 then
		local tEmotion = {
			["/Ц"] = {}, ["/˯��"] = {}, ["/����"] = {}, ["/��"] = {}, ["/ȦȦ"] = {}, 
			["/���"] = {}, ["/��Ϸ"] = {}, ["/����"] = {}, ["/����"] = {}, ["/����"] = {},
			["/����"] = {},["/����"] = {},["/����"] = {},["/����"] = {}, 
		}
		if tEmotion[szEmotion] then
			RemoteCallToServer("EmotionForQuest", szEmotion)
		end
	end
	
	if dwTargetType == 3 and (szEmotion == "/��" or szEmotion == "/�Ⱦ�") then
		local npc = GetNpc(dwTargetID)
		if not npc or npc.dwTemplateID ~= 16615 then
			return
		end
		RemoteCallToServer("EmotionForQuest", szEmotion)
	end

end	

RegisterEvent("ON_USE_EMOTION", OnUseEmotionForRemote)