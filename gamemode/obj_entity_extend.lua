local meta = FindMetaTable("Entity")
if not meta then return end

function meta:FireOutput(outpt, activator, caller)
	local intab = self[outpt]
	if intab then
		for key, tab in pairs(intab) do
			for __, subent in pairs(ents.FindByName(tab.entityname)) do
				if tab.delay == 0 then
					subent:Input(tab.input, activator, caller, tab.args)
				else
					timer.Simple(tab.delay, function() if subent:IsValid() then subent:Input(tab.input, activator, caller, tab.args) end end)
				end
			end
		end
	end
end

function meta:AddOnOutput(key, value)
	self[key] = self[key] or {}
	local tab = string.Explode(",", value)
	table.insert(self[key], {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
end

function meta:SetNextAttack(tim)
	self:SetDTFloat(3, tim)
end

function meta:GetNextAttack()
	return self:GetDTFloat(3)
end

if SERVER then
	function meta:SetModelScale(vec)
		if not self.vOriginalModelScaleMin then
			self.vOriginalModelScaleMin = self:OBBMins()
			self.vOriginalModelScaleMax = self:OBBMaxs()
		end

		local minv = self.vOriginalModelScaleMin * vec
		local maxv = self.vOriginalModelScaleMax * vec
		self:PhysicsInitBox(minv, maxv)
		--self:SetCollisionBounds(minv, maxv)

		self.vModelScale = vec
		self.BR = self:BoundingRadius()
	end

	function meta:GetModelScale()
		return self.vModelScale or Vector(1, 1, 1)
	end
end
