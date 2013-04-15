
local OpenExitPanelOld = OpenExitPanel
function OpenExitPanel(szReason, bDisableSound)
	local player = GetClientPlayer()
--	local _,_,_,szVersionEx = GetVersion()
--	if szVersionEx ~= "snda" and player and player.nLevel <= 1 and not IsInLoading() and szReason ~= "returntologin" and szReason ~= "returntorole" then
--	去掉对盛大服的限制。
	if player and player.nLevel <= 1 and not IsInLoading() and szReason ~= "returntologin" and szReason ~= "returntorole" then
		MakeQuestionnaire("FresherExitGame", true)
		local frame = Station.Lookup("Normal/QuestionnairePanel")
		if frame and frame:IsVisible() then
			frame.szReason = szReason
			frame:Lookup("Btn_Submit").OnLButtonClick = function()
				PlayerFinishQuestionnaire("FresherExitGame")
				local frame = this:GetRoot()
				local player = GetClientPlayer()
				if player then
					GMPanel.FillBasicInfo("NewUserQues")
					Interaction_AddParam("ResearchID", QuestionnairePanel.szQuestionnaire)
					Interaction_AddParam("CampID", player.nCamp)
						
					local nQuestID = 1
					while true do
						local single = frame:Lookup("Single_Quest"..nQuestID.."_1")
						if single then
							local szResult = ""
							local nOptionID = 1
							while single do
								if single:IsCheckBoxChecked() then
									szResult = tostring(nOptionID)
									break
								end
								nOptionID = nOptionID + 1
								single = frame:Lookup("Single_Quest"..nQuestID.."_"..nOptionID)
							end
							Interaction_AddParam("Q"..nQuestID, szResult)
						else
							break
						end 
						nQuestID = nQuestID + 1
					end
	
					local t3DEngineSettings = KG3DEngine.Get3DEngineOption()
					Interaction_AddParam("3DEngineSettings", var2str(t3DEngineSettings))				

					local tVideoSettings = GetVideoSettings()
					Interaction_AddParam("VideoSettings", var2str(tVideoSettings))

					local tComputerInfomation = GetComputerInfomation()
					Interaction_AddParam("ComputerInfomation", var2str(tComputerInfomation))
					
					Interaction_AddParam("FPS", GetFPS())
					Interaction_AddParam("PING", GetPing())

					Interaction_Send("Questionnaire", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)
				end
				Wnd.CloseWindow(frame:GetName())
				ExitGame()
			end
		else
			OpenExitPanelOld(szReason, bDisableSound)
		end
	else
		OpenExitPanelOld(szReason, bDisableSound)
	end
end