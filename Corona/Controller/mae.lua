local scene = storyboard.newScene()

-- hogehogehoge

-- require view
local mae_view = require( ViewDir .. 'mae_view' )
local home_view = require( ViewDir .. 'home_view' )

local function viewHandler( event )
	if event.name == 'mae_view-tap' then

		if event.value == 'back' then
			storyboard.gotoScene(ContDir..'home')
		end

		if event.value == 'shiba' then
			storyboard.gotoScene(ContDir..'shiba')
		end
		
		if event.value == 'natsu' then
			storyboard.gotoScene(ContDir..'natsu')
		end

		if event.value == 'kuma' then
			storyboard.gotoScene(ContDir..'kuma')
		end

		if event.value == 'maehara' then
			mae_view.puni()
		end

	end
end

function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view

	--user_model:addEventListener( modelHandler )
	mae_view:addEventListener( viewHandler )

	local view_obj = mae_view.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	mae_view:removeEventListener( viewHandler )

	mae_view.destroy()

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
