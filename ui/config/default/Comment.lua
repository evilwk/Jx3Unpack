local COMMENT_HOLD_TIME = 3 * 60 * 1000
local INTERVAL = 18
local OVERLAP = 3
local CHANGE_FRAME_RATE = 1000
local MOUSE_ANIMATE_WIDTH = 23
local MOUSE_ANIMATE_HEIGHT = 47
local BUTTON_OFFSET = 10
local COMMENT_ADJUST_X = 2
local COMMENT_ADJUST_Y = 3

local tComments = {}

CommentPanel_Base = class()

function CommentPanel_Base.OnFrameCreate ()
    this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("HELP_COMMENT_SHOW_INFO_CHANGED")
    this:RegisterEvent("CUSTOM_DATA_LOADED")
end

function CommentPanel_Base.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:GetSelf().AdjustSize(this)
		this:CorrectPos()
	elseif szEvent == "HELP_PANEL_SHOW_INFO_CHANGED" then
		if not IsShowHelpPanel() then
			this:Hide()
		end
	elseif szEvent == "CUSTOM_DATA_LOADED" then
		if not IsShowHelpPanel() then
			this:Hide()
		end
	end 
end

function CommentPanel_Base.OnFrameBreathe()
	if not this.bHasObject then
		return
	end
	
	assert(this.hObject)
	if not IsElemVisible(this.hObject) or GetTickCount() - this.dwStartTime > this.nHoldTime then
		CloseComment(this:GetName())
		return
	end
	
	if this.hObject:IsValid() and this.hObject:GetType() == "Box" then
		local nCurType = this.hObject:GetObjectType()
		local tCurData =  {this.hObject:GetObjectData()}
		if IsBoxChanged(this.hObject.nOldType, this.hObject.tOldData, nCurType, tCurData) then
			CloseComment(this:GetName())
			return
		end 
	end
	
	this:GetSelf().AdjustPos(this, this.hObject)
	
	local hObjectFrame = this.hObject:GetRoot()
	assert(hObjectFrame)
	
	this:ChangeRelation(hObjectFrame, true) 
	
end

function CommentPanel_Base.AdjustPos(hFrame, hObject)
	assert(hFrame)
	assert(hObject)
	
	local fObjectX, fObjectY = hObject:GetAbsPos()
	local fObjectWidth, fObjectHeight = hObject:GetSize()
	local fClientWidth, fClientHeight = Station.GetClientSize()
	local hHandle = hFrame:Lookup("", "")
	
	local hTopLeftImage = hHandle:Lookup("Image_TopLeft")
	local hTopRightImage = hHandle:Lookup("Image_TopRight")
	local hBottomLeftImage = hHandle:Lookup("Image_BottomLeft")
	local hBottomRightImage = hHandle:Lookup("Image_BottomRight")
	
	hTopLeftImage:Hide()
	hTopRightImage:Hide()
	hBottomLeftImage:Hide()
	hBottomRightImage:Hide()
	
	hFrame:CorrectPos(fObjectX, fObjectY, fObjectWidth, fObjectHeight, ALW.CENTER)
	
	local fFrameX, fFrameY = hFrame:GetAbsPos()
	if fFrameX < fObjectX then
	    if fFrameY < fObjectY then
	        hBottomRightImage:Show()
	    else
	        hTopRightImage:Show()
		end
    else
        if fFrameY < fObjectY then
            hBottomLeftImage:Show()
        else
            hTopLeftImage:Show()
        end
	end
end

