local INI_FILE_PATH = "UI/Config/Default/CGSelectPanel.ini"

CGSelectPanel = {}

function CGSelectPanel.OnFrameCreate()
	CGSelectPanel.OnEvent("UI_SCALED")
end

function CGSelectPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_CG" then
		if not this.bDisable then
			this.bOver = true
			CGSelectPanel.UpdateCGState(this)
		end
	end
end

function CGSelectPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_CG" then
		if not this.bDisable then
			this.bOver = false
			CGSelectPanel.UpdateCGState(this)
		end
	end
end

function CGSelectPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_CG" then
		if not this.bDisable then
			CGSelectPanel.SelectCG(this)
		end
	end
end

function CGSelectPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseCGSelectPanel()
	end
end


function CGSelectPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		CloseCGSelectPanel()		
	end
end

function CGSelectPanel.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -170, -150)
	end
end

function CGSelectPanel.SelectCG(hCG)
	LoginLogo.ShowCG(hCG.szCGPath, true)
	local szUrl = hCG.szDowloadUrl
	if LoginLogo.IsLogoExit(hCG.szCGPath) then
		Login.EnterLogo()
	else
		if szUrl and szUrl ~= "" then
			OpenInternetExplorer(szUrl)
		end
	end
	CloseCGSelectPanel(true)
end

function CGSelectPanel.UpdateList(hFrame)
	local hList = hFrame:Lookup("", "Handle_CGList")
	hList:Clear()
	local tList = Table_GetCGList()
	for _, tCG in ipairs(tList) do
		local hCG = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_CG")
		local hImageNormal = hCG:Lookup("Image_Normal")
		local hImagehighlight = hCG:Lookup("Image_Highlight")
		local hImageDisable = hCG:Lookup("Image_Disable")
		hImageNormal:FromUITex(tCG.szBgPath, tCG.nNormalFrame)
		hImagehighlight:FromUITex(tCG.szBgPath, tCG.nHightLightFrame)
		hImageDisable:FromUITex(tCG.szBgPath, tCG.nDisableFrame)
		local hText = hCG:Lookup("Text_TitleBase")
		hText:SetText(tCG.szDesc)
		hCG.bDisable = tCG.bDisable
		hCG.szCGPath = tCG.szCGPath
		hCG.szDowloadUrl = tCG.szDowloadUrl
		CGSelectPanel.UpdateCGState(hCG)
	end
	hList:FormatAllItemPos()
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_CGList", "CGSelectPanel", true)
end

function CGSelectPanel.UpdateCGState(hCG)
	local hImageNormal = hCG:Lookup("Image_Normal")
	local hImagehighlight = hCG:Lookup("Image_Highlight")
	local hImageDisable = hCG:Lookup("Image_Disable")
	if hCG.bDisable then
		hImageNormal:Hide()
		hImagehighlight:Hide()
		hImageDisable:Show()
	elseif hCG.bOver then
		hImageNormal:Hide()
		hImagehighlight:Show()
		hImageDisable:Hide()
	else
		hImageNormal:Show()
		hImagehighlight:Hide()
		hImageDisable:Hide()
	end
end

function OpenCGSelectPanel(bDisableSound)
	if not IsCGSelectPanelOpened() then
		Wnd.OpenWindow("CGSelectPanel")
	end
	
	local hFrame = Station.Lookup("Normal1/CGSelectPanel")
	Station.SetFocusWindow(hFrame)
	hFrame:BringToTop()
	CGSelectPanel.UpdateList(hFrame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function CloseCGSelectPanel(bDisableSound)
	if not IsCGSelectPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("CGSelectPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function IsCGSelectPanelOpened()
	local hFrame = Station.Lookup("Normal1/CGSelectPanel")
	if hFrame then
		return true
	end
	
	return false
end

do  
    RegisterScrollEvent("CGSelectPanel")
    
    UnRegisterScrollAllControl("CGSelectPanel")
        
    local szFramePath = "Normal1/CGSelectPanel"
    RegisterScrollControl(
        szFramePath, 
        "Btn_Up", "Btn_Down", 
        "Scroll_List", 
        {"", "Handle_CGList"}
   )
end