-- ProjectName : ads
--
-- Filename : fyber.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2016-06-09
--
-- Comment :
---------------------------------------------------------
local fyber = require("plugin.fyber")

local this = object.new()

this.initialized = false
this.fyber_appID = ''
this.fyber_token = ''

-----------------------------
-- 動画が見れなかった時
-----------------------------
local function waitingVideo()
	native.showAlert( '', '現在動画を準備中です。しばらく時間をおいて試してください', { 'OK' } )
end


------------------------------
-- イベントのリスナー
------------------------------
local function adFyberListener(event)
	if event.message == "DidReceivedVideo" then
		print("MSG:------ " .. event.name .. " value:" .. event.message)
		event.response = 'cached'
	end
	if event.message == "DidFailedToReceiveVideo" then
		print("MSG:------ " .. event.name .. " value:" .. event.message .. " reason: " .. event.reason)
		event.response = 'faildCached'
	end
	if event.message == "DidStartVideo" then
		print("MSG:------ " .. event.name .. " value:" .. event.message)
		event.response = 'startVideo'
	end
	if event.message == "FailedToStartVideo" then
		print("MSG:------ " .. event.name .. " value:" .. event.message .. " reason: " .. event.reason)
		event.response = 'faildVideo'
		waitingVideo()
	end
	if event.message == "DismissVideo" then
		print("MSG:------ " .. event.name .. " value:" .. event.message .. " reason: " .. event.reason)
		event.response = 'dismissVideo'
		fyber.requestRewardedVideo()
	end
	if event.message == "ReceivedVirtualCurrency" then
		print("MSG:------ " .. event.name .. " value:" .. event.message .. " currencyName: " .. event.currencyName .. " deltaOfCurrency:" .. event.deltaOfCurrency)
		event.response = 'reward'
		fyber.requestRewardedVideo()
	end
	if event.message == "FailedToReceiveVirtualCurrency" then
		print("MSG:------ " .. event.name .. " value:" .. event.message .. " reason: " .. event.reason)
		event.response = 'filadReward'
		fyber.requestRewardedVideo()
	end

	local dispatchEvent = {
		name = event.response,
	}
	this:dispatchEvent( dispatchEvent )
end


-------------------------
-- initialize
-------------------------
function this.init(option)
	if option.fyber_appID then
		this.fyber_appID = option.fyber_appID
	end
	if option.fyber_token then
		this.fyber_token = option.fyber_token
	end

	local appID = this.fyber_appID
	local token = this.fyber_token

	assert(appID, 'ERROR : fyber_appIDのIDを設定してください')
	assert(token, 'ERROR : fyber_tokenのIDを設定してください')

	-- fyberイニシャライズ
	fyber.init(appID, token, adFyberListener)
	this.initialized = true

	fyber.requestRewardedVideo()
	print("fyber -- initialize")
	print(appID, token)
end


-------------------------
-- prepare
-------------------------
function this.prepare(ads_type)
	assert(this.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです')

	-- prepare
	fyber.requestRewardedVideo()
end


-------------------------
-- show
-------------------------
function this.show(ads_type)
	assert(this.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'rewardedVideo', 'ERROR : 存在しないads_typeです')

	-- prepare
	print("fyber : "..ads_type)
	fyber.playRewardedVideo( ads_type )
	if 'simulator' == system.getInfo( 'environment' ) and ads_type == 'rewardedVideo' then
		adFyberListener( { response = 'reward' } )
	end
end


--------------------------
-- remove
--------------------------
function this.remove()
	-- fyber.closeImpression()
end
return this
