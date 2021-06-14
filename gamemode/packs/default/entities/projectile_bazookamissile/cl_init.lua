include("shared.lua")

killicon.AddFont("projectile_bazookamissile", "HL2MPTypeDeath", "3", color_white)

function ENT:Initialize()
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
	self.Emitter = ParticleEmitter(self:GetPos())
	self.FireSound = CreateSound(self, "Missile.Ignite")
	self.FireSound:Play()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.Emitter:Finish()
	self.FireSound:Stop()
end

function ENT:Draw()
	print("Draw function")
	local vel = self:GetVelocity()
	--if 10 < vel:Length() then
	print("Velocity: ")
	print(vel)
	print("Angle: ")
	print(vel:Angle())
	self:SetAngles(Angle(170, 170, 90))
	print("New Angles: ")
	print(self:GetAngles())
	
	--end
	self:SetModelScale(2)
	self:DrawModel()
	

	local r, g, b, a = self:GetColor()

	local vOffset = self:GetPos() + self:GetForward() * -9

	local particle = self.Emitter:Add("effects/fire_embers"..math.random(1, 3), vOffset)
	particle:SetDieTime(1)
	particle:SetStartAlpha(250)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(18, 26))
	particle:SetEndSize(4)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))
	particle:SetColor(r, g, b)
	for i=1, 3 do
		local particle = self.Emitter:Add("particles/smokey", vOffset)
		particle:SetVelocity(VectorRand() * 16)
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(160)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 14))
		particle:SetEndSize(6)
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
		particle:SetColor(r, g, b)
	end
end
