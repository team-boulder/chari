-- ProjectName : Talkspace
--
-- Filename : btn.lua
--
-- Creater : Ryo Takahashi, Seiya Iwaki
--
-- Date : 2013-02-08
-- Update: 2014-04-02
-- Comment : 
--
-------------------------------------------------
-- 
-- *strokeWidth  線の太さ 1.5
-- *文字の色 0
-- *pushed
-- 画像あり　setFillcolor(180)
-- 画像なし　元のカラー×0.8
-- *timer 230
-- *fontsize 24
--------------------------------------------------

local btn = {}


-------------------------------------------------------
-- btn.newRect
--
-- 画像なしでボタンを作るパターン
--------------------------------------------------------

function btn.newRect(option)
	----------------------------------
	-- option.group    	   : 
	-- option.x        	   :
	-- option.y        	   :
	-- option.width    	   :
	-- option.height   	   :
	-- option.str      	   :
	-- option.font     	   :
	-- option.fontSize 	   :
	-- option.fontColor	   :
	-- option.color    	   :
	-- option.colorStroke  :	
	-- option.action       : 
	-- option.stroke       :
	-- option.edgeColor    :
	-- option.shadowColor  :
	----------------------------------
	local o = option
	local group = display.newGroup()

	local x = o.x
	local y = o.y

	--文字
	local fontSize = o.fontSize or 18
	local textColor = o.fontColor or 0
	local font = o.font or nil
	local str = o.str or "ボタン１"

	local text
	if o.strLine then -- 複数行の文字ボタン
		if o.strLine[3] ~= nil and o.strLine[4] ~= nil then
			text = display.newText(str, 0, 0, o.strLine[3], o.strLine[4],font, fontSize)
		else
			text = display.newText(str, 0, 0, font, fontSize)
		end
	else
		text = display.newText(str, 0, 0, font, fontSize)
	end

	if o.fontColor then
		text:setFillColor(o.fontColor[1],o.fontColor[2],o.fontColor[3], o.fontColor[4] or 255)
	else
		text:setFillColor(0)
	end

	--背景
	local width = o.width or text.width + 20
	local height = o.height or text.height + 20
	local rounded = o.rounded or 0

	local colorStroke = o.colorStroke or 255
	local pushedFontColor = o.pushedFontColor or 255

	--影をつける
	local edgeGroup = display.newGroup()
	group:insert(edgeGroup)

	local mainRect = display.newRoundedRect(0, 0, width, height, rounded)
	if o.colorStroke then
		mainRect:setStrokeColor(o.colorStroke[1] or 145,o.colorStroke[2] or 208,o.colorStroke[3] or 95,o.colorStroke[4] or 255)
		mainRect.strokeWidth = 1.5
	else
		--mainRect:setStrokeColor(230)
	end

	if o.edgeColor then
		--影をつける
		local function edge()
			mainRect:setStrokeColor(o.edgeColor[1], o.edgeColor[2], o.edgeColor[3], o.edgeColor[4] or 255)
			mainRect.strokeWidth = 1.5
			if o.edge ~= false then
				local edgeRect = display.newRoundedRect(0, 0, width, height+3, rounded)
				edgeRect:setFillColor(o.edgeColor[1], o.edgeColor[2], o.edgeColor[3], o.edgeColor[4] or 255)
				group:insert(edgeRect)
			end
		end
		edge()
	end
	if o.shadowColor then
		local edgeRect = display.newRoundedRect(0, 0, width, height+3, rounded)
		edgeRect:setFillColor(o.shadowColor[1], o.shadowColor[2], o.shadowColor[3], o.shadowColor[4] or 255)
		group:insert(edgeRect)
	end

	local color = o.color or 255
	local noPushedColor = {} -- push色が指定されていない場合
	if o.color then
		mainRect:setFillColor(o.color[1],o.color[2],o.color[3], o.color[4] or 255)
		if o.pushedColor == nil then
			if o.color[1] ~= nil then
				noPushedColor[1] = math.floor(o.color[1]*0.8)
			end
			if o.color[2] ~= nil then
				noPushedColor[2] = math.floor(o.color[2]*0.8)
			end
			if o.color[3] ~= nil then
				noPushedColor[3] = math.floor(o.color[3]*0.8)
			end
			if o.color[4] ~= nil then
				noPushedColor[4] = math.floor(o.color[4]*0.8)
			end
		end
	else
		mainRect:setFillColor(255)
		if o.pushedColor == nil then 
			noPushedColor = {math.floor(255*0.8),math.floor(255*0.8),math.floor(255*0.8),math.floor(255*0.8)}
		end
	end

	if o.strLine then
		text.x = o.strLine[1]
		text.y = o.strLine[2]
	else
		text.x = mainRect.width*0.5
		text.y = mainRect.height*0.5
	end
	if o.strPoint == "center" then
		text:setReferencePoint( display.CenterReferencePoint )
		text.x = mainRect.x
	end

	group:insert(mainRect)
	group:insert(text)

	-- ボタンを押し始めた状態
	local function beganBtn()
		if o.pushedColor then
			mainRect:setFillColor(o.pushedColor[1],o.pushedColor[2],o.pushedColor[3], o.pushedColor[4] or 255)
			if o.pushedFontColor then
				text:setFillColor(o.pushedFontColor[1], o.pushedFontColor[2], o.pushedFontColor[3], o.pushedFontColor[4] or 255)
			else
				text:setFillColor(255)
			end
			timer.performWithDelay(230, 
			    function()
					if pcall(function ()
							if mainRect then
								if o.color then
									mainRect:setFillColor(o.color[1], o.color[2], o.color[3], o.color[4] or 255)
								else
									mainRect:setFillColor(255)
								end
								if o.fontColor then
									text:setFillColor(o.fontColor[1],o.fontColor[2],o.fontColor[3], o.fontColor[4] or 255)
								else
									text:setFillColor(0)
								end
							else
								display.remove(mainRect)
								mainRect = nil
							end
						end) then
					else
						tsprint("btn.lua: btn.newRect()  pcall        exception handling")
						display.remove(mainRect)
						mainRect = nil
					end	

				-- if mainRect then
				-- 	if o.color then
				-- 		mainRect:setFillColor(o.color[1], o.color[2], o.color[3], o.color[4] or 255)
				-- 	else
				-- 		mainRect:setFillColor(255)
				-- 	end
				-- 	if o.fontColor then
				-- 		text:setFillColor(o.fontColor[1],o.fontColor[2],o.fontColor[3], o.fontColor[4] or 255)
				-- 	else
				-- 		text:setFillColor(0)
				-- 	end
				-- end	
				end
			)
		else
			mainRect:setFillColor(noPushedColor[1], noPushedColor[2], noPushedColor[3], noPushedColor[4] or 255)
			timer.performWithDelay(230, 
				function()
					-- if o.color then
					-- 	mainRect:setFillColor(o.color[1], o.color[2], o.color[3], o.color[4] or 255)
					-- else
					-- 	mainRect:setFillColor(255)
					-- end
					if pcall(function ()
						if o.color then
							mainRect:setFillColor(o.color[1], o.color[2], o.color[3], o.color[4] or 255)
						else
							mainRect:setFillColor(255)
						end
						end) then
					else
						display.remove(mainRect)
						mainRect = nil
					end
				end
			)
		end
	end
	-- ボタンを離した状態
	local function endedBtn()
		if o.pushedColor then
			if o.color then
				mainRect:setFillColor(o.color[1],o.color[2],o.color[3], o.color[4] or 255)
			else
				mainRect:setFillColor(255)
			end					
			if o.fontColor then
				text:setFillColor(o.fontColor[1],o.fontColor[2],o.fontColor[3], o.fontColor[4] or 255)
			else
				text:setFillColor(0)
			end
		else
			-- 	mainRect.alpha = 1.0
			if o.color then
				mainRect:setFillColor(o.color[1], o.color[2], o.color[3], o.color[4] or 255)
			end
		end
	end

	if o.filter ~= nil then
		local filter = display.newRect(group,o.filter[1] or mainRect.x,o.filter[2] or mainRect.y,o.filter[3] or mainRect.width, o.filter[4] or mainRect.height)
	    filter.isVisible = false
	    filter.isHitTestable = true

		filter:addEventListener("touch",
			function(event)
				if event.phase == "began" then
					beganBtn()
				else
					endedBtn()
				end	
			end
		)
		if o.action then
			filter:addEventListener("tap", o.action)
		end
	else
		mainRect:addEventListener("touch",
			function(event)
				if event.phase == "began" then
					beganBtn()
				else
					endedBtn()
				end	
			end
		)
		if o.action then
			mainRect:addEventListener("tap", o.action)
		end
	end

	group.x = o.x
	group.y = o.y

	if o.group then
		o.group:insert(group)
		o.group:insert(edgeGroup)
	end

	group:setReferencePoint(display.CenterReferencePoint)

	return group
