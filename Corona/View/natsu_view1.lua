local self = object.new()
local physics = require('physics')



local obj = {}

local function googleListener(event)
	--print(event.response)
	local data = json.decode(event.response)
	local textX = 0
	for k, v in pairs(data) do
		--print("ID:" .. v.id)
		--print("Name:".. v.name)
		local text = display.newText("ID:" ..v.id.. ",Name:"..v.name..",Region:"..v.region,0,0)
		text.y = 40 * k
		text:setFillColor(0,0,0)
		obj.scrollView:insert(text)
	end
end
local params = {}


function self.create()
	physics.start()
	if obj.group == nil then
		obj.group = display.newGroup()
	end

    obj.bg = display.newRect(0,0,_W,_H)
    obj.bg:setFillColor(0)

	obj.back = display.newText('戻る',_W/2,_H-150,nil,50)
    obj.back:setReferencePoint(display.CenterReferencePoint)
    obj.back.x = _W/2
    obj.back.value = 'back'
	obj.back:addEventListener('tap',self.tap)

	obj.under = display.newRect(0,0, _W, 1)
	obj.under.x = 0
	obj.under.y = _H
	physics.addBody(obj.under, "static")

	obj.top = display.newRect(0,0, _W, 1)
	obj.top.x = 0
	obj.top.y = 0
	physics.addBody(obj.top, "static")

	obj.left = display.newRect(0,0, 1, _H)
	obj.left.x = 0
	obj.left.y = 0
	physics.addBody(obj.left, "static")

	obj.right = display.newRect(0,0, 1, _H)
	obj.right.x = _W
	obj.right.y = 0
	physics.addBody(obj.right, "static")

	obj.image = display.newImageRect("Images/satoshi/tintin.png",300,400)
	obj.image:setReferencePoint(display.CenterReferencePoint)
	obj.image.x = _W/2
	obj.image.y = _H/2
	obj.image.value = 'image'
	obj.image:addEventListener('tap',self.tap)
	physics.addBody(obj.image, {bounce = 1.0 })




	obj.whiteimage = display.newImageRect("Images/satoshi/white.png",200,200)
	obj.whiteimage:setReferencePoint(display.CenterReferencePoint)
	obj.whiteimage.x = _W/2
	obj.whiteimage.y = 200
	obj.whiteimage.value = 'whiteimage'
	obj.whiteimage.alpha = 0.1 * playerInfoData['test']
	obj.whiteimage:addEventListener('tap',self.tap)
	

	obj.text = display.newText("↑画像タップしてね",0,0,nil,40)
	obj.text.x = _W/2
	obj.text.y = _H/2 + 300
	obj.text.value = 'text'

	obj.scrollView = widget.newScrollView(
    {
        top = 0,
        left = 0,
        width = _W,
        height = 100,
        scrollWidth = _W,
        scrollHeight = 800,
        listener = scrollListener
    }
	)
    
    obj.group:insert( obj.bg )
	obj.group:insert( obj.back)
	obj.group:insert( obj.image )
	obj.group:insert( obj.whiteimage )
	obj.group:insert( obj.text )
	obj.group:insert( obj.under )
	obj.group:insert( obj.top )
	obj.group:insert( obj.left )
	obj.group:insert( obj.right )
	obj.group:insert( obj.scrollView )
	fnetwork.request("http://api.football-api.com/2.0/competitions?Authorization=565ec012251f932ea4000001fa542ae9d994470e73fdb314a8a56d76", "GET", googleListener, params)
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
		name   = 'natsu_view-tap1',
		value  = e.target.value,
	}
	self:dispatchEvent( event )
	return true
end

function self.refresh(tapCount)
	obj.whiteimage.alpha = obj.whiteimage.alpha + 0.1
	print(tapCount)
	if tapCount == 10 then
		obj.whiteimage.alpha = 0
		--timer.performWithDelay(100, listener )
	end
end

--Timer処理がうまく動きません。
local function listener(event)
	print("timer")
	obj.whiteimage.alpha = 0
end


return self
