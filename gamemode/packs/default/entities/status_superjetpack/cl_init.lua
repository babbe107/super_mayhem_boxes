include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	self.Emitter = ParticleEmitter(self:GetPos())
	self.FireSound = CreateSound(self, "Missile.Ignite")
end

function ENT:OnRemove()
	self.FireSound:Stop()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	if self:GetDTBool(0) then
		self.FireSound:Play()
	else
		self.FireSound:Stop()
	end
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	self:SetColor(owner:GetColor())
	local dir = player:GetAimVector() * -1
	local offset = owner:GetPos() + dir * (owner:BoundingRadius() - 16)
	self:SetPos(offset)

	if self:GetDTBool(0) then
		offset = offset + dir * 40
		local particle
		local particle2 = self.Emitter:Add("sprites/glow04_noz", offset)
		-- if util.PointContents(offset) and CONTENTS_WATER == 32 then
		if bit.band( util.PointContents(offset), CONTENTS_WATER ) == CONTENTS_WATER then
			particle = self.Emitter:Add("effects/bubble", offset)
		else
			particle = self.Emitter:Add("effects/fire_cloud1", offset)
			particle:SetColor(0, 180, 255)
		end
		particle2:SetColor(0, 180, 255)
		particle:SetVelocity(dir * 100 + VectorRand() * math.Rand(16, 32))
		particle2:SetVelocity(particle:GetVelocity())
		particle:SetStartAlpha(160)
		particle2:SetStartAlpha(160)
		particle:SetEndAlpha(0)
		particle2:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(24, 32))
		particle2:SetStartSize(math.Rand(24, 32))
		particle:SetEndSize(0)
		particle2:SetEndSize(0)
		particle:SetDieTime(math.Rand(0.5, 0.7))
		particle2:SetDieTime(math.Rand(0.5, 0.7))
		particle:SetAirResistance(2)
		particle2:SetAirResistance(2)
		particle:SetRoll(math.Rand(0, 360))
		particle2:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle2:SetRollDelta(math.Rand(-4, 4))
	end

	local ang = dir:Angle()
	ang.pitch = math.NormalizeAngle(ang.pitch + 90)
	self:SetAngles(ang)
	self:SetModelScale(1)
	self:DrawModel()
end
