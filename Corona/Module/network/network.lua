-- tsnetwork.lua
-- Comment : networkをカスタマイズ
-- Date : 2015-1-31
-- Creater : Ryo Takahashi
-----------------------------------------------
local MultipartFormData = require( ModDir .. 'network.class_MultipartFormData' )

module(..., package.seeall)


local function removeTableContents( array )
	if array and #array > 0 then
		for key = 1, #array do
			local value = array[key]
			key = nil
			value = nil
		end
		array = nil
		array = {}
	end
end

-- ネットワークへのConnectionを確保する
local timerTable = {}
local checkNetworkTable = {}
local checkRetryTime = 100
local checkCountNum = 0
local function checkNetworkStatus( func )

	local function checkNetworkStatusListener( event )
		print( 'event.status', event.status )

		if event.isError then
			print("network error!!")
		end
		if event.status < 0 then

			--規定回数以上失敗したら
			if #timerTable >= 60 then
				_is_network_connect = true
			else
				--再度時間をおいて接続
				timer.performWithDelay( 50,
					function()
						func()
					end
				)
			end
		elseif event.status ~= 200 then

			--規定回数以上失敗したら
			if #timerTable >= 10 then
				_is_network_connect = true
			else
				--再度時間をおいて接続
				timer.performWithDelay( 500,
					function()
						func()
					end
				)
			end
		else
			--リクエスト成功
			_is_network_connect = true
			func()
		end
	end


	if _is_network_connect == false then
		local function timerEventListener( event )
		    
		    if _is_network_connect == false then
			    --print( '_is_network_connect', _is_network_connect, checkRetryTime )

			    print( "checkNetworkStatus called ", checkCountNum )
			    checkCountNum = checkCountNum + 1
			    
			    if checkNetworkTable[ #checkNetworkTable ] then
				    network.cancel( checkNetworkTable[ #checkNetworkTable ] )
				end
			    if _is_network_connect or checkCountNum > 20 then
			    	timer.cancel( event.source )
			    	 --print( '_is_network_connect', _is_network_connect, checkCountNum )
			    	checkCountNum = 0
			        for k = 1, #checkNetworkTable do
			        	local v = checkNetworkTable[k]
			        	network.cancel( v )
			        end
			        checkRetryTime = checkRetryTime+100
			    	if checkRetryTime > 500 then
			    		-- checkRetryTime = 500
			    		_is_network_connect = true
			    	end
			    	func()
			        removeTableContents( timerTable )
			        removeTableContents( checkNetworkTable )
			    end
			end
		end

		local timerHandler = timer.performWithDelay( checkRetryTime, timerEventListener, 0 )
		timerTable[ #timerTable + 1 ] = timerHandler

		local checkRequest = network.request( 'https://encrypted.google.com/', 'GET', checkNetworkStatusListener )
		checkNetworkTable[ #checkNetworkTable + 1 ] = checkRequest
	end
end


-- ネットワークエラーがあります！！
local timerTable = {}
local function allTimerCanceler()
		local k, v
		for k,v in pairs(timerTable) do
				timer.cancel( v )
				v = nil; k = nil
		end
		timerTable = nil
		timerTable = {}
end

--ネットワーク接続
_is_network_connect = false
local connectErrorNum = 0
local networkTable = {}
local timeTable = {6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000}

function request(url, method, listener, params, errorCode)
	assert(listener, "Error: Not found Listener ")

	checkRetryTime = 100
	checkCountNum = 0
	
	--前方宣言
	local subListener, request, timeoutFunction

	networkTable[url] = {}


	-- ポップアップを閉じる
	local function closePopup()
		transition.to(popup, {time=200, alpha=0, onComplete=
			function()
				display.remove(popup)
				popup = nil
			end
		})
	end


	-- ネットワークエラーのポップアップ
	local function networkErrorPopup()
		--ユーザー用のpopupタイマーを止める
		if networkTable[url]["retry"] then
			timer.cancel(networkTable[url]["retry"])
		end

		-- 再生接続用のポップアップ表示
		local alert = native.showAlert( '通信エラー', '電波のいい環境で再度お試し下さい。', { 'OK' } )
	end

	-- Responseが返ってくる場合
	function subListener(event)

		if event.isError then
			print("network error!!")
		end
		if event.status < 0 then

			--失敗した回数
			networkTable[url]["count1"] = networkTable[url]["count1"] + 1
			--規定回数以上失敗したら
			if networkTable[url]["count1"] >= 100 then
				_is_network_connect = false
				networkErrorPopup()
			else
				--再度時間をおいて接続
				timer.performWithDelay(50,
					function()
						netrequest()
					end
				)
			end
		elseif event.status ~= 200 then
			--失敗した回数
			networkTable[url]["count2"] = networkTable[url]["count2"] + 1
			--規定回数以上失敗したら
			if networkTable[url]["count2"] >= #timeTable then
				_is_network_connect = false
				networkErrorPopup()
			else
				--再度時間をおいて接続
				timer.performWithDelay(timeTable[networkTable[url]["count2"]],
					function()
						netrequest()
					end
				)
			end
		else

			--リクエスト成功
			listener(event)

			-- json中身判定
			local data = json.decode(event.response)
			-- print( data )
			if data then

				--print(event)
				--強制ログアウト	
				if data.forced_logout == true then


				else

					-- ポップアップがないかを確認
					if data.remote_popup and __blockPopup == false then
						showRemotePopup(data.remote_popup)
					end

					-- レスポンスに新規のデータがあれば自動でDLする
					if data.remote_data then
						local dl_manager = require( ContDir .. 'dl_manager' )
						dl_manager.getDataFromUrl( data.remote_data )
					end			

					-- pointがないかを確認
					if data.time_is_money and userInfoData then
						userInfoData['item'] = tonumber( data.time_is_money )
						Runtime:dispatchEvent( { name = 'user_model-time_is_money', point = userInfoData['item'] } )
					end

					-- stminaがないかを確認
					if data.stamina_now and playerInfoData then
						playerInfoData['stamina'] = tonumber( data.stamina_now )
						Runtime:dispatchEvent( { name = 'user_model-stamina_now', stamina = playerInfoData['stamina'] } )
					end

					-- インセンティブを渡す
					if data.present_for_you and userInfoData and playerInfoData then
						local incentiveManager = require( ContDir .. 'incentiveManager' )
						incentiveManager.getDataFromUrl( data.present_for_you )
					end

					-- 広告がないか確認
					if data.ads_type then
						print( 'ads_type' )
						showRemoteAds(data.ads_type)
					end
				end
			end


			--ユーザー用のpopupタイマーを止める
			timer.cancel(networkTable[url]["errorTimer"])
			--timer.cancel(networkTable[url]["retryTimer"])    
		end
	end

	-- 30秒以上Responseがなかったら
	function timeoutFunction()
		network.cancel(networkTable[url]["request"])
	end

	--ネットワークリクエスト
	networkTable[url]["count1"]   = 0
	networkTable[url]["count2"]   = 0

	function netrequest()
		--print( 'request', url, _is_network_connect )
		if true then --if _is_network_connect then

			local multipart = MultipartFormData.new()
			for k, v in pairs(params) do
				multipart:addField(k ,v)
			end

			local parameters = {}
			parameters.body = multipart:getBody() -- Must call getBody() first!
			local headers = multipart:getHeaders() 
			headers["User-Agent"] = userAgent
			parameters.headers = headers			

			networkTable[url]["request"] = network.request(url, method, subListener, parameters)
			networkTable[url]["errorTimer"] = timer.performWithDelay(30000, timeoutFunction)
		else
			checkNetworkStatus( netrequest )
		end
	end
	netrequest()
end



function download(...)

end
