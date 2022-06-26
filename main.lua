
-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "AHT10"
VERSION = "1.0.0"

-- sys库是标配
local sys = require "sys"

local addr = 0x38
--用的默认的i2c端口，可以用软端口
i2cid = 1

sys.taskInit(function()
    if i2c.setup(1, i2c.FAST, 0x38) == 1 then
        log.info("存在 i2c1")
    else
        i2c.close(1) -- 关掉
    end
    i2c.send(i2cid, addr, string.char(1))
    sys.wait(100)
    --local data = i2c.recv(i2cid, addr, 8)
    --log.info(data:toHex())

    while true do
        
        i2c.send(1, addr, string.char(0xAC))-- 发送0xac进行测量
        sys.wait(50)-- 至少等待20ms
        i2c.send(1, addr, string.char(0x71))-- 发送0x71回传数据
        local data = i2c.recv(i2cid, addr, 6)
        -- 收取6个字节的数据，前8位是状态码，中间20位是湿度，最后20位是温度
        local data_hex = data:toHex()
        --湿度转换
        local humi = tonumber(string.sub(data_hex,3,7),16)*100/1048576
        --温度转换
        local temp = tonumber(string.sub(data_hex,8,12),16)*200/1048576-50
        log.info('Temp: ',string.format("%.2f", temp),'RH: ',string.format("%.2f", humi))
        sys.wait(1000)
    end
end)
 
-- 用户代码已结束---------------------------------------------
-- 结尾总是这一句
sys.run()
-- sys.run()之后后面不要加任何语句!!!!!
