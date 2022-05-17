local addonName, addon = ...
local module = addon:CreateModule("ActionBars")

module.defaultSettings = {
	hideGryphons = false,
	hideArtwork = false,
	hideXPBar = false,
	hidePagingButtons = false,
	extraButtons = false,
	hideMacroNames = false,
	hideKeyBinds = false,
	shortKeybindText = false,
	altKeybindFont = false,
}

module.optionsTable = {
	header_visibility = {
		order = 1,
		type = "header",
		name = "Visibility",
	},
	hideGryphons = {
		order = 2,
		type = "toggle",
		name = "Hide gryphons",
		width = "full",
	},
	hideArtwork = {
		order = 3,
		type = "toggle",
		name = "Hide background art",
		width = "full",
	},
	hideXPBar = {
		order = 4,
		type = "toggle",
		name = "Hide experience bar",
		width = "full",
	},
	hidePagingButtons = {
		order = 5,
		type = "toggle",
		name = "Hide arrows from action bar",
		desc = "Arrows to switch main action bars by it's side",
		width = "full",
	},
	header_buttons = {
		order = 6,
		type = "header",
		name = "Buttons",
	},
	extraButtons = {
		order = 7,
		type = "toggle",
		name = "Extra buttons",
		width = "full",
	},
	hideMacroNames = {
		order = 8,
		type = "toggle",
		name = "Hide macro name",
		width = "full",
	},
	hideKeyBinds = {
		order = 9,
		type = "toggle",
		name = "Hide keybinds",
		width = "full",
	},
	shortKeybindText = {
		order = 10,
		type = "toggle",
		name = "Short key bind text",
		desc = "e.g. 'Ctrl+R' goes from 'c-R' to 'CR'",
		width = "full",
	},
	altKeybindFont = {
		order = 11,
		type = "toggle",
		name = "Clean keybind font",
		width = "full",
	},
}

local eventHandler = CreateFrame("Frame", nil, UIParent)
eventHandler:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function module:Clean()
	local db = self.db

	db.hideGryphons = true
	db.hideArtwork = true
	db.hideXPBar = true
	db.hidePagingButtons = true
	db.extraButtons = true
	db.hideMacroNames = false
	db.hideKeyBinds = false
	db.shortKeybindText = false
	db.altKeybindFont = false
end

