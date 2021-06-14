include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.Rotation = math.Rand(0, 180)
	self.Seed = math.Rand(0, 10)
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
end

local matGlow = Material("sprites/light_glow02_add")
local colCoin = Color(255, 255, 0, 255)
function ENT:DrawTranslucent()
	self:SetModelScale(2)
	self:SetMaterial("models/shiny")
	self:DrawModel()
	self.Rotation = self.Rotation + FrameTime() * 4
	if 360 < self.Rotation then self.Rotation = self.Rotation - 360 end

	render.SetMaterial(matGlow)
	local siz = 40 + math.sin((RealTime() + self.Seed) * 10) * 16
	render.DrawSprite(self:GetPos(), siz, siz, colCoin)
end
