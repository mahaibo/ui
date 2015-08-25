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



    self:addBallAcceleroListener()
end

function AccelerometerScene:addBallAcceleroListener()
--    local accLayer = self:
    local layer = cc.Layer:create()
    layer:setAccelerometerEnabled(true)
    self:addChild(layer)



    local ball = self:getResourceNode():getChildByName("ball")
    ball:removeFromParentAndCleanup(true)
    layer:addChild(ball)

    local function accelerometerListener(event,x,y,z,timestamp)
        local target  = event:getCurrentTarget()
        local ballSize = target:getContentSize()
        local ptNowX,ptNowY    = target:getPosition()
        ptNowX = ptNowX + x * 9.81
        ptNowY = ptNowY + y * 9.81

        local minX  = math.floor(VisibleRect:left().x + ballSize.width / 2.0)
        local maxX  = math.floor(VisibleRect:right().x - ballSize.width / 2.0)
        if ptNowX <   minX then
            ptNowX = minX
        elseif ptNowX > maxX then
            ptNowX = maxX
        end

        local minY  = math.floor(VisibleRect:bottom().y + ballSize.height / 2.0)
        local maxY  = math.floor(VisibleRect:top().y   - ballSize.height / 2.0)
        if ptNowY <   minY then
            ptNowY = minY
        elseif ptNowY > maxY then
            ptNowY = maxY
        end

        target:setPosition(cc.p(ptNowX , ptNowY))
    end

    local listerner  = cc.EventListenerAcceleration:create(accelerometerListener)
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,ball)
end

function AccelerometerScene:onExit()
    printf("onExit")
end
return AccelerometerScene

