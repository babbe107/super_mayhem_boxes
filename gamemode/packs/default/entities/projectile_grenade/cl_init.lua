include("shared.lua")

killicon.AddFont("projectile_grenade", "HL2MPTypeDeath", "4", color_white)

function ENT:Initialize()
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
	self.Emitter = ParticleEmitter(self:GetPos())

	self.Die = CurTime() + 2
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.Emitter:Finish()
end

local matGlow = Material("sprites/glow04_noz")
function ENT:Draw()
	if self.Die < CurTime() then
		local scale = 2 + math.sin((CurTime() - self.Die) * 10)
		self:SetModelScale(scale)
		render.SetMaterial(matGlow)
		render.DrawSprite(self:GetPos(), scale * 25, scale * 25, self:GetColor())
	else
		self:SetModelScale(2)
	end
	self:DrawModel()

	local particle = self.Emitter:Add("particles/smokey", self:GetPos() + self:GetForward() * -9)
	particle:SetVelocity(VectorRand() * 16)
	particle:SetDieTime(1.5)
	particle:SetStartAlpha(160)
	particle:SetEndAlpha(0)
	particle:SetStartSize(5)
	particle:SetEndSize(5)
	particle:SetRollDelta(math.Rand(-1.5, 1.5))
	particle:SetColor(self:GetColor())
end
