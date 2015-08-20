
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local PopuView = import("..ui.PopuView")
local Layer3D = import("..ui.Layer3D")

function MainScene:onCreate()
    -- add background image
    display.newSprite("MainSceneBg.jpg")
        :move(display.center)
        :addTo(self)

    -- add play button
    local playButton = cc.MenuItemImage:create("PlayButton.png", "PlayButton.png")
        :onClicked(function()
            -- self:getApp():enterScene("PlayScene")
            print("PopuView:create")
            PopuView:create()
            
            -- local layer3D = Layer3D:create()
            -- self:addChild(layer3D)
        end)
    cc.Menu:create(playButton)
        :move(display.cx, display.cy - 200)
        :addTo(self)
end

return MainScene