function CommentPanel_Base.AdjustSize(hFrame)
    assert(hFrame)
   
	local hHandle = hFrame:Lookup("", "")
	hHandle:SetItemStartRelPos(0, 0)
	
	local hHandleMsg = hHandle:Lookup("Handle_Message")
	local fMsgWidth, fMsgHeight = hHandleMsg:GetAllItemSize()
	hHandleMsg:SetSize(fMsgWidth, fMsgHeight)
	hHandleMsg:SetItemStartRelPos(0, 0)
	
	
	local hTopLeftImage = hHandle:Lookup("Image_TopLeft")
	local fArrowWidth, fArrowHeight = hTopLeftImage:GetSize()
	hTopLeftImage:SetRelPos(0, 0)
	
	local hMouseAnimate = hHandle:Lookup("Animate_Mouse")
    local fMouseWidth, fMouseHeight = hMouseAnimate:GetSize()
	local hImage = hHandle:Lookup("Image_BG")
	
	if fMouseWidth > 0 then
	    fBGWidth = INTERVAL + fMouseWidth + INTERVAL + fMsgWidth + INTERVAL
	else
	    fBGWidth = INTERVAL + fMouseWidth + fMsgWidth + INTERVAL
	end
	
	if fMsgHeight > fMouseHeight then
	  fBGHeight = INTERVAL + fMsgHeight + INTERVAL
	else
	  fBGHeight = INTERVAL + fMouseHeight + INTERVAL
	end
	hImage:SetSize(fBGWidth, fBGHeight)
	hImage:SetRelPos(0, fArrowHeight - OVERLAP)
	
	local hButton = hFrame:Lookup("Btn_Close")
	local fButtonWidth, fButtonHeight = hButton:GetSize()
	hButton:SetRelPos(fBGWidth - fButtonWidth - BUTTON_OFFSET, fArrowHeight - OVERLAP + BUTTON_OFFSET)
	
	if fMouseWidth > 0 then
	    hHandleMsg:SetRelPos(INTERVAL + fMouseWidth + INTERVAL, fArrowHeight + (fBGHeight - fMsgHeight)/2)
	else
	    hHandleMsg:SetRelPos(INTERVAL + fMouseWidth, fArrowHeight + (fBGHeight - fMsgHeight)/2)
	end
	
	hMouseAnimate:SetRelPos(INTERVAL, fArrowHeight + (fBGHeight - fMouseHeight) / 2)
	
	local hTopRightImage = hHandle:Lookup("Image_TopRight")
	hTopRightImage:SetRelPos(fBGWidth - fArrowWidth, 0)
	
	local hBottomLeftImage = hHandle:Lookup("Image_BottomLeft")
	hBottomLeftImage:SetRelPos(0, fArrowHeight + fBGHeight - OVERLAP * 2)
	
	local hBottomRightImage = hHandle:Lookup("Image_BottomRight")
	hBottomRightImage:SetRelPos(fBGWidth - fArrowWidth, fArrowHeight + fBGHeight - OVERLAP * 2)
	
	hHandle:SetSize(fBGWidth, (fArrowHeight - OVERLAP) + fBGHeight + (fArrowHeight - OVERLAP))
	hHandle:FormatAllItemPos()
	
	hFrame:SetSize(fBGWidth, (fArrowHeight - OVERLAP) + fBGHeight + (fArrowHeight - OVERLAP))
end

function CommentPanel_Base.SetHoldTime(hFrame, nHoldTime)
    hFrame.nHoldTime = nHoldTime
end

function CommentPanel_Base.SetObject(hFrame, hObject)
	hFrame.bHasObject = true
    hFrame.hObject = hObject
    if hFrame.hObject then
    	if IsShowHelpPanel() then
			hFrame:Show()
			hFrame:GetSelf().AdjustPos(hFrame, hObject)
		end
		if hFrame.hObject:GetType() == "Box" then
			hFrame.hObject.nOldType = hFrame.hObject:GetObjectType()
			hFrame.hObject.tOldData =  {hFrame.hObject:GetObjectData()}
		end
    end
end

function CommentPanel_Base.OutputComment(hFrame, szMessage)
    assert(hFrame.hObject)
	local hHandle = hFrame:Lookup("", "Handle_Message")
	hHandle:Clear()
	hHandle:AppendItemFromString(szMessage)
	hHandle:FormatAllItemPos()
	hFrame:GetSelf().AdjustSize(hFrame)
	hFrame:BringToTop()
	
	FireEvent("ON_OUT_PUT_COMMENT")
end

