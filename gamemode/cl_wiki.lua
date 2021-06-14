-- This allows you to integrate with NoXiousNet's wiki system.

function NDB.GetWikiFrame()
	local frame = vgui.Create("DFrame")
	frame:SetDeleteOnClose(true)
	frame:SetSize(800, 600)
	frame:SetTitle("In-game Wiki")

	local pan = NDB.GetWikiPanel()
	pan:SetParent(frame)
	pan:SetPos(8, 600 - pan:GetTall() - 8)

	frame.WikiPanel = pan

	return frame
end

local NextAllowClick = 0
local function ArticleDoClick(me)
	if NextAllowClick <= SysTime() then
		NextAllowClick = SysTime() + 2
		surface.PlaySound("weapons/ar2/ar2_reload_push.wav")
		me.Output:SetHTML("<html><head></head><body bgcolor='black'><span style='text-align:center;color:red;font-decoration:bold;font-size:200%;'>Loading...</span></body></html>")
		me.Output:OpenURL("http://heavy.noxiousnet.com/wiki/index.php?title="..tostring(me.Article))
	end
end

local function ContentsDoClick(me)
	surface.PlaySound("weapons/ar2/ar2_reload_push.wav")
	me.Output:SetHTML(tostring(me.Contents))
end

local function RecursiveAdd(window, current, output, contenttab)
	for i, tab in ipairs(contenttab) do
		if tab.Contents then
			local but = current:AddNode(tab.Name)
			but.Contents = tab.Contents
			but.DoClick = ContentsDoClick
			but.Output = output
			window.Contents[tab.Name] = tab.Contents
		elseif tab.Article then
			local but = current:AddNode(tab.Name)
			but.Article = tab.Article
			but.DoClick = ArticleDoClick
			but.Output = output
		elseif tab.Name then
			local node = current:AddNode(tab.Name)
			RecursiveAdd(window, node, output, tab)
		else
			print("Garbage detected in pHelp RecursiveAdd:", i, tab, current, contenttab)
		end
	end
end

function NDB.GetWikiPanel()
	local Window = vgui.Create("DPanel")
	Window:SetSize(784, 540)
	Window:SetCursor("pointer")
	Window.Contents = {}
	pWiki = Window

	local button = EasyButton(Window, "View the ENTIRE wiki", 8, 4)
	button:SetPos(8, Window:GetTall() - button:GetTall() - 8)
	button.DoClick = function(btn)
		Window.Output:OpenURL("http://heavy.noxiousnet.com/wiki/index.php")
	end

	local tree = vgui.Create("DTree", Window)
	tree:SetSize(Window:GetWide() * 0.25 - 8, Window:GetTall() - 24 - button:GetTall())
	tree:SetPos(8, 8)
	tree:SetIndentSize(8)
	tree.Window = Window
	Window.Tree = tree

	local output = vgui.Create("HTML", Window)
	output:SetSize(Window:GetWide() - tree:GetWide() - 24, Window:GetTall() - 16)
	output:SetPos(Window:GetWide() - output:GetWide() - 8, 8)
	output.Window = Window
	Window.Output = output

	if GAMEMODE.Wiki then
		RecursiveAdd(Window, tree, output, GAMEMODE.Wiki)
	end
	if NDB.Wiki then
		RecursiveAdd(Window, tree, output, NDB.Wiki)
	end

	return Window
end

function NDB.OpenWiki(article)
	if GAMEMODE.HandleWiki and GAMEMODE:HandleWiki(article) then
		return
	end

	local frame = NDB.GetWikiFrame()
	frame:Center()
	frame:MakePopup()
	if article then
		if frame.WikiPanel.Contents[article] then
			frame.WikiPanel.Output:SetHTML(frame.WikiPanel.Contents[article])
		else
			frame.WikiPanel.Output:OpenURL("http://heavy.noxiousnet.com/wiki/index.php?title="..tostring(article))
		end
	end
end

usermessage.Hook("recelim", function(um)
	NDB.EliminatedMaps = Deserialize(um:ReadString())
end)