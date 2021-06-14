function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()
	self.Owner = ent
	self.DieTime = 0.5

	if not ent:IsValid() then return end

	sound.Play("physics/metal/metal_sheet_impact_bullet1.wav", pos, 85, math.Rand(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(30, 40)
	for i=1, math.random(20, 30) do
		local heading = VectorRand():GetNormalized()
		local particle = emitter:Add("effects/spark", pos + heading * 4)
		particle:SetVelocity(heading * math.Rand(100, 280))
		particle:SetDieTime(math.Rand(1, 2))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		local size = math.Rand(3, 6)
		particle:SetStartSize(size)
		particle:SetEndSize(size)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetBounce(0.6)
		particle:SetCollide(true)
	end
	emitter:Finish()
end

function EFFECT:Think()
	local ent = self.Owner
	if ent and ent:IsValid() and ent:Alive() then
		local pos
		local angpos = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
		if angpos then
			pos = angpos.Pos
		else
			pos = ent:EyePos()
		end

		self.Entity:SetPos(pos)
	end

	return CurTime() < self.DieTime
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local ent = self.Owner
	if ent and ent:IsValid() and ent:Alive() then
		local pos
		local angpos = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
		if angpos then
			pos = angpos.Pos
		else
			pos = ent:EyePos()
		end

		render.SetMaterial(matGlow)
		local size = 32 - (self.DieTime - CurTime()) * 100
		render.DrawSprite(pos, size, size, Color(255, 255, 255, math.min(255, (self.DieTime - CurTime()) * 700)))
	end
end
