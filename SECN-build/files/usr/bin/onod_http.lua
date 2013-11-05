local script_location = "/usr/bin/onod_logger.lua"

function split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function get_vars(str)
    local retTable = {}
    for i, x in pairs(split(str, "&")) do
        key_val = split(x, "=", 2)
        retTable[key_val[1]] = key_val[2]
    end
    return retTable
end

function handle_request(env)
    uhttpd.send(env.QUERY_STRING)
    uhttpd.send("\n\n")

    vars = get_vars(env.QUERY_STRING)
    local command = ""

    if vars["action"] == "start" then
        command = string.format("lua %s start -s %d -r %d -l %d -R %d -t /\w+/g", script_location, vars["sleep_time"], vars["run_time"], vars["max_lines"], vars["reset_file"], vars["types"])
    elseif vars["action"] == "restart" then
        command = string.format("lua %s restart -s %d -r %d -l %d -R %d -t /\w+/g", script_location, vars["sleep_time"], vars["run_time"], vars["max_lines"], vars["reset_file"], vars["types"])
    elseif vars["action"] == "stop" then
        command = string.format("lua %s stop", script_location)
    end

    uhttpd.send(command)

    if command ~= "" then
        fd = io.popen(command, "r")
        --uhttpd.send(fd:read("*line"))
    end
end
