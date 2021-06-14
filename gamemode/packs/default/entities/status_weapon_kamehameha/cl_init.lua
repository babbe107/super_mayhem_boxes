include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end

	self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	self.Emitter:Finish()
end

local matCharge = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	local nextfire = self:GetDTFloat(0, 0)

	local dir = player:GetAimVector()

	local pos = owner:GetPos() + dir * owner:BoundingRadius()

	render.SetMaterial(matCharge)
	local size
	if 0 < nextfire then
		size = (CurTime() - nextfire) * 50 + 300 + math.sin(RealTime() * 8) * 32
		local pdir = VectorRand():GetNormalized()
		local particle = self.Emitter:Add("sprites/glow04_noz", pos + pdir * 128)
		particle:SetDieTime(0.5)
		particle:SetColor(self:GetColor())
		particle:SetStartAlpha(128)
		particle:SetEndAlpha(255)
		particle:SetStartSize(2)
		particle:SetEndSize(math.Rand(32, 48))
		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetVelocity(pdir * -256 + owner:GetVelocity())
	else
		size = 64 + math.sin(RealTime() * 8) * 24
	end

	render.DrawSprite(pos, size, size, owner:GetColor())
end

function ENT:HUD(pl, box, x, y)
end

function ENT:KeyPress(pl, box, key)
end

--killicon.AddAlias("status_weapon_kamehameha", "weapon_pistol")
