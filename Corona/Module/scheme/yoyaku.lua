--[[
@
@ Project  :
@
@ Filename : yoyaku.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2016-05-18
@
@ Comment  : urlスキームから特典を配布する。失敗時の挙動も必ず入れる
@
]]--

-- -- 起動時
-- local launchArguments = ...
-- if launchArguments then
-- 	local url  = launchArguments.url
-- 	yoyaku.init( url )
-- end

local self = object.new()

-- urlに含まれるシリアルコードをPOST
local function call( options )

	local url      = options.url
	local listener = options.listener

	if url and url:find( 'fcode' ) then
	
		-- idとtokenチェック
		if userInfoData.id == nil or userInfoData.token == nil then
			local alert = native.showAlert( '※ 特典エラー', 'チュートリアル完了後に再度お試しください。', { 'OK' } )
		end

		local function networkListener( e )
			print( e )
			if e.isError then
				local alert = native.showAlert( '※ 特典エラー', '通信エラーが発生しました。再度お試しください。', { 'OK' } )
			else
				local data = json.decode( e.response )
				
				-- データ取得時の処理
				if data.result == 'success' then
					if data.my_item and type( data.my_item ) == 'number' then
						userInfoData['item'] = tonumber( data.my_item )
					end
					local yoyaku_item = __yoyaku_item or 'アイテム'
					local alert = native.showAlert( '☆予約特典☆', '予約特典の' .. yoyaku_item .. 'を取得しました。\n\n※ 特典の配布は1ユーザーにつき1度です。', { 'OK' } )
				else
					local reason = data.reason or 'Unknown Error'
					local message = '予期せぬエラーが発生しました。エラーコードを控えてお問い合わせください。\n\nエラーコード：' .. reason
					if reason == 'already published' then
						message = '既に習得済みです。'
					elseif reason == 'invalid code' then
						message = '不正なコードです。'
					end
					local alert = native.showAlert( '※ 特典エラー', message, { 'OK' } )
				end

				hideModal()
				local event = 
				{
					name  = 'scheme-call',
					phase = data['result'],
					data  = data,
				}
				self:dispatchEvent( event )
			end

			-- どうしてもここでやりたい処理用のlistener
			if listener and listener ~= '' then
				listener()
			end
		end

		local fcode = url:match('fcode=(%w+)')

		if fcode == 'fhoge123' then
			local alert = native.showAlert( '※ 特典テスト', '予約特典の組み込み成功', { 'OK' } )
		end

		--付加するパラメータ
		local params = {}
		params['token'] = userInfoData.token
		params['uid']   = userInfoData.id
		params['fcode'] = fcode

		showModal()
		fnetwork.request( urlBase .. 'incentive/scheme.php', 'POST', networkListener, params )

	else
		local alert = native.showAlert( '※ 特典エラー', '特典コードが正しくないようです。再度お試しください。', { 'OK' } )
	end
end

function self.init( options )
	if options.url == nil or options.url == '' then return end
	call( options )
end

return self