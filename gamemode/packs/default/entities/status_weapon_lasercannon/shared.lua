ENT.Type = "anim"
ENT.Base = "status__2dbase"

function ENT:SetCharge(charge)
	self:SetDTFloat(1, math.min(50, charge))
end

function ENT:GetCharge()
	return self:GetDTFloat(1)
end

GM:AddPickup("weapon_lasercannon", "Laser Cannon", "models/weapons/w_Physics.mdl", Vector(1.5, 1.5, 1.5))
GM:AddPickupToTier("weapon_lasercannon", "weapon_tier4")
