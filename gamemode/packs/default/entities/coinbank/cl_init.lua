include("shared.lua")

usermessage.Hook("FlagReturnEffect", function(um)
	local effectdata = EffectData()
		effectdata:SetOrigin(um:ReadVector())
		effectdata:SetStart(um:ReadVector())
		effectdata:SetScale(um:ReadShort())
	util.Effect("FlagReturn", effectdata)
end)

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.Rotation = 0
	self:SetRenderBounds(Vector(-128, -128, -72), Vector(128, 128, 90))
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local pos = self:GetPos()

	self:SetMaterial("models/shiny")
	self:DrawModel()
	self.Rotation = self.Rotation + FrameTime() * 4
	if 360 < self.Rotation then self.Rotation = self.Rotation - 360 end

	if self.Rotation > 360 then self.Rotation = 0 end

	local rsin = math.sin(self.Rotation) * 16
	local rcon = math.cos(self.Rotation) * 16

	local vOffset = Vector(rsin, rcon, 0)
	local vOffset2 = Vector(0, rcon, rsin)
	local vOffset3 = Vector(rcon, 0, rsin)

	local drawColor = self:GetColor() --Color(self:GetColor())
	local size =  math.sin(RealTime() * 5) * 60 + 90
	local minisize = size * 0.5

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size, size, drawColor)
	render.DrawSprite(pos + vOffset, minisize, minisize, drawColor)
	render.DrawSprite(pos + vOffset2, minisize, minisize, drawColor)
	render.DrawSprite(pos + vOffset3, minisize, minisize, drawColor)
end
