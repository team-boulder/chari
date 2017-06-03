local self = object.new()

local obj = {}

function self.create( params )
	-- if obj.group == nil then
	obj.group = display.newGroup()
    local score = params.score or 0

    obj.bg = display.newRect(0,0,_W,_H)
    obj.bg:setFillColor(0)

    obj.gameover = display.newText("GAME OVER",0,_H/2,nil,80)
    obj.gameover:setFillColor(255,0,0)
    obj.gameover:setReferencePoint(display.CenterReferencePoint)
    obj.gameover.x = _W/2
    obj.gameover.value = "game"

    obj.score = display.newText("score: "..score, 0,_H/2 + 100,nil,60)
    obj.score:setFillColor(255,0,0)
    obj.score:setReferencePoint(display.CenterReferencePoint)
    obj.score.x = _W/2
    obj.score.value = "score"
    
    obj.group:addEventListener('tap',self.tap)
    obj.group:insert(obj.bg)
    obj.group:insert(obj.score)
    obj.group:insert(obj.gameover)
	-- end
    return obj.group
end

function self.tap( e )
    local event = 
    {
        name  = "result_view-tap",
        value = e.target.value,
    }
    self:dispatchEvent( event )
    return true
end 


function self.destroy()
	if obj.group then
		local function remove()
			display.remove( obj.group )
			obj.group = nil
		end
	end
end

return self
