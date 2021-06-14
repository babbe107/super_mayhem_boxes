ENT.Type = "anim"
ENT.Base = "status__2dbase"

GM:AddPickup("weapon_sword", "Sword", "models/peanut/conansword.mdl")
GM:AddPickupToTier("weapon_sword", "weapon_tier1")

util.PrecacheSound("physics/metal/sawblade_stick1.wav")
util.PrecacheSound("physics/metal/sawblade_stick2.wav")
util.PrecacheSound("physics/metal/sawblade_stick3.wav")
