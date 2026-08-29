--[[
  Host.lua - Main Interface for Jarvis AI System
  ComputerCraft 1.21.1 NeoForge
  Controls AI interaction, TTS, and worker node coordination
]]--

-- Configuration
local MODEM_SIDE = "top"
local OLAMA_HOST = "http://localhost:11434"
local OLAMA_MODEL = "phi3:mini"
local TTS_VOICE = "Jarvis"

-- State
local conversation = {}
local isRunning = true
local connectedNodes = {}

-- Load APIs
os.loadAPI("speaker")
local component = require("component")
local modem = component.modem
if not modem then
    error("Modem component not found!")

rednet.open(MODEM_SIDE)
end

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
    -- Keep only last 50 messages
    if #conversation > 50 then
        table.remove(conversation, 1)
    end
end

-- Send question to Host.py
local function sendToAI(question)
    addMessage(question, true)
    drawBorder(20, "Jarvis AI Interface")
    
    -- Show thinking...
    addMessage("Jarvis is thinking...", false)
    
    -- Call Host.py
    local success, result = os.execute(string.format(
        'python Host.py "%s"', 
        question:gsub('"', '\\"')
    ))
    
    -- Read response from file
    local responseFile = "/tmp/jarvis_response.txt"
    local file = io.open(responseFile, "r")
    local aiResponse = ""
    if file then
        aiResponse = file:read("*a")
        file:close()
    end
    
    -- Clear thinking message and add real response
    -- Remove the "thinking..." message (last entry)
    if #conversation > 0 then
        conversation[#conversation] = nil
    end
    
    if aiResponse and #aiResponse > 0 then
        addMessage(aiResponse, false)
        
        -- Play TTS
        playJarvisTTS(aiResponse)
        
        -- Notify workers
        notifyWorkers(aiResponse)
    else
        addMessage("Jarvis: Sorry, I couldn't get a response from the AI.", false)
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
    
    -- Use speaker TTS
    if speaker and speaker.playTTS then
        speaker.playTTS(text, 1.0)
    end
    
    -- Broadcast to all worker nodes via rednet
    local msg = {
        type = "jarvis_speech",
        text = text,
        source = "host"
    }
    rednet.broadcast(msg, "jarvis_control")
end

-- Notify all worker nodes
local function notifyWorkers(message)
    local msg = {
        type = "command",
        command = message,
        source = "host"
    }
    rednet.broadcast(msg, "worker_commands")
    
    -- Update node list
    connectedNodes = {}
    local nodeCount = rednet.lookup("worker", "jarvis_control")
    if nodeCount then
        for i = 1, nodeCount do
            local id, _ = rednet.receive("worker_status", 0.1)
            if id then
                connectedNodes[#connectedNodes + 1] = id
            end
        end
    end
end

-- Handle incoming messages from workers
local function handleWorkerMessage(id, message)
    if message.type == "node_status" then
        connectedNodes[id] = {
            status = message.status,
            capabilities = message.capabilities or {}
        }
        addMessage("Node " .. id .. " connected: " .. (message.status or "unknown"), false)
    end
end

-- Setup modem event handler
local function setupModem()
    rednet.open(MODEM_SIDE)
    rednet.host("jarvis_control", "host_main")
    
    -- Set up event handler
    local eventHandler = function(event, ...)
        local type, message, distance = ...
        if type == "modem_message" then
            handleWorkerMessage(...)
        end
    end
    
    rednet.receive = function(...)
        -- Wrap the original receive
        return eventHandler(...)
    end
end

-- Main UI loop
local function mainLoop()
    -- Initial UI setup
    drawBorder(20, "Jarvis AI Interface")
    
    -- Setup modem
    setupModem()
    
    -- Set up event handling
    term.setBackgroundColor(colors.background)
    term.clear()
    term.setTextColor(colors.text)
    
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
                local nodeInfo = ""
                for nodeId, nodeData in pairs(connectedNodes) do
                    nodeInfo = nodeInfo .. "Node " .. nodeId .. ": " .. (nodeData.status or "offline") .. "\n"
                end
                if #nodeInfo > 0 then
                    addMessage("Connected nodes:\n" .. nodeInfo, false)
                else
                    addMessage("No connected nodes found.", false)
                end
                drawBorder(20, "Jarvis AI Interface")
            elseif cmd == "/help" then
                addMessage("Available commands:", false)
                addMessage("/clear - Clear conversation history", false)
                addMessage("/nodes - Show connected worker nodes", false)
                addMessage("/help - Show this help", false)
                addMessage("Just type a question to ask Jarvis!", false)
                drawBorder(20, "Jarvis AI Interface")
            else
                -- Send to AI
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
setupModem()
mainLoop()