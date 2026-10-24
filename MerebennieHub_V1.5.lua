--===================================================================================--
--               MEREBENNIE HUB V1.5 - THE STRONGEST BATTLEGROUNDS                   --
--                 COMPREHENSIVE ENTERPRISE-GRADE COMBAT MODULE                      --
--===================================================================================--

--===================================================================================--
-- LAYER 0: SERVICE INITIALIZATION AND SYSTEM KERNEL
--===================================================================================--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Ensure multi-execution protection layer
if _G.MerebennieHubLoaded then
    print("[MEREBENNIE KERNEL]: Core instance already operational. Halting redundant thread loops.")
    return
end
_G.MerebennieHubLoaded = true

--===================================================================================--
-- LAYER 1: CONFIGURATION INFRASTRUCTURE & STATE RETRIEVAL MATRIX
--===================================================================================--
local SystemRegistry = {
    Storage = {
        FileName = "MerebennieHub_TSB_V15.json",
        DefaultState = {
            FloaterTech = false,
            FloatHeight = 15,
            SupaTechV2 = false,
            InstantTwisted = false,
            SupaV3 = false,
            SupaV3Delay = 150,
            SideDashV3 = false,
            LixTech = false,
            BackDashCancel = false,
            BoomyTwisted = false,
            SideDashAssistV2 = false,
            AssistRange = 35,
            AutoBlock360 = false,
            GuiVisible = true,
            PrimaryColor = {168, 50, 247},
            SecondaryColor = {15, 12, 22},
            AccentColor = {245, 235, 255}
        },
        ActiveCache = {}
    },
    Signals = {},
    GarbageCollection = {},
    TargetingEngine = {
        ActiveTarget = nil,
        LockTimestamp = 0,
        ExpirationPeriod = 5.0
    }
}

-- Deep copy table generator
local function InitializeDeepCopy(sourceTable)
    local targetTable = {}
    for key, value in pairs(sourceTable) do
        if type(value) == "table" then
            targetTable[key] = InitializeDeepCopy(value)
        else
            targetTable[key] = value
        end
    end
    return targetTable
end

SystemRegistry.Storage.ActiveCache = InitializeDeepCopy(SystemRegistry.Storage.DefaultState)

local function SaveSystemConfiguration()
    if writefile then
        local success, serializedData = pcall(function()
            return HttpService:JSONEncode(SystemRegistry.Storage.ActiveCache)
        end)
        if success and serializedData then
            pcall(function()
                writefile(SystemRegistry.Storage.FileName, serializedData)
            end)
        end
    end
end

local function LoadSystemConfiguration()
    if readfile and isfile and isfile(SystemRegistry.Storage.FileName) then
        local success, fileContents = pcall(function()
            return readfile(SystemRegistry.Storage.FileName)
        end)
        if success and fileContents then
            local parsingSuccess, parsedTable = pcall(function()
                return HttpService:JSONDecode(fileContents)
            end)
            if parsingSuccess and type(parsedTable) == "table" then
                for optionKey, valueData in pairs(parsedTable) do
                    if SystemRegistry.Storage.ActiveCache[optionKey] ~= nil then
                        SystemRegistry.Storage.ActiveCache[optionKey] = valueData
                    end
                end
            end
        end
    end
end
LoadSystemConfiguration()

--===================================================================================--
-- LAYER 2: SYSTEM CRITICAL TOUCHGUI INTERACTION PROTECTION
--===================================================================================--
local function ProcessTouchGuiValidation()
    local executionStatus, executionError = pcall(function()
        local touchGuiInstance = PlayerGui:FindFirstChild("TouchGui")
        if touchGuiInstance then
            if touchGuiInstance:IsA("ScreenGui") and not touchGuiInstance.Enabled then
                touchGuiInstance.Enabled = true
            end
        end
    end)
    if not executionStatus and executionError then
        warn("[MEREBENNIE CRITICAL ERROR]: TouchGui validation fault reported: " .. tostring(executionError))
    end
end

task.spawn(function()
    while _G.MerebennieHubLoaded do
        task.wait(0.5)
        ProcessTouchGuiValidation()
    end
end)

