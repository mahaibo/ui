------------------------------------------------------
-- listView扩展
-- listViewEx.lua
-- created by haibo 2015/07/02
-- sean.ma@juhuiwan.cn
-- Copyright (c) 2014-2015 TengChong Co.,Ltd.
------------------------------------------------------

local UIScrollView = import(".ScrollView")
local UIListViewEx = class("UIListViewEx", UIScrollView)

local UIListViewItem = import(".ListViewItem")


UIListViewEx.DELEGATE					= "ListView_delegate"
UIListViewEx.TOUCH_DELEGATE			= "ListView_Touch_delegate"

UIListViewEx.CELL_TAG					= "Cell"
UIListViewEx.CELL_SIZE_TAG			= "CellSize"
UIListViewEx.COUNT_TAG				= "Count"
UIListViewEx.CLICKED_TAG				= "Clicked"

UIListViewEx.BG_ZORDER 				= -1
UIListViewEx.CONTENT_ZORDER			= 10

UIListViewEx.ALIGNMENT_LEFT			= 0
UIListViewEx.ALIGNMENT_RIGHT			= 1
UIListViewEx.ALIGNMENT_VCENTER		= 2
UIListViewEx.ALIGNMENT_TOP			= 3
UIListViewEx.ALIGNMENT_BOTTOM			= 4
UIListViewEx.ALIGNMENT_HCENTER		= 5


function UIListViewEx:ctor(params)
	params=params or {}
	UIListViewEx.super.ctor(self, params)

	self.items_ = {}
	self.direction = params.direction or UIScrollView.DIRECTION_VERTICAL
	printInfo("UIListViewEx direction:%s",tostring(self.direction))
	self.alignment = params.alignment or UIListViewEx.ALIGNMENT_VCENTER
	self.container=cc.Node:create()
	self:setViewRect(params.viewRect)
	self:addScrollNode(self.container)

	self:onScroll(handler(self, self.scrollListener))

end

function UIListViewEx:onTouch(listener)
	self.touchListener_ = listener

	return self
end

function UIListViewEx:setAlignment(align)
	self.alignment = align
end

function UIListViewEx:itemSizeChangeListener(listItem, newSize, oldSize)
	local pos = self:getItemPos(listItem)
	if not pos then
		return
	end

	local itemW, itemH = newSize.width - oldSize.width, newSize.height - oldSize.height
	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		itemW = 0
	else
		itemH = 0
	end

	local content = listItem:getContent()
	transition.moveBy(content,
				{x = itemW/2, y = itemH/2, time = 0.2})

	self.size.width = self.size.width + itemW
	self.size.height = self.size.height + itemH
	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		transition.moveBy(self.container,
			{x = -itemW, y = -itemH, time = 0.2})
		self:moveItems(1, pos - 1, itemW, itemH, true)
	else
		self:moveItems(pos + 1, table.nums(self.items_), itemW, itemH, true)
	end
end

function UIListViewEx:getscrollNodeBox( target )
	UIListViewEx.super.getscrollNodeBox(self, target)

	local x, y = target:getPosition()
    return {
        x=x,
        y=y,
        width=self.size.width,
        height=self.size.height
    }
end

function UIListViewEx:scrollListener(event)
	if "clicked" == event.name then
		local nodePoint = self.container:convertToNodeSpace(cc.p(event.x, event.y))
		nodePoint.x = nodePoint.x - self.viewRect_.x
		nodePoint.y = nodePoint.y - self.viewRect_.y

		local width, height = 0, self.size.height
		local itemW, itemH = 0, 0
		local pos
		if UIScrollView.DIRECTION_VERTICAL == self.direction then
			for i,v in ipairs(self.items_) do
				itemW, itemH = v:getItemSize()

				if nodePoint.y < height and nodePoint.y > height - itemH then
					pos = i
					nodePoint.y = nodePoint.y - (height - itemH)
					break
				end
				height = height - itemH
			end
		else
			for i,v in ipairs(self.items_) do
				itemW, itemH = v:getItemSize()

				if nodePoint.x > width and nodePoint.x < width + itemW then
					pos = i
					break
				end
				width = width + itemW
			end
		end

		self:notifyListener_{name = "clicked",
			listView = self, itemPos = pos, item = self.items_[pos],
			point = nodePoint}
	else
		event.scrollView = nil
		event.listView = self
		self:notifyListener_(event)
	end

