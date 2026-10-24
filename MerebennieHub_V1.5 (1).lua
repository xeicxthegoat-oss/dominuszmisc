--[[
    Merebennie Hub V1.5  |  The Strongest Battlegrounds  |  Delta Executor
    - Character-only rotation (HumanoidRootPart). The Camera is NEVER touched.
    - Config auto-saves to MerebennieHub_V1.5.json (writefile) and auto-loads (readfile).
]]

-------------------------------------------------- SERVICES
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local Lighting     = game:GetService("Lighting")
local VIM          = nil
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local IS_TOUCH = UIS.TouchEnabled
local lp = Players.LocalPlayer
if not lp then return end

local function log(...) print("[Merebennie Hub]", ...) end

if getgenv then
    local old = getgenv().MerebennieHub
    if old and old.Destroy then pcall(old.Destroy) end
end

-------------------------------------------------- CONFIG SAVE SYSTEM
local FILE = "MerebennieHub_V1.5.json"
local Config = {}

local function loadConfig()
    if not (readfile and isfile) then log("readfile/isfile unavailable - config disabled") return end
    local ok, data = pcall(function()
        if isfile(FILE) then return HttpService:JSONDecode(readfile(FILE)) end
    end)
    if ok and type(data) == "table" then Config = data log("Config loaded") else log("No config found, using defaults") end
end

local saveQueued = false
local function save()
    if saveQueued or not writefile then return end
    saveQueued = true
    task.delay(0.6, function()
        saveQueued = false
        local ok, err = pcall(function() writefile(FILE, HttpService:JSONEncode(Config)) end)
        if not ok then log("Save failed:", err) end
    end)
end

local function cfg(flag, default)
    local v = Config[flag]
    if v == nil then return default end
    return v
end

local function getKey(flag, default)
    local ok, kc = pcall(function() return Enum.KeyCode[cfg(flag, default)] end)
    return ok and kc or Enum.KeyCode[default]
end

loadConfig()

