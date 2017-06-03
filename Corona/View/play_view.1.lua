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
		-- obj.scoreNum = playerInfoData['max_score']
    obj.score:setFillColor(0)
    obj.score.x = _W/2 - 150

	obj.ground = display.newRect(0,1000,_W,10)
	obj.ground:setFillColor(0)
	physics.addBody(obj.ground,"static", {bounce = 0.0, friction = 0.0})

	obj.player = display.newImage( 'Icon-60.png', 80, 910)
    obj.player:scale(2,2)
	obj.player.value = 'player'
	physics.addBody(obj.player, {bounce = 0.0, friction = 0.0})

	obj.block ={}
	obj.block[1] = display.newRect(_W,obj.ground.y - 105,100,100)
	obj.block[2] = display.newRect(_W,obj.ground.y - 105,100,100)
	obj.block[3] = display.newRect(_W,obj.ground.y - 105,100,100)
	obj.block[4] = display.newRect(_W,obj.ground.y - 105,100,100)
	physics.addBody(obj.block[1], "static", {bounce = 0.0, friction = 0.0})
	physics.addBody(obj.block[2], "static", {bounce = 0.0, friction = 0.0})
	physics.addBody(obj.block[3], "static", {bounce = 0.0, friction = 0.0})
	physics.addBody(obj.block[4], "static", {bounce = 0.0, friction = 0.0})
	obj.blockStatus ={false,false,false,false}

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
	print("create block")
	local function delBlock(num)
		obj.block[num].x = _W
		obj.blockStatus[num] = false
	end
	for i,v in ipairs(obj.blockStatus) do
		if v == false then
			transition.to(obj.block[i],{ x = -100, time = 2000, transition = easing.linear, onComplete = delBlock(i)})
			obj.blockStatus[i] = true
		end
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
	transition.to( obj.player, { y = 500, transition = easing.continuousLoop, onStart = jumpStart, onComplete = jumpEnd, time = 200 } )
-- obj.player.y = 500
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
