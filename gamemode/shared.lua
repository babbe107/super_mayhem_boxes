include("obj_player_extend.lua")
include("obj_entity_extend.lua")

include("2dnoxteams.lua")

NDB = NDB or {}

if not NDB.MemberNames then
	include("maplist.lua")
end

GM.Name = "Super Mayhem Boxes"
GM.Version = 1.3
GM.Author = "Original author: William \"JetBoom\" Moodhe, Updated by: Babbe"
GM.Email = "jetboom@yahoo.com"
GM.Website = "http://www.noxiousnet.com"

GM.RoundTime = 600

if NDB.MemberNames then
	GM.HatsDisabled = true
	GM.BloodDyesDisabled = true
	GM.BodysDisabled = true
	GM.AccsDisabled = true
end

GM.NoGameTypeTwiceInRow = true

GM.GameTypes = {}
GM.GameTypeDescriptions = {}
GM.GameTranslates = {}
GM.Packs = {}

TEAM_RED = 1
TEAM_GREEN = 2

team.SetUp(TEAM_RED, "Team Red", Color(255, 50, 50, 255))
team.SetUp(TEAM_GREEN, "Team Green", Color(50, 255, 50, 255))

-- Just build the Tiers here to be safe.
PickupTranslates = {
	["default"] = ". . .",
	["halfheal"] = "Half heal",
	["fullheal"] = "Full heal",
	["weapon_tier1"] = "Random Weapon Tier 1",
	["weapon_tier2"] = "Random Weapon Tier 2",
	["weapon_tier3"] = "Random Weapon Tier 3",
	["weapon_tier4"] = "Random Weapon Tier 4",
	["weapon_tier5"] = "Random Weapon Tier 5",
	["weapon_def_tier1"] = "Random Defense Tier 1",
	["weapon_def_tier2"] = "Random Defense Tier 2",
	["weapon_def_tier3"] = "Random Defense Tier 3",
	["powerup_tier1"] = "Random Powerup Tier 1",
	["powerup_tier2"] = "Random Powerup Tier 2",
	["powerup_tier3"] = "Random Powerup Tier 3",
	["powerup_tier4"] = "Random Powerup Tier 4",
	["powerup_tier5"] = "Random Powerup Tier 5"
}

PICKUP_GROUPS = {
	["weapon_tier1"] = {},
	["weapon_tier2"] = {},
	["weapon_tier3"] = {},
	["weapon_tier4"] = {},
	["weapon_tier5"] = {},
	["weapon_tier6"] = {},
	["weapon_def_tier1"] = {},
	["weapon_def_tier2"] = {},
	["weapon_def_tier3"] = {},
	["weapon_def_tier4"] = {},
	["weapon_def_tier5"] = {},
	["weapon_def_tier6"] = {},
	["powerup_tier1"] = {},
	["powerup_tier2"] = {},
	["powerup_tier3"] = {},
	["powerup_tier4"] = {},
	["powerup_tier5"] = {},
	["powerup_tier6"] = {}
}

function GM:ShouldCollide(enta, entb)
	return not (enta.ShouldNotCollide and enta:ShouldNotCollide(entb) or entb.ShouldNotCollide and entb:ShouldNotCollide(enta))
end

function GM:AddPickup(class, name, model, scale, customdraw)
	if class then
		PickupTranslates[class] = name
		if CLIENT then
			PowerupDrawScales[class] = scale
			PowerupDrawModels[class] = model
			CustomDrawFunctions[class] = customdraw
		end
	else
		ErrorNoHalt("Attempt to add a nil pickup class!")
	end
end

function GM:AddPickupToTier(class, tiername)
	if class then
		if not PICKUP_GROUPS[tiername] then
			PICKUP_GROUPS[tiername] = {}
		end
		table.insert(PICKUP_GROUPS[tiername], class)
	else
		ErrorNoHalt("Attempt to add a nil pickup to a tier!")
	end
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	return pl == attacker or not attacker:IsPlayer() or attacker:Team() ~= pl:Team()
end

function GM:KeyPress(pl, key)
	local box = pl:GetBox()
	if box.KeyPress then box:KeyPress(pl, key) end
end

function GM:KeyRelease(pl, key)
	local box = pl:GetBox()
	if box.KeyRelease then box:KeyRelease(pl, key) end
end

function TrueVisible(posa, posb)
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, ents.FindByClass("boxplayer"))
	filt = table.Add(filt, ents.FindByClass("2dflag"))

	return not util.TraceLine({start = posa, endpos = posb, filter = filt, mask = MASK_SOLID}).Hit
end

function ToMinutesSeconds(TimeInSeconds)
	local iMinutes = math.floor(TimeInSeconds / 60.0)
	return string.format("%0d:%02d", iMinutes, math.floor(TimeInSeconds - iMinutes*60))
end

-- This function lets you serialize and deserialize tables.

function Deserialize(sIn)
	SRL = nil

	RunString(sIn)

	return SRL
end

