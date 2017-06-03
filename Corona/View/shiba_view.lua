local self = object.new()
local physics = require("physics")
local widget = require( "widget" )

local obj = {}

-- ScrollView listener
local function scrollListener( event )
 
    local phase = event.phase
    if ( phase == "began" ) then print( "Scroll view was touched" )
    elseif ( phase == "moved" ) then print( "Scroll view was moved" )
    elseif ( phase == "ended" ) then print( "Scroll view was released" )
    end
 
   	 -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end
 
   	return true
end



local function listener(event)
	--print(event.response)
	data = json.decode(event.response)
	--print(data[1].id)
	for i = 1, 20 do
		print(data[i].id)
		local w_text = data[i].id
 		local background = display.newText(w_text,200,200 + 20 * i,nill,20)
		background:setFillColor(0,0,0)
		obj.scrollView:insert( background )
		local name_text = data[i].name
  	  	local background = display.newText(name_text,300,200 + 20 * i,nill,20)
		background:setFillColor(0,0,0)
		obj.scrollView:insert( background )
	end
	--w_text=data[1].id
	--obj.n_text = display.newText(w_text,0,100,nill,15)
	--obj.n_text.x = _W/4
end

function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()
	end

	local data
	local param = {}
 
	-- Create the widget
	obj.scrollView = widget.newScrollView(
    	{
        	top = 100,
        	left = 10,
        	width = 500,
        	height = 500,
        	scrollWidth = 600,
        	scrollHeight = 800,
        	listener = scrollListener
    	}
	)
 
	-- Create a image and insert it into the scroll view
	--local background = display.newImageRect( ImgDir..'shiba/thinthin.png', 768, 1024 )
	--scrollView:insert( background )
	fnetwork.request( 'http://api.football-api.com/2.0/competitions?Authorization=565ec012251f932ea4000001fa542ae9d994470e73fdb314a8a56d76', 'GET', listener, param )
	--for i = 1, 40 do
	--w_text = "thinthin"
    --local background = display.newText("thinthin",0,100,nill,20)
	--background:setFillColor(0,0,0)
	--scrollView:insert( background )
	--end
	

    obj.bg = display.newRect(0,0,_W,_H)
    obj.bg:setFillColor(0)
	--バナナくん
	obj.banana = display.newImage( ImgDir..'shiba/thinthin.png', _W/3, 400)
    obj.banana:scale(0.5,0.5)
    obj.banana.y = _H/4
	physics.start()
	physics.addBody(obj.banana,{ density=1.0, friction=1, bounce=1 })
	obj.body = display.newRect( _W/2, _H/2, 200, 1 )
	obj.body:setFillColor(0,0,0)
	physics.addBody(obj.body,"static")
	obj.b_text = display.newText('やあ！ThinThinだよ🍌',0,200,nil,35)
	obj.b_text.x = _W/4
	--あわびちゃん
	obj.awabi = display.newImage( ImgDir..'shiba/awabi.png', -_W/6, 400)
    obj.awabi:scale(0.5,0.5)
    obj.awabi.y = _H/2
	obj.a_text = display.newText('あら💕 食べちゃいたい',0,500,nil,35)
	obj.a_text.x = _W/1.6

	obj.b_text:setReferencePoint(display.CenterReferencePoint)
    obj.title = display.newText('おshibaのBanana',0,50,nil,40)
    obj.title:setReferencePoint(display.CenterReferencePoint)
    obj.title.x = _W/2
    obj.back = display.newText('戻る',_W/2,_H-150,nil,50)
    obj.back:setReferencePoint(display.CenterReferencePoint)
    obj.back.x = _W/2
    obj.back.value = 'back'
	obj.back:addEventListener('tap',self.tap)

	--次へ
	obj.next = display.newText('次へ',_W/2,_H-300,nil,50)
    obj.next:setReferencePoint(display.CenterReferencePoint)
    obj.next.x = _W/2
	obj.next.value = 'next'
	obj.next:addEventListener('tap',self.tap)
    
    obj.group:insert( obj.bg )
    obj.group:insert( obj.title )
    obj.group:insert( obj.back )
	obj.group:insert( obj.next )
	obj.group:insert( obj.banana)
	obj.group:insert( obj.b_text)
	obj.group:insert( obj.awabi)
	obj.group:insert( obj.a_text)

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
		name   = 'shiba_view-tap',
		value  = e.target.value,
	}
	
	self:dispatchEvent( event )
	return true
end

return self
