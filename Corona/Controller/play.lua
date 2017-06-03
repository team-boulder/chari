local scene = storyboard.newScene()

--playkawa
-- require view
local play_view = require( ViewDir .. 'play_view' )
local home_view = require( ViewDir .. 'home_view' )
local play_model = require( ModelDir .. "play_model")

local tapcount = 0
local count = 0


local function modelHandler( event )
	print("get model event")
	if event.name == 'play_model-distance' then
		print(event)
		play_view.refresh( event.dist ) 
	end
end


local function viewHandler( event )
	if event.name == 'play_view-tap' then

		if event.value == 'bg' then
			play_view.jump()
        end

		if event.value == 'shop' then
			print('Hello')
			storyboard.gotoScene(ContDir..'result', {params = {score = play_model.dist or 0}})
		end
		if event.value == 'jumpjump' then
			count = count + 1
			if count == 1 then
			play_view.jump()
			end
			-- print(tapcount)
		end

	end
end

function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view
	play_model.distance()

	play_model:addEventListener( modelHandler )
	play_view:addEventListener( viewHandler )
	playerInfoData['age'] = playerInfoData['age'] - 0.2
	local view_obj = play_view.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	play_model.scoreSave()
	play_model.stopTimer()
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	play_view:removeEventListener( viewHandler )

	play_view.destroy()

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
