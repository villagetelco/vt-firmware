#!/usr/bin/lua

--This is disabled because not all nodes have it at this point and it isn't being used.
--require "cmdline"
local dev = "wlan0"
local dev1 = "wlan0-1"
local settings_file = "/etc/onod/logger.conf"
local gen_log_file = "/www/log/%s_log.json"
local gen_log_tmp = "/www/log/%s_log.tmp"
local pid_file = "/var/run/dmtf_scan.pid"

local iw = require "iwinfo"
local t = assert(iw.type(dev1), "Not a wireless device")
--local getparam = cmdline.getparam

local max_pool_size = 408600
local pool_sizes = {}
local last_sizes = {}
local remaining_pool = max_pool_size

function init_pool(files)
	for p, x in pairs(files) do
		pool_sizes[x] = max_pool_size / (table.getn(files) * 2) -- Only use half of the pool
		last_sizes[x] = {}
		remaining_pool = remaining_pool - pool_sizes[x]
	end
end

function shuffle_space()
	for file, data in pairs(last_sizes) do
		local avg_total = 0
		for index, size in pairs(data) do
			avg_total = avg_total + size
		end
		avg_total = avg_total / table.getn(data)

		if avg_total < pool_sizes[file] and data[table.getn(data)] < pool_sizes[file] then
			local old_size = pool_sizes[file]
			local new_size = data[table.getn(data)]
			local diff = old_size - new_size
			remaining_pool = remaining_pool + diff
			pool_sizes[file] = pool_sizes[file] - diff
		end
	end
end

function update_last_size(file, new_size)
	table.insert(last_sizes[file], new_size)

	if table.getn(last_sizes[file]) > 3 then
		table.remove(last_sizes[file], 1)
	end
end

function pool_can_write(file, current, size)
	if (current + size) < pool_sizes[file] then
		update_last_size(file, (current + size))
		return 0
	end

	if remaining_pool < size then
		shuffle_space()
	end

	-- If the new line is bigger then the remaining pool 
	if size > remaining_pool then
		update_last_size(file, (current + size))
		return 2
	end

	-- Or the new file size isn't bigger then 70% of the pool and is not the only file in the pool
	if (current + size) > (max_pool_size / 10) * 7 and table.getn(pool_sizes) ~= 1 then
		remaining_pool = remaining_pool + pool_sizes[file]
		pool_sizes[file] = (max_pool_size / 10) * 7
		remaining_pool = remaining_pool - pool_sizes[file]
		return 2
	end

	-- Recalculate the pool
	remaining_pool = remaining_pool + pool_sizes[file]
	pool_sizes[file] = current + size
	remaining_pool = remaining_pool - pool_sizes[file]

	update_last_size(file, (current + size))
	return 0
end

function readBatOrginators() 
	local a = {
		originNodes = {}
	}, line, fd

	fd = io.popen("batctl o")
	if fd then
		fd:read("*l")
		fd:read("*l")
		repeat
			line = fd:read("*l")
			if line then
				local bssid, ls, quailty = line:match("^([a-f0-9:]+) +([%d%.]+)s +%((%d+)%)")
				if bssid and ls and quailty then
					a.originNodes[#a.originNodes+1] = {
						bssid:upper(),
						tonumber(ls),
						tonumber(quailty)
					} 
				end
			end
		until not line
		fd:close()
	end
	return a.originNodes
end


function getScanList(dev)
	local wScan
	wScan = iw[t].scanlist(dev)
	return wScan
end

function getAssocList(dev)
	local aList
	aList = iw[t].assoclist(dev1)
	return aList
end

function createLogItem(item_type)
	local item = nil
	-- Add new data types to this switch
	if item_type == "assoc" then
		item = {
			time = os.date(),
			aList = getAssocList(dev1)
		}
	elseif item_type == "scan" then
		item = {
			time = os.date(),
			wScan = getScanList(dev1)
		}
	elseif item_type == "batman" then
		item = {
			time = os.date(),
			originNodes = readBatOrginators(item)
		}
	end
	return item
end

function makeAssocEntry(item)
	local assocString = "{\"time\":\"" .. item.time .. "\",\"data\":{"

	for key, data in pairs(item.aList) do
		assocString = assocString .. string.format("\"%s\":{\"noise\":%d,\"signal\":%d},", key, data.noise, data.signal)
	end

	assocString = assocString:sub(0, assocString:len() - 1)

	assocString = assocString .. "}}"

	return assocString
end

function makeScanEntry(item)
	local scanString = "{\"time\":\"" .. item.time .. "\",\"wScan\":["

	for key, data in pairs(item.wScan) do
		scanString = scanString .. string.format("{\"signal\":%d,\"quality_max\":%d,\"ssid\":\"%s\",\"encryption\":\"%s\",\"channel\":%d,\"bssid\":\"%s\",\"mode\":\"%s\",\"quality\":%d},",
			data.signal, data.quality_max, data.ssid, data.encryption.description, data.channel, data.bssid, data.mode, data.quality)
	end

	scanString = scanString:sub(0, scanString:len() - 1)
	scanString = scanString .. "]}"

	return scanString
end

function makeBatmanEntry(item)
	local batString = "{\"time\":\"" .. item.time .. "\",\"originNodes\":["

	for key, data in pairs(item.originNodes) do
		batString = batString .. string.format("[%q,%.3f,%d],", data[1], data[2], data[3])
	end

	batString = batString:sub(0, batString:len() - 1)
	batString = batString .. "]}"

	return batString
