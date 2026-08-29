--[[
  setup.lua - Red.txt Configuration Helper
  ComputerCraft 1.21.1 NeoForge
  Helps setup Red.txt for Worker.lua nodes
]]--

-- Default Red.txt template
local defaultRedTxt = [[
Side:top
Trigger:pulse
Description:Default node control
]]

-- Interactive setup function
local function setupRedTxt()
    print("=" .. string.rep("=", 50))
    print("Jarvis Worker Node Configuration Wizard")
    print("=" .. string.rep("=", 50))
    print()
    print("This will help you create a Red.txt file for your worker node.")
    print("Configuration options:")
    print("  1. Side: Which side for redstone (top/right/bottom/left/back)")
    print("  2. Trigger: How to activate (pulse/toggle/pulse toggle)")
    print("  3. Description: Description of what this node does")
    print()
    print("Example Red.txt format:")
    print("  Side:top")
    print("  Trigger:pulse")
    print("  Description:opens the hanger")
    print()
    
    -- Get side
    local side = read():gsub("^%s*(.-)%s*$", "%1")
    if side:lower() == "top" or side:lower() == "bottom" or 
       side:lower() == "left" or side:lower() == "right" or
       side:lower() == "back" then
        -- Valid side, continue
    else
        print("Invalid side. Using 'top' as default.")
        side = "top"
    end
    
    -- Get trigger type
    print("Select trigger type:")
    print("  1. pulse - Fire for 1 second")
    print("  2. toggle - Turn on/off each time")
    print("  3. pulse toggle - Pulse then toggle state")
    local triggerChoice = read():gsub("^%s*(.-)%s*$", "%1")
    
    local trigger
    if triggerChoice == "1" or triggerChoice:lower() == "pulse" then
        trigger = "pulse"
    elseif triggerChoice == "2" or triggerChoice:lower() == "toggle" then
        trigger = "toggle"
    elseif triggerChoice == "3" or triggerChoice:lower() == "pulse toggle" then
        trigger = "pulse toggle"
    else
        print("Invalid choice. Using 'pulse' as default.")
        trigger = "pulse"
    end
    
    -- Get description
    print("Enter description (press Enter to finish):")
    local description = read():gsub("^%s*(.-)%s*$", "%1")
    
    -- Create Red.txt content
    local redTxtContent = "Side:" .. side .. "\nTrigger:" .. trigger .. "\nDescription:" .. description .. "\n"
    
    -- Write to file
    local file = io.open("Red.txt", "w")
    if file then
        file.write(redTxtContent)
        file.close()
        print()
        print("=" .. string.rep("=", 50))
        print("Red.txt created successfully!")
        print("Configuration:")
        print("  Side: " .. side)
        print("  Trigger: " .. trigger)
        print("  Description: " .. description)
        print("=" .. string.rep("=", 50))
    else
        print("Error: Could not create Red.txt file!")
    end
end

-- View current Red.txt
local function viewRedTxt()
    local file = io.open("Red.txt", "r")
    if file then
        print()
        print("=" .. string.rep("=", 50))
        print("Current Red.txt Contents:")
        print("=" .. string.rep("=", 50))
        for line in file:lines() do
            print("  " .. line)
        end
        print("=" .. string.rep("=", 50))
        file.close()
    else
        print("Red.txt not found in current directory.")
        print("Run /setup to create one.")
    end
end

-- Reset Red.txt
local function resetRedTxt()
    print("Resetting Red.txt to defaults...")
    local file = io.open("Red.txt", "w")
    if file then
        file.write(defaultRedTxt)
        file.close()
        print("Red.txt reset to defaults.")
    else
        print("Error creating Red.txt!")
    end
end

-- Main setup menu
local function main()
    while true do
        print()
        print("Jarvis Setup Menu")
        print("-----------------")
        print("1. Configure New Red.txt")
        print("2. View Current Red.txt")
        print("3. Reset Red.txt to Defaults")
        print("4. Exit")
        print()
        
        local choice = read():gsub("^%s*(.-)%s*$", "%1")
        
        if choice == "1" then
            setupRedTxt()
        elseif choice == "2" then
            viewRedTxt()
        elseif choice == "3" then
            resetRedTxt()
        elseif choice == "4" then
            print("Exiting setup. Goodbye!")
            break
        else
            print("Invalid choice. Please enter 1-4.")
        end
        
        -- Small pause before showing menu again
        sleep(0.5)
    end
end

-- Run main if executed directly
if not ... then
    -- Check if running as standalone or imported
    local ok, err = pcall(function() main() end)
    if not ok then
        print("Setup utility error: " .. tostring(err))
    end
end