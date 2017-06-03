local self = object.new()

local obj = {}
function self.create(params)
	if obj.group == nil then
		obj.group = display.newGroup()

		obj.bg = display.newImage( ImgDir .. 'tmp/chart.png')
		obj.bg:setReferencePoint(display.CenterReferencePoint)
		obj.bg.x = _W/2
		obj.bg.y = _H/2
		obj.bg:scale(2.4,2.7)
		obj.bg.value = 'bg'
		obj.bg:addEventListener('tap',self.tap)
		obj.title = display.newText(params.title,100,18,'Noto-Medium.otf',35)
		obj.title:setFillColor(120,230,240)
		obj.group:insert( obj.bg )
		obj.group:insert( obj.title )

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
		name   = 'temp_view-tap',
		value  = e.target.value,
	}
	self:dispatchEvent( event )

	return true
end

return self