end

function UIListViewEx:newItem(item)
	item = UIListViewItem.new(item)
	item:setDirction(self.direction)
	item:onSizeChange(handler(self, self.itemSizeChangeListener))

	return item
end

function UIListViewEx:addItem(item, index)
	-- 先不重用
	local listItem=self:newItem(item)
	self:modifyItemSizeIf_(listItem)

	if index then
		table.insert(self.items_, index, listItem)
	else
		table.insert(self.items_, listItem)
	end
	self.container:addChild(listItem)

	return self
end

function UIListViewEx:getCount()
	return table.getn(self.items_)
end

-- @param listItem
-- @param pos 
function UIListViewEx:addItemAtPos( listItem, pos )
	self:modifyItemSizeIf_(listItem)

	if pos then
		table.insert(self.items_, pos, listItem)
	else
		table.insert(self.items_, listItem)
	end
	self.container:addChild(listItem)

	-- calcu item at pos

	return self
end

function UIListViewEx:removeItem(listItem, bAni)
	local itemW, itemH = listItem:getItemSize()
	self.container:removeChild(listItem)

	local pos = self:getItemPos(listItem)
	if pos then
		table.remove(self.items_, pos)
	end

	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		itemW = 0
	else
		itemH = 0
	end

	self.size.width = self.size.width - itemW
	self.size.height = self.size.height - itemH
	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		self:moveItems(1, pos - 1, -itemW, -itemH, bAni)
	else
		self:moveItems(pos, table.nums(self.items_), -itemW, -itemH, bAni)
	end

	return self
end

function UIListViewEx:removeAllItems(bAni)
	local itemsNum_ = table.nums(self.items_)

    if itemsNum_ > 0 then
    	self:removeItem(self.items_[1], bAni)
    	self:removeAllItems(bAni)
    	return
    end

    return self
end
	
function UIListViewEx:getItemPos(listItem)
	for i,v in ipairs(self.items_) do
		if v == listItem then
			return i
		end
	end
end

function UIListViewEx:getItemByPos( pos )
	return self.items_[pos]
end

function UIListViewEx:getItems()
	return self.items_
end

function UIListViewEx:isItemExist( pos )
	if self.items_[pos] then
		return true
	end
end

function UIListViewEx:isItemInViewRect(pos)
	local item
	if "number" == type(pos) then
		item = self.items_[pos]
	elseif "userdata" == type(pos) then
		item = pos
	end

	if not item then
		return
	end
	
	local bound = item:getBoundingBox()
	local nodePoint = self.container:convertToWorldSpace(
		cc.p(bound.x, bound.y))
	bound.x = nodePoint.x
	bound.y = nodePoint.y

	return self:rectIntersectsRect(self.viewRect_, bound)
end

