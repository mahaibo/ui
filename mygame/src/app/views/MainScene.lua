
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local PopuView = import("..ui.PopuView")

function MainScene:onCreate()
    -- add background image
    display.newSprite("MainSceneBg.jpg")
        :move(display.center)
        :addTo(self)

    -- add play button
    local playButton = cc.MenuItemImage:create("PlayButton.png", "PlayButton.png")
        :onClicked(function()
            -- self:getApp():enterScene("PlayScene")
            local popuView = PopuView:create()
            self:addChild(popuView)
        end)
    cc.Menu:create(playButton)
        :move(display.cx, display.cy - 200)
        :addTo(self)
end

return MainScene
