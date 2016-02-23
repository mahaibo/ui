------------------------------------------------------
-- 滑动控件
-- scrollView.lua
-- created by haibo 2015/07/02
-- sean.ma@juhuiwan.cn
-- Copyright (c) 2014-2015 TengChong Co.,Ltd.
------------------------------------------------------
local define=import(".define")

local UIScrollView = class("UIScrollView", function()
    return cc.ClippingNode:create()
end)
UIScrollView.__index = UIScrollView

UIScrollView.BG_ZORDER              = -100
UIScrollView.DIRECTION_BOTH         = 0
UIScrollView.DIRECTION_VERTICAL     = 1
UIScrollView.DIRECTION_HORIZONTAL   = 2
UIScrollView.REVERSE_SPEED_FACTOR   = 0.26
UIScrollView.REVERSE_ACCELERATED_SPEED   = 3.8

function UIScrollView:ctor(params)
    self.bBounce = true
    self.nShakeVal = 5
    self.direction = UIScrollView.DIRECTION_BOTH
    self.layoutPadding = {left = 0, right = 0, top = 0, bottom = 0}
    self.speed = {x = 0, y = 0}
    self.size = {}
    -- relative h
    self.relativeH = 0

    if not params then
        return
    end

    if params.viewRect then
        self:setViewRect(params.viewRect)
    end
    if params.direction then
        self:setDirection(params.direction)
    end

    self:onUpdate(handler(self,self.update_))
end

function UIScrollView:setRelativeH( rh )
    self.relativeH = rh
end

function UIScrollView:setViewRect(rect)
    local stencil = cc.DrawNode:create()
    local points = { cc.p(rect.x, rect.y), cc.p(rect.x, rect.y+rect.height), cc.p(rect.x+rect.width, rect.y+rect.height), 
        cc.p(rect.x+rect.width, rect.y) }
    stencil:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 4, cc.c4f(0,0,1,1))

    self:setStencil(stencil)
    self.viewRect_ = rect
    self.viewRectIsNodeSpace = false

    return self
end

function UIScrollView:getViewRect()
    return self.viewRect_
end

function UIScrollView:setLayoutPadding(top, right, bottom, left)
    if not self.layoutPadding then
        self.layoutPadding = {}
    end
    self.layoutPadding.top = top
    self.layoutPadding.right = right
    self.layoutPadding.bottom = bottom
    self.layoutPadding.left = left

    return self
end

function UIScrollView:setActualRect(rect)
    self.actualRect_ = rect
end

function UIScrollView:setDirection(dir)
    self.direction = dir

    return self
end

function UIScrollView:getDirection()
    return self.direction
end

function UIScrollView:setBounceable(bBounceable)
    self.bBounce = bBounceable

    return self
end

function UIScrollView:getCascadeBoundingBox(node)
    if node then
        local posX=node:getPositionX()
        local posY=node:getPositionY()
        local size=node:getContentSize()
        return cc.rect(posX,posY,size.width,size.height)
    end
end

-- 重置位置,主要用在纵向滚动时,
function UIScrollView:resetPosition()
    if UIScrollView.DIRECTION_VERTICAL ~= self.direction then
        return
    end

    local x, y = self.scrollNode:getPosition()
    local bound = self.scrollNode:getBoundingBox()
    local disY = self.viewRect_.y + self.viewRect_.height - bound.y - bound.size.height
    y = y + disY
    self.scrollNode:setPosition(cc.p(x, y))
end

function UIScrollView:rectIntersectsRect( rect1, rect2 )
    local intersect = not ( rect1.x > rect2.x + rect2.size.width or
                    rect1.x + rect1.width < rect2.x         or
                    rect1.y > rect2.y + rect2.size.height        or
                    rect1.y + rect1.height < rect2.y )

    return intersect
end

function UIScrollView:isItemInViewRect(item)
    if "userdata" ~= type(item) then
        item = nil
    end

    if not item then
        print("UIScrollView - isItemInViewRect item is not right")
        return
    end

    local bound = item:getBoundingBox()

    return self:rectIntersectsRect(self:getViewRectInWorldSpace(), bound)
end

