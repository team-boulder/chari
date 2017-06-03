local self = object.new()

local on = 0
local time = 5000
local obj = {}
function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()
	end

    obj.bg = display.newRect(0,0,_W,_H)
    obj.bg:setFillColor(0)
    obj.title = display.newText('ショップ',0,50,nil,40)
    obj.title:setReferencePoint(display.CenterReferencePoint)
    obj.title.x = _W/2
    obj.title.value = 'shop'

    obj.back = display.newText('戻る',_W/2,_H-200,nil,50)
    obj.back:setReferencePoint(display.CenterReferencePoint)
    obj.back.x = _W/2
    obj.back.value = 'Noback'
	anim.new(obj.back)
    -- obj.back.value = 'back'
	obj.rect = display.newRect(_W-200,_H-200,200,100)
    obj.rect:setReferencePoint(display.CenterReferencePoint)
	obj.rect:setFillColor( math.random(0,255), math.random(0,255), math.random(0,255))
    obj.rect.value = 'rect'

    obj.ifback = display.newText('押しても戻りません',_W/2,_H-125,nil,50)
    obj.ifback:setReferencePoint(display.CenterReferencePoint)
	obj.ifback:setFillColor( 255, 0, 0)
    obj.ifback.x = _W/2
    obj.ifback.value = 'ifback'
	obj.ifback.isVisible = false
	anim.new(obj.ifback)
	obj.ifback:punipuni()
	print(playerInfoData['age'])
	print(time - playerInfoData['age'] * 2000) 
	transition.to( obj.rect, { time = time - playerInfoData['age'] * 2000, transition=easing.continuousLoop,x=(0), y=(0), iterations=-1, xScale=0.3, yScale=0.3} )
    -- obj.back:addEventListener('tap',self.tap)
    obj.rect:addEventListener('tap',self.tap)
    obj.title:addEventListener('tap',self.tap)
    obj.back:addEventListener('tap',self.tap)
    obj.group:insert( obj.bg )
    obj.group:insert( obj.title )
    obj.group:insert( obj.back )
	obj.group:insert( obj.rect )
	obj.group:insert( obj.ifback )

    return obj.group
end

function self.destroy()
	if obj.group then
		local function remove()
			display.remove( obj.group )
			obj.group = nil
		end
		transition.to( obj.group, { time = 200, alpha = 0, onComplete = remove } )
	end
end

function self.tap( e )
	local event =
	{
		name   = 'kuma_view-tap',
		value  = e.target.value,
	}
	self:dispatchEvent( event )
	return true
end

function self.puni()
	obj.back:punipuni()
end

function self.reflesh()
	obj.ifback.isVisible = true
end 

local function puni()
end

return self
