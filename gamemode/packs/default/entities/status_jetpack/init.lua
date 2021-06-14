AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/canister_propane01a.mdl")
	self:DrawShadow(false)

	self.Fuel = 10
end

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local pl = owner:GetOwner()
		if pl:IsValid() then
			local kd = pl:KeyDown(IN_SPEED)
			if self.On and not kd then
				self.On = false
				self:SetDTBool(0, false)
			elseif not self.On and kd then
				self.On = true
				self:SetDTBool(0, true)
			end

			if self.On then
				owner:GetPhysicsObject():ApplyForceCenter(53333 * FrameTime() * pl:GetAimVector())
				self.Fuel = self.Fuel - FrameTime()
				if self.Fuel <= 0 then
					self:Remove()
				end
			end

			self:NextThink(CurTime())
			return true
		end
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	if bExists then
		self.Fuel = 10
	else
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
