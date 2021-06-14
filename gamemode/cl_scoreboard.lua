local pScoreBoardLeft
local pScoreBoardRight

local function SortByUserID(a, b)
	local afrags = a:Frags()
	local bfrags = b:Frags()
	if afrags == bfrags then
		return a:Deaths() < b:Deaths()
	end
	return bfrags < afrags
end

local Scroll = 0

local function profileopen(self, mc)
	if mc == MOUSE_LEFT then
		local player = self.Player
		if player:IsValid() then
			NDB.GeneralPlayerMenu(player, true)
		end
	end
end

local colbox = Color(40, 40, 40, 255)
local function emptypaint(self)
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), colbox)
	return true
end

function GM:ScoreboardRefresh(pScoreBoard)
	for _, element in pairs(pScoreBoard.Elements) do
		element:Remove()
	end
	pScoreBoard.Elements = {}

	local list = vgui.Create("DPanelList", pScoreBoard)
	local panw = w * 0.25 - 8
	list:SetSize(panw, pScoreBoard:GetTall() - 72)
	list:SetPos(4, 64)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSpacing(2)

	-- timer.Simple(0, list.VBar.SetScroll, list.VBar, Scroll)
	timer.Simple(0, function() list.VBar.SetScroll(list.VBar, Scroll) end) 
	pScoreBoard.PanelList = list
	table.insert(pScoreBoard.Elements, list)

	local Label = vgui.Create("DLabel", pScoreBoard)
	Label:SetText("Score")
	Label:SetTextColor(color_white)
	Label:SetFont("DefaultSmall")
	surface.SetFont("DefaultSmall")
	local tw, th = surface.GetTextSize("Score")
	Label:SetPos(panw * 0.6 - tw * 0.5 + 8, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(pScoreBoard.Elements, Label)

	local Label = vgui.Create("DLabel", pScoreBoard)
	Label:SetText("Deaths")
	Label:SetTextColor(color_white)
	Label:SetFont("DefaultSmall")
	surface.SetFont("DefaultSmall")
	local tw, th = surface.GetTextSize("Deaths")
	Label:SetPos(panw * 0.75 - tw * 0.5 + 8, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(pScoreBoard.Elements, Label)

	local Label = vgui.Create("DLabel", pScoreBoard)
	Label:SetText("Ping")
	Label:SetTextColor(color_white)
	Label:SetFont("DefaultSmall")
	surface.SetFont("DefaultSmall")
	local tw, th = surface.GetTextSize("Ping")
	Label:SetPos(panw * 0.9 + 8 - tw * 0.5, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(pScoreBoard.Elements, Label)

	local allplayers
	if pScoreBoard == pScoreBoardLeft then
		allplayers = team.GetPlayers(TEAM_GREEN)
	else
		allplayers = team.GetPlayers(TEAM_RED)
	end
	table.sort(allplayers, SortByUserID)
	for i, pl in ipairs(allplayers) do
		local Panel = vgui.Create("Panel", list)
		Panel:SetSize(panw, 40)
		Panel:SetMouseInputEnabled(true)
		--Panel:SetBGColorEx(120, 120, 120, 255)
		Panel.Player = pl
		Panel.Paint = emtptypaint
		if NDB.MemberNames then
			Panel.OnMousePressed = profileopen
		end

		if pl:IsValid() then
			local avatar = vgui.Create("AvatarImage", Panel)
			avatar:SetPos(4, 4)
			avatar:SetSize(32, 32)
			avatar:SetPlayer(pl)
			avatar:SetTooltip("Click here to view "..pl:Name().." Steam Community profile.")
		end

		local Label = vgui.Create("DLabel", Panel)
		local txt = pl:Name()
		Label:SetText(txt)
		Label:SetTextColor(team.GetColor(pl:Team()))
		Label:SetFont("Default")
		surface.SetFont("Default")
		local tw, th = surface.GetTextSize(txt)
		Label:SetPos(48, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)
		Label:SetSize(tw, th)

		local txt = pl:Frags()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("DefaultSmall")
		surface.SetFont("DefaultSmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.6 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		local txt = pl:Deaths()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("DefaultSmall")
		surface.SetFont("DefaultSmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.75 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		local txt = pl:Ping()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("DefaultSmall")
		surface.SetFont("DefaultSmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.9 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		list:AddItem(Panel)
	end
end

function GM:CreateScoreboard()
	if pScoreBoardLeft then
		pScoreBoardLeft:Remove()
		pScoreBoardLeft = nil
	end

	pScoreBoardLeft = vgui.Create("DFrame")
	pScoreBoardLeft:SetSize(w * 0.25, h * 0.7)
	pScoreBoardLeft:SetPos(8, 64)
	pScoreBoardLeft:SetVisible(true)
	pScoreBoardLeft:SetTitle(team.GetName(TEAM_GREEN))
	pScoreBoardLeft.btnClose:SetVisible(false)
	pScoreBoardLeft.NextRefresh = CurTime() + 3
	pScoreBoardLeft.Elements = {}
	local oldthink = pScoreBoardLeft.Think
	pScoreBoardLeft.Think = function(p)
		oldthink(p)

		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = pScoreBoardLeft.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	if pScoreBoardRight then
		pScoreBoardRight:Remove()
		pScoreBoardRight = nil
	end

	pScoreBoardRight = vgui.Create("DFrame")
	pScoreBoardRight:SetSize(w * 0.25, h * 0.7)
	pScoreBoardRight:SetPos(w * 0.75 - 8, 64)
	pScoreBoardRight:SetVisible(true)
	pScoreBoardRight:SetTitle(team.GetName(TEAM_RED))
	pScoreBoardRight.btnClose:SetVisible(false)
	pScoreBoardRight.NextRefresh = CurTime() + 3
	pScoreBoardRight.Elements = {}
	local oldthink = pScoreBoardRight.Think
	pScoreBoardRight.Think = function(p)
		oldthink(p)

		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = pScoreBoardRight.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	self:ScoreboardRefresh(pScoreBoardLeft)
	self:ScoreboardRefresh(pScoreBoardRight)

	if NDB.MemberNames then
		local miscPanel = vgui.Create("DFrame")
		miscPanel:SetPos(w * 0.5 - 250, h * 0.8)
		miscPanel:SetSize(500, 100)
		miscPanel:SetTitle("NoX Stuff")
		miscPanel.btnClose:SetVisible(false)
		pMiscPanel = miscPanel

		local button = vgui.Create("DButton", miscPanel)
		button:SetPos(16, 39)
		button:SetSize(72, 22)
		button:SetText("Donations")
		button.DoClick = function(btn) OpenDonationHTML() end

		local button = vgui.Create("DButton", miscPanel)
		button:SetPos(216, 39)
		button:SetSize(72, 22)
		button:SetText("Server Portal")
		button.DoClick = function(btn) RunConsoleCommand("serverportal") end

		local button = vgui.Create("DButton", miscPanel)
		button:SetPos(412, 39)
		button:SetSize(72, 22)
		button:SetText("Global Store")
		button.DoClick = function(btn) RunConsoleCommand("shopmenu") end
	end
end

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker(true)

	if not pScoreBoardLeft then
		self:CreateScoreboard()
	end

	pScoreBoardLeft:SetVisible(true)
	pScoreBoardRight:SetVisible(true)
	if NDB.MemberNames then
		pMiscPanel:SetVisible(true)
	end
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false

	if not MOUSE_VIEW then
		gui.EnableScreenClicker(false)
	end

	pScoreBoardLeft:Remove()
	pScoreBoardLeft = nil
	pScoreBoardRight:Remove()
	pScoreBoardRight = nil
	if NDB.MemberNames then
		pMiscPanel:Remove()
		pMiscPanel = nil
	end
end

function GM:HUDDrawScoreBoard()
end
