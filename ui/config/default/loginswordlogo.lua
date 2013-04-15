LoginSwordLogo={

OnFrameCreate = function()
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("TOPLEFT", 0, 0, "TOPLEFT", 35, 35)
end;

OnEvent = function(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPLEFT", 0, 0, "TOPLEFT", 35, 35)
	end
end;

};
