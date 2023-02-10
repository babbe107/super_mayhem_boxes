include("cl_deathnotice.lua")
include("cl_scoreboard.lua")
include("cl_crosshairs.lua")
include("cl_notice.lua")

NDB = NDB or {}

if NDB.MemberNames then
	hook.Add("NDBChatOn", "FixChatBoxOn", function()
		if pCrosshair and pCrosshair:Valid() then
			pCrosshair:SetMouseInputEnabled(false)
			pCrosshair:SetAlpha(0)
		end
	end)

	hook.Add("NDBChatOff", "FixChatBoxOff", function()
		if pCrosshair and pCrosshair:Valid() then
			pCrosshair:SetMouseInputEnabled(true)
			pCrosshair:SetAlpha(255)
		end
	end)

	function GM:PlayerVoicePitch(pl, pitch)
		return math.min(255, pitch * 1.9)
	end
else
	include("cl_votemap.lua")
	include("cl_wiki.lua")
end

-- # frame texture shown|text displayed|sound played.
GM.HelpTopics = {}
GM.HelpTopics["Basics"] = {
"6|Welcome to Mayhem Boxes, the multiplayer, 3D side-scrolling gamemode for GMod! Use the menu below and categories on the left to navigate.",
"10|Utilize the many weapons and powerups (or just jump on top of them) to defeat enemy players and lead your team to victory.",
"3|Whether it's Capture the Flag ...",
"22|... or Coin Collector, ...",
"11|... this fully-physical physics playground is easy to both pickup-and-play or master the game.|weapons/pistol/pistol_fire3.wav",
"12|Use weapons, powerups, the environment, and the laws of physics to defeat enemies.",
"13|But watch out yourself, because one wrong move could mean being reduced to splinters!|physics/wood/wood_crate_break5.wav",
"8|If you ever see a powerup or weapon ...",
"9|... simply run in to it to pick it up!|mayhem/powerup.wav",
"18|If you already have a weapon and want to get another one ...",
"19|... hold down your USE key (usually is E) and run over the new one.|mayhem/powerup.wav",
"16|Every level has different weapons and pickups.|ambient/explosions/explode_5.wav",
"14|If you don't have a weapon or just want to do it the old fashioned way ...",
"17|... you can always just jump on their heads to deal damage.|mayhem/jump.wav",
"15|Use your JUMP key to jump, stafe keys to move left and right, and your mouse to do weapon attacks. Hold TAB to view player scores and stuff.|ambient/machines/slicer4.wav"
}
PowerupDrawModels = {}
PowerupDrawScales = {}
CustomDrawFunctions = {}

include("shared.lua")

if not MySelf then
	MySelf = NULL
end
hook.Add("Think", "GetLocal", function()
	MySelf = LocalPlayer()
	if MySelf:IsValid() then
		gamemode.Call("HookGetLocal", MySelf)
		MySelf.Money = MySelf.Money or 0
		MySelf.MemberLevel = MySelf.MemberLevel or MEMBER_NONE or 0
		RunConsoleCommand("PostPlayerInitialSpawn")
		hook.Remove("Think", "GetLocal")
	end
end)

hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")

usermessage.Hook("FlagPoints", function(um)
	team.TeamInfo[TEAM_RED].FlagPoint = um:ReadVector()
	team.TeamInfo[TEAM_GREEN].FlagPoint = um:ReadVector()
	team.TeamInfo[TEAM_RED].Flag = um:ReadEntity()
	team.TeamInfo[TEAM_GREEN].Flag = um:ReadEntity()
end)

GM.Wiki = {
	{Name = "General",
		{Name = "About", Article = "Super_Mayhem_Boxes"}
	}
}

local gttab = {}
for _, gametype in pairs(GM.GameTypes) do
	gametype = GM.GameTranslates[gametype] or gametype
	table.insert(gttab, {Name = gametype, Article = string.gsub(gametype, " ", "_")})
end
gttab.Name = "Game Types"
table.insert(GM.Wiki, gttab)

