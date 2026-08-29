local TUNNEL_URL = "https://pty-climbing-senior-emails.trycloudflare.com"
local RAW_URL = "https://raw.githubusercontent.com/estps/Jarvis-SE-Ai/refs/heads/main/Url.txt"
local function fetchTunnelUrl()
    local ok, resp = pcall(http.get, RAW_URL)
    if ok and resp then
        local u = (resp.readAll() or ""):gsub("%s+", "")
        resp.close()
        if u:sub(1, 8) == "https://" and u:find("trycloudflare%.com") then
            TUNNEL_URL = u
            return true
        end
    end
    return false
end
local RED_TXT = "Red.txt"
local redstoneState = false
local toggleState = false
local computerId = os.getComputerID()
local isConnected = false

local function parseRedTxt()
    redConfig = {}
    local file = fs.open(RED_TXT, "r")
    if not file then
        print("Red.txt not found! Using default configuration.")
        redConfig.side = "top"
        redConfig.trigger = "pulse"
        redConfig.description = "Default node control"
    else
        local line = file.readLine()
        while line do
            local key, value = line:match("^(%a+):%s*(.+)$")
            if key and value then
                redConfig[key:lower()] = value:lower()
            end
            line = file.readLine()
        end
        file.close()
    end
    if not redConfig.side then redConfig.side = "top" end
    if not redConfig.trigger then redConfig.trigger = "pulse" end
    print("Red.txt loaded: Side=" .. redConfig.side .. ", Trigger=" .. redConfig.trigger)
end

local function setRedstone(state)
    redstoneState = state
    local side = redConfig.side
    if redstone.setOutput then
        redstone.setOutput(side, state)
    else
        print("No redstone API - simulating: " .. (state and "ON" or "OFF"))
    end
end

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

local function connectToHost()
    isConnected = true
    print("Connecting to Jarvis Host via Cloudflare tunnel...")
    print("Tunnel URL: " .. TUNNEL_URL)
end

local function sendStatusToHost()
    local ok, err = pcall(function()
        local URL = TUNNEL_URL .. "/register"
        local response = http.get(URL)
        if response then
            response.close()
        end
    end)
    return ok
end

local function checkForTTS()
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

local function playTTS(text)
    local speaker = peripheral.find("speaker")
    if speaker then
        speaker.say(text)
        print("TTS: " .. text:sub(1, 30) .. (text:len() > 30 and "..." or ""))
    else
        print("No speaker component. Text: " .. text)
    end
end

local function checkForCommands()
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

local function main()
    parseRedTxt()
    fetchTunnelUrl()
    connectToHost()
    sendStatusToHost()
    print("Worker Node Started")
    print("Computer ID: " .. computerId)
    print("Tunnel URL: " .. TUNNEL_URL)
    print("Redstone Side: " .. redConfig.side)
    print("Trigger Type: " .. redConfig.trigger)
    print("Description: " .. redConfig.description)
    print("Listening for commands from Host.py via Cloudflare tunnel...")
    print()
    while true do
        checkForTTS()
        checkForCommands()
        sleep(2)
    end
end

main()