function CommentPanel_Base.OnLButtonClick()
    CloseComment(this:GetRoot():GetName())
end

function CommentPanel_Base.SetResponse(hFrame, szResponse)
    assert(hFrame)
    assert(hFrame.hObject)
    
    if szResponse == "None" then
       return 
    end
    
    hFrame.hObject.szResponse = szResponse
    local hAnimateMouse = hFrame:Lookup("", "Animate_Mouse")
    if szResponse == "LButtonClick" then
        hAnimateMouse:SetAnimate("ui/Image/UICommon/CommonPanel2.UITex", 16)
    elseif szResponse == "RButtonClick" or szResponse == "All" then
        hAnimateMouse:SetAnimate("ui/Image/UICommon/CommonPanel2.UITex", 17)
    end
    hAnimateMouse:SetSize(MOUSE_ANIMATE_WIDTH, MOUSE_ANIMATE_HEIGHT)
    hAnimateMouse:Show()
    
    OverLoadResponseFunction(hFrame.hObject, hFrame)
end

function CreateComment(szName)
	local hFrame = Wnd.OpenWindow("CommentPanel", szName)
	assert(hFrame)
	hFrame.nHoldTime =  COMMENT_HOLD_TIME
	hFrame.dwStartTime = GetTickCount()
	hFrame.szResponse = "None"
	hFrame.bHasObject = false
	local hAnimateMouse = hFrame:Lookup("", "Animate_Mouse")
	hAnimateMouse:Hide()
	hAnimateMouse:SetSize(0, 0)
	
	hFrame:Hide()
	
	return hFrame
end

function IsElemVisible(hElem)
    if not hElem:IsValid() then
       return false 
    end
    if hElem:GetType() == "WndButton" and not hElem:IsEnabled() then
    	return false
    end
    
    while hElem do
        if not hElem:IsVisible() then
            return false 
        end
        
         hElem = hElem:GetParent()
     end
    return true
end

function CloseComment(szName, bDisableSound)
	Wnd.CloseWindow(szName)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end

function BeginStaring(hObject)
    assert(hObject)
    if not hObject:IsVisible() then
       return 
    end
    
    local nIndex = 0
    local hHandle = nil
    local hStaring = nil
    
    if hObject:GetType() == "Box" then
        hObject:SetObjectStaring(true)
    else
        if hObject:GetType() == "Handle" then
           hHandle = hObject
        end
        
        if not hHandle then
            hHandle = hObject:Lookup("", "")
            if not hHandle then
                 hObject:CreateItemHandle("Handle_Staring")
            end
            hHandle = hObject:Lookup("", "")
        end
        if not hHandle then
           hHandle = hObject:GetParent()
           nIndex = hObject:GetIndex()
        end
        assert(hHandle)
        if not (hHandle:GetType() == "Handle") then
            Log("BeginStaring hHandle is error")
        end
       
        local szIniFile = "ui/Config/Default/StaringPanel.ini"
        hHandle:InsertItemFromIni(nIndex, false, szIniFile, "Image_Staring")
        hHandle:FormatAllItemPos()
        hStaring = hHandle:Lookup("Image_Staring")
        
        local nPosX, nPosY = hObject:GetAbsPos()
        local nWidth, nHeight = hObject:GetSize()
        hStaring:SetSize(nWidth, nHeight)
        hStaring:SetAbsPos(nPosX - COMMENT_ADJUST_X, nPosY - COMMENT_ADJUST_Y)
        hStaring:Show()
        hStaring.nAlphaIndex = 0
        
        hObject.hStaring = hStaring
        
    end
    table.insert(tComments, hObject)
    OverLoadResponseFunction(hObject, hStaring)
end

