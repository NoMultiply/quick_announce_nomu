-- 此lua文件由冰冰羊参考其它模组的upvaluehelper代码制作，并进行了功能完善，如果你想使用我这个版本的upvaluehelper，建议去【冰冰羊的模组运行库】mod里获取最新版的
-- 创意工坊：https://steamcommunity.com/sharedfiles/filedetails/?id=3750536829
-- GitHub：https://github.com/BB-GOAT/bbgoat_utils/blob/master/bbgoat_utils/bbgoat_upvaluehelper.lua
-- 本文件更新时间：2026年6月24日

local visit = {} -- 保存已经访问的 防止有嵌套
local visitnum = 0
local function TryToClose(level, value, i, fn)
    if value ~= nil then
        visit = {}
        visitnum = 0
        return value, i, fn
    end
    if level == 1 then
        visit = {}
        visitnum = 0
    end
end

-- 遍历搜索上值
---@param fn function 被搜索的函数
---@param name string 要搜索的上值名
---@param fn_filter string|function|nil 限定搜索到的函数必须：来源于某个文件|符合过滤条件
---@param value_filter string|function|nil 限定找到的上值（如果是函数）必须：来源于某个文件|符合过滤条件
---@return any 找到的上值
---@return integer 上值在函数中的索引
---@return function 拥有该上值的函数
local function FindUpvalue(fn, name, fn_filter, value_filter)
    assert(type(fn_filter) == "nil" or type(fn_filter) == "string" or type(fn_filter) == "function", "Upvaluehelper.FindUpvalue 错误：传入的参数fn_filter不是string、function或nil")
    assert(type(value_filter) == "nil" or type(value_filter) == "string" or type(value_filter) == "function", "Upvaluehelper.FindUpvalue 错误：传入的参数value_filter不是string、function或nil")

    local level = visitnum + 1
    if type(fn) ~= "function" then TryToClose(level) return end
    if visit[fn] then TryToClose(level) return end -- 已访问过就返回
    visit[fn] = true
    visitnum = visitnum + 1

    local i = 1
    while true do
        local upname, upvalue = debug.getupvalue(fn, i)
        if not upname then break end -- 全找完了，跳出
        if upname and upname == name then
            if fn_filter then -- 限定条件 防止被别人提前hook导致取错
                local fninfo = debug.getinfo(fn)
                local valueinfo = type(upvalue) == "function" and debug.getinfo(upvalue)

                if ((type(fn_filter) == "string" and fninfo.source and fninfo.source:match(fn_filter)) or (type(fn_filter) == "function" and fn_filter(upvalue))) -- 检查是否符合过滤条件
                    and (not value_filter or (type(value_filter) == "string" and valueinfo and valueinfo.source:match(value_filter)) or (type(value_filter) == "function" and value_filter(upvalue)))
                then
                    return TryToClose(level, upvalue, i, fn)
                else -- 来源错误，递归查找
                    if type(upvalue) == "function" then
                        local upupvalue, upupi, upupfn = FindUpvalue(upvalue, name, fn_filter, value_filter)
                        if upupvalue ~= nil then
                            return TryToClose(level, upupvalue, upupi, upupfn)
                        end
                    end
                end
            elseif value_filter then -- 仅限定获取到的上值符合过滤条件
                if type(upvalue) == "function" then
                    local valueinfo = debug.getinfo(upvalue)

                    if (type(value_filter) == "string" and valueinfo and valueinfo.source:match(value_filter))
                        or (type(value_filter) == "function" and value_filter(upvalue))
                    then
                        return TryToClose(level, upvalue, i ,fn)
                    else -- 来源错误，递归查找
                        local upupvalue, upupi, upupfn = FindUpvalue(upvalue, name, fn_filter, value_filter)
                        if upupvalue ~= nil then
                            return TryToClose(level, upupvalue, upupi, upupfn)
                        end
                    end
                end
            else -- 未限定文件，直接返回
                return TryToClose(level, upvalue, i, fn)
            end
        end
        if upvalue and type(upvalue) == "function" and not visit[upvalue] then -- 没有访问过的
            local upupvalue, upupi, upupfn = FindUpvalue(upvalue, name, fn_filter, value_filter) -- 找不到就递归查找
            if upupvalue ~= nil then
                return TryToClose(level, upupvalue, upupi, upupfn)
            end
        end
        i = i + 1
    end
    TryToClose(level) -- 都没找到也要清除缓存
end

---@param fn function
---@param name string
---@return any
---@return integer
---@return function
local function GetUpvalueHelper(fn, name)
    local i = 1
    while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
        i = i + 1
    end
    local _, value = debug.getupvalue(fn, i)
    if value == nil then
        local found_value, found_i, found_fn = FindUpvalue(fn, name)
        if found_value ~= nil then
            return found_value, found_i, found_fn
        end
    end
    return value, i, fn
end

-- 搜索上值（找不到时自动遍历）
-- 基础debug教程：https://atjiu.github.io/dstmod-tutorial/#/debug
-- 调用示例
--[[
    local containers = require "containers"
    local params = Upvaluehelper.GetUpvalue(containers.widgetsetup, "params") -- 获取containers.widgetsetup的名为params的上值，必须在containers.widgetsetup，或者他调用的程序里使用到了params
    if params then
        params.cookpot.itemtestfn = function() ... end -- 因为返回值是表 可以直接操作 否则需要使用SetUpvalue
    end
]]
---@param fn function 被搜索的函数
---@param ... string 搜索路径
---@return any 找到的上值
---@return integer 上值在函数中的索引
---@return function 拥有该上值的函数
local function GetUpvalue(fn, ...)
    local prv, i, prv_var = nil, nil, "(起点)"
    for j,var in ipairs({...}) do
        assert(type(fn) == "function", "我们正在寻找 "..var..", 但在它之前的值 "
            ..prv_var.." 不是function (它是一个 "..type(fn)
            ..") 这是完整的链条: "..table.concat({"(起点)", ...}, "→"))
        prv_var = var
        fn, i, prv = GetUpvalueHelper(fn, var)
    end
    return fn, i, prv
end

-- 替换上值
-- 调用示例
--[[
    local containers = require "containers"
    local newtable = {}
    local params = Upvaluehelper.SetUpvalue(containers.widgetsetup, newtable, "params") -- 获取containers.widgetsetup的名为params的上值，然后替换为newtable
]]
---@param start_fn function 被搜索的函数
---@param new_fn any 新的上值
---@param ... string 搜索路径
local function SetUpvalue(start_fn, new_fn, ...)
    local _fn, _fn_i, scope_fn = GetUpvalue(start_fn, ...)
    debug.setupvalue(scope_fn, _fn_i, new_fn)
end

return {
    FindUpvalue = FindUpvalue,
    GetUpvalue = GetUpvalue,
    SetUpvalue = SetUpvalue,
}