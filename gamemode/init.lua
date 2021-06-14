AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("obj_entity_extend.lua")
AddCSLuaFile("2dnoxteams.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_crosshairs.lua")
AddCSLuaFile("cl_notice.lua")

NDB = NDB or {}

if NDB.MemberNames then
	include("shared.lua")
else
	AddCSLuaFile("maplist.lua")
	AddCSLuaFile("cl_votemap.lua")
	AddCSLuaFile("cl_wiki.lua")

	include("shared.lua")
	include("votemap.lua")

	function game.GetMapNext()
		return GAMEMODE.NEXT_MAP or game.GetMap()
	end

	function game.LoadNextMap()
		local nextmap = game.GetMapNext()
		print("Next map: "..nextmap)
		if not file.Exists("maps/"..nextmap..".bsp", "GAME") then
			nextmap = game.GetMap()
		end
		print("Next map: "..nextmap)
		timer.Simple(0.1, function() RunConsoleCommand("changelevel", nextmap) end) 
	end
end

-- TODO: Fix box going flying after capping a flag.
-- TODO: HUD sucks.
-- TODO: Do something about the VGUI mouse aiming thing.
-- TODO: Replace the death sound since it's just mumbled garbage after that one update.
-- TOTEST: Simple vote map system.

function gmod.BroadcastLua(lua)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(lua)
	end
end

function GM:GameTypeThink()
end

function GM:ShowHelp(pl)
	pl:SendLua("MakepHelp()")
end

function GM:ShowSpare1(pl)
	pl:SendLua("MakepCredits()")
end

local AlreadyLost = {}

function GM:Initialize()
	timer.Destroy("HostnameThink")

	-- Is there a workaround?
	-- RunConsoleCommand("mp_flashlight", 0)

	resource.AddFile("materials/killicon/boxplayer.vtf")
	resource.AddFile("materials/killicon/boxplayer.vmt")
	resource.AddFile("materials/killicon/env_explosion_killicon.vtf")
	resource.AddFile("materials/killicon/env_explosion_killicon.vmt")
	resource.AddFile("materials/killicon/env_fire_killicon.vtf")
	resource.AddFile("materials/killicon/env_fire_killicon.vmt")

	resource.AddFile("materials/noxctf/flagicon_home.vmt")
	resource.AddFile("materials/noxctf/flagicon_home.vtf")
	resource.AddFile("materials/noxctf/flagicon_dropped.vmt")
	resource.AddFile("materials/noxctf/flagicon_dropped.vtf")
	resource.AddFile("materials/noxctf/flagicon_field.vmt")
	resource.AddFile("materials/noxctf/flagicon_field.vtf")

	resource.AddFile("sound/nox/missilesofmagic.wav")

	for _, filename in pairs(file.Find("materials/mayhem/*.vmt", "GAME")) do
		resource.AddFile("materials/mayhem/"..filename)
	end

	for _, filename in pairs(file.Find("sound/mayhem/*.wav", "GAME")) do
		resource.AddFile("sound/mayhem/"..filename)
		util.PrecacheSound("mayhem/"..filename)
	end
	for _, filename in pairs(file.Find("sound/mayhem/*.mp3", "GAME")) do
		resource.AddFile("sound/mayhem/"..filename)
		util.PrecacheSound("mayhem/"..filename)
	end
	for _, filename in pairs(file.Find("materials/mixerman3d/weapons/*.*", "GAME")) do
		resource.AddFile("materials/mixerman3d/weapons/"..filename)
	end
	for _, filename in pairs(file.Find("models/mixerman3d/weapons/*.*", "GAME")) do
		resource.AddFile("models/mixerman3d/weapons/"..filename)
	end
	for _, filename in pairs(file.Find("models/peanut/*.*", "GAME")) do
		resource.AddFile("models/peanut/"..filename)
	end
	for _, filename in pairs(file.Find("materials/peanut/*.*", "GAME")) do
		resource.AddFile("materials/peanut/"..filename)
	end

	resource.AddFile("resource/fonts/supermayhemboxes.ttf")
end

