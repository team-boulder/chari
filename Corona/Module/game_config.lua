--[[
@
@ Project  :
@
@ Filename : game_config.lua
@
@ Author   : Task Nagashige
@
@ Date     :
@
@ Comment  : ゲーム性の設定
@
]]--

-- n秒間どれくらい回復するか
-- TODO : 今は1秒に1回復する
__recovery_per_sec = 300

-- 課金アイテムの名称
__iab_item = 'クリスタル'

-- ガチャの値段
__gacha_price = 1

__long_tap_time = 300

__reward_diff = 300

-- TODO : チャージアイコンの名前
__charge_icon_name = 'アイコン'

-- TODO : チャージアイテムの回復薬の名前
__charge_potion_name = 'チケット'

-- TODO : チャージにリワードの助っ人がくる間隔（seconds）
__charge_helper_interval = 5*60

__tips_num = 2

function showModal2()
	if __loadingModalGroup == nil then

		__loadingModalGroup = display.newGroup()

		local bg = display.newImage( ImgDir .. 'play/bg3.jpg' )
		-- bg.isVisible = false
		bg.isHitestable = true

		local popup = display.newImage(ImgDir..'start/dl.png')

		local tips_src = math.random( __tips_num )
		local tips_image = display.newImage( ImgDir .. 'modal/tips/' .. tips_src .. '.png' )
		tips_image.x, tips_image.y = _W*0.5, 350

		__progress_text = display.newImage(ImgDir..'start/point.png',0,0)
		__progress_text.x, __progress_text.y = _W/2+70, _H/2+210

		__loading_text = number.newImage( 0, ImgDir..'number/rank', 0, 0,'jpg')
		__loading_text.x, __loading_text.y = _W/2+190, _H/2+205

		__spinner = widget.newSpinner
		{
			width = 120,
			height = 120,
		}
		__spinner.x, __spinner.y = _W*0.5, _H*0.5-60
		__spinner.isVisible = false

		bg:addEventListener( 'tap', returnTrue )
		bg:addEventListener( 'touch', returnTrue )

		__loadingModalGroup:insert( bg )
		__loadingModalGroup:insert( popup )
		__loadingModalGroup:insert( tips_image )
		__loadingModalGroup:insert( __loading_text )
		__loadingModalGroup:insert( __spinner )
		__loadingModalGroup:insert( __progress_text )

		if __spinner and __spinner.parent then
			local flag, ret = pcall( __spinner.start, __spinner )
			if not flag then
				print("error", ret)
			end
		end

		__loadingModalGroup.x = 0
		__loadingModalGroup:setReferencePoint( display.CenterReferencePoint )
		__loadingModalGroup:scale( 0.2, 0.2 )
		transition.to( __loadingModalGroup, { time = 300, xScale = 1, yScale = 1, transition=easing.outBack } )
	end
end

function progress_point()
end

--スタミナ自然回復処理
timer.performWithDelay( 1000, function()
	if playerInfo and playerInfoData then
		if playerInfoData['stamina'] and playerInfoData['stamina_limit'] and playerInfoData['stamina'] < playerInfoData['stamina_limit'] then
			local utc_time = os.time(os.date('*t'))
			local add_stamina = math.abs( (utc_time-playerInfoData['stamina_time'])/__recovery_per_sec )
			local check_add_stamina = math.ceil( add_stamina )

			-- 整数チェック
			if type( add_stamina ) == 'number' and add_stamina == check_add_stamina then
				playerInfoData['stamina'] = playerInfoData['stamina'] + add_stamina
			end
			if playerInfoData['stamina'] > playerInfoData['stamina_limit'] then
				playerInfoData['stamina'] = playerInfoData['stamina_limit']
			end
			-- playerInfo.save()
			Runtime:dispatchEvent( { name = 'user_model-stamina_now', stamina = playerInfoData['stamina'], time = playerInfoData['stamina_time'] } )
		end
	end
end, -1 )
