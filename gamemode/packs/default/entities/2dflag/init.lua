AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Roller_Spikes.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.Carrier = self
	self.NextCantTakeMsg = 0
	self.LastDrop = 0
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:EnableMotion(false)
		phys:Wake()
	end

	local col = team.TeamInfo[self.Team].Color
	self:SetColor(col.r, col.g, col.b, 255)

	self:SetName(self.Team)
end

function ENT:Drop(box)
	local pl = NULL
	if box and box:IsValid() then pl = box:GetOwner() end

	local byplayer = "itself"

	if pl and pl:IsValid() then
		byplayer = pl:Name()
	end

	constraint.RemoveConstraints(self, "Rope")

	self:SetTrigger(false)
	self.Carrier = self
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():Wake()
	self.LastDrop = CurTime()
	self.AutoReturnTimer = CurTime() + 30
	self:SetDTInt(0, 2)

	gamemode.Call("FlagDropped", self.Team, byplayer)
end

function ENT:Return(pl, box, far, dist)
	local myteam = self.Team
	local flagpoint = team.TeamInfo[myteam].FlagPoint

	if far then
		-- umsg.Start("FlagReturnEffect")
		-- 	umsg.Vector(self:GetPos())
		-- 	umsg.Vector(flagpoint)
		-- 	umsg.Short(myteam)
		-- umsg.End()
		util.AddNetworkString("FlagReturnEffect")
		net.Start("FlagReturnEffect")
			net.WriteVector(self:GetPos())
			net.WriteVector(flagpoint)
			net.WriteInt(myteam, 16)
		net.Broadcast()
	end

	constraint.RemoveConstraints(self, "Rope")
	constraint.RemoveConstraints(self, "Weld")

	self:SetTrigger(false)
	self:SetPos(flagpoint)
	self.Carrier = self
	self:GetPhysicsObject():EnableMotion(false)
	self.AutoReturnTimer = nil
	self:SetDTInt(0, 0)

	gamemode.Call("FlagReturned", pl, box, myteam, far, dist)
end

function ENT:Capture(pl, box, otherflag)
	local myteam = self.Team
	local flagpoint = team.TeamInfo[myteam].FlagPoint

	local otherflag = ents.FindByClass("2dflag")
	if otherflag[1] == self then otherflag = otherflag[2] else otherflag = otherflag[1] end
	local otherteam = otherflag.Team
	local otherflagpoint = team.TeamInfo[otherteam].FlagPoint

	constraint.RemoveConstraints(self, "Rope")
	constraint.RemoveConstraints(self, "Weld")

	self:SetTrigger(false)
	self:SetPos(flagpoint)
	self.Carrier = self
	self:GetPhysicsObject():EnableMotion(false)
	self.AutoReturnTimer = nil
	self:SetDTInt(0, 0)
	self.TouchCoolDown = CurTime() + 0.5

	constraint.RemoveConstraints(otherflag, "Rope")
	constraint.RemoveConstraints(otherflag, "Weld")

	otherflag:SetPos(otherflagpoint)
	otherflag.Carrier = otherflag
	otherflag:GetPhysicsObject():EnableMotion(false)
	otherflag.AutoReturnTimer = nil
	otherflag:SetDTInt(0, 0)

	gamemode.Call("FlagCaptured", pl, box, myteam, otherteam)
end

function ENT:Pickup(pl, box)
	self:SetTrigger(true)
	self.Carrier = box
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():Wake()
	self:SetDTInt(0, 1)

	self.AutoReturnTimer = nil

	constraint.Rope(box, self, 0, 0, Vector(0,0,0), Vector(0,0,0), 100, 32, 0, 4.5, "cable/rope", false)

	gamemode.Call("FlagPickedUp", pl, box, self.Team)
end

function ENT:ThinkTouched(hitent)
	if ENDGAME then return end

	if hitent:GetClass() == "boxplayer" then
		local carrier = self.Carrier
		if not carrier:IsValid() then self.Carrier = self carrier = self end

		local pl = hitent:GetOwner()
		local plteam = pl:Team()

		local otherflag = ents.FindByClass("2dflag")
		if otherflag[1] == self then otherflag = otherflag[2] else otherflag = otherflag[1] end

		local myteam = self.Team
		if carrier == self then -- At base or dropped in the field
			if self:GetPhysicsObject():IsMoveable() then -- Dropped in the field
				if plteam == myteam then -- Return it.
					local distfromhome = self:GetPos():Distance(team.TeamInfo[myteam].FlagPoint)
					self:Return(pl, hitent, 512 < distfromhome, distfromhome)
				else -- Pick it up.
					self:Pickup(pl, hitent)
				end
			else -- At home.
				if plteam == myteam then -- Our own team.
					if otherflag.Carrier == hitent then -- Carrying the other team's flag?
						self:Capture(pl, hitent, otherflag) -- i won!
					end
				elseif 0 < team.NumPlayers(myteam) then -- Pick it up.
					self:Pickup(pl, hitent)
				elseif self.NextCantTakeMsg < CurTime() then
					pl:PrintMessage(HUD_PRINTCENTER, "You can't take the ball of an unrepresented team!")
					self.NextCantTakeMsg = CurTime() + 0.5
				end
			end
		end -- Being carried already. Don't do anything.
	end
end

function ENT:Think()
	if self.ThinkHitEntity then
		if self.ThinkHitEntity:IsValid() then
			self:ThinkTouched(self.ThinkHitEntity)
		end
		self.ThinkHitEntity = nil
	end

	if self.AutoReturnTimer and self.AutoReturnTimer <= CurTime() then
		self:Return(nil, nil, true)
	else
		local carrier = self.Carrier
		if carrier ~= self and not carrier:IsValid() then
			self:Drop(carrier)
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

util.PrecacheSound("npc/turret_floor/click1.wav")
function ENT:PhysicsCollide(data, phys)
	if 50 < data.Speed and 0.3 < data.DeltaTime then
		self:EmitSound("npc/turret_floor/click1.wav")
	end

	if data.HitEntity and data.HitEntity:IsValid() and (self.TouchCoolDown or 0) <= CurTime() then
		self.ThinkHitEntity = data.HitEntity
		self:NextThink(CurTime())
	end
end

--[[function ENT:ShouldNotCollide(ent)
	return self.Carrier ~= self and ent:IsValid() and ent:GetClass() == "trigger_teleport"
end]]

function ENT:TouchBoxHurter(ent)
	if self.Carrier == self and 100 <= ent.Damage and self:GetPhysicsObject():IsMoveable() then
		self:Return(nil, nil, true)
	end
end
