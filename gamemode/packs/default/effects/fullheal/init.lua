function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.DieTime = CurTime() + 0.25
end

function EFFECT:Think()
	if self.DieTime < CurTime() then
		if self.Ent:IsValid() then
			local pos = self.Ent:GetPos()
			local velocity = self.Ent:GetVelocity()
			local emitter = ParticleEmitter(pos)
			local vec0 = Vector(0,0,1)
			for i=0, 359 do
				local dir = vec0
				dir:Rotate(Angle(0, 0, i))
				local particle = emitter:Add("sprites/glow04_noz", pos + dir * 8)
				particle:SetVelocity(velocity + dir * 128)
				particle:SetDieTime(1)
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(0)
				particle:SetStartSize(8)
				particle:SetEndSize(32)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-2, 2))
				particle:SetColor(100, 255, 100)
			end
			emitter:Finish()
		end

		return false
	end

	return true
end

local colHeal = Color(50, 255, 50, 255)
local matRing = Material("effects/select_ring")
function EFFECT:Render()
	local ent = self.Ent
	if ent:IsValid() then
		render.SetMaterial(matRing)
		local size = (CurTime() - self.DieTime) * 1150
		local pos = ent:GetPos()
		render.DrawSprite(pos, size, size, colHeal)
		render.DrawSprite(pos, size, size, colHeal)
	end
end