function GM:PlayerDeathThink(pl)
	if pl.NextSpawnTime <= CurTime() and pl:KeyDown(IN_ATTACK) then
		pl:Spawn()
	end
end

function GM:OnDamagedByExplosion(pl, dmginfo)
end

function GM:OnBoxRemoved(box)
end

function GM:OnBoxCreated(box, owner)
end

function GM:InitPostEntity()
	MapEditorEntities = {}
	file.CreateDir("supermayhemboxesmaps")
	if file.Exists("supermayhemboxesmaps/"..game.GetMap()..".txt", "GAME") then
		for _, enttab in pairs(Deserialize(file.Read("supermayhemboxesmaps/"..game.GetMap()..".txt", "GAME"))) do
			local ent = ents.Create(string.lower(enttab.Class))
			if ent:IsValid() then
				ent:SetPos(enttab.Position)
				ent:SetAngles(enttab.Angles)
				if enttab.KeyValues then
					for key, value in pairs(enttab.KeyValues) do
						ent[key] = value
					end
				end
				ent:Spawn()
				table.insert(MapEditorEntities, ent)
			end
		end
	end

	if file.Exists(GAMEMODE_NAME.."_gametype.txt", "DATA") then
		local gt = file.Read(GAMEMODE_NAME.."_gametype.txt", "DATA")

		if self[gt.."Initialize"] then
			self[gt.."Initialize"](self)
		end
	elseif self.CTFInitialize then
		self:CTFInitialize()
	else
		local gt = self.GameTypes[1]
		if gt then
			self[gt.."Initialize"](self)
			print("Using gametype "..gt)
		else
			ErrorNoHalt("NO GAMETYPES FOUND!?")
		end
	end

	self.Spawns = {}
	self.Spawns[TEAM_RED] = ents.FindByClass("info_player_red")
	self.Spawns[TEAM_RED] = table.Add(self.Spawns[TEAM_RED], ents.FindByClass("info_player_mayhem"))
	self.Spawns[TEAM_GREEN] = ents.FindByClass("info_player_green")
	self.Spawns[TEAM_GREEN] = table.Add(self.Spawns[TEAM_GREEN], ents.FindByClass("info_player_green"))

	for _, ent in pairs(ents.FindByClass("redflagpoint")) do
		team.TeamInfo[TEAM_RED].FlagPoint = ent:GetPos()
	end
	for _, ent in pairs(ents.FindByClass("info_flag_mayhem")) do
		team.TeamInfo[TEAM_RED].FlagPoint = ent:GetPos()
	end
	for _, ent in pairs(ents.FindByClass("greenflagpoint")) do
		team.TeamInfo[TEAM_GREEN].FlagPoint = ent:GetPos()
	end
	for _, ent in pairs(ents.FindByClass("info_flag_green")) do
		team.TeamInfo[TEAM_GREEN].FlagPoint = ent:GetPos()
	end

	if self.FlagEntity then
		local ent = ents.Create(self.FlagEntity)
		--print(self.FlagEntity)
		--print(team.TeamInfo[TEAM_RED].FlagPoint)
		--print(ent)
		ent:SetPos(team.TeamInfo[TEAM_RED].FlagPoint)
		ent.Team = TEAM_RED
		ent:Spawn()
		team.TeamInfo[TEAM_RED].Flag = ent

		local ent = ents.Create(self.FlagEntity)
		ent:SetPos(team.TeamInfo[TEAM_GREEN].FlagPoint)
		ent.Team = TEAM_GREEN
		ent:Spawn()
		team.TeamInfo[TEAM_GREEN].Flag = ent
	end

	if self.StartScore then
		team.SetScore(TEAM_GREEN, self.StartScore)
		team.SetScore(TEAM_RED, self.StartScore)
	end

	if NDB.MemberNames then
		RunConsoleCommand("sv_voiceenable", 1)
		RunConsoleCommand("sv_alltalk", 0)
	end
end

concommand.Add("mapeditor_add", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	if not arguments[1] then return end

	local tr = sender:TraceLine(3000)
	if tr.Hit then
		local ent = ents.Create(string.lower(arguments[1]))
		if ent:IsValid() then
			ent:SetPos(tr.HitPos)
			ent:Spawn()
			table.insert(MapEditorEntities, ent)
			SaveMapEditorFile()
		end
	end
end)

