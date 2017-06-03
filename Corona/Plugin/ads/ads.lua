
-- ProjectName :
--
-- Filename : ads.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-06-18
--
-- Comment :
--
-- 利用中の広告
--   * webView系広告
--   * chartboost
--
-- 広告タイプ一覧
-- header : 画面上部のバナー広告
-- footer : 画面下部のバナー広告
-- icon   : アイコン広告
-- wall   : 画面全体の広告
----------------------------------------------------------------------------------
-- chartboost
local chartboost = object.new()
-- CoronaビルドとXcodeビルドで使い分け
if system.getInfo('platformName') == 'iPhone OS' and not __coronaBuild then
	chartboost = require(PluginDir .. 'ads.chartboost-ios')
else
	chartboost = require(PluginDir .. 'ads.chartboost')
end
local webviewAds = require(PluginDir .. 'ads.webviewAds')
local admob      = require(PluginDir .. 'ads.admob')
local fads       = require(PluginDir .. 'ads.freepAds')
local vungle     = require(PluginDir .. 'ads.vungle')
local applovin   = require(PluginDir .. 'ads.applovin')
local adcolony   = object.new()
-- TODO : 管理画面が来るまで
if system.getInfo('platformName') == 'Android' then
	adcolony   = require( PluginDir .. 'ads.adcolony' )
end
local fyber      = object.new()
if system.getInfo('platformName') == 'iPhone OS' and not __coronaBuild then
    fyber = require(PluginDir .. 'ads.fyber')
end


local this = object.new()

-- 設定
this.option = {
	-- 媒体を設定(optional)
	service = {
		banner = 'nend',
		header = 'nend',
		footer = 'nend',
		icon   = 'nend',
		wall   = 'applipromotion',
	},
}
this.hidden_wall = true

local is_initialized = false

-- 表示中の広告
this.showing_ads = {}

-- ステージ毎に広告を表示するタイミング
this.ads_stage = 0
this.interstitial_stage = 0

-- 広告表示の切り替え
this.switch = 'banner'

-- コンテンツになじませるネイティブアド
this.native_icon  = {}
this.native_chara = {}

this.native_chara = { { id = 20160128, name = '元カノ復讐', image = urlBase .. '/assets/motokano_chara.png' }, { id = 20160128, name = '元カノ復讐', image = urlBase .. '/assets/motokano_chara.png' } }
this.native_icon = { { id = 20160128, name = '元カノ復讐', image = urlBase .. '/assets/motokano_icon.png' }, { id = 20160128, name = '元カノ復讐', image = urlBase .. '/assets/motokano_icon.png' } }

local webview_isHide = false

-----------------------------------
-- イニシャライズ
--
-- Chartboostのイニシャライズを行う
--
-- @params table option :
-----------------------------------
local chartboost_isVisible = false
local webView_isVisible = false
local admob_isVisible = false
local freep_isVisible = false
local fyber_isVisible = false
local vungle_isVisible = false
local applovin_isVisible = false
local adcolony_isVisible = false

