ENT.Type = "anim"
ENT.Base = "status__2dbase"

if SERVER then
	GM:AddPickup("weapon_mom", "Missiles of Magic")
end

if CLIENT then
	local matGlow = Material("sprites/glow04_noz")
	GM:AddPickup("weapon_mom", "Missiles of Magic", nil, nil, function(self, pos, rt)
		pos = pos + Vector(0, math.sin(RealTime() * 6) * 32, math.cos(RealTime() * 6) * 32)

		render.SetMaterial(matGlow)
		render.DrawSprite(pos, math.Rand(32, 48), math.Rand(32, 48), COLOR_YELLOW)

		local emitter = ParticleEmitter(pos)
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
		emitter:Finish()
	end)
end
GM:AddPickupToTier("weapon_mom", "weapon_tier4")
