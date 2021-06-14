ENT.Type = "anim"
ENT.Base = "status__2dbase"

GM:AddPickup("weapon_turret", "Deployable Gun Turret", "models/Combine_turrets/Floor_turret.mdl", Vector(1.25, 1.25, 1.25))
GM:AddPickupToTier("weapon_turret", "weapon_def_tier2")
GM:AddPickupToTier("weapon_turret", "weapon_def_tier3")
