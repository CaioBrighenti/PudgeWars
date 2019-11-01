modifier_ability_points = class({})

function modifier_ability_points:IsHidden() return false end
function modifier_ability_points:RemoveOnDeath() return false end
function modifier_ability_points:GetTexture() return "pudge_wars_hook" end

function modifier_ability_points:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(0.1) -- might be too laggy?
end

function modifier_ability_points:OnIntervalThink()
	local items = {}

	for i = 0, 8 do
		local item
		if self:GetParent().GetItemInSlot then
			item = self:GetParent():GetItemInSlot(i)
		end

		if item then
			for k, v in pairs(items) do
				if v:GetAbilityName() == item:GetAbilityName() then
					local item_name = item:GetAbilityName()
					local item_cost = item:GetCost()

					result_level = item:GetLevel() + v:GetLevel()
					UTIL_RemoveImmediate(item)
					UTIL_RemoveImmediate(v)

					if result_level > 5 then
						newItem = CreateItem(item_name, self:GetParent(), nil)
						newItem:SetLevel(5)
						self:GetParent():AddItem(newItem)
						self:GetParent():ModifyGold(item_cost * (result_level - 5), true, 1)
					else
						newItem = CreateItem(item_name, self:GetParent(), nil)
						newItem:SetLevel(result_level)
						self:GetParent():AddItem(newItem)
					end

					break
				end
			end

			items[i] = item
		end
	end
end
