AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	if self.DieTime < CurTime() then
		self:Remove()
	else
		local box = self:GetOwner()
		if box:IsValid() then
			if 0 < box:WaterLevel() then
				self:Remove()
			else
				box:TakeDamage(1, self.Attacker, self)
				self:NextThink(CurTime() + 0.15)
				return true
			end
		end
	end
end

util.PrecacheSound("ambient/fire/ignite.wav")
function ENT:PlayerSet(pPlayer, eBox, bExists)
	if not bExists then
		pPlayer:EmitSound("ambient/fire/ignite.wav")
	end
end