--===================================================================================--
-- LAYER 3: CORE RAYCASTING AND VECTOR MATHEMATICS ENGINE
--===================================================================================--
local AdvancedMathModule = {}

function AdvancedMathModule.GetFlatVectorDistance(vectorA, vectorB)
    return math.sqrt((vectorA.X - vectorB.X)^2 + (vectorA.Z - vectorB.Z)^2)
end

function AdvancedMathModule.ComputeOrbitCFrame(pivotPoint, referenceCFrame, lateralOffset, depthOffset)
    local lateralStep = referenceCFrame.RightVector * lateralOffset
    local depthStep = referenceCFrame.LookVector * depthOffset
    local finalComputedPosition = referenceCFrame.Position + lateralStep + depthStep
    return CFrame.new(finalComputedPosition, Vector3.new(pivotPoint.X, referenceCFrame.Position.Y, pivotPoint.Z))
end

function AdvancedMathModule.ScanTerrainClearance(characterModel)
    local rootPart = characterModel:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local nativeRaycastParams = RaycastParams.new()
    nativeRaycastParams.FilterDescendantsInstances = {characterModel}
    nativeRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    nativeRaycastParams.IgnoreWater = true
    
    local calculationResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -100, 0), nativeRaycastParams)
    return calculationResult
end

--===================================================================================--
-- LAYER 4: TARGETING LOGIC AND PROXIMITY INDEX ARRAYS
--===================================================================================--
local function FetchOptimalProximityTarget(maximumStudRange)
    local userCharacter = LocalPlayer.Character
    local userRootPart = userCharacter and userCharacter:FindFirstChild("HumanoidRootPart")
    if not userRootPart then return nil end
    
    local verifiedTarget = nil
    local minimumDistanceFound = maximumStudRange
    
    local systemPlayersList = Players:GetPlayers()
    for index = 1, #systemPlayersList do
        local targetPlayer = systemPlayersList[index]
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local enemyRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local computedDistance = (userRootPart.Position - enemyRoot.Position).Magnitude
                if computedDistance < minimumDistanceFound then
                    minimumDistanceFound = computedDistance
                    verifiedTarget = targetPlayer.Character
                end
            end
        end
    end
    return verifiedTarget
end

local function RegisterCombatHitboxSignature(instantiatedChild)
    local validationString = string.lower(instantiatedChild.Name)
    if validationString:find("hit") or validationString:find("attack") or validationString:find("combo") or validationString:find("action") or validationString:find("swing") then
        local foundCombatant = FetchOptimalProximityTarget(16)
        if foundCombatant then
            SystemRegistry.TargetingEngine.ActiveTarget = foundCombatant
            SystemRegistry.TargetingEngine.LockTimestamp = tick()
        end
    end
end

local function AttachCombatListenersToCharacter(activeCharacter)
    if not activeCharacter then return end
    
    local childAddedConnection = activeCharacter.ChildAdded:Connect(function(newObject)
        RegisterCombatHitboxSignature(newObject)
    end)
    table.insert(SystemRegistry.Signals, childAddedConnection)
end

SystemRegistry.Hooks = {
    InitCharacterHooks = function()
        LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            task.wait(0.5)
            AttachCombatListenersToCharacter(newCharacter)
        end)
        AttachCombatListenersToCharacter(LocalPlayer.Character)
    end
}
SystemRegistry.Hooks.InitCharacterHooks()

--===================================================================================--
-- LAYER 5: CHARACTER ORIENTATION LOCK CONTROLLERS
--===================================================================================--
local function FaceCharacterTowardsTargetCoordinates(targetVector3)
    local sourceCharacter = LocalPlayer.Character
    local sourceRootPart = sourceCharacter and sourceCharacter:FindFirstChild("HumanoidRootPart")
    if sourceRootPart then
        local planarTargetCoordinates = Vector3.new(targetVector3.X, sourceRootPart.Position.Y, targetVector3.Z)
        if (sourceRootPart.Position - planarTargetCoordinates).Magnitude > 0.05 then
            sourceRootPart.CFrame = CFrame.new(sourceRootPart.Position, planarTargetCoordinates)
        end
    end
end

