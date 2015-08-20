--
-- @authors haibo
-- @email sean.ma@juhuiwan.cn
-- @date 2015-08-13 21:58:44
--
local Layer3D = class("Layer3D",function( ... )
	return cc.Layer:create()
end)

function Layer3D:ctor( ... )
	self:init()
end

function Layer3D:onEnter( ... )
	self.layer3D_ = cc.Layer:create()
	self:addChild(self.layer3D_)
	local line = cc.DrawNode3D:create()
    --draw x
    for i = -20 ,20 do
        line:drawLine(cc.vec3(-100, 0, 5 * i), cc.vec3(100, 0, 5 * i), cc.c4f(1, 0, 0, 0))
    end

    --draw z
    for i = -20, 20 do
        line:drawLine(cc.vec3(5 * i, 0, -100), cc.vec3(5 * i, 0, 100), cc.c4f(0, 0, 1, 1))
    end

    --draw y
    line:drawLine(cc.vec3(0, -50, 0), cc.vec3(0,0,0), cc.c4f(0, 0.5, 0, 1))
    line:drawLine(cc.vec3(0, 0, 0), cc.vec3(0,50,0), cc.c4f(0, 1, 0, 1))
    self.layer3D_:addChild(line)
end

function Layer3D:onExit( ... )
	-- body
end

function Layer3D:init( ... )
	self:registerScriptHandler(function (event)
    if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    end
    end)
end

return Layer3D