--
-- @authors haibo
-- @email sean.ma@juhuiwan.cn
-- @date 2015-08-12 22:36:41
-- 

local PopuView = class("PopuView",function( ... )
	return ccui.Widget:create()
end)

function PopuView:ctor( params )
	self.layerbg_ = cc.LayerColor:create(cc.c4b(255, 255, 255, 184), 200, 200)
	self.layerbgWidth_ = self.layerbg_:getContentSize().width
	self.layerBgHeight_ = self.layerbg_:getContentSize().height
	self.layerbg_:setPosition(display.cx - self.layerbgWidth_/2.0
		, display.cy - self.layerBgHeight_ /2.0)

	self:addChild(self.layerbg_)

	self:createLabel(self.layerbgWidth_/2.0, self.layerBgHeight_/2.0)
	self:createTipsImg()

	self:showAnimation()

	self:registerTouchEvent()

end

function PopuView:showAnimation( ... )
	local actions = {}
	local scaleBigAction =  cc.ScaleTo:create(0.1, 1.1, 1.1)
	actions[#actions + 1] = scaleBigAction
	local scaleSmallAction = cc.ScaleTo:create(0.1, 0.9, 0.9)
	actions[#actions + 1] = scaleSmallAction
	local backAction = cc.ScaleTo:create(0.1, 1.0, 1.0)
	actions[#actions + 1] = backAction
	local sequence =  cc.Sequence:create(actions)
	-- run action
	self.layerbg_:runAction(sequence)

end

function PopuView:getBg( ... )
	return self.layerbg_
end

function PopuView:setSize(size)
	self.w_ = size.width
	self.h_ = size.height
end

function PopuView:getSize( ... )
	return self.w_, self.h_
end

function PopuView:createTipsImg()
	local tipsImg = cc.Sprite:create("exclamation-icon.png")
	tipsImg:setPosition(self.layerbgWidth_/2.0 - 100, self.layerBgHeight_/2.0)
	tipsImg:setScale(0.2)
	self.layerbg_:addChild(tipsImg)
end



function PopuView:createLabel( posX, posY )
	self.label_ = cc.Label:createWithSystemFont("00","Arial",28)
    -- self.label_:setString("Billboard2")
    self.label_:setPosition(posX, posY)
    self.label_:setString("是否确认退出")
    self.label_:setTextColor(cc.c3b(0, 0, 0))
    self.layerbg_:addChild(self.label_)
end

function PopuView:getLabel( ... )
	return self.label_
end

function PopuView:registerTouchEvent( ... )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
    	self:onTouchBegan(touch, event)
    		return true
    	end ,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event)
    	self:onTouchEnded(touch, event)
    end, cc.Handler.EVENT_TOUCH_ENDED)
    
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function PopuView:onTouchBegan(touch, event)
	-- body
end

function PopuView:onTouchEnded(touch, event)
	self:removeSelf()
end

return PopuView