local function initListener(event)
	local webViewOption = {}
	local admobOption = {}
	local freepOption = {}

	if not event.isError then
		local data = json.decode(event.response)
		-- print( data )
		for k, v in pairs(data.ads) do
			this.option.service[v.type] = v.service

			-- webViewAds用
			if v.url and v.service == 'freep' then
				freepOption[v.type] = v.url
			elseif v.url then
				webViewOption[v.type] = v.url
			end

			-- chartboost用
			if v.service == 'chartboost' then
				this.option.chartboost_appID          = v.appID
				this.option.chartboost_appSignature   = v.appSignature
				this.option.chartboost_apiKey         = v.apiKey
				this.option.chartboost_appOrientation = v.appOrientation
				this.option.chartboost_testMode       = v.testMode
			end

			-- fyber用
			if v.service == 'fyber' then
				this.option.fyber_appID = v.appID
				this.option.fyber_token = v.token
			end

			-- vungle用
			if v.service == 'vungle' then
				this.option.vungle_appID = v.appID
			end

			-- applovin用
			if v.service == 'applovin' then
				this.option.applovin_appID = v.appID
			end

			if v.service == 'adcolony' then
				this.option.adcolony_apiKey       = v.apiKey
				this.option.adcolony_debugLogging = v.debugLogging
				this.option.adcolony_testMode     = v.testMode
			end

			-- admob用
			if v.service == 'admob' then
				this.option.nend_appID = v.appID
				admobOption[v.type] = {appId=v.appID, testMode=v.testMode}
			end
		end

		this.ads_stage = tonumber( data.ads_stage ) or 0
		this.interstitial_stage = tonumber( data.interstitial_stage ) or 0
		this.switch = data.ads_switch or 'banner'

		-- ウォール広告の有無を送信
		this.hidden_wall = data.hidden_wall
		local dispatchEvent = {
			name = 'hidden_wall',
			result = data.hidden_wall or false,
			share = data.share or nil,
		}
		this:dispatchEvent(dispatchEvent)
	end

	for k, v in pairs(this.option.service) do
		if v == 'chartboost' then
			chartboost_isVisible = true
		elseif v == 'fyber' then
			fyber_isVisible = true

		elseif v == 'vungle' then
			vungle_isVisible = true

		elseif v == 'applovin' then
			applovin_isVisible = true

		elseif v == 'adcolony' then
			adcolony_isVisible = true

		elseif v == 'nend' or v == 'applipromotion' then
			webView_isVisible = true

		elseif v == 'admob' then
			admob_isVisible = true

		elseif v == 'freep' then
			freep_isVisible = true
		end
	end

	-- chartboost用initialize
	if chartboost_isVisible == true then
		local chartboost_option = {
			chartboost_appID          = this.option.chartboost_appID,
			chartboost_appSignature   = this.option.chartboost_appSignature,
			chartboost_apiKey         = this.option.chartboost_apiKey,
			chartboost_appOrientation = this.option.chartboost_appOrientation,
			chartboost_testMode       = this.option.chartboost_testMode,
		}
		chartboost.init(chartboost_option)
	end

	-- fyber用initialize
	if fyber_isVisible == true then
		local fyber_option = {
			fyber_appID = this.option.fyber_appID,
			fyber_token = this.option.fyber_token
		}
		fyber.init(fyber_option)
	end

	-- vungle用initialize
	if vungle_isVisible == true then
		local vungle_option = {
			vungle_appID = this.option.vungle_appID,
		}
		vungle.init( vungle_option )
	end

	-- applovin用initialize
	if applovin_isVisible == true then
		local applovin_option = {
			applovin_appID = this.option.applovin_appID,
		}
		applovin.init( applovin_option )
	end

	-- adcolony用initialize
	if adcolony_isVisible == true then
		local adcolony_option = {
			apiKey       = this.option.adcolony_apiKey,
			debugLogging = this.option.adcolony_debugLogging,
			testMode     = this.option.adcolony_testMode,
		}
		adcolony.init( adcolony_option )
	end

	-- admobのinitialize
	if admob_isVisible == true then
		admob.init( this.option.nend_appID, admobOption )
	end

	-- admobのinitialize
	if webView_isVisible == true then
		webviewAds.init(webViewOption)
	end

	-- freepのinitialize
	if freep_isVisible == true then
		fads.init(freepOption)
	end

	is_initialized = true
end

function this.init(option)
	if userInfoData and userInfoData['id'] then
		--付加するパラメータ
		local params = {}
		params['platform'] = system.getInfo( "platformName" )
		params['language'] = system.getPreference("locale", "language")
		params['height'] = display.pixelHeight
		params['uid'] = userInfoData['id']
		params['ver'] = __app_ver or 1
		params['login_num'] = userInfoData['login_num'] or math.random( 100 )

		fnetwork.request(urlBase .. "ads/init.php", "POST", initListener, params)
	else
		timer.performWithDelay( 100, function() this.init(option) end)
	end
