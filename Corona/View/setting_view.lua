local self = object.new()

-- local themeColor = {120,230,240}
local themeColor = playerInfoData['theme_color']
local headerSize = 100

local obj = {}

local function sliderListener( event )
	if event.target.name == 'red' then
		playerInfoData['theme_color'][1] = math.floor(event.value/100*255)
	elseif event.target.name == 'green' then
		playerInfoData['theme_color'][2] = math.floor(event.value/100*255)
	elseif event.target.name == 'blue' then
		playerInfoData['theme_color'][3] = math.floor(event.value/100*255)
	end
	obj.header:setFillColor(unpack(playerInfoData['theme_color']))
end
	
function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()

		obj.bg = display.newRect(0,0,_W,_H)
		obj.bg.value = 'bg'
		obj.bg:addEventListener('tap',self.tap)
		obj.header = display.newRect(0,0,_W,headerSize)
		obj.header:setFillColor(unpack(themeColor))
		obj.title = display.newText('   設定',0,0,'Noto-Light.otf',35)
		obj.title:setReferencePoint(display.CenterReferencePoint)
		obj.title.x = _W/2
		obj.title.y = obj.header.height/2
		obj.back = display.newImage( ImgDir .. 'setting/back.png',20,20)
		obj.backArea = display.newRect(0,0,150,100)
		obj.backArea.value = 'back'
		obj.backArea.isVisible = false
		obj.backArea.isHitTestable = true
		obj.backArea:addEventListener('tap',self.tap)

		obj.colorTitle = display.newText('テーマカラー',50,150,'Noto-Light.otf',30)
		obj.colorTitle:setFillColor(150)
		local sliderParams = {
			top = 250,
			left = 150,
			width = 400,
			value = 10,  -- Start slider at 10% (optional)
			listener = sliderListener
		}
		sliderParams.value = math.floor(playerInfoData['theme_color'][1]/255*100)
		print(sliderParams.value)
		obj.Rslider = widget.newSlider(sliderParams)
		obj.Rslider.name = 'red'
		obj.Rslider.y = 250
		sliderParams.value = math.floor(playerInfoData['theme_color'][2]/255*100)
		obj.Gslider = widget.newSlider(sliderParams)
		obj.Gslider.name = 'blue'
		obj.Gslider.y = 300
		sliderParams.value = math.floor(playerInfoData['theme_color'][3]/255*100)
		obj.Bslider = widget.newSlider(sliderParams)
		obj.Bslider.name = 'green'
		obj.Bslider.y = 350
		obj.rText = display.newText('R',75,0,'Noto-Light.otf',30)
		obj.rText:setReferencePoint(display.CenterReferencePoint)
		obj.rText.y = obj.Rslider.y
		obj.rText:setFillColor(150)
		obj.gText = display.newText('G',75,0,'Noto-Light.otf',30)
		obj.gText:setReferencePoint(display.CenterReferencePoint)
		obj.gText.y = obj.Gslider.y
		obj.gText:setFillColor(150)
		obj.bText = display.newText('B',75,0,'Noto-Light.otf',30)
		obj.bText:setReferencePoint(display.CenterReferencePoint)
		obj.bText.y = obj.Bslider.y
		obj.bText:setFillColor(150)

		obj.group:insert( obj.bg )
		obj.group:insert( obj.header )
		obj.group:insert( obj.title )
		obj.group:insert( obj.back )
		obj.group:insert( obj.backArea )
		obj.group:insert( obj.Rslider )
		obj.group:insert( obj.Gslider )
		obj.group:insert( obj.Bslider )
		obj.group:insert( obj.colorTitle )
		obj.group:insert( obj.rText )
		obj.group:insert( obj.gText )
		obj.group:insert( obj.bText )

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

function self.tap( e )

	local event =
	{
		name   = 'setting_view-tap',
		value  = e.target.value,
	}
	self:dispatchEvent( event )

	return true
end

return self
