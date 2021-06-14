include("shared.lua")

killicon.Add("status_firedamage", "killicon/env_fire_killicon", color_white)

util.PrecacheSound("ambient/fire/fire_med_loop1.wav")
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	self.Emitter = ParticleEmitter(self:GetPos())
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")
	self.AmbientSound:Play()
end

function ENT:OnRemove()
	self.Emitter:Finish()
	self.AmbientSound:Stop()
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local mins, maxs = owner:OBBMins(), owner:OBBMaxs()

		local vOffset = owner:GetPos() + Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z))
		local particle = self.Emitter:Add("effects/fire_embers"..math.random(1, 3), vOffset)
		particle:SetGravity(Vector(0,0,200))
		particle:SetDieTime(math.Rand(0.7, 0.92))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(30, 40))
		particle:SetEndSize(12)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))

		local particle = self.Emitter:Add("particles/smokey", vOffset)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(8, 64))
		particle:SetGravity(Vector(0,0,150))
		particle:SetDieTime(1.8)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(30, 40))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
		particle:SetColor(40, 40, 40)
	end
end
