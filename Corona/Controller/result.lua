local scene = storyboard.newScene()

--playkawa
-- require view
local result_view = require( ViewDir .. 'result_view' )



local function viewHandler( event )

end

function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view
	result_view:addEventListener( viewHandler )

	local result_obj = result_view.create()
	group:insert( result_obj )
end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view 
    result_view:removeEventListener( viewHandler )

	result_view.destroy()

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
