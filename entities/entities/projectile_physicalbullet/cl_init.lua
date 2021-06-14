include("shared.lua")

function ENT:Initialize()
	--self:SetModel("models/crossbow_bolt.mdl")
	self:SetModel("models/Weapons/w_bullet.mdl")
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-60, -60, -60), Vector(60, 60, 60))
end

function ENT:Think()
end

function ENT:OnRemove()
end

local matBeam = Material("effects/spark")
function ENT:Draw()
	self:DrawModel()
	render.SetMaterial(matBeam)
	local pos = self:GetPos()
	local norm = self:GetVelocity():GetNormalized()
	local col = self:GetColor() -- Color(self:GetColor())
	local start = pos + norm * 10
	local endpos = pos - norm * 40
	render.DrawBeam(start, endpos, 16, 1, 0, col)
	render.DrawBeam(start, endpos, 12, 1, 0, col)
end
