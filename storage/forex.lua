local log = require('log')
local http = require('http.client')
local fiber = require('fiber')
local json = require('json')

local Schema = {
    "USD", "RUB", "AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK",
    "DKK", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY",
    "KRW", "MXN", "MYR", "NOK", "NZD", "PLN", "RON", "SEK", "SGD",
    "THB", "TRY", "ZAR"
}

local FXServer = {
    uri = 'http://api.fixer.io/',
    get = function(self, arg)
        if arg == nil then
            arg = 'latest'
        end
        local resp = http.get(self.uri .. arg)
        if resp.status ~= 200 then
            log.error("Exchange server is error")
        end
        return json.decode(resp.body)
    end,
    by_date = function(self, date)
        local data = self:get(date)
        local flatten = {data.date}
        for _, key in pairs(Schema) do
            table.insert(flatten, data.rates[key])
        end
        return flatten
    end
}

local Worker = {
    broker = FXServer,
    worker = function(self)
        fiber.name('Forex worker')
        self:warmup()
        while true do
            local tuple = self.broker:by_date()
            local data = self.space:get(tuple[1])
            if data == nil then
                self.space:replace(tuple)
                log.info('Exchange info updated')
            end
            fiber.sleep(1)
        end
    end,
    warmup = function(self)
        for i=1, 30 do
            local day = tostring(i)
            if #day == 1 then
                day = '0' .. day
            end
            local date = '2016-05-'..day
            local tuple = self.broker:by_date(date)
            tuple[1] = date
            self.space:replace(tuple)
        end
        log.info('Warmup complete')
    end,
    run = function(self, space)
        if box.space[space] == nil then
            log.errror('Space %s does not exist', space)
        end
        self.space = box.space[space]
        fiber.create(self.worker, self)
        log.info('Forex server is ready')
    end,
}

return {
    server = FXServer,
    worker = Worker,
    schema = Schema
}
