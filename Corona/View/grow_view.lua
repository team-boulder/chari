--[[
@
@ Project  :
@
@ Filename : start_view.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2015-10-10
@
@ Comment  : アプリ起動時に色々な情報を取ってきて起動の準備をするページ。
@            実態はスプラッシュ・ローディングが表示されているのみ
@
]]--

local self = object.new()
local pet = require( ContDir .. 'pet' )

local obj = {}

function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()

		obj.bg = display.newRect(0,0,_W,_H)
		obj.bg:setFillColor(0)
		obj.title = display.newText('育成',0,100,'8bit.ttf',50)
		obj.title:setReferencePoint(display.CenterReferencePoint)
		obj.title.x = _W/2

		obj.blockGroup = display.newGroup()
		obj.block = pet.genPet(obj.blockGroup,self.tap)

		obj.back = display.newText('戻る',_W-200,_H-200,'8bit.ttf',50)
		obj.back:setReferencePoint(display.CenterReferencePoint)
		obj.back.x = _W/2
		obj.back.value = 'back'
		obj.back:addEventListener('tap',self.tap)

		obj.group:insert( obj.bg )
		obj.group:insert( obj.title )
		obj.group:insert( obj.blockGroup )
		obj.group:insert( obj.back )

		return obj.group
	end
end

function self.paint(i,j,color)
	obj.block[i][j]:setFillColor(color)
	playerInfoData['petdata'][i][j] = 0
	playerInfo.save()
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
		name   = 'grow_view-tap',
		value  = e.target.value,
	}
	self:dispatchEvent( event )
	return true
end

return self