local function MakeTable(tab, done)
	local str = ""
	local done = done or {}

	local sequential = table.IsSequential(tab)

	for key, value in pairs(tab) do
		local keytype = type(key)
		local valuetype = type(value)

		if sequential then
			key = ""
		else
			if keytype == "number" or keytype == "boolean" then 
				key ="["..tostring(key).."]="
			elseif keytype ~= "Entity" and keytype ~= "Player" then
				key = "["..string.format("%q", tostring(key)).."]="
			end
		end

		if valuetype == "table" and not done[value] then
			done[value] = true
			str = str..key.."{"..MakeTable(value, done).."},"
		else
			if valuetype == "string" then 
				value = string.format("%q", value)
			elseif valuetype == "Vector" then
				value = "Vector("..value.x..","..value.y..","..value.z..")"
			elseif valuetype == "Angle" then
				value = "Angle("..value.pitch..","..value.yaw..","..value.roll..")"
			elseif valuetype ~= "Entity" and valuetype ~= "Player" then
				value = tostring(value)
			end

			str = str .. key .. value .. ","
		end
	end

	if string.sub(str, -1) == "," then
		return string.sub(str, 1, string.len(str) - 1)
	else
		return str
	end
end

function Serialize(tIn)
	return "SRL={"..MakeTable(tIn).."}"
end

packname = "default"
print("Loading pack: " ..packname)
if not string.find(packname, ".", 1, true) then
	local disabled
	for __ in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/pack.lua", "LUA")) do
		PACK = {}
		include("packs/"..packname.."/pack.lua")
		AddCSLuaFile("packs/"..packname.."/pack.lua")
		GM.Packs[packname] = PACK
		if PACK.Disabled then disabled = true end
		print("Added pack: " ..packname)
		break
	end

	if not disabled then
		print("Using pack: "..packname)
		print("Searching entity files for pack " ..packname)
		local files, directories = file.Find("supermayhemboxes/gamemode/packs/"..packname.."/entities/*", "LUA")

		for _,entitydir in pairs(directories) do
			print("[Loading entity] "..entitydir)
			if not string.find(entitydir, ".", 1, true) then
				ENT = {}
				local included
				if SERVER then
					for __ in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/entities/"..entitydir.."/init.lua", "LUA")) do
						include("packs/"..packname.."/entities/"..entitydir.."/init.lua")
						print("[SERVER: Entity loaded] packs/"..packname.."/entities/"..entitydir.."/init.lua")
						included = true
						break
					end
				end
				if CLIENT then
					for __ in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/entities/"..entitydir.."/cl_init.lua", "LUA")) do
						include("packs/"..packname.."/entities/"..entitydir.."/cl_init.lua")
						print("[CLIENT: Entity loaded] packs/"..packname.."/entities/"..entitydir.."/cl_init.lua")
						included = true
						break
					end
				end
				if not included then
					for __ in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/entities/"..entitydir.."/shared.lua", "LUA")) do
						include("packs/"..packname.."/entities/"..entitydir.."/shared.lua")
						print("[SHARED: Entity loaded] packs/"..packname.."/entities/"..entitydir.."/shared.lua")
						break
					end
				end

				scripted_ents.Register(ENT, entitydir)
			end
		end

		print("Searching effect files for pack " ..packname)
		local files, directories = file.Find("supermayhemboxes/gamemode/packs/"..packname.."/effects/*", "LUA")
		for _,effectdir in pairs(directories) do
			print("[Loading effect] " ..effectdir)
			if not string.find(effectdir, ".", 1, true) then
				if CLIENT then
					EFFECT = {}
					for __ in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/effects/"..effectdir.."/init.lua", "LUA")) do
						include("supermayhemboxes/gamemode/packs/"..packname.."/effects/"..effectdir.."/init.lua")
						print("[CLIENT: Effect loaded] packs/"..packname.."/entities/"..effectdir.."/init.lua")
						break
					end
					effects.Register(EFFECT, effectdir)
				elseif SERVER then
					for __ in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/effects/"..effectdir.."/init.lua", "LUA")) do
						print("Adding Lua file supermayhemboxes/gamemode/packs/"..packname.."/effects/"..effectdir.."/init.lua")
						AddCSLuaFile("packs/"..packname.."/effects/"..effectdir.."/init.lua")
						print("[SERVER: Effect loaded] packs/"..packname.."/entities/"..effectdir.."/init.lua")
						break
					end
				end
			end
		end

		print("Searching gamemode files for pack " ..packname)
		for i, filename in pairs(file.Find("supermayhemboxes/gamemode/packs/"..packname.."/gametypes/*.lua", "LUA")) do
			print("[Loading gamemode] " .. filename)
			local isshared = string.sub(filename, 1, 3) == "sh_"
			local isclient = string.sub(filename, 1, 3) == "cl_"
			local isserver = not isshared and not isclient

			if SERVER and not isserver then
				print("Adding Lua file packs/"..packname.."/gametypes/"..filename)
				AddCSLuaFile("packs/"..packname.."/gametypes/"..filename)
			end

			if CLIENT and (isclient or isshared) or SERVER and (isserver or isshared) then
				include("packs/"..packname.."/gametypes/"..filename)
			end
		end
	end
end
-- end
