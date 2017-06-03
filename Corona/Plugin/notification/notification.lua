-- notification.lua
--
-- Comment : Schedule Push / Remote Pushを送る、設定する
-- Creater : Ryo Takahashi
-- Date : 2015-07-29
-----------------------------------------------------------
local OneSignal     = require("plugin.OneSignal")
local notifications = require( 'plugin.notifications' )
local self = object.new()

-- プロパティ宣言
self.id = nil
self.is_initialized = false
self.is_recovery_push = false

self.notify_log = {}
self.alert = {}

local alertMsg = 
{
	'チャージページが満タンになりました！'
}

--------------------------------
-- OneSignalのCallBackListener
--------------------------------
local function OneSignalCallBackListener(message, additionalData, isActive)
	if (additionalData) then
		if (additionalData.discount) then
			native.showAlert( "Discount!", message, { "OK" } )
			-- Take user to your in-app store
		elseif (additionalData.actionSelected) then -- Interactive notification button pressed
			native.showAlert("Button Pressed!", "ButtonID:" .. additionalData.actionSelected, { "OK"} )
		end
	else
		native.showAlert("OneSignal Message", message, { "OK" } )
	end
end

------------------------------------
-- ユーザーをセグメントに分ける
------------------------------------
local function OneSignalSendTag(data)
	if self.is_initialized then
		function printAllTags(delete_tags)
			local tags = {}
			for k, v in pairs(delete_tags) do
				table.insert(tags, k)
			end
			-- タグを削除
			OneSignal.DeleteTags(tags)

			-- タグ追加
			local add_tags = {}
			for k, v in pairs(data) do
				add_tags[k] = v
			end
			OneSignal.SendTags(add_tags)
		end

		-- 現在のタグを取得
		OneSignal.GetTags(printAllTags)
	end
end

--------------------------------------
-- init
--------------------------------------
local function initListener(event)
	local data = json.decode(event.response)
	if data.id then
		-- id設定
		self.id = data.id

		-- segment登録
		if data.tags then
			OneSignalSendTag(data.tags)
		end

		-- テキストファイルに保存
		local filename = 'info.json'
		writeText(filename, json.encode(data))
	end

	if data.recovery then
		self.is_recovery_push = true
	end

	if data.alert then
		self.alert = data.alert
	end
end

local function init()
	local filename = 'info.json'
	local json_data = readText(filename)
	
	if json_data then
		-- テキストファイルデータがない場合
		local data = json.decode( json_data )
		self.id = data.id
	end

	--付加するパラメータ
	local params = {}
	params['platform'] = system.getInfo( "platformName" )
	params['language'] = system.getPreference("locale", "language")
	params['app_ver']  = __app_ver or 1

	if self.id then
		params['id'] = self.id
	end

	fnetwork.request(urlBase .. "notification/init.php", "POST",initListener, params)	
end

function self.registerForPushNotifications()
	return notifications.registerForPushNotifications()
end

local function notificationListener( event )

	print(json.encode(event))
    if ( event.type == "remote" ) then
        --handle the push notification

    elseif ( event.type == "local" ) then
        --handle the local notification
    end
end

-- Schedule a notification using Coordinated Universal Time (UTC)
function self.set( name, time, message )
	assert( name, 'ERROR : not found name' )
	assert( time, 'ERROR : not found time' )
	if not self.is_recovery_push then return end	

	local i = math.random( #alertMsg )
	
	local utcTime = os.date( "!*t", os.time() + time )
	if not message then
		message = alertMsg[1]
	end
	local options = 
	{
	    alert = self.alert[name] or message,
	    badge = 0,
	    custom = { name = name, time = utcTime },
	    badge=1
	}
	if not self.notify_log[name] then
		-- 通知を追加
		self.notify_log[name] = notifications.scheduleNotification( time, options )
	else
		self.remove( name )
		self.set( name, time )
	end

	local event = 
	{
		name = 'notifications-set-finish',
		value = name,
	}
	self:dispatchEvent( event )
end

function self.remove( name )
	assert( name, 'ERROR : not found name' )

	if not self.notify_log[name] then
		return -1
	else
		notifications.cancelNotification( self.notify_log[name] )
		self.notify_log[name] = nil
		local event = 
		{
			name = 'notifications-remove-finish',
			value = name,
		}
		self:dispatchEvent( event )
	end
end

function self.reset()
	if system.getInfo( 'platformName' ) == 'iPhone OS' then
		local options = 
		{
		    alert = '',
		    badge = 0,
		    custom = { foo = 'bar' }
		}
		local notification1 = notifications.scheduleNotification( 10, options )
	end
end

-------------------------------------------------
-- 起動時に呼び出す
--
-- @params table option : 設定
--
-- optionの中身
-- one_signal_application_key : アプリのキー
-- google_product_number : 
-------------------------------------------------
function self.init(option)

	-- 登録番号の確認等
	init()

	-- local dealDir = existsDirectory( 'notification' )
	-- if not dealDir then
	-- 	createDirectory( 'notification' )
	-- end	
	function IdsAvailable(userID, pushToken)
	    print("PLAYER_ID:" .. userID)
	    if (pushToken) then -- nil if user did not accept push notifications on iOS
	        print("PUSH_TOKEN:" .. pushToken)
	    end
	end

	OneSignal.IdsAvailableCallback(IdsAvailable)

	assert(option.one_signal_application_key, 'ERROR : one_signal_application_keyが設定されていません')
	assert(option.google_product_number, 'ERROR : google_product_numberが設定されていません')
	assert(type(option.google_product_number) == 'string', 'ERROR : google_product_numberは文字列にして設定して下さい')

	-- One Signalのイニシャライズ
	if option.one_signal_application_key and option.google_product_number then
		OneSignal.Init(option.one_signal_application_key, option.google_product_number, OneSignalCallBackListener)
		self.is_initialized = true
	end
end
Runtime:addEventListener( 'notification', notificationListener )
return self