--===================================================================================--
-- LAYER 6: GRAPHICAL USER INTERFACE ARCHITECTURE ("MEREBENNIE HUB V1.5")
--===================================================================================--
local UserInterfaceEngine = {}
function UserInterfaceEngine.CreateCoreCanvas()
local screenGuiObject = Instance.new("ScreenGui")
screenGuiObject.Name = "MerebennieHub_CanvasV15"
screenGuiObject.ResetOnSpawn = false
screenGuiObject.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
screenGuiObject.Parent = PlayerGui
end)
return screenGuiObject
end
local CoreCanvas = UserInterfaceEngine.CreateCoreCanvas()
local function BuildUserInterfaceLayout()
local cachedColors = SystemRegistry.Storage.ActiveCache
local containerFrame = Instance.new("Frame")
containerFrame.Name = "MerebennieMainFrame"
containerFrame.Size = UDim2.new(0, 540, 0, 370)
containerFrame.Position = UDim2.new(0.5, -270, 0.5, -185)
containerFrame.BackgroundColor3 = Color3.fromRGB(cachedColors.SecondaryColor[1], cachedColors.SecondaryColor[2], cachedColors.SecondaryColor[3])
containerFrame.BorderSizePixel = 0
containerFrame.Active = true
containerFrame.Draggable = true
containerFrame.Visible = cachedColors.GuiVisible
containerFrame.Parent = CoreCanvas
local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 10)
containerCorner.Parent = containerFrame
local neonBorderStroke = Instance.new("UIStroke")
neonBorderStroke.Thickness = 2.5
neonBorderStroke.Color = Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3])
neonBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
neonBorderStroke.Parent = containerFrame
local applicationTitle = Instance.new("TextLabel")
applicationTitle.Size = UDim2.new(1, -20, 0, 50)
applicationTitle.Position = UDim2.new(0, 15, 0, 0)
applicationTitle.BackgroundTransparency = 1
applicationTitle.Text = "Merebennie Hub V1.5"
applicationTitle.TextColor3 = Color3.fromRGB(cachedColors.AccentColor[1], cachedColors.AccentColor[2], cachedColors.AccentColor[3])
applicationTitle.Font = Enum.Font.GothamBold
applicationTitle.TextSize = 18
applicationTitle.TextXAlignment = Enum.TextXAlignment.Left
applicationTitle.Parent = containerFrame
local dynamicTabList = Instance.new("Frame")
dynamicTabList.Size = UDim2.new(0, 140, 1, -65)
dynamicTabList.Position = UDim2.new(0, 12, 0, 52)
dynamicTabList.BackgroundColor3 = Color3.fromRGB(22, 17, 30)
dynamicTabList.BorderSizePixel = 0
dynamicTabList.Parent = containerFrame
local tabListCorner = Instance.new("UICorner")
tabListCorner.CornerRadius = UDim.new(0, 8)
tabListCorner.Parent = dynamicTabList
local primaryScrollContainer = Instance.new("ScrollingFrame")
primaryScrollContainer.Size = UDim2.new(1, -175, 1, -65)
primaryScrollContainer.Position = UDim2.new(0, 163, 0, 52)
primaryScrollContainer.BackgroundTransparency = 1
primaryScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 750)
primaryScrollContainer.ScrollBarThickness = 5
primaryScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3])
primaryScrollContainer.Parent = containerFrame
local contentLayoutManager = Instance.new("UIListLayout")
contentLayoutManager.Padding = UDim.new(0, 8)
contentLayoutManager.SortOrder = Enum.SortOrder.LayoutOrder
contentLayoutManager.Parent = primaryScrollContainer
local internalControlBuilders = {}
function internalControlBuilders.InjectToggleElement(displayName, cacheKey)
local frameLayout = Instance.new("Frame")
frameLayout.Size = UDim2.new(1, -10, 0, 45)
frameLayout.BackgroundColor3 = Color3.fromRGB(26, 20, 36)
frameLayout.BorderSizePixel = 0
frameLayout.Parent = primaryScrollContainer
local cornerLayout = Instance.new("UICorner")
cornerLayout.CornerRadius = UDim.new(0, 6)
cornerLayout.Parent = frameLayout
local labelLayout = Instance.new("TextLabel")
labelLayout.Size = UDim2.new(1, -70, 1, 0)
labelLayout.Position = UDim2.new(0, 12, 0, 0)
labelLayout.BackgroundTransparency = 1
labelLayout.Text = displayName
labelLayout.TextColor3 = Color3.fromRGB(225, 215, 240)
labelLayout.Font = Enum.Font.GothamSemibold
labelLayout.TextSize = 13
labelLayout.TextXAlignment = Enum.TextXAlignment.Left
labelLayout.Parent = frameLayout
local interactiveButton = Instance.new("TextButton")
interactiveButton.Size = UDim2.new(0, 52, 0, 26)
interactiveButton.Position = UDim2.new(1, -64, 0.5, -13)
interactiveButton.BackgroundColor3 = SystemRegistry.Storage.ActiveCache[cacheKey] and Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3]) or Color3.fromRGB(46, 40, 60)
interactiveButton.Text = ""
interactiveButton.Parent = frameLayout
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = interactiveButton
interactiveButton.MouseButton1Click:Connect(function()
SystemRegistry.Storage.ActiveCache[cacheKey] = not SystemRegistry.Storage.ActiveCache[cacheKey]
SaveSystemConfiguration()
TweenService:Create(interactiveButton, TweenInfo.new(0.2), {
BackgroundColor3 = SystemRegistry.Storage.ActiveCache[cacheKey] and Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3]) or Color3.fromRGB(46, 40, 60)
}):Play()
end)
end
function internalControlBuilders.InjectSliderElement(displayName, cacheKey, minVal, maxVal, descriptorUnit)
local frameLayout = Instance.new("Frame")
frameLayout.Size = UDim2.new(1, -10, 0, 56)
frameLayout.BackgroundColor3 = Color3.fromRGB(26, 20, 36)
frameLayout.BorderSizePixel = 0
frameLayout.Parent = primaryScrollContainer
local cornerLayout = Instance.new("UICorner")
cornerLayout.CornerRadius = UDim.new(0, 6)
cornerLayout.Parent = frameLayout
local labelLayout = Instance.new("TextLabel")
labelLayout.Size = UDim2.new(0.65, 0, 0, 26)
labelLayout.Position = UDim2.new(0, 12, 0, 2)
labelLayout.BackgroundTransparency = 1
labelLayout.Text = displayName
labelLayout.TextColor3 = Color3.fromRGB(225, 215, 240)
labelLayout.Font = Enum.Font.GothamSemibold
labelLayout.TextSize = 13
labelLayout.TextXAlignment = Enum.TextXAlignment.Left
labelLayout.Parent = frameLayout
local displayValueLabel = Instance.new("TextLabel")
displayValueLabel.Size = UDim2.new(0.3, 0, 0, 26)
displayValueLabel.Position = UDim2.new(0.65, 0, 0, 2)
displayValueLabel.BackgroundTransparency = 1
displayValueLabel.Text = tostring(SystemRegistry.Storage.ActiveCache[cacheKey]) .. descriptorUnit
displayValueLabel.TextColor3 = Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3])
displayValueLabel.Font = Enum.Font.GothamBold
displayValueLabel.TextSize = 13
displayValueLabel.TextXAlignment = Enum.TextXAlignment.Right
displayValueLabel.Parent = frameLayout
local sliderTrack = Instance.new("TextButton")
sliderTrack.Size = UDim2.new(1, -24, 0, 6)
sliderTrack.Position = UDim2.new(0, 12, 0, 38)
sliderTrack.BackgroundColor3 = Color3.fromRGB(54, 46, 70)
sliderTrack.Text = ""
sliderTrack.Parent = frameLayout
local currentPercentage = math.clamp((SystemRegistry.Storage.ActiveCache[cacheKey] - minVal) / (maxVal - minVal), 0, 1)
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(currentPercentage, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3])
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack
local isUserDraggingSlider = false
local function ProcessSliderAdjustment(inputObject)
local boundedPercentage = math.clamp((inputObject.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
sliderFill.Size = UDim2.new(boundedPercentage, 0, 1, 0)
local calculatedInteger = math.floor(minVal + (boundedPercentage * (maxVal - minVal)))
displayValueLabel.Text = tostring(calculatedInteger) .. descriptorUnit
SystemRegistry.Storage.ActiveCache[cacheKey] = calculatedInteger
SaveSystemConfiguration()
end
sliderTrack.InputBegan:Connect(function(inputObject)
if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
isUserDraggingSlider = true
ProcessSliderAdjustment(inputObject)
end
end)
UserInputService.InputChanged:Connect(function(inputObject)
if isUserDraggingSlider and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
ProcessSliderAdjustment(inputObject)
end
end)
UserInputService.InputEnded:Connect(function(inputObject)
if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
isUserDraggingSlider = false
end
end)
end
local combatTabButton = Instance.new("TextButton")
combatTabButton.Size = UDim2.new(1, -12, 0, 40)
combatTabButton.Position = UDim2.new(0, 6, 0, 6)
combatTabButton.BackgroundColor3 = Color3.fromRGB(38, 30, 54)
combatTabButton.Text = "Combat System"
combatTabButton.TextColor3 = Color3.fromRGB(245, 240, 255)
combatTabButton.Font = Enum.Font.GothamBold
combatTabButton.TextSize = 13
combatTabButton.Parent = dynamicTabList
local tabButtonCorner = Instance.new("UICorner")
tabButtonCorner.CornerRadius = UDim.new(0, 5)
tabButtonCorner.Parent = combatTabButton
-- Instantiate interface toggles and continuous adjustments
internalControlBuilders.InjectToggleElement("Complex Floater Tech", "FloaterTech")
internalControlBuilders.InjectSliderElement("Float Velocity Cutoff", "FloatHeight", 5, 40, " Vel")
internalControlBuilders.InjectToggleElement("Supa Tech V2 (Combo)", "SupaTechV2")
internalControlBuilders.InjectToggleElement("Instant Twisted", "InstantTwisted")
internalControlBuilders.InjectToggleElement("Supa V3 Extended", "SupaV3")
internalControlBuilders.InjectSliderElement("Supa V3 Frame Delay", "SupaV3Delay", 50, 400, "ms")
internalControlBuilders.InjectToggleElement("Side Dash V3", "SideDashV3")
internalControlBuilders.InjectToggleElement("Lix Tech [REWORKED]", "LixTech")
internalControlBuilders.InjectToggleElement("Back Dash Cancel", "BackDashCancel")
internalControlBuilders.InjectToggleElement("BOOMY Instant Twisted", "BoomyTwisted")
internalControlBuilders.InjectToggleElement("Automated Side Dash Assist V2", "SideDashAssistV2")
internalControlBuilders.InjectSliderElement("Assist Scan Range", "AssistRange", 10, 100, " Studs")
internalControlBuilders.InjectToggleElement("360-Degree Auto Block", "AutoBlock360")
local floatMenuToggle = Instance.new("TextButton")
floatMenuToggle.Size = UDim2.new(0, 80, 0, 35)
floatMenuToggle.Position = UDim2.new(0, 15, 0, 15)
floatMenuToggle.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
floatMenuToggle.Text = "Merebennie"
floatMenuToggle.TextColor3 = Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3])
floatMenuToggle.Font = Enum.Font.GothamBold
floatMenuToggle.TextSize = 11
floatMenuToggle.Parent = CoreCanvas
local toggleButtonCorner = Instance.new("UICorner")
toggleButtonCorner.CornerRadius = UDim.new(0, 6)
toggleButtonCorner.Parent = floatMenuToggle
local toggleButtonStroke = Instance.new("UIStroke")
toggleButtonStroke.Thickness = 1.5
toggleButtonStroke.Color = Color3.fromRGB(cachedColors.PrimaryColor[1], cachedColors.PrimaryColor[2], cachedColors.PrimaryColor[3])
toggleButtonStroke.Parent = floatMenuToggle
floatMenuToggle.MouseButton1Click:Connect(function()
SystemRegistry.Storage.ActiveCache.GuiVisible = not SystemRegistry.Storage.ActiveCache.GuiVisible
containerFrame.Visible = SystemRegistry.Storage.ActiveCache.GuiVisible
SaveSystemConfiguration()
end)
end
BuildUserInterfaceLayout()
--===================================================================================--
-- LAYER 7: AUTOMATED REAL COMBAT EXECUTION LOOPS ("TECHS")
--===================================================================================--
-- Execution loop 1: Advanced Physics Automation (Complex Floater Tech Engine)
RunService.Heartbeat:Connect(function()
if not SystemRegistry.Storage.ActiveCache.FloaterTech then return end
local nativeCharacter = LocalPlayer.Character
local coreRootPart = nativeCharacter and nativeCharacter:FindFirstChild("HumanoidRootPart")
local coreHumanoid = nativeCharacter and nativeCharacter:FindFirstChild("Humanoid")
if not coreRootPart or not coreHumanoid then return end
local currentVelocityVector = coreRootPart.AssemblyLinearVelocity
local activeState = coreHumanoid:GetState()
if activeState == Enum.HumanoidStateType.FreeFall or currentVelocityVector.Y < -12 then
local targetGroundRaycast = AdvancedMathModule.ScanTerrainClearance(nativeCharacter)
if targetGroundRaycast and targetGroundRaycast.Distance <= 7 then
-- Bounce Suppression mechanism activated
local configuredVelocityCutoff = SystemRegistry.Storage.ActiveCache.FloatHeight
coreRootPart.AssemblyLinearVelocity = Vector3.new(currentVelocityVector.X, math.clamp(currentVelocityVector.Y, -1, configuredVelocityCutoff), currentVelocityVector.Z)
local internalBodyVelocity = coreRootPart:FindFirstChild("MerebennieVForce") or Instance.new("BodyVelocity")
internalBodyVelocity.Name = "MerebennieVForce"
internalBodyVelocity.MaxForce = Vector3.new(0, 16000, 0)
internalBodyVelocity.Velocity = Vector3.new(0, configuredVelocityCutoff * 0.45, 0)
internalBodyVelocity.Parent = coreRootPart
end
else
local existingForceObject = coreRootPart:FindFirstChild("MerebennieVForce")
if existingForceObject then
existingForceObject:Destroy()
end
end
end)
-- Execution loop 2: Sequence Automation Matrix
RunService.PreSimulation:Connect(function()
local executionCharacter = LocalPlayer.Character
local executionRootPart = executionCharacter and executionCharacter:FindFirstChild("HumanoidRootPart")
local executionHumanoid = executionCharacter and executionCharacter:FindFirstChild("Humanoid")
if not executionRootPart or not executionHumanoid then return end
local activeCacheReference = SystemRegistry.Storage.ActiveCache
-- Enforce absolute 5-second lifespan on target acquisition link cache
if SystemRegistry.TargetingEngine.ActiveTarget and (tick() - SystemRegistry.TargetingEngine.LockTimestamp > SystemRegistry.TargetingEngine.ExpirationPeriod) then
SystemRegistry.TargetingEngine.ActiveTarget = nil
end
-- Supa Tech V2 & V3 Smart Automated Combo Extender Engine
local currentTargetObject = SystemRegistry.TargetingEngine.ActiveTarget
if (activeCacheReference.SupaTechV2 or activeCacheReference.SupaV3) and currentTargetObject and currentTargetObject:FindFirstChild("HumanoidRootPart") then
local targetRootPart = currentTargetObject.HumanoidRootPart
local structuralDistance = (executionRootPart.Position - targetRootPart.Position).Magnitude
if executionCharacter:FindFirstChild("Attacking") and structuralDistance <= 18 then
FaceCharacterTowardsTargetCoordinates(targetRootPart.Position)
if activeCacheReference.SupaV3 then
task.wait(activeCacheReference.SupaV3Delay / 1000)
end
-- Frame execution combo tracking displacement math
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(0, 0, 1.4)
task.wait(0.01)
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(0, 0, -6.5)
SystemRegistry.TargetingEngine.ActiveTarget = nil
end
end
-- Instant Twisted & BOOMY Variant Mechanics Engine
if (activeCacheReference.InstantTwisted or activeCacheReference.BoomyTwisted) and executionCharacter:FindFirstChild("Attacking") then
local nearestThreatModel = FetchOptimalProximityTarget(15)
if nearestThreatModel and nearestThreatModel:FindFirstChild("HumanoidRootPart") then
local enemyCoordinates = nearestThreatModel.HumanoidRootPart.Position
if activeCacheReference.BoomyTwisted then
executionRootPart.CFrame = CFrame.new(executionRootPart.Position, Vector3.new(enemyCoordinates.X, executionRootPart.Position.Y, enemyCoordinates.Z)) * CFrame.Angles(0, math.rad(115), 0)
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(0, 0, -5)
else
executionRootPart.CFrame = CFrame.new(executionRootPart.Position, Vector3.new(enemyCoordinates.X, executionRootPart.Position.Y, enemyCoordinates.Z)) * CFrame.Angles(0, math.rad(90), 0)
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(0, 0, -5)
end
end
end
-- Side Dash V3 Engine
if activeCacheReference.SideDashV3 and executionCharacter:FindFirstChild("Dashing") then
local dynamicThreatModel = FetchOptimalProximityTarget(25)
if dynamicThreatModel and dynamicThreatModel:FindFirstChild("HumanoidRootPart") then
FaceCharacterTowardsTargetCoordinates(dynamicThreatModel.HumanoidRootPart.Position)
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(7, 0, 0)
end
end
-- Lix Tech Animation Reworked Engine
if activeCacheReference.LixTech and executionCharacter:FindFirstChild("Attacking") then
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(0.5, 0, -0.5)
RunService.RenderStepped:Wait()
executionRootPart.CFrame = executionRootPart.CFrame * CFrame.new(-0.5, 0, 0.5)
end
-- Back Dash Cancel Override Engine
if activeCacheReference.BackDashCancel and executionCharacter:FindFirstChild("BackDashing") then
pcall(function()
executionCharacter.BackDashing:Destroy()
end)
executionRootPart.AssemblyLinearVelocity = executionRootPart.CFrame.LookVector * 52
end
-- Automated Side Dash Assist V2 Module
if activeCacheReference.SideDashAssistV2 then
local prioritizedEnemyCharacter = FetchOptimalProximityTarget(activeCacheReference.AssistRange)
if prioritizedEnemyCharacter and prioritizedEnemyCharacter:FindFirstChild("HumanoidRootPart") then
local enemyRootCoordinates = prioritizedEnemyCharacter.HumanoidRootPart.Position
FaceCharacterTowardsTargetCoordinates(enemyRootCoordinates)
local targetOrbitCFrame = executionRootPart.CFrame * CFrame.new(8, 0, -4)
executionRootPart.CFrame = executionRootPart.CFrame:Keep(0.16)
executionRootPart.CFrame = executionRootPart.CFrame:Lerp(CFrame.new(targetOrbitCFrame.Position, Vector3.new(enemyRootCoordinates.X, executionRootPart.Position.Y, enemyRootCoordinates.Z)), 0.16)
end
end
end)
--===================================================================================--
-- LAYER 8: 360-DEGREE RADIAL DETECTOR & AUTO BLOCK MECHANIC
--===================================================================================--
RunService.Stepped:Connect(function()
if not SystemRegistry.Storage.ActiveCache.AutoBlock360 then return end
local checkingCharacter = LocalPlayer.Character
local checkingRootPart = checkingCharacter and checkingCharacter:FindFirstChild("HumanoidRootPart")
if not checkingRootPart then return end
local systemPlayers = Players:GetPlayers()
for activeIndex = 1, #systemPlayers do
local externalPlayer = systemPlayers[activeIndex]
if externalPlayer ~= LocalPlayer and externalPlayer.Character then
local opponentCharacter = externalPlayer.Character
local opponentRootPart = opponentCharacter:FindFirstChild("HumanoidRootPart")
if opponentRootPart then
if opponentCharacter:FindFirstChild("Attacking") or opponentCharacter:FindFirstChild("ForwardV") or opponentCharacter:FindFirstChild("DashVelocity") then
local structuralRadiusDistance = (checkingRootPart.Position - opponentRootPart.Position).Magnitude
if structuralRadiusDistance <= 16.5 then
local activeGuardTool = checkingCharacter:FindFirstChild("Block") or checkingCharacter:FindFirstChild("Guard")
if activeGuardTool and activeGuardTool:IsA("Tool") then
activeGuardTool:Activate()
end
end
end
end
end
end
end)
print("[MEREBENNIE HUB]: Fully integrated modular code logic engine initiated successfully.")
