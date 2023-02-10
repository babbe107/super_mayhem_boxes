function EFFECT:Init(data)
	local dir = data:GetNormal() * -1
	self.Dir = dir
	local pos = data:GetOrigin() + dir * 0.5
	self.EndPos = pos
	self.TeamID = math.Round(data:GetMagnitude())
	local col = team.GetColor(self.TeamID) or color_white
	self.Col = col
	local colr,colg,colb = col
	self.DieTimeTwo = CurTime() + 0.25
	self.SpriteSize = math.Rand(14, 20)

	util.Decal("Impact.Concrete", pos + dir, pos - dir)

	-- WorldSound("weapons/fx/rics/ric"..math.random(1, 5)..".wav", pos, 74, math.Rand(190, 255))
	sound.Play("weapons/fx/rics/ric"..math.random(1, 5)..".wav", pos, 74, math.Rand(190, 255))

	self.Entity:SetModel("models/Weapons/w_bullet.mdl")
	self.Entity:SetMaterial("models/shiny")
	self.Entity:SetColor(colr, colg, colb, 255)
	self.Entity:SetModelScale(3)
	self.Entity:SetAngles(self.Dir:Angle())
end

function EFFECT:Think()
	return CurTime() < self.DieTimeTwo
end

--local matGlow = Material("sprites/glow04_noz")
local matGlow = Material("effects/yellowflare")
function EFFECT:Render()
	local ct = CurTime()
	local colr, colg, colb = self.Col
	if not self.EndParticles then
		self.EndParticles = true
		local emitter = ParticleEmitter(self.EndPos)
		for i=1, math.random(13, 18) do
			local particle = emitter:Add("effects/yellowflare", self.EndPos)
			particle:SetDieTime(math.Rand(0.3, 0.5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(8)
			if not self.Dir then
				self.Dir = 0
			end
			particle:SetVelocity((VectorRand():GetNormalized() + self.Dir):GetNormalized() * math.Rand(500, 900))
			particle:SetAirResistance(1000)
			particle:SetColor(r, g, b)
		end
	end

	local siz = (self.DieTimeTwo - ct) * 512
	render.SetMaterial(matGlow)
	render.DrawSprite(self.EndPos, siz, siz, col)
	render.SetMaterial(matGlow)
	render.DrawQuadEasy(self.EndPos + self.Dir * 0.1, self.Dir, siz, siz, col)
	self.Entity:SetColor(colr,colg,colb, math.min(255, siz))
	self.Entity:SetPos(self.EndPos)

	self.Entity:DrawModel()
end
