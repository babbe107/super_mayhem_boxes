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
	self:SetModelScale(2.5)
	self:DrawModel()
end

function ENT:HUD(pl, box, x, y)
	local ct = CurTime()
	if ct < self:GetNextAttack() then
		surface.SetDrawColor(255, 255, 255, 180)
		local len = (self:GetNextAttack() - ct) * 18.3
		surface.DrawRect(x - len * 0.5, y + 33, len, 6)
	end
end

function ENT:KeyPress(pl, box, key)
	if (key == IN_ATTACK or key == IN_ATTACK2) and self:GetNextAttack() <= CurTime() then
		self:SetNextAttack(CurTime() + 3.5)
		self:NextThink(CurTime())
	end
end
