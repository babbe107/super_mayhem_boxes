include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

local colTimeRoller = Color(50, 70, 255, 220)

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:SetModelScale(1)
	end
end

local matRing = Material("effects/select_ring")
local matGlow = Material("sprites/light_glow02_add")
local colTimeRoller = Color(50, 70, 255, 255)
local colTimeRoller2 = Color(150, 150, 150, 255)
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:SetModelScale(0.25)
		local rt = RealTime() * 5
		local pos = self:GetPos()

		local size = math.sin(rt) * 90 + 120
		local size2 = math.cos(rt) * 90 + 120
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, size * 4, size * 4, colTimeRoller2)
		render.SetMaterial(matRing)
		render.DrawSprite(pos, size2, size, colTimeRoller)
		render.DrawSprite(pos, size, size2, colTimeRoller)
		render.DrawSprite(pos, size2, size2, colTimeRoller)
		render.DrawSprite(pos, size, size, colTimeRoller)

		self:DrawModel()
	end
end
