--[[
@
@ Project  : 
@
@ Filename : transition.lua
@
@ Author   : Task Nagashige
@
@ Date     : 
@
@ Comment  : 
@
@ Package  : transition関数の拡張
@
]]-- 

local cached_transitionCancel = transition.cancel
function transition.cancel( ... )
	local arg = { ... }
	local obj = arg[1]
	if type( obj ) == 'table' then
		local group_num = obj.numChildren
		if group_num and group_num > 1 then
			local i
			for i = 1, group_num do
				transition.cancel( obj[i] )
			end
			i = nil
			group_num = nil
		end
	end
	cached_transitionCancel( ... )
	return nil
end

local cached_transitionTo = transition.to
function transition.to( ... )
	return cached_transitionTo( ... )
end