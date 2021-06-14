include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
end

function ENT:Think()
end

function ENT:OnRemove()
end

function ENT:Draw()
	local vel = self:GetVelocity()
	if 10 < vel:Length() then
		self:SetAngles(vel:Angle())
	end
	self:DrawModel()
end