local weptab = {}
for classname, weaponname in pairs(PickupTranslates) do
	if classname ~= "default" and not PICKUP_GROUPS[classname] then
		table.insert(weptab, {Name = weaponname, Article = string.gsub(weaponname, " ", "_")})
	end
end
weptab.Name = "Weapons and Powerups"
table.insert(GM.Wiki, weptab)

function GM:SpawnMenuEnabled()
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:ContextMenuOpen()
	return false
end

if NDB.MemberNames then
	function GM:AccountPaint()
		if NDB.ChatOn or GetConVarNumber("nox_accountbox_hideunlesschatting") ~= 1 then
			local wi, he = self:GetSize()
			local alpha = GetConVarNumber("nox_accountbox_transparency")
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawRect(0, 24, wi, he - 24)
			surface.SetDrawColor(15, 15, 60, alpha)
			surface.DrawRect(0, 0, wi, 24)
			surface.SetDrawColor(120, 120, 120, alpha)
			surface.DrawOutlinedRect(0, 0, wi, he)

			if not self.ChildrenShowing then
				self:SetMouseInputEnabled(false)
				self:ShowChildren(true)
			end
		elseif self.ChildrenShowing then
			self:SetMouseInputEnabled(false)
			self:ShowChildren(false)
		end
	end
end

function GM:GUIMousePressed(mc)
	if mc == MOUSE_LEFT then RunConsoleCommand("+attack")
	elseif mc == MOUSE_RIGHT then RunConsoleCommand("+attack2")
	end
end

function GM:GUIMouseReleased(mc)
	if mc == MOUSE_LEFT then RunConsoleCommand("-attack")
	elseif mc == MOUSE_RIGHT then RunConsoleCommand("-attack2")
	end
end

function BetterScreenScale()
	return ScrH() / 1200
end

COLOR_RED = Color(255, 0, 0)
COLOR_YELLOW = Color(255, 255, 0)
COLOR_ORANGE = Color(255, 200, 0)
COLOR_PINK = Color(255, 20, 100)
COLOR_GREEN = Color(0, 255, 0)
COLOR_LIMEGREEN = Color(50, 255, 50)
COLOR_PURPLE = Color(255, 0, 255)
COLOR_BLUE = Color(0, 0, 255)
COLOR_LIGHTBLUE = Color(0, 80, 255)
COLOR_CYAN = Color(0, 255, 255)
COLOR_WHITE = Color(255, 255, 255)
COLOR_BLACK = Color(0, 0, 0)

color_black_alpha90 = Color(0, 0, 0, 90)
color_black_alpha180 = Color(0, 0, 0, 180)
color_black_alpha220 = Color(0, 0, 0, 220)

function GM:Initialize()
	--timer.Simple(5, RunConsoleCommand, "requestgametype")
	timer.Simple(5, function() RunConsoleCommand("requestgametype") end) 

	self.BaseClass:Initialize()

	if not BOXENT then
		BOXENT = NULL
	end

	killicon.AddAlias("status_weapon_pistol", "weapon_pistol")

	surface.CreateFont("mayhem16", {"Trebuchet24", size = 16, 400, false, false})
	surface.CreateFont("mayhem18", {"Trebuchet24", size = 18, 400, false, false})
	surface.CreateFont("mayhem22", {"Trebuchet24", size = 22, 400, false, false})
	surface.CreateFont("mayhem26", {"Trebuchet24", size = 26, 400, false, false})
	surface.CreateFont("mayhem32", {"Trebuchet24", size = 32, 400, false, false})
	surface.CreateFont("mayhem48", {"Trebuchet24", size = 48, 400, false, false})
	surface.CreateFont("mayhem64", {"Trebuchet24", size = 64, 400, false, false})

	local crosshair = vgui.Create("CrosshairPanel")
	crosshair:SetPos(w * 0.5 - 16, h * 0.5 - 16)
	crosshair:SetSize(32, 32)
	crosshair:SetVisible(true)
	crosshair:SetCursor("blank")
	crosshair:SetMouseInputEnabled(true)
	crosshair:SetKeyboardInputEnabled(false)
	pCrosshair = crosshair
