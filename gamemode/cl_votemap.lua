-- This is a lite version of the NoXiousNet map voting system. No doubt it will be used in places besides this gamemode.

local cvarUseFileNames = CreateClientConVar("nox_votemap_usefilenames", 0, true, false)
local cvarUseHTML = CreateClientConVar("nox_votemap_usehtml", 1, true, false)

local VoteButtonDoClick = function(me)
	surface.PlaySound("buttons/button3.wav")
	RunConsoleCommand("votemap", me.ID)
end

local WikiButtonDoClick = function(me)
	NDB.OpenWiki(me.MapName)
end

local VotePanelPaint = function(me)
	if me.m_bPaintBackground then
		local wid, hei = me:GetSize()

		surface.SetDrawColor(85, 85, 85, 255)
		surface.DrawRect(1, 1, wid - 2, hei - 2)

		surface.SetDrawColor(7, 4, 12, 255)
		surface.DrawRect(1, 0, wid - 2, 1)
		surface.DrawRect(0, 1, 1, hei - 2)
		surface.DrawRect(1, hei - 1, wid - 2, 1)
		surface.DrawRect(wid - 1, 1, 1, hei - 2)

		surface.SetDrawColor(46, 45, 49, 255)
		surface.DrawRect(1, 1, 1, 1)
		surface.DrawRect(wid - 2,1, 1, 1)
		surface.DrawRect(1, hei - 2, 1, 1)
		surface.DrawRect(wid - 2, hei - 2, 1, 1)
	end

	return true
end

local function SortByAmount(a,b) return a[2]>b[2] end

GM.VoteMapPanels = {}

local numvotes = {}
local numgtvotes = {}

-- usermessage.Hook("recmapnumvotes", function(um)
-- 	numvotes[um:ReadString()] = um:ReadShort()
-- 	if pVoteMap and pVoteMap.ListView then
-- 		pVoteMap.ListView:RefreshMaps()
-- 	end
-- end)

net.Receive("recmapnumvotes", function()
	print("Receiving recmapnumvotes")
	local a = net.ReadString()
	local b = net.ReadInt(16)
	numvotes[a] = b
	if pVoteMap and pVoteMap.ListView then
		pVoteMap.ListView:RefreshMaps()
	end
end)

-- usermessage.Hook("recgtnumvotes", function(um)
-- 	numgtvotes[um:ReadString()] = um:ReadShort()
-- end)

net.Receive("recgtnumvotes", function()
	print("Receiving recgtnumvotes")
	local a = net.ReadString()
	local b = net.ReadInt(16)
	numgtvotes[a] = b
end)

