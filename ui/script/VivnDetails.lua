local VivnDetails = {}

function VivnDetails.OnButtonEnter(hButton)

	if hButton:HasTip() then
		return
	end

	local hHandle = hButton:Lookup("", "")
	if hHandle then
		local hText = hHandle:Lookup(0)
		if hText and hText:GetType() == "Text" then
			szText = hText:GetText()
			if szText then
				szText = GetFormatText(szText)
				local x, y = hButton:GetAbsPos()
				local w, h = hButton:GetSize()
				OutputTip(szText, 335, {x, y, w, h})
			end
		end
	end
end

function VivnDetails.OnButtonLeave(hButton)
	HideTip()
end


function OnVivnDetails(szEvent)

	if szEvent == "OnButtonEnter" then
		VivnDetails.OnButtonEnter(this)
	elseif szEvent == "OnButtonLeave" then
		VivnDetails.OnButtonLeave(this)
	end

end
