ENT.Type = "anim"

function ENT:Team()
	return self:GetOwner():Team()
end

function ENT:Grounded()
	local pos = self:GetPos()
	return self:WaterLevel() == 0 and util.TraceLine({start = pos, endpos = pos + Vector(0, 0, self:BoundingRadius() * -1.15), filter = self, mask = MASK_SOLID}).Hit
end

function ENT:PredictedGrounded()
	local pos = self:GetPredictedPos()
	--ToDo: Tweak for smoother movement
	--return self:WaterLevel() == 0 and util.TraceLine({start = pos, endpos = pos + Vector(0, 0, self:BoundingRadius() * -1.15), filter = self, mask = MASK_SOLID}).Hit
	return self:WaterLevel() == 0 and util.TraceLine({start = pos, endpos = pos + Vector(0, 0, self:BoundingRadius() * -1.35), filter = self, mask = MASK_SOLID}).Hit
end

function ENT:GetCoins()
	return self:GetDTInt(0, 0)
end

function ENT:SetCoins(int)
	self:SetDTInt(0, int)
end

function ENT:SetWinking(winking)
	self:SetDTBool(3, winking)
end

function ENT:GetWinking()
	return self:GetDTBool(3)
end

function ENT:GrappleHookable(proj)
	local owner = proj.Owner
	return owner:IsValid() and owner:Team() ~= self:Team()
end
