--[[
@
@ Project  :
@
@ Filename : vungle.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2016-03-28
@
@ Comment  : 
@
]]--
 
local vungle = require( 'ads' )

local this = object.new()

this.initialized = false
this.vungle_appID = ''
this.vungle_appSignature = ''
this.replace_listener = function() end

local vungle_ads = nil
if system.getInfo( 'platformName' ) == 'Android' then
	this.vungle_appID = '56f8729484f9407b09000069'
else
	this.vungle_appID = '56f872c3af90b97f7d000097'
end


------------------------------
-- イベントのリスナー
------------------------------
local function ad_vungle_listener( event )

	print( event )
	event.response = 'unknown_event'
	if event.type == 'adStart' then
		if event.isError then
			print( 'vungle : 失敗しました。', event.response )
			hideModal()
			local alert = native.showAlert( '視聴失敗', '見ることができる動画がありません。しばらく経ったあとで試してください。', { 'OK' } )
		end
	elseif event.type == 'adView' then

	elseif event.type == 'adEnd' then
		if not event.isError then
			event.response = 'reward'
		end
		vungle_ads = nil
	elseif event.type == 'cachedAdAvailable' then

	end

	local dispatch_event = 
	{
		name = event.response,
	}
	this:dispatchEvent( dispatch_event )
end

-------------------------
-- initialize
-------------------------
function this.init( option )
	local option = option or {}
	local appID = option.vungle_appID or this.vungle_appID
	assert(appID, 'ERROR : vungle_appIDのIDを設定してください')

	print( option )
	vungle.init( 'vungle', appID, ad_vungle_listener )

	this.initialized = true
end

-------------------------
-- prepare
-------------------------
function this.prepare(ads_type)
	if ads_type == 'wall' then
		ads_type = 'moreApps'
	end
	assert( this.initialized == true, 'ERROR : vungle.init() をして下さい' )
	assert( ads_type, 'ERROR : ads_typeが指定されていません' )
	assert( ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです' )

	-- prepare
	-- vungle.cache( ads_type )
	vungle.isAdAvailable()
end


-------------------------
-- show
-------------------------
function this.show( ads_type )
	assert( this.initialized == true, 'ERROR : vungle.init() をして下さい' )
	assert( ads_type, 'ERROR : ads_typeが指定されていません')
	assert( ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです')
	-- prepare
	print( 'vungle : ', ads_type )
	-- リワードビデオに置換
	if ads_type == 'rewardedVideo' then
		ads_type = 'incentivized'
	end
	vungle_ads = vungle.show( ads_type )
	if 'simulator' == system.getInfo( 'environment' ) and ads_type == 'rewardedVideo' then
		ad_vungle_listener( { response = 'reward' } )
	end
end


--------------------------
-- remove
--------------------------
function this.remove()
	-- vungle.closeImpression()
end

return this