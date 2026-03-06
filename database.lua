-- // NEW GITHUB LINK CONFIG
local GITHUB_DB = "https://raw.githubusercontent.com/badscarz/a/refs/heads/main/README.md"

-- // FETCH DATA ENGINE
local Data = {Main = {}, Sub = {}}
local success, res = pcall(function() 
    return loadstring(game:HttpGet(GITHUB_DB))() 
end)

if success and type(res) == "table" then
    Data = res
else
    warn("Krypton: Failed to fetch database from GitHub.")
    Data = {
        Main = {
            {name = "RETRY FETCH", url = GITHUB_DB},
            {name = "TERMINATE ALL", url = "ACTION_TERMINATE"}
        },
        Sub = {}
    }
end

-- // SCROLL HUB GUI (INTERNAL LIST)
local subGui = Instance.new("Frame", sg)
subGui.Size, subGui.Position = UDim2.new(0, 300, 0, 350), UDim2.new(0.5, -150, 0.5, -175)
subGui.BackgroundColor3, subGui.BorderSizePixel, subGui.BorderColor3, subGui.Visible = Color3.fromRGB(5, 5, 5), 2, Color3.fromRGB(255, 0, 0), false

local subHeader = Instance.new("Frame", subGui)
subHeader.Size, subHeader.BackgroundColor3 = UDim2.new(1, 0, 0, 35), Color3.fromRGB(45, 0, 0)

local subTitle = Instance.new("TextLabel", subHeader)
subTitle.Size, subTitle.Position, subTitle.Text = UDim2.new(1, -40, 1, 0), UDim2.new(0, 10, 0, 0), "INTERNAL GAME HUB"
subTitle.Font, subTitle.TextColor3, subTitle.TextSize, subTitle.BackgroundTransparency = Enum.Font.GothamBold, Color3.new(1, 1, 1), 12, 1

local closeX = Instance.new("TextButton", subHeader)
closeX.Size, closeX.Position, closeX.Text = UDim2.new(0, 35, 0, 35), UDim2.new(1, -35, 0, 0), "X"
closeX.BackgroundColor3, closeX.TextColor3, closeX.BorderSizePixel = Color3.fromRGB(150, 0, 0), Color3.new(1, 1, 1), 0

local scroll = Instance.new("ScrollingFrame", subGui)
scroll.Size, scroll.Position, scroll.BackgroundTransparency = UDim2.new(1, -10, 1, -45), UDim2.new(0, 5, 0, 40), 1
scroll.ScrollBarThickness, scroll.ScrollBarImageColor3 = 3, Color3.new(1, 0, 0)
local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.Padding = UDim.new(0, 5)

-- // REBUILD MAIN SLOTS FROM GITHUB
for _, s in pairs(slots) do s.Frame:Destroy() end
slots = {}
for i, d in ipairs(Data.Main) do 
    createGtaSlot(i, d.name, d.url) 
end
main.Size = UDim2.new(0, 330, 0, 100 + (#Data.Main * 46))

-- // BUILD SUB-MENU SCROLL LIST
local subSlots, subIdx = {}, 1
for i, d in ipairs(Data.Sub) do
    local f = Instance.new("Frame", scroll)
    f.Size, f.BackgroundColor3, f.BorderSizePixel = UDim2.new(1, -5, 0, 35), Color3.fromRGB(25, 25, 25), 0
    local l = Instance.new("TextLabel", f)
    l.Size, l.Position, l.Text = UDim2.new(1, -10, 1, 0), UDim2.new(0, 10, 0, 0), d.name:upper()
    l.Font, l.TextColor3, l.TextSize, l.BackgroundTransparency = Enum.Font.Gotham, Color3.new(0.7, 0.7, 0.7), 11, 1
    subSlots[i] = {Frame = f, Label = l, Load = d.load}
end
scroll.CanvasSize = UDim2.new(0, 0, 0, #subSlots * 40)

-- // NAVIGATION ENGINE
local menuMode = "MAIN"
local function sync()
    for i, s in pairs(slots) do
        local active = (menuMode == "MAIN" and i == selectedIndex)
        s.Frame.BackgroundColor3 = active and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
        s.Frame.BackgroundTransparency = active and 0 or 0.5
        s.Label.TextColor3 = active and Color3.new(0, 0, 0) or (s.URL == "ACTION_TERMINATE" and Color3.new(1, 0, 0) or Color3.new(1, 1, 1))
    end
    for i, s in pairs(subSlots) do
        local active = (menuMode == "SUB" and i == subIdx)
        s.Frame.BackgroundColor3 = active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(25, 25, 25)
        s.Label.TextColor3 = active and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
        if active then 
            scroll.CanvasPosition = Vector2.new(0, math.max(0, (i-4) * 40)) 
        end
    end
end

closeX.MouseButton1Click:Connect(function() 
    subGui.Visible = false 
    menuMode = "MAIN" 
    sync() 
end)

-- // FINAL INPUT BINDING
UserInputService.InputBegan:Connect(function(io, gpe)
    if gpe and io.KeyCode ~= Enum.KeyCode.Return then return end
    if io.KeyCode == Enum.KeyCode.Zero then 
        main.Visible = not main.Visible 
        subGui.Visible = false 
        menuMode = "MAIN" 
    end
    if not main.Visible then return end

    if io.KeyCode == Enum.KeyCode.Down then
        if menuMode == "MAIN" then 
            selectedIndex = selectedIndex >= #slots and 1 or selectedIndex + 1
        else 
            subIdx = subIdx >= #subSlots and 1 or subIdx + 1 
        end
    elseif io.KeyCode == Enum.KeyCode.Up then
        if menuMode == "MAIN" then 
            selectedIndex = selectedIndex <= 1 and #slots or selectedIndex - 1
        else 
            subIdx = subIdx <= 1 and #subSlots or subIdx - 1 
        end
    elseif io.KeyCode == Enum.KeyCode.Return then
        if menuMode == "MAIN" then
            local t = slots[selectedIndex]
            if t.url == "OPEN_SUB_GUI" or t.URL == "OPEN_SUB_GUI" then 
                subGui.Visible = true 
                menuMode = "SUB"
            elseif t.url == "ACTION_TERMINATE" or t.URL == "ACTION_TERMINATE" then
                for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do 
                    if v:IsA("ScreenGui") and v.Name ~= sg.Name then v:Destroy() end 
                end
            elseif t.url and t.url ~= "" then 
                loadstring(game:HttpGet(t.url))() 
            elseif t.URL and t.URL ~= "" then
                loadstring(game:HttpGet(t.URL))()
            end
        else
            local t = subSlots[subIdx]
            if t.Load ~= "" then loadstring(t.Load)() end
        end
    elseif io.KeyCode == Enum.KeyCode.Backspace and menuMode == "SUB" then
        subGui.Visible = false 
        menuMode = "MAIN"
    end
    sync()
end)

sync()
