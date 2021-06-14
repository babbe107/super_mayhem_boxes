include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-100, -100, -100), Vector(100, 100, 100))
	if MySelf:IsValid() and self:GetOwner() == MySelf:GetBox() then
		MySelf:GetBox().Weapon = self
	end
end

function ENT:OnRemove()
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local player = owner:GetOwner()
	if not player:IsValid() then return end

	self:SetColor(owner:GetColor())
	local dir = player:GetAimVector()
	local ang = dir:Angle()
	self:SetPos(owner:GetPos() + dir * 28 + ang:Up() * 16)
	self:SetAngles(ang * -1)
	self:SetModelScale(2)
	self:DrawModel()
end

function ENT:HUD(pl, box, x, y)
	local ct = CurTime()
	if ct < self:GetNextAttack() then
		surface.SetDrawColor(255, 255, 255, 180)
		local len = math.ceil((self:GetNextAttack() - ct) * 8.5333)
		surface.DrawRect(x - len * 0.5, y + 33, len, 6)
	end
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() then
		local dir = pl:GetAimVector()
		-- if util.PointContents(box:GetPos() + dir * 4 + dir:Angle():Up() * 16) and CONTENTS_WATER ~= 32 then
		if util.PointContents(box:GetPos() + dir * 4 + dir:Angle():Up() * 16) and bit.band( util.PointContents(box:GetPos()), CONTENTS_WATER ) ~= CONTENTS_WATER then
		-- if util.PointContents(box:GetPos() + dir * 4 + dir:Angle():Up() * 16) then
			self:SetNextAttack(CurTime() + 7.5)
			self:NextThink(CurTime())
		end
	end
end