end

function GM:InitPostEntity()
end

local vec0 = Vector(0, 0, 0)
function GM:Think()
	if MySelf:IsValid() then
		if not vgui.MouseEnabled then
			gui.EnableScreenClicker(true)
		end

		if BOXENT:IsValid() then
			local ts = BOXENT:GetPos():ToScreen()
			local mx, my = gui.MousePos()
			MySelf:SetEyeAngles(Vector(0, mx - ts.x, ts.y - my):Angle())
		else
			for _, box in pairs(ents.FindByClass("boxplayer")) do
				if box:GetOwner() == MySelf then BOXENT = box end
			end
		end
	end

	for _, pl in pairs(player.GetAll()) do
		-- pl:SetModelScale(vec0)
		pl:SetModelScale(0)
	end
end

function GM:CreateMove(ucmd)
end

function GM:PlayerDeath(pl, attacker)
end

function GM:PlayerBindPress(pl, bind, down)
	return false
end

function GM:GameTypeHUDPaint()
end

w, h = ScrW(), ScrH()
function GM:HUDPaint()
	w, h = ScrW(), ScrH()

	local screenscale = math.max(0.5, BetterScreenScale())

	self:DrawBasicHUD(screenscale)
	self:DrawGameModeHUD(screenscale)
	self:GameTypeHUDPaint(screenscale)
	self:DrawDeathNotice(0.5, 0.08, screenscale)
	self:PaintNotes(screenscale)

	if MySelf:IsValid() then
		local box = MySelf:GetBox()
		if box:IsValid() then
			local wep = box.Weapon
			if wep:IsValid() then
				local wepclass = string.gsub(wep:GetClass(), "status_", "")

				draw.DrawTextShadow(PickupTranslates[wepclass] or wepclass, "mayhem32", w * 0.5, h - 100, color_white, color_black, TEXT_ALIGN_CENTER)
				surface.SetFont("mayhem32")
				local texw, texh = surface.GetTextSize("BIGTEXT")
				draw.DrawTextShadow("(Hold down USE while running over another weapon to swap them)", "Default", w * 0.5, texh + h - 100, color_white, color_black, TEXT_ALIGN_CENTER)
			end
		end
	end
end

function GM:DrawTime(screenscale)
	draw.DrawTextShadow(ToMinutesSeconds(math.max(0, self.RoundTime - CurTime())), "mayhem26", w * 0.5, 36, color_white, color_black, TEXT_ALIGN_CENTER)
end

function GM:DrawGameModeHUD(screenscale)
	draw.RoundedBox(8, w * 0.5 - 128, 0, 256, 70, color_black_alpha180)

	draw.DrawText(self.GameTranslates[self.GameType] or self.GameType or "-", "mayhem26", w * 0.5, 8, color_white, TEXT_ALIGN_CENTER)
	gamemode.Call("DrawTime", screenscale)

	draw.RoundedBox(8, w * 0.25 - 64, 0, 128, 58, color_black_alpha180)
	draw.DrawText(team.GetName(TEAM_GREEN), "mayhem22", w * 0.25, 8, team.GetColor(TEAM_GREEN), TEXT_ALIGN_CENTER)
	draw.DrawText(team.GetScore(TEAM_GREEN), "mayhem18", w * 0.25, 32, team.GetColor(TEAM_GREEN), TEXT_ALIGN_CENTER)

	draw.RoundedBox(8, w * 0.75 - 64, 0, 128, 58, color_black_alpha180)
	draw.DrawText(team.GetName(TEAM_RED), "mayhem22", w * 0.75, 8, team.GetColor(TEAM_RED), TEXT_ALIGN_CENTER)
	draw.DrawText(team.GetScore(TEAM_RED), "mayhem18", w * 0.75, 32, team.GetColor(TEAM_RED), TEXT_ALIGN_CENTER)

	--[[draw.DrawTextShadow(team.GetName(TEAM_GREEN).." - "..team.GetScore(TEAM_GREEN), "mayhem48", 8, 8, team.GetColor(TEAM_GREEN), color_black, TEXT_ALIGN_LEFT)
	draw.DrawTextShadow(team.GetScore(TEAM_RED).." - "..team.GetName(TEAM_RED), "mayhem48", w - 8, 8, team.GetColor(TEAM_RED), color_black, TEXT_ALIGN_RIGHT)]]
