item_techies_explosive_barrel = item_techies_explosive_barrel or class({})

function item_techies_explosive_barrel:OnCreated()
--	print(self:GetLevel())
end

function item_techies_explosive_barrel:OnChannelFinish(bInterrupted)
	local point = self:GetCursorPosition()

	if bInterrupted then
	else
		local mine = CreateUnitByName("npc_dota_mine_"..self:GetLevel(), point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	end
end
