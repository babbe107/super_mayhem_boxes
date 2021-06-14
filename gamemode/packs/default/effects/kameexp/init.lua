function EFFECT:Init(data)
	self.Size = 24
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()

	local tr = util.TraceLine({start = pos, endpos = pos + normal * -64})
	util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	sound.Play("mayhem/kame_hit.wav", pos, 100, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(128, 160)
	for i=1, 359 do
		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(Vector(1400 * math.sin(i), 1400 * math.cos(i), 0))
		particle:SetDieTime(5)
		particle:SetStartAlpha(100)
		particle:SetEndAlpha(0)
		particle:SetStartSize(160)
		particle:SetEndSize(500)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(20)
	end

	for i=1, 5 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(3 + i)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(300)
		particle:SetEndSize(7500)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
	end

	emitter:Finish()

	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetRenderBoundsWS(pos + Vector(-8000, -8000, -8000), pos + Vector(8000, 8000, 8000))

	local dist = MySelf:EyePos():Distance(pos)
	if dist < 4000 then
		MySelf:ScreenShake((4000 - dist) * 0.0012, 60, 12)
	end
end

function EFFECT:Think()
	local ft = FrameTime()
	self.Size = self.Size + ft * self.Size * 1.1
	self.Entity:SetAngles(Angle(0, self:GetAngles().yaw + ft * 360, 0))
	return self.Size < 180
end

local matCharge = Material("sprites/glow04_noz")
function EFFECT:Render()
	local ent = self.Entity
	local siz = self.Size
	ent:SetModelScale(siz)
	ent:SetColor(235, 240, 255, math.min(255, (180 - siz) * 5))
	ent:SetMaterial("models/shiny")
	ent:DrawModel()

	render.SetMaterial(matCharge)
	local col = self:GetColor() -- Color(self:GetColor())
	render.DrawSprite(self:GetPos(), siz * 70, siz * 70, col)
	render.DrawSprite(self:GetPos(), siz * 90, siz * 90, col)
	render.DrawSprite(self:GetPos(), siz * 120, siz * 120, col)
end
