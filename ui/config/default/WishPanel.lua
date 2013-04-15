-- local WISH_PANEL_PATH = "UI/Config/default/WishPanel.ini"
WishPanel = {}
WishPanel.hFrame = nil
WishPanel.dwIndex = nil

-- ����򿪴��ں���
function WishPanel.Open(dwIndex)
	WishPanel.hFrame = Station.Lookup("Normal/WishPanel")
	if not WishPanel.hFrame then
		-- WishPanel.hFrame = Wnd.OpenWindow(WISH_PANEL_PATH, "WishPanel")
		WishPanel.hFrame = Wnd.OpenWindow("WishPanel")
	end
	WishPanel.hFrame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	WishPanel.hFrame:Show()
	WishPanel.dwIndex = dwIndex

end
-- ����رմ��ں���
function WishPanel.Close()
	if WishPanel.hFrame then
		WishPanel.hFrame:Hide()
	end
end
-- ��Ӧ���������ʱ�¼�
function WishPanel.OnLButtonClick()

	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local nWishAmount = GetClientPlayer().GetItemAmount(ITEM_TABLE_TYPE.OTHER, WishPanel.dwIndex)		
		if nWishAmount > 0 then
			local szVowText = WishPanel.hFrame:Lookup("Edit_Wish"):GetText()
			if szVowText and szVowText ~= "" then				
				RemoteCallToServer("OnWishRequest", szVowText:sub(1, 50), WishPanel.dwIndex)
				WishPanel.Close()
			else
				OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.NO_WISH_ANNOUNCE)
				return
			end
		end
		
	elseif szName == "Btn_Close" then
		WishPanel.Close()
	end
end
