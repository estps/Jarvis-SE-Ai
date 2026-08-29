--[[
  Host.lua - Main Interface for Jarvis AI System
  ComputerCraft 1.21.1 NeoForge
  Cloudflare Tunnel Mode - No modems needed!
  Connects to Host.py via HTTP through Cloudflare tunnel
]]--

-- Configuration - Cloudflare Tunnel
local TUNNEL_URL = "https://immunology-retrieved-dow-sort.trycloudflare.com"
local OLAMA_MODEL = "phi3:mini"

-- State
local conversation = {}
local isRunning = true
local connected = false

-- UI Colors (ComputerCraft 16-color palette: 0-15)
local ccColors = {
    background = colors.black,
    primary = colors.lightBlue,
    secondary = colors.gray,
    text = colors.white,
    muted = colors.lightGray,
    accent = colors.yellow
}

-- Draw border function
local function drawBorder(height, title)
    local promptLine = height - 1
    term.setBackgroundColor(ccColors.background)
    term.clear()

    local status = "OFFLINE"
    local statusColor = colors.red
    if connected then
        status = "ONLINE"
        statusColor = colors.green
    end

    term.setTextColor(ccColors.primary)
    term.setCursorPos(1, 1)
    write("== " .. title .. " ==")

    term.setTextColor(statusColor)
    term.setCursorPos(1, 2)
    write("[" .. status .. "] HOST.PY")

    local y = 3
    local maxLines = promptLine - 1
    local start = math.max(1, #conversation - (maxLines - y))
    for i = start, #conversation do
        local line = conversation[i]
        if line then
            term.setCursorPos(2, y)
            local display = string.sub(line, 1, 37)
            write(display)
            y = y + 1
            if y > maxLines then break end
        end
    end

    term.setCursorPos(1, promptLine)
    term.setBackgroundColor(ccColors.secondary)
    term.clearLine()
    term.setTextColor(ccColors.text)
    write("> ")
end

-- Add message to conversation
local function addMessage(text, isUser)
    local prefix = isUser and "You" or "Jarvis"
    table.insert(conversation, "[" .. prefix .. "] " .. text)
    if #conversation > 50 then
        table.remove(conversation, 1)
    end
end

-- Test connection to Host.py through the tunnel
local function testConnection()
    local ok, err = pcall(function()
        local response = http.get(TUNNEL_URL .. "/status", nil, 10)
        if response then
            local body = response.readAll()
            response.close()
            local data = textutils.unserialiseJSON(body)
            connected = not not data
        else
            connected = false
        end
    end)
    if not ok then
        connected = false
    end
    return connected
end

-- Send question to Host.py via Cloudflare tunnel
local function sendToAI(question)
    addMessage(question, true)
    drawBorder(20, "Jarvis AI Interface")

    addMessage("Jarvis is thinking...", false)

    local success, err = pcall(function()
        local URL = TUNNEL_URL .. "/ask"
        local postData = textutils.serialiseJSON({question = question})
        local headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#postData)
        }

        local response = http.post(URL, postData, headers)
        if response then
            local body = response.readAll()
            response.close()
            local data = textutils.unserialiseJSON(body)

            if #conversation > 0 then
                conversation[#conversation] = nil
            end

            if data and data.response then
                addMessage(data.response, false)
                playJarvisTTS(data.response)
                notifyWorkers(data.response)
            else
                addMessage("Jarvis: Sorry, no response from AI.", false)
            end
        end
    end)

    if not success then
        addMessage("Jarvis: Connection error. Is Host.py running?", false)
        if #conversation > 0 and conversation[#conversation]:find("thinking") then
            conversation[#conversation] = nil
        end
    end

    drawBorder(20, "Jarvis AI Interface")
end

-- Play Jarvis TTS
local function playJarvisTTS(text)
    term.setTextColor(ccColors.accent)
    write("[" .. os.time() .. "] ")
    term.setTextColor(ccColors.text)
    write("Speaking: ")
    term.setTextColor(ccColors.accent)
    write(text:sub(1, 20))
    term.setTextColor(ccColors.text)
    write("...")

    local ok, err = pcall(function()
        local speaker = peripheral.find("speaker")
        if speaker and speaker.say then
            speaker.say(text)
        end
    end)

    if not ok then
        print("TTS: " .. text:sub(1, 30) .. (text:len() > 30 and "..." or ""))
    end

    local ok2, err2 = pcall(function()
        local URL = TUNNEL_URL .. "/tts"
        local postData = textutils.serialiseJSON({text = text})
        local headers = {["Content-Type"] = "application/json"}
        http.post(URL, postData, headers)
    end)
end

-- Notify all worker nodes via Cloudflare tunnel
local function notifyWorkers(message)
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/nodes"
        local postData = textutils.serialiseJSON({command = message, action = "notify"})
        local headers = {["Content-Type"] = "application/json"}
        http.post(URL, postData, headers)
    end)
end

-- Main UI loop
local function mainLoop()
    -- Test connection to Host.py on startup
    addMessage("Testing connection to Host.py...", false)
    local okConn = testConnection()
    if okConn then
        addMessage("Connected to Host.py via Cloudflare tunnel!", false)
    else
        addMessage("NOT connected to Host.py. Check tunnel URL / Host.py running.", false)
    end

    drawBorder(20, "Jarvis AI Interface")

    while isRunning do
        term.setCursorPos(1, 19)
        term.setBackgroundColor(ccColors.secondary)
        term.clearLine()
        term.setTextColor(ccColors.muted)
        write("> ")

        local input = read()

        if input and #input > 0 then
            local cmd = input:lower():gsub("^%s*(.-)%s*$", "%1")

            if cmd == "/clear" then
                conversation = {}
                drawBorder(20, "Jarvis AI Interface")
            elseif cmd == "/ping" then
                local okConn = testConnection()
                if okConn then
                    addMessage("PONG! Connected to Host.py.", false)
                else
                    addMessage("No response from Host.py. Is it running?", false)
                end
                drawBorder(20, "Jarvis AI Interface")
            elseif cmd == "/nodes" then
                local ok, err = pcall(function()
                    local URL = TUNNEL_URL .. "/nodes"
                    local response = http.get(URL)
                    if response then
                        local body = response.readAll()
                        response.close()
                        local data = textutils.unserialiseJSON(body)
                        if data and data.nodes then
                            local nodeInfo = ""
                            for _, nodeData in pairs(data.nodes) do
                                nodeInfo = nodeInfo .. "Node: " .. (nodeData.addr or "unknown") .. "\n"
                            end
                            if #nodeInfo > 0 then
                                addMessage("Connected nodes:\n" .. nodeInfo, false)
                            else
                                addMessage("No connected nodes found.", false)
                            end
                        end
                    end
                end)
                drawBorder(20, "Jarvis AI Interface")
            elseif cmd == "/help" then
                addMessage("Available commands:", false)
                addMessage("/clear - Clear conversation history", false)
                addMessage("/ping - Test connection to Host.py", false)
                addMessage("/nodes - Show connected worker nodes", false)
                addMessage("/help - Show this help", false)
                addMessage("Just type a question to ask Jarvis!", false)
                drawBorder(20, "Jarvis AI Interface")
            else
                sendToAI(input)
            end
        end
    end
end

-- Run main
mainLoop()
