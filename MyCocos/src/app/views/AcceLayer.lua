--
-- Created by IntelliJ IDEA.
-- User: haibo
-- Date: 15/8/20
-- Time: 下午11:27
-- To change this template use File | Settings | File Templates.
--

local AcceLayer = class("AcceLayer", cc.load("mvc").ViewBase)

AcceLayer.RESOURCE_FILENAME = "AcceLayer.csb"


function AcceLayer:onCreate()
    printf("AcceLayer onCreate")
    self:setAccelerometerEnabled(true)
end

return AcceLayer

