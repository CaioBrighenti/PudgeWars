modifier_companion = class({})

function modifier_companion:IsHidden() return true end
function modifier_companion:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_companion:GetAbsoluteNoDamageMagical() return 1 end
function modifier_companion:GetAbsoluteNoDamagePure() return 1 end

function modifier_companion:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_companion:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}

	return decFuncs
end

function modifier_companion:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)

		if not self:GetParent().base_model then
			self:GetParent().base_model = self:GetParent():GetModelName()
		end

		if not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
		end

		self:SetStackCount(0)
	end
end

--[[
local anti_spam = false
function modifier_companion:OnAttacked(keys)
local target = keys.target

	if IsServer() then
		if target == self:GetParent() then
			if anti_spam == false then
				anti_spam = true
				target:EmitSound("Companion.Llama")
				Timers:CreateTimer(5.0, function()
					anti_spam = false
				end)
			end
		end
	end
end
--]]

function modifier_companion:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_companion:OnIntervalThink()
	if IsServer() then
		local companion = self:GetParent()

		-- vanilla baseclass bug
		if companion:IsMoving() then
			companion:StartGesture(ACT_DOTA_RUN)
		else
			companion:FadeGesture(ACT_DOTA_RUN)
		end

		if companion:GetPlayerOwner() == nil or companion:GetPlayerOwner():GetAssignedHero() == nil then return end
		local hero = companion:GetPlayerOwner():GetAssignedHero()
		hero.companion = companion
		local wait_pos = Vector(0, 0, 0) + RandomVector(200)
		local hero_origin = hero:GetAbsOrigin()
		local hero_distance = (hero_origin - companion:GetAbsOrigin()):Length()
		local wait_pos_distance = (wait_pos - companion:GetAbsOrigin()):Length()
		local min_distance = 250
		local blink_distance = 750

		if companion:GetIdealSpeed() ~= hero:GetIdealSpeed() - 70 then
			companion:SetBaseMoveSpeed(hero:GetIdealSpeed() - 70)
		end

--		for _,v in pairs(IMBA_INVISIBLE_MODIFIERS) do
--			if not hero:HasModifier(v) then
--				if companion:HasModifier(v) then
--					companion:RemoveModifierByName(v)
--				end
--			else
--				if not companion:HasModifier(v) then
--					companion:AddNewModifier(companion, nil, v, {})
--				end
--			end
--		end

		if not hero:IsAlive() then
			if wait_pos_distance > blink_distance then -- min_distance is too high with fountain bound radius
				FindClearSpaceForUnit(companion, wait_pos, false)
				companion:Stop()
				return
			end
		elseif hero_distance < min_distance then
			companion:Stop()
		elseif hero_distance > blink_distance then
			companion:Blink(hero_origin + RandomVector(RandomInt(150, 300)), true, false)
			companion:Stop()
		elseif hero_distance > min_distance then
			if not companion:IsMoving() then
				companion:MoveToNPC(hero)
			end
		end

		self:SetStackCount(hero_distance / 4)

--		for _, v in ipairs(SHARED_NODRAW_MODIFIERS) do
--			if hero:HasModifier(v) or self:IsOnMountain() then
--				companion:AddNoDraw()
--				return
--			elseif not hero:HasModifier(v) then
--				companion:RemoveNoDraw()
--			end
--		end
	end
end

function modifier_companion:IsOnMountain()
	local hero = self:GetParent():GetPlayerOwner():GetAssignedHero()
	local origin = hero:GetAbsOrigin()

--	print("cliff:", origin.z, 512)
	if origin.z > 512 then
		return true
	else
		return false
	end
end
