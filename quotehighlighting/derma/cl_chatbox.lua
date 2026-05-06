local PLUGIN = PLUGIN


local maxChatEntries = 100

-- chatbox history panel
-- holds individual messages in a scrollable panel
PANEL = {}

AccessorFunc(PANEL, "filter", "Filter") -- blacklist of message classes
AccessorFunc(PANEL, "id", "ID", FORCE_STRING)
AccessorFunc(PANEL, "button", "Button") -- button panel that this panel corresponds to

function PANEL:Init()
	self:DockMargin(4, 2, 4, 4) -- smaller top margin to help blend tab button/history panel transition
	self:SetPaintedManually(true)

	local bar = self:GetVBar()
	bar:SetWide(0)

	self.entries = {}
	self.filter = {}
end

DEFINE_BASECLASS("Panel") -- DScrollPanel doesn't have SetVisible member
function PANEL:SetVisible(bState)
	self:GetCanvas():SetVisible(bState)
	BaseClass.SetVisible(self, bState)
end

DEFINE_BASECLASS("DScrollPanel")
function PANEL:PerformLayoutInternal()
	local bar = self:GetVBar()
	local bScroll = !ix.gui.chat:GetActive() or bar.Scroll == bar.CanvasSize -- only scroll when we're not at the bottom/inactive

	BaseClass.PerformLayoutInternal(self)

	if (bScroll) then
		self:ScrollToBottom()
	end
end

function PANEL:ScrollToBottom()
	local bar = self:GetVBar()
	bar:SetScroll(bar.CanvasSize)
end

-- adds a line of text as described by its elements
function PANEL:AddLine(elements, bShouldScroll)
	-- table.concat is faster than regular string concatenation where there are lots of strings to concatenate
	local buffer = {
		"<font=ixChatFont>"
	}

	if (ix.option.Get("chatTimestamps", false)) then
		buffer[#buffer + 1] = "<color=150,150,150>("

		if (ix.option.Get("24hourTime", false)) then
			buffer[#buffer + 1] = os.date("%H:%M")
		else
			buffer[#buffer + 1] = os.date("%I:%M %p")
		end

		buffer[#buffer + 1] = ") "
	end

	if (CHAT_CLASS) then
		buffer[#buffer + 1] = "<font="
		buffer[#buffer + 1] = CHAT_CLASS.font or "ixChatFont"
		buffer[#buffer + 1] = ">"
	end

	for _, v in ipairs(elements) do
		if (type(v) == "IMaterial") then
			local texture = v:GetName()

			if (texture) then
				buffer[#buffer + 1] = string.format("<img=%s,%dx%d> ", texture, v:Width(), v:Height())
			end
		elseif (istable(v) and v.r and v.g and v.b) then
			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>", v.r, v.g, v.b)
		elseif (type(v) == "Player") then
			local color = team.GetColor(v:Team())

			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>%s", color.r, color.g, color.b,
				v:GetName():gsub("<", "&lt;"):gsub(">", "&gt;"))
		else
			buffer[#buffer + 1] = tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("%b**", function(value)
				local inner = value:utf8sub(2, -2)

				if (inner:find("%S")) then
					return "<font=ixChatFontItalics>" .. value:utf8sub(2, -2) .. "</font>"
				end
			end)
		end
	end

		-- QUOTE HIGHLIGHTING
	local concat = table.concat(buffer)
	if CHAT_CLASS and (CHAT_CLASS.uniqueID != "looc" and CHAT_CLASS.uniqueID != "ooc") then
		if ix.option.Get("quoteHighlight", true) then
			concat = concat:gsub("%b\"\"", function(value)
				local inner = value:utf8sub(1, -1)
				local color = ix.option.Get("quoteHighlightColor")

				if (inner:find("%S")) then
					return string.format("<color=%d,%d,%d>\"", color.r, color.g, color.b)  .. value:utf8sub(2, -2) .. "\"</color>"
				end
			end)
		end
	end

	local panel = self:Add("ixChatMessage")
	panel:Dock(TOP)
	panel:InvalidateParent(true)
	panel:SetMarkup(concat)

	if (#self.entries >= maxChatEntries) then
		local oldPanel = table.remove(self.entries, 1)

		if (IsValid(oldPanel)) then
			oldPanel:Remove()
		end
	end

	self.entries[#self.entries + 1] = panel
	return panel
end

vgui.Register("ixChatboxHistory", PANEL, "DScrollPanel")