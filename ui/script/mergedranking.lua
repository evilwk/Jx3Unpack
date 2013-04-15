
if IsFileExist("\\ui\\mergedranking\\loadinglist.lua") then
	LoadScriptFile("\\ui\\mergedranking\\loadinglist.lua")
	local szUserRegion, szUserSever = GetUserServer()
	if g_MergedServerInfo and g_MergedRankingLoadingList then
		local t = g_MergedServerInfo[szUserSever] or {}
		for i, szOrgServer in ipairs(t) do
			if g_MergedRankingLoadingList[szOrgServer] then
				LoadScriptFile(g_MergedRankingLoadingList[szOrgServer])
			end
		end
	end
end

