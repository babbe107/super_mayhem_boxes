function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()
	self.DieTime = CurTime() + 0.75
	util.Decal("Scorch", pos + normal, pos - normal)
	pos = pos + normal * 2
	self.Pos = pos
	self.Norm = normal
	self.Entity:SetRenderBoundsWS(pos + Vector(-1000, -1000, -1000), pos + Vector(1000, 1000, 1000))

	sound.Play("ambient/explosions/explode_"..math.random(1,5)..".wav", pos, 95, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(80, 100)
	for i=1, 16 do
		local dir = (VectorRand() + normal):GetNormalized()
		local particle = emitter:Add("particle/smokestack", pos + dir * 32)
		particle:SetVelocity(dir * math.Rand(80, 180))
		particle:SetDieTime(math.Rand(3.5, 4))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(20, 30))
		particle:SetEndSize(math.Rand(100, 140))
		particle:SetColor(40, 40, 40)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(math.Rand(20, 40))

		local particle = emitter:Add("effects/fire_cloud1", pos + dir * 16)
		particle:SetVelocity(dir * math.Rand(140, 180))
		particle:SetDieTime(math.Rand(1, 1.8))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(math.Rand(60, 100))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.5, 0.5))
		particle:SetAirResistance(60)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRing = Material("effects/select_ring")
function EFFECT:Render()
	local ct = CurTime()
	if ct < self.DieTime then
		render.SetMaterial(matRing)
		local size = (0.75 - (self.DieTime - ct)) * 700
		local col = Color(255, 190, 40, math.min(255, (self.DieTime - ct) * 560))
		render.DrawQuadEasy(self.Pos, self.Norm, size, size, col, 0)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col, 0)
	end
end
