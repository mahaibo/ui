
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    self:onstart()
end

function MainScene:onstart()
    local startBtn = self:getResourceNode():getChildByName("btn_start")
    local function startCallback(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:getApp():enterScene("AccelerometerScene")

        end
    end
    startBtn:addTouchEventListener(startCallback)
end

return MainScene