end

-------------------------
-- prepare
--
-- @params table option :
--
-- optionの中身
-- listener : eventListener
-------------------------
function this.prepare(ads_type, option)
	-- 会社に分けてprepare
	if this.option.service[ads_type] == 'chartboost' then
		chartboost.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'fyber' then
		fyber.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'vungle' then
		vungle.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'applovin' then
		applovin.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'adcolony' then
		adcolony.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'nend' then
		webviewAds.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'admob' then
		admob.prepare(ads_type, option)

	elseif this.option.service[ads_type] == 'freep' then
		fads.prepare( ads_type, option )
	end
end

--------------------------
-- init待ち
--------------------------
local waiting = {}

-------------------------
-- show
-------------------------
function this.show(ads_type, ads_option)
	assert( ads_type , "指定されたads_typeがありません" )

	local is_display = true
	-- for k, v in pairs(ads.showing_ads) do
	-- 	if k == ads_type then
	-- 		is_display = false
	-- 	end
	-- end

	if is_display == false then return end

	if is_initialized == false then
		if not waiting[ads_type] then
			waiting[ads_type] = {}
			waiting[ads_type]['count'] = 0
			waiting[ads_type]['option'] = ads_option
		end

		waiting[ads_type]['count'] = waiting[ads_type]['count'] + 1
		if waiting[ads_type]['count'] < 10 then
			waiting[ads_type]['timer'] = timer.performWithDelay( 100,
				function()
					this.show(ads_type, ads_option)
				end
			)
		else
			if waiting[ads_type]['timer'] then
				timer.cancel( waiting[ads_type]['timer'] )
			end
		end
	else
		-- 表示待ちの管理
		waiting[ads_type] = nil

		-- チャンネルが設定されている場合
		if ads_option and ads_option.channel then

		end
		-- 会社に分けてprepare
		if this.option.service[ads_type] == 'chartboost' then
			chartboost.show(ads_type,ads_option)

		elseif this.option.service[ads_type] == 'fyber' then
			fyber.show(ads_type,ads_option)

		elseif this.option.service[ads_type] == 'vungle' then
			vungle.show(ads_type,ads_option)

		elseif this.option.service[ads_type] == 'applovin' then
			applovin.show(ads_type,ads_option)

		elseif this.option.service[ads_type] == 'adcolony' then
			adcolony.show(ads_type,ads_option)

		elseif this.option.service[ads_type] == 'nend' or this.option.service[ads_type] == 'applipromotion' then
			if ads_option.return_obj == true then
				return webviewAds.show(ads_type,ads_option)
			else
				webviewAds.show(ads_type,ads_option)
			end

		elseif this.option.service[ads_type] == 'admob' then
			admob.show(ads_type, ads_option)

		elseif this.option.service[ads_type] == 'freep' then
			if ads_type == 'interstitial' then
				timer.performWithDelay( 800, function()
					fads.show(ads_type, ads_option)
				end )
			else
				fads.show(ads_type, ads_option)
			end
		end

		-- 表示中の広告追加
		this.showing_ads[ads_type] = ads_option or {}
	end
end


--------------------------
-- remove
--------------------------
function this.remove(ads_type, option)
	if waiting[ads_type] then
		if waiting[ads_type]['timer'] then
			timer.cancel( waiting[ads_type]['timer'] )
		end
	end

	-- チャンネルが設定されている場合
	if ads_option and ads_option.channel then
	end

	-- 会社に分けてprepare
	if this.option.service[ads_type] == 'chartboost' then
		chartboost.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'fyber' then
		fyber.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'vungle' then
		vungle.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'applovin' then
		applovin.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'adcolony' then
		adcolony.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'nend' then
		webviewAds.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'admob' then
		admob.remove(ads_type, option)

	elseif this.option.service[ads_type] == 'freep' then
		fads.remove(ads_type, option)
	end

	-- 表示中の広告除去
	this.showing_ads[ads_type] = nil
