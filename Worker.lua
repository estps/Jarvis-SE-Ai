--[[
  Worker.lua - Node Controller for Jarvis AI System
  ComputerCraft 1.21.1 NeoForge
  Runs on "normal computers" connected via wired modems
  Handles Redstone output and Speaker TTS
]]--

-- Configuration
local MODEM_SIDE = "right"  -- Default modem side
local RED_TXT = "Red.txt"   -- Configuration file
local REDNET_ALIAS = "worker"

-- State
local redConfig = {}          -- Parsed Red.txt data
local redstoneState = false -- Current redstone state
local isToggleOn = false    -- Toggle state tracking
local connectedToHost = false

-- Load ComputerCraft APIs
local component = require("component")
local redstone = component.redstone
local sides = require("sides")
local event = require("event")
local modems = component.modem

if not modems then
    error("Modem component not found on this computer!")
end

-- Red.txt Parsing
local function parseRedTxt()
    redConfig = {}
    
    local file = io.open(RED_TXT, "r")
    if not file then
        -- Create default Red.txt if it doesn't exist
        print("Red.txt not found. Creating default configuration...")
        file = io.open(RED_TXT, "w")
        file:setColor(16777215)  -- White text
        file.write("Side:top\nTrigger:pulse\nDescription:Default node control\n")
        file.close()
        redConfig.side = "top"
        redConfig.trigger = "pulse"
        redConfig.description = "Default node control"
        return
    end
    
    for line in file:lines() do
        local key, value = line:match("^(%a+):%s*(.+)$")
        if key and value then
            redConfig[key:lower()] = value:lower()
        end
    end
    file.close()
    
    -- Validate required fields
    if not redConfig.side then
        error("Red.txt missing 'Side:' field!")
    end
    if not redConfig.trigger then
        error("Red.txt missing 'Trigger:' field!")
    end
    
    print("Red.txt loaded successfully:")
    print("  Side: " .. tostring(redConfig.side))
    print("  Trigger: " .. tostring(redConfig.trigger))
    print("  Description: " .. tostring(redConfig.description))
end

-- Determine trigger action
local function handleTrigger()
    local trigger = redConfig.trigger
    
    if trigger == "pulse" then
        -- Fire redstone pulse for 1 second
        redstone.setOutput(redConfig.side, true)
        sleep(1)
        redstone.setOutput(redConfig.side, false)
        print("Redstone pulse activated on " .. redConfig.side)
        
    elseif trigger == "toggle" then
        -- Toggle redstone state
        isToggleOn = not isToggleOn
        redstone.setOutput(redConfig.side, isToggleOn)
        local status = isToggleOn and "ON" or "OFF"
        print("Redstone toggled to " .. status .. " on " .. redConfig.side)
        
    elseif trigger == "pulse toggle" then
        -- Pulse then toggle
        redstone.setOutput(redConfig.side, true)
        sleep(0.5)
        redstone.setOutput(redConfig.side, false)
        sleep(0.5)
        isToggleOn = not isToggleOn
        redstone.setOutput(redConfig.side, isToggleOn)
        local status = isToggleOn and "ON" or "OFF"
        print("Redstone pulse+toggled to " .. status .. " on " .. redConfig.side)
    end
end

-- Rednet Communication
local function sendStatusToHost()
    local statusMsg = {
        type = "node_status",
        node_id = os.getComputerID(),
        status = "online",
        side = redConfig.side,
        trigger = redConfig.trigger,
        description = redConfig.description,
        redstone_state = redstone.getOutput(redConfig.side)
    }
    
    rednet.send(os.getComputerID(), statusMsg, "jarvis_control")
end

local function handleHostCommand(id, message)
    if message.type == "jarvis_speech" then
        -- Host wants us to speak
        playTTS(message.text)
        
    elseif message.type == "command_query" then
        -- AI is asking about our capabilities
        local response = {
            type = "node_capabilities",
            node_id = os.getComputerID(),
            capabilities = {
                side = redConfig.side,
                trigger = redConfig.trigger,
                description = redConfig.description
            }
        }
        rednet.send(id, response, "jarvis_control")
    end
end

-- Speaker TTS
local function playTTS(text)
    local speaker = component.speaker
    if speaker then
        -- Try to use speaker TTS
        speaker.say(text)
        print("TTS: " .. text:sub(1, 30) .. (text:len() > 30 and "..." or ""))
    else
        print("No speaker component found - text only:")
        print(text)
    end
end

-- Main Setup
local function main()
    -- Parse Red.txt configuration
    parseRedTxt()
    
    -- Open modem
    modems.open()
    rednet.open(MODEM_SIDE)
    rednet.setAlias(REDNET_ALIAS)
    
    -- Initial status broadcast
    sendStatusToHost()
    
    print("=" .. string.rep("=", 40))
    print("Worker Node Started")
    print("Computer ID: " .. os.getComputerID())
    print("Modem Side: " .. MODEM_SIDE)
    print("Redstone Side: " .. redConfig.side)
    print("Trigger Type: " .. redConfig.trigger)
    print("Description: " .. redConfig.description)
    print("=" .. string.rep("=", 40))
    print("Waiting for commands from Host...")
    print("Commands supported:")
    print("  - TTS: Text-to-speech via speaker")
    print("  - Redstone: " .. redConfig.trigger .. " on " .. redConfig.side)
    print("=" .. string.rep("=", 40))
    
    -- Main event loop
    while true do
        local eventName, id, message, distance = event.pull("modem_message")
        
        if eventName == "modem_message" and id then
            handleHostCommand(id, message)
        end
        
        -- Optional: Check for redstone input changes
        -- Could be used for trigger detection from computers
        local rsEvent = event.pull(0.1, "redstone_changed")
        if rsEvent then
            -- Redstone state changed, could trigger actions
        end
    end
end

-- Exit handler
local function onExit()
    -- Ensure redstone is off
    if redstone then
        redstone.setOutput(redConfig.side, false)
    end
    print("Worker node shutting down...")
end

-- Run main
main()