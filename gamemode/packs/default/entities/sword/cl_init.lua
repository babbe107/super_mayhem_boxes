include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.Pos = {self:GetPos() + self:GetUp() * -20}
	self.NextBeam = 0
end

function ENT:Think()
	if self.NextBeam < CurTime() then
		self.NextBeam = CurTime() + 0.02

		local tpos = #self.Pos
		table.insert(self.Pos, 1, self:GetPos() + self:GetUp() * -20)

		if 10 < tpos then
			table.remove(self.Pos, tpos + 1)
		end
	end
end

function ENT:OnRemove()
end

local matTrail = Material("Effects/laser1")
function ENT:Draw()
	render.SetMaterial(matTrail)
	local scroll = CurTime() * -20
	local col = self:GetColor() -- Color(self:GetColor())
	render.StartBeam(#self.Pos + 1)
		render.AddBeam(self:GetPos() + self:GetUp() * -20, 120, scroll, col)
		for i=1, #self.Pos do
			render.AddBeam(self.Pos[i], 120 - i * 8, scroll + i, col)
		end
	render.EndBeam()

	self:DrawModel()
end
