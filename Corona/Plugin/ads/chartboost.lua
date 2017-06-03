-- ProjectName : ads
--
-- Filename : chartboost.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-07-08
--
-- Comment :
---------------------------------------------------------
local chartboost = require("plugin.chartboost")

local this = object.new()

this.initialized = false
this.chartboost_appID = ''
this.chartboost_appSignature = ''
this.chartboost_apiKey = ''
this.chartboost_appOrientation = ''

------------------------------
-- イベントのリスナー
------------------------------
local function adChartboostListener(event)

	print( event )
	if event.phase == 'init' then

	elseif event.phase == 'loaded' then
		-- キャッシュ完了
        if this.loaded_listener then
        	this.loaded_listener()
        	this.loaded_listener = nil
        end

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
		print("chartboost : 失敗しました。", event.info)
		local alert = native.showAlert( '視聴失敗', '見ることができる動画がありません。しばらく経ったあとで試してください。', { 'OK' } )
	end

	this:dispatchEvent( { name = event.phase } )
end

-------------------------
-- initialize
-------------------------
function this.init(option)
	local appID          = option.chartboost_appID or this.chartboost_appID
	local appSignature   = option.chartboost_appSignature or this.chartboost_appSignature
	local apiKey         = option.chartboost_apiKey or this.chartboost_apiKey
	local appOrientation = option.chartboost_appOrientation or this.chartboost_appOrientation
	local testMode       = option.chartboost_testMode

	-- assert(appID, 'ERROR : chartboost_appIDのIDを設定してください')
	-- assert(appSignature, 'ERROR : chartboost_appSignatureのIDを設定してください')
	assert( apiKey, 'ERROR : chartboostのapiKeyを設定してください' )

	-- chartboostイニシャライズ
	local chartboost_options = 
	{
		-- appID          = appID,
		-- appSignature   = appSignature, 
		apiKey         = apiKey,
		appOrientation = appOrientation,
		-- listener       = adChartboostListener,
		testMode       = testMode,
		autoCacheAds   = true
	}
	chartboost.init( adChartboostListener, chartboost_options )

	print("chartboost -- initialize")
	print( appID, appSignature )
	print( apiKey )

	this.initialized = true
end

-------------------------
-- prepare
-------------------------
function this.prepare( ads_type, listener )
	if ads_type == 'wall' then
		ads_type = 'moreApps'
	end
	assert(this.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'interstitial' or
			ads_type == 'rewardedVideo' or 
			ads_type == 'moreApps', 'ERROR : 存在しないads_typeです')

	if listener then
		this.loaded_listener = function()
			listener()
		end
	end

	-- prepare
	chartboost.load( ads_type )
end


-------------------------
-- show
-------------------------
function this.show( ads_type )
	if ads_type == 'wall' then
		ads_type = 'moreApps'
	end
	assert(this.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'interstitial' or
			ads_type == 'rewardedVideo' or 
			ads_type == 'moreApps', 'ERROR : 存在しないads_typeです')

	-- prepare
	print("chartboost : "..ads_type)

	-- ロードされているかチェック
	local is_loaded = chartboost.isLoaded( ads_type )

	if is_loaded then
		chartboost.show( ads_type )
	else
		this.prepare( ads_type, function() this.show( ads_type ) end )
	end

	if 'simulator' == system.getInfo( 'environment' ) and ads_type == 'rewardedVideo' then
		adChartboostListener( { response = 'reward' } )
	end
end


--------------------------
-- remove
--------------------------
function this.remove()
	chartboost.hide()
end
return this