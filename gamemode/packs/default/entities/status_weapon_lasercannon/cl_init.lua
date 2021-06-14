include("shared.lua")

--killicon.AddAlias("status_weapon_lasercannon", "weapon_pistol")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end

	self.AmbientSound = CreateSound(self, "ambient/levels/citadel/zapper_loop1.wav")
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:Think()
end

function ENT:HUD(pl, box, x, y)
	local charge = self:GetCharge()
	if 0 < charge then
		surface.SetDrawColor(charge * 5, 20, 255 - charge * 5, 180)
		surface.DrawRect(x - charge, y + 33, charge * 2, 6)
	end
end

function ENT:KeyPress(pl, box, key)
end

local matRing = Material("effects/select_ring")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	self:SetColor(owner:GetColor())
	local dir = player:GetAimVector()
	local pos = owner:GetPos() + dir * (owner:BoundingRadius() - 4)
	self:SetPos(pos)
	self:SetAngles(dir:Angle())
	self:SetModelScale(1.5) --Vector(1.5, 1.5, 1.5))
	self:DrawModel()

	local charge = self:GetCharge()
	if 0 < charge then
		pos = pos + dir * 16
		render.SetMaterial(matRing)
		local size = math.abs(math.sin(charge)) * 100
		local size2 = math.abs(math.cos(charge)) * 100
		local col = owner:GetColor() --Color(owner:GetColor())
		render.DrawQuadEasy(pos, dir, size, size2, col, size2)
		render.DrawQuadEasy(pos, dir * -1, size2, size, col, size)
		local pos2 = pos + math.sin(CurTime() * charge * 0.15) * 16 * dir
		render.DrawQuadEasy(pos2, dir, charge, charge, col, CurTime())
		render.DrawQuadEasy(pos2, dir * -1, charge, charge, col, CurTime())
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, size, size2, col)
		render.DrawSprite(pos, size2, size, col)
		render.DrawSprite(pos, charge * 2, charge * 2, col)
		self.AmbientSound:PlayEx(70 + charge * 0.3, 90 + charge * 2)
	else
		self.AmbientSound:Stop()
	end
end
