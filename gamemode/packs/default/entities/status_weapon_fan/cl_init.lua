include("shared.lua")

util.PrecacheSound("ambient/wind/wind1.wav")
function ENT:Initialize()
	self:SetModel("models/props_citizen_tech/windmill_blade004a.mdl")
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	self.Yaw = math.Rand(0, 180)
	self.Emitter = ParticleEmitter(self:GetPos())
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end
	self.BlowerSound = CreateSound(self, "ambient/wind/wind1.wav")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	--if self:GetModel() == "models/props/de_prodigy/fan.mdl" then
	if self:GetSpinning() then
		self.BlowerSound:PlayEx(90, 255)
	else
		self.BlowerSound:Stop()
	end
end

function ENT:OnRemove()
	self.Emitter:Finish()
	self.BlowerSound:Stop()
end

function ENT:HUD(pl, box, x, y)
end

function ENT:KeyPress(pl, box, key)
end

local vecHalf = Vector(0.5, 0.5, 0.5)
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	self:SetColor(owner:GetColor())
	local dir = player:GetAimVector()
	local offset = owner:GetPos() + dir * owner:BoundingRadius()
	self:SetPos(offset)
	local ang = dir:Angle()

	if self:GetSpinning() then
		local particle
		-- if util.PointContents(offset) and CONTENTS_WATER == 32 then
		if bit.band( util.PointContents(offset), CONTENTS_WATER ) == CONTENTS_WATER then
			particle = self.Emitter:Add("effects/bubble", offset)
		else
			particle = self.Emitter:Add("particle/snow", offset)
		end
		particle:SetVelocity(owner:GetVelocity() + dir * 500 + VectorRand() * math.Rand(80, 160))
		particle:SetStartAlpha(160)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(math.Rand(58, 70))
		particle:SetDieTime(math.Rand(1, 1.3))
		particle:SetAirResistance(30)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetCollide(true)
		particle:SetBounce(0.5)

		self.Yaw = math.NormalizeAngle(self.Yaw - FrameTime() * 720)
	end

	ang:RotateAroundAxis(dir, self.Yaw, 0)
	self:SetAngles(ang)
	self:SetModelScale(0.4)
	self:DrawModel()
end