function UIListViewEx:layout_()
	local width, height = 0, 0
	local itemW, itemH = 0, 0
	local margin

	-- calcate whole width height
	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		width = self.viewRect_.width

		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			height = height + itemH
			printInfo("itemH:%s", tostring(itemH))
		end
	else
		height = self.viewRect_.height

		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			width = width + itemW
		end
	end

	printInfo("height:%s", tostring(height))

	self:setActualRect({x = self.viewRect_.x,
		y = self.viewRect_.y,
		width = width,
		height = height})
	self.size.width = width
	self.size.height = height

	local setPositionByAlignment = function(content, w, h, margin)
		local size = content:getContentSize()
		if 0 == margin.left and 0 == margin.right and 0 == margin.top and 0 == margin.bottom then
			if UIScrollView.DIRECTION_VERTICAL == self.direction then
				if UIListViewEx.ALIGNMENT_LEFT == self.alignment then
					content:setPosition(cc.p(size.width/2, h/2))
				elseif UIListViewEx.ALIGNMENT_RIGHT == self.alignment then
					content:setPosition(cc.p(w - size.width/2, h/2))
				else
					content:setPosition(cc.p(w/2, h/2))
				end
			else
				if UIListViewEx.ALIGNMENT_TOP == self.alignment then
					content:setPosition(cc.p(w/2, h - size.height/2))
				elseif UIListViewEx.ALIGNMENT_RIGHT == self.alignment then
					content:setPosition(cc.p(w/2, size.height/2))
				else
					content:setPosition(cc.p(w/2, h/2))
				end
			end
		else
			local posX, posY
			if 0 ~= margin.right then
				posX = w - margin.right - size.width/2
			else
				posX = size.width/2 + margin.left
			end
			if 0 ~= margin.top then
				posY = h - margin.top - size.height/2
			else
				posY = size.height/2 + margin.bottom
			end
			content:setPosition(cc.p(posX, posY))
		end
	end

	local tempWidth, tempHeight = width, height
	printInfo("UIListViewEx:layout_ direction:%s",tostring(self.direction))
	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		itemW, itemH = 0, 0

		local content
		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			tempHeight = tempHeight - itemH
			printInfo("tempHeight:%s", tostring(tempHeight))
			content = v:getContent()
			content:setAnchorPoint(cc.p(0.5, 0.5))
			-- content:setPosition(itemW/2, itemH/2)
			setPositionByAlignment(content, itemW, itemH, v:getMargin())
			v:setPosition(cc.p(self.viewRect_.x,
				self.viewRect_.y + tempHeight))
		end
	else
		itemW, itemH = 0, 0
		tempWidth = 0

		for i,v in ipairs(self.items_) do
			itemW, itemH = v:getItemSize()
			itemW = itemW or 0
			itemH = itemH or 0

			content = v:getContent()
			content:setAnchorPoint(cc.p(0.5, 0.5))
			-- content:setPosition(itemW/2, itemH/2)
			setPositionByAlignment(content, itemW, itemH, v:getMargin())
			v:setPosition(cc.p(self.viewRect_.x + tempWidth, self.viewRect_.y))
			tempWidth = tempWidth + itemW
		end
	end

end

function UIListViewEx:reload()
	self:layout_()
	self.size.oldWidth = self.size.width
	self.size.oldHeight = self.size.height
	local deltaY=self.viewRect_.height - self.size.height
	self.container:setPosition(cc.p(0, deltaY))

	return self
end

function UIListViewEx:getContainer()
	return self.container
end

-- @param pos 
-- @param prevX
-- @param prevY
function UIListViewEx:loadmore()
	self:layout_()

	local oldX, oldY = self.container:getPosition()
	local deltaY=math.abs(self.size.height-self.size.oldHeight)
	self.container:setPosition(cc.p(0, oldY-deltaY))
end

function UIListViewEx:notifyItem(point)
	local count = self.listener[UIListViewEx.DELEGATE](self, UIListViewEx.COUNT_TAG)
	local temp = (self.direction == UIListViewEx.DIRECTION_VERTICAL and self.container:getContentSize().height) or 0
	local w,h = 0, 0
	local tag = 0

	for i = 1, count do
		w,h = self.listener[UIListViewEx.DELEGATE](self, UIListViewEx.CELL_SIZE_TAG, i)
		if self.direction == UIListViewEx.DIRECTION_VERTICAL then
			temp = temp - h
			if point.y > temp then
				point.y = point.y - temp
				tag = i
				break
			end
		else
			temp = temp + w
			if point.x < temp then
				point.x = point.x + w - temp
				tag = i
				break
			end
		end
	end

	if 0 == tag then
		printInfo("UIListView - didn't found item")
		return
	end

	local item = self.container:getChildByTag(tag)
	self.listener[UIListViewEx.DELEGATE](self, UIListViewEx.CLICKED_TAG, tag, point)
