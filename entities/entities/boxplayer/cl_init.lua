include("shared.lua")

function ENT:Initialize()
	self.Weapon = NULL
	self.LastPredict = 0
end

function ENT:OnRemove()
	if self.Predicter and self.Predicter:IsValid() then self.Predicter:Remove() end
end

function ENT:KeyPress(pl, key)
	local wep = self.Weapon
	if wep:IsValid() then wep:KeyPress(pl, self, key) end
end

function ENT:KeyRelease(pl, key)
	local wep = self.Weapon
	if wep:IsValid() then wep:KeyRelease(pl, self, key) end
end

--[[local ShadowParams = {secondstoarrive = 0.01, maxangular = 1, maxangulardamp = 10000, maxspeed = 32000, maxspeeddamp = 1000, dampfactor = 0.1, teleportdistance = 0}
function ENT:GetPredictedPos()
	if self:GetOwner() ~= MySelf then return self:GetPos() end
	if self.LastPredict == CurTime() then return self.LastPredictPos end

	if not self.Predicter then
		local ent = ents.Create("prop_physics")
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetModel(self:GetModel())
		--ent:SetNoDraw(true)
		ent:DrawShadow(false)
		ent:Spawn()
		ent:PhysicsInitBox(self:OBBMins(), self:OBBMaxs())  
		ent:SetCollisionBounds(self:OBBMins(), self:OBBMaxs())  
		ent:SetMoveType(MOVETYPE_VPHYSICS)  
		ent:SetSolid(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(true)
			phys:Wake()
			phys:ApplyForceCenter(phys:GetMass() * self:GetVelocity())
		end
		self.Predicter = ent
	end

	local owner = MySelf
	local deltatime = FrameTime()

	local vel = self:GetVelocity()

	local onground, onobject = self:Grounded()
	if owner:KeyDown(IN_MOVELEFT) then
		if not owner:KeyDown(IN_MOVERIGHT) then
			if onground then
				vel = vel + Vector(0, -1400 * deltatime, 0)
			else
				vel = vel + Vector(0, -650 * deltatime, 0)
			end
		end
	elseif owner:KeyDown(IN_MOVERIGHT) then
		if not owner:KeyDown(IN_MOVELEFT) then
			if onground then
				vel = vel + Vector(0, 1400 * deltatime, 0)
			else
				vel = vel + Vector(0, 650 * deltatime, 0)
			end
		end
	end

	local pos = self:GetPos()
	self.Predicter:SetPos(pos)
	local nextpos = pos + owner:Ping() * 0.001 * vel

	ShadowParams.pos = nextpos
	ShadowParams.angle = self:GetAngles()
	ShadowParams.deltatime = deltatime

	local phys = self.Predicter:GetPhysicsObject()
	phys:Wake()
	phys:SetVelocity(phys:GetVelocity() * -1)
	phys:ComputeShadowControl(ShadowParams)

	--local tr = util.TraceHull({start = pos, endpos = nextpos, mask = MASK_SOLID, mins = self:OBBMins(), maxs = self:OBBMaxs(), filter = self})
	--if tr.Hit and tr.HitNormal:Dot(vel:Normalize()) < 0 then
		--nextpos = tr.HitPos + tr.HitNormal * self:OBBMaxs().z -- Assuming we're always a cube.
	--end

	self.LastPredict = CurTime()
	self.LastPredictPos = self.Predicter:GetPos()
	return self.LastPredictPos
end
]]
ENT.GetPredictedPos = debug.getregistry().Entity.GetPos

local matWire = Material("shadertest/wireframe")
local matEye = Material("mayhem/boxeye")
local matSmile = Material("mayhem/boxsmile")
local vecfacing = Vector(1, 0, 0)
function ENT:Draw()
	self:DrawModel()
	--[[if self:GetOwner() == MySelf then
		cam.Start3D(EyePos() + (self:GetPos() - self:GetPredictedPos()), EyeAngles())
			render.SuppressEngineLighting(true)
			SetMaterialOverride(matWire)
			self:DrawModel()
			SetMaterialOverride()
			render.SuppressEngineLighting(false)
		cam.End3D()
	end]]

	local maxs = self:OBBMaxs()
	local pos = self:GetPredictedPos() + vecfacing * (maxs.x + 8)

	local aimvec
	local health
	local pl = self:GetOwner()
	if pl:IsValid() then
		aimvec = pl:GetAimVector()
		health = pl:Health()
	else
		aimvec = Vector(0, 0, 0)
		health = 100
	end

	render.SetMaterial(matEye)
	if self:GetWinking() then
		render.DrawQuadEasy(pos + Vector(0, maxs.y * -0.6, maxs.z * 0.5) + aimvec * 5, vecfacing, 12, 2, color_white)
		render.DrawQuadEasy(pos + Vector(0, maxs.y * 0.6, maxs.z * 0.5) + aimvec * 5, vecfacing, 12, 2, color_white)
	else
		render.DrawQuadEasy(pos + Vector(0, maxs.y * -0.6, maxs.z * 0.5) + aimvec * 5, vecfacing, 12, 12, color_white)
		render.DrawQuadEasy(pos + Vector(0, maxs.y * 0.6, maxs.z * 0.5) + aimvec * 5, vecfacing, 12, 12, color_white)
	end
	render.SetMaterial(matSmile)
	local frac = health * 0.01
	if 0.5 < frac then
		render.DrawQuadEasy(pos + Vector(0, 0, maxs.z * -0.35), vecfacing, 16, math.max(0.1, frac) * 16, color_white, 180)
	else
		render.DrawQuadEasy(pos + Vector(0, 0, maxs.z * -0.35), vecfacing, 16, math.max(0.1, 1 - frac) * 16, color_white)
	end
end
