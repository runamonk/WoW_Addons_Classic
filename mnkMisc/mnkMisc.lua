mnkMisc = CreateFrame('Frame')
local myaddonName = ...

function mnkMisc:DoOnEvent(event, ...)
    if event == 'ADDON_LOADED' then
        local addonName = ...
		if addonName == myaddonName then
            SetCVar('alwaysCompareItems', 0)
            SetCVar('autoLootDefault', 1)
            SetCVar('enableFloatingCombatText', 1)
            OrderHall_CheckCommandBar = mnkLibs.donothing
        end
	elseif event == 'MERCHANT_SHOW' then
		local price = 0
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				if select(4, GetContainerItemInfo(bag, slot)) == LE_ITEM_QUALITY_POOR then
					--ShowMerchantSellCursor(1)
					UseContainerItem(bag, slot)
					price = price + select(11, GetItemInfo(GetContainerItemID(bag, slot)))
				end
			end
		end
		ResetCursor()
		if price ~= 0 then
			DEFAULT_CHAT_FRAME:AddMessage(string.format('Sold junk for: % s', GetCoinTextureString(price)))
		end
    end    
end

SLASH_RL1 = '/rl'
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end

local MainMenuBarLeftEndCap = _G.MainMenuBarLeftEndCap
local MainMenuBarRightEndCap = _G.MainMenuBarRightEndCap
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()

--Hide open all mail button, it's buggy.
OpenAllMail:Hide()

mnkMisc:SetScript('OnEvent', mnkMisc.DoOnEvent)
mnkMisc:RegisterEvent('ADDON_LOADED')
mnkMisc:RegisterEvent('MERCHANT_SHOW')

