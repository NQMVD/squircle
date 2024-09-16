local statistical = {}

local unpack = unpack or table.unpack

local function sort(t)
    table.sort(t)
    return t
end

function statistical.min(t)
    assert(#t > 0, "Table is empty")
    return math.min(unpack(t))
end

function statistical.max(t)
    assert(#t > 0, "Table is empty")
    return math.max(unpack(t))
end

function statistical.median(t)
    assert(#t > 0, "Table is empty")
    local sorted = sort({unpack(t)})
    local len = #sorted
    if len % 2 == 0 then
        return (sorted[len/2] + sorted[(len/2)+1]) / 2
    else
        return sorted[math.ceil(len/2)]
    end
end

function statistical.average(t)
    assert(#t > 0, "Table is empty")
    local sum = 0
    for _, v in ipairs(t) do
        sum = sum + v
    end
    return sum / #t
end

function statistical.dist(t)
    assert(#t > 0, "Table is empty")
    local min, max = statistical.min(t), statistical.max(t)
    return max - min
end

return statistical