function OpenVoteMenu()
	if pVoteMap then
		pVoteMap:SetVisible(true)
		return
	end

	if not GAMEMODE.MapList then
		return
	end

	local wid = 660
	local hei = 560

	local Window = vgui.Create("DFrame")
	Window:SetSize(wid, hei)
	Window:Center()
	Window:SetTitle("Votemap")
	Window:SetVisible(true)
	Window:MakePopup()
	Window:SetDeleteOnClose(false)
	Window:SetKeyboardInputEnabled(false)
	pVoteMap = Window

	local PanelList = vgui.Create("DPanelList", Window)
	PanelList:EnableVerticalScrollbar()
	PanelList:EnableHorizontal(false)
	PanelList:SetSpacing(2)
	PanelList:SetSize(wid - 16, hei * 0.5 - 8)
	PanelList:SetPos(8, hei * 0.5)
	Window.PanelList = PanelList

	local allmaps = table.Copy(GAMEMODE.MapList)
	for i, tab in pairs(allmaps) do
		tab.Key = i
	end
	local function alphabeticalmapsort(a,b)
		a = string.lower(a[2] or a[1])
		b = string.lower(b[2] or b[1])
		return a < b
	end
	table.sort(allmaps, alphabeticalmapsort)

	for i, maptab in ipairs(allmaps) do
		if maptab[1] then
			local mappanel = vgui.Create("DPanel", PanelList)
			mappanel.Paint = VotePanelPaint
			mappanel:SetSize(PanelList:GetWide() - 16, 32)
			mappanel.MapTab = maptab
			PanelList:AddItem(mappanel)

			local eliminated = string.lower(game.GetMap()) == string.lower(maptab[1])

			local col
			if eliminated then
				col = COLOR_RED
			else
				col = COLOR_LIMEGREEN
			end

			if maptab[2] then
				local mapnamelab = EasyLabel(mappanel, maptab[2], "Default", col)
				mapnamelab:SetPos(4, 2)

				local filenamelab = EasyLabel(mappanel, maptab[1], "DefaultSmall")
				filenamelab:SetPos(4, 3 + mapnamelab:GetTall())
			else
				local mapnamelab = EasyLabel(mappanel, maptab[1], "Default", col)
				mapnamelab:SetPos(4, 2)
			end

			if maptab[5] then
				local pllab = EasyLabel(mappanel, "("..maptab[5].."+ players)", "DefaultSmall", color_white)
				pllab:SetPos(mappanel:GetWide() * 0.25 - pllab:GetWide() * 0.5, 16 - pllab:GetTall() * 0.5)
			end

			GAMEMODE.VoteMapPanels[ maptab[1] ] = mappanel

			local wikibutton = EasyButton(mappanel, "Wiki", 4, 1)
			wikibutton.DoClick = WikiButtonDoClick
			wikibutton.MapName = string.lower(maptab[1])
			wikibutton:SetPos(mappanel:GetWide() - 4 - wikibutton:GetWide(), 16 - wikibutton:GetTall() * 0.5)

			local votebutton = EasyButton(mappanel, "Vote!", 4, 1)
			if eliminated then
				votebutton:SetDisabled(true)
			else
				votebutton.ID = maptab.Key
				votebutton.DoClick = VoteButtonDoClick
			end
			votebutton:SetPos(mappanel:GetWide() - 8 - wikibutton:GetWide() - votebutton:GetWide(), 16 - votebutton:GetTall() * 0.5)

			if maptab[3] then
				if maptab[5] then
					mappanel:SetTooltip(tostring(maptab[3]).."\n\nCreated by:\n"..tostring(maptab[4]))
				else
					mappanel:SetTooltip(tostring(maptab[4]))
				end
			end
		end
	end
	if PanelList.VBar then
		timer.Simple(0, function()
			local mn, mx = math.min(0, PanelList.VBar.CanvasSize), math.max(0, PanelList.VBar.CanvasSize)
			PanelList.VBar:SetScroll(math.random(mn, mx))
		end)
	end

	local labd = EasyLabel(Window, "Double click an already voted map to quickly vote for it.", nil, COLOR_LIMEGREEN)
	labd:SetPos(8, 32)

	local ListView = vgui.Create("DListView", Window)
	ListView:SetMultiSelect(false)
	ListView:SetSize(wid * 0.35, hei * 0.5 - 42 - labd:GetTall())
	ListView:SetPos(8, 32 + labd:GetTall() + 2)
	ListView:AddColumn("Votes"):SetMaxWidth(48)
	ListView:AddColumn("Map Name")
	ListView.DoDoubleClick = function(me, id, line)
		if line.MapID then
			RunConsoleCommand("votemap", line.MapID)
		end
	end

	ListView.RefreshMaps = function(me)
		for id in pairs(me:GetLines()) do
			me:RemoveLine(id)
		end
		local maplist = GAMEMODE.MapList
		for mapname, numvotes in pairs(numvotes) do
			print("[Voting in progress] "..mapname..numvotes)
			if numvotes and 0 < numvotes then
				local line = me:AddLine(numvotes, mapname)
				if line and maplist then
					for i, mt in pairs(maplist) do
						if mt[1] and string.lower(mt[1]) == string.lower(mapname) then
							line.MapID = i
							break
						end
					end
				end
			end
		end
		me:SortByColumn(1, true)
	end

	ListView:RefreshMaps()
	for k, line in ipairs( ListView:GetLines() ) do
		print( k, line:GetValue( 1 ) )
	end
	Window.ListView = ListView

	local quickinfo = vgui.Create("DTextEntry", Window)
	quickinfo:SetMultiline(true)
	local lvx, lvy = ListView:GetPos()
	local qx = lvx + ListView:GetWide() + 8
	quickinfo:SetPos(qx, lvy)
	quickinfo:SetSize(wid - qx - 8, ListView:GetTall())
	quickinfo:SetEditable(false)
	quickinfo:SetValue("Welcome to the map voting menu.\n\nYour number of votes is determined by how well you do in the game, usually your score.\n\nWhen you're ready to vote, click the \"Vote\" button on the right side. You can also click the \"Wiki\" button to display detailed information the community may have contributed for it. Scrolling over a map panel will display a short description and any authors.")
