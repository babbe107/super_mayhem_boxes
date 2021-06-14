AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DieTime = 0

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:SetPlayer(pPlayer, bExists)
	if bExists then
		self:PlayerSet(pPlayer, pPlayer:GetBox(), bExists)
	elseif pPlayer and pPlayer:IsValid() then
		local eBox = pPlayer:GetBox()
		self:SetPos(eBox:GetPos())
		pPlayer[self:GetClass()] = self
		self:SetOwner(eBox)
		self:SetParent(eBox)
		self:PlayerSet(pPlayer, eBox)
		self.Owner = pPlayer
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
end

function ENT:Think()
	-- Any kind of active effect.

	if self.DieTime <= CurTime() then
		self:Remove()
	end
end

function ENT:KeyValue(key, value)
	if key == "dietime" then
		self:SetDie(tonumber(value))
		return true
	end
end

function ENT:PhysicsCollide(data, physobj)
end

function ENT:Touch(ent)
end

function ENT:OnRemove()
	--[[if not self.SilentRemove and self:GetParent():IsValid() then
		-- Emit death sound
	end]]
end

function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	else
		self.DieTime = CurTime() + fTime
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end