-------------------------------------------------- CONNECTION / CLEANUP TRACKING
local Conns, Alive = {}, true
local function track(c) Conns[#Conns + 1] = c return c end
local cleanupFns = {}

-------------------------------------------------- HELPERS
local TAU = math.pi * 2
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function unit(v) local m = v.Magnitude if m < 1e-4 then return nil end return v / m end
local function rotY(v, ang) return CFrame.Angles(0, ang, 0):VectorToWorldSpace(v) end
local function ease(a) return TweenService:GetValue(math.clamp(a, 0, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.Out) end

local function getChar()
    local c = lp.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChildOfClass("Humanoid")
    if r and h and h.Health > 0 then return c, r, h end
end

local function nearestEnemy(range)
    local _, root = getChar()
    if not root then return end
    local best, bestD, bestP = nil, range or math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - root.Position).Magnitude
                if d < bestD then best, bestD, bestP = r, d, p end
            end
        end
    end
    return best, bestP, bestD
end

local function sendKey(kc, down)
    if VIM then pcall(function() VIM:SendKeyEvent(down, kc, false, game) end) end
end
local function tapKey(kc, hold)
    sendKey(kc, true) task.wait(hold or 0.05) sendKey(kc, false)
end
local function click()
    if not VIM then return end
    pcall(function()
        local s = workspace.CurrentCamera.ViewportSize
        VIM:SendMouseButtonEvent(s.X / 2, s.Y / 2, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(s.X / 2, s.Y / 2, 0, false, game, 0)
    end)
end

-------------------------------------------------- MOTION ENGINE
-- Smooth velocity-driven movement. Rotates ONLY the character root, never the camera.
local Busy = false
local function motion(duration, velFn, faceFn, turnRate)
    local _, root, hum = getChar()
    if not root or Busy then return end
    Busy = true
    local prevAuto = hum.AutoRotate
    hum.AutoRotate = false
    local t = 0
    local ok, err = pcall(function()
        while t < duration and Alive do
            local dt = RunService.Heartbeat:Wait()
            t += dt
            if not root.Parent or hum.Health <= 0 then break end
            local a = math.clamp(t / duration, 0, 1)
            local v, y = velFn(a, dt)
            if v then
                local cur = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(v.X, y or cur.Y, v.Z)
            end
            if faceFn then
                local look = faceFn(a)
                if look and flat(look).Magnitude > 0.001 then
                    local goal = CFrame.lookAt(root.Position, root.Position + flat(look))
                    root.CFrame = root.CFrame:Lerp(goal, math.clamp(dt * (turnRate or 25), 0, 1))
                end
            end
        end
    end)
    pcall(function() hum.AutoRotate = prevAuto end)
    Busy = false
    if not ok then log("Motion error:", err) end
end

-- Preferred direction: nearest enemy in range, else movement input, else facing.
local function aimDir(root, hum)
    local tgt = nearestEnemy(cfg("t_range", 45))
    local d
    if tgt then d = unit(flat(tgt.Position - root.Position)) end
    if not d then d = unit(flat(hum.MoveDirection)) end
    if not d then d = unit(flat(root.CFrame.LookVector)) end
    return d or Vector3.new(0, 0, -1), tgt
end

-- Works for WASD and the mobile joystick: uses Humanoid.MoveDirection relative to the camera (camera is only read)
local function moveInput()
    local _, _, hum = getChar()
    local cam = workspace.CurrentCamera
    if not hum or not cam then return 0, 0 end
    local md = hum.MoveDirection
    if md.Magnitude < 0.2 then return 0, 0 end
    local r = unit(flat(cam.CFrame.RightVector)) or Vector3.xAxis
    local f = unit(flat(cam.CFrame.LookVector)) or -Vector3.zAxis
    return md:Dot(r), md:Dot(f) -- x: right(+)/left(-), y: forward(+)/back(-)
end
local function sideSign()
    local x, f = moveInput()
    if math.abs(x) > 0.45 and math.abs(x) >= math.abs(f) * 0.6 then return x > 0 and 1 or -1 end
    return nil
end
local function backHeld()
    local x, f = moveInput()
    return f < -0.5 and math.abs(x) < 0.5
end

-------------------------------------------------- TECHS
local function twist(o)
    local _, root, hum = getChar()
    if not root then return end
    local d = aimDir(root, hum)
    local p = cfg("t_power", 60) * (o.power or 1)
    local wind = o.windup or 0
    motion(o.dur, function(a)
        if a < wind then return -d * p * 0.25 * (1 - a / wind) end
        local b = (a - wind) / (1 - wind)
        return d * p * (1 - b) ^ 1.6
    end, function(a)
        if a < wind then return d end
        local b = (a - wind) / (1 - wind)
        return rotY(d, (1 - ease(b)) * TAU * (o.spins or 1))
    end, 90)
end

local function instantTwisted()  twist({dur = 0.28, power = 1.0, spins = 1}) end
local function boomyTwisted()    twist({dur = 0.22, power = 1.5, spins = 1}) end
local function boomyTwistedRW()  twist({dur = 0.34, power = 1.7, spins = 2, windup = 0.25}) end

local function supaV2()
    local _, root, hum = getChar() if not root then return end
    local d = aimDir(root, hum)
    local p = cfg("t_power", 60)
    motion(0.38, function(a) return d * p * (1 - a * a) end, function() return d end, 30)
end

local function supaV3()
    local _, root, hum = getChar() if not root then return end
    local d = aimDir(root, hum)
    local p = cfg("t_power", 60)
    local right = Vector3.new(-d.Z, 0, d.X)
    motion(0.55, function(a)
        local m = math.sin(math.pi * (0.15 + 0.85 * a))
        return d * p * 1.15 * m + right * math.sin(a * TAU) * p * 0.15
    end, function() return d end, 30)
end

local lastSide = 1
local function sideDashV3()
    local _, root, hum = getChar() if not root then return end
    local d, tgt = aimDir(root, hum)
    local s = sideSign() or -lastSide
    lastSide = s
    local right = Vector3.new(-d.Z, 0, d.X) * s
    local p = cfg("t_power", 60) * 1.5
    motion(0.22, function(a) return (right + d * 0.2) * p * (1 - a) ^ 1.2 end,
        function() if tgt and tgt.Parent then return tgt.Position - root.Position end return d end, 60)
end

-- Orbit around a target (shared by Side Dash Assist, Oreo, Kyoto)
local function orbit(tgt, sign, arcDeg, dur)
    local _, root = getChar()
    if not root or not tgt or not tgt.Parent then return end
    local rel = flat(root.Position - tgt.Position)
    local r = math.clamp(rel.Magnitude, 3.5, 8)
    local ang0 = math.atan2(rel.Z, rel.X)
    local toT = unit(-rel) or Vector3.new(0, 0, -1)
    local wanted = Vector3.new(-toT.Z, 0, toT.X) * sign
    local tangent = Vector3.new(-math.sin(ang0), 0, math.cos(ang0))
    local sweep = math.rad(arcDeg) * (tangent:Dot(wanted) >= 0 and 1 or -1)
    motion(dur, function(a, dt)
        if not tgt.Parent then return end
        local ang = ang0 + sweep * ease(a)
        local goal = tgt.Position + Vector3.new(math.cos(ang), 0, math.sin(ang)) * r
        local v = flat(goal - root.Position) / math.max(dt, 1 / 120)
        if v.Magnitude > 95 then v = v.Unit * 95 end
        return v
    end, function() if tgt.Parent then return tgt.Position - root.Position end end, 45)
end

local function sideDashAssist()
    local tgt = nearestEnemy(cfg("sda_range", 30))
    if not tgt then return end
    local s = sideSign() or -lastSide
    lastSide = s
    orbit(tgt, s, cfg("sda_arc", 110), cfg("sda_dur", 0.32))
end

local function lizTech() -- hop-dash with a flick turn (custom interpretation)
    local _, root, hum = getChar() if not root then return end
    local d = aimDir(root, hum)
    local p = cfg("t_power", 60) * 0.9
    motion(0.45, function(a)
        local y = a < 0.5 and 30 * (1 - a * 2) or nil
        return d * p * (1 - a * 0.5), y
    end, function(a)
        if a < 0.5 then return rotY(d, math.pi * ease(a * 2)) end
        return rotY(d, math.pi * (1 - ease((a - 0.5) * 2)))
    end, 70)
end

local function lunge(mult, dur)
    local _, root, hum = getChar() if not root then return end
    local d, tgt = aimDir(root, hum)
    local p = cfg("t_power", 60) * mult
    motion(dur, function(a) return d * p * (1 - a) ^ 1.3 end,
        function() if tgt and tgt.Parent then return tgt.Position - root.Position end return d end, 50)
end

local function backDashCancel()
    task.wait(cfg("bdc_delay", 0.12))
    local _, root, hum = getChar() if not root then return end
    pcall(function()
        local an = hum:FindFirstChildOfClass("Animator")
        if an then
            for _, tr in ipairs(an:GetPlayingAnimationTracks()) do
                local n = (tr.Name or ""):lower()
                local id = (tr.Animation and tr.Animation.Name or ""):lower()
                if n:find("dash") or id:find("dash") or n:find("back") then tr:Stop(0.05) end
            end
        end
    end)
    local v = root.AssemblyLinearVelocity
    root.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
    Busy = false
    lunge(0.4, 0.14)
end

-- Macro techs (generic - set the "Move Key" to the hotbar slot you want used)
local MacroBusy = false
local KyPad = false
local function pressMove(flag) tapKey(getKey(flag, "One"), 0.05) end

local function longslam()
    if MacroBusy then return end MacroBusy = true
    pcall(function()
        task.spawn(function() task.wait(cfg("ls_delay", 0.12)) pressMove("ls_move") end)
        lunge(1.3, 0.25)
    end)
    MacroBusy = false
end

local function oreo()
    if MacroBusy then return end MacroBusy = true
    pcall(function()
        lunge(0.8, 0.18)
        for _ = 1, cfg("oreo_hits", 2) do click() task.wait(0.12) end
        local tgt = nearestEnemy(cfg("t_range", 45))
        if tgt then orbit(tgt, sideSign() or lastSide, cfg("sda_arc", 110), 0.3) end
        click() task.wait(0.08)
        pressMove("oreo_move")
    end)
    MacroBusy = false
end

local function kyoto()
    if MacroBusy then return end MacroBusy = true
    pcall(function()
        local trig = getKey("ky_key", "C")
        local loops = 0
        while Alive and cfg("ky_on", false) and (UIS:IsKeyDown(trig) or KyPad) and loops < 20 do
            loops += 1
            local tgt = nearestEnemy(cfg("t_range", 45))
            if not tgt then break end
            lunge(0.9, 0.18)
            click() task.wait(0.1) click()
            orbit(tgt, -lastSide, cfg("sda_arc", 110), 0.28)
            lastSide = -lastSide
            pressMove("ky_move")
            task.wait(cfg("ky_gap", 0.25))
        end
    end)
    MacroBusy = false
    KyPad = false
end
local function kyotoPad()
    KyPad = not KyPad
    if KyPad then task.spawn(function() pcall(kyoto) end) end
end

-- Registry: { display name, toggle flag, key flag, default key, function }
local TechList = {
    {"Instant Twisted",                  "t_twisted",  "k_twisted",  "T", instantTwisted},
    {"Supa V2",                          "t_supa2",    "k_supa2",    "Y", supaV2},
    {"Supa V3",                          "t_supa3",    "k_supa3",    "U", supaV3},
    {"Side Dash V3",                     "t_side3",    "k_side3",    "G", sideDashV3},
    {"Liz Tech (REWORKED)",              "t_liz",      "k_liz",      "H", lizTech},
    {"BOOMY Instant Twisted",            "t_boomy",    "k_boomy",    "J", boomyTwisted},
    {"BOOMY Instant Twisted [REWORKED]", "t_boomy2",   "k_boomy2",   "K", boomyTwistedRW},
}

-------------------------------------------------- FLOATER (hover tech)
-- Holds your altitude in mid-air so you can move and fight while floating; movement stays player-controlled.
local FL = {on = false, y = 0, t0 = 0}
local rayParams = RaycastParams.new()
pcall(function() rayParams.FilterType = Enum.RaycastFilterType.Exclude end)

local function floorY(root, c)
    rayParams.FilterDescendantsInstances = {c}
    local r = workspace:Raycast(root.Position, Vector3.new(0, -600, 0), rayParams)
    return r and r.Position.Y or nil
end

local function floaterEngage()
    local c, root, hum = getChar()
    if not root then return end
    local grounded = hum.FloorMaterial ~= Enum.Material.Air
    if cfg("fl_hold", true) and not grounded then
        FL.y = root.Position.Y -- freeze at current altitude
    else
        local fy = floorY(root, c)
        FL.y = (fy or (root.Position.Y - 3)) + 3 + cfg("fl_height", 12)
    end
    FL.on, FL.t0 = true, os.clock()
end

local function floaterToggle()
    if not cfg("t_floater", false) then return end
    if FL.on then FL.on = false else floaterEngage() end
end

local function floaterStep(dt)
    if not cfg("t_floater", false) then FL.on = false return end
    local _, root, hum = getChar()
    if not root then FL.on = false return end
    if not FL.on then
        if cfg("fl_auto", false) and hum:GetState() == Enum.HumanoidStateType.Freefall
            and (UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump) and root.AssemblyLinearVelocity.Y < 0 then
            floaterEngage()
        end
        return
    end
    if os.clock() - FL.t0 > cfg("fl_time", 4) then FL.on = false return end
    local v = root.AssemblyLinearVelocity
    local desired = math.clamp((FL.y - root.Position.Y) * cfg("fl_smooth", 8), -60, 60)
    root.AssemblyLinearVelocity = Vector3.new(v.X, v.Y + (desired - v.Y) * math.min(1, dt * 12), v.Z)
    if hum:GetState() ~= Enum.HumanoidStateType.Freefall then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end) end
end

-- Mobile: detect the game's own dash by a sudden horizontal speed spike
local lastSpeed, dashCd = 0, 0
local function dashDetect(dt)
    if not cfg("ad_on", IS_TOUCH) then return end
    local _, root = getChar()
    if not root then return end
    local sp = flat(root.AssemblyLinearVelocity).Magnitude
    dashCd -= dt
    if sp > cfg("ad_speed", 45) and lastSpeed < 28 and dashCd <= 0 and not Busy and not MacroBusy then
        dashCd = 0.6
        if cfg("bdc_on", false) and backHeld() and not sideSign() then
            task.spawn(function() pcall(backDashCancel) end)
        elseif cfg("sda_on", false) and sideSign() then
            task.spawn(function() task.wait(0.03) pcall(sideDashAssist) end)
        end
    end
    lastSpeed = sp
end

-------------------------------------------------- AUTO BLOCK (360)
local blocking = false
local function doBlock()
    if blocking then return end
    blocking = true
    task.spawn(function()
        local kc = getKey("ab_key", "F")
        sendKey(kc, true)
        task.wait(cfg("ab_hold", 0.35))
        sendKey(kc, false)
        task.wait(cfg("ab_cd", 0.1))
        blocking = false
    end)
end

local ACTION = {
    [Enum.AnimationPriority.Action] = true, [Enum.AnimationPriority.Action2] = true,
    [Enum.AnimationPriority.Action3] = true, [Enum.AnimationPriority.Action4] = true,
}

local function autoBlockStep()
    if not cfg("ab_on", false) or blocking then return end
    local _, root = getChar()
    if not root then return end
    local radius, speedThr = cfg("ab_radius", 18), cfg("ab_speed", 28)
    for _, p in ipairs(Players:GetPlayers()) do
        local ch = p ~= lp and p.Character
        local er = ch and ch:FindFirstChild("HumanoidRootPart")
        local eh = ch and ch:FindFirstChildOfClass("Humanoid")
        if er and eh and eh.Health > 0 then
            local off = root.Position - er.Position
            local dist = off.Magnitude
            if dist <= radius then -- full 360: no facing/angle restriction
                -- 1) fast-closing body / hitbox velocity from any direction
                local closing = er.AssemblyLinearVelocity:Dot(off / math.max(dist, 0.01))
                if closing > speedThr then doBlock() return end
                -- 2) enemy attack animation just started
                if cfg("ab_anim", true) and dist <= radius * 0.8 then
                    local an = eh:FindFirstChildOfClass("Animator")
                    if an then
                        for _, tr in ipairs(an:GetPlayingAnimationTracks()) do
                            if ACTION[tr.Priority] and tr.TimePosition < 0.4 then doBlock() return end
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------------------- VISUALS / OPTIMIZATION / COLOR
local function espStep()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local h = p.Character:FindFirstChild("MBHub_ESP")
            if cfg("v_esp", false) then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "MBHub_ESP"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.OutlineColor = Color3.fromRGB(190, 90, 255)
                    h.FillColor = Color3.fromRGB(150, 50, 255)
                    h.FillTransparency = 0.7
                    h.Parent = p.Character
                end
            elseif h then h:Destroy() end
        end
    end
