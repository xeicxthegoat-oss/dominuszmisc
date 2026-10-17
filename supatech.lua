-- filename:
-- version: lua51
-- line: [0, 0] id: 0
local r0_0 = game:GetService("Players")
local r1_0 = game:GetService("TweenService")
local r2_0 = game:GetService("UserInputService")
local r3_0 = game:GetService("RunService")
local r4_0 = r0_0.LocalPlayer
local r5_0 = nil
local r6_0 = nil
local r7_0 = nil
local r8_0 = 0
local r9_0 = 0.3
local r10_0 = true
local r11_0 = false
local r12_0 = 4
local r13_0 = "https://discord.gg/RsxcaHhRqb"
local function r14_0()
  -- line: [0, 0] id: 15
  local r1_15 = 20
  if not r7_0 then
    return nil
  end
  local r0_15 = nil       -- notice: implicit variable refs by block#[12]
  for r5_15, r6_15 in pairs(workspace:GetDescendants()) do
    if r6_15:IsA("Model") and r6_15:FindFirstChild("HumanoidRootPart") and r6_15 ~=
r5_0 then
       local r7_15, r8_15 = pcall(function()
          -- line: [0, 0] id: 16
          return (r7_0.Position - r6_15.HumanoidRootPart.Position).Magnitude
       end)
       if r7_15 and r8_15 and r8_15 < r1_15 then
          r1_15 = r8_15
          r0_15 = r6_15
       end
    end
    -- close: r5_15
  end
  return r0_15
end
local function r15_0()
  -- line: [0, 0] id: 42
  pcall(function()
    -- line: [0, 0] id: 45
    local r0_45 = {
       [1] = {
          Dash = Enum.KeyCode.W,
          Key = Enum.KeyCode.Q,
          Goal = "KeyPress",
       },
    }
    if r5_0 and r5_0:FindFirstChild("Communicate") then
       r5_0.Communicate:FireServer(unpack(r0_45))
    end
  end)
  local function r0_42(r0_44, r1_44)
    -- line: [0, 0] id: 44
    for r5_44, r6_44 in pairs(getnilinstances()) do
       if r6_44.ClassName == r1_44 and r6_44.Name == r0_44 then
          return r6_44
       end
    end
  end
  pcall(function()
    -- line: [0, 0] id: 43
    local r0_43 = {
       [1] = {
          Goal = "delete bv",
          BV = r0_42("moveme", "BodyVelocity"),
       },
    }
    if r5_0 and r5_0:FindFirstChild("Communicate") then
       r5_0.Communicate:FireServer(unpack(r0_43))
    end
  end)
