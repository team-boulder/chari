local self = object.new()
local physics = require('physics')

local on = 0
local time = 5000
local obj = {}
local play_model = require( ModelDir .. 'play_model' )
function self.create()
	physics.start()
	-- if obj.group == nil then
		obj.group = display.newGroup()
	-- end

	obj.Landscape = require( ViewDir .. 'background' )
	obj.landscape = obj.Landscape.create()
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
    obj.score:setFillColor(0)
    obj.score.x = _W/2 - 150

	obj.ground = display.newRect(0,1000,_W,10)
	obj.ground:setFillColor(0)
	physics.addBody(obj.ground,"static", {bounce = 0.0, friction = 1.0})

	obj.player = display.newImage( 'Icon-60.png', 80, 910)
    obj.player:scale(2,2)
	obj.player.value = 'player'
	physics.addBody(obj.player, {bounce = 0.0, friction = 1.0})

    obj.timer = timer.performWithDelay(100,self.checkPos, -1)

    obj.title:addEventListener('tap',self.tap)
    obj.bg:addEventListener('tap',self.tap)
    obj.group:insert( obj.bg )
    obj.group:insert( obj.landscape )
    obj.group:insert( obj.title )
    obj.group:insert( obj.ground )
    obj.group:insert( obj.player )
	obj.group:insert( obj.score )
	obj.group:insert( obj.dist )

    return obj.group
end

function self.createBlock()
	local block = display.newRect(_W,obj.ground.y - 105,100,100)
	obj.group:insert( block )
	physics.addBody(block, 'static', {bounce = 0.0, friction = 0.0})
	local function delBlock()
		block = nil
		display.remove(block)
	end
	transition.to(block,{ x = -100, time = 2000, transition = easing.linear, onComplete = delBlock})
end

function self.checkPos()
	if obj.player.x < -100 then
		local event = {
			name   = 'play_view-gameover',
		}
		self:dispatchEvent( event )
	end
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
	transition.to( obj.player, { y = 500, transition = easing.continuousLoop, onStart = jumpStart, onComplete = jumpEnd, time = 1000 } )
-- obj.player.y = 500
end


function self.destroy()
	transition.cancel()
    timer.cancel(obj.timer)
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
