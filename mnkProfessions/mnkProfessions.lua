mnkProfessions = CreateFrame('Frame')
mnkProfessions.LDB = LibStub:GetLibrary('LibDataBroker-1.1')
local libQTip = LibStub('LibQTip-1.0')
local SPACER = '       '
--local t = {}
local tIgnoreList = {'Skinning',
					 'Herbalism',
					 'Mining',
					 'Fishing'}
					 
local hasSpellsChanged = false
local hasPlayerLogin = false

local function IgnoreSkill(v)
    for index, value in ipairs(tIgnoreList) do
        if value == v then
            return true
        end
    end
    return false
end


function mnkProfessions:DoOnEvent(event, arg1)
    if event == 'PLAYER_LOGIN' then
		hasPlayerLogin = true
        mnkProfessions.LDB = LibStub('LibDataBroker-1.1'):NewDataObject('mnkProfessions', {
            type = 'data source', 
            icon = '', 
            OnClick = nil, 
            OnEnter = mnkProfessions.DoOnEnter
        })
        self.LDB.label = 'Professions'
    end
	    
    if event == 'CHAT_MSG_SKILL' then
        CombatText_AddMessage(arg1, CombatText_StandardScroll, 255, 255, 255, nil, false)
    end
	--print(event)
	if (hasPlayerLogin == true) and ((hasSpellsChanged == true) or (event == 'SPELLS_CHANGED')) then
		hasSpellsChanged = true
		self.LDB.text = self.GetText()
	else
		self.LDB.text = 'n/a'
	end
end

function mnkProfessions.DoOnMouseDown(self, arg, button) 
	
	if name == "Mining" then 
		CastSpellByName("Find Minerals")
	elseif name == "Herbalism" then 
		CastSpellByName("Find Herbs")
	else
		CastSpellByName(arg)
	end
end

function mnkProfessions.DoOnEnter(self)
    
    local tooltip = libQTip:Acquire('mnkProfessionsTooltip', 3, 'LEFT', 'LEFT', 'RIGHT')
    self.tooltip = tooltip
    tooltip:SetFont(mnkLibs.DefaultTooltipFont)
    tooltip:SetHeaderFont(mnkLibs.DefaultTooltipFont)
    tooltip:Clear()
    local t = mnkProfessions.GetProfessions('Professions')
	local i = 0
	
    tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Professions', SPACER, mnkLibs.Color(COLOR_GOLD)..'Level')
	if #t == 0 then
		tooltip:AddLine('No professions.')
	else
		for i = 1, #t do
			local y, x = tooltip:AddLine(string.format('|T%s:16|t %s', t[i].icon, t[i].name), SPACER, t[i].rank..'/'..t[i].maxRank)
			if not IgnoreSkill(t[i].name) then
				tooltip:SetLineScript(y, 'OnMouseDown', mnkProfessions.DoOnMouseDown, t[i].name)
			end
		end
	end
	
	t = mnkProfessions.GetProfessions('Secondary Skills')
		
	if #t > 0 then
		tooltip:AddLine(' ')
		tooltip:AddHeader(mnkLibs.Color(COLOR_GOLD)..'Secondary Skills', SPACER, mnkLibs.Color(COLOR_GOLD)..'Level')
		for i = 1, #t do
			local y, x = tooltip:AddLine(string.format('|T%s:16|t %s', t[i].icon, t[i].name), SPACER, t[i].rank..'/'..t[i].maxRank)
			if not IgnoreSkill(t[i].name) then
				tooltip:SetLineScript(y, 'OnMouseDown', mnkProfessions.DoOnMouseDown, t[i].name)
			end
		end
	end	
	

    tooltip:SetAutoHideDelay(.1, self)
    tooltip:SmartAnchorTo(self)
    tooltip:SetBackdropBorderColor(0, 0, 0, 0)
    tooltip:Show()
end

function mnkProfessions.GetProfessionTexture(name)
	local s = " "
	if name == "Mining" then 
		s = GetSpellTexture("Find Minerals")
	elseif name == "Herbalism" then 
		s = GetSpellTexture("Find Herbs")
	else 
		s = GetSpellTexture(name)
	end

	if s == nil then s = " " end
	--print(name.." "..s)
	return s	
end

function mnkProfessions.GetProfessions(skillHeader)
	local skillIndex = 0
	local profIdx = 0
	local t = {}
	local i = 0
	
	for skillIndex = 1, GetNumSkillLines() do
		local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = GetSkillLineInfo(skillIndex)
		
		if isHeader == nil then isHeader = false else isHeader = true end	
		if isHeader then
			if skillName == skillHeader then 
				profIdx = skillIndex
			elseif skillName ~= skillHeader and skillIndex > profIdx then
				profIdx = 0
			end
		end
		
		if not isHeader and profIdx > 0 then
			i = i +1
			t[i] = {};
			t[i].name = skillName
			t[i].icon = mnkProfessions.GetProfessionTexture(skillName)
			t[i].rank = skillRank
			t[i].maxRank = skillMaxRank			
		end
	end
	return t
end

function mnkProfessions.GetText()
	local t = mnkProfessions.GetProfessions('Professions')
	local s = "n/a"
	
	if #t > 0 then
		s = string.format('|T%s:16|t', t[1].icon) ..' '..mnkLibs.Color(COLOR_GOLD)..t[1].rank..'/'..t[1].maxRank 
		if #t > 1 then
			if t[2].icon == nil then
				s = s.." "..mnkLibs.Color(COLOR_GOLD)..t[2].rank..'/'..t[2].maxRank
			else
				s = s.." "..string.format('|T%s:16|t', t[2].icon) ..' '..mnkLibs.Color(COLOR_GOLD)..t[2].rank..'/'..t[2].maxRank
			end
		end
			
		return s
	end
	return s 
end

mnkProfessions:SetScript('OnEvent', mnkProfessions.DoOnEvent)
mnkProfessions:RegisterEvent('PLAYER_LOGIN')
mnkProfessions:RegisterEvent('CHAT_MSG_SKILL')
mnkProfessions:RegisterEvent('SPELLS_CHANGED')
mnkProfessions:RegisterEvent('SKILL_LINES_CHANGED')




