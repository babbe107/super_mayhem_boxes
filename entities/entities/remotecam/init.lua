ENT.Type = "point"

function ENT:AcceptInput(name, activator, caller)
end

function ENT:Initialize()
end

function ENT:Think()
	self:SetPos(self.Box:GetPos())
end

function ENT:OnRemove()
end

function ENT:KeyValue(key, value)
end