end

local fbOrig
local function setFullbright(on)
    if on then
        fbOrig = fbOrig or {Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.Ambient}
        Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 2, 14, false
        Lighting.Ambient = Color3.fromRGB(170, 170, 170)
    elseif fbOrig then
        Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows, Lighting.Ambient = table.unpack(fbOrig)
        fbOrig = nil
    end
end

local CC = Instance.new("ColorCorrectionEffect")
CC.Name = "MBHub_CC"
CC.Enabled = false
CC.Parent = Lighting
local function applyCC()
    CC.Enabled = cfg("cc_on", false)
    CC.TintColor = Color3.fromRGB(cfg("cc_r", 255), cfg("cc_g", 255), cfg("cc_b", 255))
    CC.Saturation = cfg("cc_sat", 0)
    CC.Contrast = cfg("cc_con", 0)
    CC.Brightness = cfg("cc_bri", 0)
end

local boosted, boostConn = {}, nil
local function boostInst(i)
    if i:IsA("ParticleEmitter") or i:IsA("Trail") or i:IsA("Beam") or i:IsA("Smoke") or i:IsA("Fire") or i:IsA("Sparkles") then
        if i.Enabled then boosted[#boosted + 1] = i i.Enabled = false end
    end
end
local function setBoost(on)
    if on then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        Lighting.GlobalShadows = false
        for _, i in ipairs(workspace:GetDescendants()) do pcall(boostInst, i) end
        boostConn = workspace.DescendantAdded:Connect(function(i) pcall(boostInst, i) end)
        log("FPS boost applied")
    else
        if boostConn then boostConn:Disconnect() boostConn = nil end
        for _, i in ipairs(boosted) do pcall(function() i.Enabled = true end) end
        boosted = {}
        Lighting.GlobalShadows = true
    end
end

-------------------------------------------------- GUI LIBRARY
local PURPLE, BG, PANEL, PANEL2 = Color3.fromRGB(170, 70, 255), Color3.fromRGB(14, 11, 21), Color3.fromRGB(23, 18, 34), Color3.fromRGB(30, 24, 45)
local TEXT, DIM = Color3.fromRGB(235, 228, 250), Color3.fromRGB(150, 140, 175)
local FONT, FONTB = Enum.Font.GothamMedium, Enum.Font.GothamBold

local function mk(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props) do i[k] = v end
    i.Parent = parent
    return i
end
local function corner(o, r) mk("UICorner", {CornerRadius = UDim.new(0, r or 6)}, o) end
local function stroke(o, c, t, tr) return mk("UIStroke", {Color = c, Thickness = t or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o) end
local function tw(o, t, p) TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), p):Play() end

