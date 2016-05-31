#!/usr/bin/env tarantool
forex = require('forex')
log = require('log')

-- init tarantool db and grant
box.cfg{listen=3301}
box.schema.user.grant('guest', 'read,write,execute', 'universe')

-- create space and run
space = box.schema.create_space('fx')
space:create_index('primary', {type='tree', parts={1, 'str'}})
forex.worker:run('fx')

function qs_arg(request, field, default)
    if request.args[field] ~= nil then
        return request.args[field]
    end
    return default
end

function fx(request)
    local response = {'Bad request'}
    local ok, err = pcall(function()
        response = {
            fx_data = box.space.fx:select({}, {
                limit=tonumber(qs_arg(request, 'limit', 12*3)),
                offset=tonumber(qs_arg(request, 'offset', 0))
            }), legend=forex.schema
        }
    end)
    if not ok then
        log.error(err)
    end
    return response
end