end

function createLogEntry(item_type, item)
	local retString = ""
	-- Add new data types to this switch
	if item_type == "assoc" then
		retString = makeAssocEntry(item)
	elseif item_type == "scan" then
		retString = makeScanEntry(item)
	elseif item_type == "batman" then
		retString = makeBatmanEntry(item)
	end
	return retString
end

function runRoutine(seconds, run_time, max_lines, reset_file, types)
	if(run_time == 0) then run_time = 31557600; end -- almost 150 million years
	local resets = {}
	
	for p, x in pairs(types) do
		resets[x] = reset_file
	end

	local j = 0
	while j < run_time do
		for p, x in pairs(types) do
			local log_file = string.format(gen_log_file, x)
			local log_tmp = string.format(gen_log_tmp, x)
			
			local fi = io.open(log_file, "r")

			if fi == nil then --Create the file if it doesn't exist
				fi = io.open(log_file, "w")
				fi:close()
				fi = io.open(log_file, "r")
				resets[x] = 1
			end

			local line_count = 0
			local current_size = 0

			for i in io.lines(log_file) do --Read in the current file and get the line count
				line_count = line_count + 1
				current_size = current_size + i:len()
			end

			line_count = line_count - 2

			local item = createLogItem(x)
			local entry = createLogEntry(x, item)

			local lines_to_trim = pool_can_write(x, current_size, entry:len())
			if lines_to_trim > 0 then
				if line_count >= max_lines then
					line_count = line_count + lines_to_trim -- Trim off a line if the log is too big
				else
					line_count = max_lines + lines_to_trim
				end
			end

			local fo = assert(io.open(log_tmp, "w"), "Cannot open temporary file")

			local line_write = fi:read("*l")

			fo:write("{\"items\":[\n")

			if(resets[x] == 1) then --Reset file
				fo:write(entry .. "\n")
				resets[x] = 0
			else
				local i = 0

				while i < (line_count - max_lines + 1) do --Trim off excess lines
					line_write = fi:read("*l")
					i = i + 1
				end

				i = 1

				while i > 0 do --Write lines to file
					line_write = fi:read("*l")

					if line_write == nil then break end

					if(line_write:sub(line_write:len()) ~= ",") then --Last line
						line_write = line_write .. ","
						i = 0
					end

					fo:write(line_write .. "\n")
				end

				fo:write(entry .. "\n") --Add new entry
			end

			fo:write("]}")

			fo:close()
			fi:close()

			os.remove(log_file)
			os.rename(log_tmp, log_file)
		end
		os.execute(string.format("sleep %s", seconds))
		j = j + 1
	end
end

local seconds, run_time, max_lines, flag;

function get_parameters(params)
	local i = 1

	ret = {}

	while i <= #arg do
		for i, x in pairs(arg) do
			if arg[i] == x then
				i = i + 1
				ret[x] = arg[i]
			end
		end

		i = i + 1
	end

	return ret
end

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

function get_pid()
	local stat = io.open("/proc/self/stat")
	return stat:read("*number")
end

function does_pid_exist()
	if io.open(pid_file, "r") == nil then
		return false
	end
	return true
end

function stop_running()
	if not does_pid_exist() then
		return false
	end

	local cur_pid_file = io.open(pid_file, "r")
	local cur_pid = cur_pid_file:read("*number")
	cur_pid_file:close()

	os.remove(pid_file)
	os.execute(string.format("kill %d", cur_pid))
	return true
end

function make_pid()
	if does_pid_exist() then
		return false
	end

	local cur_pid_file = io.open(pid_file, "w")
	cur_pid_file:write(string.format("%d", get_pid()))
	cur_pid_file:close()

	return true
end

print(get_pid())

print(#arg)

if arg[1] == "start" then
	if not make_pid() then
		print("Daemon is probably already running. Try using restart instead.\n")
		os.exit(1)
	end
elseif arg[1] == "restart" then
	stop_running()
	if not make_pid() then
		print("Something went horribly wrong when creating the PID file!\n")
		os.exit()
	end
elseif arg[1] == "stop" then
	if not stop_running() then
		print("Daemon doesn't seem to be running at the moment.\n")
		os.exit(1)
	end
	os.exit(0)
else
	print("Please call using start, stop or restart.\n")
	os.exit(1)
end

function init_logger()
	for l in io.lines(settings_file) do
		local tmp = l:match("option location '(.*)'")

		if tmp ~= nil then
			log_file = tmp .. "%s_log.json"
			log_tmp = tmp .. "%s_log.tmp"
		end

		tmp = l:match("option file_size (%d*)")

		if tmp ~= nil then
			max_pool_size = tonumber(tmp)
		end
	end
end

arguments = {
	"-l", --Length of log
	"-r", --Run time/loops
	"-s", --Sleep time
	"-R", --Restart
	"-t"  --Types
}

paras = get_parameters(arguments)

print(paras["-l"])
print(paras["-r"])
print(paras["-s"])
print(paras["-R"])
print(paras["-t"])

-- The ghetto is strong in this one...
seconds = tonumber(paras["-s"])
run_time = tonumber(paras["-r"])
max_lines = tonumber(paras["-l"])
flag = tonumber(paras["-R"])

item_types = split(paras["-t"], ",") --{"assoc", "scan", "batman"}

init_logger()

print(log_file)
print(max_pool_size)

init_pool(item_types)

runRoutine(seconds, run_time, max_lines, flag, item_types)
stop_running()