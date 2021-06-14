local meta = FindMetaTable("Player")
if not meta then return end

function meta:GetTeamName()
	return team.GetName(self:Team()) or "None"
end

function meta:ConvertNet()
	return ConvertNet(self:SteamID())
end

meta.GetBox = debug.getregistry()["Entity"].GetOwner
meta.SetBox = debug.getregistry()["Entity"].SetOwner

if SERVER then
	function meta:ScreenShake(duration, frequency, amplitude)
		-- umsg.Start("screenshake", self)
		-- 	umsg.Float(duration)
		-- 	umsg.Float(frequency)
		-- 	umsg.Float(amplitude)
		-- umsg.End()
		util.AddNetworkString("screenshake")
		net.Start("screenshake")
			net.WriteFloat(duration)
			net.WriteFloat(frequency)
			net.WriteFloat(amplitude)
		net.Send(self)
	end

	function meta:RemoveAllStatus(bSilent, bInstant)
		if bInstant then
			for _, ent in pairs(ents.FindByClass("status_*")) do
				local owner =  ent:GetOwner()
				if owner:IsValid() and not ent.NoRemoveOnDeath and owner:GetOwner() == self then
					ent:Remove()
				end
			end
		else
			for _, ent in pairs(ents.FindByClass("status_*")) do
				local owner =  ent:GetOwner()
				if owner:IsValid() and not ent.NoRemoveOnDeath and owner:GetOwner() == self then
					ent.SilentRemove = bSilent
					ent:SetDie()
				end
			end
		end
	end

	function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
		local removed
		for _, ent in pairs(ents.FindByClass("status_"..sType)) do
			if sExclude and ent:GetClass() ~= sExclude then
				local owner = ent:GetOwner()
				if owner:IsValid() and owner:GetOwner() == self then
					if bInstant then
						ent:Remove()
					else
						ent.SilentRemove = bSilent
						ent:SetDie()
					end
					removed = true
				end
			end
		end
		return removed
	end

	function meta:GetStatus(sType)
		local ent = self["status_"..sType]
		if ent and ent:IsValid() then
			if ent.Owner == self then
				return ent
			end
		end
	end

	function meta:GiveStatus(sType, fDie)
		local cur = self:GetStatus(sType)
		if cur then
			cur:SetPlayer(self, true)
			if fDie then
				cur:SetDie(fDie)
			end
			return cur
		else
			local ent = ents.Create("status_"..sType)
			if ent:IsValid() then
				ent:Spawn()
				ent:SetPlayer(self)
				if fDie then
					ent:SetDie(fDie)
				end
				return ent
			end
		end
	end
	meta.Give = meta.GiveStatus

	function meta:ForceRespawn()
		self:StripWeapons()
		self.LastDeath = CurTime()
		self:RemoveAllStatus(true, true)
		self:Spawn()
		self.SpawnTime = CurTime()
	end
end

if CLIENT then
	function meta:GetStatus(sType)
		for _, ent in ents.FindByClass("status_"..sType) do
			local owner = ent:GetOwner()
			if owner:IsValid() and owner:GetOwner() == self then return ent end
		end
	end

	function meta:ScreenShake(duration, frequency, amplitude)
		SCREENSHAKEDURATION = math.max(SCREENSHAKEDURATION, CurTime() + duration)
		SCREENSHAKEFREQ = math.max(SCREENSHAKEFREQ, frequency)
		SCREENSHAKEAMP = math.max(SCREENSHAKEAMP, amplitude)
	end
end

local oldalive = meta.Alive
function meta:Alive()
	if self:Team() == TEAM_SPECTATE then return false end

	return oldalive(self)
end