end
local function r16_0()
  -- line: [0, 0] id: 17
  if not r5_0 or not r6_0 or not r7_0 then
    return
  end
  local r0_17 = r14_0()
  if not r0_17 then
    return
  end
  local r1_17 = r0_17:FindFirstChild("HumanoidRootPart")
  if not r1_17 then
    return
  end
  local r2_17 = {}
  pcall(function()
    -- line: [0, 0] id: 35
    r2_17.WalkSpeed = r6_0.WalkSpeed
    r2_17.JumpPower = r6_0.JumpPower
    r2_17.PlatformStand = r6_0.PlatformStand
    if r6_0:GetAttribute("AutoRotate") == nil then
       pcall(function()
          -- line: [0, 0] id: 36
          r2_17.AutoRotate = r6_0.AutoRotate
       end)
    else
       r2_17.AutoRotate = r6_0.AutoRotate
    end
  end)
  local r3_17 = nil
  local function r5_17()
    -- line: [0, 0] id: 31
    if r3_17 and r3_17.Disconnect then
       pcall(function()
          -- line: [0, 0] id: 34
          r3_17:Disconnect()
       end)
    end
    pcall(function()
       -- line: [0, 0] id: 32
       if r6_0 then
          r6_0.WalkSpeed = r2_17.WalkSpeed or 16
          r6_0.JumpPower = r2_17.JumpPower or 50
         r6_0.PlatformStand = r2_17.PlatformStand or false
         if r2_17.AutoRotate ~= nil then
           pcall(function()
              -- line: [0, 0] id: 33
              r6_0.AutoRotate = r2_17.AutoRotate
           end)
         end
      end
      if r7_0 then
         r7_0.Velocity = Vector3.new(0, 0, 0)
         r7_0.RotVelocity = Vector3.new(0, 0, 0)
      end
    end)
  end
  (function()
    -- line: [0, 0] id: 24
    if not r6_0 or not r7_0 or not r5_0 then
      return
    end
    pcall(function()
      -- line: [0, 0] id: 25
      r6_0.WalkSpeed = 0
      r6_0.JumpPower = 0
      r6_0.PlatformStand = true
      pcall(function()
         -- line: [0, 0] id: 26
         r6_0.AutoRotate = false
      end)
      r7_0.Velocity = Vector3.new(0, 0, 0)
      r7_0.RotVelocity = Vector3.new(0, 0, 0)
    end)
    for r3_24, r4_24 in pairs(r5_0:GetDescendants()) do
      local r5_24 = r4_24.ClassName
      if r5_24 == "BodyVelocity" or r5_24 == "BodyPosition" or r5_24 == "BodyGyro"
or r5_24 == "VectorForce" or r5_24 == "AlignPosition" or r5_24 ==
"AlignOrientation" or r5_24 == "LinearVelocity" or r5_24 == "AngularVelocity" then
         pcall(function()
           -- line: [0, 0] id: 27
           r4_24:Destroy()
         end)
      end
      -- close: r3_24
    end
    r3_17 = r3_0.Heartbeat:Connect(function()
      -- line: [0, 0] id: 28
      if r7_0 then
         pcall(function()
           -- line: [0, 0] id: 30
           r7_0.Velocity = Vector3.new(0, 0, 0)
           r7_0.RotVelocity = Vector3.new(0, 0, 0)
         end)
      end
      if r6_0 and r6_0.WalkSpeed then
         pcall(function()
           -- line: [0, 0] id: 29
           r6_0.WalkSpeed = 0
         end)
      end
    end)
  end)()
  pcall(r15_0)
  task.wait(0.2)
  pcall(function()
    -- line: [0, 0] id: 18
    r6_0:ChangeState(Enum.HumanoidStateType.Physics)
  end)
  if r7_0 then
    r7_0.CFrame = r7_0.CFrame * CFrame.Angles(math.rad(60), 0, 0)
  end
  local r6_17 = 0.2
  local r7_17 = tick()
  local r8_17 = nil
  r8_17 = r3_0.Heartbeat:Connect(function()
    -- line: [0, 0] id: 19
    if r6_17 <= tick() - r7_17 then
       if r8_17 and r8_17.Disconnect then
         pcall(function()
            -- line: [0, 0] id: 20
            r8_17:Disconnect()
         end)
       end
       return
    end
    local r1_19, r2_19 = pcall(function()
       -- line: [0, 0] id: 21
       return CFrame.new((r1_17.Position - r1_17.CFrame.LookVector * 0.3)) *
CFrame.Angles(math.rad(60), 0, 0)
    end)
    if r1_19 and r2_19 and r7_0 then
       pcall(function()
         -- line: [0, 0] id: 22
         r7_0.CFrame = r2_19
       end)
    end
  end)
  repeat
    task.wait()
  until r6_17 <= tick() - r7_17
  pcall(function()
    -- line: [0, 0] id: 23
    r6_0:ChangeState(Enum.HumanoidStateType.GettingUp)
  end)
  pcall(r5_17)
