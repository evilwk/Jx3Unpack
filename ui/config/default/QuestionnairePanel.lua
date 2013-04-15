QuestionnairePanel = {}

function QuestionnairePanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	QuestionnairePanel.OnEvent("UI_SCALED")
	
	local btn = this:Lookup("Btn_Submit")
	if btn then
		btn:Enable(false)
	end
end

function QuestionnairePanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function QuestionnairePanel.OnCheckBoxCheck()
	local szName = this:GetName()
	local nQuestID, nOptionID, bMulti = QuestionnairePanel.GetQuestionOptionByName(szName)	
	if not nQuestID then
		return
	end
	
	local frame = this:GetRoot()
	if not bMulti then
		local nIndex = 1
		local c = frame:Lookup("Single_Quest"..nQuestID.."_"..nIndex)
		while c do
			if nIndex ~= nOptionID then
				c:Check(false)
			end
			nIndex = nIndex + 1
			c = frame:Lookup("Single_Quest"..nQuestID.."_"..nIndex)
		end
	end
	
	local btn = frame:Lookup("Btn_Submit")
	if btn then	
		btn:Enable(QuestionnairePanel.CanSubmitData(frame))
	end
end

function QuestionnairePanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	local nQuestID, nOptionID, bMulti = QuestionnairePanel.GetQuestionOptionByName(szName)
	if not nQuestID then
		return
	end
	local frame = this:GetRoot()
	local btn = frame:Lookup("Btn_Submit")
	if btn then	
		btn:Enable(QuestionnairePanel.CanSubmitData(frame))
	end
end

function QuestionnairePanel.GetQuestionOptionByName(szName)
	local nQuestID, nOptionID, bMulti
	if string.sub(szName, 1, 11) == "Multi_Quest" then
		local szTail = string.sub(szName, 12, -1)
		local nPos = string.find(szTail, "_")
		if nPos then
			nQuestID = tonumber(string.sub(szTail, 1, nPos - 1))
			nOptionID = tonumber(string.sub(szTail, nPos + 1, -1))
			bMulti = true
		end
	elseif string.sub(szName, 1, 12) == "Single_Quest" then
		local szTail = string.sub(szName, 13, -1)
		local nPos = string.find(szTail, "_")
		if nPos then
			nQuestID = tonumber(string.sub(szTail, 1, nPos - 1))
			nOptionID = tonumber(string.sub(szTail, nPos + 1, -1))
			bMulti = false
		end
	end
	
	return nQuestID, nOptionID, bMulti
end

function QuestionnairePanel.CanSubmitData(frame)
	local bCan = true
	local nQuestID = 1
	while true do
		local single = frame:Lookup("Single_Quest"..nQuestID.."_1")
		local multi = frame:Lookup("Multi_Quest"..nQuestID.."_1")
		local input = frame:Lookup("Input_Quest"..nQuestID)
		if single then
			local bFinish = false
			local nOptionID = 1
			while single do
				if single:IsCheckBoxChecked() then
					bFinish = true
					break
				end
				nOptionID = nOptionID + 1
				single = frame:Lookup("Single_Quest"..nQuestID.."_"..nOptionID)
			end
			if not bFinish then
				bCan = false
				break
			end
		elseif multi then
			local bFinish = false
			local nOptionID = 1
			while multi do
				if multi:IsCheckBoxChecked() then
					bFinish = true
					break
				end
				nOptionID = nOptionID + 1
				multi = frame:Lookup("Multi_Quest"..nQuestID.."_"..nOptionID)
			end
			if not bFinish then
				bCan = false
				break
			end
		elseif input then
			if input:GetText() == "" then
				bCan = false
				break
			end
		else
			break
		end
		nQuestID = nQuestID + 1
	end
	return bCan
end

function QuestionnairePanel.SubmitData(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	GMPanel.FillBasicInfo("NewUserQues")
	Interaction_AddParam("ResearchID", QuestionnairePanel.szQuestionnaire)
	Interaction_AddParam("CampID", player.nCamp)
	
	local nQuestID = 1
	while true do
		local single = frame:Lookup("Single_Quest"..nQuestID.."_1")
		local multi = frame:Lookup("Multi_Quest"..nQuestID.."_1")
		local input = frame:Lookup("Input_Quest"..nQuestID)
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
		elseif multi then
			local szResult = ""
			local nOptionID = 1
			while multi do
				if multi:IsCheckBoxChecked() then
					if szResult == "" then
						szResult = tostring(nOptionID)
					else
						szResult = szResult..","..nOptionID
					end
				end
				nOptionID = nOptionID + 1
				multi = frame:Lookup("Multi_Quest"..nQuestID.."_"..nOptionID)
			end
			Interaction_AddParam("Q"..nQuestID, szResult)
		elseif input then
			Interaction_AddParam("Q"..nQuestID, input:GetText())
		else
			break
		end 
		nQuestID = nQuestID + 1
	end
	
	Interaction_Send("Questionnaire", GMPanel.szIP, GMPanel.szObjectName, GMPanel.szVerb, GMPanel.nPort)		
end

function QuestionnairePanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Submit" or szName == "Btn_Sure" then
		QuestionnairePanel.SubmitData(this:GetRoot())
		CloseQuestionnairePanel()
		if not this.bDisableMessagebox then
			local msg = 
			{
				szMessage = g_tStrings.QUESTIONNAIRE_THANKS, 
				szName = "SubmitOk", 
				{szOption = g_tStrings.STR_PLAYER_SURE},
			}
			MessageBox(msg)
		end
	elseif szName == "Btn_Close" or szName == "Btn_Cancel" then
		CloseQuestionnairePanel()
	end
end

function OpenQuestionnairePanel(szQuestionnaire, szPannelName, bDisableSound)
	QuestionnairePanel.szQuestionnaire = szQuestionnaire
	
	if IsQuestionnairePanelOpened() then
		CloseQuestionnairePanel(true)
	end
	
	Wnd.OpenWindow(szPannelName, "QuestionnairePanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsQuestionnairePanelOpened()
	local frame = Station.Lookup("Normal/QuestionnairePanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseQuestionnairePanel(bDisableSound)
	Wnd.CloseWindow("QuestionnairePanel")
	QuestionnairePanel.szPannel = nil
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

local aQuestionnaire = 
{
	["Fresher"] = 1350,
	["FresherExitGame"] = 1351,
}

function MakeQuestionnaire(szQuestionnaire, bNotRecord)
	if aQuestionnaire[szQuestionnaire] and not GetUserPreferences(aQuestionnaire[szQuestionnaire], "b") then
		OpenQuestionnairePanel(szQuestionnaire, "Questionnaire_"..szQuestionnaire)
		if not bNotRecord then
			SetUserPreferences(aQuestionnaire[szQuestionnaire], "b", true)
		end
	end
end

function PlayerFinishQuestionnaire(szQuestionnaire)
	if aQuestionnaire[szQuestionnaire] then
		SetUserPreferences(aQuestionnaire[szQuestionnaire], "b", true)
	end
end
