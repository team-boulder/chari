local self = object.new()
local anim = require("Plugin.anim.anim")
local physics = require("physics")
local widget = require( "widget" )

local obj = {}
function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()
	end


	local function networkListener( event )
		local data = json.decode(event.response)
		local scrollView = widget.newScrollView(
    		{
        	top = 0,
        	left = 10,
        	width = 600,
        	height = 400,
        	scrollWidth = 60,
        	scrollHeight = 80,
        	listener = scrollListener
    		}
		)
		for i , var in pairs(data) do
			local obj1 = display.newText(data[i].id, 0, i*100 , 100, 150)
			local obj2 = display.newText(data[i].name, 100, i*100 , 200, 150)
			local obj3 = display.newText(data[i].region, 300, i*100 , 200, 150)
			obj1:setFillColor(1,0,0)
			obj2:setFillColor(1,0,0)
			obj3:setFillColor(1,0,0)
			scrollView:insert(obj1)
			scrollView:insert(obj2)
			scrollView:insert(obj3)
		end
	end
	local params = {}
	fnetwork.request("http://api.football-api.com/2.0/competitions?Authorization=565ec012251f932ea4000001fa542ae9d994470e73fdb314a8a56d76", "GET", networkListener, params)
    obj.bg = display.newRect(0,0,_W,_H)
    obj.bg:setFillColor(0)

    obj.title = display.newText('ショップ',0, playerInfoData['hoge'],nil,40) 
    playerInfoData['hoge'] = playerInfoData['hoge'] + 10
    obj.title:setReferencePoint(display.CenterReferencePoint)
    obj.title.x = _W/2
    physics.start()
    physics.addBody(obj.title, { friction=1.0, bounce=1.0 })
    

    obj.back = display.newText('戻る',_W/2,_H-150,nil,50)
    obj.back:setReferencePoint(display.CenterReferencePoint)
    obj.back.x = _W/2
	obj.back.value = 'back'
	obj.back:addEventListener('tap',self.tap)
	
	obj.shiba = display.newText('芝', 0 ,_H-300,nil,50)
    obj.shiba:setReferencePoint(display.CenterReferencePoint)
    obj.shiba.x = _W/4
    obj.shiba.value = 'shiba'
	obj.shiba:addEventListener('tap',self.tap)
    anim.new(obj.shiba)
    obj.shiba:ika()

	obj.kuma = display.newText('熊',_W/2 - 100,_H-300,nil,50)
    obj.kuma:setReferencePoint(display.CenterReferencePoint)
    obj.kuma.x = _W/2
    obj.kuma.value = 'kuma'
	obj.kuma:addEventListener('tap',self.tap)
	anim.new(obj.kuma)
	obj.kuma:ika()

	obj.natsu = display.newText('夏',_W/2,_H-300,nil,50)
    obj.natsu:setReferencePoint(display.CenterReferencePoint)
    obj.natsu.x = _W*3/4
    obj.natsu.value = 'natsu'
	obj.natsu:addEventListener('tap',self.tap)
	anim.new(obj.natsu)
	obj.natsu:ika()

	obj.text = display.newText('前原だよ！！', 0, _H-500, nil, 100)
	obj.text:setReferencePoint(display.CenterReferencePoint)
	obj.text.value = 'maehara'
	obj.text:addEventListener('tap',self.tap)
	anim.new(obj.text)
	physics.addBody(obj.text, "static" ,{ friction=1.0, bounce=1.0 })

    obj.group:insert( obj.bg )
    obj.group:insert( obj.title )
    obj.group:insert( obj.back )
	obj.group:insert( obj.shiba )
	obj.group:insert( obj.kuma )
	obj.group:insert( obj.natsu )
	obj.group:insert( obj.text )

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
		name   = 'mae_view-tap',
		value  = e.target.value,
	}
	self:dispatchEvent( event )
	return true
end

function self.puni() 
	obj.text:stopAnim()
	obj.text:punipuni()
end 

return self