end
local r17_0 = Instance.new("ScreenGui")
r17_0.Name = "Merebennie_StickDashGui"
r17_0.ResetOnSpawn = false
r17_0.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
r17_0.IgnoreGuiInset = true
r17_0.DisplayOrder = 9999
r17_0.Parent = r4_0:WaitForChild("PlayerGui")
local r19_0 = Instance.new("TextButton")
r19_0.Name = "StickDashToggle"
r19_0.Size = UDim2.new(0, 140, 0, 25)
r19_0.Position = UDim2.new(0.4, 0, 0.8, 0)
r19_0.Text = "Supa Tech V2: On"
r19_0.Font = Enum.Font.GothamBold
r19_0.TextScaled = true
r19_0.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
r19_0.TextColor3 = Color3.fromRGB(255, 255, 255)
r19_0.TextStrokeTransparency = 1
r19_0.AutoButtonColor = false
r19_0.ZIndex = 9999
r19_0.Parent = r17_0
local r20_0 = Instance.new("UICorner")
r20_0.CornerRadius = UDim.new(0, 8)
r20_0.Parent = r19_0
local r21_0 = Instance.new("Sound")
r21_0.Name = "ButtonClickSound"
r21_0.SoundId = "rbxassetid://6042053626"
r21_0.Volume = 1
r21_0.Looped = false
r21_0.Parent = r19_0
r19_0.MouseButton1Click:Connect(function()
  -- line: [0, 0] id: 1
  pcall(function()
     -- line: [0, 0] id: 2
     r21_0:Play()
  end)
  r19_0:TweenSize(UDim2.new(0, 136, 0, 23), "Out", "Quad", 0.05, true)
  task.wait(0.05)
  r19_0:TweenSize(UDim2.new(0, 140, 0, 25), "Out", "Quad", 0.05, true)
end)
local r22_0 = nil
local r23_0 = nil
local r24_0 = nil
local r25_0 = nil
r19_0.InputBegan:Connect(function(r0_7)
  -- line: [0, 0] id: 7
  if r0_7.UserInputType == Enum.UserInputType.MouseButton1 or r0_7.UserInputType ==
Enum.UserInputType.Touch then
     r22_0 = true
     r24_0 = r0_7.Position
     r25_0 = r19_0.Position
     r0_7.Changed:Connect(function()
       -- line: [0, 0] id: 8
       if r0_7.UserInputState == Enum.UserInputState.End then
          r22_0 = false
       end
     end)
  end
end)
r19_0.InputChanged:Connect(function(r0_12)
  -- line: [0, 0] id: 12
  if r0_12.UserInputType == Enum.UserInputType.MouseMovement or r0_12.UserInputType
== Enum.UserInputType.Touch then
     r23_0 = r0_12
  end
end)
r2_0.InputChanged:Connect(function(r0_14)
  -- line: [0, 0] id: 14
  if r0_14 == r23_0 and r22_0 and r25_0 then
     local r1_14 = r0_14.Position - r24_0
     r19_0.Position = UDim2.new(r25_0.X.Scale, r25_0.X.Offset + r1_14.X,
r25_0.Y.Scale, r25_0.Y.Offset + r1_14.Y)
  end
end)
r19_0.MouseButton1Click:Connect(function()
  -- line: [0, 0] id: 13
  r10_0 = not r10_0
  if r10_0 then
     r19_0.Text = "Supa Tech V2: On"
     r19_0.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
     r19_0.TextColor3 = Color3.fromRGB(255, 255, 255)
  else
     r19_0.Text = "Supa Tech V2: Off"
     r19_0.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
     r19_0.TextColor3 = Color3.fromRGB(255, 255, 255)
  end
end)
local r26_0 = Instance.new("Frame")
r26_0.Name = "CreditFrame"
r26_0.Size = UDim2.new(0, 200, 0, 100)
r26_0.Position = UDim2.new(1, 0, 0.1, 0)
r26_0.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
r26_0.ZIndex = 9999
r26_0.Parent = r17_0
local r27_0 = Instance.new("UICorner")
r27_0.CornerRadius = UDim.new(0, 8)
r27_0.Parent = r26_0
local r28_0 = Instance.new("TextLabel")
r28_0.Size = UDim2.new(1, 0, 0.3, 0)
r28_0.Position = UDim2.new(0, 0, 0, 0)
r28_0.BackgroundTransparency = 1
r28_0.Text = "Made by Merebennie on YouTube"
r28_0.Font = Enum.Font.GothamBold
r28_0.TextColor3 = Color3.fromRGB(255, 255, 255)
r28_0.TextScaled = true
r28_0.TextStrokeTransparency = 1
r28_0.Parent = r26_0
local r29_0 = Instance.new("TextLabel")
r29_0.Size = UDim2.new(1, 0, 0.3, 0)
r29_0.Position = UDim2.new(0, 0, 0.3, 0)
r29_0.BackgroundTransparency = 1
r29_0.Text = r13_0
r29_0.Font = Enum.Font.GothamBold
r29_0.TextColor3 = Color3.fromRGB(255, 255, 255)
r29_0.TextScaled = true
r29_0.TextStrokeTransparency = 1
r29_0.Parent = r26_0
local r30_0 = Instance.new("TextButton")
r30_0.Size = UDim2.new(1, 0, 0.4, 0)
r30_0.Position = UDim2.new(0, 0, 0.6, 0)
r30_0.BackgroundTransparency = 1
r30_0.Text = "Click me to copy"
r30_0.Font = Enum.Font.GothamBold
r30_0.TextColor3 = Color3.fromRGB(255, 255, 255)
r30_0.TextScaled = true
r30_0.TextStrokeTransparency = 1
r30_0.Parent = r26_0
r30_0.MouseButton1Click:Connect(function()
  -- line: [0, 0] id: 38
  if setclipboard then
     setclipboard(r13_0)
  end
  r30_0.Text = "Copied Thanks!"
end)
local r31_0 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
r1_0:Create(r26_0, r31_0, {
  Position = UDim2.new(1, -200, 0.1, 0),
}):Play()
task.delay(4, function()
  -- line: [0, 0] id: 3
  local r0_3 = r1_0:Create(r26_0, r31_0, {
     Position = UDim2.new(1, 0, 0.1, 0),
  })
  r0_3:Play()
  r0_3.Completed:Connect(function()
     -- line: [0, 0] id: 4
     r26_0:Destroy()
  end)
end)
local r33_0 = Instance.new("TextLabel")
r33_0.Name = "CooldownLabel"
r33_0.Size = UDim2.new(0, 120, 0, 30)
r33_0.Position = UDim2.new(0, 10, 1, 0)
r33_0.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
r33_0.BackgroundTransparency = 0.35
r33_0.TextColor3 = Color3.fromRGB(255, 255, 255)
r33_0.Text = "Cooldown: 4"
r33_0.Font = Enum.Font.GothamBold
r33_0.TextScaled = true
r33_0.TextStrokeTransparency = 1
r33_0.Visible = false
r33_0.ZIndex = 9999
r33_0.Parent = r17_0
local r34_0 = Instance.new("UICorner")
r34_0.CornerRadius = UDim.new(0, 8)
r34_0.Parent = r33_0
local r35_0 = {}
local function r36_0()
  -- line: [0, 0] id: 5
  for r3_5, r4_5 in pairs(r35_0) do
     if r4_5 and r4_5.Disconnect then
       pcall(function()
          -- line: [0, 0] id: 6
          r4_5:Disconnect()
       end)
     end
     -- close: r3_5
  end
  r35_0 = {}