concommand.Add("mapeditor_addonme", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	if not arguments[1] then return end

	local ent = ents.Create(string.lower(arguments[1]))
	if ent:IsValid() then
		ent:SetPos(sender:EyePos())
		ent:Spawn()
		table.insert(MapEditorEntities, ent)
		SaveMapEditorFile()
	end
end)

concommand.Add("mapeditor_remove", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:TraceLine(3000)
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(MapEditorEntities) do
			if ent == tr.Entity then
				table.remove(MapEditorEntities, i)
				ent:Remove()
			end
		end
		SaveMapEditorFile()
	end
end)

local function ME_Pickup(pl, ent, uid)
	if pl:IsValid() and ent:IsValid() then
		ent:SetPos(util.TraceLine({start=pl:GetShootPos(),endpos=pl:GetShootPos() + pl:GetAimVector() * 3000, filter={pl, ent}}).HitPos)
		return
	end
	timer.Destroy(uid.."mapeditorpickup")
	SaveMapEditorFile()
end

concommand.Add("mapeditor_pickup", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:TraceLine(3000)
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(MapEditorEntities) do
			if ent == tr.Entity then
				timer.Create(sender:UniqueID().."mapeditorpickup", 0.25, 0, ME_Pickup, sender, ent, sender:UniqueID())
			end
		end
	end
end)

concommand.Add("mapeditor_drop", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	timer.Destroy(sender:UniqueID().."mapeditorpickup")
	SaveMapEditorFile()
end)

function SaveMapEditorFile()
	local sav = {}
	for _, ent in pairs(MapEditorEntities) do
		if ent:IsValid() then
			local enttab = {}
			enttab.Class = ent:GetClass()
			enttab.Position = ent:GetPos()
			enttab.Angles = ent:GetAngles()
			if ent.KeyValues then
				enttab.KeyValues = {}
				for _, key in pairs(ent.KeyValues) do
					enttab.KeyValues[key] = ent[key]
				end
			end
			table.insert(sav, enttab)
		end
	end
	file.Write("noxctf2dmaps/"..game.GetMap()..".txt", Serialize(sav))
end

function GM:TimeUp()
	local greenscore = team.GetScore(TEAM_GREEN)
	local redscore = team.GetScore(TEAM_RED)
	if greenscore == redscore then
		gamemode.Call("EndGame", 0)
	elseif redscore < greenscore then
		gamemode.Call("EndGame", TEAM_GREEN)
	else
		gamemode.Call("EndGame", TEAM_RED)
	end
end

function GM:Think()
	if self.RoundTime <= CurTime() then
		gamemode.Call("TimeUp")
	end

	self:GameTypeThink()
end

function GM:ShutDown()
end

function GM:PlayerInitialSpawn(pl)
	pl:SetModel("models/player/kleiner.mdl")

	pl.JoinTime = CurTime()

	local onred = 0
	local ongreen = 0
	for _, pl in pairs(player.GetAll()) do
		local plteam = pl:Team()
		if plteam == TEAM_RED then
			onred = onred + 1
		elseif plteam == TEAM_GREEN then
			ongreen = ongreen + 1
		end
	end

	if onred == ongreen then
		math.randomseed(SysTime())
		pl:SetTeam(math.random(TEAM_RED, TEAM_GREEN))
	elseif onred < ongreen then
		pl:SetTeam(TEAM_RED)
	else
		pl:SetTeam(TEAM_GREEN)
	end
end

function GM:PlayerLoadout()
end

function GM:PlayerSpawn(pl)
	pl.LastAttacker = NULL
	pl.LastAttacked = 0

	local ent = ents.Create("boxplayer")
	if ent:IsValid() then
		ent:SetPos(pl:GetPos())
		ent:SetOwner(pl)
		ent:Spawn()
		pl:SetBox(ent)
		local col = team.GetColor(pl:Team())
		--print("Team color")
		--print(col)
		-- ent:SetColor(col.r, col.g, col.b, 255)
		ent:SetColor(col)
		pl:SetGroundEntity(NULL)
		pl:SetGravity(0)
		pl:SetMoveType(MOVETYPE_NONE)
		pl:SetCollisionGroup(COLLISION_GROUP_WORLD)

		gamemode.Call("OnBoxCreated", ent, pl)
	else
		print("Warning - couldn't create boxplayer for player: "..tostring(pl))
	end

	pl:SetMoveType(MOVETYPE_NONE)
