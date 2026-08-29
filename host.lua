local TUNNEL_URL = "https://pty-climbing-senior-emails.trycloudflare.com"
local CFG_FILE = "jarvis_config.json"
if fs.exists(CFG_FILE) then
    local ch = fs.open(CFG_FILE, "r")
    if ch then
        local ok, t = pcall(textutils.unserialiseJSON, ch.readAll())
        if ok and t and t.tunnel_url and t.tunnel_url ~= "" then
            TUNNEL_URL = t.tunnel_url
            if TUNNEL_URL:sub(-1) == "/" then TUNNEL_URL = TUNNEL_URL:sub(1, -2) end
        end
        ch.close()
    end
end

local G = {}
local function rows(a) return a end
G["A"] = rows({".#...", "#..#.", "#..#.", "#####", "#..#.", "#..#.", "#..#."})
G["B"] = rows({"####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."})
G["C"] = rows({".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."})
G["D"] = rows({"####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."})
G["E"] = rows({"#####", "#....", "#....", "####.", "#....", "#....", "#####"})
G["F"] = rows({"#####", "#....", "#....", "####.", "#....", "#....", "#...."})
G["G"] = rows({".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".###."})
G["H"] = rows({"#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"})
G["I"] = rows({".###.", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."})
G["J"] = rows({"..###", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."})
G["K"] = rows({"#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"})
G["L"] = rows({"#....", "#....", "#....", "#....", "#....", "#....", "#####"})
G["M"] = rows({"#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"})
G["N"] = rows({"#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"})
G["O"] = rows({".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."})
G["P"] = rows({"####.", "#...#", "#...#", "####.", "#....", "#....", "#...."})
G["Q"] = rows({".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"})
G["R"] = rows({"####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"})
G["S"] = rows({".####", "#....", "#....", ".###.", "....#", "....#", "####."})
G["T"] = rows({"#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."})
G["U"] = rows({"#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."})
G["V"] = rows({"#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."})
G["W"] = rows({"#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"})
G["X"] = rows({"#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"})
G["Y"] = rows({"#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."})
G["Z"] = rows({"#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"})
G["a"] = rows({".....", ".....", ".##..", "#...#", ".####", "#...#", ".####"})
G["b"] = rows({"#....", ".###.", "#...#", "#...#", "#...#", "#...#", ".###."})
G["c"] = rows({".....", ".....", ".###.", "#...#", "#....", "#...#", ".###."})
G["d"] = rows({"....#", ".####", "#...#", "#...#", "#...#", "#...#", ".####"})
G["e"] = rows({".....", ".....", ".###.", "#...#", "#####", "#....", ".###."})
G["f"] = rows({"..##.", ".#...", ".###.", ".#...", ".#...", ".#...", ".#..."})
G["g"] = rows({".####", "#...#", "#...#", ".####", "....#", "#...#", ".###."})
G["h"] = rows({"#....", "#....", "####.", "#...#", "#...#", "#...#", "#...#"})
G["i"] = rows({"..#..", ".....", ".##..", "..#..", "..#..", "..#..", ".###."})
G["j"] = rows({"...#.", ".....", ".###.", "...#.", "...#.", "...#.", "#..#."})
G["k"] = rows({"#....", "#....", "#..#.", "#.#..", "##...", "#.#..", "#..#."})
G["l"] = rows({".##..", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."})
G["m"] = rows({".....", ".....", "##.#.", "#.#.#", "#.#.#", "#.#.#", "#.#.#"})
G["n"] = rows({".....", ".....", "####.", "#...#", "#...#", "#...#", "#...#"})
G["o"] = rows({".....", ".....", ".###.", "#...#", "#...#", "#...#", ".###."})
G["p"] = rows({".....", "###..", "#...#", "#...#", "####.", "#....", "#...."})
G["q"] = rows({".....", ".###.", "#...#", "#...#", "#...#", ".####", "....#"})
G["r"] = rows({".....", "..##.", "#.#..", "#....", "#....", "#....", "#...."})
G["s"] = rows({".....", ".....", ".####", "#....", ".###.", "....#", "####."})
G["t"] = rows({".#...", ".#...", ".###.", ".#...", ".#...", ".#...", "..##."})
G["u"] = rows({".....", ".....", "#...#", "#...#", "#...#", "#...#", ".####"})
G["v"] = rows({".....", ".....", "#...#", "#...#", "#...#", ".#.#.", "..#.."})
G["w"] = rows({".....", ".....", "#...#", "#.#.#", "#.#.#", "#.#.#", ".#.#."})
G["x"] = rows({".....", ".....", "#...#", ".#.#.", "..#..", ".#.#.", "#...#"})
G["y"] = rows({".....", "#...#", "#...#", ".####", "....#", "#...#", ".###."})
G["z"] = rows({".....", ".....", "#####", "...#.", "..#..", ".#...", "#####"})
G["0"] = rows({".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."})
G["1"] = rows({"..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."})
G["2"] = rows({".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"})
G["3"] = rows({"#####", "....#", "...#.", "..##.", "....#", "#...#", ".###."})
G["4"] = rows({"...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."})
G["5"] = rows({"#####", "#....", "####.", "....#", "....#", "#...#", ".###."})
G["6"] = rows({"..##.", ".#...", "#....", "####.", "#...#", "#...#", ".###."})
G["7"] = rows({"#####", "....#", "...#.", "..#..", "..#..", "..#..", "..#.."})
G["8"] = rows({".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."})
G["9"] = rows({".###.", "#...#", "#...#", ".####", "....#", "...#.", ".##.."})
G[" "] = rows({".....", ".....", ".....", ".....", ".....", ".....", "....."})
G["."] = rows({".....", ".....", ".....", ".....", ".....", "..#..", "..#.."})
G[","] = rows({".....", ".....", ".....", ".....", "..#..", "..#..", ".#..."})
G["!"] = rows({"..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."})
G["?"] = rows({".###.", "#...#", "...#.", "..#..", "..#..", ".....", "..#.."})
G[":"] = rows({".....", "..#..", "..#..", ".....", "..#..", "..#..", "....."})
G[";"] = rows({".....", "..#..", "..#..", ".....", "..#..", "..#..", ".#..."})
G["'"] = rows({"..#..", "..#..", ".....", ".....", ".....", ".....", "....."})
G['"'] = rows({".#.#.", ".#.#.", ".....", ".....", ".....", ".....", "....."})
G["-"] = rows({".....", ".....", ".....", "#####", ".....", ".....", "....."})
G["_"] = rows({".....", ".....", ".....", ".....", ".....", ".....", "#####"})
G["/"] = rows({"....#", "....#", "...#.", "..#..", ".#...", "#....", "#...."})
G["\\"] = rows({"#....", "#....", ".#...", "..#..", "...#.", "....#", "....#"})
G["+"] = rows({".....", "..#..", "..#..", "#####", "..#..", "..#..", "....."})
G["="] = rows({".....", ".....", "#####", ".....", "#####", ".....", "....."})
G["<"] = rows({"...#.", "..#..", ".#...", "#....", ".#...", "..#..", "...#."})
G[">"] = rows({".#...", "..#..", "...#.", "....#", "...#.", "..#..", ".#..."})
G["("] = rows({"...#.", "..#..", ".#...", ".#...", ".#...", "..#..", "...#."})
G[")"] = rows({".#...", "..#..", "...#.", "...#.", "...#.", "..#..", ".#..."})
G["["] = rows({"..###", "..#..", "..#..", "..#..", "..#..", "..#..", "..###"})
G["]"] = rows({"###..", "..#..", "..#..", "..#..", "..#..", "..#..", "###.."})
G["{"] = rows({"...#.", "..#..", "..#..", ".#...", "..#..", "..#..", "...#."})
G["}"] = rows({".#...", "..#..", "..#..", "...#.", "..#..", "..#..", ".#..."})
G["|"] = rows({"..#..", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."})
G["#"] = rows({".#.#.", "#####", ".#.#.", "#####", ".#.#.", ".....", "....."})
G["@"] = rows({".###.", "#...#", "#..##", "#.#.#", "#..##", "#....", ".###."})
G["&"] = rows({".#...", "#.#..", "#.#..", ".#...", "#.#..", "#.#..", ".#.#."})
G["$"] = rows({"..#..", ".####", "#..#.", "#....", ".###.", "...#.", "####."})
G["%"] = rows({"#...#", "#...#", "...#.", "..#..", ".#...", "#...#", "#...#"})
G["*"] = rows({".....", "#.#..", ".###.", "..#..", ".###.", "#.#..", "....."})
G["^"] = rows({".#...", "#.#..", "#...#", ".....", ".....", ".....", "....."})
G["~"] = rows({".....", ".....", ".#...", "#.#.#", "...#.", ".....", "....."})
G["`"] = rows({".#...", "..#..", ".....", ".....", ".....", ".....", "....."})
G["?"] = rows({".###.", "#...#", "...#.", "..#..", "..#..", ".....", "..#.."})

local P = {
    bg = 16, panel = 17, head = 18, bd = 19, white = 20, dim = 21,
    accent = 22, ai = 23, sys = 24, ok = 25, err = 26, input = 27, inbd = 28, cur = 29
}
local PAL = {
    {16, 24, 32, 54}, {17, 26, 36, 62}, {18, 40, 56, 90}, {19, 58, 84, 130},
    {20, 224, 234, 248}, {21, 126, 146, 180}, {22, 50, 224, 255}, {23, 170, 234, 255},
    {24, 132, 152, 186}, {25, 72, 226, 146}, {26, 255, 96, 108}, {27, 26, 36, 58},
    {28, 66, 96, 148}, {29, 50, 224, 255}
}

local dbgOn = true
local lastEv = "none"
local evP1 = ""
local evP2 = ""

local function dbg(...)
    pcall(function()
        local f = fs.open("/dbg.txt", "a")
        if f then
            f.write(os.clock() .. " " .. table.concat({ ... }, " ") .. "\n")
            f.close()
        end
    end)
end

dbg("script start")

local function bytesStr(s)
    local t = {}
    for i = 1, #s do
        t[i] = string.byte(s, i)
    end
    return table.concat(t, ",")
end

local gw, gh = 1, 1
local gfx = false
local function initGfx()
    local ok = pcall(function()
        term.setGraphicsMode(2)
        if term.getGraphicsMode() ~= 2 then error("no gfx") end
        gw, gh = term.getSize(true)
        for i = 1, #PAL do
            local e = PAL[i]
            term.setPaletteColour(e[1], e[2] / 255, e[3] / 255, e[4] / 255)
        end
    end)
    if ok then gfx = true end
    dbg("initGfx ok", gfx)
end

local function rect(x, y, w, h, c)
    pcall(term.drawPixels, x, y, c, w, h)
end

local function textRow(g, r, fg, bg)
    local row = G[g] and G[g][r] or G["?"][r]
    local t = {}
    for i = 1, 5 do
        t[i] = row:sub(i, i) == "#" and fg or bg
    end
    return table.concat(t)
end

local function drawText(px, py, s, fg, bg)
    if #s == 0 then return end
    local rows = { "", "", "", "", "", "", "" }
    for i = 1, #s do
        local g = G[s:sub(i, i)] or G["?"]
        for r = 1, 7 do
            rows[r] = rows[r] .. textRow(g, r, fg, bg)
        end
    end
    pcall(term.drawPixels, px, py, rows)
end

local buf = {}
local online = false
local nodeCount = 0
local sc = 0
local input = ""
local thinkingTag = "GENERATING..."

local CPL = 48
local VIS = 16

local function wrap(text, lim)
    local out = {}
    local cur = ""
    for w in (text .. " "):gmatch("%S+") do
        if #cur + #w + 1 > lim then
            if cur ~= "" then
                table.insert(out, cur:sub(1, -2))
                cur = ""
            end
            while #w > lim do
                table.insert(out, w:sub(1, lim))
                w = w:sub(lim + 1)
            end
            if #w > 0 then cur = w .. " " end
        else
            cur = cur .. w .. " "
        end
    end
    if cur ~= "" then table.insert(out, cur:sub(1, -2)) end
    if #out == 0 then out = { "" } end
    return out
end

local function addMsg(fg, text)
    local lines = wrap(text, CPL)
    for i = 1, #lines do
        table.insert(buf, { fg = fg, txt = lines[i] })
    end
    sc = math.max(0, #buf - VIS)
end

local function popThinking()
    for i = #buf, 1, -1 do
        if buf[i].txt == thinkingTag then
            table.remove(buf, i)
        end
    end
end

local function char(idx)
    return string.char(idx)
end

local cW = char(P.white)
local function visLines()
    local v = math.floor((gh - 37) / 8)
    if dbgOn then v = v - 1 end
    return math.max(4, v)
end

local function render()
    term.setFrozen(true)
    rect(0, 0, gw, gh, P.bg)
    rect(0, 0, gw, 16, P.head)
    rect(0, 16, gw, 1, P.bd)
    drawText(6, 4, "JARVIS SE AI", char(P.accent), char(P.head))
    local stTxt = "OFFLINE"
    local stCol = P.err
    if online then stTxt = "ONLINE" end
    if online then stCol = P.ok end
    local stW = #stTxt * 6 + 8
    rect(gw - 6 - stW, 3, stW, 10, P.bd)
    drawText(gw - 6 - stW + 4, 4, stTxt, char(stCol), char(P.bd))
    drawText(gw - 6 - stW - 6, 4, "NODES  " .. tostring(nodeCount), char(P.dim), char(P.head))
    local iy = gh - 17
    rect(0, iy, gw, 15, P.input)
    rect(0, iy, gw, 1, P.inbd)
    rect(0, iy + 14, gw, 1, P.inbd)
    local msgTop = 20
    if dbgOn then
        drawText(6, 18, lastEv .. " " .. evP1 .. "|" .. bytesStr(input), char(P.warn), char(P.bg))
        msgTop = 27
    end
    local n = #buf
    local from = math.max(1, n - VIS - sc + 1)
    local to = math.max(0, n - sc)
    local lineNo = 0
    for i = from, to do
        drawText(6, msgTop + lineNo * 8, buf[i].txt, char(buf[i].fg), char(P.bg))
        lineNo = lineNo + 1
    end
    drawText(6, iy + 4, ">", char(P.dim), char(P.input))
    drawText(12, iy + 4, input, cW, char(P.input))
    if math.floor(os.epoch("utc") / 500) % 2 == 0 then
        rect(12 + #input * 6, iy + 4, 2, 8, P.cur)
    end
    term.setFrozen(false)
end

local function jsonIt(t)
    return textutils.serialiseJSON(t)
end

local function testConnection()
    local ok, resp = pcall(http.get, TUNNEL_URL .. "/", {}, 4000)
    if ok and resp then
        local body = resp.readAll()
        resp.close()
        online = true
    else
        online = false
    end
end

local function playJarvisTTS(text)
    pcall(function()
        local ok, resp = pcall(http.post, TUNNEL_URL .. "/tts", jsonIt({ text = text }),
            { ["Content-Type"] = "application/json" }, 3000)
        if ok and resp then resp.close() end
    end)
end

local function fetchNodes()
    pcall(function()
        local ok, resp = pcall(http.get, TUNNEL_URL .. "/nodes", {}, 4000)
        if ok and resp then
            local body = resp.readAll()
            resp.close()
            local ok2, t = pcall(textutils.unserialiseJSON, body)
            if ok2 and t then
                if t.total then
                    nodeCount = t.total
                elseif type(t) == "table" then
                    local count = 0
                    for k, v in pairs(t) do
                        if type(k) == "number" then count = count + 1 end
                    end
                    nodeCount = count
                end
            end
        end
    end)
end

local function sysLine(txt)
    addMsg(P.sys, txt)
end

local function runCommand(line)
    local parts = {}
    for w in line:lower():gmatch("%S+") do
        table.insert(parts, w)
    end
    local c = parts[1] or ""
    if c == "/clear" then
        buf = {}
        sc = 0
    elseif c == "/ping" then
        testConnection()
        if online then
            sysLine("Link OK  " .. TUNNEL_URL)
        else
            sysLine("Host unreachable - start Host.py")
        end
    elseif c == "/nodes" then
        fetchNodes()
        sysLine("Workers connected: " .. tostring(nodeCount))
    elseif c == "/help" then
        sysLine("/ping /nodes /clear /help /debug /exit /reboot")
    elseif c == "/debug" then
        dbgOn = not dbgOn
        if gfx then VIS = visLines() end
        sysLine("Debug " .. (dbgOn and "ON" or "OFF") .. " - see /dbg.txt")
    elseif c == "/exit" then
        pcall(term.setGraphicsMode, 0)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        term.write("Jarvis powered down.")
        os.sleep(1)
        term.turnOff()
    elseif c == "/reboot" then
        os.reboot()
    else
        sysLine("Unknown command: " .. c)
    end
end

local function sendToAI(text)
    addMsg(P.accent, "> " .. text)
    addMsg(P.dim, thinkingTag)
    render()
    local received = false
    local ok, resp = pcall(http.post, TUNNEL_URL .. "/ask", jsonIt({ question = text }),
        { ["Content-Type"] = "application/json" }, 20000)
    if ok and resp then
        local body = resp.readAll()
        resp.close()
        local ok2, t = pcall(textutils.unserialiseJSON, body)
        local answer = ok2 and t and t.response
        if answer and answer ~= "" then
            received = true
            popThinking()
            addMsg(P.ai, answer)
            playJarvisTTS(answer)
        end
    end
    if not received then
        popThinking()
        addMsg(P.err, "Connection error. Is Host.py running?")
    end
    render()
end

local KEY_BS = 14
local KEY_ENTER = 28
local KEY_UP = 200
local KEY_DOWN = 208
if type(keys) == "table" then
    KEY_BS = keys.backspace or KEY_BS
    KEY_ENTER = keys.enter or KEY_ENTER
    KEY_UP = keys.up or KEY_UP
    KEY_DOWN = keys.down or KEY_DOWN
end

local function handleSubmit(txt)
    if txt ~= "" then
        if txt:sub(1, 1) == "/" then
            runCommand(txt)
        else
            sendToAI(txt)
        end
    end
end

local running = true
local timer = -1

local function dispatch(ev)
    if ev[1] == "timer" and ev[2] == timer then
        timer = os.startTimer(0.35)
    elseif ev[1] == "terminate" then
        running = false
    elseif ev[1] == "char" then
        if ev[2] == "\n" or ev[2] == "\r" then
            handleSubmit(input)
            input = ""
        else
            input = input .. ev[2]
        end
    elseif ev[1] == "paste" then
        input = input .. ev[2]
    elseif ev[1] == "key" then
        if ev[2] == KEY_BS then
            input = input:sub(1, -2)
        elseif ev[2] == KEY_ENTER then
            local txt = input
            input = ""
            handleSubmit(txt)
        elseif ev[2] == KEY_UP then
            sc = math.min(sc + 1, math.max(0, #buf - VIS))
        elseif ev[2] == KEY_DOWN then
            sc = math.max(0, sc - 1)
        end
    elseif ev[1] == "mouse_scroll" then
        sc = math.min(sc + ev[2], math.max(0, #buf - VIS))
    end
end

local function mainGraphics()
    dbg("boot mainGraphics")
    initGfx()
    if not gfx then return false end
    dbg("graphics active", gw, gh)
    CPL = math.floor((gw - 14) / 6)
    VIS = visLines()
    dbg("gfx", gw, gh, "cpl", CPL, "vis", VIS)
    testConnection()
    fetchNodes()
    sysLine("Jarvis online. Type a message or /help")
    running = true
    timer = os.startTimer(0.35)
    while running do
        local rerr = pcall(render)
        if not rerr then dbg("render error") end
        local ev = { os.pullEventRaw() }
        lastEv = tostring(ev[1] or "nil")
        evP2 = tostring(ev[3] or "")
        if ev[1] == "char" or ev[1] == "key" or ev[1] == "paste" or ev[1] == "terminate" or ev[1] == "timer" or ev[1] == "mouse_scroll" then
            evP1 = tostring(ev[2] or "")
            dbg("ev", ev[1], tostring(ev[2]), tostring(ev[3]))
        end
        local eok = pcall(dispatch, ev)
        if not eok then dbg("dispatch error", ev[1]) end
    end
    dbg("mainGraphics exit")
    pcall(term.setGraphicsMode, 0)
    return true
end

local TXTCOL = {
    [P.accent] = colors.cyan, [P.ai] = colors.white, [P.sys] = colors.gray,
    [P.dim] = colors.gray, [P.err] = colors.red, [P.ok] = colors.green
}

local function mainText()
    dbg("mainText entered")
    testConnection()
    fetchNodes()
    CPL = term.getSize() - 4
    VIS = 17
    addMsg(P.accent, "Jarvis online. Type a message or /help")
    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setTextColor(colors.gray)
        term.setCursorPos(1, 1)
        term.write("JARVIS SE  [")
        if online then
            term.setTextColor(colors.green)
            term.write("ONLINE")
        else
            term.setTextColor(colors.red)
            term.write("OFFLINE")
        end
        term.setTextColor(colors.gray)
        term.write("]  Nodes " .. tostring(nodeCount))
        local n = #buf
        local from = math.max(1, n - VIS + 1)
        local row = 2
        for i = from, n do
            term.setCursorPos(1, row)
            term.setTextColor(TXTCOL[buf[i].fg] or colors.white)
            term.write(buf[i].txt)
            row = row + 1
            if row > 18 then break end
        end
        term.setCursorPos(1, 19)
        term.setTextColor(colors.cyan)
        term.write("> ")
        term.setTextColor(colors.white)
        local line = read()
        if line ~= "" then
            if line:sub(1, 1) == "/" then
                runCommand(line)
            else
                sendToAI(line)
            end
        end
    end
end

local function main()
    local ok1, err1 = pcall(mainGraphics)
    if not ok1 then error(tostring(err1), 0) end
    if not gfx then
        pcall(term.setGraphicsMode, 0)
        local ok2, err2 = pcall(mainText)
        if not ok2 then error(tostring(err2), 0) end
        error("graphics mode unavailable", 0)
    end
    return true
end

local ok, err = pcall(main)
if not ok then
    dbg("FATAL", tostring(err))
    pcall(term.setGraphicsMode, 0)
    term.setTextColor(colors.red)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Jarvis crashed: " .. tostring(err))
    os.sleep(8)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    pcall(term.turnOff)
end