function UIScrollView:addScrollNode(node)
    self:addChild(node)
    self.scrollNode = node

    if not self.viewRect_ then
        self.viewRect_ = self.scrollNode:getBoundingBox()
        self:setViewRect(self.viewRect_)
    end

    local event = {}
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        printInfo("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
        -- CCTOUCHBEGAN event must return true
        event.name="began"
        event.x=location.x
        event.y=location.y
        self:onTouch_(event)
        return true
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        printInfo("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
        event.name="moved"
        event.x=location.x
        event.y=location.y
        self:onTouch_(event)
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        printInfo("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
        event.name="ended"
        event.x=location.x
        event.y=location.y
        self:onTouch_(event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    return self
end

function UIScrollView:getScrollNode()
    return self.scrollNode
end

function UIScrollView:onScroll(listener)
    self.scrollListener_ = listener

    return self
end

function UIScrollView:update_(dt)
end

function UIScrollView:onTouchCapture_(event)
    if ("began" == event.name or "moved" == event.name or "ended" == event.name)
        and self:isTouchInViewRect(event) then
        return true
    else
        return false
    end
end

function UIScrollView:checkAtBorder()
    local py = self.scrollNode:getPositionY()
    py = py + self.relativeH

    local topBorder = self.viewRect_.y + self.viewRect_.height
    local bBorder = self.viewRect_.y
    -- 滚动到顶部
    if py + self.size.height < topBorder then
        return {topBorder - py - self.size.height,top=true}
    end

    if py + self.size.height > topBorder and self.size.height < self.viewRect_.height then
        return {topBorder - py - self.size.height}
    end

    -- 滚动到底部
    if py > bBorder and self.size.height >= self.viewRect_.height then
        return {bBorder - py,bottom=true}
    end
end

function UIScrollView:onTouch_(event)
    print("UIScrollView:onTouch_")

    if "began" == event.name and not self:isTouchInViewRect(event) then
        self.prevX_ = event.x
        self.prevY_ = event.y
        printInfo("UIScrollView - touch didn't in viewRect")
        self.position_ = {x = self.scrollNode:getPositionX(), 
            y=self.scrollNode:getPositionY()}
        self.prePosition_={x = self.scrollNode:getPositionX(), 
            y=self.scrollNode:getPositionY()}
        return false
    end

    if "began" == event.name then
        self.prevX_ = event.x
        self.prevY_ = event.y
        self.bDrag_ = false
        self.position_ = {x = self.scrollNode:getPositionX(), 
            y=self.scrollNode:getPositionY()}
        dump(self.position_)

        self.prePosition_={x = self.scrollNode:getPositionX(), 
            y=self.scrollNode:getPositionY()}

        transition.stopTarget(self.scrollNode)
        self:callListener_{name = "began", x = event.x, y = event.y}


        self.scaleToWorldSpace_ = self:scaleToParent_()

        return true
    elseif "moved" == event.name then
        if self:isShake(event) then
            return
        end

        self.bDrag_ = true
        -- 位移
        self.speed.x = event.x - self.prevX_
        self.speed.y = event.y - self.prevY_

        if self.direction == UIScrollView.DIRECTION_VERTICAL then
            self.speed.x = 0
        elseif self.direction == UIScrollView.DIRECTION_HORIZONTAL then
            self.speed.y = 0
        else
            -- do nothing
        end

        self:scrollBy(self.speed.x, self.speed.y)
        
        self:callListener_{name = "moved", x = event.x, y = event.y}
    elseif "ended" == event.name then
        if self.bDrag_ then
            self.bDrag_ = false

            self:scrollAuto()

            self:callListener_{name = "ended", x = event.x, y = event.y, disY = self.autoScrollY}

        else
            self:callListener_{name = "clicked", x = event.x, y = event.y}
        end
    end
end

function UIScrollView:rectContainsPoint( rect, point )
    local ret = false
    
    if (point.x >= rect.x) and (point.x <= rect.x + rect.width) and
       (point.y >= rect.y) and (point.y <= rect.y + rect.height) then
        ret = true
    end

    return ret
end

function UIScrollView:isTouchInViewRect(event)
    -- dump(self.viewRect_, "viewRect:")
    local viewRect = self:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
    viewRect.width = self.viewRect_.width
    viewRect.height = self.viewRect_.height
    -- dump(viewRect, "new viewRect:")-

    return self:rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function UIScrollView:isTouchInScrollNode(event)
    local cascadeBound = self:getScrollNodeRect()
    return self:rectContainsPoint(cascadeBound, cc.p(event.x, event.y))
end

function UIScrollView:scrollTo(p, y)
    local x_, y_
    if "table" == type(p) then
        x_ = p.x or 0
        y_ = p.y or 0
    else
        x_ = p
        y_ = y
    end

    self.position_ = cc.p(x_, y_)
    self.scrollNode:setPosition(self.position_)
end

-- 移动距离
function UIScrollView:moveXY(orgX, orgY, speedX, speedY)
    if self.bBounce then
        -- bounce enable
        return orgX + speedX, orgY + speedY
    end

    -- local cascadeBound = self:getScrollNodeRect()
    -- local viewRect = self:getViewRectInWorldSpace()
    -- local x, y = orgX, orgY
    -- local disX, disY

    -- if speedX > 0 then
    --     if cascadeBound.x < viewRect.x then
    --         disX = viewRect.x - cascadeBound.x
    --         disX = disX / self.scaleToWorldSpace_.x
    --         x = orgX + math.min(disX, speedX)
    --     end
    -- else
    --     if cascadeBound.x + cascadeBound.width > viewRect.x + viewRect.width then
    --         disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
    --         disX = disX / self.scaleToWorldSpace_.x
    --         x = orgX + math.max(disX, speedX)
    --     end
    -- end

    -- if speedY > 0 then
    --     if cascadeBound.y < viewRect.y then
    --         disY = viewRect.y - cascadeBound.y
    --         disY = disY / self.scaleToWorldSpace_.y
    --         y = orgY + math.min(disY, speedY)
    --     end
    -- else
    --     if cascadeBound.y + cascadeBound.height > viewRect.y + viewRect.height then
    --         disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
    --         disY = disY / self.scaleToWorldSpace_.y
    --         y = orgY + math.max(disY, speedY)
    --     end
    -- end

    -- return x, y
end

-- 根据位移值来滚动
function UIScrollView:scrollBy(speedX, speedY)
    self.position_.x, self.position_.y = self:moveXY(self.prePosition_.x, self.prePosition_.y, speedX, speedY)
    self.scrollNode:setPosition(cc.p(self.position_.x, self.position_.y))

    if self.actualRect_ then
        self.actualRect_.x = self.actualRect_.x + speedX
        self.actualRect_.y = self.actualRect_.y + speedY
    end
end

function UIScrollView:scrollAuto()
    if self:twiningScroll() then
        return
    end
    self:elasticScroll()
end

function UIScrollView:getscrollNodeBox(target) 
end

-- 边界回弹
function UIScrollView:elasticScroll()
    local data=self:checkAtBorder()
    if data==nil then return end 
    local disY = data[1]
    if not disY then
        return
    end

    if 0 == disY then
        return
    end

    transition.moveBy(self.scrollNode,
    {x = disX, y = disY, time = 0.3,
    easing = "backout",
    onComplete = function()
        self:callListener_{name = "scrollEnd", disX = disX, disY = disY, bottom=data.bottom}
    end})
end

-- fast drag
function UIScrollView:twiningScroll()

    if math.abs(self.speed.x) < 10 and math.abs(self.speed.y) < 10 then
        return false
    end

    local disX, disY
    if self:checkAtBorder() then
        disX, disY = self:moveXY(0, 0, self.speed.x * UIScrollView.REVERSE_SPEED_FACTOR, 
            self.speed.y * UIScrollView.REVERSE_SPEED_FACTOR)
    else
        disX, disY = self:moveXY(0, 0, self.speed.x * UIScrollView.REVERSE_ACCELERATED_SPEED, 
            self.speed.y * UIScrollView.REVERSE_ACCELERATED_SPEED)
    end
    
    transition.moveBy(self.scrollNode,
        {x = disX, y = disY, time = 0.3,
        easing = "sineOut",
        onComplete = function()
            self:elasticScroll()
        end})
    return true
end

function UIScrollView:getScrollNodeRect()
    local bound = self.scrollNode:getBoundingBox()

    local rect2t = function(_r)
        _r.x = _r.x
        _r.y = _r.y
        _r.width = _r.size.width
        _r.height = _r.size.height

        return _r
    end
    return rect2t(bound)
    -- return bound
end

function UIScrollView:getViewRectInWorldSpace()
    local rect = self:convertToWorldSpace(
        cc.p(self.viewRect_.x, self.viewRect_.y))
    rect.width = self.viewRect_.width
    rect.height = self.viewRect_.height

    return rect
end

function UIScrollView:callListener_(event)
    if not self.scrollListener_ then
        return
    end
    event.scrollView = self

    self.scrollListener_(event)
end

function UIScrollView:isShake(event)
    if math.abs(event.x - self.prevX_) < self.nShakeVal
        and math.abs(event.y - self.prevY_) < self.nShakeVal then
        return true
    end
end

function UIScrollView:scaleToParent_()
    -- local parent
    -- local node = self
    -- local scale = {x = 1, y = 1}

    -- while true do
    --     scale.x = scale.x * node:getScaleX()
    --     scale.y = scale.y * node:getScaleY()
    --     parent = node:getParent()
    --     if not parent then
    --         break
    --     end
    --     node = parent
    -- end

    -- return scale
end

return UIScrollView
