--[[
@
@ Project  :
@
@ Filename : start.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2015-10-10
@
@ Comment  : アプリ起動時に色々な情報を取ってきて起動の準備をするページ。
@            実態はスプラッシュが表示されているのみ
@
]]--

local scene = storyboard.newScene()

-- require view
local start_view = require( ViewDir .. 'start_view' )

local function viewHandler( event )
	if event.name == 'start_view-tap' then
		storyboard.gotoScene( ContDir .. 'home')
	end
end


function scene:createScene( event )
	local group = self.view

end

function scene:willEnterScene( event )
	local group = self.view

	--user_model:addEventListener( modelHandler )
	start_view:addEventListener( viewHandler )

	local view_obj = start_view.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	start_view:removeEventListener( viewHandler )

	start_view.destroy()

end

function scene:didExitScene( event )
    local group = self.view

end

function scene:destroyScene( event )
	local group = self.view
end


-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

scene:addEventListener( "didExitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeAll() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