end

function GM:CallScreenClickHook(down, mousecode, aimvec)
end

function GM:ShutDown()
end

function GM:RenderScreenspaceEffects()
end

function GM:GetTeamColor(ent)
	local teamid = TEAM_UNASSIGNED
	if ent.Team then teamid = ent:Team() end
	return team.GetColor(teamid)
end

function GM:AdjustMouseSensitivity(fDefault)
	return -1
end

function GM:ForceDermaSkin()
end

local texGradientDown = surface.GetTextureID("gui/gradient_down")
function GM:DrawBasicHUD()
	for _, pl in pairs(player.GetAll()) do
		local box = pl:GetBox()
		if box:IsValid() then
			local tpos = (box:GetPos() - Vector(0, 0, 32)):ToScreen()
			if tpos.visible then
				local x, y = tpos.x, tpos.y
				local col = team.GetColor(pl:Team())
				draw.DrawTextShadow(pl:Name(), "Default", x, y, col, color_black, TEXT_ALIGN_CENTER)
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(x - 32, y + 20, 64, 12)
				surface.SetDrawColor(col.r, col.g, col.b, 200)
				surface.DrawOutlinedRect(x - 32, y + 20, 64, 12)
				local barwid = 0.64 * pl:Health()
				surface.SetTexture(texGradientDown)
				surface.DrawTexturedRect(x - 32, y + 20, barwid, 12)
				surface.SetDrawColor(col.r, col.g, col.b, 20)
				surface.DrawRect(x - 32, y + 20, barwid, 12)

				local wep = box.Weapon
				if box == BOXENT and wep.HUD then
					wep:HUD(pl, box, x, y)
				end
			end
		end
	end
end

