do
	local tFunc = {}
	local CloseDialoguePanelOld = CloseDialoguePanel
		CloseDialoguePanel= function(bDisableSound)
		CloseDialoguePanelOld()
		local frame = Station.Lookup("Normal/DialoguePanel")
		if not frame then
			return
		end
		local eTargetType = frame.dwTargetType or false
		local dwTargetID = frame.dwTargetId or false
		local player = GetClientPlayer()
		
		for i, v in pairs(tFunc) do
			tFunc[i](player, eTargetType, dwTargetID)
		end
	end
	
	tFunc[4957] = function(player, eTargetType, dwTargetID)
		if eTargetType ~= TARGET.PLAYER then
			return
		end
		if dwTargetID ~= player.dwID then
			return
		end
		local tBuffList = player.GetBuffList()
		if not tBuffList then
			return
		end
		for i = 1, #tBuffList do 
			if tBuffList[i]["dwID"] == 1845 then
				RemoteCallToServer("RemoteDelBuff", eTargetType, dwTargetID)
				break
			end
		end		
	end	
end

