include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end
end

function ENT:OnRemove()
end

function ENT:DrawTranslucent()
end

function ENT:KeyPress(pl, box, key)
end
