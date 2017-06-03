local anim = require("Plugin.anim.anim")
local self = object.new()

local obj = {}
local tableData = {
	{ label = '夏山', value = 'natsu' },
	{ label = '芝',   value = 'shiba' },
	{ label = '熊川', value = 'play' },
	{ label = '前原', value = 'mae' },
}
local TextColor = {0,0,0}

local themeColor = {255,255,255}
--playerInfoData['theme_color']
local headerSize = 200
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
		obj.BG = require( ViewDir .. 'background' )
		obj.bg = obj.BG.create()
		obj.cloud = display.newEmitter( emitter.params[3] )
		obj.cloud.x = _W*1.5
		obj.cloud.y = 100
		obj.header = display.newRect(0,_H/5,_W,headerSize)
		obj.header:setFillColor(unpack(themeColor))
		obj.header.isVisible = false
		obj.title = display.newImage(ImgDir..'home/title.png')
		obj.title:setReferencePoint(display.CenterReferencePoint)
		obj.title.x = _W/2
		obj.title.y = 350
		anim.new(obj.title)
		obj.title:punipuni()

		-- local sheetOptions = {
		-- 	width = 512,
		-- 	height = 256,
		-- 	numFrames = 8
		-- }
		-- obj.cat = graphics.newImageSheet( ImgDir.."home/cat.png", sheetOptions )
		-- obj.title = display.newText('Season of チャリ走',0,0,'Noto-Midium.otf',60)
		-- obj.title:setReferencePoint(display.CenterReferencePoint)
		-- obj.title.x = _W/2
		-- obj.title.y = _H/5 + headerSize/3
		-- obj.title:setFillColor(unpack(TextColor))
		-- obj.title2 = display.newText('~Presented team Boulder~',0,0,'Noto-Midium.otf',40)
		-- obj.title2:setReferencePoint(display.CenterReferencePoint)
		-- obj.title2.x = _W/2
		-- obj.title2.y = _H/5 + headerSize*2/3
		-- obj.title2:setFillColor(unpack(TextColor))

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

		obj.group:insert( obj.bg )
		obj.group:insert( obj.cloud )
		obj.group:insert( obj.header )
		obj.group:insert( obj.title )
		-- obj.group:insert( obj.title2 )
		-- obj.group:insert( obj.title3 )
		obj.group:insert( obj.chari )
		obj.group:insert( obj.startButton )
		obj.group:insert( obj.ruleButton )

		return obj.group
	end
end


function self.destroy()
	obj.BG.destroy()
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
