--- overlay.lua
--
-- This Scene is used as an overlay for the menu.scene.lua Scene.
-- Its primary goal is to display your Facebook friends and offer
-- an option for you to challenge them at a game.
-- You will notice that a lot of user-dependant code is in 'enterScene',
-- and not in 'willEnterScene'.  This is because overlays are 'destroyed'
-- once they are hidden according to the storyboard API.
--
-- @author Paul Moore
--
-- Copyright (c) 2012 Strange Ideas Software
--
-- This file is part of Factor Friends.
--
-- Factor Friends is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- Factor Friends is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with Factor Friends.  If not, see <http://www.gnu.org/licenses/>.

local storyboard = require "storyboard"
local widget     = require "widget"
local net        = require "net"

local scene = storyboard.newScene()

local table

local btnSound

local function onRowEvent (event)
end

local function onRowRender (event)
	local friend = net.friends()[event.index]
	local profileImage
	local function showImage (imageEvent)
		profileImage = imageEvent.target
		-- Important.  If on an old iPhone, the user may scroll way faster
		-- than the table can keep up with.  We have to check to see if the
		-- row's view is still active (i.e. was not 'removed' when the user scrolled past it).
		-- If it has not yet been, we can place the image in its place, otherwise we have to trash it.
		if event.view.insert then
			event.view:insert(profileImage)
			profileImage.width  = 80
			profileImage.height = 80
			profileImage:setReferencePoint(display.CenterLeftReferencePoint)
			profileImage.x = 10 + display.contentBleedWidth
			profileImage.y = event.view.height / 2 - 5
		else
			profileImage:removeSelf()
		end
	end
	display.loadRemoteImage(
		"http://graph.facebook.com/".. friend.id .."/picture",
		"GET",
		showImage,
		"friend"..event.index..".png", 
		system.TemporaryDirectory
	)
	local nameLabel = display.newText(event.view, friend.name, 0, 0, "Bauhaus93", 34)
	while nameLabel.width > 330 do
		nameLabel.size = nameLabel.size - 1
	end
	nameLabel:setTextColor(0x3B, 0x4C, 0x4C)
	nameLabel:setReferencePoint(display.CenterLeftReferencePoint)
	nameLabel.x = 110 + display.contentBleedWidth
	nameLabel.y = event.view.height / 2
	local function onPlayBtnRelease ()
		local options = {
			effect = "slideLeft",
			time   = 500,
			params = event.index
		}
		storyboard.gotoScene("connect.scene", options)
		audio.play(btnSound)
	end
	local playBtn = widget.newButton({
		width     = 140,
		height    = 72,
		onRelease = onPlayBtnRelease,
		default   = "res/img/menu_btn_play_default.png",
		over      = "res/img/menu_btn_play_over.png"
	})
	event.view:insert(playBtn)
	playBtn:setReferencePoint(display.CenterRightReferencePoint)
	playBtn.x = display.contentBgWidth - display.contentBleedWidth - 10
	playBtn.y = event.view.height / 2
end

-- Called when the scene's view does not exist:
local function onCreateScene (event)
	btnSound = audio.loadSound("res/audio/play_btn.wav")
	
	table = widget.newTableView({
		width           = display.contentBgWidth,
		height          = display.contentHeight - 270,
		left            = -display.contentBleedWidth,
		top             = 270,
		bgColor         = {0x00, 0x00, 0x00, 0x00},
		renderThresh    = 0,
		maskFile        = "res/img/table_mask.png"
	})
	scene.view:insert(table)
	
	friends = event.params
	
	local rowColor1 = {0xF5, 0xFF, 0xEC, 0xC0}
	local rowColor2 = {0xE6, 0xFF, 0xD7, 0xC0}
	local lineColor = {0x7B, 0xC2, 0x2E}
	
	for i = 1, #net.friends() do
		local rcolor
		if i % 2 == 0 then
			rcolor = rowColor1
		else
			rcolor = rowColor2
		end
		
		table:insertRow({
			onEvent   = onRowEvent,
			onRender  = onRowRender,
			rowColor  = rcolor,
			lineColor = lineColor,
			height    = 110
		})
	end
end

-- Called BEFORE scene has moved onscreen:
local function onWillEnterScene (event)
end

-- Called immediately after scene has moved onscreen:
local function onEnterScene (event)
end

-- Called when scene is about to move offscreen:
local function onExitScene (event)
end

-- Called AFTER scene has finished moving offscreen:
local function onDidExitScene (event)
end
-- Called if/when overlay scene is displayed via storyboard.showOverlay()
local function onOverlayBegan (event)
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
local function onOverlayEnded (event)
end

-- Called prior to the removal of scene's "view" (display group)
local function onDestroyScene (event)
	table    = nil
	audio.dispose(btnSound)
	btnSound = nil
end

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener("createScene", onCreateScene)

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener("willEnterScene", onWillEnterScene)

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener("enterScene", onEnterScene)

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener("exitScene", onExitScene)

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener("didExitScene", onDidExitScene)

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener("overlayBegan", onOverlayBegan)
 
-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener("overlayEnded", onOverlayEnded)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener("destroyScene", onDestroyScene)

return scene
