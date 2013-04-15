FPS={
	
g_nCount = 0;

OnFrameBreathe=function()
	FPS.g_nCount = FPS.g_nCount + 1
	if FPS.g_nCount < 5 then
		return
	end
	FPS.g_nCount = 0
	
	local text = this:Lookup("", "Text_FPS")
	if text then
		local nLocalTatal, nLocalFree, nNonLocalTatal, nNonLocalFree, nTextureTatal, nTexturnFree, nD3DTatal, nD3DFree = GetVideoMemeryInfo()
		local nMemoryUsage, nTextureUsage, nSliceUsage = GetUITextureUsage()
		local nScale = 1024 * 1024
		nLocalTatal = math.floor(nLocalTatal / nScale)
		nLocalFree = math.floor(nLocalFree / nScale)
		nNonLocalTatal = math.floor(nNonLocalTatal / nScale)
		nNonLocalFree = math.floor(nNonLocalFree / nScale)
		nTextureTatal = math.floor(nTextureTatal / nScale)
		nTexturnFree = math.floor(nTexturnFree / nScale)
		nD3DTatal = math.floor(nD3DTatal / nScale)
		nD3DFree = math.floor(nD3DFree / nScale)
		nMemoryUsage = math.floor(nMemoryUsage / nScale)
		local strUIUsed = string.format("%.2f", nMemoryUsage)
		local strD3DFree = string.format("%.2f", nD3DFree)
		text:SetText("FPS:"..GetFPS().." UI:"..strUIUsed.."M used, ".." 3D:"..strD3DFree.."M free");
	end
end;

}
