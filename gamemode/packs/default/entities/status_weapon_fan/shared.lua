ENT.Type = "anim"
ENT.Base = "status__2dbase"

function ENT:GetSpinning()
	return self:GetDTBool(0)
end

function ENT:SetSpinning(spinning)
	self:SetDTBool(0, spinning)
end

util.PrecacheModel("models/props_citizen_tech/windmill_blade004a.mdl")

--GM:AddPickup("weapon_fan", "Fan", "models/props/de_prodigy/fanoff.mdl")
GM:AddPickup("weapon_fan", "Fan", "models/props_citizen_tech/windmill_blade004a.mdl", Vector(0.5, 0.5, 0.5))
GM:AddPickupToTier("weapon_fan", "weapon_tier3")
