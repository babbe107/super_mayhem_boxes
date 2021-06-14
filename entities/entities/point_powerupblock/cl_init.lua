include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetRenderBounds(Vector(-128, -128, -32), Vector(128, 128, 160))
	self:SetSolid(SOLID_NONE)
	self.Rotation = math.Rand(0, 180)
	self.Seed = math.Rand(0, 10)
end

local vVec1 = Vector(1, 1, 1)
local col = Color(255, 140, 40, 255)
local colPowerup = Color(50, 255, 50, 255)
local matRing = Material("effects/select_ring")
function ENT:DrawTranslucent()
	local newrot = self.Rotation + FrameTime() * 35

	if 360 < newrot then newrot = newrot - 360 end
	self.Rotation = newrot

	local pos = self:GetPos()

	local rt = RealTime() + self.Seed

	local typ = self:GetPickupType()
	if CustomDrawFunctions[typ] then
		CustomDrawFunctions[typ](self, pos, rt)
	elseif PowerupDrawModels[typ] then
		local size = math.sin(rt * 5) * 60 + 90
		local size2 = math.cos(rt * 5) * 60 + 90
		render.SetMaterial(matRing)
		if string.sub(typ, 1, 7) == "weapon_" then
			render.DrawSprite(pos, size2, size, col)
			render.DrawSprite(pos, size, size2, col)
			render.DrawSprite(pos, size2, size2, col)
			render.DrawSprite(pos, size, size, col)
		else
			render.DrawSprite(pos, size2, size, colPowerup)
			render.DrawSprite(pos, size, size2, colPowerup)
			render.DrawSprite(pos, size2, size2, colPowerup)
			render.DrawSprite(pos, size, size, colPowerup)
		end

		local adding2 = math.sin(rt) * 180 + 180
		self:SetAngles(Angle(math.sin(rt * 0.8) * 180 + 180, adding2, adding2))
		self:SetModel(PowerupDrawModels[typ])
		-- self:SetModelScale(PowerupDrawScales[typ] or 1)
		self:SetModelScale(1)
		self:DrawModel()
	else
		local size = math.sin(rt * 5) * 60 + 90
		local size2 = math.cos(rt * 5) * 60 + 90
		render.SetMaterial(matRing)
		if string.sub(typ, 1, 7) == "weapon_" then
			render.DrawSprite(pos, size2, size, col)
			render.DrawSprite(pos, size, size2, col)
			render.DrawSprite(pos, size2, size2, col)
			render.DrawSprite(pos, size, size, col)
		else
			render.DrawSprite(pos, size2, size, colPowerup)
			render.DrawSprite(pos, size, size2, colPowerup)
			render.DrawSprite(pos, size2, size2, colPowerup)
			render.DrawSprite(pos, size, size, colPowerup)
		end
	end

	cam.Start3D2D(pos, Angle(0, 90, 90), 1.6 + math.cos(5 * rt) * 0.25)
		draw.DrawTextShadow(self:GetPickupName(), "Default", 0, 0, color_white, color_black, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