local gui = Instance.new("ScreenGui")
gui.Name = "MerebennieHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end) then
    gui.Parent = lp:WaitForChild("PlayerGui")
end

local function viewport()
    local s = gui.AbsoluteSize
    if s.X < 50 or s.Y < 50 then
        local cam = workspace.CurrentCamera
        s = cam and cam.ViewportSize or Vector2.new(800, 450)
    end
    return s
end
local function sizeOf(f)
    local s = f.AbsoluteSize
    if s.X < 1 then return Vector2.new(f.Size.X.Offset, f.Size.Y.Offset) end
    return s
end
local function clampXY(x, y, size)
    local vp = viewport()
    return math.clamp(x, 0, math.max(0, vp.X - size.X)), math.clamp(y, 0, math.max(0, vp.Y - size.Y))
end

-- Generic drag helper: mouse + touch, stays on screen, tap (no movement) fires onTap
local function makeDraggable(handle, target, onTap, fx, fy)
    local dragging, moved, startIn, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, startIn = true, false, i.Position
            startPos = Vector2.new(target.AbsolutePosition.X, target.AbsolutePosition.Y)
        end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startIn
            if d.Magnitude > 6 then moved = true end
            if moved then
                local x, y = clampXY(startPos.X + d.X, startPos.Y + d.Y, sizeOf(target))
                target.Position = UDim2.fromOffset(x, y)
            end
        end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if moved then
                if fx then Config[fx] = target.Position.X.Offset Config[fy] = target.Position.Y.Offset save() end
            elseif onTap then
                pcall(onTap)
            end
        end
    end))
end

local main = mk("Frame", {Name = "Main", BackgroundColor3 = BG, BorderSizePixel = 0, Active = true}, gui)
corner(main, 10)
stroke(main, PURPLE, 2)
mk("ImageLabel", {Name = "Glow", BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = PURPLE,
    ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 50, 1, 50), Position = UDim2.fromOffset(-25, -25), ZIndex = 0}, main)

