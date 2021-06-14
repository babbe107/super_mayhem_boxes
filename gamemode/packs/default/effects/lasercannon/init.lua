function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()
	local start = data:GetStart()
	local box = data:GetEntity()
	local mag = data:GetMagnitude()

	local rb = 10 * mag
	self.Entity:SetRenderBoundsWS(pos, start, Vector(rb, rb, rb))

	if box:IsValid() then
		self.Col = box:GetColor() --Color(box:GetColor())
	else
		self.Col = table.Copy(color_white)
	end

	self.Mag = mag

	self.StartPos = start
	self.EndPos = pos

	self.DieTime = CurTime() + 0.75
	if mag < 25 then
		util.Decal("FadingScorch", pos + normal, pos - normal)
	else
		util.Decal("Scorch", pos + normal, pos - normal)
	end

	self.Pos = pos
	self.Norm = normal
	self.Entity:SetRenderBoundsWS(pos + Vector(-1000, -1000, -1000), pos + Vector(1000, 1000, 1000))

	sound.Play("ambient/explosions/explode_"..math.random(1,5)..".wav", pos, 70 + mag * 0.37, 135 - mag)

	local r,g,b = self.Col.r, self.Col.g, self.Col.b

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(80, 100)
	local othernorm = normal * -1
	for i=1, 16 do
		local dir = (VectorRand() + othernorm):GetNormalized()
		local particle = emitter:Add("sprites/glow04_noz", pos + dir * 32)
		particle:SetVelocity(mag * math.Rand(6, 8) * dir)
		particle:SetDieTime(math.Rand(0.8, 1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(mag * math.Rand(1, 2))
		particle:SetEndSize(mag * math.Rand(4, 5))
		particle:SetColor(r, g, b)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(mag * -0.5, mag * 0.5))
		particle:SetAirResistance(math.Rand(10, 40))
	end

	local dir = (start - pos):GetNormalized()

	mag = math.max(mag, 5)
	for i=1, start:Distance(pos), 48 do
		for x=1, 3 do
			local particle
			if math.random(1, 5) == 5 then
				particle = emitter:Add("particle/smokestack", pos + i * dir + VectorRand():GetNormalized() * math.Rand(12, 32))
			else
				particle = emitter:Add("sprites/glow04_noz", pos + i * dir + VectorRand():GetNormalized() * math.Rand(12, 32))
			end
			particle:SetDieTime(math.Rand(0.6, 1.4))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(mag * math.Rand(1, 1.6))
			particle:SetEndSize(0)
			particle:SetColor(r, g, b)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(mag * -0.25, mag * 0.25))
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRing = Material("effects/select_ring")
local matBeam = Material("effects/laser1")
function EFFECT:Render()
	local ct = CurTime()
	if ct < self.DieTime then
		render.SetMaterial(matRing)
		local size = (0.75 - (self.DieTime - ct)) * self.Mag * 10
		local col = self.Col
		col.a = math.min(255, (self.DieTime - ct) * 560)
		render.DrawQuadEasy(self.Pos, self.Norm, size, size, col, 0)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col, 0)

		render.SetMaterial(matBeam)
		render.DrawBeam(self.StartPos, self.EndPos, self.Mag, 1, 0, col)
		render.DrawBeam(self.StartPos, self.EndPos, (self.DieTime - ct) * math.max(12, self.Mag), 1, 0, col)
	end
end
