ENT.Type = "anim"
ENT.Base = "status__2dbase"

if SERVER then
	GM:AddPickup("weapon_kamehameha", "Kamehameha")
end

if CLIENT then
	local matKame = Material("sprites/glow04_noz")
	GM:AddPickup("weapon_kamehameha", "Kamehameha", nil, nil, function(self, pos, rt)
		render.SetMaterial(matKame)
		local pdir = VectorRand():GetNormalized()
		local emitter = ParticleEmitter(pos)
		local particle = emitter:Add("sprites/glow04_noz", pos + pdir * 128)
		particle:SetDieTime(0.5)
		particle:SetColor(self:GetColor())
		particle:SetStartAlpha(128)
		particle:SetEndAlpha(255)
		particle:SetStartSize(2)
		particle:SetEndSize(math.Rand(32, 48))
		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetVelocity(pdir * -256)
		emitter:Finish()

		local size = 200 + math.sin(RealTime() * 8) * 32
		render.DrawSprite(pos, size, size, color_white)
	end)
end
GM:AddPickupToTier("weapon_kamehameha", "weapon_tier5")

util.PrecacheSound("ambient/levels/citadel/portal_beam_shoot6.wav")
util.PrecacheSound("ambient/levels/citadel/portal_beam_shoot5.wav")
