local HUDNotes = {}
function GM:AddNotify(str, color, length, font)
	if not str then return end

	length = length or 4
	color = color or color_white

	local findmin, findmax, text, snd = string.find(str, "(.+)~w(.+)")
	if text and str then
		str = text
		surface.PlaySound(snd)
	end

	for _, note in pairs(HUDNotes) do
		if note.text == str then
			note.death = RealTime() + length
			note.color = table.Copy(color)
			if length <= 1 then
				note.color.a = math.floor(length * 255)
			end
			return
		end
	end

	local tab = {}
	tab.text = str
	tab.death = RealTime() + length
	tab.color = table.Copy(color)
	tab.font = font or "mayhem22"

	if 12 < #HUDNotes then
		table.remove(HUDNotes, #HUDNotes)
	end

	table.insert(HUDNotes, 1, tab)
end

local colBlack = Color(0, 0, 0, 255)
function GM:PaintNotes()
	if #HUDNotes == 0 then return end

	local rt = RealTime()
	local y = h * 0.35
	local x = w * 0.5
	for i, note in ipairs(HUDNotes) do
		if note then
			if rt <= note.death then
				if note.death - rt <= 1 then
					note.color.a = math.floor((note.death - rt) * 255)
				end
				colBlack.a = note.color.a
				draw.DrawTextShadow(note.text, note.font, x, y, note.color, colBlack, TEXT_ALIGN_CENTER)
				local addx, addy = surface.GetTextSize(note.text)
				y = y - addy
			else
				table.remove(HUDNotes, i)
				i = i - 1
			end
		end
	end
end