end

function GM:PlayerReady(pl)
	if pl:IsValid() then
--		umsg.Start("FlagPoints", pl)
--			umsg.Vector(team.TeamInfo[TEAM_RED].FlagPoint)
--			umsg.Vector(team.TeamInfo[TEAM_GREEN].FlagPoint)
--			umsg.Entity(team.TeamInfo[TEAM_RED].Flag)
--			umsg.Entity(team.TeamInfo[TEAM_GREEN].Flag)
--		umsg.End()
        util.AddNetworkString("FlagPoints")
		net.Start("FlagPoints")
			net.WriteVector(team.TeamInfo[TEAM_RED].FlagPoint)
			net.WriteVector(team.TeamInfo[TEAM_GREEN].FlagPoint)
			net.WriteEntity(team.TeamInfo[TEAM_RED].Flag)
			net.WriteEntity(team.TeamInfo[TEAM_GREEN].Flag)
		net.Send(pl)
	end
end

function GM:EndGame(winner)
	if ENDGAME then return end

	NEXTMAP = CurTime() + 30
	ENDGAME = true

	hook.Add("Think", "NextMapChecker", function()
		if NEXTMAP <= CurTime() then
			game.LoadNextMap()
			hook.Remove("Think", "NextMapChecker")
		end
	end)

	-- timer.Simple(5, gmod.BroadcastLua, "OpenVoteMenu()")
	-- timer.Simple(20, gmod.BroadcastLua, "OpenGTVoteMenu()")
	timer.Simple(5, function() gmod.BroadcastLua("OpenVoteMenu()") end) 
	timer.Simple(20, function() gmod.BroadcastLua("OpenGTVoteMenu()") end) 
	VOTEMAPOVER = CurTime() + 20

	local allplayers = player.GetAll()
	local playercount = #allplayers

	if 0 < winner and 2 <= playercount then
		for _, pl in pairs(allplayers) do
			local steamid = pl:SteamID()
			if pl:Team() == winner then
				if NDB.MemberNames then
					pl:AddMoney(2000)
					pl.MayhemBoxesWins = pl.MayhemBoxesWins + 1
					pl:PrintMessage(HUD_PRINTTALK, "You and your team members have won the round! You have been given 2000 Silver! Personal wins / losses: "..pl.MayhemBoxesWins.." / "..pl.MayhemBoxesLosses)
				else
					pl:PrintMessage(HUD_PRINTTALK, "You and your team members have won the round!")
				end
			elseif pl:Team() ~= TEAM_SPECTATE then
				if NDB.MemberNames then
					pl:AddMoney(250)
					if not AlreadyLost[pl:SteamID()] then
						pl.MayhemBoxesLosses = pl.MayhemBoxesLosses + 1
						AlreadyLost[pl:SteamID()] = true
					end
					pl:PrintMessage(HUD_PRINTTALK, "You and your team members have lost the round. You have been given 250 Silver. Personal wins / losses: "..pl.MayhemBoxesWins.." / "..pl.MayhemBoxesLosses)
				else
					pl:PrintMessage(HUD_PRINTTALK, "You and your team members have lost the round.")
				end
			end
		end
	else
		for _, pl in pairs(allplayers) do
			if NDB.MemberNames and 2 <= playercount then
				pl:AddMoney(250)
				pl:PrintMessage(HUD_PRINTTALK, "The game ended in a tie. You have been given 250 Silver. Personal wins / losses: "..pl.MayhemBoxesWins.." / "..pl.MayhemBoxesLosses)
			else
				pl:PrintMessage(HUD_PRINTTALK, "The game ended in a tie.")
			end
		end
	end

	for _, pl in pairs(allplayers) do
		pl:Freeze(true)
		pl:GodEnable()
	end

	util.AddNetworkString("EndG")
	net.Start("EndG")
		net.WriteInt(winner, 16)
	net.Broadcast()

	if NDB.MemberNames then
		NDB.GlobalSave()
	end

	hook.Add("PlayerSpawn", "FREEZENEW", function(p) p:Freeze(true) p:GodEnable() end)
