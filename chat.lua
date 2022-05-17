local addonName, addon = ...
local module = addon:CreateModule("Chat")

module.defaultSettings = {
	hideChatButtons = false,
	hideSocialButton = false,
	unclamp = false,
}

module.optionsTable = {
	header_visibility = {
		order = 1,
		type = "header",
		name = "Visibility",
	},
	hideChatButtons = {
		order = 2,
		type = "toggle",
		name = "Hide chat buttons",
		desc = "Buttons such as the social and typing ones are hidden/shown"
		width = "full",
	},
	hideSocialButton = {
		order = 3,
		type = "toggle",
		name = "Hide social button",
		desc = "The blizzard social button is hidden/shown"
		width = "full",
	},
	header_miscellaneous = {
		order = 4,
		type = "header",
		name = "Miscellaneous",
	},
	unclamp = {
		order = 5,
		type = "toggle",
		name = "Unclamp chat frame",
		desc = "Unclamps/clamps the chat frame so it can be moved beyond blizzard's set limits"
		width = "full",
	},
}

function module:Clean()
	local db = self.db

	db.hideChatButtons = true
	db.hideSocialButton = true
	db.unclamp = true
end

function module:OnLoad()
	local db = self.db

	if db.hideChatButtons then
		local tframe = CreateFrame("FRAME")
		tframe:Hide()

		local function AddMouseScroll(chtfrm)
			if _G[chtfrm] then
				_G[chtfrm]:SetScript("OnMouseWheel", function(self, direction)
					if direction == 1 then
						if IsControlKeyDown() then
							self:ScrollToTop()
						elseif IsShiftKeyDown() then
							self:PageUp()
						else
							self:ScrollUp()
						end
					else
						if IsControlKeyDown() then
							self:ScrollToBottom()
						elseif IsShiftKeyDown() then
							self:PageDown()
						else
							self:ScrollDown()
						end
					end
				end)
				_G[chtfrm]:EnableMouseWheel(true)
			end
		end

		local function HideButtons(chtfrm)
			_G[chtfrm .. "ButtonFrameMinimizeButton"]:SetParent(tframe)
			_G[chtfrm .. "ButtonFrameMinimizeButton"]:Hide();
			_G[chtfrm .. "ButtonFrame"]:SetSize(0.1,0.1)
			_G[chtfrm].ScrollBar:SetParent(tframe)
			_G[chtfrm].ScrollBar:Hide()
		end

		local function HighlightTabs(chtfrm)
			_G[chtfrm].ScrollToBottomButton.Flash:SetTexture("Interface/BUTTONS/GRADBLUE.png")
			_G[chtfrm].ScrollToBottomButton:ClearAllPoints()
			_G[chtfrm].ScrollToBottomButton:SetPoint("BOTTOM",_G[chtfrm .. "Tab"],0,-4)
			_G[chtfrm].ScrollToBottomButton:Show()
			_G[chtfrm].ScrollToBottomButton:SetWidth(_G[chtfrm .. "Tab"]:GetWidth() - 12)
			_G[chtfrm].ScrollToBottomButton:SetHeight(24)

			_G[chtfrm .. "Tab"]:SetScript("OnSizeChanged", function()
				for j = 1, 50 do
					if _G["ChatFrame" .. j] and _G["ChatFrame" .. j].ScrollToBottomButton then
						_G["ChatFrame" .. j].ScrollToBottomButton:SetWidth(_G["ChatFrame" .. j .. "Tab"]:GetWidth() - 12)
					end
				end
			end)

			-- talvez tenha que atualizar as proximas linhas no 10.0 (hookscript)
			_G[chtfrm].ScrollToBottomButton:SetScript("OnClick", nil)

			_G[chtfrm].ScrollToBottomButton:SetNormalTexture("")
			_G[chtfrm].ScrollToBottomButton:SetHighlightTexture("")
			_G[chtfrm].ScrollToBottomButton:SetPushedTexture("")

			_G[chtfrm .. "Tab"]:HookScript("OnClick", function(self,arg1)
				if arg1 == "LeftButton" then
					_G[chtfrm]:ScrollToBottom();
				end
			end)

		end

		ChatFrameMenuButton:SetParent(tframe)
		ChatFrameChannelButton:SetParent(tframe)
		ChatFrameToggleVoiceDeafenButton:SetParent(tframe)
		ChatFrameToggleVoiceMuteButton:SetParent(tframe)

		for i = 1, 50 do
			if _G["ChatFrame" .. i] then
				AddMouseScroll("ChatFrame" .. i);
				HideButtons("ChatFrame" .. i);
				HighlightTabs("ChatFrame" .. i)
			end
		end

		hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType)
			local cf = FCF_GetCurrentChatFrame():GetName() or nil
			if cf then
				AddMouseScroll(cf)
				HideButtons(cf)
				HighlightTabs(cf)
				_G[cf .. "Tab"]:SetScript("OnSizeChanged", function()
					_G[cf].ScrollToBottomButton:SetWidth(_G[cf .. "Tab"]:GetWidth()-10)
				end)
			end
		end)
	end

	if db.hideSocialButton then
		local tframe = CreateFrame("FRAME")
		tframe:Hide()
		QuickJoinToastButton:SetParent(tframe)
	end

	if db.unclamp then
		for i = 1, 50 do
			if _G["ChatFrame" .. i] then 
				_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0);
			end
		end

		hooksecurefunc("FloatingChatFrame_UpdateBackgroundAnchors", function(self)
			self:SetClampRectInsets(0, 0, 0, 0);
		end)

		hooksecurefunc("FCF_OpenTemporaryWindow", function()
			local cf = FCF_GetCurrentChatFrame():GetName() or nil
			if cf then
				_G[cf]:SetClampRectInsets(0, 0, 0, 0);
			end
		end)
	end
end