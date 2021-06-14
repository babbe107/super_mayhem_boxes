function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.DieTime = CurTime() + 0.5
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

function EFFECT:Render()
	local ent = self.Ent
	if ent:IsValid() then
		local selfent = self.Entity
		selfent:SetModel(ent:GetModel())
		local timeleft = self.DieTime - CurTime()
		local scale = timeleft * 8
		-- selfent:SetModelScale(ent:GetModelScale() + Vector(scale, scale, scale))
		selfent:SetModelScale(ent:GetModelScale() + scale)
		local r,g,b,a = ent:GetColor()
		if not a then
			a = 255
		end
		selfent:SetColor(r, g, b, timeleft * 160 * (a / 255))
		selfent:SetPos(ent:GetPos())
		selfent:SetAngles(ent:GetAngles())
		selfent:SetMaterial("models/props_combine/tpballglow")
		selfent:DrawModel()
	end
end