end
concommand.Add("votemapopen", OpenVoteMenu)

function GetMostVotes()
	local most = 0
	local mapname = "this one"
	for name, num in pairs(numvotes) do
		if most < num then
			most = num
			mapname = name
		end
	end
	--print("Most map votes")
	--print(mapname)
	--print(most)
	return mapname, most
end

function GM:GetMapVotes()
	--print("Get Map votes")
	--print(numvotes)
	return numvotes
end

function GetMostGTVotes()
	local most = 0
	local gtname = "this one"
	for name, num in pairs(numgtvotes) do
		if most < num then
			most = num
			gtname = name
		end
	end
	--("Most GT votes")
	--print(gtname)
	--print(most)
	return gtname, most
end

function GM:GetGTVotes()
	--print("Get GT votes")
	--print(numgtvotes)
	return numgtvotes
end

hook.Add("Initialize", "GameTypeVotingInitialize", function()
	hook.Remove("Initialize", "GameTypeVotingInitialize")

	if not GAMEMODE.GameTypes then return end

	function OpenGTVoteMenu()
		if pVoteMap then
			pVoteMap:SetVisible(false)
		end

		if pGTVote and pGTVote:Valid() then
			return
		end

		local wid = 340
		local halfwid = wid * 0.5

		local Window = vgui.Create("DFrame")
		Window:SetWide(wid)
		Window:SetTitle("Vote for a Game Type!")
		Window:SetDeleteOnClose(true)
		Window:SetKeyboardInputEnabled(false)
		pGTVote = Window

		local y = 32

		local wb = WordBox(Window, "Vote for a Game Type to be played next!", "Default", color_white)
		wb:SetPos(halfwid - wb:GetWide() * 0.5, y)
		y = y + wb:GetTall() + 8

		local lab = EasyLabel(Window, "The next map is")
		lab:SetPos(8, y)
		print("Next map is...")
		lab.Think = function(me)
            -- print("Next map tick")
			local mapname, numvotes = GetMostVotes()
			-- print("Mapname: "..mapname)
			-- print("Numvotes: "..numvotes)
			if me.MostVotes ~= numvotes or me.MapName ~= mapname then
				me.MostVotes = numvotes
				me.MapName = mapname
				me:SetText("The next map is "..mapname.." with "..numvotes.." votes.")
				me:SizeToContents()
			end
		end
		y = y + lab:GetTall() + 2

		local lab = EasyLabel(Window, "The next game type is")
		lab:SetPos(8, y)
		lab.Think = function(me)
			local gtname, numvotes = GetMostGTVotes()
			if me.MostVotes ~= numvotes or me.GTName ~= gtname then
				me.MostVotes = numvotes
				me.GTName = gtname
				me:SetText("The next game type is "..gtname.." with "..numvotes.." votes.")
				me:SizeToContents()
			end
		end
		y = y + lab:GetTall() + 16

		for i, gt in ipairs(GAMEMODE.GameTypes) do
			local but = EasyButton(Window, GAMEMODE.GameTranslates[gt] or gt, 0, 4)
			but:SetWide(wid - 16)
			but:SetPos(8, y)
			but.GameType = gt
			but.Votes = -1
			but.OldThink = but.Think
			but.Think = function(me)
				local votes = numgtvotes[me.GameType] or 0

				if votes ~= me.Votes then
					me:SetText((GAMEMODE.GameTranslates[me.GameType] or me.GameType).." - "..votes.." votes")
				end
			end
			if GAMEMODE.GameTypeDescriptions and GAMEMODE.GameTypeDescriptions[gt] then
				but:SetTooltip(GAMEMODE.GameTypeDescriptions[gt])
			end
			but.DoClick = function()
				RunConsoleCommand("votegt", gt)
			end

			y = y + but:GetTall() + 4
		end

		Window:SetTall(y + 4)
		Window:Center()
		Window:SetVisible(true)
		Window:MakePopup()
	end
	concommand.Add("votegtopen", OpenGTVoteMenu)
end)