end

function UIListViewEx:moveItems(beginIdx, endIdx, x, y, bAni)
	if 0 == endIdx then
		self:elasticScroll()
	end

	local posX, posY = 0, 0

	local moveByParams = {x = x, y = y, time = 0.2}
	for i=beginIdx, endIdx do
		if bAni then
			if i == beginIdx then
				moveByParams.onComplete = function()
					self:elasticScroll()
				end
			else
				moveByParams.onComplete = nil
			end
			transition.moveBy(self.items_[i], moveByParams)
		else
			posX, posY = self.items_[i]:getPosition()
			self.items_[i]:setPosition(cc.p(posX + x, posY + y))
			if i == beginIdx then
				self:elasticScroll()
			end
		end
	end
end

function UIListViewEx:notifyListener_(event)
	if not self.touchListener_ then
		return
	end

	self.touchListener_(event)
end

function UIListViewEx:modifyItemSizeIf_(item)
	local w, h = item:getItemSize()
	printInfo("UIListViewEx:modifyItemSizeIf_,w:%s,h:%s",
		tostring(w), tostring(h))

	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		if w ~= self.viewRect_.width then
			item:setItemSize(self.viewRect_.width, h, true)
		end
	else
		if h ~= self.viewRect_.height then
			item:setItemSize(w, self.viewRect_.height, true)
		end
	end
end

function UIListViewEx:update_(dt)
	UIListViewEx.super.update_(self, dt)

	self:checkItemsInStatus_()
end

function UIListViewEx:getAutoScrollY( ... )
	if self:twiningScroll() then
		return self.twingScrollDisY
	end
end

function UIListViewEx:checkItemsInStatus_()
	if not self.itemInStatus_ then
		self.itemInStatus_ = {}
	end

	local rectIntersectsRect = function(rectParent, rect)
		-- dump(rectParent, "parent:")
		-- dump(rect, "rect:")

		local nIntersects -- 0:no intersects,1:have intersects,2,have intersects and include totally

		local bIn = rectParent.x <= rect.x and
				rectParent.x + rectParent.width >= rect.x + rect.width and
				rectParent.y <= rect.y and
				rectParent.y + rectParent.height >= rect.y + rect.height
		if bIn then
			nIntersects = 2
		else
			local bNotIn = rectParent.x > rect.x + rect.width or
				rectParent.x + rectParent.width < rect.x or
				rectParent.y > rect.y + rect.height or
				rectParent.y + rectParent.height < rect.y
			if bNotIn then
				nIntersects = 0
			else
				nIntersects = 1
			end
		end

		return nIntersects
	end

	local newStatus = {}
	local bound
	local nodePoint
	for i,v in ipairs(self.items_) do
		bound = v:getBoundingBox()
		nodePoint = self.container:convertToWorldSpace(cc.p(bound.x, bound.y))
		bound.x = nodePoint.x
		bound.y = nodePoint.y
		newStatus[i] =
			rectIntersectsRect(self.viewRect_, bound)
	end

	for i,v in ipairs(newStatus) do
		if self.itemInStatus_[i] and self.itemInStatus_[i] ~= v then
			local params = {listView = self,
							itemPos = i,
							item = self.items_[i]}
			if 0 == v then
				params.name = "itemDisappear"
			elseif 1 == v then
				params.name = "itemAppearChange"
			elseif 2 == v then
				params.name = "itemAppear"
			end
			self:notifyListener_(params)
		else
		end
	end
	self.itemInStatus_ = newStatus
end

return UIListViewEx
