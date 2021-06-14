ENT.Type = "anim"
ENT.Base = "status__2dbase"

if SERVER then
	GM:AddPickup("timeroller", "Timeroller", "models/props_trainstation/trainstation_clock001.mdl", Vector(1.5, 1.5, 1.5))
end

-- The Timeroller has a custom draw function for pickups.
if CLIENT then
	local matRing = Material("effects/select_ring")
	local matGlow = Material("sprites/light_glow02_add")
	local colTimeRoller = Color(50, 70, 255, 255)
	local colTimeRoller2 = Color(150, 150, 150, 255)
	GM:AddPickup("timeroller", "Timeroller", "models/props_trainstation/trainstation_clock001.mdl", Vector(1.5, 1.5, 1.5), function(self, pos, rt)
		local size = math.sin(rt * 5) * 90 + 120
		local size2 = math.cos(rt * 5) * 90 + 120
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, size * 4, size * 4, colTimeRoller2)
		render.SetMaterial(matRing)
		render.DrawSprite(pos, size2, size, colTimeRoller)
		render.DrawSprite(pos, size, size2, colTimeRoller)
		render.DrawSprite(pos, size2, size2, colTimeRoller)
		render.DrawSprite(pos, size, size, colTimeRoller)

		self:SetAngles(Angle(0, 0, math.sin(rt * 0.8) * 180 + 180))
		self:SetModel(PowerupDrawModels["timeroller"])
		-- self:SetModelScale(PowerupDrawScales["timeroller"])
		self:SetModelScale(1)
		self:DrawModel()
	end)
end
GM:AddPickupToTier("timeroller", "powerup_tier4")

util.PrecacheSound("ambient/levels/citadel/portal_beam_shoot6.wav")
util.PrecacheSound("ambient/levels/citadel/portal_beam_shoot5.wav")