end

concommand.Add("PostPlayerInitialSpawn", function(sender, command, arguments)
	if not sender.PostPlayerInitialSpawn then
		sender.PostPlayerInitialSpawn = true

		gamemode.Call("PlayerReady", sender)
	end
end)

function GM:SetPlayerAnimation(pl, anim)
end

function GM:PlayerSelectSpawn(pl)
	local tab = self.Spawns[pl:Team()]
	local Count = #tab
	if Count == 0 then return pl end
	local ChosenSpawnPoint = tab[1]
	for i=0, 20 do
		ChosenSpawnPoint = tab[math.random(1, Count)]
		if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() then
			local blocked = false
			for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-48, -48, -48), ChosenSpawnPoint:GetPos() + Vector(48, 48, 48))) do
				if ent:GetClass() == "boxplayer" then
					blocked = true
				end
			end
			if not blocked then
				return ChosenSpawnPoint
			end
		end
	end

	return ChosenSpawnPoint
end

function GM:PlayerDeathSound(pl)
	return true
end

function GM:PlayerDeath(Victim, Inflictor, Attacker)
end

function GM:PlayerDeath2(Victim, Inflictor, Attacker)
	if Inflictor == Attacker and Inflictor:IsPlayer() and Inflictor.Weapon then
		Inflictor = Inflictor.Weapon
	end

	if Attacker == Victim then
		gamemode.Call("PlayerKilledBySelf", Victim, Inflictor)
	elseif Attacker:IsPlayer() then
		gamemode.Call("PlayerKilledByPlayer", Victim, Attacker, Inflictor)
	else
		gamemode.Call("PlayerKilledByWorld", Victim, Attacker, Inflictor)
	end
end

function GM:PlayerKilledByPlayer(victim, attacker, inflictor)
	util.AddNetworkString("PlayerKilledByPlayer")
	net.Start("PlayerKilledByPlayer")
		net.WriteEntity(victim)
		net.WriteString(inflictor:GetClass())
		net.WriteEntity(attacker)
	net.Broadcast()
end

function GM:PlayerKilledBySelf(victim, inflictor)
	-- umsg.Start("PlayerKilledSelf")
	-- 	umsg.Entity(victim)
	-- 	umsg.String(inflictor:GetClass())
	-- umsg.End()
	util.AddNetworkString("PlayerKilledSelf")
	net.Start("PlayerKilledSelf")
		net.WriteEntity(victim)
		net.WriteString(inflictor:GetClass())
	net.Broadcast()
end

function GM:PlayerKilledByWorld(victim, attacker, inflictor)
	-- umsg.Start("PlayerKilled")
	-- 	umsg.Entity(victim)
	-- 	umsg.String(inflictor:GetClass())
	-- 	umsg.String(attacker:GetClass())
	-- umsg.End()
	util.AddNetworkString("PlayerKilled")
	net.Start("PlayerKilled")
		net.WriteEntity(victim)
		net.WriteString(inflictor:GetClass())
		net.WriteString(attacker:GetClass())
	net.Broadcast()
end

function GM:PlayerKilled(victim)
end

function GM:PlayerGrappledObject(pl, box, proj, ent, data)
end

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	pl.NextSpawnTime = CurTime() + 3
	pl:AddDeaths(1)
	if NDB.MemberNames then
		pl.MayhemBoxesDeaths = pl.MayhemBoxesDeaths + 1
	end

	local inflictor = dmginfo:GetInflictor()
	local inflictorisself = inflictor == attacker or not inflictor:IsValid() or inflictor:GetClass() == "func_boxhurter"
	if inflictorisself and pl.LastAttacker:IsValid() and CurTime() < pl.LastAttacked + 7.5 then
		attacker = pl.LastAttacker
		inflictorisself = false
	end

	if attacker:IsPlayer() then
		if attacker == pl then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
			if NDB.MemberNames then
				attacker.MayhemBoxesKills = attacker.MayhemBoxesKills + 1
			end
		end
	end

	for _, box in pairs(ents.FindByClass("boxplayer")) do
		if box:GetOwner() == pl then
			box:Destroyed(dmginfo)
		end
	end

	if inflictorisself then
		self:PlayerDeath2(pl, pl, pl)
	else
		self:PlayerDeath2(pl, inflictor, attacker)
	end