local top = mk("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = PANEL, BorderSizePixel = 0, Active = true}, main)
corner(top, 10)
mk("Frame", {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = PANEL, BorderSizePixel = 0}, top)
mk("TextLabel", {Text = "Merebennie Hub V1.5", Font = FONTB, TextSize = 16, TextColor3 = PURPLE, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left}, top)
local subtitle = mk("TextLabel", {Text = "The Strongest Battlegrounds", Font = FONT, TextSize = 11, TextColor3 = DIM, BackgroundTransparency = 1,
    Position = UDim2.new(1, -250, 0, 0), Size = UDim2.fromOffset(200, 38), TextXAlignment = Enum.TextXAlignment.Right}, top)
local minBtn = mk("TextButton", {Text = "–", Font = FONTB, TextSize = 22, TextColor3 = TEXT, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(46, 38), Position = UDim2.new(1, -46, 0, 0)}, top)

local sidebar = mk("ScrollingFrame", {Position = UDim2.fromOffset(8, 46), Size = UDim2.new(0, 150, 1, -54), BackgroundColor3 = PANEL,
    BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = PURPLE, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y}, main)
corner(sidebar, 8)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
mk("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 6)}, sidebar)

local content = mk("Frame", {Position = UDim2.fromOffset(166, 46), Size = UDim2.new(1, -174, 1, -54), BackgroundTransparency = 1}, main)

-- Fit the window to any screen (phones included) and keep it on-screen
local function layoutMain(keepPos)
    local vp = viewport()
    local w, h = math.min(640, vp.X - 16), math.min(410, vp.Y - 16)
    main.Size = UDim2.fromOffset(w, h)
    local sbw = w < 560 and 112 or 150
    sidebar.Size = UDim2.new(0, sbw, 1, -54)
    content.Position = UDim2.fromOffset(sbw + 16, 46)
    content.Size = UDim2.new(1, -(sbw + 24), 1, -54)
    subtitle.Visible = w >= 540
    local cx, cy
    if keepPos then
        cx, cy = main.Position.X.Offset, main.Position.Y.Offset
    else
        cx, cy = cfg("win_x", (vp.X - w) / 2), cfg("win_y", (vp.Y - h) / 2)
    end
    local x, y = clampXY(cx, cy, Vector2.new(w, h))
    main.Position = UDim2.fromOffset(x, y)
end
layoutMain(false)
makeDraggable(top, main, nil, "win_x", "win_y")

-- Minimized icon: random icon, draggable, never leaves the screen, tap to reopen
local ICONS = {"⚡", "🔥", "💜", "👁️", "🌀", "☄️", "🎯", "🔮", "💎", "🌙", "⭐", "🗡️"}
local rng = Random.new()
local fab = mk("TextButton", {Text = "⚡", Font = FONTB, TextSize = 24, TextColor3 = TEXT, BackgroundColor3 = BG,
    Size = UDim2.fromOffset(48, 48), Visible = false, AutoButtonColor = false, Active = true, ZIndex = 5}, gui)
corner(fab, 24) stroke(fab, PURPLE, 2)
mk("ImageLabel", {BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = PURPLE, ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Size = UDim2.new(1, 30, 1, 30),
    Position = UDim2.fromOffset(-15, -15), ZIndex = 4}, fab)

local function placeFab(x, y)
    x, y = clampXY(x, y, Vector2.new(48, 48))
    fab.Position = UDim2.fromOffset(x, y)
end
local function minimizeUI()
    local mx, my = main.AbsolutePosition.X, main.AbsolutePosition.Y
    fab.Text = ICONS[rng:NextInteger(1, #ICONS)]
    placeFab(cfg("fab_x", mx + 8), cfg("fab_y", my + 8))
    main.Visible, fab.Visible = false, true
end
local function restoreUI()
    layoutMain(true)
    main.Visible, fab.Visible = true, false
end
local function toggleUI() if main.Visible then minimizeUI() else restoreUI() end end
minBtn.Activated:Connect(minimizeUI)
makeDraggable(fab, fab, restoreUI, "fab_x", "fab_y")

-- Re-fit when the screen size / orientation changes
track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    layoutMain(true)
    if fab.Visible then placeFab(fab.Position.X.Offset, fab.Position.Y.Offset) end
end))

-- Tabs
local Tabs, Tab = {}, {}
Tab.__index = Tab

local function selectTab(t)
    for _, o in ipairs(Tabs) do
        o.page.Visible = (o == t)
        tw(o.btn, 0.15, {BackgroundColor3 = (o == t) and PURPLE or PANEL2, TextColor3 = (o == t) and Color3.new(1, 1, 1) or DIM})
    end
end

local function newTab(name)
    local btn = mk("TextButton", {Text = name, Font = FONT, TextSize = 12, TextColor3 = DIM, BackgroundColor3 = PANEL2,
        Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false, LayoutOrder = #Tabs + 1}, sidebar)
    corner(btn, 6)
    local page = mk("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = PURPLE, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false}, content)
    mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    mk("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}, page)
    local t = setmetatable({page = page, btn = btn}, Tab)
    Tabs[#Tabs + 1] = t
    btn.MouseButton1Click:Connect(function() selectTab(t) end)
    return t
end

local function row(page, h)
    local f = mk("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = PANEL, BorderSizePixel = 0}, page)
    corner(f, 6)
    stroke(f, Color3.fromRGB(70, 40, 110), 1, 0.3)
    return f
end

local function safe(cb, ...) if cb then local ok, e = pcall(cb, ...) if not ok then log("Callback error:", e) end end end

function Tab:Section(text)
    mk("TextLabel", {Text = string.upper(text), Font = FONTB, TextSize = 11, TextColor3 = PURPLE, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left}, self.page)
end

function Tab:Label(text)
    mk("TextLabel", {Text = text, Font = FONT, TextSize = 12, TextColor3 = DIM, BackgroundTransparency = 1, TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 30), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, self.page)
end

function Tab:Button(text, cb)
    local f = row(self.page, 32)
    local b = mk("TextButton", {Text = text, Font = FONT, TextSize = 13, TextColor3 = TEXT, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1)}, f)
    b.MouseButton1Click:Connect(function() tw(f, 0.1, {BackgroundColor3 = PANEL2}) task.delay(0.12, function() tw(f, 0.2, {BackgroundColor3 = PANEL}) end) safe(cb) end)
end

function Tab:Toggle(text, flag, default, cb)
    local on = cfg(flag, default or false)
    Config[flag] = on
    local f = row(self.page, 36)
    mk("TextLabel", {Text = text, Font = FONT, TextSize = 13, TextColor3 = TEXT, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -110, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd}, f)
    local state = mk("TextLabel", {Font = FONTB, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 36),
        Position = UDim2.new(1, -86, 0, 0)}, f)
    local sw = mk("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = PANEL2}, f)
    corner(sw, 10)
    local sws = stroke(sw, PURPLE, 1)
    local knob = mk("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = DIM}, sw)
    corner(knob, 7)
    local function render()
        state.Text = on and "ON" or "OFF"
        tw(state, 0.15, {TextColor3 = on and PURPLE or DIM})
        tw(sw, 0.15, {BackgroundColor3 = on and PURPLE or PANEL2})
        tw(knob, 0.15, {Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = on and Color3.new(1, 1, 1) or DIM})
        sws.Transparency = on and 0 or 0.6
    end
    render()
    local btn = mk("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, f)
    btn.MouseButton1Click:Connect(function()
        on = not on
        Config[flag] = on
        render() save() safe(cb, on)
    end)
    task.defer(safe, cb, on) -- apply loaded state
end

function Tab:Slider(text, flag, min, max, default, step, cb)
    local val = math.clamp(tonumber(cfg(flag, default)) or default, min, max)
    Config[flag] = val
    local f = row(self.page, 50)
    mk("TextLabel", {Text = text, Font = FONT, TextSize = 13, TextColor3 = TEXT, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -90, 0, 20), TextXAlignment = Enum.TextXAlignment.Left}, f)
    local vl = mk("TextLabel", {Font = FONTB, TextSize = 12, TextColor3 = PURPLE, BackgroundTransparency = 1,
        Position = UDim2.new(1, -78, 0, 4), Size = UDim2.fromOffset(66, 20), TextXAlignment = Enum.TextXAlignment.Right}, f)
    local track_ = mk("Frame", {Position = UDim2.new(0, 12, 0, 33), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = PANEL2}, f)
    corner(track_, 3)
    local fill = mk("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = PURPLE}, track_)
    corner(fill, 3)
    local knob = mk("Frame", {Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1)}, fill)
    corner(knob, 6)
    local function set(v, silent)
        v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
        val = v
        Config[flag] = v
        local a = (v - min) / (max - min)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(1, 0.5)
        vl.Text = tostring(math.floor(v * 1000 + 0.5) / 1000)
        if not silent then save() safe(cb, v) end
    end
    set(val, true)
    local dragging = false
    local function fromInput(i) set(min + (max - min) * math.clamp((i.Position.X - track_.AbsolutePosition.X) / track_.AbsoluteSize.X, 0, 1)) end
    local hit = mk("TextButton", {Text = "", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 24), Size = UDim2.new(1, 0, 0, 26)}, f)
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            self.page.ScrollingEnabled = false
            fromInput(i)
        end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromInput(i) end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            self.page.ScrollingEnabled = true
        end
    end))
    task.defer(safe, cb, val)
end

function Tab:Keybind(text, flag, default)
    local name = cfg(flag, default)
    Config[flag] = name
    local f = row(self.page, 32)
    mk("TextLabel", {Text = text, Font = FONT, TextSize = 13, TextColor3 = TEXT, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -100, 1, 0), TextXAlignment = Enum.TextXAlignment.Left}, f)
    local b = mk("TextButton", {Text = name, Font = FONTB, TextSize = 12, TextColor3 = PURPLE, BackgroundColor3 = PANEL2,
        Size = UDim2.fromOffset(76, 22), Position = UDim2.new(1, -86, 0.5, -11), AutoButtonColor = false}, f)
    corner(b, 5) stroke(b, PURPLE, 1, 0.4)
    b.MouseButton1Click:Connect(function()
        b.Text = "..."
        local c
        c = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                if i.KeyCode ~= Enum.KeyCode.Escape then name = i.KeyCode.Name Config[flag] = name save() end
                b.Text = name
                c:Disconnect()
            end
        end)
    end)
end

-------------------------------------------------- BUILD TABS
local tMain   = newTab("Main")
local tOpt    = newTab("Optimization")
local tTechs  = newTab("Techs")
local tVis    = newTab("Visuals")
local tColor  = newTab("Game Color Changer")
local tCD     = newTab("Cooldown Indicator")
local tBlock  = newTab("Auto Block")
local tLong   = newTab("Longslam V3")
local tOreo   = newTab("Oreo")
local tKyoto  = newTab("Auto-Kyoto V3")

-- MAIN
tMain:Section("General")
tMain:Label("Techs rotate only your character; your camera is never modified. Keyboard: rebind keys per tab. Mobile: use the Action Pad (draggable).")
tMain:Keybind("Toggle UI Key", "ui_key", "RightShift")
tMain:Slider("Tech Target Range (studs)", "t_range", 10, 120, 45, 1)
local pad -- forward declaration (built below)
tMain:Toggle("Mobile Action Pad", "mobile_btns", IS_TOUCH, function(on) if pad then pad.Visible = on end end)
tMain:Section("Config")
tMain:Button("Save Config Now", function() saveQueued = false save() log("Config saved to " .. FILE) end)
tMain:Button("Reset Config (delete file)", function()
    if delfile and isfile and pcall(isfile, FILE) and isfile(FILE) then pcall(delfile, FILE) end
    log("Config deleted - re-execute the script")
end)
tMain:Button("Unload Hub", function() if getgenv and getgenv().MerebennieHub then getgenv().MerebennieHub.Destroy() end end)

-- OPTIMIZATION
tOpt:Section("Performance")
tOpt:Toggle("FPS Boost (disable effects/shadows)", "opt_boost", false, setBoost)
tOpt:Slider("FPS Cap", "fps_cap", 30, 240, 60, 5, function(v) if setfpscap then pcall(setfpscap, v) end end)

-- TECHS
tTechs:Section("Shared")
tTechs:Slider("Dash Power", "t_power", 20, 120, 60, 1)
for _, t in ipairs(TechList) do
    tTechs:Section(t[1])
    tTechs:Toggle(t[1], t[2], false)
    tTechs:Keybind("   Key", t[3], t[4])
end
tTechs:Section("Side Dash Assist V2")
tTechs:Toggle("Side Dash Assist V2", "sda_on", false)
tTechs:Keybind("   Game Dash Key (hook)", "dash_key", "Q")
tTechs:Slider("   Activation Range (studs)", "sda_range", 5, 80, 30, 1)
tTechs:Slider("   Orbit Arc (degrees)", "sda_arc", 40, 200, 110, 5)
tTechs:Slider("   Orbit Duration (s)", "sda_dur", 0.15, 0.8, 0.32, 0.01)
tTechs:Section("Floater Tech")
tTechs:Toggle("Floater Tech", "t_floater", false)
tTechs:Keybind("   Hover Key (toggle)", "fl_key", "V")
tTechs:Toggle("   Hold Current Height (if airborne)", "fl_hold", true)
tTechs:Slider("   Hover Height (studs)", "fl_height", 3, 40, 12, 1)
tTechs:Slider("   Smoothness", "fl_smooth", 2, 20, 8, 1)
tTechs:Slider("   Max Hover Time (s)", "fl_time", 1, 12, 4, 0.5)
tTechs:Toggle("   Auto Float (hold Jump while falling)", "fl_auto", false)
tTechs:Section("Dash Detection (mobile)")
tTechs:Toggle("Auto-Detect Game Dash (for touch)", "ad_on", IS_TOUCH)
tTechs:Slider("   Dash Speed Threshold", "ad_speed", 25, 90, 45, 1)
tTechs:Section("Back Dash Cancel")
tTechs:Toggle("Back Dash Cancel (hooks S + dash key)", "bdc_on", false)
tTechs:Slider("   Cancel Delay (s)", "bdc_delay", 0.03, 0.4, 0.12, 0.01)

-- VISUALS
tVis:Section("ESP / Lighting")
tVis:Toggle("Player Highlight ESP", "v_esp", false, function() pcall(espStep) end)
tVis:Toggle("Fullbright", "v_fb", false, setFullbright)

-- COLOR CHANGER
tColor:Section("Screen Color")
tColor:Toggle("Enable Color Changer", "cc_on", false, applyCC)
tColor:Slider("Tint Red", "cc_r", 0, 255, 255, 1, applyCC)
tColor:Slider("Tint Green", "cc_g", 0, 255, 255, 1, applyCC)
tColor:Slider("Tint Blue", "cc_b", 0, 255, 255, 1, applyCC)
tColor:Slider("Saturation", "cc_sat", -1, 2, 0, 0.05, applyCC)
tColor:Slider("Contrast", "cc_con", -1, 1, 0, 0.05, applyCC)
tColor:Slider("Brightness", "cc_bri", -0.5, 0.5, 0, 0.02, applyCC)

-- COOLDOWN INDICATOR
tCD:Section("HUD")
tCD:Label("Reads Tool attributes / Enabled state; otherwise estimates from last use.")
tCD:Toggle("Cooldown Indicator", "cd_on", false)
tCD:Slider("Estimated Cooldown (s)", "cd_est", 1, 60, 10, 1)

-- AUTO BLOCK
tBlock:Section("360° Auto Block")
tBlock:Toggle("360° Auto Block", "ab_on", false)
tBlock:Keybind("Block Key (game)", "ab_key", "F")
tBlock:Slider("Detection Radius (studs)", "ab_radius", 6, 40, 18, 1)
tBlock:Slider("Closing Speed Threshold", "ab_speed", 10, 90, 28, 1)
tBlock:Slider("Block Hold Time (s)", "ab_hold", 0.1, 1.2, 0.35, 0.01)
tBlock:Slider("Re-block Cooldown (s)", "ab_cd", 0.0, 0.5, 0.1, 0.01)
tBlock:Toggle("Attack Animation Detection", "ab_anim", true)

-- LONGSLAM / OREO / KYOTO
tLong:Section("Longslam V3")
tLong:Toggle("Longslam V3", "ls_on", false)
tLong:Keybind("Trigger Key", "ls_key", "Z")
tLong:Keybind("Move Key (hotbar slot)", "ls_move", "One")
tLong:Slider("Move Delay (s)", "ls_delay", 0.02, 0.4, 0.12, 0.01)

tOreo:Section("Oreo")
tOreo:Toggle("Oreo", "oreo_on", false)
tOreo:Keybind("Trigger Key", "oreo_key", "X")
tOreo:Keybind("Move Key (hotbar slot)", "oreo_move", "Two")
tOreo:Slider("M1 Hits", "oreo_hits", 1, 5, 2, 1)

tKyoto:Section("Auto-Kyoto V3")
tKyoto:Toggle("Auto-Kyoto V3", "ky_on", false)
tKyoto:Keybind("Hold Key", "ky_key", "C")
tKyoto:Keybind("Move Key (hotbar slot)", "ky_move", "Three")
tKyoto:Slider("Loop Gap (s)", "ky_gap", 0.1, 1, 0.25, 0.01)

-------------------------------------------------- COOLDOWN HUD
local hud = mk("Frame", {Name = "CooldownHUD", BackgroundColor3 = BG, BackgroundTransparency = 0.15, Size = UDim2.fromOffset(170, 20),
    Position = UDim2.new(0, 12, 1, -230), AutomaticSize = Enum.AutomaticSize.Y, Visible = false}, gui)
corner(hud, 8) stroke(hud, PURPLE, 1.5)
mk("UIListLayout", {Padding = UDim.new(0, 2)}, hud)
mk("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 8)}, hud)
hud.Active = true
if Config.hud_x then hud.Position = UDim2.fromOffset(Config.hud_x, Config.hud_y) end
makeDraggable(hud, hud, nil, "hud_x", "hud_y")
local hudLabels, hooked, lastUse = {}, {}, {}

local function cdStep()
    hud.Visible = cfg("cd_on", false)
    if not hud.Visible then return end
    local tools = {}
    local bp, ch = lp:FindFirstChildOfClass("Backpack"), lp.Character
    for _, src in ipairs({bp, ch}) do
        if src then for _, t in ipairs(src:GetChildren()) do if t:IsA("Tool") then tools[#tools + 1] = t end end end
    end
    for _, t in ipairs(tools) do
        if not hooked[t] then hooked[t] = t.Activated:Connect(function() lastUse[t] = os.clock() end) end
        local lbl = hudLabels[t]
        if not lbl then
            lbl = mk("TextLabel", {Font = FONT, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left}, hud)
            hudLabels[t] = lbl
        end
        local rem = tonumber(t:GetAttribute("Cooldown") or t:GetAttribute("CD") or t:GetAttribute("CooldownTime"))
        if not rem or rem <= 0 then
            local cv = t:FindFirstChild("Cooldown")
            if cv and cv:IsA("NumberValue") then rem = cv.Value end
        end
        if (not rem or rem <= 0) and t.Enabled == false then rem = 1 end
        if (not rem or rem <= 0) and lastUse[t] then rem = cfg("cd_est", 10) - (os.clock() - lastUse[t]) end
        if rem and rem > 0 then
            lbl.Text = string.format("%s  %.1fs", t.Name, rem)
            lbl.TextColor3 = Color3.fromRGB(255, 90, 120)
        else
            lbl.Text = t.Name .. "  READY"
            lbl.TextColor3 = PURPLE
        end
    end
    for t, l in pairs(hudLabels) do
        if not t.Parent then l:Destroy() hudLabels[t] = nil if hooked[t] then hooked[t]:Disconnect() hooked[t] = nil end end
    end
end

-------------------------------------------------- MOBILE ACTION PAD
local PadList = {}
for _, t in ipairs(TechList) do PadList[#PadList + 1] = {(t[1]:gsub(" %[REWORKED%]", "*")), t[2], t[5]} end
for _, e in ipairs({
    {"Floater", "t_floater", floaterToggle}, {"Side Dash Assist", "sda_on", sideDashAssist},
    {"Back Dash Cancel", "bdc_on", backDashCancel}, {"Longslam V3", "ls_on", longslam},
    {"Oreo", "oreo_on", oreo}, {"Auto-Kyoto V3", "ky_on", kyotoPad},
}) do PadList[#PadList + 1] = e end

pad = mk("Frame", {Name = "ActionPad", BackgroundColor3 = BG, BackgroundTransparency = 0.15, Size = UDim2.fromOffset(124, 10),
    AutomaticSize = Enum.AutomaticSize.Y, Active = true, Visible = cfg("mobile_btns", IS_TOUCH)}, gui)
corner(pad, 8) stroke(pad, PURPLE, 1.5)
mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, pad)
mk("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, pad)
local grip = mk("TextLabel", {Text = "⠿ ACTION PAD", Font = FONTB, TextSize = 11, TextColor3 = PURPLE, BackgroundColor3 = PANEL,
    Size = UDim2.new(1, 0, 0, 22), Active = true, LayoutOrder = 0}, pad)
corner(grip, 5)
do
    local vp = viewport()
    local px, py = clampXY(cfg("pad_x", vp.X - 134), cfg("pad_y", 60), Vector2.new(124, 40))
    pad.Position = UDim2.fromOffset(px, py)
end
makeDraggable(grip, pad, nil, "pad_x", "pad_y")

local padBtns = {}
for n, e in ipairs(PadList) do
    local b = mk("TextButton", {Text = e[1], Font = FONT, TextSize = 12, TextColor3 = TEXT, TextWrapped = true, BackgroundColor3 = PANEL2,
        Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false, LayoutOrder = n, Visible = false}, pad)
    corner(b, 6) stroke(b, PURPLE, 1, 0.3)
    b.Activated:Connect(function()
        tw(b, 0.08, {BackgroundColor3 = PURPLE})
        task.delay(0.15, function() tw(b, 0.2, {BackgroundColor3 = PANEL2}) end)
        if cfg(e[2], false) then task.spawn(function() pcall(e[3]) end) end
    end)
    padBtns[#padBtns + 1] = {btn = b, flag = e[2]}
end
local function refreshPad() for _, p in ipairs(padBtns) do p.btn.Visible = cfg(p.flag, false) end end

-------------------------------------------------- INPUT + MAIN LOOP
track(UIS.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Keyboard or UIS:GetFocusedTextBox() then return end
    local k = i.KeyCode
    if k == getKey("ui_key", "RightShift") then toggleUI() return end
    if k == getKey("fl_key", "V") then floaterToggle() return end

    for _, t in ipairs(TechList) do
        if cfg(t[2], false) and k == getKey(t[3], t[4]) then task.spawn(function() pcall(t[5]) end) return end
    end
    if cfg("ls_on", false) and k == getKey("ls_key", "Z") then task.spawn(function() pcall(longslam) end) return end
    if cfg("oreo_on", false) and k == getKey("oreo_key", "X") then task.spawn(function() pcall(oreo) end) return end
    if cfg("ky_on", false) and k == getKey("ky_key", "C") then task.spawn(function() pcall(kyoto) end) return end

    -- Hooks onto the game's own dash
    if k == getKey("dash_key", "Q") then
        if cfg("bdc_on", false) and backHeld() and not sideSign() then
            task.spawn(function() pcall(backDashCancel) end)
        elseif cfg("sda_on", false) and sideSign() then
            task.spawn(function() task.wait(0.03) pcall(sideDashAssist) end)
        end
    end
end))

local blockAcc, slowAcc, cdAcc = 0, 0, 0
track(RunService.Heartbeat:Connect(function(dt)
    if not Alive then return end
    pcall(floaterStep, dt)
    pcall(dashDetect, dt)
    blockAcc += dt
    if blockAcc >= 0.05 then blockAcc = 0 pcall(autoBlockStep) end
    cdAcc += dt
    if cdAcc >= 0.15 then cdAcc = 0 pcall(cdStep) pcall(refreshPad) end
    slowAcc += dt
    if slowAcc >= 1 then slowAcc = 0 pcall(espStep) end
end))

-------------------------------------------------- FINISH
selectTab(Tabs[1])

local function destroy()
    Alive = false
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(hooked) do pcall(function() c:Disconnect() end) end
    pcall(setBoost, false)
    pcall(setFullbright, false)
    pcall(function() CC:Destroy() end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then local h = p.Character:FindFirstChild("MBHub_ESP") if h then h:Destroy() end end
    end
    pcall(function() gui:Destroy() end)
    log("Unloaded")
end
if getgenv then getgenv().MerebennieHub = {Destroy = destroy} end

if setfpscap then pcall(setfpscap, cfg("fps_cap", 60)) end
applyCC()
log("Loaded V1.5 - press " .. cfg("ui_key", "RightShift") .. " or tap the M button to toggle the UI")
