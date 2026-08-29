--[[
  Worker.lua - Node Controller for Jarvis AI System
  ComputerCraft 1.21.1 NeoForge
  Cloudflare Tunnel Mode - NO MODEMS NEEDED!
  Connects to Host.py via HTTP through Cloudflare tunnel
]]--

-- Configuration - Cloudflare Tunnel
local TUNNEL_URL = "https://immunology-retrieved-dow-sort.trycloudflare.com"  -- Cloudflare tunnel local endpoint

-- Redstone configuration
local RED_TXT = "Red.txt"
local redstoneState = false
local toggleState = false

-- State
local computerId = os.getComputerID()
local isConnected = false

-- Red.txt Parsing
local function parseRedTxt()
    redConfig = {}
    
    local file = io.open(RED_TXT, "r")
    if not file then
        print("Red.txt not found! Using default configuration.")
        redConfig.side = "top"
        redConfig.trigger = "pulse"
        redConfig.description = "Default node control"
    else
        for line in file:lines() do
            local key, value = line:match("^(%a+):%s*(.+)$")
            if key and value then
                redConfig[key:lower()] = value:lower()
            end
        end
        file.close()
    end
    
    -- Validate
    if not redConfig.side then redConfig.side = "top" end
    if not redConfig.trigger then redConfig.trigger = "pulse" end
    
    print("Red.txt loaded: Side=" .. redConfig.side .. ", Trigger=" .. redConfig.trigger)
end

-- Set redstone output (ComputerCraft uses redstone.setOutput)
local function setRedstone(state)
    redstoneState = state
    local side = redConfig.side
    
    if redstone.setOutput then
        if state then
            redstone.setOutput(side, true)
        else
            redstone.setOutput(side, false)
        end
    else
        print("No redstone API - simulating: " .. (state and "ON" or "OFF"))
    end
    
    -- In tunnel mode, we don't need to report back - Host tracks state
end

-- Trigger action based on Red.txt config
local function handleTrigger()
    local trigger = redConfig.trigger
    
    if trigger == "pulse" then
        setRedstone(true)
        sleep(1)
        setRedstone(false)
        print("Redstone pulse on side " .. redConfig.side)
        
    elseif trigger == "toggle" then
        toggleState = not toggleState
        setRedstone(toggleState)
        local status = toggleState and "ON" or "OFF"
        print("Redstone toggled to " .. status .. " on side " .. redConfig.side)
        
    elseif trigger == "pulse toggle" then
        -- Pulse then toggle
        setRedstone(true)
        sleep(0.5)
        setRedstone(false)
        sleep(0.5)
        toggleState = not toggleState
        setRedstone(toggleState)
        local status = toggleState and "ON" or "OFF"
        print("Redstone pulse+toggled to " .. status .. " on side " .. redConfig.side)
    end
end

-- Cloudflare Tunnel: Connect to Host.py
local function connectToHost()
    -- Poll the tunnel endpoint to register and check for commands
    isConnected = true
    print("Connecting to Jarvis Host via Cloudflare tunnel...")
    print("Tunnel URL: " .. TUNNEL_URL)
end

-- Send status to Host.py
local function sendStatusToHost()
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/register"
        local response = http.get(URL)
        if response then
            response.close()
            -- Worker registered successfully
        end
    end)
    return ok
end

-- Check for TTS commands from Host.py
local function checkForTTS()
    -- Poll Host.py for TTS commands
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/check_tts"
        local response = http.get(URL)
        if response then
            local body = response.readAll()
            response.close()
            local success, data = pcall(textutils.unserialiseJSON, body)
            if success and data then
                if data.text then
                    playTTS(data.text)
                end
            end
        end
    end)
    return ok
end

-- Play TTS via speaker (ComputerCraft peripheral)
local function playTTS(text)
    local speaker = peripheral.find("speaker")
    if speaker then
        speaker.say(text)
        print("TTS: " .. text:sub(1, 30) .. (text:len() > 30 and "..." or ""))
    else
        print("No speaker component. Text: " .. text)
    end
end

-- Check for redstone commands from Host
local function checkForCommands()
    -- Poll Host.py for redstone commands
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/command"
        local response = http.get(URL)
        if response then
            local body = response.readAll()
            response.close()
            local success, data = pcall(textutils.unserialiseJSON, body)
            if success and data then
                if data.action == "trigger_pulse" then
                    handleTrigger()
                elseif data.action == "toggle" then
                    toggleState = not toggleState
                    setRedstone(toggleState)
                end
            end
        end
    end)
    return ok
end

-- Main loop
local function main()
    -- Parse Red.txt configuration
    parseRedTxt()
    
    -- Connect to Host via Cloudflare tunnel
    connectToHost()
    sendStatusToHost()
    
    -- Main event loop
    print("Worker Node Started")
    print("Computer ID: " .. computerId)
    print("Tunnel URL: " .. TUNNEL_URL)
    print("Redstone Side: " .. redConfig.side)
    print("Trigger Type: " .. redConfig.trigger)
    print("Description: " .. redConfig.description)
    print("Listening for commands from Host.py via Cloudflare tunnel...")
    print()
    
    while true do
        -- Check for TTS commands
        checkForTTS()
        
        -- Check for redstone commands
        checkForCommands()
        
        -- Poll every 2 seconds
        sleep(2)
    end
end

-- Run main
main()