usermessage.Hook("EndG", function(um)
	local winner = um:ReadShort()
	END_GAME = true
	NEXT_MAP = CurTime() + 30
	if 0 < winner then
		GAMEMODE:AddNotify(team.GetName(winner).." has won the match!", team.GetColor(winner), 60)
	else
		GAMEMODE:AddNotify("The match ended in a tie.", nil, 60)
	end

	if MySelf:Team() == winner then
		surface.PlaySound("mayhem/roundwin.wav")
	else
		surface.PlaySound("mayhem/gameover.wav")
	end

	GAMEMODE.Whiteness = 8
	function GAMEMODE:HUDPaint() end
	function GAMEMODE:HUDPaintBackground()
		self.Whiteness = math.min(255, self.Whiteness + FrameTime() * self.Whiteness)
		surface.SetDrawColor(0, 0, 0, self.Whiteness)
		surface.DrawRect(0, 0, w, h)
		if CurTime() <= NEXT_MAP then
			draw.RoundedBox(16, w*0.45, h*0.8, w*0.1, h*0.05, color_black)
			draw.SimpleText("Next Map: "..ToMinutesSeconds(NEXT_MAP - CurTime()), "Default", w*0.5, h*0.825, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.RoundedBox(16, w*0.45, h*0.8, w*0.1, h*0.05, color_black)
			draw.SimpleText("Loading...", "Default", w*0.5, h*0.825, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)

local viewpos = Vector(0, 0, 0)
local viewang = Angle(0, 0, 0)
local camdist = 400

hook.Add("CalcView", "GetCamDist", function(pl, _origin, _angles, _fov)
	if BOXENT:IsValid() then
		local pos = BOXENT:GetPos()
		viewpos = pos + Vector(camdist, 0, camdist * 0.213333)

		if util.TraceLine({start = viewpos, endpos = viewpos + Vector(FrameTime() * 240, 0, 0), mask = MASK_SOLID_BRUSHONLY}).Hit then
			hook.Remove("CalcView", "GetCamDist")
		else
			camdist = math.min(780, camdist + FrameTime() * 240)
			if camdist == 780 then hook.Remove("CalcView", "GetCamDist") end
		end
	end
end)

function GM:CalcView(pl, _origin, _angles, _fov)
	if BOXENT:IsValid() then
		local pos = BOXENT:GetPos()
		viewpos = pos + Vector(camdist, 0, camdist * 0.213333)
		viewang = (pos - viewpos):Angle()

		if pl:KeyDown(IN_SPEED) then
			if pl:KeyDown(IN_FORWARD) then
				if not util.TraceLine({start=viewpos, endpos = viewpos + Vector(FrameTime() * -240, 0, 0), mask = MASK_SOLID_BRUSHONLY}).Hit then
					camdist = math.max(100, camdist - FrameTime() * 240)
				end
			elseif pl:KeyDown(IN_BACK) then
				if not util.TraceLine({start=viewpos, endpos = viewpos + Vector(FrameTime() * 240, 0, 0), mask = MASK_SOLID_BRUSHONLY}).Hit then
					camdist = math.min(780, camdist + FrameTime() * 240)
				end
			end
		end
	end

	if SCREENSHAKEDURATION and CurTime() < SCREENSHAKEDURATION then
		viewang.roll = math.sin(RealTime() * SCREENSHAKEFREQ) * SCREENSHAKEAMP * (SCREENSHAKEDURATION - CurTime())
	end

	return {origin = viewpos, angles = viewang}
end

SCREENSHAKEDURATION = -1
SCREENSHAKEFREQ = 0
SCREENSHAKEAMP = 0
usermessage.Hook("screenshake", function(um)
	SCREENSHAKEDURATION = math.max(SCREENSHAKEDURATION, CurTime() + um:ReadFloat())
	SCREENSHAKEFREQ = math.max(SCREENSHAKEFREQ, um:ReadFloat())
	SCREENSHAKEAMP = math.max(SCREENSHAKEAMP, um:ReadFloat())
end)

function GM:HUDPaintBackground()
end

local dontdraw = {}
dontdraw["CHudHealth"] = true
dontdraw["CHudBattery"] = true
dontdraw["CHudCrosshair"] = true
dontdraw["CHudDamageIndicator"] = true
function GM:HUDShouldDraw(name)
	return not dontdraw[name]
end

local mayhemhelped = CreateClientConVar("mayhem_helped", 0, true, false)
hook.Add("Initialize", "mayhemhelp", function()
	if not mayhemhelped:GetBool() then
		MakepHelp()
	end
end)

local colDark = Color(40, 60, 40, 255)
local function MessageBoxPaint(p)
	draw.RoundedBox(8, 0, 0, p:GetWide(), p:GetTall(), colDark)

	return true
end

function MakepCredits()
	if pCredits then
		pCredits:SetVisible(true)
		pCredits:MakePopup()
		return
	end

	local wid, hei = math.min(ScrW() - 16, 600), math.min(ScrH() - 16, 400)

	local frame = vgui.Create("DFrame")
	frame:SetSize(wid, hei)
	frame:SetTitle("Server's Installed Packs")
	frame:SetDeleteOnClose(false)
	pCredits = frame

	local ctrl = vgui.Create("DListView", frame)
	ctrl:SetSize(wid - 16, hei - 32)
	ctrl:SetPos(8, 24)
	ctrl:AddColumn("Pack")
	ctrl:AddColumn("Author")
	ctrl:AddColumn("Description"):SetMinWidth(wid * 0.5)
	for packname, packtab in pairs(GAMEMODE.Packs) do
		local name = tostring(packtab.Name)
		if packtab.Version then
			name = name.." v"..packtab.Version
		end
		ctrl:AddLine(name, packtab.Author or "Unknown", packtab.Description or "N/A")
	end

	frame:Center()
	frame:SetVisible(true)
	frame:MakePopup()
end

function MakepHelp(category, page)
	category = category or "Basics"
	page = page or 1

	if not GAMEMODE.HelpTopics[category] then
		print("MakepHelp tried to open a category that didn't exist: "..tostring(category))
		return
	end

	RunConsoleCommand("mayhem_helped", "1")

	if pHelp then
		if pHelp:Valid() then
			pHelp:Remove()
		end
		pHelp = nil
	end

	local Window = vgui.Create("DFrame")
	local tall = math.min(600, h)
	local wide = math.min(800, w)
	Window:SetSize(wide, tall)
	Window:Center()
	Window:SetTitle(" ")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:MakePopup()
	Window:SetDeleteOnClose(false)
	Window:SetKeyboardInputEnabled(false)
	Window:SetCursor("pointer")
	Window.Paint = function(frr)
		draw.RoundedBox(8, 0, 0, frr:GetWide(), frr:GetTall(), color_black)
		return true
	end
	pHelp = Window

	local label = EasyLabel(Window, "Quick Help: "..tostring(category), "Default", color_white)
	label:SetPos(wide * 0.5 - label:GetWide() * 0.5, 4)

	local text = GAMEMODE.HelpTopics[category][page]
	if text then
		local expl = string.Explode("|", text)
		if expl[2] then
			local iconnum = expl[1]

			local Control = vgui.Create("DImage", Window)
			Control:SetImage("mayhem/help"..iconnum)
			Control:SetPos(wide * 0.5 - 256, 64)
			Control:SetSize(512, 512)
			Control.OldPaint = Control.Paint
			Control.Paint = function(ct)
				ct:OldPaint()
				surface.SetDrawColor(30, 255, 30, 255)
				surface.DrawOutlinedRect(0, 0, ct:GetWide(), ct:GetTall())
			end

			text = expl[2]

			if expl[3] then
				surface.PlaySound(expl[3])
			end
		end

		surface.SetFont("Default")
		local texw, texh = surface.GetTextSize(text)

		local dpan = vgui.Create("DPanel", Window)
		dpan:SetSize(texw + 10, texh + 6)
		dpan:SetPos(wide * 0.5 - dpan:GetWide() * 0.5, 32)
		dpan.Paint = MessageBoxPaint

		local label = vgui.Create("DLabel", dpan)
		label:SetFont("Default")
		label:SetTextColor(COLOR_LIMEGREEN)
		label:SetText(text)
		label:SetPos(5, 3)
		label:SetSize(texw, texh)
	else
		print("MakepHelp tried to view a page that didn't exist in category \""..tostring(category).."\": "..tostring(page))
	end

	local button = vgui.Create("DButton", Window)
	button:SetText("Close")
	button:SizeToContents()
	button:SetWide(button:GetWide() + 16)
	button:SetTall(button:GetTall() + 8)
	button:SetPos(wide * 0.5 - button:GetWide() * 0.5, tall - 8 - button:GetTall())
	button.DoClick = function(btn)
		btn:GetParent():SetVisible(false)
		MySelf:ChatPrint("You can view help anytime by pressing your gamemode help button. This is F1 by default.")
	end

	if GAMEMODE.HelpTopics[category][page - 1] then
		local button = vgui.Create("DButton", Window)
		button:SetText("<- Previous page")
		button:SizeToContents()
		button:SetWide(button:GetWide() + 16)
		button:SetTall(button:GetTall() + 8)
		button:SetPos(wide * 0.25 - button:GetWide() * 0.5, tall - 8 - button:GetTall())
		button.DoClick = function()
			MakepHelp(category, page - 1)
		end
	end

	if GAMEMODE.HelpTopics[category][page + 1] then
		local button = vgui.Create("DButton", Window)
		button:SetText("Next page ->")
		button:SizeToContents()
		button:SetWide(button:GetWide() + 16)
		button:SetTall(button:GetTall() + 8)
		button:SetPos(wide * 0.75 - button:GetWide() * 0.5, tall - 8 - button:GetTall())
		button.DoClick = function()
			MakepHelp(category, page + 1)
		end
	end

	local y = 64
	for categoryname in pairs(GAMEMODE.HelpTopics) do
		local button = vgui.Create("DButton", Window)
		button:SetText(categoryname)
		button:SizeToContents()
		button:SetWide(button:GetWide() + 16)
		button:SetTall(button:GetTall() + 8)
		button:SetPos(8, y)
		button.DoClick = function()
			MakepHelp(categoryname, 1)
		end

		y = y + button:GetTall() + 4
	end

	y = y + 48
	local button = EasyButton(Window, "In-game Wiki", 8, 4)
	button:SetPos(8, y)
	button.DoClick = function() NDB.OpenWiki() end

	local labb = EasyLabel(Window, "by William \"JetBoom\" Moodhe", nil, color_white)
	labb:SetPos(8, tall - labb:GetTall() - 8)
end

function draw.DrawTextShadow(text, font, x, y, color, shadowcolor, xalign)
	local tw, th = 0, 0
	surface.SetFont(font)

	if xalign == TEXT_ALIGN_CENTER then
		tw, th = surface.GetTextSize(text)
		x = x - tw * 0.5
	elseif xalign == TEXT_ALIGN_RIGHT then
		tw, th = surface.GetTextSize(text)
		x = x - tw
	end

	surface.SetTextColor(shadowcolor.r, shadowcolor.g, shadowcolor.b, shadowcolor.a or 255)
	surface.SetTextPos(x+1, y+1)
	surface.DrawText(text)
	surface.SetTextPos(x-1, y-1)
	surface.DrawText(text)
	surface.SetTextPos(x+1, y-1)
	surface.DrawText(text)
	surface.SetTextPos(x-1, y+1)
	surface.DrawText(text)

	if color then
		surface.SetTextColor(color.r, color.g, color.b, color.a or 255)
	end

	surface.SetTextPos(x, y)
	surface.DrawText(text)

	return tw, th
end

function draw.SimpleTextShadow(text, font, x, y, color, shadowcolor, xalign, yalign)
	font 	= font 		or "Default"
	x 		= x 		or 0
	y 		= y 		or 0
	xalign 	= xalign 	or TEXT_ALIGN_LEFT
	yalign 	= yalign 	or TEXT_ALIGN_TOP
	local tw, th = 0, 0
	surface.SetFont(font)
	
	if xalign == TEXT_ALIGN_CENTER then
		tw, th = surface.GetTextSize(text)
		x = x - tw*0.5
	elseif xalign == TEXT_ALIGN_RIGHT then
		tw, th = surface.GetTextSize(text)
		x = x - tw
	end
	
	if yalign == TEXT_ALIGN_CENTER then
		tw, th = surface.GetTextSize(text)
		y = y - th*0.5
	end

	surface.SetTextColor(shadowcolor.r, shadowcolor.g, shadowcolor.b, shadowcolor.a or 255)
	surface.SetTextPos(x+1, y+1)
	surface.DrawText(text)
	surface.SetTextPos(x-1, y-1)
	surface.DrawText(text)
	surface.SetTextPos(x+1, y-1)
	surface.DrawText(text)
	surface.SetTextPos(x-1, y+1)
	surface.DrawText(text)

	if color then
		surface.SetTextColor(color.r, color.g, color.b, color.a or 255)
	else
		surface.SetTextColor(255, 255, 255, 255)
	end

	surface.SetTextPos(x, y)
	surface.DrawText(text)

	return tw, th
end

function WordBox(parent, text, font, textcolor)
	local cpanel = vgui.Create("DPanel", parent)
	local label = EasyLabel(cpanel, text, font, textcolor)
	local tsizex, tsizey = label:GetSize()
	cpanel:SetSize(tsizex + 16, tsizey + 8)
	label:SetPos(8, (tsizey + 8) * 0.5 - tsizey * 0.5)
	cpanel:SetVisible(true)
	cpanel:SetMouseInputEnabled(false)
	cpanel:SetKeyboardInputEnabled(false)

	return cpanel
end

function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "Default")
	end
	dpanel:SetText(text)
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end
