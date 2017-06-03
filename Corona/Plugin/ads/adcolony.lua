--[[
@
@ Project  :
@
@ Filename : adcolony.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2016-03-28
@
@ Comment  : 
@
]]--

local adcolony = require( 'plugin.adcolony' )

local self = object.new()

self.initialized = false
self.adcolony_apiKey = ''

------------------------------
-- イベントのリスナー
------------------------------
local function adcolonyListener(event)

	print( event )
	if event.phase == 'init' then

	elseif event.phase == 'loaded' then

	elseif event.phase == 'willDisplay' then
		-- 広告表示前

	elseif event.phase == 'didDisplay' then
		-- 広告表示完了

	elseif event.phase == 'closed' then
		-- 広告を閉じた

	elseif event.phase == 'clicked' then
		-- 広告インストールボタンを押した

	elseif event.phase == 'reward' then
		-- 広告を見終わった時

	elseif event.phase == 'failed' then
		-- 表示するコンテンツがありません
		print('adcolony : 失敗しました。', event.info)
		local alert = native.showAlert( '視聴失敗', '見ることができる動画がありません。しばらく経ったあとで試してください。', { 'OK' } )
	end

	self:dispatchEvent( { name = event.phase } )
end

-------------------------
-- initialize
-------------------------
function self.init( option )
	local apiKey       = option.adcolony_apiKey or self.adcolony_apiKey
	local debugLogging = option.adcolony_debugLogging
	local testMode     = option.adcolony_testMode

	assert( apiKey, 'ERROR : apiKeyを設定してください')

	-- adcolonyイニシャライズ
	local adcolony_options = 
	{
		apiKey       = apiKey,
		debugLogging = debugLogging,
		testMode     = testMode
	}
	adcolony.init( adcolonyListener, adcolony_options )

	print('adcolony -- initialize')
	print( apiKey )

	self.initialized = true
end

-------------------------
-- prepare
-------------------------
function self.prepare( ads_type )
	assert(self.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'interstitial' or
			ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです')

end


-------------------------
-- show
-------------------------
function self.show( ads_type )
	assert(self.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'interstitial' or
			ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです')

	-- prepare
	print('adcolony : '..ads_type)

	-- ロードされているかチェック
	local is_loaded = adcolony.isLoaded( ads_type )
	if is_loaded then
		adcolony.show( ads_type )
	else
		timer.performWithDelay( 1000, function() self.show( ads_type ) end )
	end
	if 'simulator' == system.getInfo( 'environment' ) and ads_type == 'rewardedVideo' then
		adcolonyListener( { response = 'reward' } )
	end
end


--------------------------
-- remove
--------------------------
function self.remove()
	adcolony.hide()
end

return self