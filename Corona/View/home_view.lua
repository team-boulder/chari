local self = object.new()

local obj = {}
local tableData = {
	{ label = '夏山', value = 'natsu' },
	{ label = '芝',   value = 'shiba' },
	{ label = '熊川', value = 'kuma' },
	{ label = '前原', value = 'mae' },
}
local TextColor = {0,0,0}

local themeColor = {255,255,255}
--playerInfoData['theme_color']
local headerSize = 300
local boxSize = 100

local function createContent(str)
	local group = display.newGroup()

	local box = display.newRect(group,0,0,_W,boxSize)
	box:setStrokeColor(220)
	box.strokeWidth = 2
	
	function box:touch(event)
		if event.phase == "began" then
			self:setFillColor(unpack(themeColor))
			timer.performWithDelay(100,function()
				self:setFillColor(255)
			end)
		end
	end
	box:addEventListener('touch')
	return group
end

function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()

		obj.scoreNum = playerInfoData['max_score']

		-- tytle
		obj.header = display.newRect(0,_H/5,_W,headerSize)
		obj.header:setFillColor(unpack(themeColor))
		obj.title = display.newText('Season of チャリ走',0,0,'Noto-Midium.otf',60)
		obj.title:setReferencePoint(display.CenterReferencePoint)
		obj.title.x = _W/2
		obj.title.y = _H/5 + headerSize/3
		obj.title:setFillColor(unpack(TextColor))
		obj.title2 = display.newText('~Presented team Boulder~',0,0,'Noto-Midium.otf',40)
		obj.title2:setReferencePoint(display.CenterReferencePoint)
		obj.title2.x = _W/2
		obj.title2.y = _H/5 + headerSize*2/3
		obj.title2:setFillColor(unpack(TextColor))

		obj.title3 = display.newText('MaxScore：'..obj.scoreNum,0,0,'Noto-Midium.otf',50)
		obj.title3:setReferencePoint(display.CenterReferencePoint)
		obj.title3.x = _W/2
		obj.title3.y = _H*5/7
		obj.title3:setFillColor(unpack(themeColor))

		obj.chari = display.newImage( ImgDir..'home/chari.png', 0, 0)
   		obj.chari:scale(0.5,0.5)
		obj.chari.x = _W/2
    	obj.chari.y = _H*4/7

		-- Startボタンの生成
		obj.startButton = display.newGroup()
		local circle = display.newCircle( obj.startButton, _W-150, _H-150, 100)
		local plus = display.newText( obj.startButton, 'Start', 0, 0, nil, 70)
		plus:setReferencePoint(display.CenterReferencePoint)
		plus.x = circle.x
		plus.y = circle.y
		circle:setFillColor(255,50,50)
		circle.fill.effect = "filter.bloom"
		circle.fill.effect.levels.white = 0.2
		circle.fill.effect.levels.black = 1.0
		circle.fill.effect.levels.gamma = 0.2
		obj.startButton:setReferencePoint(circle.x, circle.y)
		obj.startButton.anim = true
		obj.startButton.value = 'start'
		obj.startButton:addEventListener('tap',self.tap)

		-- Ruleボタンの生成
		obj.ruleButton = display.newGroup()
		local b_rule = display.newCircle( obj.ruleButton, 100, _H-100, 50)
		local r_plus = display.newText( obj.ruleButton, 'Rule', 0, 0, nil, 40)
		r_plus:setReferencePoint(display.CenterReferencePoint)
		r_plus.x = b_rule.x
		r_plus.y = b_rule.y
		b_rule:setFillColor(50,50,255)
		b_rule.fill.effect = "filter.bloom"
		b_rule.fill.effect.levels.white = 0.2
		b_rule.fill.effect.levels.black = 1.0
		b_rule.fill.effect.levels.gamma = 0.2
		obj.ruleButton:setReferencePoint(b_rule.x, b_rule.y)
		obj.ruleButton.anim = true
		obj.ruleButton.value = 'start'
		obj.ruleButton:addEventListener('tap',self.tap)

		--[[
		obj.menu = display.newImage( ImgDir .. 'home/menu.png',30,30)
		obj.menuArea = display.newRect(0,0,150,100)
		obj.menuArea.value = 'menu'
		obj.menuArea.isVisible = false
		obj.menuArea.isHitTestable = true
		obj.menuArea:addEventListener('tap',self.tap)
		obj.scrollView = widget.newScrollView(
		{
        	top = 0,
        	left = 0,
        	width = _W,
        	height = _H,
        	scrollWidth = 60,
        	scrollHeight = 80
		})
		obj.scrollView:setIsLocked( true, "horizontal" )
--]]
		--[[
		-- 連想配列から取り出してテーブルを作成
		for i,v in ipairs(tableData) do
			obj[v.value] = createContent(v.label)
			obj[v.value].y = headerSize + (i-1)*boxSize
			obj[v.value].value = v.value
			obj[v.value]:addEventListener('tap',self.tap)
			obj.scrollView:insert(obj[v.value])
			obj.contentNum = obj.contentNum + 1
		end

		-- 追加ボタンの生成
		obj.startButton = display.newGroup()
		local circle = display.newCircle( obj.startButton, _W-100, _H-100, 50)
		local plus = display.newText( obj.startButton, '＋', 0, 0, nil, 70)
		plus:setReferencePoint(display.CenterReferencePoint)
		plus.x = circle.x
		plus.y = circle.y
		circle:setFillColor(unpack(themeColor))
		circle.fill.effect = "filter.bloom"
		circle.fill.effect.levels.white = 0.2
		circle.fill.effect.levels.black = 1.0
		circle.fill.effect.levels.gamma = 0.2
		obj.startButton:setReferencePoint(circle.x, circle.y)
		obj.startButton.anim = true
		obj.startButton.value = 'add'
		obj.startButton:addEventListener('tap',self.tap)

		-- メニューを予め作成しておく
		obj.menuGroup = display.newGroup()
		obj.menuBG = display.newRect(0,0,_W,_H)
		obj.menuBG:setFillColor(0,0,0,150)
		obj.menuBG.alpha = 0
		obj.menuBG.value = 'menubg'
		obj.menuBG:addEventListener('tap',self.tap)
		obj.menuBG:addEventListener('touch',self.touch)
		obj.menuWindow = display.newRect(obj.menuGroup,0, 0, 400, _H)
		obj.menuWindow:setFillColor(240)
		obj.menuWindow.value = 'menuWindow'
		obj.menuWindow:addEventListener('tap',self.tap)
		obj.menuWindow:addEventListener('touch',self.touch)
		obj.menuTitle = display.newText(obj.menuGroup,'ありがちなメニュー',0,0,'Noto-Light.otf',35)
		obj.menuTitle:setReferencePoint(display.CenterReferencePoint)
		obj.menuTitle:setFillColor(100)
		obj.menuTitle.x = obj.menuWindow.x 
		obj.menuTitle.y = 50
		obj.menuSetting = display.newText(obj.menuGroup,'設定',0,0,'Noto-Light.otf',35)
		obj.menuSetting:setReferencePoint(display.CenterReferencePoint)
		obj.menuSetting:setFillColor(100)
		obj.menuSetting.x = obj.menuWindow.x 
		obj.menuSetting.y = 180
		obj.menuSetting.value = 'setting'
		obj.menuSetting:addEventListener('tap',self.tap)
		obj.menuGroup.x = -400
		obj.menuGroup.alpha = 0

		-- ポップアップウィンドウも予め作成しておく
		obj.popupGroup = display.newGroup()
		obj.bg = display.newRect(obj.popupGroup,0,0,_W,_H)
		obj.bg:setFillColor(0,0,0,150)
		obj.bg.value = 'bg'
		obj.bg:addEventListener('tap',self.tap)
		obj.bg:addEventListener('touch',self.touch)
		obj.popupWindow = display.newRect(obj.popupGroup,1/10*_W, 1/5*_H, 4/5*_W, 3/5*_H)
		obj.popupWindow:setFillColor(240)
		obj.popupWindow.value = 'popupWindow'
		obj.popupWindow:addEventListener('tap',self.tap)
		obj.popupWindow:addEventListener('touch',self.touch)
		obj.message = display.newText(obj.popupGroup,'ラベルを入力してください',0,0,'Noto-Light.otf',35)
		obj.message:setReferencePoint(display.CenterReferencePoint)
		obj.message:setFillColor(100)
		obj.message.x = obj.popupWindow.x 
		obj.message.y = obj.popupWindow.y - 200
		obj.textField = native.newTextField( 0,0, obj.popupWindow.width*0.8, 80 )
		obj.textField:setReferencePoint(display.CenterReferencePoint)
		obj.textField.x = obj.popupWindow.x 
		obj.textField.y = obj.popupWindow.y - 50
		obj.textField.isVisible = false
		obj.accept = display.newText(obj.popupGroup,'追加',0,0,'Noto-Medium.otf',35)
		obj.accept:setReferencePoint(display.CenterReferencePoint)
		obj.accept:setFillColor(unpack(themeColor))
		obj.accept.x = obj.popupWindow.x 
		obj.accept.y = obj.popupWindow.y + 200
		obj.accept.value = 'accept'
		obj.accept:addEventListener('tap',self.tap)
		obj.popupGroup:insert(obj.textField)
		obj.popupGroup.alpha = 0
--]]
		--obj.group:insert( obj.scrollView )
		obj.group:insert( obj.header )
		obj.group:insert( obj.title )
		obj.group:insert( obj.title2 )
		obj.group:insert( obj.title3 )
		obj.group:insert( obj.chari )
		--obj.group:insert( obj.menu )
		--obj.group:insert( obj.menuArea )
		obj.group:insert( obj.startButton )
		obj.group:insert( obj.ruleButton )
		--obj.group:insert( obj.menuBG )
		--obj.group:insert( obj.menuGroup )
		--obj.group:insert( obj.popupGroup )

		return obj.group
	end
end


function self.destroy()
	if obj.group then
		local function remove()
			display.remove( obj.group )
			obj.group = nil
		end
		remove()
		-- transition.to( obj.group, { time = 200, alpha = 0, onComplete = remove } )
	end
end

function self.touch( e )

	local event =
	{
		name   = 'home_view-touch',
		value  = e.target.value,
	}
	self:dispatchEvent( event )

	if e.target.value == 'bg' and e.target.value == 'popupWindow' then
		return false
    else
		return true
    end
end

function self.tap( e )

	if e.target.anim then
		transition.to(e.target,{
			time=100,
			xScale=0.8,
			yScale=0.8,
			transition=easing.continuousLoop
		})
	end

	local event =
	{
		name   = 'home_view-tap',
		value  = e.target.value,
	}
	if e.target.text then
		event['text'] = e.target.text
    end
	self:dispatchEvent( event )

	if e.target.value == 'bg' and e.target.value == 'popupWindow' then
		return false
    else
		return true
    end
end

return self
