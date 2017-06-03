--[[
@
@ Project  : 
@
@ Filename : timer.lua
@
@ Author   : Task Nagashige
@
@ Date     : 
@
@ Comment  : 
@
@ Package  : timer関数の拡張
@
]]-- 

local cached_timerCancel = timer.cancel
function timer.cancel( timer_id )
	local timer_id = timer_id
	if timer_id then
		timer_id.isAwake = false
		return cached_timerCancel( timer_id )
	end
end

local cached_timerPause = timer.pause
function timer.pause( timer_id )
	local timer_id = timer_id
	if timer_id and timer_id.isAwake then
		return cached_timerPause( timer_id )
	end
end

local cached_timerPerformWithDelay = timer.performWithDelay
function timer.performWithDelay( ... )
	local arg = { ... }

	local debugInfo = debug.getinfo(2)
	local fileName = debugInfo.source:match("[^/]*$")
	local currentLine = debugInfo.currentline	

	local timer_id = nil
	local cached_listener = arg[2]
	if arg[3] == nil then
		arg[2] = function( e )
			timer_id.isAwake = false
			if cached_listener then
				local flag, ret = pcall( cached_listener, e )
				if not flag then 
					print( 'error', ret )
				end
			end
			if timer_id then
				timer.cancel( timer_id )
				timer_id = nil
			end
		end
	end

	timer_id = cached_timerPerformWithDelay( arg[1], arg[2], arg[3] )
	-- timerが有効かを判定するflag
	timer_id.isAwake = true
	return timer_id
end

local cached_timerResume = timer.resume
function timer.resume( timer_id )
	local timer_id = timer_id
	if timer_id and timer_id.isAwake then
		return cached_timerResume( timer_id )
	end
end
