--[[
@
@ Project  : 
@
@ Filename : native.lua
@
@ Author   : Task Nagashige
@
@ Date     : 
@
@ Comment  : 
@
@ Package  : native関数の拡張
@
]]-- 

-- ネイティブ系関数のデバッグ用
local native_is_debug = false

local function native_print( ... )
	if native_is_debug then
		print( ... )
	end
end

local cached_nativeShowAlert = native.showAlert
local is_showAlert = false
function native.showAlert( ... )
	native_print( 'cached_nativeShowAlert' )
	local arg = { ... }
	local alert

	local self = {}

	local native_timer = nil
	local remove_timer = nil

	local function remove()
		if alert then
			native.cancelAlert( alert ) 
			alert = nil
		end
		
		if remove_timer then
			timer.cancel( remove_timer )
			remove_timer = nil
		end

		if native_timer then
			timer.cancel( native_timer )
			native_timer = nil
		end
		is_showAlert = false
	end

	if arg[4] == nil then
		arg[4] = function() 
		end
	end

	local function onComplete( event )
	    if event.action == 'clicked' then
			is_showAlert = false
			if native_timer then
				timer.cancel( native_timer )
				native_timer = nil
			end
	    end
	    arg[4]( event )
	    remove_timer = timer.performWithDelay( 10000, remove )
	end

	local function returnValue()
		is_showAlert = true
		alert = cached_nativeShowAlert( arg[1], arg[2], arg[3], onComplete )
		return alert
	end
	
	local function checkAlert()
		if not is_showAlert then
			return returnValue()
		end
	end
	native_timer = timer.performWithDelay( 300, checkAlert, -1 )
end