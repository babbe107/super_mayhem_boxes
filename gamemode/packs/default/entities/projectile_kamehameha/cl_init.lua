include("shared.lua")

--killicon.AddFont("projectile_kamehameha", "HL2MPTypeDeath", "3", color_white)

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
	self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())

	local vecstart = self:GetDTVector(0)
	if vecstart then
		self:SetRenderBoundsWS(self:GetPos(), vecstart, Vector(128, 128, 128))
	end
end

function ENT:OnRemove()
	self.Emitter:Finish()
end

local matTrail = Material("Effects/laser1")
function ENT:Draw()
	self:SetModelScale(3)
	self:SetMaterial("models/shiny")
	print(self:GetColor())
	local r, g, b, a = self:GetColor()
	-- ToDo: There is no color?
	if not a then
		a = 255
		r = 255
		g = 255
		b = 255
	end
	self:SetColor(r, g, b, 40)
	self:DrawModel()

	local vOffset = self:GetPos() + self:GetForward() * -9

	local particle = self.Emitter:Add("sprites/glow04_noz", vOffset)
	particle:SetDieTime(3)
	particle:SetStartAlpha(250)
	particle:SetEndAlpha(100)
	particle:SetStartSize(math.Rand(140, 200))
	particle:SetEndSize(2)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-12, 12))
	particle:SetColor(r, g, b)

	local vecstart = self:GetDTVector(0)
	if vecstart then
		render.SetMaterial(matTrail)
		-- What is the current color here? Can't we just use 255 255 255?
		print("Color: "..r)
		print("Color: "..g)
		print("Color: "..b)
		local col = Color(r,g,b,255)
		render.DrawBeam(vecstart, vOffset, 300, 1, 0, col)
		render.DrawBeam(vecstart, vOffset, 340, 1, 0, color_white)
		render.DrawBeam(vecstart, vOffset, 360, 1, 0, col)
	end
end
