CreateConVar("hud_deathnotice_time", "6", FCVAR_REPLICATED)

killicon.AddFont("prop_physics", "HL2MPTypeDeath", "9", color_white)
killicon.AddFont("prop_physics_multiplayer", "HL2MPTypeDeath", "9", color_white)
--killicon.AddFont("status_weapon_lasercannon", "HL2MPTypeDeath", ",", color_white)
killicon.Add("boxplayer", "killicon/boxplayer", color_white)

usermessage.Hook("PlayerKilledByPlayers", function(message)
	local victim = message:ReadEntity()
	local inflictor = message:ReadString()
	local attacker = message:ReadEntity()
	local attacker2 = message:ReadEntity()

	GAMEMODE:AddDeathNotice(attacker:Name().." + "..attacker2:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team())
end)

usermessage.Hook("PlayerKilledByPlayer", function(message)
	local victim = message:ReadEntity()
	local inflictor = message:ReadString()
	local attacker = message:ReadEntity()

	GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team())
end)

usermessage.Hook("PlayerKilledSelf", function(message)
	local deadguy = message:ReadEntity()

	GAMEMODE:AddDeathNotice(nil, -1, message:ReadString(), deadguy:Name(), deadguy:Team())
end)

usermessage.Hook("PlayerKilled", function(message)
	local victim = message:ReadEntity()
	local inflictor = message:ReadString()
	local attacker = "#"..message:ReadString()

	GAMEMODE:AddDeathNotice(attacker, -1, inflictor, victim:Name(), victim:Team())
end)

local Deaths = {}

function GM:AddDeathNotice(Victim, team1, Inflictor, Attacker, team2)
	local Death = {}
	Death.victim = Victim
	Death.attacker = Attacker
	Death.time = RealTime() + GetConVarNumber("hud_deathnotice_time")

	Death.left = Victim
	Death.right = Attacker
	Death.icon = Inflictor

	if team1 == -1 then Death.color1 = COLOR_RED
	else Death.color1 = team.GetColor(team1) end

	if team2 == -1 then Death.color2 = COLOR_RED
	else Death.color2 = team.GetColor(team2) end

	if Death.left == Death.right then
		Death.left = nil
		Death.icon = "suicide"
	end

	surface.SetFont("ChatFont")

	local tw2, th2 = surface.GetTextSize(Attacker)

	Death.height = th2

	if 6 < #Deaths then
		table.remove(Deaths, 1)
	end

	table.insert(Deaths, Death)
end

--local colTrans = Color(20, 20, 20, 90)
local function DrawDeath(x, y, death)
	local w, h = killicon.GetSize(death.icon)

	if death.left then
		surface.SetDrawColor(20, 20, 20, 90)
		surface.DrawRect(x - 40, y - 2, 80, death.height + 4)
		--draw.RoundedBox(8, x - 40, y - 2, 80, death.height + 4, colTrans)
		killicon.Draw(x, y, death.icon, 255)

		draw.SimpleText(death.left, "ChatFont", x - w * 0.5 - 16, y, death.color1, TEXT_ALIGN_RIGHT)
	else
		surface.SetDrawColor(20, 20, 20, 90)
		surface.DrawRect(x, y - 2, 40, death.height + 4)
		--draw.RoundedBox(8, x, y - 2, 40, death.height + 4, colTrans)
		killicon.Draw(x, y, death.icon, 255)
	end

	draw.SimpleText(death.right, "ChatFont", x + w * 0.5 + 16, y, death.color2, TEXT_ALIGN_LEFT)

	return y + h
end

function GM:DrawDeathNotice(x, y, screenscale)
	x = x * w
	y = y * ScrH()

	local done = true
	for k, Death in pairs(Deaths) do
		if RealTime() < Death.time then
			done = false

			if Death.lerp then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			else
				Death.lerp = {}
			end

			Death.lerp.x = x
			Death.lerp.y = y

			y = DrawDeath(x, y, Death)
		end
	end

	if done then
		Deaths = {}
	end
end
