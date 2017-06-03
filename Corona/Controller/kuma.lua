local scene = storyboard.newScene()

--Kumakawa
-- require view
local kuma_view = require( ViewDir .. 'kuma_view' )
local home_view = require( ViewDir .. 'home_view' )

local tapcount = 0
local function viewHandler( event )
	if event.name == 'kuma_view-tap' then

		if event.value == 'rect' then
			storyboard.gotoScene(ContDir..'home')
        end

		if event.value == 'shop' then
			print('Hello')
			storyboard.gotoScene(ContDir..'home')
		end
		if event.value == 'Noback' then
			kuma_view.puni()
			kuma_view.reflesh()
			-- print(tapcount)
		end

	end
end

function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view

	--user_model:addEventListener( modelHandler )
	kuma_view:addEventListener( viewHandler )
	playerInfoData['age'] = playerInfoData['age'] - 0.2
	local view_obj = kuma_view.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	kuma_view:removeEventListener( viewHandler )

	kuma_view.destroy()

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
