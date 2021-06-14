AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.KeyValues = {"RespawnTime", "CycleTime", "CurrentPowerup", "AllPowerups"}

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(false)

	self:SetCollisionBounds(Vector( -48, -48, -48), Vector(48, 48, 48))
	self:PhysicsInitBox(Vector(-48, -48, -48), Vector(48, 48, 48))

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions(false)
		phys:EnableMotion(false)
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetTrigger(true)
	self:SetNotSolid(true)

	self.IsVisible = true

	self.RespawnTime = self.RespawnTime or 10
	self.CycleTime = self.CycleTime or 1.5
	self.CurrentPowerup = self.CurrentPowerup or 1
	self.AllPowerups = self.AllPowerups or {"weapon_pistol"}

	self:SetPickupType(self.AllPowerups[self.CurrentPowerup])

	self:Fire("cycle", "", self.CycleTime)
end

function ENT:AcceptInput(input, args, activator, caller)
	if input == "cycle" then
		self:Fire("cycle", "", self.CycleTime)

		local leng = #self.AllPowerups
		if 1 < leng then
			local curp = self.CurrentPowerup
			if leng == curp then
				self.CurrentPowerup = 1
			else
				self.CurrentPowerup = curp + 1
			end

			self:SetPickupType(self.AllPowerups[self.CurrentPowerup])
		end

		return true
	elseif input == "revisible" then
		self:SetNoDraw(false)
		self.IsVisible = true
		return true
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "powerups" then
		self.AllPowerups = string.Explode(",", value)
		for	i, powerup in ipairs(self.AllPowerups) do
			if not PickupTranslates[powerup] and not PICKUP_GROUPS[powerup] and (PickupTranslates["weapon_"..powerup] or PICKUP_GROUPS["weapon_"..powerup]) then
				self.AllPowerups[i] = "weapon_"..powerup
			end
		end
		self:SetPickupType(self.AllPowerups[1])
	elseif key == "cycletime" then
		self.CycleTime = tonumber(value) or self.CycleTime
	elseif key == "respawntime" then
		self.RespawnTime = tonumber(value) or self.RespawnTime
	end
end

function ENT:Touch(ent)
	if self.IsVisible and ent:GetClass() == "boxplayer" then

		--for k, v in pairs(self.AllPowerups) do
		--	print("[self.AllPowerups] " .. k, v)
		--end
		--print("[self.CurrentPowerup] ".. self.CurrentPowerup)

		local pik = self.AllPowerups[self.CurrentPowerup]
		--print("[pik] ".. pik)

		
		if PICKUP_GROUPS[pik] then
			--for k, v in pairs(PICKUP_GROUPS[pik]) do
			--	print(PICKUP_GROUPS[pik])
			--	print("PICKUP_GROUPS[pik] " .. k, v)
			--end
			pik = PICKUP_GROUPS[pik][math.random(1, #PICKUP_GROUPS[pik])]

		end

		if not (ent.Weapon:IsValid() and ent.Weapon:GetClass() == "status_"..pik) and (string.sub(pik, 1, 7) ~= "weapon_" or ent:GetOwner():KeyDown(IN_USE) or not ent.Weapon:IsValid()) then
			--print(pik)
			--print(ent:GetOwner())
			ent:GetOwner():GiveStatus(pik)
			if self.RespawnTime == -1 then
				self:Remove()
			else
				self:SetNoDraw(true)
				self.IsVisible = false
				self:Fire("revisible", "", self.RespawnTime)
			end
		end
	end
end
