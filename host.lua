--[[
  Host.lua - Main Interface for Jarvis AI System
  ComputerCraft 1.21.1 NeoForge
  Cloudflare Tunnel Mode - No modems needed!
  Connects to Host.py via HTTPS through Cloudflare tunnel
]]--

-- Configuration - Cloudflare Tunnel
local TUNNEL_URL = "http://127.0.0.1:5999"  -- Cloudflare tunnel local endpoint
local OLAMA_MODEL = "phi3:mini"

-- State
local conversation = {}
local isRunning = true

-- UI Colors
local colors = {
    background = 0x0d0d0d,
    primary = 0x00bfff,
    secondary = 0x303030,
    text = 0xffffff,
    muted = 0x888888,
    accent = 0xffd700
}

-- Draw border function
local function drawBorder(height, title)
    term.setBackgroundColor(colors.background)
    term.clear()
    
    -- Top border
    term.setCursorPos(1, 1)
    write("╔" .. string.rep("═", math.max(40, #title + 4)) .. "╗")
    
    -- Title
    term.setCursorPos(3, 1)
    write("║ " .. title .. string.rep(" ", math.max(0, 40 - #title)) .. " ║")
    
    -- Middle separator
    term.setCursorPos(1, 2)
    write("║" .. string.rep("═", 40) .. "║")
    
    -- Conversation area
    local y = 3
    for i = math.max(1, #conversation - 15), #conversation do
        local line = conversation[i]
        if line then
            term.setCursorPos(2, y)
            local display = string.sub(line, 1, 38)
            write("║ " .. display .. string.rep(" ", 40 - #display) .. " ║")
            y = y + 1
        end
    end
    
    -- Bottom border
    local bottomY = math.min(height - 1, y + 1)
    term.setCursorPos(1, bottomY)
    write("╚" .. string.rep("═", 40) .. "╝")
    
    -- Input line
    term.setCursorPos(1, bottomY + 1)
    term.setBackgroundColor(colors.secondary)
    term.clearLine()
    term.setTextColor(colors.text)
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

-- Send question to Host.py via Cloudflare tunnel
local function sendToAI(question)
    addMessage(question, true)
    drawBorder(20, "Jarvis AI Interface")
    
    -- Show thinking...
    addMessage("Jarvis is thinking...", false)
    
    -- Call Host.py via Cloudflare tunnel
    local success, err = pcall(function()
        local URL = TUNNEL_URL .. "/ask"
        local postData = json.encode({question = question})
        local headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#postData)
        }
        
        local response = http.post(URL, postData, headers)
        if response then
            local body = response.body
            local data = textutils.unserialize(body)
            
            -- Remove thinking message
            if #conversation > 0 then
                conversation[#conversation] = nil
            end
            
            if data and data.response then
                addMessage(data.response, false)
                
                -- Play TTS
                playJarvisTTS(data.response)
                
                -- Notify workers via tunnel
                notifyWorkers(data.response)
            else
                addMessage("Jarvis: Sorry, no response from AI.", false)
            end
        end
    end)
    
    if not success then
        addMessage("Jarvis: Connection error. Is Host.py running with Cloudflare tunnel?", false)
        -- Remove thinking message
        if #conversation > 0 and conversation[#conversation]:find("thinking") then
            conversation[#conversation] = nil
        end
    end
    
    drawBorder(20, "Jarvis AI Interface")
end

-- Play Jarvis TTS
local function playJarvisTTS(text)
    term.setTextColor(colors.accent)
    write("[" .. os.time() .. "] ")
    term.setTextColor(colors.text)
    write("Speaking: ")
    term.setTextColor(colors.accent)
    write(text:sub(1, 20))
    term.setTextColor(colors.text)
    write("...")
    
    -- Use speaker TTS if available
    local ok, err = pcall(function()
        local speaker = component.speaker
        if speaker and speaker.say then
            speaker.say(text)
        end
    end)
    
    if not ok then
        print("TTS: " .. text:sub(1, 30) .. (text:len() > 30 and "..." or ""))
    end
    
    -- Notify ALL worker computers via Cloudflare tunnel
    -- They will play the TTS audio locally
    local ok2, err2 = pcall(function()
        local URL = TUNNEL_URL .. "/tts"
        local postData = json.encode({text = text})
        local headers = {["Content-Type"] = "application/json"}
        http.post(URL, postData, headers)
    end)
end

-- Notify all worker nodes via Cloudflare tunnel
local function notifyWorkers(message)
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/nodes"
        local postData = json.encode({command = message, action = "notify"})
        local headers = {["Content-Type"] = "application/json"}
        http.post(URL, postData, headers)
    end)
    
    -- Don't wait for response - fire and forget
end

-- Handle incoming data from workers (optional polling)
local function checkForWorkerResponses()
    -- In tunnel mode, we can poll for worker status
    -- This is optional - workers could also send messages independently
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/status"
        local response = http.get(URL)
        if response then
            local body = response.body
            -- Could update node status display
        end
    end)
end

-- Main UI loop
local function mainLoop()
    -- Initial UI setup
    drawBorder(20, "Jarvis AI Interface (Cloudflare Tunnel)")
    
    while isRunning do
        -- Draw input prompt
        term.setCursorPos(1, 19)
        term.setBackgroundColor(colors.secondary)
        term.clearLine()
        term.setTextColor(colors.muted)
        write("> ")
        
        -- Get user input
        local input = read()
        
        if input and #input > 0 then
            -- Handle commands
            local cmd = input:lower():gsub("^%s*(.-)%s*$", "%1")
            
            if cmd == "/clear" then
                conversation = {}
                drawBorder(20, "Jarvis AI Interface")
            elseif cmd == "/nodes" then
                -- Query connected nodes
                local ok, err = pcall(function()
                    local URL = TUNNEL_URL .. "/nodes"
                    local response = http.get(URL)
                    if response then
                        local body = response.body
                        local data = textutils.unserialize(body)
                        if data and data.nodes then
                            local nodeInfo = ""
                            for nodeId, nodeData in pairs(data.nodes) do
                                nodeInfo = nodeInfo .. "Node " .. nodeId .. ": " .. (nodeData.status or "offline") .. "\n"
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
                addMessage("/nodes - Show connected worker nodes", false)
                addMessage("/help - Show this help", false)
                addMessage("Just type a question to ask Jarvis!", false)
                drawBorder(20, "Jarvis AI Interface")
            else
                -- Send to AI via Cloudflare tunnel
                sendToAI(input)
            end
        end
    end
end

-- Exit handler
local function onExit()
    isRunning = false
    term.setBackgroundColor(colors.background)
    term.clear()
    term.setTextColor(colors.text)
    write("Goodbye! Jarvis signing off.\n")
end

-- Run main
mainLoop()
