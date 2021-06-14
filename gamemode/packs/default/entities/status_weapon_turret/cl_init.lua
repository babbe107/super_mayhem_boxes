include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end
end

function ENT:OnRemove()
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	self:SetColor(owner:GetColor())
	local dir = player:GetAimVector()
	self:SetPos(owner:GetPos() + dir * owner:BoundingRadius())
	self:SetAngles(dir:Angle())
	self:SetModelScale(1.5) --Vector(1.5, 1.5, 1.5))
	self:DrawModel()
end

function ENT:HUD(pl, box, x, y)
end

function ENT:KeyPress(pl, box, key)
end