function module:OnLoad()
	local db = self.db

	if db.hideGryphons then
		MainMenuBarArtFrame.RightEndCap:Hide()
		MainMenuBarArtFrame.LeftEndCap:Hide()
	end

	if db.hideArtwork then
		MainMenuBarArtFrameBackground.BackgroundSmall:SetAlpha(0)
		MainMenuBarArtFrameBackground.BackgroundLarge:SetAlpha(0)
		MainMenuBarArtFrameBackground.QuickKeybindGlowLarge:SetAlpha(0)
		MainMenuBarArtFrameBackground.QuickKeybindGlowSmall:SetAlpha(0)
		MultiBarBottomLeft.QuickKeybindGlow:SetAlpha(0)
		MultiBarBottomRight.QuickKeybindGlow:SetAlpha(0)
		MainMenuBarArtFrame.PageNumber:Hide()
		StanceBarLeft:SetAlpha(0)
		StanceBarRight:SetAlpha(0)
		StanceBarMiddle:SetAlpha(0)
		SlidingActionBarTexture0:SetAlpha(0)
		SlidingActionBarTexture1:SetAlpha(0)

		-- atualizar no 10.0 125-130(implementar api)
		MainMenuBar:EnableMouse(false)
		PetActionBarFrame:EnableMouse(false)

		MultiBarBottomLeft:SetMovable(true)
		MultiBarBottomLeft:SetUserPlaced(true)
	end

	if db.hideXPBar then
		StatusTrackingBarManager:SetAlpha(0)

		hooksecurefunc(StatusTrackingBarManager, "LayoutBar", function(self, bar)
			bar:SetPoint("BOTTOM", MainMenuBarArtFrameBackground, 0, select(5, bar:GetPoint()))
		end)
	end

	if db.hideArtwork or db.hideXPBar or db.extraButtons then
		hooksecurefunc("UIParent_ManageFramePositions", self.ManageBarPositions)
		eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
	end

	if db.hideArtwork or db.hideXPBar then
		self.PetActionBarFrame = CreateFrame("Frame", nil, PetActionBarFrame)
		self.PetActionBarFrame:SetSize(509, 43)

		for i = 1, 10 do
			local button = _G["PetActionButton"..i]
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", self.PetActionBarFrame, "BOTTOMLEFT", 36, 2)
			else
				button:SetPoint("LEFT", "PetActionButton"..i-1, "RIGHT", 8, 0)
			end
		end

		SlidingActionBarTexture0:ClearAllPoints()
		SlidingActionBarTexture0:SetPoint("TOPLEFT", self.PetActionBarFrame)

		StanceBarFrame.ignoreFramePositionManager = true
	end

	if db.hidePagingButtons then
		ActionBarDownButton:SetAlpha(0)
		ActionBarUpButton:SetAlpha(0)
	end

	local buttons = {}

	for i = 1, 12 do
		tinsert(buttons, _G["ActionButton"..i])
		tinsert(buttons, _G["MultiBarBottomLeftButton"..i])
		tinsert(buttons, _G["MultiBarBottomRightButton"..i])
		tinsert(buttons, _G["MultiBarLeftButton"..i])
		tinsert(buttons, _G["MultiBarRightButton"..i])
	end

	if db.hideKeyBinds then
		local function updateHotkeys(self)
			self.HotKey:Hide()
		end

		for _, button in pairs(buttons) do
			hooksecurefunc(button, "UpdateHotkeys", updateHotkeys)
		end
	
		hooksecurefunc("ActionButton_UpdateRangeIndicator", updateHotkeys)
		hooksecurefunc("PetActionButton_SetHotkeys", updateHotkeys)
	end

	if db.shortKeybindText then
		local function updateHotkeys(self)
			local hotkey = self.HotKey
			local text = hotkey:GetText()
	
			text = gsub(text, "(s%-)", "S")
			text = gsub(text, "(a%-)", "A")
			text = gsub(text, "(c%-)", "C")
			text = gsub(text, "(st%-)", "C")
	
			for i = 1, 30 do
				text = gsub(text, _G["KEY_BUTTON"..i], "M"..i)
			end
	
			for i = 1, 9 do
				text = gsub(text, _G["KEY_NUMPAD"..i], "Nu"..i)
			end
	
			text = gsub(text, KEY_NUMPADDECIMAL, "Nu.")
			text = gsub(text, KEY_NUMPADDIVIDE, "Nu/")
			text = gsub(text, KEY_NUMPADMINUS, "Nu-")
			text = gsub(text, KEY_NUMPADMULTIPLY, "Nu*")
			text = gsub(text, KEY_NUMPADPLUS, "Nu+")
	
			text = gsub(text, KEY_MOUSEWHEELUP, "WU")
			text = gsub(text, KEY_MOUSEWHEELDOWN, "WD")
			text = gsub(text, KEY_NUMLOCK, "NuL")
			text = gsub(text, KEY_PAGEUP, "PU")
			text = gsub(text, KEY_PAGEDOWN, "PD")
			text = gsub(text, KEY_SPACE, "_")
			text = gsub(text, KEY_INSERT, "Ins")
			text = gsub(text, KEY_HOME, "Hm")
			text = gsub(text, KEY_DELETE, "Del")
			text = gsub(text, "Capslock", "Caps")
	
			hotkey:SetText(text)
		end
	
		for _, button in pairs(buttons) do
			hooksecurefunc(button, "UpdateHotkeys", updateHotkeys)
		end
	
		hooksecurefunc("ActionButton_UpdateRangeIndicator", updateHotkeys)
		hooksecurefunc("PetActionButton_SetHotkeys", updateHotkeys)
	end

	if db.altKeybindFont then

		local function updateHotkeys(self)
			local hotkey = self.HotKey
			local text = hotkey:GetText()
	
			if not self.PUI then
				self.PUI = true
				hotkey:SetFontObject("Game11Font_o1")
				hotkey:ClearAllPoints()
				hotkey:SetPoint("TOPRIGHT", -1, -3)
			end
		end
	
		for _, button in pairs(buttons) do
			hooksecurefunc(button, "UpdateHotkeys", updateHotkeys)
		end
	
		hooksecurefunc("ActionButton_UpdateRangeIndicator", updateHotkeys)
		hooksecurefunc("PetActionButton_SetHotkeys", updateHotkeys)
	end

	if db.hideMacroNames then
		for _, button in pairs(buttons) do
			button.Name:Hide()
		end
	end
