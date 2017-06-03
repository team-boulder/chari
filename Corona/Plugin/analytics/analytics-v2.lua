--[[
@
@ Project  : 
@
@ Filename : analytics-v2.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2016-09-05
@
@ Comment  : flurryのコードの現時点での新しいもの
@
]]--

local flurryAnalytics = require( 'plugin.flurry.analytics' )

local self = {}

-------------------------------
-- FlurryサイトよりAPI Keyを取得
-------------------------------
-- TODO : iOSとAndroidのAPIキーを設定する
local app_key = nil
if system.getInfo( 'platformName' ) == 'Android' then
	app_key = 'DYC9KKQ7RC8553GXCJQR'
elseif system.getInfo( 'platformName' ) == 'iPhone OS' then
	app_key = '4QWZKQ5JB2GRKVSJJ6SR'
end


local log_level = 'default'
if __isDebug then
	log_level = 'all'
end

local function flurryListener( event )
    if event.phase == 'init' then
        print( event.provider )
    end
end
flurryAnalytics.init( flurryListener, { apiKey = app_key, crashReportingEnabled = true, logLevel = log_level } )

function self.logEvent( ... )
	if 'simulator' ~= system.getInfo( 'environment' ) then
		return flurryAnalytics.logEvent( ... )
	end
end

function self.startTimedEvent( ... )
	return flurryAnalytics.startTimedEvent( ... )
end

function self.endTimedEvent( ... )
	return flurryAnalytics.endTimedEvent( ... )
end

return self
