local self = object.new()

local on = 0
local time = 5000
local obj = {}
local play_model = require( ModelDir .. 'play_model' )
function self.create()
	-- if obj.group == nil then
		obj.group = display.newGroup()
	-- end

    obj.bg = display.newRect(0,0,_W,_H)
    obj.bg:setFillColor(255,255,255)
	obj.bg.value = 'bg'

    obj.title = display.newText('キョリ：',0,50,nil,40)
    obj.title:setFillColor(0)
    obj.title:setReferencePoint(display.CenterReferencePoint)
    obj.title.x = _W/2 + 150
    obj.title.value = 'shop'

	obj.dist = display.newText('',0,50,nil,40)
	obj.dist:setFillColor(0)
	obj.dist.x = _W/2 + 250
	
	obj.score = display.newText('Max Score：' .. playerInfoData['max_score'],0,50,nil,40)
		-- obj.scoreNum = playerInfoData['max_score']
    obj.score:setFillColor(0)
    obj.score.x = _W/2 - 150

	obj.ground = display.newRect(0,1000,_W,10)
	obj.ground:setFillColor(0)

	obj.player = display.newImage( 'Icon-60.png', 80, 910)
    obj.player:scale(2,2)
	obj.player.value = 'player'

    obj.title:addEventListener('tap',self.tap)
    obj.bg:addEventListener('tap',self.tap)
    obj.group:insert( obj.bg )
    obj.group:insert( obj.title )
    obj.group:insert( obj.ground )
    obj.group:insert( obj.player )
	obj.group:insert( obj.score )
	obj.group:insert( obj.dist )

    return obj.group
end

function self.refresh(dist)
	obj.dist.text = dist
end

local function jumpStart()
	obj.bg.value = '' 
end
	
local function jumpEnd()
	obj.bg.value = 'bg' 
end

function self.jump()
	transition.to( obj.player, { y = 500, transition = easing.continuousLoop, onStart = jumpStart, onComplete = jumpEnd, time = 200 } )
end


function self.destroy()
	if obj.group then
		local function remove()
			display.remove( obj.group )
			obj.group = nil
		end
		-- transition.to( obj.group, { time = 200, alpha = 0, onComplete = remove } )
	end
end

function self.tap( e )
	local event =
	{
		name   = 'play_view-tap',
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