end

function module.ManageBarPositions()
	if InCombatLockdown() then
		module.queuedManageBarPositions = true
		return
	end

	local db = module.db

	if db.extraButtons then
		local arrowAnchor = SHOW_MULTI_ACTIONBAR_2 and MultiBarBottomRightButton6 or MultiBarRightButton12

		MultiBarLeftButton12:ClearAllPoints()
		MultiBarRightButton12:ClearAllPoints()
		ActionBarDownButton:ClearAllPoints()
		ActionBarUpButton:ClearAllPoints()

		MultiBarLeftButton12:SetPoint("LEFT", MultiBarBottomLeftButton12, "RIGHT", 6, 0)
		MultiBarRightButton12:SetPoint("LEFT", ActionButton12, "RIGHT", 6, 0)
		ActionBarUpButton:SetPoint("BOTTOM", arrowAnchor, "RIGHT", 14, -1)
		ActionBarDownButton:SetPoint("TOP", arrowAnchor, "RIGHT", 14, -1)

		if SHOW_MULTI_ACTIONBAR_2 then
			MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", 3, 0)
		end
	end

	if db.hideArtwork or db.hideXPBar then
		local yOffset_PetActionBarFrame = SHOW_MULTI_ACTIONBAR_1 and 48 or 0
		local yOffset_StanceBarFrame = SHOW_MULTI_ACTIONBAR_1 and 45 or -3

		if db.hideArtwork then
			MultiBarBottomLeft:ClearAllPoints()
			MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 6)
			MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, 6)

			for i=1, NUM_STANCE_SLOTS do
				_G["StanceButton"..i]:GetNormalTexture():SetWidth(52)
				_G["StanceButton"..i]:GetNormalTexture():SetHeight(52)
			end

			yOffset_PetActionBarFrame = SHOW_MULTI_ACTIONBAR_1 and yOffset_PetActionBarFrame - 6 or yOffset_PetActionBarFrame
			yOffset_StanceBarFrame = SHOW_MULTI_ACTIONBAR_1 and yOffset_StanceBarFrame - 6 or yOffset_StanceBarFrame
		end

		if db.hideXPBar then
			MainMenuBarArtFrameBackground:ClearAllPoints()
			MainMenuBarArtFrameBackground:SetPoint("LEFT", MainMenuBar)
			MainMenuBarArtFrameBackground:SetPoint("BOTTOM", UIParent, 0, db.hideArtwork and 3 or 0)
		end

		module.PetActionBarFrame:SetPoint("BOTTOMLEFT", MainMenuBarArtFrameBackground, "TOPLEFT", 36, -3 + yOffset_PetActionBarFrame)
		StanceBarFrame:SetPoint("BOTTOMLEFT", MainMenuBarArtFrameBackground, "TOPLEFT", 30, yOffset_StanceBarFrame)
	end
end

function eventHandler:PLAYER_REGEN_ENABLED()
	if module.queuedManageBarPositions then
		module.queuedManageBarPositions = false
		module.ManageBarPositions()
	end
end