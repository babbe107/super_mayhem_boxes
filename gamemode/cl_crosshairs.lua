local PANEL = {}

function PANEL:Paint()
	if MySelf:IsValid() then
		local x, y = gui.MousePos()
		local wide, tall = self:GetSize()
		self:SetPos(x - wide * 0.5, y - tall * 0.5)

		local box = MySelf:GetBox()
		if box:IsValid() then
			local wep = box.Weapon
			if wep and wep:IsValid() and wep.PaintCrosshair then
				wep:PaintCrosshair(wide, tall)
			else
				--[[surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(0, tall * 0.5 - 2, wide, 4)
				surface.DrawRect(wide * 0.5 - 2, 0, 4, tall)
				surface.SetDrawColor(255, 25, 25, 255)
				surface.DrawRect(2, tall * 0.5 - 1, wide - 4, 2)
				surface.DrawRect(wide * 0.5 - 1, 2, 2, tall - 4)]]

				local barwide = wide * 0.35
				local bartall = tall * 0.35
				local halfwide = wide * 0.5
				local halftall = tall * 0.5
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(0, halftall - 2, barwide, 4)
				surface.DrawRect(wide - barwide, halftall - 2, barwide, 4)
				surface.DrawRect(halfwide - 2, 0, 4, bartall)
				surface.DrawRect(halfwide - 2, tall - bartall, 4, bartall)
				surface.SetDrawColor(255, 25, 25, 255)
				surface.DrawRect(0, halftall - 1, barwide, 2)
				surface.DrawRect(wide - barwide, halftall - 1, barwide, 2)
				surface.DrawRect(halfwide - 1, 0, 2, bartall)
				surface.DrawRect(halfwide - 1, tall - bartall, 2, bartall)
			end
		end
	end

	return true
end

function PANEL:Think()
	local x, y = self:GetPos()
	if x < 0 or y < 0 or w < x or h < y then
		self:SetPos(math.Clamp(x, 0, w), math.Clamp(y, 0, h))
	end
end

function PANEL:OnMousePressed(mc)
	if mc == MOUSE_LEFT then
		RunConsoleCommand("+attack")
	elseif mc == MOUSE_RIGHT then
		RunConsoleCommand("+attack2")
	end
end

function PANEL:OnMouseReleased(mc)
	if mc == MOUSE_LEFT then
		RunConsoleCommand("-attack")
	elseif mc == MOUSE_RIGHT then
		RunConsoleCommand("-attack2")
	end
end

vgui.Register("CrosshairPanel", PANEL, "Panel")