function OverLoadResponseFunction(hObject, hResonseObject)
    assert(hObject)
    local bItem = false;
    local hParent = hObject:GetParent()
    assert(hParent)
    if hObject:GetType() == "Handle" or hParent:GetType()== "Handle" then
        bItem = true
    end
    
    if hObject.szResponse == "LButtonClick" or hObject.szResponse == "All" then
        if bItem then
            local OldOnItemLButtonClick = nil
            if hObject.OnItemLButtonClick then
               OldOnItemLButtonClick = hObject.OnItemLButtonClick
            end
            hObject.OnItemLButtonClick = function()
                if hObject:GetType() == "Box" then
                    hObject:SetObjectStaring(false)
                end
                if hResonseObject then
                    hResonseObject:Hide()
                end
                        
                if OldOnItemLButtonClick then
                    OldOnItemLButtonClick()
                else
                	local hRoot = hObject:GetRoot()
	                if hRoot:GetSelf().OnItemLButtonClick then
	                    hRoot:GetSelf().OnItemLButtonClick()
	                end
                end
            end
        else 
            local OldOnLButtonClick = nil
            if hObject.OnLButtonClick then
               OldOnLButtonClick = hObject.OnLButtonClick
            end
            hObject.OnLButtonClick = function()
                if hObject:GetType() == "Box" then
                    hObject:SetObjectStaring(false)
                end
                if hResonseObject then
                    hResonseObject:Hide()
                end
                
                if OldOnLButtonClick then
                    OldOnLButtonClick()
                else
                	local hRoot = hObject:GetRoot()
	                if hRoot:GetSelf().OnLButtonClick then
	                    hRoot:GetSelf().OnLButtonClick()
	                end
                end
            end
        end
    end
    if hObject.szResponse == "RButtonClick" or hObject.szResponse == "All" then
        if bItem then
            local OldOnItemRButtonClick = nil
            if hObject.OnItemRButtonClick then
               OldOnItemRButtonClick = hObject.OnItemRButtonClick
            end
            hObject.OnItemRButtonClick = function()
                if hObject:GetType() == "Box" then
                    hObject:SetObjectStaring(false)
                end
                if hResonseObject then
                    hResonseObject:Hide()
                end
                
                if OldOnItemRButtonClick then
                    OldOnItemRButtonClick()
                else
                	local hRoot = hObject:GetRoot()
	                if hRoot:GetSelf().OnItemRButtonClick then
	                    hRoot:GetSelf().OnItemRButtonClick()
	                end
                end
            end
        else 
            local OldOnRButtonClick = nil
            if hObject.OnRButtonClick then
               OldOnRButtonClick = hObject.OnRButtonClick
            end
            hObject.OnRButtonClick = function()
                if hObject:GetType() == "Box" then
                    hObject:SetObjectStaring(false)
                end
                if hResonseObject then
                    hResonseObject:Hide()
                end
                
                if OldOnRButtonClick then
                    OldOnRButtonClick()
                else
                	local hRoot = hObject:GetRoot()
	                if hRoot:GetSelf().OnRButtonClick then
	                    hRoot:GetSelf().OnRButtonClick()
	                end
                end
            end
        end
    end
end

function OnCommentObjectBreathe()
    local hObject = nil
    
    local tAlpha = {255, 0, 32, 64, 96, 128, 160, 192, 224}
    local nAlphaCount = #tAlpha
    
	for _, hObject in pairs(tComments) do
        if IsElemVisible(hObject) and IsShowHelpPanel() then
            if hObject.hStaring then
                hObject.hStaring.nAlphaIndex = (hObject.hStaring.nAlphaIndex + 1) % nAlphaCount
                hObject.hStaring:SetAlpha(tAlpha[hObject.hStaring.nAlphaIndex + 1]) 
            end
        else
        	if hObject:IsValid() and hObject:GetType() == "Box" then
        		hObject:SetObjectStaring(false)
        	end
            if hObject.hStaring then
                hObject.hStaring:Hide()
            end
        end 
    end
end

function IsBoxChanged(nOldType, tOldData, nCurType, tCurData)
	if nOldType ~= nCurType then
		return true
	end
	
	if #tOldData ~= #tCurData then
		return true
	end
	
	for i = 1, #tOldData do
		if tOldData[i] ~= tCurData[i] then
			return true
		end
	end
	
	return false
end


