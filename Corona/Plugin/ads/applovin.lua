--[[
@
@ Project  :
@
@ Filename : applovin.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2016-03-28
@
@ Comment  : 
@
]]--
local applovin = require( "plugin.applovin" )

local this = object.new()

this.initialized = false
this.applovin_appID = 'WJTgHZKoCKeW9sqDe9GBnVJRJw3zBZ0iuUNA2hyF1bnARbO4mfGW9ZzSU0QfaQMTwldyRaCSB-dcZ1hJgyqqWo'
this.applovin_appSignature = ''

this.is_rewarded = true
this.replace_listener = function() end
this.loaded_listener = nil

local is_show = false

------------------------------
-- イベントのリスナー
------------------------------
local function ad_applovin_listener( event )

	print( event )
    if event.phase == 'init' then  -- Successful initialization
        print( event.isError )
        -- Load an AppLovin ad
        applovin.load( this.is_rewarded )

    elseif event.phase == 'loaded' then  -- The ad was successfully loaded
        print( event.type )
        -- Show the ad
		if is_show then
	        applovin.show( this.is_rewarded )
		end
		
        if this.loaded_listener then
        	this.loaded_listener()
        end

    elseif event.phase == 'failed' then  -- The ad failed to load
        print( event.type )
        print( event.isError )
        print( event.response )
        this.replace_listener()
        if is_show then
        	hideModal()
        	local alert = native.showAlert( '視聴失敗', '見ることができる動画がありません。しばらく経ったあとで試してください。', { 'OK' } )
		end

    elseif event.phase == 'displayed' or event.phase == 'playbackBegan' then  -- The ad was displayed/played
    	is_show = false
        print( event.type )

    elseif event.phase == 'hidden' or event.phase == 'playbackEnded' then  -- The ad was closed/hidden
    	is_show = false
        print( event.type )
		if not event.isError and event.type == 'incentivizedInterstitial' and event.phase == 'playbackEnded' then
			event.response = 'reward'
		end
    elseif event.phase == 'clicked' then  -- The ad was clicked/tapped
        print( event.type )
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
	local appID = option.applovin_appID or this.applovin_appID
	assert(appID, 'ERROR : applovin_appIDのIDを設定してください')
	
	print( option )
	applovin.init( ad_applovin_listener, { sdkKey = appID, verboseLogging = true } )
	this.initialized = true
end

-------------------------
-- prepare
-------------------------
function this.prepare( ads_type, listener )
	assert( this.initialized == true, 'ERROR : ads.init() をして下さい' )
	assert( ads_type, 'ERROR : ads_typeが指定されていません' )
	assert( ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです' )

	-- prepare
	if ads_type == 'rewardedVideo' then
		this.is_rewarded = true
	else
		this.is_rewarded = false
	end
	if listener then
		this.loaded_listener = function()
			listener()
		end
	end
	applovin.load( this.is_rewarded )
end


-------------------------
-- show
-------------------------
function this.show( ads_type )
	assert( this.initialized == true, 'ERROR : ads.init() をして下さい' )
	assert( ads_type, 'ERROR : ads_typeが指定されていません' )
	assert( ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです' )

	is_show = true

	-- prepare
	print( 'applovin : ', ads_type )
	if ads_type == 'rewardedVideo' then
		this.is_rewarded = true
	else
		this.is_rewarded = false
	end
	local is_loaded = applovin.isLoaded( this.is_rewarded )
	if is_loaded then
		applovin.show( this.is_rewarded )
	else
		this.prepare( ads_type, function() this.show( this.is_rewarded ) end )
	end
	if 'simulator' == system.getInfo( 'environment' ) and ads_type == 'rewardedVideo' then
		ad_applovin_listener( { response = 'reward' } )
	end
end


--------------------------
-- remove
--------------------------
function this.remove()
	is_show = false
	-- applovin.closeImpression()
end

return this