end

function GM:PlayerDisconnect(pl)
	if pl:IsConnected() and pl:IsValid() then
		for _, ent in pairs(ents.FindByClass("boxplayer")) do
			if ent:GetOwner() == pl then ent:Remove() end
		end
		
		if NDB.MemberNames then
			if not AlreadyLost[pl:SteamID()] and self.PlayerShouldGetALossForLeaving and self:PlayerShouldGetALossForLeaving(pl) then
				pl.MayhemBoxesLosses = pl.MayhemBoxesLosses + 1
				AlreadyLost[pl:SteamID()] = true
				NDB.SaveInfo(pl)
			end
		end
	end
end

function GM:PlayerHurt(pl, attacker, healthremaining, damage)
end

GM.DeathSounds = {Sound("vo/npc/male01/no01.wav"),
Sound("vo/npc/male01/no02.wav"),
Sound("vo/npc/male01/pain07.wav"),
Sound("vo/npc/male01/pain08.wav"),
Sound("vo/npc/male01/pain09.wav"),
Sound("vo/npc/male01/pain07.wav"),
Sound("vo/npc/male01/pain08.wav"),
Sound("vo/npc/male01/pain09.wav"),
Sound("vo/npc/male01/help01.wav"),
Sound("vo/npc/Barney/ba_pain04.wav"),
Sound("vo/npc/Barney/ba_pain05.wav"),
Sound("vo/npc/Barney/ba_pain01.wav"),
Sound("vo/npc/male01/ow01.wav"),
Sound("vo/npc/male01/myleg02.wav"),
Sound("vo/npc/male01/myleg01.wav")
}

function GM:OnBoxDestroyed(box, pl, dmginfo)
	box.Removing = true
	pl:EmitSound("mayhem/die.wav")
	pl:EmitSound(self.DeathSounds[math.random(1, #self.DeathSounds)], 90, math.Rand(190, 200))

	local ent = ents.Create("prop_physics_multiplayer")
	if ent:IsValid() then
		local pos = box:GetPos()
		ent:SetPos(pos)
		ent:SetAngles(box:GetAngles())
		ent:SetModel(box:GetModel())
		ent:Spawn()
		ent:GetPhysicsObject():SetVelocityInstantaneous(box:GetVelocity() * 3)
		ent:Fire("break", "", 0)
		ent:Fire("kill", "", 0.1)
	end
end

function GM:EntityTakeDamage(ent, inflictor, attacker, amount, dmginfo)
	if attacker then 
		if ent ~= attacker and ent.SendLua and attacker.SendLua and ent:Team() ~= attacker:Team() then
			ent.LastAttacker = attacker
			ent.LastAttacked = CurTime()
		end
	end
end

function GM:CreateEntityRagdoll(ent, ragdoll)
end

concommand.Add("requestgametype", function(sender, command, arguments)
	-- ToDo: attempt to concatenate field 'GameType' (a nil value)
	sender:SendLua("GAMEMODE:"..GAMEMODE.GameType.."Initialize()")
end)

if NDB.MemberNames then
	function GM:GlobalSave(pl, tim)
		mysql_threaded_query("UPDATE noxplayers SET Money = "..pl.Money..", MayhemBoxesWins = "..pl.MayhemBoxesWins..", MayhemBoxesLosses = "..pl.MayhemBoxesLosses..", LastOnline = "..tim..", MayhemBoxesKills = "..pl.MayhemBoxesKills..", MayhemBoxesDeaths = "..pl.MayhemBoxesDeaths.." WHERE noxplayers.SteamID = '"..pl:SteamID().."'")

		return true
	end
end
