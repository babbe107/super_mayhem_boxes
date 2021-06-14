include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end
	self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:OnRemove()
	self.Emitter:Finish()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

local matFire = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	local pos = owner:GetPos() + player:GetAimVector() * (owner:BoundingRadius() + 8)
	self:SetPos(pos)

	render.SetMaterial(matFire)
	render.DrawSprite(pos, math.Rand(32, 48), math.Rand(32, 48), COLOR_YELLOW)

	local emitter = self.Emitter
	emitter:SetPos(pos)
	local particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(14, 20))
	particle:SetEndSize(2)
	particle:SetRoll(math.random(0, 360))
	for i=1, 4 do
		particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos)
		particle:SetVelocity(self:GetVelocity() * -0.4 + VectorRand() * 50)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(10, 14))
		particle:SetEndSize(1)
		particle:SetRoll(math.random(0, 360))
	end
end

function ENT:HUD(pl, box, x, y)
	local ct = CurTime()
	if ct < self:GetNextAttack() then
		surface.SetDrawColor(255, 255, 255, 180)
		local len = (self:GetNextAttack() - ct) * 32
		surface.DrawRect(x - len * 0.5, y + 33, len, 6)
	end
end

function ENT:KeyPress(pl, box, key)
	-- if key == IN_ATTACK and self:GetNextAttack() <= CurTime() and util.PointContents(box:GetPos() + pl:GetAimVector() * 2) and CONTENTS_WATER ~= 32 then
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() and util.PointContents(box:GetPos() + pl:GetAimVector() * 2) and bit.band( util.PointContents(box:GetPos()), CONTENTS_WATER ) ~= CONTENTS_WATER then
		self:SetNextAttack(CurTime() + 2)
		self:NextThink(CurTime())
	end
end

killicon.AddAlias("status_weapon_mom", "weapon_mom")