end

-------------------------------------------------------
-- btn.newPushImage
--
-- ボタンを押している状態に画像を変化させる
--------------------------------------------------------
function btn.newPushImage(option)
	----------------------------------
	-- option.group    	   : 
	-- option.image    	   :
	-- option.str          :
	-- option.x        	   :
	-- option.y        	   :
	-- option.fillter      :
	-- option.action       : 
	-- option.horizontal   :
	----------------------------------
	local o = option
	local group = display.newGroup()

	--local action = option.action or nil
	local dir = o.dir or system.ResourceDirectory
	local image = display.newImage(group, o.image, dir, o.x or 0, o.y or 0 )
	image.alpha = 1.0

	if o.imageScale then
		image:scale(o.imageScale[1],o.imageScale[2])
	end

	if option.horizontal == 1 then
		image.xScale = -1
	end

	local focusW, focusH = nil, nil
	if o.focusX then

		image.x = o.focusX
		focusW = o.focusX-image.width*0.5
	end
	if o.focusY then

		image.y = o.focusY
		focusH = o.focusY-image.height*0.5
	end

	if o.str ~= nil then
		local text = display.newText(group,o.str, 0, 0, o.font or native.systemFont, o.fontSize or 25)
		if o.strX ~= nil then
			text.x =  o.strX
		else
			text.x = image.x
		end

		if o.strY ~= nil then
			text.y =  o.strY
		else
			text.y = image.y
		end
		-- text.x, text.y = image.x, image.y

		if o.fontColor then
			text:setFillColor(o.fontColor[1],o.fontColor[2],o.fontColor[3], o.fontColor[4] or 255)
		end

	end

	-- focusを設定した関係上必要な変数
	if focusW == nil then
		focusW = 0
	end
	if focusH == nil then
		focusH = 0
	end
	
	--ボタンを押すときの反応範囲
	local imageFilter
	if o.fillter ~= nil or o.filter ~= nil then
		if o.fillter ~= nil then
			imageFilter = display.newRect(group,o.fillter[1],o.fillter[2],o.fillter[3],o.fillter[4])
		elseif o.filter ~= nil then
			imageFilter = display.newRect(group,o.filter[1],o.filter[2],o.filter[3],o.filter[4])
        end
        imageFilter:setFillColor( 255, 0, 0 )
        imageFilter.x, imageFilter.y = image.x, image.y
        imageFilter.alpha = __HitTestAlha
	    imageFilter.isHitTestable = true

	    imageFilter:addEventListener("touch",function(event)
        	if event.phase == "began" then
				image:setFillColor(180)
				timer.performWithDelay( 230,
					function() 
						if pcall(function()
								if image then
									image:setFillColor(255) 
								else 
									display.remove( image )
									image = nil
								end
							end) then
						else
							display.remove( image )
							image = nil
						end
					end
				)

			end
			--return true
	    end)
	else
		imageFilter = display.newRect(group, -10+(o.x or focusW),-10+(o.y or focusH),image.width + 20, image.height + 20)
		imageFilter.x, imageFilter.y = image.x, image.y
        imageFilter:setFillColor( 255, 0, 0 )
        imageFilter.alpha = __HitTestAlha
        imageFilter.isHitTestable = true

	    imageFilter:addEventListener("touch",function(event)
			if event.phase == "began" then
				--image.alpha = 0.5
				image:setFillColor( 180 )
				timer.performWithDelay(230,
					function() 
						if pcall(function()
								if image then
									image:setFillColor(255) 
								else 
									display.remove( image )
									image = nil
								end
							end) then
						else
							display.remove( image )
							image = nil
						end
					end
				)
			end
			--return true
	    end)
	end

	imageFilter:addEventListener("tap",
		function()
			image:setFillColor(255)
			if o.action then o.action() end
			-- return true
		end
	)
	--group.x = o.x or 0
	--group.y = o.y or 0
	--[[
	if o.group then 
		o.group:insert(group)
	end
	--]]

	if o.group then
		o.group:insert(group)
	end

	group:setReferencePoint( display.CenterReferencePoint )

	return group
end

function btn.newImage( ... )
	return btn.newPushImage( ... )
end


return btn