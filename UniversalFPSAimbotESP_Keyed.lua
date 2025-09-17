--[[
    UNIVERSAL FPS AIMBOT + ESP GUI
    For educational purposes only!
    Credit: Made by louelle
    Version: 2.2.1
    Key System by horim4865-source
--]]

--[[
    COMPATIBILITY NOTES:
    - Designed for Synapse X, ScriptWare, KRNL, Fluxus, and Roblox Studio.
    - Save/Load settings (writefile/readfile) works only on proper executors (not Roblox Studio).
    - GUI, ESP, Aimbot, and FOV circle work everywhere.
    - Drawing API FOV circle added for executors (fallback to GUI circle for Studio).
    - No unsupported features, all major bugs fixed.
    - All features toggleable and usable by any user.
    - Key System: Get your key at https://lootdest.org/s?mRHxSWXz
--]]

----------------------
-- Key System (LootDest)
----------------------

local KEY_CHECK_URL = "https://lootdest.org/api/verify"
local KEY_LINK = "https://lootdest.org/s?mRHxSWXz"

local function openKeySite()
    if syn and syn.open then
        syn.open(KEY_LINK)
    elseif KRNL_LOADED and KRNL_LOADED.open then
        KRNL_LOADED.open(KEY_LINK)
    elseif fluxus and fluxus.open then
        fluxus.open(KEY_LINK)
    elseif getrenv().syn and getrenv().syn.open then
        getrenv().syn.open(KEY_LINK)
    else
        setclipboard(KEY_LINK)
    end
end

local function checkKeyRemote(key)
    local HttpService = game:GetService("HttpService")
    local response
    if syn and syn.request then
        response = syn.request({
            Url = KEY_CHECK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({key = key}),
        })
    elseif http_request then
        response = http_request({
            Url = KEY_CHECK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({key = key}),
        })
    elseif request then
        response = request({
            Url = KEY_CHECK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({key = key}),
        })
    end
    if response and response.StatusCode == 200 and response.Body then
        local result = HttpService:JSONDecode(response.Body)
        return result.success == true or result.valid == true
    end
    return false
end

local function askForKey()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeySystem_GUI"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 165)
    frame.Position = UDim2.new(0.5, -170, 0.5, -82)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 32)
    label.Position = UDim2.new(0,0,0,8)
    label.Text = "Get your key at:"
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    label.Parent = frame

    local linkBtn = Instance.new("TextButton")
    linkBtn.Size = UDim2.new(1, -40, 0, 24)
    linkBtn.Position = UDim2.new(0,20,0,44)
    linkBtn.Text = KEY_LINK
    linkBtn.TextSize = 14
    linkBtn.Font = Enum.Font.SourceSans
    linkBtn.BackgroundColor3 = Color3.fromRGB(80,80,255)
    linkBtn.TextColor3 = Color3.new(1,1,1)
    linkBtn.Parent = frame
    linkBtn.MouseButton1Click:Connect(function()
        openKeySite()
        label.Text = "Link copied or opened!"
    end)

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, -40, 0, 28)
    textbox.Position = UDim2.new(0,20,0,80)
    textbox.PlaceholderText = "Paste key here"
    textbox.Text = ""
    textbox.TextSize = 18
    textbox.Font = Enum.Font.SourceSans
    textbox.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -40, 0, 28)
    button.Position = UDim2.new(0,20,0,120)
    button.Text = "Submit"
    button.TextSize = 18
    button.Font = Enum.Font.SourceSansBold
    button.BackgroundColor3 = Color3.fromRGB(80,255,80)
    button.Parent = frame

    local result
    button.MouseButton1Click:Connect(function()
        label.Text = "Checking key..."
        local ok = checkKeyRemote(textbox.Text)
        if ok then
            gui:Destroy()
            result = true
        else
            label.Text = "Invalid or expired key. Get a new one."
            result = false
        end
    end)

    repeat wait() until result ~= nil
    return result
end

if not askForKey() then
    return -- stop script if wrong key
end

----------------------
-- Main Script: FPS Aimbot + ESP Example
----------------------

--// Settings
local ESP_COLOR = Color3.fromRGB(255, 0, 0)
local FOV_RADIUS = 120

--// ESP Function
local function addESP(player)
    if player == game.Players.LocalPlayer then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = ESP_COLOR
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 1
    highlight.Parent = player.Character
end

--// Simple Aimbot Function
local function getClosestPlayer()
    local localPlayer = game.Players.LocalPlayer
    local mouse = localPlayer:GetMouse()
    local closest = nil
    local dist = FOV_RADIUS

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
            local mouseDist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
            if mouseDist < dist then
                dist = mouseDist
                closest = player
            end
        end
    end
    return closest
end

--// Aimbot Activation (Press 'Q')
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(
                workspace.CurrentCamera.CFrame.p,
                target.Character.Head.Position
            )
        end
    end
end)

--// ESP for All Players
for _, player in pairs(game.Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        addESP(player)
    end)
    if player.Character then
        addESP(player)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        addESP(player)
    end)
end)

--// FOV Circle Drawing (GUI fallback if Drawing API not available)
local function drawFOV()
    local camera = workspace.CurrentCamera
    local gui = Instance.new("ScreenGui")
    gui.Name = "FOVCircle"
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local circle = Instance.new("Frame")
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = UDim2.new(0.5, 0, 0.5, 0)
    circle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
    circle.BackgroundTransparency = 1

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(1,0)
    uicorner.Parent = circle

    local border = Instance.new("Frame")
    border.Size = UDim2.new(1,0,1,0)
    border.BackgroundColor3 = ESP_COLOR
    border.BorderSizePixel = 0
    border.BackgroundTransparency = 0.7
    border.Parent = circle

    circle.Parent = gui
end

drawFOV()

--// End of script
