include("shared.lua")

local matGlow = Material("sprites/glow04_noz")

ENT.Seed = math.Rand(0, 10)

function ENT:Draw()
	local mypos = self:GetPos()

	self:DrawModel()

	render.SetMaterial(matGlow)
	local radius = 24 + math.cos((CurTime() + self.Seed) * 10) * 8
	render.DrawSprite(mypos + self:GetUp() * 8, radius, radius, self:GetColor())
end