end
local function r37_0()
  -- line: [0, 0] id: 9
  if not r10_0 or r11_0 then
     return
  end
  if r9_0 <= tick() - r8_0 then
     r8_0 = tick()
     r11_0 = true
     task.spawn(function()
       -- line: [0, 0] id: 11
       pcall(r16_0)
     end)
    local r0_9 = UDim2.new(0, 10, 1, 0)
    local r1_9 = UDim2.new(0, 10, 1, -40)
    r33_0.Position = r0_9
    r33_0.Visible = true
    r1_0:Create(r33_0, r31_0, {
       Position = r1_9,
    }):Play()
    task.spawn(function()
       -- line: [0, 0] id: 10
       for r3_10 = 4, 1, -1 do
          r33_0.Text = "Cooldown: " .. r3_10
          task.wait(1)
       end
       r11_0 = false
       local r0_10 = r1_0:Create(r33_0, r31_0, {
          Position = r0_9,
       })
       r0_10:Play()
       r0_10.Completed:Wait()
       r33_0.Visible = false
    end)
    -- close: r0_9
  end
end
local function r38_0(r0_37)
  -- line: [0, 0] id: 37
  local r1_37 = r0_37 and r0_37.Animation
  if r1_37 then
    local r2_37 = tostring(r1_37.AnimationId or "")
    if string.find(r2_37, "10503381238", 1, true) then
       task.delay(0.3, r37_0)
       return
    end
    if string.find(r2_37, "13379003796", 1, true) then
       task.delay(0.3, r37_0)
       return
    end
  end
end
local function r39_0(r0_39)
  -- line: [0, 0] id: 39
  r36_0()
  r5_0 = r0_39
  r6_0 = r0_39:WaitForChild("Humanoid")
  r7_0 = r0_39:WaitForChild("HumanoidRootPart")
  local r1_39, r2_39 = pcall(function()
    -- line: [0, 0] id: 40
    return r6_0.AnimationPlayed:Connect(r38_0)
  end)
  if r1_39 and r2_39 then
    table.insert(r35_0, r2_39)
  end
  local r3_39 = r6_0:FindFirstChildOfClass("Animator")
  if r3_39 then
    local r4_39, r5_39 = pcall(function()
       -- line: [0, 0] id: 41
       return r3_39.AnimationPlayed:Connect(r38_0)
    end)
    if r4_39 and r5_39 then
      table.insert(r35_0, r5_39)
    end
  end
end
r4_0.CharacterAdded:Connect(r39_0)
if r4_0.Character then
  r39_0(r4_0.Character)
end

