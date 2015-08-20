--
-- Created by IntelliJ IDEA.
-- User: haibo
-- Date: 15/8/20
-- Time: 下午10:27
-- To change this template use File | Settings | File Templates.
--

local AccelerometerScene = class("AccelerometerScene", cc.load("mvc").ViewBase)

AccelerometerScene.RESOURCE_FILENAME = "AccelerometerScene.csb"

function AccelerometerScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
end

function AccelerometerScene:onEnter()
    printf("onEnter")
    local back = self:getResourceNode():getChildByName("back")

    local function menuCloseCallback( sender,eventType)
        if eventType == ccui.TouchEventType.ended then
--            self:unscheduleUpdate()
--            local scene = CocoStudioTestMain()
            self:getApp():enterScene("MainScene")

        end
    end
    back:addTouchEventListener(menuCloseCallback)
end

function AccelerometerScene:onExit()
    printf("onExit")
end
return AccelerometerScene