end

-- 広告を隠す
function this.unreveal( ads_type )
	assert(ads_type, 'ERROR : ads_typeを指定して下さい')

	-- チャンネルが設定されている場合
	if ads_option and ads_option.channel then
	end

	-- 会社に分けてprepare
	if this.option.service[ads_type] == 'chartboost' then
	elseif this.option.service[ads_type] == 'fyber' then

	elseif this.option.service[ads_type] == 'nend' then
		webviewAds.unreveal(ads_type)

	elseif this.option.service[ads_type] == 'admob' then

	elseif this.option.service[ads_type] == 'freep' then
		fads.unreveal(ads_type)
	end
end

function this.reveal( ads_type, ads_option )
	assert(ads_type, 'ERROR : ads_typeを指定して下さい')

	-- チャンネルが設定されている場合
	if ads_option and ads_option.channel then

	end

	-- 会社に分けてprepare
	if this.option.service[ads_type] == 'chartboost' then
		-- chartboost.reveal(ads_type)
	elseif this.option.service[ads_type] == 'fyber' then

	elseif this.option.service[ads_type] == 'nend' or this.option.service[ads_type] == 'applipromotion' then
		webviewAds.reveal(ads_type)

	elseif this.option.service[ads_type] == 'admob' then
		-- admob.reveal(ads_type)

	elseif this.option.service[ads_type] == 'freep' then
		fads.reveal(ads_type)
	end
end


----------------------------
-- 一旦非表示
----------------------------
local is_display = true
local ads_keep = {}
function this.hide(remove_ads)
	for k, v in pairs(ads.showing_ads) do
		if remove_ads ~= k then
			ads_keep[k] = v
			this.unreveal(k)
		end
	end
	is_display = false
	this:dispatchEvent( { name = 'ads-hide' } )
end


----------------------------
-- 非表示解除
----------------------------
function this.display(remove_ads)
	if is_display then return end
	if ads_keep ~= {} then
		for k, v in pairs(ads_keep) do
			-- リワードを非表示解除ということはないのであらかじめ省く
			if k ~= remove_ads and k ~= 'rewardedVideo' then
				this.reveal(k, v)
			end
		end
	end
	ads_keep = nil
	ads_keep = {}
	is_display = true
	this:dispatchEvent( { name = 'ads-display' } )
end

function this.destroy()
	ads_keep = nil
	ads_keep = {}
end

----------------------------
-- dispatchEvent
----------------------------
function this.eventHandler(event)
	if event.name == 'adsRequest' and event.provider == 'AdMobProvider' then
		if not event.isError then
			if event.phase == "shown" then
			    -- the ad was viewed and closed
			    if system.getInfo('platformName') == 'iPhone OS' and not webview_isHide then
				    this.hide( 'interstitial' )
				    timer.performWithDelay( 500, function() this.display( 'interstitial' ) end )
				end
			end
		end
	end
	this:dispatchEvent(event)
end

------------------
-- fadsListener
------------------
function this.fadsListener(event)

	-- アフィリエイト or 自社wall
	if event.phase == 'closed' and event.name ~= 'moyashi' then
		--　閉じた時に非表示にしていた広告を再表示
		this.display(event.name)

		-- 表示中の広告除去
		this.showing_ads[event.name] = nil

	elseif event.phase == 'showed' and event.name ~= 'moyashi' then
		--　その他広告を非表示
		this.hide(event.name)
	end

end

admob:addEventListener( this.eventHandler )
chartboost:addEventListener( this.eventHandler )
adcolony:addEventListener( this.eventHandler )
fyber:addEventListener( this.eventHandler )
vungle:addEventListener( this.eventHandler )
applovin:addEventListener( this.eventHandler )
webviewAds:addEventListener( this.eventHandler )
fads:addEventListener( this.eventHandler )
fads:addEventListener( this.fadsListener )

return this
