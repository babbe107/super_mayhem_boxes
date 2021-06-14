ENT.Type = "anim"

function ENT:SetPickupType(name)
	if PickupTranslates[name] or PICKUP_GROUPS[name] then
		self:SetNetworkedString("in", name)
	elseif PickupTranslates["weapon_"..name] or PICKUP_GROUPS["weapon_"..name] then
		self:SetNetworkedString("in", "weapon_"..name)
	else
		Msg("Warning: powerup - unhandled pickup type ".. name.."\n")
		self:SetNetworkedString("in", "default")
	end
end

function ENT:GetPickupName()
	return PickupTranslates[self:GetPickupType()]
end

function ENT:GetPickupType()
	return self:GetNetworkedString("in", "default")
end
