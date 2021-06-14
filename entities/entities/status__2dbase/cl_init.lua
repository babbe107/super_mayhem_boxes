include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()
end

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
end

function ENT:Think()
end

function ENT:OnRemove()
end
