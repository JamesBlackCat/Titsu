--[[
    Aim.lua
    Aimlock script — Settings + Aimlock + NPC ESP.
]]

-- ============================================================
--  SERVICES
-- ============================================================

local Players          = game:GetService("Players")
local Teams            = game:GetService("Teams")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local function getCharParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil, nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildWhichIsA("Humanoid")
    local anim = hum and hum:FindFirstChildWhichIsA("Animator")
    return char, hrp, hum, anim
end

-- ============================================================
--  DEFAULTS / SETTINGS
-- ============================================================
local D = {
    -- ── Aimlock core ──────────────────────────────────────
    aimlockEnabled            = false,
    aimlockFOV                = 200,
    aimlockRange              = 1000,
    aimlockTeamCheck          = true,
    aimlockFriendCheck        = true,
    aimlockWallCheck          = true,
    aimlockShowFOV            = true,
    aimlockPart               = "Head",
    aimlockCrosshairPos       = UDim2.new(0.5, 0, 0.5, 0),
    aimlockCrosshairOpacity   = 0,          -- 0 = fully visible, 1 = invisible
    aimlockCrosshairShape     = "dot",      -- "dot" | "cross"
    aimlockCrosshairImage     = "",         -- optional rbxassetid/decal ID; blank uses shape
    aimlockCrosshairMoveSpeed = 300,        -- pixels per second while holding an editor arrow
    aimlockKey                = Enum.KeyCode.P,
    panelKey                 = Enum.KeyCode.RightControl,
    orbSetupKey              = Enum.KeyCode.O,
    orbSpawnKey              = Enum.KeyCode.I,
    orbUndoKey               = Enum.KeyCode.U,
    orbSetKey                = Enum.KeyCode.J,
    orbCancelKey             = Enum.KeyCode.K,
    orbDeleteModeKey         = Enum.KeyCode.L,
    orbForwardKey            = Enum.KeyCode.W,
    orbBackwardKey           = Enum.KeyCode.S,
    switchLeftKey            = Enum.KeyCode.LeftBracket,
    switchRightKey           = Enum.KeyCode.RightBracket,
    aimlockStickyLock         = true,
    aimlockSmartAI            = true,
    aimlockPredictStrength    = 1.0,
    aimlockSmoothing          = 0.55,
    aimlockMaxDegPerFrame     = 0,
    aimlockReacquireDelay     = 0.6,
    aimlockCursorMode         = true,
    aimlockHoldToAim          = false,
    aimlockPartChain          = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" },
    aimlockHumanize           = 0,
    aimlockPredictAccel       = false,
    aimlockMissChance         = 0,
    aimlockFOVColorR          = 255,
    aimlockFOVColorG          = 60,
    aimlockFOVColorB          = 60,
    aimlockFOVRingSize        = 200,
    aimlockIgnoreTransparentWalls = false,
    aimlockTransparencyThreshold   = 1,
    aimlockCanCollideWallCheck     = false,
    -- ── Lists ─────────────────────────────────────────────
    targetLockEnabled         = false,
    targetLockList            = {},
    ignoreList                = {},
    aimlockIgnoreTeams        = {},
    aimlockSmartTeamCheck     = false,
    -- ── Switch Targets ────────────────────────────────────
    switchTargetsEnabled      = false,
    -- ── Target Mode ───────────────────────────────────────
    targetPlayers             = true,
    targetNPCs                = false,
    targetOrbs                = true,
    targetBasedOffDistance    = false,       -- choose nearest eligible target inside the FOV ring
    targetDistanceSticky      = false,       -- distance target remains locked until it dies
    -- ── Orb Mark system ───────────────────────────────────
    orbEnabled                = true,
    orbHP                     = 100,
    orbRespawnTime            = 5,
    orbSize                   = 1.2,
    orbFloatSpeed              = 8,
    orbMaxPlacementDistance   = 1000,
    orbDeleteFOV               = 120,
    orbDeleteMode              = false,
    -- ── Rotation modes ────────────────────────────────────
    playerSitRotation         = false,
    npcSitRotation            = false,
    -- Sitting targets use their own selectable profiles.  The existing
    -- player/npc rotation profiles remain the standing profiles.
    playerSitTPEnabled        = false,
    playerSitTPRate           = 500,
    playerSitTPUnit           = "ms",
    playerSitTP1Part          = "Head",
    playerSitTP1Chance        = 100,
    playerSitTP2Part          = "",
    playerSitTP2Chance        = 0,
    playerSitTP3Part          = "",
    playerSitTP3Chance        = 0,
    playerSitTP4Part          = "",
    playerSitTP4Chance        = 0,
    playerSitTP5Part          = "",
    playerSitTP5Chance        = 0,
    playerSitTPMiss           = false,
    npcSitTPEnabled           = false,
    npcSitTPRate              = 500,
    npcSitTPUnit              = "ms",
    npcSitTP1Part             = "Head",
    npcSitTP1Chance           = 100,
    npcSitTP2Part             = "",
    npcSitTP2Chance           = 0,
    npcSitTP3Part             = "",
    npcSitTP3Chance           = 0,
    npcSitTP4Part             = "",
    npcSitTP4Chance           = 0,
    npcSitTP5Part             = "",
    npcSitTP5Chance           = 0,
    npcSitTPMiss              = false,
    -- ── NPC ESP (Drawing-based box) ───────────────────────
    espEnabled                = false,
    espDistance               = 500,        -- studs
    espBoxSize                = 40,         -- pixels (square side length)
    espBoxColorR              = 255,
    espBoxColorG              = 50,
    espBoxColorB              = 50,
    espNameTag                = true,       -- show name above box
    espHealthBar              = false,      -- show a live health bar beside the box
    espShowHealth             = false,      -- circle + torso health text
    espHealthDisplayDistance  = 250,
    -- ── Target Part Rotation — Players ───────────────────────
    playerTPEnabled    = false,
    playerTPRate       = 500,       -- switch interval (number)
    playerTPUnit       = "ms",      -- "ms" or "s"
    playerTP1Part      = "UpperTorso",
    playerTP1Chance    = 30,
    playerTP2Part      = "",
    playerTP2Chance    = 0,
    playerTP3Part      = "",
    playerTP3Chance    = 0,
    playerTP4Part      = "",
    playerTP4Chance    = 0,
    playerTP5Part      = "",
    playerTP5Chance    = 0,
    playerTPMiss       = false,
    -- ── Target Part Rotation — NPCs ───────────────────────────
    npcTPEnabled       = false,
    npcTPRate          = 500,
    npcTPUnit          = "ms",
    npcTP1Part         = "UpperTorso",
    npcTP1Chance       = 30,
    npcTP2Part         = "",
    npcTP2Chance       = 0,
    npcTP3Part         = "",
    npcTP3Chance       = 0,
    npcTP4Part         = "",
    npcTP4Chance       = 0,
    npcTP5Part         = "",
    npcTP5Chance       = 0,
    npcTPMiss          = false,
    -- ── Images ────────────────────────────────────────────
    aimlockOffImg             = "rbxassetid://124959989742325",
    aimlockOnImg              = "rbxassetid://119279898696244",
    -- ── Button layout ─────────────────────────────────────
    btnSize                   = UDim2.new(0, 72, 0, 72),
    aimlockBtnPos             = UDim2.new(0.34, 0, 0.80, 0),
    switchLeftBtnPos          = UDim2.new(0.18, 0, 0.65, 0),
    switchRightBtnPos         = UDim2.new(0.26, 0, 0.65, 0),
    modeBtnPlayerPos          = UDim2.new(0.42, 0, 0.80, 0),
    modeBtnNpcPos             = UDim2.new(0.50, 0, 0.80, 0),
}
local S = {}
for k, v in pairs(D) do S[k] = v end
S.targetLockList  = {}
S.ignoreList      = {}
S.aimlockIgnoreTeams = {}
S.aimlockPartChain = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }
S.aimlockFOVRingSize = math.clamp(tonumber(S.aimlockFOVRingSize) or 200, 1, 350)

-- ============================================================
--  ORB MARK SYSTEM
-- ============================================================
-- Orbs are the only target objects created by this feature.  They live in a
-- dedicated folder, never collide with the world, and carry their own health
-- and respawn state.  The target selector can therefore ignore arbitrary
-- map parts and empty raycasts entirely.
local OrbSystem = {
    folder = nil,
    saved = {},
    preview = {},
    floatMode = false,
    floatDistance = 10,
    forwardHeld = false,
    backwardHeld = false,
    setupActive = false,
    deleteRing = nil,
    selected = {},
}

do
    local oldFolder = workspace:FindFirstChild("__AimlockOrbs")
    if oldFolder then pcall(function() oldFolder:Destroy() end) end
    local folder = Instance.new("Folder")
    folder.Name = "__AimlockOrbs"
    folder.Parent = workspace
    OrbSystem.folder = folder
end

local function getOrbData(part)
    for _, data in ipairs(OrbSystem.saved) do
        if data.part == part then return data end
    end
    for _, data in ipairs(OrbSystem.preview) do
        if data.part == part then return data end
    end
    return nil
end

local function setOrbVisibility(data, visible)
    if not data or not data.part then return end
    -- Saved orb rigs stay invisible but remain queryable target parts.  Only
    -- placement previews are rendered, so the visible object on screen never
    -- becomes part of the saved setup.
    local previewTransparency = OrbSystem.floatMode and 0.60 or 0.35
    data.part.Transparency = visible and previewTransparency or 1
    data.part.CanQuery = visible
    data.part.CanTouch = false
    data.part:SetAttribute("OrbActive", visible)
    local glow = data.part:FindFirstChild("OrbGlow")
    if glow and glow:IsA("PointLight") then
        glow.Enabled = visible
    end
end

local function refreshOrbAppearance(data)
    if not data or not data.part then return end
    local hp = math.max(0, tonumber(data.hp) or 0)
    local maxHp = math.max(1, tonumber(data.maxHp) or 1)
    local fraction = math.clamp(hp / maxHp, 0, 1)
    data.part:SetAttribute("OrbHP", hp)
    data.part:SetAttribute("OrbMaxHP", maxHp)
    data.part:SetAttribute("OrbState", data.state or "Active")
    local isPreview = data.state == "Preview"
    if data.state == "Respawning" then
        data.part.Color = Color3.fromRGB(120, 120, 140)
        setOrbVisibility(data, false)
    elseif fraction <= 0 then
        data.part.Color = Color3.fromRGB(100, 100, 110)
        setOrbVisibility(data, false)
    elseif fraction < 0.35 then
        data.part.Color = Color3.fromRGB(255, 100, 80)
        setOrbVisibility(data, isPreview)
    else
        data.part.Color = Color3.fromRGB(95, 210, 255)
        setOrbVisibility(data, isPreview)
    end
end

local function createOrbPart(position, data)
    local part = Instance.new("Part")
    part.Name = "OrbMark"
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(S.orbSize, S.orbSize, S.orbSize)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = true
    part.Material = Enum.Material.Neon
    part.CastShadow = false
    part:SetAttribute("OrbTarget", true)
    part.Parent = OrbSystem.folder

    local light = Instance.new("PointLight")
    light.Name = "OrbGlow"
    light.Brightness = 0.8
    light.Range = 8
    light.Color = Color3.fromRGB(95, 210, 255)
    light.Parent = part

    data.part = part
    refreshOrbAppearance(data)
    return part
end

local function getOrbPlacementPosition()
    local character = LocalPlayer.Character
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character, OrbSystem.folder }
    rayParams.IgnoreWater = true

    local crosshairPos = S.aimlockCrosshairPos or UDim2.new(0.5, 0, 0.5, 0)
    local cross = Vector2.new(
        crosshairPos.X.Scale * Camera.ViewportSize.X + crosshairPos.X.Offset,
        crosshairPos.Y.Scale * Camera.ViewportSize.Y + crosshairPos.Y.Offset)
    local ray = Camera:ViewportPointToRay(cross.X, cross.Y)
    local result = workspace:Raycast(
        ray.Origin, ray.Direction * math.max(1, S.orbMaxPlacementDistance), rayParams)
    if result then return result.Position end
    return ray.Origin + ray.Direction * math.max(1, S.orbMaxPlacementDistance)
end

local function getFloatPlacementPosition()
    local character, hrp = getCharParts()
    local origin = Camera.CFrame.Position
    if hrp then origin = hrp.Position + Vector3.new(0, 1.5, 0) end
    return origin + Camera.CFrame.LookVector * math.max(2, OrbSystem.floatDistance)
end

local function createPreviewOrb()
    local data = {
        hp = math.max(1, tonumber(S.orbHP) or 100),
        maxHp = math.max(1, tonumber(S.orbHP) or 100),
        state = "Preview",
    }
    createOrbPart(
        OrbSystem.floatMode and getFloatPlacementPosition() or getOrbPlacementPosition(),
        data)
    table.insert(OrbSystem.preview, data)
    return data
end

local function destroyOrbData(data)
    if data and data.highlight then
        pcall(function() data.highlight:Destroy() end)
        data.highlight = nil
    end
    if data and data.part then pcall(function() data.part:Destroy() end) end
end

local function clearPreviewOrbs()
    for _, data in ipairs(OrbSystem.preview) do destroyOrbData(data) end
    OrbSystem.preview = {}
end

local function undoPreviewOrb()
    local data = table.remove(OrbSystem.preview)
    if data then destroyOrbData(data) end
end

local function setPreviewOrbs()
    for _, data in ipairs(OrbSystem.preview) do
        data.state = "Active"
        data.hp = math.max(1, tonumber(S.orbHP) or 100)
        data.maxHp = math.max(1, tonumber(S.orbHP) or 100)
        data.respawn = math.max(0, tonumber(S.orbRespawnTime) or 5)
        table.insert(OrbSystem.saved, data)
        refreshOrbAppearance(data)
    end
    OrbSystem.preview = {}
    OrbSystem.setupActive = false
end

local function beginOrbSetup()
    if not S.orbEnabled then return end
    OrbSystem.setupActive = true
    clearPreviewOrbs()
end

local function cancelOrbSetup()
    clearPreviewOrbs()
    OrbSystem.setupActive = false
end

local function damageOrb(data, amount)
    if not data or data.state ~= "Active" then return false end
    data.hp = math.max(0, data.hp - math.max(0, tonumber(amount) or 0))
    if data.hp <= 0 then
        data.state = "Respawning"
        data.respawnAt = tick() + math.max(0, tonumber(data.respawn) or 0)
    end
    refreshOrbAppearance(data)
    return true
end

local function deleteOrb(data)
    if not data then return end
    for i = #OrbSystem.saved, 1, -1 do
        if OrbSystem.saved[i] == data then
            table.remove(OrbSystem.saved, i)
            break
        end
    end
    for i = #OrbSystem.preview, 1, -1 do
        if OrbSystem.preview[i] == data then
            table.remove(OrbSystem.preview, i)
            break
        end
    end
    destroyOrbData(data)
end

local function updateOrbs(dt)
    if OrbSystem.floatMode then
        local direction = (OrbSystem.forwardHeld and 1 or 0)
            - (OrbSystem.backwardHeld and 1 or 0)
        if direction ~= 0 then
            OrbSystem.floatDistance = math.clamp(
                OrbSystem.floatDistance
                    + direction * math.max(0, tonumber(S.orbFloatSpeed) or 8) * dt,
                2, math.max(2, tonumber(S.orbMaxPlacementDistance) or 1000))
        end
    end

    if OrbSystem.setupActive and OrbSystem.floatMode then
        for _, data in ipairs(OrbSystem.preview) do
            if data.part then data.part.Position = getFloatPlacementPosition() end
        end
    end

    local now = tick()
    for _, data in ipairs(OrbSystem.saved) do
        if data.state == "Respawning" and now >= (data.respawnAt or now) then
            data.state = "Active"
            data.hp = data.maxHp
            refreshOrbAppearance(data)
        end
    end
end

_G.__Aimlock_DamageOrb = function(orbPart, amount)
    return damageOrb(getOrbData(orbPart), amount)
end

-- ============================================================
--  NPC CACHE  (event-driven — zero polling, zero GetDescendants spam)
-- ============================================================
--  npcCache[model] = { root=BasePart, hum=Humanoid }
--  Populated once at load via a single GetDescendants scan, then kept
--  current through workspace.DescendantAdded/Removing events and
--  Humanoid.Died signals.  No repeated scanning — the 0.5 s spike is gone.
--  root is cached so the ESP loop never calls FindFirstChildWhichIsA.
-- ============================================================
local npcCache       = {}   -- [Model] = { root=BasePart, hum=Humanoid }
local playerCharsSet = {}   -- set of current player character models

-- Track all player characters so we never add them to npcCache
local function trackPlayer(p)
    p.CharacterAdded:Connect(function(c)   playerCharsSet[c] = true  end)
    p.CharacterRemoving:Connect(function(c) playerCharsSet[c] = nil  end)
    if p.Character then playerCharsSet[p.Character] = true end
end
for _, p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then playerCharsSet[p.Character] = nil end
end)

local function getModelRoot(model)
    return model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart", true)
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function tryAddNPC(model)
    if not model or not model:IsA("Model") or model == workspace then return end
    if playerCharsSet[model] then return end
    if npcCache[model] then return end
    local hum = model:FindFirstChildWhichIsA("Humanoid", true)
    if not hum or hum.Health <= 0 then return end
    local root = getModelRoot(model)
    if not root then return end
    npcCache[model] = { root = root, hum = hum }
    -- Remove entry the instant the NPC dies (no lag, no polling)
    hum.Died:Connect(function()
        npcCache[model] = nil
        -- Remove the visible GUI immediately instead of waiting for the
        -- next ESP heartbeat.
        local currentRoot = root
        if currentRoot and currentRoot.Parent then
            local gui = currentRoot:FindFirstChild("NPC_ESP")
            if gui then pcall(function() gui:Destroy() end) end
        end
    end)
end

-- Health can reach zero between the cache pass, the ESP queue, and the
-- heartbeat that creates the BillboardGui.  Always check at the point of use
-- so a dead NPC can never receive (or keep) an ESP GUI.
local function isAliveNPC(model, data)
    local hum = data and data.hum
    return model and model.Parent and hum and hum.Parent and hum.Health > 0
end

-- ── Initial one-time scan (runs only at script load) ─────────
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Humanoid") then
        local m = obj.Parent
        while m and not m:IsA("Model") do m = m.Parent end
        tryAddNPC(m)
    end
end

-- ── Event: new Humanoid spawned anywhere in workspace ─────────
workspace.DescendantAdded:Connect(function(obj)
    if not obj:IsA("Humanoid") and not obj:IsA("BasePart")
    and not obj:IsA("Model") then return end
    -- defer so the rig is fully parented/initialized before we inspect it
    task.defer(function()
        local m = obj:IsA("Model") and obj or obj.Parent
        while m and not m:IsA("Model") do m = m.Parent end
        if m and not playerCharsSet[m] then tryAddNPC(m) end
    end)
end)

-- ── Event: Model removed from workspace ───────────────────────
workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") and npcCache[obj] then
        npcCache[obj] = nil
    end
end)


-- ============================================================
--  AIMLOCK STATE
-- ============================================================
local Aimlock = {
    target          = nil,
    targetModel     = nil, -- exact character/NPC model captured for the lock
    distanceDeadTarget = nil, -- don't reacquire this entity after its death
    targetLostAt    = 0,
    crosshairGui    = nil,
    crosshairDot    = nil,
    crosshairCrossH = nil,
    crosshairCrossV = nil,
    crosshairImage  = nil,
    fovCircle       = nil,
    fovStroke       = nil,
    statusLabel     = nil,
    friendCache     = {},
    _holdActive     = false,
}

-- ── List helpers ──────────────────────────────────────────────
local function isOnLockList(entity)
    if not entity then return false end
    return S.targetLockList[string.lower(entity.Name)] == true
end

local function isOnIgnoreList(entity)
    if not entity then return false end
    return S.ignoreList[string.lower(entity.Name)] == true
end

local function isFriend(plr)
    if not plr or plr == LocalPlayer then return false end
    local cached = Aimlock.friendCache[plr.UserId]
    if cached ~= nil then return cached end
    local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
    if ok then Aimlock.friendCache[plr.UserId] = res; return res end
    return false
end
Players.PlayerRemoving:Connect(function(p) Aimlock.friendCache[p.UserId] = nil end)

-- ── Entity helpers ────────────────────────────────────────────
local function getEntityModel(entity)
    if not entity then return nil end
    if entity:IsA("Player") then return entity.Character end
    if entity:IsA("BasePart") and entity:GetAttribute("OrbTarget") then return entity end
    return entity
end

local function setAimlockTarget(entity)
    Aimlock.target = entity
    Aimlock.targetModel = entity and getEntityModel(entity) or nil
end

-- ── Target Part Rotation  (state + weighted picker) ──────────
--  playerActiveTP / npcActiveTP : current part name (or nil).
--  playerActiveMiss / npcActiveMiss : true when the selected slot
--  is an empty "miss" slot (part = "") and miss is enabled —
--  getEntityAimPart returns nil so the aimlock skips the lock.
local playerActiveTP   = nil
local npcActiveTP      = nil
local playerActiveMiss = false
local npcActiveMiss    = false
local playerSitActiveTP   = nil
local npcSitActiveTP      = nil
local playerSitActiveMiss = false
local npcSitActiveMiss    = false

-- Common body parts shown in dropdowns (R15 + R6).
-- "(none)" means the slot acts as a miss slot when Miss is enabled.
local COMMON_PARTS = {
    "(none)",
    "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
    "LeftFoot", "RightFoot",
}

-- Returns how many chance points are still free for row `excl`
-- (100 minus the sum of all other rows under the same prefix).
local function getTPBudget(prefix, excl)
    local used = 0
    for i = 1, 5 do
        if i ~= excl then used = used + (S[prefix .. i .. "Chance"] or 0) end
    end
    return math.max(0, 100 - used)
end

-- Picks a weighted random slot.
--   missEnabled = true  → empty-name slots are treated as miss slots.
--   missEnabled = false → empty-name slots are skipped entirely.
-- Returns: partName (string), isMiss (bool)
local function pickWeightedPart(prefix, missEnabled)
    local valid, total = {}, 0
    for i = 1, 5 do
        local part   = S[prefix .. i .. "Part"]   or ""
        local chance = S[prefix .. i .. "Chance"] or 0
        if chance > 0 then
            if part ~= "" then
                total = total + chance
                table.insert(valid, { part = part, w = chance, miss = false })
            elseif missEnabled then
                total = total + chance
                table.insert(valid, { part = "",   w = chance, miss = true  })
            end
        end
    end
    if total == 0 then return nil, false end
    local r, cum = math.random() * total, 0
    for _, e in ipairs(valid) do
        cum = cum + e.w
        if r <= cum then return e.part, e.miss end
    end
    local last = valid[#valid]
    return last.part, last.miss
end

local function getEntityAimPart(entity)
    local model = getEntityModel(entity)
    if not model then return nil end
    if model:IsA("BasePart") and model:GetAttribute("OrbTarget") then
        return model
    end

    -- Target Part Rotation override.  Sitting targets use a separate profile
    -- when enabled, so a player or NPC can switch from (for example) Head 40%
    -- while standing to Head 100% while seated without changing the standing
    -- profile.
    local partName
    local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
    local isSitting = humanoid and humanoid.Sit == true
    local isPlayer = entity:IsA("Player")
    local isNPC = not isPlayer and not entity:IsA("BasePart")
    if isPlayer and isSitting and S.playerSitRotation and S.playerSitTPEnabled then
        if playerSitActiveMiss then return nil end
        partName = (playerSitActiveTP ~= nil and playerSitActiveTP ~= "")
            and playerSitActiveTP or nil
    elseif isNPC and isSitting and S.npcSitRotation and S.npcSitTPEnabled then
        if npcSitActiveMiss then return nil end
        partName = (npcSitActiveTP ~= nil and npcSitActiveTP ~= "")
            and npcSitActiveTP or nil
    elseif isPlayer and S.playerTPEnabled then
        if playerActiveMiss then return nil end
        partName = (playerActiveTP ~= nil and playerActiveTP ~= "")
            and playerActiveTP or nil
    elseif isNPC and S.npcTPEnabled then
        if npcActiveMiss then return nil end
        partName = (npcActiveTP ~= nil and npcActiveTP ~= "")
            and npcActiveTP or nil
    end
    partName = partName or ((S.aimlockPart and S.aimlockPart ~= "") and S.aimlockPart or nil)

    local useSitReference =
        isPlayer and S.playerSitRotation and not S.playerSitTPEnabled
        or (isNPC and S.npcSitRotation and not S.npcSitTPEnabled)
    if useSitReference then
        local sitRoot = model:FindFirstChild("HumanoidRootPart", true)
        if isSitting and sitRoot and sitRoot:IsA("BasePart") then
            return sitRoot
        end
    end

    if partName then
        local p = model:FindFirstChild(partName, true)
        if p and p:IsA("BasePart") then return p end
    end
    for _, name in ipairs(S.aimlockPartChain or { "Head", "HumanoidRootPart" }) do
        local p = model:FindFirstChild(name, true)
        if p and p:IsA("BasePart") then return p end
    end
    if model:IsA("Model") and model.PrimaryPart then return model.PrimaryPart end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

local function isEntityAlive(entity)
    local model = getEntityModel(entity)
    if not model or not model.Parent then return false end
    if model:IsA("BasePart") and model:GetAttribute("OrbTarget") then
        local data = getOrbData(model)
        return data ~= nil and data.state == "Active"
            and (tonumber(data.hp) or 0) > 0
    end
    local hum = model:FindFirstChildWhichIsA("Humanoid", true)
    return hum ~= nil and hum.Health > 0
end

-- ── Geometry helpers ──────────────────────────────────────────
local function wallBlocked(fromPos, toPart)
    if not S.aimlockWallCheck then return false end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = { LocalPlayer.Character }
    if toPart then
        -- Exclude the entire target model. Otherwise the ray can hit another
        -- body part or accessory on the target and mistake it for a wall.
        local targetModel = toPart:FindFirstAncestorOfClass("Model")
        if targetModel then
            table.insert(exclude, targetModel)
        elseif toPart.Parent then
            table.insert(exclude, toPart.Parent)
        end
    end
    rp.IgnoreWater = true
    local dir = toPart.Position - fromPos
    local ignoredHits = 0

    -- Continue the same ray after skipping configured non-blocking parts.
    -- This lets transparency and CanCollide filters work independently or
    -- together without allowing a later solid wall to be bypassed.
    while ignoredHits < 32 do
        rp.FilterDescendantsInstances = exclude
        local hit = workspace:Raycast(fromPos, dir, rp)
        if not hit then return false end

        local part = hit.Instance
        local skipTransparency =
            S.aimlockIgnoreTransparentWalls == true
            and part:IsA("BasePart")
            and part.Transparency > math.clamp(
                S.aimlockTransparencyThreshold or 0.5, 0, 1)
        local skipCanCollide =
            S.aimlockCanCollideWallCheck == true
            and part:IsA("BasePart")
            and part.CanCollide == false

        if not skipTransparency and not skipCanCollide then
            return true
        end

        table.insert(exclude, part)
        ignoredHits = ignoredHits + 1
    end

    -- A ray with an unusually large number of ignored objects is treated as
    -- blocked rather than being allowed through by the safety cap.
    return true
end

local function getTargetFOVRadius()
    return math.clamp(
        S.aimlockFOVRingSize or S.aimlockFOV or 200, 1, 350)
end

local function isInsideTargetFOV(part, cross)
    if not part or not part.Parent or not cross then return false end
    local screenPos = Camera:WorldToViewportPoint(part.Position)
    if screenPos.Z <= 0 then return false end
    local dx = screenPos.X - cross.X
    local dy = screenPos.Y - cross.Y
    local radius = getTargetFOVRadius()
    return dx * dx + dy * dy <= radius * radius
end

local function getEntityDistance2(entity, hrp)
    local part = getEntityAimPart(entity)
    if not part or not hrp then return math.huge end
    local delta = part.Position - hrp.Position
    return delta:Dot(delta)
end

local function crosshairScreenPos()
    local vp  = Camera.ViewportSize
    local pos = S.aimlockCrosshairPos or UDim2.new(0.5, 0, 0.5, 0)
    return Vector2.new(
        pos.X.Scale * vp.X + pos.X.Offset,
        pos.Y.Scale * vp.Y + pos.Y.Offset)
end

-- ── Velocity prediction ───────────────────────────────────────
local _velCache = {}
Players.PlayerRemoving:Connect(function(p) _velCache[p] = nil end)

local function predictedAimPoint(entity, hrp)
    local part = getEntityAimPart(entity)
    if not part then return nil end
    if not S.aimlockSmartAI then return part.Position, part end
    local v   = part.AssemblyLinearVelocity
    local now = tick()
    local accel = Vector3.zero
    local cache = _velCache[entity]
    if cache then
        local dt = math.max(now - cache.t, 1e-3)
        accel = (v - cache.v) / dt
        if accel.Magnitude > 500 then accel = accel.Unit * 500 end
    end
    _velCache[entity] = { v = v, t = now }
    if v.Magnitude < 0.5 and accel.Magnitude < 0.5 then return part.Position, part end
    local dist  = (part.Position - (hrp and hrp.Position or Camera.CFrame.Position)).Magnitude
    local leadT = math.clamp(dist / 1000, 0, 1.5) * (S.aimlockPredictStrength or 1)
    local lead  = v * leadT
    if S.aimlockPredictAccel then
        lead = lead + accel * (0.5 * leadT * leadT)
    end
    return part.Position + lead, part
end

-- ── Team helper ───────────────────────────────────────────────
local function p_team_eq(plr)
    return plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
end

local function isOnIgnoredTeam(plr)
    if not plr or not plr:IsA("Player") or not plr.Team then return false end
    return S.aimlockIgnoreTeams[string.lower(plr.Team.Name)] == true
end

-- ── Smart team check ───────────────────────────────────────────
-- Builds inferred teams from clothing asset IDs and meaningful clothing/
-- accessory names. Shared clothing keys join entities into the same group.
local smartTeamGroups = {}
local smartTeamLastScan = 0

local function addSmartClothingKey(keys, value)
    if value == nil then return end
    local text = tostring(value):lower():gsub("%s+", "")
    if text == "" or text == "0" then return end

    -- Roblox clothing templates are often URLs rather than plain IDs.
    local id = text:match("[?&]id=(%d+)") or text:match("(%d+)")
    if id then
        keys["id:" .. id] = true
    else
        keys["name:" .. text] = true
    end
end

local function getSmartClothingKeys(entity)
    local model = getEntityModel(entity)
    if not model then return {} end

    local keys = {}
    local hum = model:FindFirstChildWhichIsA("Humanoid")

    -- HumanoidDescription covers avatar clothing even when the visual
    -- Shirt/Pants instances have not finished replicating yet.
    if hum then
        pcall(function()
            local desc = hum:GetAppliedDescription()
            if desc then
                addSmartClothingKey(keys, desc.Shirt)
                addSmartClothingKey(keys, desc.Pants)
                addSmartClothingKey(keys, desc.GraphicTShirt)
            end
        end)
    end

    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("Shirt") then
            addSmartClothingKey(keys, obj.ShirtTemplate)
        elseif obj:IsA("Pants") then
            addSmartClothingKey(keys, obj.PantsTemplate)
        elseif obj:IsA("ShirtGraphic") then
            addSmartClothingKey(keys, obj.Graphic)
        end
    end

    return keys
end

local function rebuildSmartTeams()
    smartTeamGroups = {}
    smartTeamLastScan = tick()

    local entities = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(entities, plr) end
    end
    for model in pairs(npcCache) do
        table.insert(entities, model)
    end
    table.insert(entities, LocalPlayer)

    local parents = {}
    local keysByIndex = {}
    local indexByKey = {}

    local function findRoot(index)
        while parents[index] ~= index do
            parents[index] = parents[parents[index]]
            index = parents[index]
        end
        return index
    end

    local function union(a, b)
        local rootA, rootB = findRoot(a), findRoot(b)
        if rootA ~= rootB then parents[rootB] = rootA end
    end

    for index, entity in ipairs(entities) do
        parents[index] = index
        local keys = getSmartClothingKeys(entity)
        keysByIndex[index] = keys
        for key in pairs(keys) do
            if indexByKey[key] then
                union(index, indexByKey[key])
            else
                indexByKey[key] = index
            end
        end
    end

    for index, entity in ipairs(entities) do
        if next(keysByIndex[index]) then
            smartTeamGroups[entity] = findRoot(index)
        end
    end
end

local function isSmartTeamMatch(entity)
    if not S.aimlockSmartTeamCheck then return false end
    if tick() - smartTeamLastScan >= 0.5 then rebuildSmartTeams() end
    local localGroup = smartTeamGroups[LocalPlayer]
    return localGroup ~= nil and smartTeamGroups[entity] == localGroup
end

-- ── Validity checks ───────────────────────────────────────────
local function isValidPlayerTarget(plr, requireInFOV, cross, ignoreRange)
    if not plr or plr == LocalPlayer then return false end
    if not S.targetPlayers then return false end
    if isOnIgnoreList(plr) then return false end
    if isOnIgnoredTeam(plr) then return false end
    if not isEntityAlive(plr) then return false end
    local part = getEntityAimPart(plr); if not part then return false end
    local _, hrp = getCharParts(); if not hrp then return false end
    if not ignoreRange
    and (part.Position - hrp.Position).Magnitude > S.aimlockRange then return false end
    if wallBlocked(hrp.Position, part) then return false end
    local listed = isOnLockList(plr)
    if not listed then
        if S.aimlockTeamCheck and p_team_eq(plr) then return false end
        if isSmartTeamMatch(plr) then return false end
        if S.aimlockFriendCheck and isFriend(plr) then return false end
    end
    if requireInFOV and not isInsideTargetFOV(part, cross) then return false end
    return true
end

local function isValidNPCTarget(model, requireInFOV, cross, ignoreRange)
    if not model then return false end
    if not S.targetNPCs then return false end
    if isOnIgnoreList(model) then return false end
    if not isEntityAlive(model) then return false end
    local part = getEntityAimPart(model); if not part then return false end
    local _, hrp = getCharParts(); if not hrp then return false end
    if not ignoreRange
    and (part.Position - hrp.Position).Magnitude > S.aimlockRange then return false end
    if wallBlocked(hrp.Position, part) then return false end
    if isSmartTeamMatch(model) then return false end
    if requireInFOV and not isInsideTargetFOV(part, cross) then return false end
    return true
end

local function isValidOrbTarget(orb, requireInFOV, cross, ignoreRange)
    if not orb or not orb:IsA("BasePart") then return false end
    if not S.targetOrbs or not S.orbEnabled then return false end
    if not orb:GetAttribute("OrbTarget") or not isEntityAlive(orb) then return false end
    local _, hrp = getCharParts(); if not hrp then return false end
    if not ignoreRange
    and (orb.Position - hrp.Position).Magnitude > S.aimlockRange then return false end
    if wallBlocked(hrp.Position, orb) then return false end
    if requireInFOV and not isInsideTargetFOV(orb, cross) then return false end
    return true
end

local function isEntityValid(entity, requireInFOV, cross, ignoreRange)
    if entity:IsA("BasePart") and entity:GetAttribute("OrbTarget") then
        return isValidOrbTarget(entity, requireInFOV, cross, ignoreRange)
    elseif entity:IsA("Player") then
        return isValidPlayerTarget(entity, requireInFOV, cross, ignoreRange)
    else
        return isValidNPCTarget(entity, requireInFOV, cross, ignoreRange)
    end
end

local function isDistanceStickyEnabled()
    return S.targetBasedOffDistance == true
        and S.targetDistanceSticky == true
end

local function clearDistanceTargetAfterDeath(entity)
    if isDistanceStickyEnabled() and entity then
        Aimlock.distanceDeadTarget = entity
    end
    setAimlockTarget(nil)
end

-- ── Candidate list builder ─────────────────────────────────────
--  Reads from the event-driven npcCache — no GetDescendants() call.
--  Applies a squared-distance pre-filter on NPCs so only in-range
--  models ever reach the full validity check.
-- ──────────────────────────────────────────────────────────────
local function getCandidates()
    local list = {}
    if S.targetOrbs and S.orbEnabled then
        for _, data in ipairs(OrbSystem.saved) do
            if data.part and data.state == "Active" and (tonumber(data.hp) or 0) > 0 then
                table.insert(list, data.part)
            end
        end
    end
    if S.targetPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer
            and not (isDistanceStickyEnabled()
                and p == Aimlock.distanceDeadTarget) then
                table.insert(list, p)
            end
        end
    end
    if S.targetNPCs then
        local _, hrp = getCharParts()
        if hrp then
            -- Pre-compute squared range once (avoids repeated multiplication)
            local range = math.max(0, tonumber(S.aimlockRange) or 1000)
            local range2 = range * range
            local hx, hy, hz = hrp.Position.X, hrp.Position.Y, hrp.Position.Z
            for model in pairs(npcCache) do
                if isDistanceStickyEnabled()
                and model == Aimlock.distanceDeadTarget then
                    continue
                end
                -- Quick squared-distance check (no sqrt — cheapest possible filter)
                local data = npcCache[model]
                local root = data and data.root
                    or model.PrimaryPart
                    or model:FindFirstChild("HumanoidRootPart", true)
                    or model:FindFirstChildWhichIsA("BasePart", true)
                if root and isEntityAlive(model) then
                    local dx = root.Position.X - hx
                    local dy = root.Position.Y - hy
                    local dz = root.Position.Z - hz
                    if (dx*dx + dy*dy + dz*dz) <= range2 then
                        table.insert(list, model)
                    end
                end
            end
        else
            -- No HRP yet — include everything and let validity check handle it
            for model in pairs(npcCache) do
                if not (isDistanceStickyEnabled()
                    and model == Aimlock.distanceDeadTarget) then
                    table.insert(list, model)
                end
            end
        end
    end
    return list
end

-- ── Acquire best target from FOV ─────────────────────────────
local function acquireTarget()
    local _, hrp = getCharParts(); if not hrp then return nil end
    local cross = crosshairScreenPos()
    local bestListed, bestListedDist = nil, math.huge
    local bestAny,    bestAnyDist    = nil, math.huge
    for _, entity in ipairs(getCandidates()) do
        if isEntityValid(entity, true, cross) then
            local part = getEntityAimPart(entity)
            if part then
                local sp = Camera:WorldToViewportPoint(part.Position)
                local dx, dy = sp.X - cross.X, sp.Y - cross.Y
                local screenD2 = dx * dx + dy * dy
                local d2 = S.targetBasedOffDistance
                    and getEntityDistance2(entity, hrp)
                    or screenD2
                if isOnLockList(entity) then
                    if d2 < bestListedDist then bestListedDist, bestListed = d2, entity end
                else
                    if d2 < bestAnyDist then bestAnyDist, bestAny = d2, entity end
                end
            end
        end
    end
    return bestListed or bestAny
end

-- ── Switch-targets helpers ────────────────────────────────────
--  In-FOV targets (sorted by screen dist) come before out-FOV (sorted by world dist).
local function buildSwitchList()
    local _, hrp = getCharParts(); if not hrp then return {} end
    local cross = crosshairScreenPos()
    local fovRadius = getTargetFOVRadius()
    local fovR2  = fovRadius * fovRadius
    local requireInFOV = S.targetBasedOffDistance == true
    local inFov  = {}
    local outFov = {}
    for _, entity in ipairs(getCandidates()) do
        if isEntityValid(entity, requireInFOV, cross) then
            local part = getEntityAimPart(entity)
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and sp.Z > 0 then
                    local dx, dy = sp.X - cross.X, sp.Y - cross.Y
                    local screenD2 = dx * dx + dy * dy
                    if screenD2 <= fovR2 then
                        table.insert(inFov,  { entity = entity, dist = screenD2 })
                    else
                        table.insert(outFov, { entity = entity,
                            dist = (part.Position - hrp.Position).Magnitude })
                    end
                else
                    table.insert(outFov, { entity = entity,
                        dist = (part.Position - hrp.Position).Magnitude })
                end
            end
        end
    end
    if S.targetBasedOffDistance then
        table.sort(inFov, function(a, b)
            return getEntityDistance2(a.entity, hrp) < getEntityDistance2(b.entity, hrp)
        end)
        table.sort(outFov, function(a, b)
            return getEntityDistance2(a.entity, hrp) < getEntityDistance2(b.entity, hrp)
        end)
    else
        table.sort(inFov,  function(a, b) return a.dist < b.dist end)
        table.sort(outFov, function(a, b) return a.dist < b.dist end)
    end
    local result = {}
    for _, v in ipairs(inFov)  do table.insert(result, v.entity) end
    for _, v in ipairs(outFov) do table.insert(result, v.entity) end
    return result
end

local function switchTarget(dir)
    local list = buildSwitchList()
    if #list == 0 then return end
    local curIdx = 0
    for i, e in ipairs(list) do
        if e == Aimlock.target then curIdx = i; break end
    end
    local newIdx = curIdx + dir
    if newIdx < 1 then newIdx = #list end
    if newIdx > #list then newIdx = 1 end
    setAimlockTarget(list[newIdx])
    Aimlock.targetLostAt = 0
end

-- ============================================================
--  NPC ESP  (BillboardGui square — see-through-walls, Heartbeat-driven)
-- ============================================================
--  espBoxes[model] = { gui=BillboardGui, frame=Frame, lbl=TextLabel }
--  BillboardGui is parented to the cached NPC root part so it auto-
--  follows in 3D and auto-destroys when the root leaves the game.
--  updateESPBoxes() runs on RunService.Heartbeat at ~10 fps — never
--  on BindToRenderStep — so it cannot cause render-thread frame drops.
-- ============================================================
local espBoxes = {}

-- Cached Color3 so Color3.fromRGB() is not called every tick
local _espColorR, _espColorG, _espColorB = -1, -1, -1
local _espCachedColor = Color3.fromRGB(255, 50, 50)

local function getESPColor()
    local r, g, b = S.espBoxColorR, S.espBoxColorG, S.espBoxColorB
    if r ~= _espColorR or g ~= _espColorG or b ~= _espColorB then
        _espCachedColor  = Color3.fromRGB(r, g, b)
        _espColorR, _espColorG, _espColorB = r, g, b
        -- Propagate new color to all already-created boxes immediately
        for _, e in pairs(espBoxes) do
            if e.frame then e.frame.BackgroundColor3 = _espCachedColor end
            if e.lbl   then e.lbl.TextColor3         = _espCachedColor end
        end
    end
    return _espCachedColor
end

local function removeESPBox(model)
    local e = espBoxes[model]
    if not e then return end
    if e.gui then pcall(function() e.gui:Destroy() end) end
    espBoxes[model] = nil
end

local function clearAllESPBoxes()
    for model in pairs(espBoxes) do
        removeESPBox(model)
    end
end

local function updateESPHealthBar(entry, hum, inRange)
    if not entry then return end
    local alive = hum and hum.Parent and hum.Health > 0
    local maxHealth = math.max(hum and hum.MaxHealth or 0, 1)
    local fraction = math.clamp((hum and hum.Health or 0) / maxHealth, 0, 1)

    local showBar = S.espHealthBar == true and alive and inRange == true
    if entry.healthBack then
        entry.healthBack.Visible = showBar
        if showBar and entry.healthFill then
            entry.healthFill.Size = UDim2.new(1, 0, fraction, 0)
            entry.healthFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - fraction)),
                math.floor(220 * fraction),
                40)
        end
    end

    local showHealth = S.espShowHealth == true and alive and inRange == true
    if entry.healthGui then entry.healthGui.Enabled = showHealth end
    if entry.healthTextGui then entry.healthTextGui.Enabled = showHealth end
    if showHealth then
        if entry.healthCircleFill then
            entry.healthCircleFill.Size = UDim2.new(1, 0, fraction, 0)
            entry.healthCircleFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - fraction)),
                math.floor(220 * fraction),
                50)
        end
        if entry.healthText then
            entry.healthText.Text = string.format("%d / %d", math.ceil(hum.Health), math.ceil(maxHealth))
        end
    end
end

-- Creation queue — BillboardGuis are built here, then handed to the loop
local _espCreateQueue = {}   -- list of models waiting for GUI creation

local function flushCreateQueue(budget)
    local count = 0
    local boxSz   = math.max(8, S.espBoxSize)
    local boxCol  = getESPColor()
    local showTag = S.espNameTag == true
    local LABEL_H = 18

    for i = #_espCreateQueue, 1, -1 do
        local model = _espCreateQueue[i]
        table.remove(_espCreateQueue, i)

        -- Model may have died between queue and flush — skip if so
        local data = npcCache[model]
        if isAliveNPC(model, data) and data.root and data.root.Parent
        and not espBoxes[model] then
            local root = data.root

            local gui = Instance.new("BillboardGui")
            gui.Name             = "NPC_ESP"
            gui.Size             = UDim2.new(0, boxSz, 0, boxSz + LABEL_H)
            gui.StudsOffset      = Vector3.new(0, 3.5, 0)
            gui.AlwaysOnTop      = true    -- renders through walls
            gui.ResetOnSpawn     = false
            gui.ClipsDescendants = false
            gui.Enabled          = true
            gui.Parent           = root

            local lbl = Instance.new("TextLabel")
            lbl.Name                   = "NameTag"
            lbl.Size                   = UDim2.new(1, 0, 0, LABEL_H)
            lbl.Position               = UDim2.new(0, 0, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = model.Name
            lbl.TextColor3             = boxCol
            lbl.TextScaled             = true
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextStrokeTransparency = 0.3
            lbl.Visible                = showTag
            lbl.Parent                 = gui

            local frame = Instance.new("Frame")
            frame.Name             = "ESPSquare"
            frame.Size             = UDim2.new(1, 0, 0, boxSz)
            frame.Position         = UDim2.new(0, 0, 0, LABEL_H)
            frame.BackgroundColor3 = boxCol
            frame.BorderSizePixel  = 0
            frame.Parent           = gui

            -- Black outline — fixed color, not adjustable
            local stroke = Instance.new("UIStroke")
            stroke.Color     = Color3.fromRGB(0, 0, 0)
            stroke.Thickness = 2
            stroke.Parent    = frame

            -- Health bar sits just outside the right edge of the box.
            local healthBack = Instance.new("Frame")
            healthBack.Name                   = "HealthBarBackground"
            healthBack.Size                   = UDim2.new(0, 6, 0, boxSz)
            healthBack.Position               = UDim2.new(1, 5, 0, LABEL_H)
            healthBack.BackgroundColor3       = Color3.fromRGB(20, 20, 20)
            healthBack.BorderSizePixel        = 0
            healthBack.Visible                = false
            healthBack.Parent                 = gui

            local healthFill = Instance.new("Frame")
            healthFill.Name                   = "HealthBarFill"
            healthFill.AnchorPoint            = Vector2.new(0, 1)
            healthFill.Position               = UDim2.new(0, 0, 1, 0)
            healthFill.Size                   = UDim2.new(1, 0, 1, 0)
            healthFill.BackgroundColor3       = Color3.fromRGB(40, 220, 40)
            healthFill.BorderSizePixel        = 0
            healthFill.Parent                 = healthBack

            local entry = {
                gui = gui,
                frame = frame,
                lbl = lbl,
                healthBack = healthBack,
                healthFill = healthFill,
            }

            -- Optional health circle beside the box.  It is a separate,
            -- reusable BillboardGui so toggling it never rebuilds the box.
            local healthGui = Instance.new("BillboardGui")
            healthGui.Name = "NPC_HealthDisplay"
            healthGui.Size = UDim2.new(0, 58, 0, 72)
            healthGui.StudsOffset = Vector3.new(3.4, 2.8, 0)
            healthGui.AlwaysOnTop = true
            healthGui.ResetOnSpawn = false
            healthGui.Enabled = false
            healthGui.Parent = root

            local healthCircle = Instance.new("Frame")
            healthCircle.Name = "HealthCircle"
            healthCircle.Size = UDim2.new(0, 42, 0, 42)
            healthCircle.Position = UDim2.new(0.5, -21, 0, 0)
            healthCircle.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
            healthCircle.BorderSizePixel = 0
            healthCircle.ClipsDescendants = true
            healthCircle.Parent = healthGui
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(0.5, 0)
            circleCorner.Parent = healthCircle
            local circleStroke = Instance.new("UIStroke")
            circleStroke.Color = Color3.fromRGB(125, 220, 255)
            circleStroke.Thickness = 2
            circleStroke.Parent = healthCircle

            local circleFill = Instance.new("Frame")
            circleFill.Name = "HealthCircleFill"
            circleFill.AnchorPoint = Vector2.new(0, 1)
            circleFill.Position = UDim2.new(0, 0, 1, 0)
            circleFill.Size = UDim2.new(1, 0, 1, 0)
            circleFill.BackgroundColor3 = Color3.fromRGB(60, 220, 130)
            circleFill.BorderSizePixel = 0
            circleFill.Parent = healthCircle
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0.5, 0)
            fillCorner.Parent = circleFill

            local healthText = Instance.new("TextLabel")
            healthText.Name = "HealthText"
            healthText.Size = UDim2.new(1, 0, 0, 22)
            healthText.Position = UDim2.new(0, 0, 0, 45)
            healthText.BackgroundTransparency = 1
            healthText.TextColor3 = Color3.fromRGB(240, 248, 255)
            healthText.TextStrokeTransparency = 0.35
            healthText.Font = Enum.Font.GothamBold
            healthText.TextScaled = true
            local healthTextGui = Instance.new("BillboardGui")
            healthTextGui.Name = "NPC_TorsoHealthText"
            healthTextGui.Size = UDim2.new(0, 108, 0, 24)
            healthTextGui.StudsOffset = Vector3.new(0, 1.65, 0)
            healthTextGui.AlwaysOnTop = true
            healthTextGui.ResetOnSpawn = false
            healthTextGui.Enabled = false
            healthTextGui.Parent = root
            healthText.Parent = healthTextGui

            entry.healthGui = healthGui
            entry.healthCircleFill = circleFill
            entry.healthText = healthText
            entry.healthTextGui = healthTextGui
            espBoxes[model] = entry
            updateESPHealthBar(entry, data.hum, true)

            count = count + 1
            if count >= budget then break end
        end
    end
end

-- Called on Heartbeat at ~10 fps — never on BindToRenderStep
local function updateESPBoxes()
    if not S.espEnabled then
        -- Turn off: disable all GUIs and clear the creation queue
        for _, e in pairs(espBoxes) do
            if e.gui then e.gui.Enabled = false end
        end
        _espCreateQueue = {}
        return
    end

    local _, hrp = getCharParts()
    if not hrp then return end

    local range2   = S.espDistance * S.espDistance
    local healthRange = math.max(0, tonumber(S.espHealthDisplayDistance) or S.espDistance)
    local healthRange2 = healthRange * healthRange
    local hPos     = hrp.Position
    local boxCol   = getESPColor()
    local showTag  = S.espNameTag == true

    -- ── Flush up to 3 pending GUI creations per tick ─────────
    flushCreateQueue(3)

    -- ── Range + visibility pass over the NPC cache ────────────
    for model, data in pairs(npcCache) do
        local root = data.root
        if not isAliveNPC(model, data) or not root or not root.Parent then
            -- Root destroyed without a DescendantRemoving event
            npcCache[model] = nil
            removeESPBox(model)
        else
            local rPos = root.Position
            local dx   = rPos.X - hPos.X
            local dy   = rPos.Y - hPos.Y
            local dz   = rPos.Z - hPos.Z
            local inRange = (dx*dx + dy*dy + dz*dz) <= range2
            local healthInRange = (dx*dx + dy*dy + dz*dz) <= healthRange2

            if inRange then
                local e = espBoxes[model]
                if not e then
                    -- Queue creation (capped per tick to spread the cost)
                    local already = false
                    for _, m in ipairs(_espCreateQueue) do
                        if m == model then already = true; break end
                    end
                    if not already then
                        table.insert(_espCreateQueue, model)
                    end
                else
                    e.gui.Enabled = true
                    if e.lbl then e.lbl.Visible = showTag end
                    updateESPHealthBar(e, data.hum, healthInRange)
                end
            else
                local e = espBoxes[model]
                if e then
                    if e.gui then e.gui.Enabled = false end
                    updateESPHealthBar(e, data.hum, healthInRange)
                end
            end
        end
    end

    -- ── Cleanup: destroy boxes for NPCs no longer in cache ────
    for model in pairs(espBoxes) do
        if not npcCache[model] then
            removeESPBox(model)
        end
    end
end


-- ============================================================
--  CROSSHAIR GUI
-- ============================================================
local function syncCrosshairShape()
    local hasImage = type(S.aimlockCrosshairImage) == "string"
        and S.aimlockCrosshairImage:gsub("%s+", "") ~= ""
    local isCross = S.aimlockCrosshairShape == "cross"
    if Aimlock.crosshairImage then Aimlock.crosshairImage.Visible = hasImage end
    if Aimlock.crosshairDot then Aimlock.crosshairDot.Visible = not hasImage and not isCross end
    if Aimlock.crosshairCrossH then Aimlock.crosshairCrossH.Visible = not hasImage and isCross end
    if Aimlock.crosshairCrossV then Aimlock.crosshairCrossV.Visible = not hasImage and isCross end
end

local function normalizeCrosshairImage(value)
    local text = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return "" end
    local id = text:match("^https?://www%.roblox%.com/asset/%?id=(%d+)")
        or text:match("^https?://create%.roblox%.com/marketplace/asset/(%d+)")
        or text:match("^(%d+)$")
    if id then return "rbxassetid://" .. id end
    if text:match("^rbxassetid://%d+$") then return text end
    return text
end

local function syncCrosshairImage()
    local image = normalizeCrosshairImage(S.aimlockCrosshairImage)
    S.aimlockCrosshairImage = image
    if Aimlock.crosshairImage then
        Aimlock.crosshairImage.Image = image
        Aimlock.crosshairImage.ImageTransparency = S.aimlockCrosshairOpacity or 0
    end
    syncCrosshairShape()
end

local function applyCrosshairPosition(pos)
    local x = math.clamp(pos.X.Scale + pos.X.Offset / math.max(Camera.ViewportSize.X, 1), 0, 1)
    local y = math.clamp(pos.Y.Scale + pos.Y.Offset / math.max(Camera.ViewportSize.Y, 1), 0, 1)
    local normalized = UDim2.new(x, 0, y, 0)
    S.aimlockCrosshairPos = normalized

    if Aimlock.fovCircle then Aimlock.fovCircle.Position = normalized end
    if Aimlock.crosshairDot then Aimlock.crosshairDot.Position = normalized end
    if Aimlock.crosshairCrossH then Aimlock.crosshairCrossH.Position = normalized end
    if Aimlock.crosshairCrossV then Aimlock.crosshairCrossV.Position = normalized end
    if Aimlock.crosshairImage then Aimlock.crosshairImage.Position = normalized end
    if Aimlock.statusLabel then
        Aimlock.statusLabel.Position = UDim2.new(x, 0, y, 28)
    end
end

local function makeCrosshairGui()
    if Aimlock.crosshairGui then return end
    local sg = Instance.new("ScreenGui")
    sg.Name           = "AimlockCrosshairGui"
    sg.ResetOnSpawn   = false
    sg.IgnoreGuiInset = true
    sg.Parent         = LocalPlayer:WaitForChild("PlayerGui")

    -- FOV ring
    local ring = Instance.new("Frame")
    ring.Name              = "FOVRing"
    ring.AnchorPoint       = Vector2.new(0.5, 0.5)
    ring.Position          = S.aimlockCrosshairPos
    local ringRadius = getTargetFOVRadius()
    ring.Size              = UDim2.new(0, ringRadius * 2, 0, ringRadius * 2)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel   = 0
    ring.Visible           = S.aimlockShowFOV == true
    ring.Parent            = sg
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0.5, 0); rc.Parent = ring
    local rs = Instance.new("UIStroke")
    rs.Thickness   = 2
    rs.Color       = Color3.fromRGB(S.aimlockFOVColorR, S.aimlockFOVColorG, S.aimlockFOVColorB)
    rs.Transparency= 0.15
    rs.Parent      = ring
    Aimlock.fovCircle = ring
    Aimlock.fovStroke = rs

    -- Crosshair dot
    local dot = Instance.new("Frame")
    dot.Name               = "CrosshairDot"
    dot.Size               = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint        = Vector2.new(0.5, 0.5)
    dot.Position           = S.aimlockCrosshairPos
    dot.BackgroundColor3   = Color3.fromRGB(255, 40, 40)
    dot.BackgroundTransparency = S.aimlockCrosshairOpacity or 0
    dot.BorderSizePixel    = 0
    dot.Parent             = sg
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0.5, 0); dc.Parent = dot
    local ds = Instance.new("UIStroke")
    ds.Thickness = 2; ds.Color = Color3.fromRGB(255,255,255); ds.Transparency = 0.2; ds.Parent = dot
    Aimlock.crosshairDot = dot

    -- Optional image/decal crosshair.  It replaces either generated shape
    -- while an ID is present; clearing the setting restores the selected
    -- dot/cross shape.
    local image = Instance.new("ImageLabel")
    image.Name               = "CrosshairImage"
    image.Size               = UDim2.new(0, 26, 0, 26)
    image.AnchorPoint        = Vector2.new(0.5, 0.5)
    image.Position           = S.aimlockCrosshairPos
    image.BackgroundTransparency = 1
    image.Image              = normalizeCrosshairImage(S.aimlockCrosshairImage)
    image.ImageTransparency  = S.aimlockCrosshairOpacity or 0
    image.ScaleType          = Enum.ScaleType.Fit
    image.Parent             = sg
    Aimlock.crosshairImage = image

    -- Crosshair cross — very thin horizontal line
    local crossH = Instance.new("Frame")
    crossH.Name               = "CrosshairCrossH"
    crossH.Size               = UDim2.new(0, 28, 0, 1)
    crossH.AnchorPoint        = Vector2.new(0.5, 0.5)
    crossH.Position           = S.aimlockCrosshairPos
    crossH.BackgroundColor3   = Color3.fromRGB(255, 40, 40)
    crossH.BackgroundTransparency = S.aimlockCrosshairOpacity or 0
    crossH.BorderSizePixel    = 0
    crossH.Parent             = sg
    Aimlock.crosshairCrossH = crossH

    -- Crosshair cross — very thin vertical line
    local crossV = Instance.new("Frame")
    crossV.Name               = "CrosshairCrossV"
    crossV.Size               = UDim2.new(0, 1, 0, 28)
    crossV.AnchorPoint        = Vector2.new(0.5, 0.5)
    crossV.Position           = S.aimlockCrosshairPos
    crossV.BackgroundColor3   = Color3.fromRGB(255, 40, 40)
    crossV.BackgroundTransparency = S.aimlockCrosshairOpacity or 0
    crossV.BorderSizePixel    = 0
    crossV.Parent             = sg
    Aimlock.crosshairCrossV = crossV

    syncCrosshairShape()
    syncCrosshairImage()

    -- Status label
    local lbl = Instance.new("TextLabel")
    lbl.AnchorPoint        = Vector2.new(0.5, 0)
    lbl.Position           = UDim2.new(S.aimlockCrosshairPos.X.Scale, 0,
                                       S.aimlockCrosshairPos.Y.Scale, 28)
    lbl.Size               = UDim2.new(0, 220, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextScaled         = true
    lbl.TextColor3         = Color3.fromRGB(255, 80, 80)
    lbl.TextStrokeTransparency = 0.4
    lbl.Text               = ""
    lbl.Parent             = sg

    Aimlock.crosshairGui = sg
    Aimlock.statusLabel  = lbl
end

local function destroyCrosshairGui()
    if Aimlock.crosshairGui then
        pcall(function() Aimlock.crosshairGui:Destroy() end)
        Aimlock.crosshairGui    = nil
        Aimlock.crosshairDot    = nil
        Aimlock.crosshairCrossH = nil
        Aimlock.crosshairCrossV = nil
        Aimlock.crosshairImage  = nil
        Aimlock.fovCircle       = nil
        Aimlock.fovStroke       = nil
        Aimlock.statusLabel     = nil
    end
end

local function setAimlock(on)
    S.aimlockEnabled = on
    if on then
        makeCrosshairGui()
    else
        destroyCrosshairGui()
        setAimlockTarget(nil)
        Aimlock.distanceDeadTarget = nil
        Aimlock.targetLostAt = 0
    end
    if _G.__FlyScript_UpdateAimlockBtn then pcall(_G.__FlyScript_UpdateAimlockBtn) end
end
_G.__FlyScript_SetAimlock = setAimlock

-- ============================================================
--  RENDER LOOP  (camera + crosshair sync)
-- ============================================================
RunService:BindToRenderStep("FlyAimlock", Enum.RenderPriority.Camera.Value + 2, function()
    if not S.aimlockEnabled then return end
    if S.aimlockHoldToAim and not Aimlock._holdActive then
        if Aimlock.statusLabel then Aimlock.statusLabel.Text = "" end
        return
    end

    -- Sync crosshair position & opacity
    local opacity = S.aimlockCrosshairOpacity or 0
    local pos     = S.aimlockCrosshairPos
    if Aimlock.crosshairDot then
        Aimlock.crosshairDot.Position           = pos
        Aimlock.crosshairDot.BackgroundTransparency = opacity
    end
    if Aimlock.crosshairCrossH then
        Aimlock.crosshairCrossH.Position           = pos
        Aimlock.crosshairCrossH.BackgroundTransparency = opacity
    end
    if Aimlock.crosshairCrossV then
        Aimlock.crosshairCrossV.Position           = pos
        Aimlock.crosshairCrossV.BackgroundTransparency = opacity
    end
    if Aimlock.crosshairImage then
        Aimlock.crosshairImage.Position         = pos
        Aimlock.crosshairImage.ImageTransparency = opacity
    end
    syncCrosshairShape()

    -- Sync FOV ring
    if Aimlock.fovCircle then
        Aimlock.fovCircle.Visible  = S.aimlockShowFOV == true
        Aimlock.fovCircle.Position = pos
        local ringRadius = getTargetFOVRadius()
        Aimlock.fovCircle.Size     = UDim2.new(0, ringRadius * 2, 0, ringRadius * 2)
        if Aimlock.fovStroke then
            Aimlock.fovStroke.Color = Color3.fromRGB(
                S.aimlockFOVColorR, S.aimlockFOVColorG, S.aimlockFOVColorB)
        end
    end
    if Aimlock.statusLabel then
        Aimlock.statusLabel.Position = UDim2.new(pos.X.Scale, 0, pos.Y.Scale, 28)
    end

    -- Miss chance
    local missPct = math.clamp(S.aimlockMissChance or 0, 0, 90)
    if missPct > 0 and math.random(1, 100) <= missPct then return end

    local _, hrp = getCharParts()
    if not hrp then return end
    local cross = crosshairScreenPos()

    -- Humanizer jitter
    local humPx = math.max(0, S.aimlockHumanize or 0)
    if humPx > 0 then
        cross = Vector2.new(
            cross.X + (math.random() - 0.5) * 2 * humPx,
            cross.Y + (math.random() - 0.5) * 2 * humPx)
    end

    -- Target acquisition
    if S.switchTargetsEnabled then
        local targetDied = Aimlock.target and (
            not isEntityAlive(Aimlock.target)
            or Aimlock.targetModel ~= getEntityModel(Aimlock.target))
        local targetInvalid = targetDied
        if Aimlock.target and isDistanceStickyEnabled()
        and not targetDied
        and not isEntityValid(Aimlock.target, false, cross, true) then
            targetInvalid = true
        end
        if targetDied and isDistanceStickyEnabled() then
            -- Remember the Player/NPC whose original character died so a
            -- respawn cannot immediately become the next sticky target.
            Aimlock.distanceDeadTarget = Aimlock.target
        end
        if Aimlock.target and S.targetBasedOffDistance
        and not isDistanceStickyEnabled()
        and not isEntityValid(Aimlock.target, true, cross) then
            targetInvalid = true
        end
        if targetInvalid then
            local list = buildSwitchList()
            setAimlockTarget(#list > 0 and list[1] or nil)
        end
        if not Aimlock.target then
            local list = buildSwitchList()
            setAimlockTarget(#list > 0 and list[1] or nil)
        end
    else
        local cur  = Aimlock.target
        local keep = false
        if cur and (S.aimlockStickyLock or isDistanceStickyEnabled()) then
            if isDistanceStickyEnabled() then
                -- Distance sticky mode ignores FOV and range after the
                -- initial target is acquired, but still enforces wall,
                -- team, friend, ignore-list, and target-mode checks.
                -- The exact-model check prevents a respawn from inheriting
                -- the previous character's lock.
                if Aimlock.targetModel == getEntityModel(cur)
                and isEntityValid(cur, false, cross, true) then
                    keep = true
                    Aimlock.targetLostAt = 0
                else
                    if not isEntityAlive(cur)
                    or Aimlock.targetModel ~= getEntityModel(cur) then
                        clearDistanceTargetAfterDeath(cur)
                    else
                        setAimlockTarget(nil)
                    end
                    Aimlock.targetLostAt = 0
                end
            else
                local mustStayInFOV = S.targetBasedOffDistance == true
                if isEntityValid(cur, mustStayInFOV, cross) then
                    keep = true
                    Aimlock.targetLostAt = 0
                else
                    if Aimlock.targetLostAt == 0 then Aimlock.targetLostAt = tick() end
                    if not S.targetBasedOffDistance
                    and (tick() - Aimlock.targetLostAt) < (S.aimlockReacquireDelay or 0.6)
                    and cur and cur.Parent and isEntityAlive(cur) then
                        keep = true
                    else
                        setAimlockTarget(nil)
                        Aimlock.targetLostAt = 0
                    end
                end
            end
        end
        if not keep or not Aimlock.target then
            setAimlockTarget(acquireTarget())
            Aimlock.targetLostAt = 0
        end
    end

    local t = Aimlock.target
    if not t then
        if Aimlock.statusLabel then Aimlock.statusLabel.Text = "" end
        return
    end

    local aimPos = predictedAimPoint(t, hrp)
    if not aimPos then
        if Aimlock.statusLabel then Aimlock.statusLabel.Text = "" end
        return
    end

    local camPos   = Camera.CFrame.Position
    local lookCF   = CFrame.lookAt(camPos, aimPos)
    local vp       = Camera.ViewportSize
    local fovY     = math.rad(Camera.FieldOfView)
    local focal    = (vp.Y * 0.5) / math.tan(fovY * 0.5)
    local pxOffX   = cross.X - vp.X * 0.5
    local pxOffY   = cross.Y - vp.Y * 0.5
    local yawOff   = math.atan(pxOffX / focal)
    local pitchOff = math.atan(pxOffY / focal)
    local targetCF = lookCF * CFrame.Angles(pitchOff, yawOff, 0)
    local smooth   = math.clamp(S.aimlockSmoothing or 1, 0.05, 1)
    local newCF    = Camera.CFrame:Lerp(targetCF, smooth)
    local maxDeg   = S.aimlockMaxDegPerFrame or 0
    if maxDeg > 0 then
        local dotV   = math.clamp(Camera.CFrame.LookVector:Dot(newCF.LookVector), -1, 1)
        local angDeg = math.deg(math.acos(dotV))
        if angDeg > maxDeg then newCF = Camera.CFrame:Lerp(newCF, maxDeg / angDeg) end
    end
    Camera.CFrame = newCF

    if Aimlock.statusLabel then
        local tag = isOnLockList(t) and " [LIST]" or ""
        Aimlock.statusLabel.Text = "Locked: " .. t.Name .. tag
    end
end)

-- ============================================================
--  ESP HEARTBEAT  (~10 fps — fully off the render thread)
-- ============================================================
--  Running ESP on Heartbeat instead of BindToRenderStep means it
--  can NEVER cause a render-frame drop.  The 0.1 s budget cap also
--  means even heavy NPC scenes only do one distance-check sweep
--  ten times a second, not sixty.
-- ============================================================
do
    local _espAccum = 0
    RunService.Heartbeat:Connect(function(dt)
        _espAccum = _espAccum + dt
        if _espAccum < 0.1 then return end   -- ~10 fps
        _espAccum = 0
        pcall(updateESPBoxes)                -- pcall isolates any runtime error
    end)
end


-- ============================================================
--  KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode
    if k == S.aimlockKey then
        if S.aimlockHoldToAim then
            Aimlock._holdActive = true
            if not S.aimlockEnabled then setAimlock(true) end
        else
            setAimlock(not S.aimlockEnabled)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if S.aimlockHoldToAim and input.KeyCode == S.aimlockKey then
        Aimlock._holdActive = false
    end
end)

-- ============================================================
--  SCREEN GUI
-- ============================================================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local previousSG = playerGui:FindFirstChild("AimlockUI")
if previousSG then pcall(function() previousSG:Destroy() end) end
local SG = Instance.new("ScreenGui")
SG.Name            = "AimlockUI"
SG.ResetOnSpawn    = false
SG.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset  = true
SG.DisplayOrder    = 10
SG.Parent          = playerGui

local editActive     = false
local allButtons     = {}
local buttonRegistry = {}
local DRAG_THRESH    = 12

local function makeButton(name, initPos, initSize, labelText, bgColor, callback)
    local frame = Instance.new("Frame")
    frame.Name                  = name
    frame.Size                  = initSize
    frame.Position              = initPos
    frame.BackgroundColor3      = bgColor
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel       = 0
    frame.Active                = true
    frame.Parent                = SG
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = frame end

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1,0,1,0); icon.BackgroundTransparency = 1
    icon.Image = ""; icon.ScaleType = Enum.ScaleType.Fit; icon.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Lbl"; lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextStrokeTransparency = 0.4; lbl.ZIndex = 2; lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 5; btn.Parent = frame

    local activeTouches    = {}
    local currentDragTouch = nil
    local pinchStartDist   = nil
    local pinchStartSize   = nil

    local function getTouchList()
        local list = {}
        for inp in pairs(activeTouches) do table.insert(list, inp) end
        return list
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        activeTouches[input] = { startPos = input.Position,
            startFramePos = frame.Position, dragging = false }
        local list = getTouchList()
        if #list == 2 then
            pinchStartDist = (list[1].Position - list[2].Position).Magnitude
            pinchStartSize = frame.Size
        end
    end)

    btn.InputChanged:Connect(function(input)
        local info = activeTouches[input]; if not info then return end
        local list = getTouchList()
        if #list == 2 and pinchStartDist and pinchStartDist > 0 and editActive then
            local newDist = (list[1].Position - list[2].Position).Magnitude
            local scale   = newDist / pinchStartDist
            local px = math.clamp(
                (pinchStartSize.X.Offset > 0 and pinchStartSize.X.Offset or 72) * scale, 48, 128)
            frame.Size = UDim2.new(0, px, 0, px)
            return
        end
        local delta = input.Position - info.startPos
        if not info.dragging and delta.Magnitude >= DRAG_THRESH and editActive then
            info.dragging = true; currentDragTouch = input
        end
        if info.dragging and currentDragTouch == input and editActive then
            frame.Position = UDim2.new(
                info.startFramePos.X.Scale,
                info.startFramePos.X.Offset + delta.X,
                info.startFramePos.Y.Scale,
                info.startFramePos.Y.Offset + delta.Y)
        end
    end)

    btn.InputEnded:Connect(function(input)
        local info = activeTouches[input]; if not info then return end
        if not info.dragging then callback() end
        activeTouches[input] = nil
        if currentDragTouch == input then currentDragTouch = nil end
        local list = getTouchList()
        if #list < 2 then pinchStartDist = nil; pinchStartSize = nil end
    end)

    btn.MouseButton1Click:Connect(function()
        if not next(activeTouches) then callback() end
    end)

    local obj = { frame = frame, lbl = lbl, icon = icon }
    table.insert(allButtons, obj)
    return obj
end

-- ── Aimlock button ────────────────────────────────────────────
local aimlockBtnObj = makeButton("AimlockBtn", S.aimlockBtnPos, S.btnSize, "AIM",
    Color3.fromRGB(40, 20, 20),
    function()
        if S.aimlockHoldToAim then return end
        if _G.__FlyScript_SetAimlock then _G.__FlyScript_SetAimlock(not S.aimlockEnabled) end
    end)
table.insert(buttonRegistry, { obj = aimlockBtnObj, sKey = "aimlockBtnPos" })
do
    local function isHoldInput(i)
        return i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1
    end
    aimlockBtnObj.frame.InputBegan:Connect(function(i)
        if not S.aimlockHoldToAim then return end
        if not isHoldInput(i) then return end
        Aimlock._holdActive = true
        if not S.aimlockEnabled and _G.__FlyScript_SetAimlock then
            _G.__FlyScript_SetAimlock(true) end
    end)
    aimlockBtnObj.frame.InputEnded:Connect(function(i)
        if not S.aimlockHoldToAim then return end
        if not isHoldInput(i) then return end
        Aimlock._holdActive = false
    end)
end

-- ── Switch-target buttons ─────────────────────────────────────
local switchLeftBtnObj = makeButton("SwitchLeft", S.switchLeftBtnPos, S.btnSize, "◄",
    Color3.fromRGB(20, 60, 130),
    function() if S.switchTargetsEnabled then switchTarget(-1) end end)
table.insert(buttonRegistry, { obj = switchLeftBtnObj, sKey = "switchLeftBtnPos" })

local switchRightBtnObj = makeButton("SwitchRight", S.switchRightBtnPos, S.btnSize, "►",
    Color3.fromRGB(20, 60, 130),
    function() if S.switchTargetsEnabled then switchTarget(1) end end)
table.insert(buttonRegistry, { obj = switchRightBtnObj, sKey = "switchRightBtnPos" })

-- ── Target mode buttons (PLR / NPC) ───────────────────────────
local modeColors = { active = Color3.fromRGB(40,200,80), inactive = Color3.fromRGB(160,30,30) }
local modeBtnObjs = {}

local function refreshModeButtons()
    if modeBtnObjs["player"] then
        modeBtnObjs["player"].frame.BackgroundColor3 =
            S.targetPlayers and modeColors.active or modeColors.inactive
    end
    if modeBtnObjs["npc"] then
        modeBtnObjs["npc"].frame.BackgroundColor3 =
            S.targetNPCs and modeColors.active or modeColors.inactive
    end
end

local plrBtnObj = makeButton("ModeBtn_player", S.modeBtnPlayerPos, S.btnSize, "PLR",
    modeColors.active, function()
        S.targetPlayers = not S.targetPlayers; refreshModeButtons()
    end)
modeBtnObjs["player"] = plrBtnObj
plrBtnObj.frame.Visible = false
table.insert(buttonRegistry, { obj = plrBtnObj, sKey = "modeBtnPlayerPos" })

local npcBtnObj = makeButton("ModeBtn_npc", S.modeBtnNpcPos, S.btnSize, "NPC",
    modeColors.inactive, function()
        S.targetNPCs = not S.targetNPCs; refreshModeButtons()
    end)
modeBtnObjs["npc"] = npcBtnObj
npcBtnObj.frame.Visible = false
table.insert(buttonRegistry, { obj = npcBtnObj, sKey = "modeBtnNpcPos" })

refreshModeButtons()

-- ── Combined Heartbeat (buttons + Target Part Rotation timers) ──
local _playerTPAccum = 0
local _npcTPAccum    = 0
local _playerSitTPAccum = 0
local _npcSitTPAccum    = 0
RunService.Heartbeat:Connect(function(dt)
    -- Button visibility
    switchLeftBtnObj.frame.Visible  = S.switchTargetsEnabled
    switchRightBtnObj.frame.Visible = S.switchTargetsEnabled
    plrBtnObj.frame.Visible         = S._showModeBtns == true
    npcBtnObj.frame.Visible         = S._showModeBtns == true
    aimlockBtnObj.frame.Visible     = true

    -- Player Target Part Rotation timer
    if S.playerTPEnabled then
        _playerTPAccum = _playerTPAccum + dt
        local rate = S.playerTPUnit == "s"
            and math.max(0.05, S.playerTPRate)
            or  math.max(0.05, S.playerTPRate / 1000)
        if _playerTPAccum >= rate then
            _playerTPAccum = 0
            playerActiveTP, playerActiveMiss = pickWeightedPart("playerTP", S.playerTPMiss)
        end
    else
        _playerTPAccum  = 0
        playerActiveTP  = nil
        playerActiveMiss = false
    end

    -- NPC Target Part Rotation timer
    if S.npcTPEnabled then
        _npcTPAccum = _npcTPAccum + dt
        local rate = S.npcTPUnit == "s"
            and math.max(0.05, S.npcTPRate)
            or  math.max(0.05, S.npcTPRate / 1000)
        if _npcTPAccum >= rate then
            _npcTPAccum = 0
            npcActiveTP, npcActiveMiss = pickWeightedPart("npcTP", S.npcTPMiss)
        end
    else
        _npcTPAccum  = 0
        npcActiveTP  = nil
        npcActiveMiss = false
    end

    -- Sitting profiles are evaluated independently.  This makes the profile
    -- switch happen as soon as Humanoid.Sit changes instead of waiting for the
    -- standing rotation timer or changing the standing settings.
    if S.playerSitTPEnabled then
        _playerSitTPAccum = _playerSitTPAccum + dt
        local rate = S.playerSitTPUnit == "s"
            and math.max(0.05, S.playerSitTPRate)
            or math.max(0.05, S.playerSitTPRate / 1000)
        if _playerSitTPAccum >= rate then
            _playerSitTPAccum = 0
            playerSitActiveTP, playerSitActiveMiss =
                pickWeightedPart("playerSitTP", S.playerSitTPMiss)
        end
    else
        _playerSitTPAccum = 0
        playerSitActiveTP = nil
        playerSitActiveMiss = false
    end

    if S.npcSitTPEnabled then
        _npcSitTPAccum = _npcSitTPAccum + dt
        local rate = S.npcSitTPUnit == "s"
            and math.max(0.05, S.npcSitTPRate)
            or math.max(0.05, S.npcSitTPRate / 1000)
        if _npcSitTPAccum >= rate then
            _npcSitTPAccum = 0
            npcSitActiveTP, npcSitActiveMiss =
                pickWeightedPart("npcSitTP", S.npcSitTPMiss)
        end
    else
        _npcSitTPAccum = 0
        npcSitActiveTP = nil
        npcSitActiveMiss = false
    end
end)

-- ── Aimlock button icon hook ───────────────────────────────────
_G.__FlyScript_UpdateAimlockBtn = function()
    if not aimlockBtnObj then return end
    if S.aimlockEnabled then
        aimlockBtnObj.icon.Image             = S.aimlockOnImg or ""
        aimlockBtnObj.frame.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
    else
        aimlockBtnObj.icon.Image             = S.aimlockOffImg or ""
        aimlockBtnObj.frame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    end
end

-- ── Edit-layout mode ──────────────────────────────────────────
local function enterEditMode()
    if editActive then return end
    editActive = true

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundTransparency = 1
    overlay.ZIndex = 20; overlay.Parent = SG

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(0.72,0,0.06,0); hint.Position = UDim2.new(0.14,0,0.04,0)
    hint.BackgroundColor3 = Color3.new(0,0,0); hint.BackgroundTransparency = 0.4
    hint.TextColor3 = Color3.new(1,1,1); hint.Text = "Drag to move  •  Pinch to resize"
    hint.TextScaled = true; hint.Font = Enum.Font.GothamSemibold
    hint.ZIndex = 21; hint.Parent = overlay
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.25,0); c.Parent = hint end

    local function makeCtrlBtn(label, xPos, bg, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.22,0,0.055,0); b.Position = UDim2.new(xPos,0,0.91,0)
        b.BackgroundColor3 = bg; b.TextColor3 = Color3.new(1,1,1)
        b.Text = label; b.TextScaled = true; b.Font = Enum.Font.GothamBold
        b.ZIndex = 21; b.Parent = overlay
        do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.3,0); c.Parent = b end
        b.MouseButton1Click:Connect(cb); b.TouchTap:Connect(cb)
    end

    makeCtrlBtn("Save", 0.08, Color3.fromRGB(30,160,60), function()
        for _, entry in ipairs(buttonRegistry) do S[entry.sKey] = entry.obj.frame.Position end
        overlay:Destroy(); editActive = false
    end)
    makeCtrlBtn("Reset", 0.39, Color3.fromRGB(160,120,10), function()
        for _, entry in ipairs(buttonRegistry) do
            entry.obj.frame.Position = D[entry.sKey]; S[entry.sKey] = D[entry.sKey]
        end
        overlay:Destroy(); editActive = false
    end)
    makeCtrlBtn("Cancel", 0.70, Color3.fromRGB(175,30,30), function()
        overlay:Destroy(); editActive = false
    end)
end

-- ── Crosshair position editor ─────────────────────────────────
-- This editor is separate from the button-layout editor.  Drag mode
-- moves the crosshair directly; Move Position mode uses four directional
-- controls for precise placement.
local crosshairEditActive = false
local syncCrosshairEditorVisual = nil

local function enterCrosshairEditMode()
    if crosshairEditActive then return end
    crosshairEditActive = true

    local hadCrosshairGui = Aimlock.crosshairGui ~= nil
    if not hadCrosshairGui then makeCrosshairGui() end

    local overlay = Instance.new("Frame")
    overlay.Name = "CrosshairEditOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.ZIndex = 50
    overlay.Parent = SG

    local mode = "drag"
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local originalPos = S.aimlockCrosshairPos
    local connections = {}

    local function disconnectAll()
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
    end

    local function finish(commit)
        disconnectAll()
        if overlay then overlay:Destroy() end
        crosshairEditActive = false
        if not commit then
            applyCrosshairPosition(originalPos)
        end
        syncCrosshairEditorVisual = nil
        if not hadCrosshairGui and not S.aimlockEnabled then
            destroyCrosshairGui()
        end
    end

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(0.82, 0, 0.055, 0)
    hint.Position = UDim2.new(0.09, 0, 0.035, 0)
    hint.BackgroundColor3 = Color3.new(0, 0, 0)
    hint.BackgroundTransparency = 0.35
    hint.TextColor3 = Color3.new(1, 1, 1)
    hint.Text = "Crosshair position editor"
    hint.TextScaled = true
    hint.Font = Enum.Font.GothamSemibold
    hint.ZIndex = 51
    hint.Parent = overlay
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.25, 0)
        c.Parent = hint
    end

    local handle = Instance.new("TextButton")
    handle.Name = "CrosshairDragHandle"
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Size = UDim2.new(0, 64, 0, 64)
    handle.BackgroundTransparency = 1
    handle.Text = ""
    handle.ZIndex = 52
    handle.Parent = overlay

    -- Keep the hit area large for dragging, but mirror the selected
    -- crosshair instead of drawing a second circle/plus on top of it.
    local handleDot = Instance.new("Frame")
    handleDot.Size = UDim2.new(0, 14, 0, 14)
    handleDot.AnchorPoint = Vector2.new(0.5, 0.5)
    handleDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    handleDot.BorderSizePixel = 0
    handleDot.ZIndex = 53
    handleDot.Parent = handle
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = handleDot end

    local handleCrossH = Instance.new("Frame")
    handleCrossH.Size = UDim2.new(0, 28, 0, 1)
    handleCrossH.AnchorPoint = Vector2.new(0.5, 0.5)
    handleCrossH.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleCrossH.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    handleCrossH.BorderSizePixel = 0
    handleCrossH.ZIndex = 53
    handleCrossH.Parent = handle

    local handleCrossV = Instance.new("Frame")
    handleCrossV.Size = UDim2.new(0, 1, 0, 28)
    handleCrossV.AnchorPoint = Vector2.new(0.5, 0.5)
    handleCrossV.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleCrossV.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    handleCrossV.BorderSizePixel = 0
    handleCrossV.ZIndex = 53
    handleCrossV.Parent = handle

    local handleImage = Instance.new("ImageLabel")
    handleImage.Size = UDim2.new(0, 26, 0, 26)
    handleImage.AnchorPoint = Vector2.new(0.5, 0.5)
    handleImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleImage.BackgroundTransparency = 1
    handleImage.ScaleType = Enum.ScaleType.Fit
    handleImage.ZIndex = 53
    handleImage.Parent = handle

    local function syncHandle()
        local pos = S.aimlockCrosshairPos
        handle.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
    end
    syncHandle()

    local function syncHandleVisual()
        local image = normalizeCrosshairImage(S.aimlockCrosshairImage)
        local hasImage = image ~= ""
        local isCross = S.aimlockCrosshairShape == "cross"
        handleImage.Image = image
        handleImage.Visible = hasImage
        handleDot.Visible = not hasImage and not isCross
        handleCrossH.Visible = not hasImage and isCross
        handleCrossV.Visible = not hasImage and isCross
    end
    syncCrosshairEditorVisual = syncHandleVisual

    local function setMode(nextMode)
        mode = nextMode
        hint.Text = mode == "drag"
            and "Drag mode — drag the crosshair, then save"
            or "Move position mode — use the four arrow buttons"
        handle.AutoButtonColor = mode == "drag"
        syncHandleVisual()
    end

    local function nudgePixels(dx, dy)
        local pos = S.aimlockCrosshairPos
        applyCrosshairPosition(UDim2.new(
            pos.X.Scale, pos.X.Offset + dx,
            pos.Y.Scale, pos.Y.Offset + dy))
        syncHandle()
    end

    table.insert(connections, handle.InputBegan:Connect(function(input)
        if mode ~= "drag" then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragInput = input
        dragStart = input.Position
        startPos = S.aimlockCrosshairPos
    end))

    table.insert(connections, handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if mode ~= "drag" or input ~= dragInput or not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        applyCrosshairPosition(UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y))
        syncHandle()
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragInput = nil
            dragStart = nil
            startPos = nil
        end
    end))

    local function makeEditorButton(label, position, color, callback, holdDirection)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.22, 0, 0.055, 0)
        button.Position = position
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Text = label
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.ZIndex = 51
        button.Parent = overlay
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0.3, 0)
        c.Parent = button
        if holdDirection then
            local held = false
            table.insert(connections, button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    held = true
                end
            end))
            table.insert(connections, button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    held = false
                end
            end))
            table.insert(connections, RunService.Heartbeat:Connect(function(dt)
                if held and mode == "move" then
                    local speed = math.max(1, tonumber(S.aimlockCrosshairMoveSpeed) or 300)
                    nudgePixels(holdDirection.X * speed * dt, holdDirection.Y * speed * dt)
                end
            end))
        end
        button.MouseButton1Click:Connect(callback)
        button.TouchTap:Connect(callback)
        return button
    end

    makeEditorButton("Drag", UDim2.new(0.08, 0, 0.78, 0),
        Color3.fromRGB(190, 55, 55), function() setMode("drag") end)
    makeEditorButton("Move Position", UDim2.new(0.38, 0, 0.78, 0),
        Color3.fromRGB(55, 100, 190), function() setMode("move") end)

    local arrowY = 0.86
    local function tapNudge(dx, dy)
        if mode ~= "move" then return end
        local speed = math.max(1, tonumber(S.aimlockCrosshairMoveSpeed) or 300)
        nudgePixels(dx * speed * 0.05, dy * speed * 0.05)
    end
    makeEditorButton("Up", UDim2.new(0.08, 0, arrowY, 0),
        Color3.fromRGB(70, 70, 70), function() tapNudge(0, -1) end, Vector2.new(0, -1))
    makeEditorButton("Down", UDim2.new(0.30, 0, arrowY, 0),
        Color3.fromRGB(70, 70, 70), function() tapNudge(0, 1) end, Vector2.new(0, 1))
    makeEditorButton("Left", UDim2.new(0.52, 0, arrowY, 0),
        Color3.fromRGB(70, 70, 70), function() tapNudge(-1, 0) end, Vector2.new(-1, 0))
    makeEditorButton("Right", UDim2.new(0.74, 0, arrowY, 0),
        Color3.fromRGB(70, 70, 70), function() tapNudge(1, 0) end, Vector2.new(1, 0))

    makeEditorButton("Save", UDim2.new(0.08, 0, 0.93, 0),
        Color3.fromRGB(30, 160, 60), function() finish(true) end)
    makeEditorButton("Reset", UDim2.new(0.38, 0, 0.93, 0),
        Color3.fromRGB(160, 120, 10), function()
            applyCrosshairPosition(D.aimlockCrosshairPos)
            syncHandle()
        end)
    makeEditorButton("Cancel", UDim2.new(0.68, 0, 0.93, 0),
        Color3.fromRGB(175, 30, 30), function()
            finish(false)
        end)

    setMode("drag")
    syncHandleVisual()
end

-- ============================================================
--  RAYFIELD UI
-- ============================================================
-- Retained below as a migration reference only.  The executable UI is the
-- native panel appended after this block; no Rayfield code is loaded.
if false then
local Window = Rayfield:CreateWindow({
    Name                   = "Aimlock",
    Icon                   = 0,
    LoadingTitle           = "Aimlock",
    LoadingSubtitle        = "by your script",
    Theme                  = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    KeySystem              = false,
    ConfigurationSaving    = {
        Enabled    = true,
        FolderName = "AimlockScript",
        FileName   = "Config",
    },
    Discord     = { Enabled = false },
    MenuKeybind = "RightControl",
})

-- ── MAIN ─────────────────────────────────────────────────────
local TMain = Window:CreateTab("Main", 4483362458)
TMain:CreateToggle({
    Name = "Enable Aimlock", CurrentValue = S.aimlockEnabled,
    Flag = "AimlockEnabled", Callback = function(v) setAimlock(v) end,
})

-- ── TARGETING ────────────────────────────────────────────────
local TTarg = Window:CreateTab("Targeting", 4483362458)
TTarg:CreateSection("FOV & Range")
TTarg:CreateSlider({ Name = "FOV Radius (px)", Range = {10,800}, Increment = 5, Suffix = "px",
    CurrentValue = S.aimlockFOV, Flag = "AimlockFOV",
    Callback = function(v) S.aimlockFOV = v end })
TTarg:CreateSlider({ Name = "Max Range (studs)", Range = {50,5000}, Increment = 50, Suffix = " st",
    CurrentValue = S.aimlockRange, Flag = "AimlockRange",
    Callback = function(v) S.aimlockRange = v end })
TTarg:CreateToggle({ Name = "Target based off distance  (nearest inside FOV)",
    CurrentValue = S.targetBasedOffDistance, Flag = "TargetBasedOffDistance",
    Callback = function(v)
        S.targetBasedOffDistance = v
        if not v then
            Aimlock.distanceDeadTarget = nil
        end
        -- Reacquire immediately using the new selection rule.
        setAimlockTarget(nil)
        Aimlock.targetLostAt = 0
    end })
TTarg:CreateToggle({
    Name = "Stick distance target until death",
    CurrentValue = S.targetDistanceSticky,
    Flag = "TargetDistanceSticky",
    Callback = function(v)
        S.targetDistanceSticky = v
        if not v then
            Aimlock.distanceDeadTarget = nil
            Aimlock.targetLostAt = 0
        end
    end,
})
TTarg:CreateSection("Checks")
TTarg:CreateToggle({ Name = "Team Check", CurrentValue = S.aimlockTeamCheck, Flag = "AimlockTeamCheck",
    Callback = function(v) S.aimlockTeamCheck = v end })
local ignoreTeamDropdown = TTarg:CreateDropdown({
    Name = "Ignore Team  (never targeted)",
    Options = {}, CurrentOption = {}, MultipleOptions = true,
    Flag = "AimlockIgnoreTeams",
    Callback = function(selectedTeams)
        S.aimlockIgnoreTeams = {}
        for _, teamName in ipairs(selectedTeams or {}) do
            S.aimlockIgnoreTeams[string.lower(teamName)] = true
        end
    end,
})
TTarg:CreateToggle({ Name = "Smart Team Check  (clothing IDs/names)",
    CurrentValue = S.aimlockSmartTeamCheck, Flag = "AimlockSmartTeamCheck",
    Callback = function(v)
        S.aimlockSmartTeamCheck = v
        smartTeamLastScan = 0
        if v then rebuildSmartTeams() end
    end })
TTarg:CreateToggle({ Name = "Friend Check", CurrentValue = S.aimlockFriendCheck, Flag = "AimlockFriendCheck",
    Callback = function(v) S.aimlockFriendCheck = v end })
TTarg:CreateToggle({ Name = "Wall Check", CurrentValue = S.aimlockWallCheck, Flag = "AimlockWallCheck",
    Callback = function(v) S.aimlockWallCheck = v end })
TTarg:CreateToggle({
    Name = "Ignore Transparency Wall Check",
    CurrentValue = S.aimlockIgnoreTransparentWalls,
    Flag = "AimlockIgnoreTransparentWalls",
    Callback = function(v) S.aimlockIgnoreTransparentWalls = v end,
})
TTarg:CreateInput({
    Name = "Transparency Ignore Threshold  (0–1)",
    PlaceholderText = tostring(S.aimlockTransparencyThreshold),
    RemoveTextAfterFocusLost = false,
    Flag = "AimlockTransparencyThreshold",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            S.aimlockTransparencyThreshold = math.clamp(n, 0, 1)
        end
    end,
})
TTarg:CreateToggle({
    Name = "Check CanCollide Wall",
    CurrentValue = S.aimlockCanCollideWallCheck,
    Flag = "AimlockCanCollideWallCheck",
    Callback = function(v) S.aimlockCanCollideWallCheck = v end,
})
TTarg:CreateSection("Target Part")
TTarg:CreateInput({ Name = "Aim Part  (e.g. Head, UpperTorso)",
    PlaceholderText = S.aimlockPart, RemoveTextAfterFocusLost = false, Flag = "AimlockPart",
    Callback = function(v) if v and v ~= "" then S.aimlockPart = v end end })

-- ── BEHAVIOUR ────────────────────────────────────────────────
local TBehav = Window:CreateTab("Behaviour", 4483362458)
TBehav:CreateSection("Lock Mode")
TBehav:CreateToggle({ Name = "Sticky Lock", CurrentValue = S.aimlockStickyLock,
    Flag = "AimlockStickyLock", Callback = function(v) S.aimlockStickyLock = v end })
TBehav:CreateToggle({ Name = "Hold-to-Aim", CurrentValue = S.aimlockHoldToAim,
    Flag = "AimlockHoldToAim", Callback = function(v) S.aimlockHoldToAim = v end })
TBehav:CreateToggle({ Name = "Cursor Mode", CurrentValue = S.aimlockCursorMode,
    Flag = "AimlockCursorMode", Callback = function(v) S.aimlockCursorMode = v end })
TBehav:CreateSlider({ Name = "Reacquire Delay (sec)", Range = {0,3}, Increment = 1, Suffix = "s",
    CurrentValue = S.aimlockReacquireDelay, Flag = "AimlockReacquireDelay",
    Callback = function(v) S.aimlockReacquireDelay = v end })
TBehav:CreateSection("Smoothing & Speed")
TBehav:CreateSlider({ Name = "Smoothing  (1=snap  20=slow glide)", Range = {1,20}, Increment = 1,
    CurrentValue = math.floor(S.aimlockSmoothing * 20 + 0.5), Flag = "AimlockSmoothing",
    Callback = function(v) S.aimlockSmoothing = v / 20 end })
TBehav:CreateSlider({ Name = "Max Deg Per Frame  (0 = no limit)", Range = {0,45}, Increment = 1,
    Suffix = "°", CurrentValue = S.aimlockMaxDegPerFrame, Flag = "AimlockMaxDeg",
    Callback = function(v) S.aimlockMaxDegPerFrame = v end })
TBehav:CreateSlider({ Name = "Humanizer  (pixel jitter, 0 = off)", Range = {0,40}, Increment = 1,
    Suffix = "px", CurrentValue = S.aimlockHumanize, Flag = "AimlockHumanize",
    Callback = function(v) S.aimlockHumanize = v end })
TBehav:CreateSlider({ Name = "Miss Chance", Range = {0,40}, Increment = 1, Suffix = "%",
    CurrentValue = S.aimlockMissChance, Flag = "AimlockMissChance",
    Callback = function(v) S.aimlockMissChance = v end })
TBehav:CreateSection("Switch Targets  (◄ ► on-screen buttons)")
TBehav:CreateToggle({ Name = "Enable Switch Targets", CurrentValue = S.switchTargetsEnabled,
    Flag = "SwitchTargets",
    Callback = function(v)
        S.switchTargetsEnabled = v
        if v then
            local list = buildSwitchList()
            if #list > 0 then setAimlockTarget(list[1]) end
        end
    end })
TBehav:CreateSection("Target Mode  (PLR / NPC on-screen buttons)")
TBehav:CreateToggle({ Name = "Show Target Mode Buttons", CurrentValue = false,
    Flag = "ShowModeBtns",
    Callback = function(v) S._showModeBtns = v; refreshModeButtons() end })
TBehav:CreateToggle({ Name = "Target Players", CurrentValue = S.targetPlayers,
    Flag = "TargetPlayers",
    Callback = function(v) S.targetPlayers = v; refreshModeButtons() end })
TBehav:CreateToggle({ Name = "Target NPCs  (all humanoid models)", CurrentValue = S.targetNPCs,
    Flag = "TargetNPCs",
    Callback = function(v) S.targetNPCs = v; refreshModeButtons() end })

-- ── PLAYER TARGET PART ROTATION ─────────────────────────────
-- Dropdowns show all common body parts (R15 + R6).
-- Select "(none)" to make that row a miss slot when Miss is ON.
-- Chance sliders are auto-capped: row N's max = 100 - sum of other rows.
-- With Miss OFF  → (none) rows are ignored; only named parts rotate.
-- With Miss ON   → (none) rows count toward the rotation and cause
--                  the aimlock to intentionally skip locking that tick.
TBehav:CreateSection("Player Target Part Rotation")
TBehav:CreateToggle({ Name = "Enable Player Part Rotation",
    CurrentValue = S.playerTPEnabled, Flag = "PlayerTPEnabled",
    Callback = function(v) S.playerTPEnabled = v end })
TBehav:CreateSlider({ Name = "Switch Rate", Range = {1, 5000}, Increment = 1,
    CurrentValue = S.playerTPRate, Flag = "PlayerTPRate",
    Callback = function(v) S.playerTPRate = v end })
TBehav:CreateDropdown({ Name = "Switch Rate Unit",
    Options = {"ms", "s"}, CurrentOption = {S.playerTPUnit},
    MultipleOptions = false, Flag = "PlayerTPUnit",
    Callback = function(v) S.playerTPUnit = (type(v)=="table" and v[1]) or v end })
TBehav:CreateSection("PLR Row 1  —  pick part, then set chance")
TBehav:CreateDropdown({
    Name = "Part  ('PLR Row 1')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.playerTP1Part ~= "" and S.playerTP1Part or "(none)")},
    MultipleOptions = false, Flag = "PlayerTP1Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.playerTP1Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.playerTP1Chance, Flag = "PlayerTP1Chance",
    Callback = function(v)
        S.playerTP1Chance = math.min(v, getTPBudget("playerTP", 1))
    end })
TBehav:CreateSection("PLR Row 2  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('PLR Row 2')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.playerTP2Part ~= "" and S.playerTP2Part or "(none)")},
    MultipleOptions = false, Flag = "PlayerTP2Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.playerTP2Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.playerTP2Chance, Flag = "PlayerTP2Chance",
    Callback = function(v)
        S.playerTP2Chance = math.min(v, getTPBudget("playerTP", 2))
    end })
TBehav:CreateSection("PLR Row 3  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('PLR Row 3')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.playerTP3Part ~= "" and S.playerTP3Part or "(none)")},
    MultipleOptions = false, Flag = "PlayerTP3Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.playerTP3Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.playerTP3Chance, Flag = "PlayerTP3Chance",
    Callback = function(v)
        S.playerTP3Chance = math.min(v, getTPBudget("playerTP", 3))
    end })
TBehav:CreateSection("PLR Row 4  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('PLR Row 4')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.playerTP4Part ~= "" and S.playerTP4Part or "(none)")},
    MultipleOptions = false, Flag = "PlayerTP4Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.playerTP4Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.playerTP4Chance, Flag = "PlayerTP4Chance",
    Callback = function(v)
        S.playerTP4Chance = math.min(v, getTPBudget("playerTP", 4))
    end })
TBehav:CreateSection("PLR Row 5  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('PLR Row 5')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.playerTP5Part ~= "" and S.playerTP5Part or "(none)")},
    MultipleOptions = false, Flag = "PlayerTP5Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.playerTP5Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.playerTP5Chance, Flag = "PlayerTP5Chance",
    Callback = function(v)
        S.playerTP5Chance = math.min(v, getTPBudget("playerTP", 5))
    end })
TBehav:CreateSection("PLR Miss")
TBehav:CreateToggle({ Name = "Enable Miss  ((none) rows skip the lock that tick)",
    CurrentValue = S.playerTPMiss, Flag = "PlayerTPMiss",
    Callback = function(v) S.playerTPMiss = v end })

-- ── NPC TARGET PART ROTATION ──────────────────────────────────
TBehav:CreateSection("NPC Target Part Rotation")
TBehav:CreateToggle({ Name = "Enable NPC Part Rotation",
    CurrentValue = S.npcTPEnabled, Flag = "NpcTPEnabled",
    Callback = function(v) S.npcTPEnabled = v end })
TBehav:CreateSlider({ Name = "Switch Rate", Range = {1, 5000}, Increment = 1,
    CurrentValue = S.npcTPRate, Flag = "NpcTPRate",
    Callback = function(v) S.npcTPRate = v end })
TBehav:CreateDropdown({ Name = "Switch Rate Unit",
    Options = {"ms", "s"}, CurrentOption = {S.npcTPUnit},
    MultipleOptions = false, Flag = "NpcTPUnit",
    Callback = function(v) S.npcTPUnit = (type(v)=="table" and v[1]) or v end })
TBehav:CreateSection("NPC Row 1  —  pick part, then set chance")
TBehav:CreateDropdown({
    Name = "Part  ('NPC Row 1')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.npcTP1Part ~= "" and S.npcTP1Part or "(none)")},
    MultipleOptions = false, Flag = "NpcTP1Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.npcTP1Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.npcTP1Chance, Flag = "NpcTP1Chance",
    Callback = function(v)
        S.npcTP1Chance = math.min(v, getTPBudget("npcTP", 1))
    end })
TBehav:CreateSection("NPC Row 2  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('NPC Row 2')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.npcTP2Part ~= "" and S.npcTP2Part or "(none)")},
    MultipleOptions = false, Flag = "NpcTP2Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.npcTP2Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.npcTP2Chance, Flag = "NpcTP2Chance",
    Callback = function(v)
        S.npcTP2Chance = math.min(v, getTPBudget("npcTP", 2))
    end })
TBehav:CreateSection("NPC Row 3  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('NPC Row 3')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.npcTP3Part ~= "" and S.npcTP3Part or "(none)")},
    MultipleOptions = false, Flag = "NpcTP3Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.npcTP3Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.npcTP3Chance, Flag = "NpcTP3Chance",
    Callback = function(v)
        S.npcTP3Chance = math.min(v, getTPBudget("npcTP", 3))
    end })
TBehav:CreateSection("NPC Row 4  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('NPC Row 4')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.npcTP4Part ~= "" and S.npcTP4Part or "(none)")},
    MultipleOptions = false, Flag = "NpcTP4Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.npcTP4Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.npcTP4Chance, Flag = "NpcTP4Chance",
    Callback = function(v)
        S.npcTP4Chance = math.min(v, getTPBudget("npcTP", 4))
    end })
TBehav:CreateSection("NPC Row 5  (set to 0 to disable)")
TBehav:CreateDropdown({
    Name = "Part  ('NPC Row 5')",
    Options = COMMON_PARTS,
    CurrentOption = {(S.npcTP5Part ~= "" and S.npcTP5Part or "(none)")},
    MultipleOptions = false, Flag = "NpcTP5Part",
    Callback = function(v)
        local sel = (type(v)=="table" and v[1]) or v
        S.npcTP5Part = (sel == "(none)") and "" or (sel or "")
    end })
TBehav:CreateSlider({
    Name = "Chance  (remaining budget auto-capped)",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = S.npcTP5Chance, Flag = "NpcTP5Chance",
    Callback = function(v)
        S.npcTP5Chance = math.min(v, getTPBudget("npcTP", 5))
    end })
TBehav:CreateSection("NPC Miss")
TBehav:CreateToggle({ Name = "Enable Miss  ((none) rows skip the lock that tick)",
    CurrentValue = S.npcTPMiss, Flag = "NpcTPMiss",
    Callback = function(v) S.npcTPMiss = v end })

-- ── PREDICTION ───────────────────────────────────────────────
local TPred = Window:CreateTab("Prediction", 4483362458)
TPred:CreateSection("Smart AI Lead")
TPred:CreateToggle({ Name = "Smart AI", CurrentValue = S.aimlockSmartAI,
    Flag = "AimlockSmartAI", Callback = function(v) S.aimlockSmartAI = v end })
TPred:CreateSlider({ Name = "Predict Strength  (0=none  10=full)", Range = {0,10}, Increment = 1,
    CurrentValue = math.floor(S.aimlockPredictStrength * 10 + 0.5), Flag = "AimlockPredictStr",
    Callback = function(v) S.aimlockPredictStrength = v / 10 end })
TPred:CreateToggle({ Name = "Acceleration Prediction  (noisy)",
    CurrentValue = S.aimlockPredictAccel, Flag = "AimlockPredictAccel",
    Callback = function(v) S.aimlockPredictAccel = v end })

-- ── VISUALS ───────────────────────────────────────────────────
local TVis = Window:CreateTab("Visuals", 4483362458)
TVis:CreateSection("FOV Ring")
TVis:CreateToggle({ Name = "Show FOV Ring", CurrentValue = S.aimlockShowFOV,
    Flag = "AimlockShowFOV",
    Callback = function(v)
        S.aimlockShowFOV = v
        if Aimlock.fovCircle then Aimlock.fovCircle.Visible = v end
    end })
TVis:CreateInput({ Name = "FOV Ring Size  (max 350 px)",
    PlaceholderText = tostring(S.aimlockFOVRingSize),
    RemoveTextAfterFocusLost = false, Flag = "AimlockFOVRingSize",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            S.aimlockFOVRingSize = math.clamp(math.floor(n + 0.5), 1, 350)
            if Aimlock.fovCircle then
                Aimlock.fovCircle.Size = UDim2.new(
                    0, S.aimlockFOVRingSize * 2,
                    0, S.aimlockFOVRingSize * 2)
            end
        end
    end })
TVis:CreateSlider({ Name = "Ring Color — Red", Range = {0,255}, Increment = 5,
    CurrentValue = S.aimlockFOVColorR, Flag = "AimlockFOVR",
    Callback = function(v)
        S.aimlockFOVColorR = v
        if Aimlock.fovStroke then Aimlock.fovStroke.Color =
            Color3.fromRGB(S.aimlockFOVColorR, S.aimlockFOVColorG, S.aimlockFOVColorB) end
    end })
TVis:CreateSlider({ Name = "Ring Color — Green", Range = {0,255}, Increment = 5,
    CurrentValue = S.aimlockFOVColorG, Flag = "AimlockFOVG",
    Callback = function(v)
        S.aimlockFOVColorG = v
        if Aimlock.fovStroke then Aimlock.fovStroke.Color =
            Color3.fromRGB(S.aimlockFOVColorR, S.aimlockFOVColorG, S.aimlockFOVColorB) end
    end })
TVis:CreateSlider({ Name = "Ring Color — Blue", Range = {0,255}, Increment = 5,
    CurrentValue = S.aimlockFOVColorB, Flag = "AimlockFOVB",
    Callback = function(v)
        S.aimlockFOVColorB = v
        if Aimlock.fovStroke then Aimlock.fovStroke.Color =
            Color3.fromRGB(S.aimlockFOVColorR, S.aimlockFOVColorG, S.aimlockFOVColorB) end
    end })
TVis:CreateSection("Crosshair")
TVis:CreateToggle({ Name = "Cross Crosshair  (replaces dot with + shape)",
    CurrentValue = S.aimlockCrosshairShape == "cross", Flag = "CrosshairCross",
    Callback = function(v)
        S.aimlockCrosshairShape = v and "cross" or "dot"
        syncCrosshairShape()
        if syncCrosshairEditorVisual then syncCrosshairEditorVisual() end
    end })
TVis:CreateInput({ Name = "Crosshair X  (0.0 – 1.0, default 0.5)",
    PlaceholderText = "0.5", RemoveTextAfterFocusLost = false, Flag = "CrosshairX",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            n = math.clamp(n, 0, 1)
            S.aimlockCrosshairPos = UDim2.new(n, 0, S.aimlockCrosshairPos.Y.Scale, 0)
        end
    end })
TVis:CreateInput({ Name = "Crosshair Y  (0.0 – 1.0, default 0.5)",
    PlaceholderText = "0.5", RemoveTextAfterFocusLost = false, Flag = "CrosshairY",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            n = math.clamp(n, 0, 1)
            S.aimlockCrosshairPos = UDim2.new(S.aimlockCrosshairPos.X.Scale, 0, n, 0)
        end
    end })
TVis:CreateButton({
    Name = "Drag Crosshair",
    Callback = function() enterCrosshairEditMode() end,
})
TVis:CreateSlider({ Name = "Move Position Speed  (pixels/sec)",
    Range = {10, 2000}, Increment = 10, Suffix = " px/s",
    CurrentValue = S.aimlockCrosshairMoveSpeed, Flag = "CrosshairMoveSpeed",
    Callback = function(v)
        S.aimlockCrosshairMoveSpeed = math.max(1, v)
    end })
TVis:CreateInput({ Name = "Crosshair Image / Decal ID  (blank = selected shape)",
    PlaceholderText = "Image or decal ID", RemoveTextAfterFocusLost = false,
    Flag = "CrosshairImage",
    Callback = function(v)
        S.aimlockCrosshairImage = normalizeCrosshairImage(v)
        syncCrosshairImage()
        if syncCrosshairEditorVisual then syncCrosshairEditorVisual() end
    end })
TVis:CreateSlider({ Name = "Crosshair Opacity  (0 = solid, 100 = invisible)",
    Range = {0,100}, Increment = 5, Suffix = "%",
    CurrentValue = math.floor((S.aimlockCrosshairOpacity or 0) * 100),
    Flag = "CrosshairOpacity",
    Callback = function(v)
        S.aimlockCrosshairOpacity = v / 100
        local t = v / 100
        if Aimlock.crosshairDot    then Aimlock.crosshairDot.BackgroundTransparency    = t end
        if Aimlock.crosshairCrossH then Aimlock.crosshairCrossH.BackgroundTransparency = t end
        if Aimlock.crosshairCrossV then Aimlock.crosshairCrossV.BackgroundTransparency = t end
        if Aimlock.crosshairImage then Aimlock.crosshairImage.ImageTransparency = t end
    end })

-- ── NPC ESP ───────────────────────────────────────────────────
local TESP = Window:CreateTab("NPC ESP", 4483362458)

TESP:CreateSection("Settings")
TESP:CreateToggle({ Name = "Enable NPC ESP", CurrentValue = S.espEnabled,
    Flag = "ESPEnabled",
    Callback = function(v)
        S.espEnabled = v
        -- Immediately destroy all BillboardGui objects when turning off
        if not v then clearAllESPBoxes() end
    end })

TESP:CreateSlider({ Name = "Distance  (studs)", Range = {50, 2000},
    Increment = 50, Suffix = " st", CurrentValue = S.espDistance,
    Flag = "ESPDistance",
    Callback = function(v) S.espDistance = v end })

TESP:CreateSlider({ Name = "Box Size  (px)", Range = {8, 120}, Increment = 2,
    CurrentValue = S.espBoxSize, Flag = "ESPBoxSize",
    Callback = function(v)
        S.espBoxSize = v
        -- Rebuild existing boxes at new size on next frame
        clearAllESPBoxes()
    end })

TESP:CreateToggle({ Name = "Show Name Tag", CurrentValue = S.espNameTag,
    Flag = "ESPNameTag",
    Callback = function(v)
        S.espNameTag = v
        if not v then
            for _, e in pairs(espBoxes) do
                if e.lbl then e.lbl.Visible = false end
            end
        end
    end })
TESP:CreateToggle({ Name = "Enable Health Bar", CurrentValue = S.espHealthBar,
    Flag = "ESPHealthBar",
    Callback = function(v)
        S.espHealthBar = v
        for model, e in pairs(espBoxes) do
            local data = npcCache[model]
            if data then
                updateESPHealthBar(e, data.hum, e.gui and e.gui.Enabled == true)
            end
        end
    end })

TESP:CreateSection("Box Color")
TESP:CreateSlider({ Name = "Box Color — Red", Range = {0, 255}, Increment = 5,
    CurrentValue = S.espBoxColorR, Flag = "ESPBoxR",
    Callback = function(v) S.espBoxColorR = v end })
TESP:CreateSlider({ Name = "Box Color — Green", Range = {0, 255}, Increment = 5,
    CurrentValue = S.espBoxColorG, Flag = "ESPBoxG",
    Callback = function(v) S.espBoxColorG = v end })
TESP:CreateSlider({ Name = "Box Color — Blue", Range = {0, 255}, Increment = 5,
    CurrentValue = S.espBoxColorB, Flag = "ESPBoxB",
    Callback = function(v) S.espBoxColorB = v end })

-- ── LOCK LIST ────────────────────────────────────────────────
local TLL = Window:CreateTab("Lock List", 4483362458)
TLL:CreateSection("Priority Targets  (bypass friend check)")
TLL:CreateToggle({ Name = "Enable Lock List", CurrentValue = S.targetLockEnabled,
    Flag = "TargetLockEnabled", Callback = function(v) S.targetLockEnabled = v end })

local lockDropdown = TLL:CreateDropdown({
    Name = "Lock List  (select to add, deselect to remove)",
    Options = {}, CurrentOption = {}, MultipleOptions = true, Flag = "LockListDropdown",
    Callback = function(selectedNames)
        S.targetLockList = {}
        for _, name in ipairs(selectedNames) do
            S.targetLockList[string.lower(name)] = true
        end
    end,
})

TLL:CreateSection("Ignore List  (never targeted)")

local ignoreDropdown = TLL:CreateDropdown({
    Name = "Ignore List  (select to add, deselect to remove)",
    Options = {}, CurrentOption = {}, MultipleOptions = true, Flag = "IgnoreListDropdown",
    Callback = function(selectedNames)
        S.ignoreList = {}
        for _, name in ipairs(selectedNames) do
            S.ignoreList[string.lower(name)] = true
        end
    end,
})

local function refreshTeamDropdown()
    local optionsByName = {}
    for _, team in ipairs(Teams:GetTeams()) do
        optionsByName[team.Name] = true
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Team then optionsByName[plr.Team.Name] = true end
    end

    local names = {}
    for name in pairs(optionsByName) do table.insert(names, name) end
    table.sort(names)

    local selected = {}
    for _, name in ipairs(names) do
        if S.aimlockIgnoreTeams[string.lower(name)] then
            table.insert(selected, name)
        end
    end
    pcall(function() ignoreTeamDropdown:Refresh(names, selected) end)
end

local function watchPlayerTeamChanges(plr)
    plr:GetPropertyChangedSignal("Team"):Connect(refreshTeamDropdown)
end

local function refreshListDropdowns()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    pcall(function() lockDropdown:Refresh(names, {}) end)
    pcall(function() ignoreDropdown:Refresh(names, {}) end)
end
Players.PlayerAdded:Connect(refreshListDropdowns)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1); refreshListDropdowns()
end)
Players.PlayerAdded:Connect(refreshTeamDropdown)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1); refreshTeamDropdown()
end)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then watchPlayerTeamChanges(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then watchPlayerTeamChanges(plr) end
end)
Teams.ChildAdded:Connect(refreshTeamDropdown)
Teams.ChildRemoved:Connect(refreshTeamDropdown)
refreshListDropdowns()
refreshTeamDropdown()

-- ── SETTINGS ─────────────────────────────────────────────────
local TSet = Window:CreateTab("Settings", 4483362458)
TSet:CreateSection("Button Layout")
TSet:CreateButton({ Name = "Edit Layout  (drag buttons to reposition)",
    Callback = function() enterEditMode() end })
TSet:CreateButton({ Name = "Reset Layout to Default", Callback = function()
    for _, entry in ipairs(buttonRegistry) do
        entry.obj.frame.Position = D[entry.sKey]; S[entry.sKey] = D[entry.sKey]
    end
end })
end

-- ============================================================
--  AIMLOCK CONTROL CENTER
-- ============================================================
-- This is a native ScreenGui.  It intentionally has no third-party UI
-- dependency, uses one shared update loop, and reuses controls instead of
-- rebuilding them whenever a setting changes.
local previousControlCenter = playerGui:FindFirstChild("AimlockControlCenter")
if previousControlCenter then pcall(function() previousControlCenter:Destroy() end) end

local ControlGui = Instance.new("ScreenGui")
ControlGui.Name = "AimlockControlCenter"
ControlGui.ResetOnSpawn = false
ControlGui.IgnoreGuiInset = true
ControlGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ControlGui.DisplayOrder = 30
ControlGui.Parent = playerGui

local COLORS = {
    background = Color3.fromRGB(13, 17, 26),
    panel = Color3.fromRGB(19, 25, 37),
    panelAlt = Color3.fromRGB(24, 32, 47),
    border = Color3.fromRGB(45, 58, 82),
    text = Color3.fromRGB(235, 242, 252),
    muted = Color3.fromRGB(142, 157, 180),
    accent = Color3.fromRGB(91, 205, 255),
    accentDark = Color3.fromRGB(35, 112, 156),
    good = Color3.fromRGB(66, 214, 145),
    danger = Color3.fromRGB(255, 106, 116),
    warning = Color3.fromRGB(246, 188, 82),
}

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

local function addStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = instance
    return stroke
end

local function makeLabel(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Text = text
    label.TextColor3 = color or COLORS.text
    label.Font = font or Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.new(0, 480, 0, 610)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.BackgroundColor3 = COLORS.background
window.BorderSizePixel = 0
window.Active = true
window.Parent = ControlGui
addCorner(window, 14)
addStroke(window, COLORS.border, 1)

local windowScale = Instance.new("UIScale")
windowScale.Name = "ResponsiveScale"
windowScale.Parent = window

local function isMobileProfile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function updateResponsiveScale()
    local viewport = Camera.ViewportSize
    local desired = isMobileProfile() and 0.60 or 0.50
    local fitScale = math.min((viewport.X - 24) / 480, (viewport.Y - 24) / 610)
    windowScale.Scale = math.clamp(math.min(desired, fitScale), 0.35, desired)
end

updateResponsiveScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 72)
topbar.BackgroundColor3 = COLORS.panel
topbar.BorderSizePixel = 0
topbar.Active = true
topbar.Parent = window
addCorner(topbar, 14)

local topbarMask = Instance.new("Frame")
topbarMask.Size = UDim2.new(1, 0, 0, 16)
topbarMask.Position = UDim2.new(0, 0, 1, -16)
topbarMask.BackgroundColor3 = COLORS.panel
topbarMask.BorderSizePixel = 0
topbarMask.Parent = topbar

local brandMark = Instance.new("Frame")
brandMark.Size = UDim2.new(0, 34, 0, 34)
brandMark.Position = UDim2.new(0, 18, 0, 18)
brandMark.BackgroundColor3 = COLORS.accentDark
brandMark.BorderSizePixel = 0
brandMark.Parent = topbar
addCorner(brandMark, 10)
local mark = Instance.new("Frame")
mark.Size = UDim2.new(0, 12, 0, 12)
mark.Position = UDim2.new(0.5, -6, 0.5, -6)
mark.BackgroundColor3 = COLORS.accent
mark.BorderSizePixel = 0
mark.Parent = brandMark
addCorner(mark, 6)

local title = makeLabel(topbar, "AIMLOCK CONTROL CENTER",
    UDim2.new(0, 260, 0, 20), COLORS.text, Enum.Font.GothamBold)
title.Position = UDim2.new(0, 66, 0, 16)
title.TextSize = 14
local subtitle = makeLabel(topbar, "Orb targeting  /  visual telemetry",
    UDim2.new(0, 280, 0, 18), COLORS.muted, Enum.Font.Gotham)
subtitle.Position = UDim2.new(0, 66, 0, 37)
subtitle.TextSize = 11

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -86, 0, 24)
statusDot.BackgroundColor3 = COLORS.danger
statusDot.BorderSizePixel = 0
statusDot.Parent = topbar
addCorner(statusDot, 4)
local statusText = makeLabel(topbar, "OFF", UDim2.new(0, 40, 0, 18),
    COLORS.muted, Enum.Font.GothamBold)
statusText.Position = UDim2.new(1, -72, 0, 19)
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Right

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -34, 0, 7)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = COLORS.muted
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 22
closeButton.Parent = topbar
closeButton.Activated:Connect(function() window.Visible = false end)

local nav = Instance.new("ScrollingFrame")
nav.Name = "Navigation"
nav.Size = UDim2.new(0, 112, 1, -88)
nav.Position = UDim2.new(0, 12, 0, 82)
nav.BackgroundColor3 = COLORS.panel
nav.BorderSizePixel = 0
nav.CanvasSize = UDim2.new(0, 0, 0, 0)
nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
nav.ScrollBarThickness = 3
nav.ScrollBarImageColor3 = COLORS.accentDark
nav.ScrollingDirection = Enum.ScrollingDirection.Y
nav.Parent = window
addCorner(nav, 10)
local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 5)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = nav
local navPadding = Instance.new("UIPadding")
navPadding.PaddingTop = UDim.new(0, 10)
navPadding.PaddingLeft = UDim.new(0, 7)
navPadding.PaddingRight = UDim.new(0, 7)
navPadding.Parent = nav

local dButton = Instance.new("TextButton")
dButton.Name = "DragToggleButton"
dButton.AnchorPoint = Vector2.new(0.5, 0.5)
dButton.Position = UDim2.new(0, 34, 0.5, 0)
dButton.Size = UDim2.new(0, 54, 0, 54)
dButton.BackgroundColor3 = COLORS.accentDark
dButton.BorderSizePixel = 0
dButton.Text = "D"
dButton.TextColor3 = COLORS.text
dButton.TextSize = 22
dButton.Font = Enum.Font.GothamBold
dButton.AutoButtonColor = false
dButton.ZIndex = 40
dButton.Parent = ControlGui
addCorner(dButton, 30)
addStroke(dButton, COLORS.accent, 2)

local dHint = Instance.new("TextLabel")
dHint.Name = "DragHint"
dHint.Size = UDim2.new(0, 74, 0, 16)
dHint.Position = UDim2.new(0.5, -37, 1, 3)
dHint.BackgroundTransparency = 1
dHint.Text = "DRAG / OPEN"
dHint.TextColor3 = COLORS.muted
dHint.TextSize = 8
dHint.Font = Enum.Font.GothamBold
dHint.Parent = dButton

local dDragInput, dDragStart, dStartPosition
local dMoved = false
dButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dDragInput = input
        dDragStart = input.Position
        dStartPosition = dButton.Position
        dMoved = false
    end
end)
dButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input ~= dDragInput or not dDragStart or not dStartPosition then return end
    local delta = input.Position - dDragStart
    if delta.Magnitude > 6 then dMoved = true end
    local viewport = Camera.ViewportSize
    local x = math.clamp(dStartPosition.X.Offset + delta.X, 28, viewport.X - 28)
    local y = math.clamp(dStartPosition.Y.Scale * viewport.Y + dStartPosition.Y.Offset + delta.Y,
        28, viewport.Y - 28)
    dButton.Position = UDim2.new(
        0, x, 0, y)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dDragInput, dDragStart, dStartPosition = nil, nil, nil
    end
end)

local dPressedAt
dButton.Activated:Connect(function()
    if dMoved then dMoved = false return end
    if dPressedAt and os.clock() - dPressedAt < 0.25 then return end
    dPressedAt = os.clock()
    window.Visible = not window.Visible
end)

-- ── Inline orb setup controls ─────────────────────────────────
-- These controls stay on the play screen while placement is active, so the
-- user does not have to reopen the panel between every orb action.
do
local orbQuickBar = Instance.new("Frame")
orbQuickBar.Name = "OrbQuickBar"
orbQuickBar.AnchorPoint = Vector2.new(0.5, 1)
orbQuickBar.Position = UDim2.new(0.5, 0, 1, -24)
orbQuickBar.Size = UDim2.new(0, 360, 0, 44)
orbQuickBar.BackgroundColor3 = COLORS.panel
orbQuickBar.BorderSizePixel = 0
orbQuickBar.Visible = false
orbQuickBar.ZIndex = 45
orbQuickBar.Parent = ControlGui
addCorner(orbQuickBar, 12)
addStroke(orbQuickBar, COLORS.accentDark, 1)

local orbQuickLayout = Instance.new("UIListLayout")
orbQuickLayout.FillDirection = Enum.FillDirection.Horizontal
orbQuickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
orbQuickLayout.VerticalAlignment = Enum.VerticalAlignment.Center
orbQuickLayout.Padding = UDim.new(0, 5)
orbQuickLayout.Parent = orbQuickBar

local orbQuickButtons = {}
local function makeOrbQuickButton(id, text, color, callback)
    local button = Instance.new("TextButton")
    button.Name = id
    button.Size = UDim2.new(0, 78, 0, 30)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ZIndex = 46
    button.Parent = orbQuickBar
    addCorner(button, 8)
    button.Activated:Connect(callback)
    orbQuickButtons[id] = button
    return button
end

makeOrbQuickButton("AddOrb", "+ ORB", COLORS.accentDark, function()
    if not OrbSystem.setupActive then beginOrbSetup() end
    if OrbSystem.setupActive then createPreviewOrb() end
end)
makeOrbQuickButton("UndoOrb", "UNDO", COLORS.warning, undoPreviewOrb)
makeOrbQuickButton("SetOrbs", "SET", COLORS.good, setPreviewOrbs)
makeOrbQuickButton("CancelOrbs", "CANCEL", COLORS.danger, cancelOrbSetup)

local floatQuickBar = Instance.new("Frame")
floatQuickBar.Name = "FloatingOrbQuickBar"
floatQuickBar.AnchorPoint = Vector2.new(0.5, 1)
floatQuickBar.Position = UDim2.new(0.5, 0, 1, -76)
floatQuickBar.Size = UDim2.new(0, 180, 0, 36)
floatQuickBar.BackgroundColor3 = COLORS.panel
floatQuickBar.BorderSizePixel = 0
floatQuickBar.Visible = false
floatQuickBar.ZIndex = 45
floatQuickBar.Parent = ControlGui
addCorner(floatQuickBar, 10)
addStroke(floatQuickBar, COLORS.accentDark, 1)
local floatQuickLayout = Instance.new("UIListLayout")
floatQuickLayout.FillDirection = Enum.FillDirection.Horizontal
floatQuickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
floatQuickLayout.VerticalAlignment = Enum.VerticalAlignment.Center
floatQuickLayout.Padding = UDim.new(0, 5)
floatQuickLayout.Parent = floatQuickBar

local function makeHoldFloatButton(name, text, directionKey)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 78, 0, 26)
    button.BackgroundColor3 = COLORS.accentDark
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ZIndex = 46
    button.Parent = floatQuickBar
    addCorner(button, 7)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            OrbSystem[directionKey] = true
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            OrbSystem[directionKey] = false
        end
    end)
end

makeHoldFloatButton("FloatForward", "FORWARD", "forwardHeld")
makeHoldFloatButton("FloatBackward", "BACKWARD", "backwardHeld")

OrbSystem.quickBar = orbQuickBar
OrbSystem.floatQuickBar = floatQuickBar
OrbSystem.quickButtons = orbQuickButtons
end

local function refreshOrbQuickBar()
    OrbSystem.quickBar.Visible = OrbSystem.setupActive and S.orbEnabled == true
    OrbSystem.floatQuickBar.Visible = OrbSystem.setupActive
        and OrbSystem.floatMode == true and S.orbEnabled == true
    local hasPreview = #OrbSystem.preview > 0
    OrbSystem.quickButtons.UndoOrb.Active = hasPreview
    OrbSystem.quickButtons.UndoOrb.AutoButtonColor = hasPreview
    OrbSystem.quickButtons.SetOrbs.Active = hasPreview
    OrbSystem.quickButtons.SetOrbs.AutoButtonColor = hasPreview
    OrbSystem.quickButtons.UndoOrb.BackgroundColor3 = hasPreview
        and COLORS.warning or COLORS.border
    OrbSystem.quickButtons.SetOrbs.BackgroundColor3 = hasPreview
        and COLORS.good or COLORS.border
end

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -140, 1, -88)
content.Position = UDim2.new(0, 132, 0, 82)
content.BackgroundTransparency = 1
content.Parent = window

local pages = {}
local navButtons = {}
local activePage = nil

local function createPage(id, label)
    local page = Instance.new("ScrollingFrame")
    page.Name = id
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = COLORS.accentDark
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = page
    page:SetAttribute("ControlOrder", 0)

    local navButton = Instance.new("TextButton")
    navButton.Name = id .. "Nav"
    navButton.Size = UDim2.new(1, 0, 0, 38)
    navButton.BackgroundColor3 = COLORS.panel
    navButton.Text = label
    navButton.TextColor3 = COLORS.muted
    navButton.TextSize = 11
    navButton.Font = Enum.Font.GothamSemibold
    navButton.TextXAlignment = Enum.TextXAlignment.Left
    navButton.AutoButtonColor = false
    navButton.Parent = nav
    addCorner(navButton, 7)
    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.Parent = navButton
    navButton.Activated:Connect(function()
        for _, entry in pairs(pages) do entry.page.Visible = false end
        for _, entry in pairs(navButtons) do
            entry.BackgroundColor3 = COLORS.panel
            entry.TextColor3 = COLORS.muted
        end
        page.Visible = true
        navButton.BackgroundColor3 = COLORS.accentDark
        navButton.TextColor3 = COLORS.text
        activePage = id
    end)

    pages[id] = { page = page, label = label }
    navButtons[id] = navButton
    return page
end

local function nextLayoutOrder(page)
    local nextOrder = (page:GetAttribute("ControlOrder") or 0) + 1
    page:SetAttribute("ControlOrder", nextOrder)
    return nextOrder
end

local function addSection(page, text)
    local label = makeLabel(page, text:upper(), UDim2.new(1, -8, 0, 24),
        COLORS.accent, Enum.Font.GothamBold)
    label.TextSize = 10
    label.LayoutOrder = nextLayoutOrder(page)
    return label
end

local function addCard(page, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, height or 48)
    card.BackgroundColor3 = COLORS.panel
    card.BorderSizePixel = 0
    card.LayoutOrder = nextLayoutOrder(page)
    card.Parent = page
    addCorner(card, 9)
    addStroke(card, COLORS.border, 1, 0.35)
    return card
end

local function addToggle(page, labelText, value, callback, detail)
    local card = addCard(page, detail and 58 or 46)
    local label = makeLabel(card, labelText, UDim2.new(1, -78, 0, 20),
        COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0, 14, 0, detail and 9 or 13)
    label.TextSize = 12
    if detail then
        local hint = makeLabel(card, detail, UDim2.new(1, -100, 0, 16),
            COLORS.muted, Enum.Font.Gotham)
        hint.Position = UDim2.new(0, 14, 0, 31)
        hint.TextSize = 10
    end
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 42, 0, 24)
    button.Position = UDim2.new(1, -56, 0.5, -12)
    button.BackgroundColor3 = value and COLORS.good or COLORS.border
    button.Text = value and "ON" or "OFF"
    button.TextColor3 = value and COLORS.background or COLORS.muted
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = card
    addCorner(button, 12)
    local current = value
    local function sync(nextValue)
        current = nextValue == true
        button.BackgroundColor3 = current and COLORS.good or COLORS.border
        button.Text = current and "ON" or "OFF"
        button.TextColor3 = current and COLORS.background or COLORS.muted
    end
    button.Activated:Connect(function()
        local nextValue = not current
        callback(nextValue)
        sync(nextValue)
    end)
    return card, sync
end

local function addNumber(page, labelText, value, minValue, maxValue, callback, suffix)
    local card = addCard(page, 46)
    local label = makeLabel(card, labelText, UDim2.new(1, -140, 1, 0),
        COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.TextSize = 11
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 94, 0, 28)
    box.Position = UDim2.new(1, -108, 0.5, -14)
    box.BackgroundColor3 = COLORS.panelAlt
    box.BorderSizePixel = 0
    box.Text = tostring(value)
    box.PlaceholderText = suffix or ""
    box.TextColor3 = COLORS.text
    box.PlaceholderColor3 = COLORS.muted
    box.TextSize = 11
    box.Font = Enum.Font.GothamSemibold
    box.ClearTextOnFocus = false
    box.Parent = card
    addCorner(box, 6)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if not n then box.Text = tostring(value); return end
        n = math.clamp(n, minValue, maxValue)
        value = n
        box.Text = tostring(n)
        callback(n)
    end)
    return card
end

local function addTextInput(page, labelText, value, callback, placeholder)
    local card = addCard(page, 46)
    local label = makeLabel(card, labelText, UDim2.new(1, -140, 1, 0),
        COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.TextSize = 11
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 128, 0, 28)
    box.Position = UDim2.new(1, -142, 0.5, -14)
    box.BackgroundColor3 = COLORS.panelAlt
    box.BorderSizePixel = 0
    box.Text = tostring(value or "")
    box.PlaceholderText = placeholder or ""
    box.TextColor3 = COLORS.text
    box.PlaceholderColor3 = COLORS.muted
    box.TextSize = 11
    box.Font = Enum.Font.GothamSemibold
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = card
    addCorner(box, 6)
    box.FocusLost:Connect(function()
        if box.Text == "" then box.Text = tostring(value or "") return end
        value = box.Text
        callback(value)
    end)
    return card
end

local function addChoice(page, labelText, value, options, callback)
    local card = addCard(page, 46)
    local label = makeLabel(card, labelText, UDim2.new(1, -150, 1, 0),
        COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.TextSize = 11
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 122, 0, 28)
    button.Position = UDim2.new(1, -136, 0.5, -14)
    button.BackgroundColor3 = COLORS.panelAlt
    button.BorderSizePixel = 0
    button.TextColor3 = COLORS.text
    button.TextSize = 10
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.Parent = card
    addCorner(button, 6)

    local currentIndex = 1
    for index, option in ipairs(options) do
        if option == value then currentIndex = index break end
    end
    local function sync()
        button.Text = tostring(options[currentIndex] or options[1])
    end
    sync()
    button.Activated:Connect(function()
        currentIndex = currentIndex % #options + 1
        local nextValue = options[currentIndex]
        callback(nextValue)
        sync()
    end)
    return card
end

local function addKeybind(page, labelText, keyCode, callback)
    local card = addCard(page, 46)
    local label = makeLabel(card, labelText, UDim2.new(1, -150, 1, 0),
        COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.TextSize = 11
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 122, 0, 28)
    button.Position = UDim2.new(1, -136, 0.5, -14)
    button.BackgroundColor3 = COLORS.panelAlt
    button.BorderSizePixel = 0
    button.TextColor3 = COLORS.accent
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = card
    addCorner(button, 6)

    local listening = false
    local captureConnection
    local function render(value)
        button.Text = listening and "PRESS A KEY" or (value and value.Name or "NONE")
    end
    render(keyCode)
    button.Activated:Connect(function()
        if listening then return end
        listening = true
        render(keyCode)
        captureConnection = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe or input.KeyCode == Enum.KeyCode.Unknown then return end
            keyCode = input.KeyCode
            listening = false
            if captureConnection then captureConnection:Disconnect() end
            captureConnection = nil
            callback(keyCode)
            render(keyCode)
        end)
    end)
    return card
end

local openListPopup
local function addMultiList(page, labelText, getOptions, getSelected, setSelected)
    local card = addCard(page, 46)
    local label = makeLabel(card, labelText, UDim2.new(1, -150, 1, 0),
        COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.TextSize = 11
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 122, 0, 28)
    button.Position = UDim2.new(1, -136, 0.5, -14)
    button.BackgroundColor3 = COLORS.panelAlt
    button.BorderSizePixel = 0
    button.TextColor3 = COLORS.text
    button.TextSize = 10
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.Parent = card
    addCorner(button, 6)

    local function refreshButton()
        local count = 0
        for _ in pairs(getSelected()) do count = count + 1 end
        button.Text = count == 0 and "NONE SELECTED" or (tostring(count) .. " SELECTED")
    end
    refreshButton()

    button.Activated:Connect(function()
        if openListPopup then openListPopup:Destroy() openListPopup = nil end
        local popup = Instance.new("Frame")
        popup.Name = "MultiListPopup"
        popup.Size = UDim2.new(0, 250, 0, 270)
        popup.Position = UDim2.new(0, 122, 0, 45)
        popup.BackgroundColor3 = COLORS.background
        popup.BorderSizePixel = 0
        popup.ZIndex = 60
        popup.Parent = window
        addCorner(popup, 9)
        addStroke(popup, COLORS.accentDark, 1)
        openListPopup = popup

        local titleLabel = makeLabel(popup, labelText, UDim2.new(1, -54, 0, 28),
            COLORS.text, Enum.Font.GothamBold)
        titleLabel.Position = UDim2.new(0, 12, 0, 5)
        titleLabel.TextSize = 11
        titleLabel.ZIndex = 61
        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 26, 0, 26)
        close.Position = UDim2.new(1, -32, 0, 5)
        close.BackgroundTransparency = 1
        close.Text = "×"
        close.TextColor3 = COLORS.muted
        close.TextSize = 18
        close.Font = Enum.Font.GothamBold
        close.ZIndex = 61
        close.Parent = popup
        close.Activated:Connect(function()
            setSelected(getSelected())
            refreshButton()
            popup:Destroy()
            openListPopup = nil
        end)

        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, -20, 1, -48)
        list.Position = UDim2.new(0, 10, 0, 40)
        list.BackgroundTransparency = 1
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 3
        list.ScrollBarImageColor3 = COLORS.accentDark
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.ZIndex = 61
        list.Parent = popup
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 4)
        listLayout.Parent = list

        local selected = {}
        for key, value in pairs(getSelected()) do selected[key] = value end
        for _, option in ipairs(getOptions()) do
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -4, 0, 30)
            row.BackgroundColor3 = selected[string.lower(option)]
                and COLORS.accentDark or COLORS.panelAlt
            row.BorderSizePixel = 0
            row.Text = (selected[string.lower(option)] and "✓  " or "    ") .. option
            row.TextColor3 = COLORS.text
            row.TextSize = 10
            row.Font = Enum.Font.GothamSemibold
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.ZIndex = 62
            row.Parent = list
            addCorner(row, 5)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 8)
            pad.Parent = row
            row.Activated:Connect(function()
                local key = string.lower(option)
                selected[key] = not selected[key]
                row.BackgroundColor3 = selected[key] and COLORS.accentDark or COLORS.panelAlt
                row.Text = (selected[key] and "✓  " or "    ") .. option
                setSelected(selected)
                refreshButton()
            end)
        end
    end)
    return card
end

local function makeRotationEditor(page, titleText, prefix, enabledKey, rateKey, unitKey, missKey)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 48)
    container.BackgroundColor3 = COLORS.panel
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.LayoutOrder = nextLayoutOrder(page)
    container.Parent = page
    addCorner(container, 9)
    addStroke(container, COLORS.border, 1, 0.35)

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 46)
    header.BackgroundTransparency = 1
    header.Text = (S[enabledKey] and "▾  " or "▸  ") .. titleText
    header.TextColor3 = COLORS.text
    header.TextSize = 12
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.AutoButtonColor = false
    header.Parent = container
    local headerPadding = Instance.new("UIPadding")
    headerPadding.PaddingLeft = UDim.new(0, 14)
    header.Parent = container
    headerPadding.Parent = header

    local enable = Instance.new("TextButton")
    enable.Size = UDim2.new(0, 42, 0, 24)
    enable.Position = UDim2.new(1, -56, 0, 11)
    enable.BackgroundColor3 = S[enabledKey] and COLORS.good or COLORS.border
    enable.Text = S[enabledKey] and "ON" or "OFF"
    enable.TextColor3 = S[enabledKey] and COLORS.background or COLORS.muted
    enable.TextSize = 9
    enable.Font = Enum.Font.GothamBold
    enable.AutoButtonColor = false
    enable.Parent = container
    addCorner(enable, 12)

    local body = Instance.new("Frame")
    body.Position = UDim2.new(0, 10, 0, 50)
    body.Size = UDim2.new(1, -20, 0, 0)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = container
    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0, 6)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.Parent = body

    local function bodyRow(height)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, height or 42)
        row.BackgroundColor3 = COLORS.panelAlt
        row.BorderSizePixel = 0
        row.LayoutOrder = #body:GetChildren()
        row.Parent = body
        addCorner(row, 7)
        return row
    end

    local function bodyLabel(row, text)
        local label = makeLabel(row, text, UDim2.new(0.46, 0, 1, 0),
            COLORS.text, Enum.Font.GothamSemibold)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.TextSize = 10
        return label
    end

    local rateRow = bodyRow()
    bodyLabel(rateRow, "Switch rate")
    local rateBox = Instance.new("TextBox")
    rateBox.Size = UDim2.new(0, 74, 0, 26)
    rateBox.Position = UDim2.new(1, -158, 0.5, -13)
    rateBox.BackgroundColor3 = COLORS.background
    rateBox.BorderSizePixel = 0
    rateBox.Text = tostring(S[rateKey])
    rateBox.TextColor3 = COLORS.text
    rateBox.TextSize = 10
    rateBox.Font = Enum.Font.GothamSemibold
    rateBox.ClearTextOnFocus = false
    rateBox.Parent = rateRow
    addCorner(rateBox, 5)
    rateBox.FocusLost:Connect(function()
        local n = tonumber(rateBox.Text)
        if n then
            S[rateKey] = math.clamp(math.floor(n + 0.5), 1, 5000)
            rateBox.Text = tostring(S[rateKey])
        else
            rateBox.Text = tostring(S[rateKey])
        end
    end)
    local unitButton = Instance.new("TextButton")
    unitButton.Size = UDim2.new(0, 64, 0, 26)
    unitButton.Position = UDim2.new(1, -78, 0.5, -13)
    unitButton.BackgroundColor3 = COLORS.background
    unitButton.BorderSizePixel = 0
    unitButton.Text = tostring(S[unitKey])
    unitButton.TextColor3 = COLORS.accent
    unitButton.TextSize = 10
    unitButton.Font = Enum.Font.GothamBold
    unitButton.AutoButtonColor = false
    unitButton.Parent = rateRow
    addCorner(unitButton, 5)
    unitButton.Activated:Connect(function()
        S[unitKey] = S[unitKey] == "ms" and "s" or "ms"
        unitButton.Text = S[unitKey]
    end)

    local rowParts = {}
    local rotationMenu
    local function closeRotationMenu()
        if rotationMenu then
            rotationMenu:Destroy()
            rotationMenu = nil
        end
    end
    local function openRotationMenu(anchor, options, selectOption)
        closeRotationMenu()
        local position = anchor.AbsolutePosition
        local size = anchor.AbsoluteSize
        local menu = Instance.new("ScrollingFrame")
        menu.Name = "RotationPartMenu"
        menu.Position = UDim2.new(0, position.X, 0, position.Y + size.Y + 4)
        menu.Size = UDim2.new(0, 168, 0, math.min(260, #options * 28 + 8))
        menu.BackgroundColor3 = COLORS.background
        menu.BorderSizePixel = 0
        menu.ScrollBarThickness = 3
        menu.ScrollBarImageColor3 = COLORS.accentDark
        menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
        menu.CanvasSize = UDim2.new(0, 0, 0, 0)
        menu.ZIndex = 90
        menu.Parent = ControlGui
        addCorner(menu, 8)
        addStroke(menu, COLORS.accentDark, 1)
        local menuLayout = Instance.new("UIListLayout")
        menuLayout.Padding = UDim.new(0, 3)
        menuLayout.Parent = menu
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 4)
        padding.PaddingLeft = UDim.new(0, 4)
        padding.PaddingRight = UDim.new(0, 4)
        padding.Parent = menu
        rotationMenu = menu

        for _, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, -8, 0, 26)
            optionButton.BackgroundColor3 = COLORS.panelAlt
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = COLORS.text
            optionButton.TextSize = 10
            optionButton.Font = Enum.Font.GothamSemibold
            optionButton.TextXAlignment = Enum.TextXAlignment.Left
            optionButton.ZIndex = 91
            optionButton.Parent = menu
            addCorner(optionButton, 5)
            local optionPadding = Instance.new("UIPadding")
            optionPadding.PaddingLeft = UDim.new(0, 8)
            optionPadding.Parent = optionButton
            optionButton.Activated:Connect(function()
                selectOption(option)
                closeRotationMenu()
            end)
        end
    end
    for index = 1, 5 do
        local row = bodyRow()
        bodyLabel(row, "Row " .. index .. " part")
        local partButton = Instance.new("TextButton")
        partButton.Size = UDim2.new(0, 114, 0, 26)
        partButton.Position = UDim2.new(0.43, 0, 0.5, -13)
        partButton.BackgroundColor3 = COLORS.background
        partButton.BorderSizePixel = 0
        partButton.TextColor3 = COLORS.text
        partButton.TextSize = 9
        partButton.Font = Enum.Font.GothamSemibold
        partButton.AutoButtonColor = false
        partButton.Parent = row
        addCorner(partButton, 5)
        local chanceBox = Instance.new("TextBox")
        chanceBox.Size = UDim2.new(0, 58, 0, 26)
        chanceBox.Position = UDim2.new(1, -68, 0.5, -13)
        chanceBox.BackgroundColor3 = COLORS.background
        chanceBox.BorderSizePixel = 0
        chanceBox.TextColor3 = COLORS.text
        chanceBox.TextSize = 10
        chanceBox.Font = Enum.Font.GothamSemibold
        chanceBox.ClearTextOnFocus = false
        chanceBox.Parent = row
        addCorner(chanceBox, 5)
        local options = COMMON_PARTS
        local selectedIndex = 1
        local currentPart = S[prefix .. index .. "Part"]
        for optionIndex, option in ipairs(options) do
            local normalized = option == "(none)" and "" or option
            if normalized == currentPart then selectedIndex = optionIndex break end
        end
        local function syncPart()
            local selected = options[selectedIndex]
            partButton.Text = selected
            S[prefix .. index .. "Part"] = selected == "(none)" and "" or selected
        end
        syncPart()
        chanceBox.Text = tostring(S[prefix .. index .. "Chance"] or 0) .. "%"
        partButton.Activated:Connect(function()
            openRotationMenu(partButton, options, function(selected)
                for optionIndex, option in ipairs(options) do
                    if option == selected then
                        selectedIndex = optionIndex
                        break
                    end
                end
                syncPart()
            end)
        end)
        chanceBox.FocusLost:Connect(function()
            local n = tonumber(string.gsub(chanceBox.Text, "%%", ""))
            if n then
                n = math.clamp(math.floor(n + 0.5), 0, getTPBudget(prefix, index))
                S[prefix .. index .. "Chance"] = n
            end
            chanceBox.Text = tostring(S[prefix .. index .. "Chance"] or 0) .. "%"
        end)
        rowParts[index] = { part = partButton, chance = chanceBox }
    end

    local missRow = bodyRow()
    bodyLabel(missRow, "Miss on (none) rows")
    local missButton = Instance.new("TextButton")
    missButton.Size = UDim2.new(0, 42, 0, 24)
    missButton.Position = UDim2.new(1, -56, 0.5, -12)
    missButton.BackgroundColor3 = S[missKey] and COLORS.good or COLORS.border
    missButton.Text = S[missKey] and "ON" or "OFF"
    missButton.TextColor3 = S[missKey] and COLORS.background or COLORS.muted
    missButton.TextSize = 9
    missButton.Font = Enum.Font.GothamBold
    missButton.AutoButtonColor = false
    missButton.Parent = missRow
    addCorner(missButton, 12)
    missButton.Activated:Connect(function()
        S[missKey] = not S[missKey]
        missButton.BackgroundColor3 = S[missKey] and COLORS.good or COLORS.border
        missButton.Text = S[missKey] and "ON" or "OFF"
        missButton.TextColor3 = S[missKey] and COLORS.background or COLORS.muted
    end)

    local bodyHeight = 42 * 7 + 6 * 6
    local open = S[enabledKey] == true
    local function setOpen(value)
        open = value
        S[enabledKey] = value
        local targetBody = value and bodyHeight or 0
        local targetContainer = 48 + (value and bodyHeight + 10 or 0)
        header.Text = (value and "▾  " or "▸  ") .. titleText
        enable.BackgroundColor3 = value and COLORS.good or COLORS.border
        enable.Text = value and "ON" or "OFF"
        enable.TextColor3 = value and COLORS.background or COLORS.muted
        TweenService:Create(body, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, -20, 0, targetBody) }):Play()
        TweenService:Create(container, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, -8, 0, targetContainer) }):Play()
    end
    header.Activated:Connect(function() setOpen(not open) end)
    enable.Activated:Connect(function() setOpen(not open) end)
    if open then
        body.Size = UDim2.new(1, -20, 0, bodyHeight)
        container.Size = UDim2.new(1, -8, 0, 48 + bodyHeight + 10)
    end
    return container
end

local function addAction(page, labelText, callback, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 42)
    button.BackgroundColor3 = color or COLORS.panelAlt
    button.BorderSizePixel = 0
    button.Text = labelText
    button.TextColor3 = COLORS.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.AutoButtonColor = false
    button.LayoutOrder = nextLayoutOrder(page)
    button.Parent = page
    addCorner(button, 8)
    addStroke(button, COLORS.border, 1, 0.3)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = color and color:Lerp(Color3.new(1, 1, 1), 0.08)
            or COLORS.accentDark
    end)
    button.MouseLeave:Connect(function() button.BackgroundColor3 = color or COLORS.panelAlt end)
    button.Activated:Connect(callback)
    return button
end

local function addActionRow(page, actions)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 42)
    row.BackgroundTransparency = 1
    row.LayoutOrder = nextLayoutOrder(page)
    row.Parent = page
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.Parent = row
    for _, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1 / #actions, -6, 1, 0)
        button.BackgroundColor3 = action.color or COLORS.panelAlt
        button.BorderSizePixel = 0
        button.Text = action.label
        button.TextColor3 = COLORS.text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 10
        button.AutoButtonColor = false
        button.Parent = row
        addCorner(button, 8)
        addStroke(button, COLORS.border, 1, 0.3)
        button.Activated:Connect(action.callback)
    end
    return row
end

-- ── Save / Load snapshots ─────────────────────────────────────
-- Snapshots contain the complete settings table, including normalized
-- crosshair and button positions, but never copy OrbSystem.saved/preview.
-- Orb rigs are runtime objects; loading a setup must not recreate them.
local saveState = {
    savedSetups = {},
    nextSetupId = 1,
}

function saveState.cloneSetupValue(value)
    local valueType = typeof(value)
    if valueType == "UDim2" then
        return UDim2.new(value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
    elseif valueType == "Color3" then
        return Color3.new(value.R, value.G, value.B)
    elseif type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = saveState.cloneSetupValue(item)
    end
    return result
end

function saveState.captureSetup()
    local snapshot = {}
    for key, value in pairs(S) do
        snapshot[key] = saveState.cloneSetupValue(value)
    end
    return snapshot
end

function saveState.refreshAfterLoad()
    if not S.orbEnabled then cancelOrbSetup() end
    applyCrosshairPosition(S.aimlockCrosshairPos)
    syncCrosshairShape()
    syncCrosshairImage()
    if syncCrosshairEditorVisual then syncCrosshairEditorVisual() end
    refreshModeButtons()
    if Aimlock.fovCircle then
        Aimlock.fovCircle.Visible = S.aimlockShowFOV == true
        Aimlock.fovCircle.Size = UDim2.new(0, S.aimlockFOVRingSize * 2,
            0, S.aimlockFOVRingSize * 2)
    end
    if Aimlock.fovStroke then
        Aimlock.fovStroke.Color = Color3.fromRGB(
            S.aimlockFOVColorR, S.aimlockFOVColorG, S.aimlockFOVColorB)
    end
end

function saveState.saveSetup(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return false end
    local id = "setup-" .. tostring(saveState.nextSetupId)
    saveState.nextSetupId = saveState.nextSetupId + 1
    table.insert(saveState.savedSetups, {
        id = id,
        name = name,
        values = saveState.captureSetup(),
    })
    return true
end

function saveState.loadSetup(entry)
    if not entry or not entry.values then return false end
    for key, value in pairs(entry.values) do
        S[key] = saveState.cloneSetupValue(value)
    end
    saveState.refreshAfterLoad()
    return true
end

function saveState.renameSetup(entry, name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if not entry or name == "" then return false end
    entry.name = name
    return true
end

local savePage

local function setModePage(id)
    if navButtons[id] then navButtons[id]:Activate() end
end

local controlPage = createPage("Control", "CONTROL")
local orbPage = createPage("OrbMarks", "ORB MARKS")
local targetPage = createPage("Targeting", "TARGETING")
local behaviourPage = createPage("Behaviour", "BEHAVIOUR")
local visualPage = createPage("Visuals", "VISUALS")
local rotationPage = createPage("Rotation", "ROTATION")
local lockPage = createPage("LockList", "LOCK LIST")
local keybindPage = createPage("Keybinds", "KEYBINDS")
local configPage = createPage("Settings", "SETTINGS")
savePage = createPage("SaveLoad", "SAVE / LOAD")

addSection(savePage, "Create setup")
saveState.createSaveCard = addCard(savePage, 66)
saveState.saveNameBox = Instance.new("TextBox")
saveState.saveNameBox.Size = UDim2.new(1, -76, 0, 34)
saveState.saveNameBox.Position = UDim2.new(0, 10, 0.5, -17)
saveState.saveNameBox.BackgroundColor3 = COLORS.panelAlt
saveState.saveNameBox.BorderSizePixel = 0
saveState.saveNameBox.Text = ""
saveState.saveNameBox.PlaceholderText = "Name this setup"
saveState.saveNameBox.TextColor3 = COLORS.text
saveState.saveNameBox.PlaceholderColor3 = COLORS.muted
saveState.saveNameBox.TextSize = 11
saveState.saveNameBox.Font = Enum.Font.GothamSemibold
saveState.saveNameBox.ClearTextOnFocus = false
saveState.saveNameBox.TextXAlignment = Enum.TextXAlignment.Left
saveState.saveNameBox.Parent = saveState.createSaveCard
addCorner(saveState.saveNameBox, 8)
saveState.saveNamePadding = Instance.new("UIPadding")
saveState.saveNamePadding.PaddingLeft = UDim.new(0, 10)
saveState.saveNamePadding.Parent = saveState.saveNameBox

saveState.createSaveButton = Instance.new("TextButton")
saveState.createSaveButton.Size = UDim2.new(0, 48, 0, 34)
saveState.createSaveButton.Position = UDim2.new(1, -58, 0.5, -17)
saveState.createSaveButton.BackgroundColor3 = COLORS.good
saveState.createSaveButton.BorderSizePixel = 0
saveState.createSaveButton.Text = "+"
saveState.createSaveButton.TextColor3 = COLORS.background
saveState.createSaveButton.TextSize = 24
saveState.createSaveButton.Font = Enum.Font.GothamBold
saveState.createSaveButton.AutoButtonColor = false
saveState.createSaveButton.Parent = saveState.createSaveCard
addCorner(saveState.createSaveButton, 8)

saveState.status = makeLabel(savePage, "No setups saved yet",
    UDim2.new(1, -8, 0, 22), COLORS.muted, Enum.Font.Gotham)
saveState.status.TextSize = 10
saveState.status.LayoutOrder = nextLayoutOrder(savePage)

saveState.list = Instance.new("ScrollingFrame")
saveState.list.Name = "SavedSetupList"
saveState.list.Size = UDim2.new(1, -8, 0, 300)
saveState.list.BackgroundTransparency = 1
saveState.list.BorderSizePixel = 0
saveState.list.ScrollBarThickness = 3
saveState.list.ScrollBarImageColor3 = COLORS.accentDark
saveState.list.AutomaticCanvasSize = Enum.AutomaticSize.Y
saveState.list.CanvasSize = UDim2.new(0, 0, 0, 0)
saveState.list.LayoutOrder = nextLayoutOrder(savePage)
saveState.list.Parent = savePage
saveState.listLayout = Instance.new("UIListLayout")
saveState.listLayout.Padding = UDim.new(0, 6)
saveState.listLayout.SortOrder = Enum.SortOrder.LayoutOrder
saveState.listLayout.Parent = saveState.list

local function closeSavePopup()
    if saveState.popup then
        saveState.popup:Destroy()
        saveState.popup = nil
    end
end

local function openSavePopup(entry)
    closeSavePopup()
    local popup = Instance.new("Frame")
    popup.Name = "SaveContextMenu"
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.Position = UDim2.new(0.5, 0, 0.5, 0)
    popup.Size = UDim2.new(0, 300, 0, 178)
    popup.BackgroundColor3 = COLORS.background
    popup.BorderSizePixel = 0
    popup.ZIndex = 80
    popup.Parent = ControlGui
    addCorner(popup, 10)
    addStroke(popup, COLORS.accentDark, 1)
    saveState.popup = popup

    local titleLabel = makeLabel(popup, "EDIT SETUP", UDim2.new(1, -24, 0, 24),
        COLORS.accent, Enum.Font.GothamBold)
    titleLabel.Position = UDim2.new(0, 12, 0, 10)
    titleLabel.TextSize = 11
    titleLabel.ZIndex = 81

    local renameBox = Instance.new("TextBox")
    renameBox.Size = UDim2.new(1, -24, 0, 32)
    renameBox.Position = UDim2.new(0, 12, 0, 40)
    renameBox.BackgroundColor3 = COLORS.panelAlt
    renameBox.BorderSizePixel = 0
    renameBox.Text = entry.name
    renameBox.TextColor3 = COLORS.text
    renameBox.TextSize = 11
    renameBox.Font = Enum.Font.GothamSemibold
    renameBox.ClearTextOnFocus = false
    renameBox.ZIndex = 81
    renameBox.Parent = popup
    addCorner(renameBox, 7)
    local renamePadding = Instance.new("UIPadding")
    renamePadding.PaddingLeft = UDim.new(0, 9)
    renamePadding.Parent = renameBox

    local function popupButton(text, x, color, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 82, 0, 32)
        button.Position = UDim2.new(0, x, 1, -44)
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = COLORS.text
        button.TextSize = 10
        button.Font = Enum.Font.GothamBold
        button.AutoButtonColor = false
        button.ZIndex = 81
        button.Parent = popup
        addCorner(button, 7)
        button.Activated:Connect(callback)
        return button
    end

    popupButton("RENAME", 12, COLORS.accentDark, function()
        if saveState.renameSetup(entry, renameBox.Text) then
            saveState.status.Text = "Renamed setup: " .. entry.name
            saveState.refreshSaveRows()
        end
        closeSavePopup()
    end)
    popupButton("DELETE", 108, COLORS.danger, function()
        for index, candidate in ipairs(saveState.savedSetups) do
            if candidate == entry then
                table.remove(saveState.savedSetups, index)
                break
            end
        end
        saveState.status.Text = "Setup deleted"
        saveState.refreshSaveRows()
        closeSavePopup()
    end)
    popupButton("CANCEL", 204, COLORS.border, closeSavePopup)
end

saveState.refreshSaveRows = function()
    for _, child in ipairs(saveState.list:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    saveState.status.Text = #saveState.savedSetups == 0
        and "No setups saved yet"
        or (tostring(#saveState.savedSetups) .. " saved setup"
            .. (#saveState.savedSetups == 1 and "" or "s"))

    for index, entry in ipairs(saveState.savedSetups) do
        local row = Instance.new("Frame")
        row.Name = entry.id
        row.Size = UDim2.new(1, -4, 0, 48)
        row.BackgroundColor3 = COLORS.panel
        row.BorderSizePixel = 0
        row.LayoutOrder = index
        row.Parent = saveState.list
        addCorner(row, 8)
        addStroke(row, COLORS.border, 1, 0.35)

        local label = makeLabel(row, entry.name, UDim2.new(1, -170, 1, 0),
            COLORS.text, Enum.Font.GothamSemibold)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.TextSize = 11

        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0, 60, 0, 28)
        loadButton.Position = UDim2.new(1, -112, 0.5, -14)
        loadButton.BackgroundColor3 = COLORS.accentDark
        loadButton.BorderSizePixel = 0
        loadButton.Text = "LOAD"
        loadButton.TextColor3 = COLORS.text
        loadButton.TextSize = 9
        loadButton.Font = Enum.Font.GothamBold
        loadButton.AutoButtonColor = false
        loadButton.Parent = row
        addCorner(loadButton, 6)
        loadButton.Activated:Connect(function()
            if saveState.loadSetup(entry) then
                saveState.status.Text = "Loaded setup: " .. entry.name
            end
        end)

        local menuButton = Instance.new("TextButton")
        menuButton.Size = UDim2.new(0, 32, 0, 28)
        menuButton.Position = UDim2.new(1, -44, 0.5, -14)
        menuButton.BackgroundColor3 = COLORS.panelAlt
        menuButton.BorderSizePixel = 0
        menuButton.Text = "•••"
        menuButton.TextColor3 = COLORS.muted
        menuButton.TextSize = 12
        menuButton.Font = Enum.Font.GothamBold
        menuButton.AutoButtonColor = false
        menuButton.Parent = row
        addCorner(menuButton, 6)
        menuButton.Activated:Connect(function() openSavePopup(entry) end)
    end
end

saveState.createSaveButton.Activated:Connect(function()
    if saveState.saveSetup(saveState.saveNameBox.Text) then
        saveState.status.Text = "Saved setup: " .. saveState.saveNameBox.Text
        saveState.saveNameBox.Text = ""
        saveState.refreshSaveRows()
    else
        saveState.status.Text = "Enter a name before saving"
    end
end)
saveState.refreshSaveRows()

addSection(controlPage, "Session control")
addToggle(controlPage, "Enable aimlock", S.aimlockEnabled, function(v) setAimlock(v) end,
    "P toggles aimlock by default")
addToggle(controlPage, "Orb targets", S.targetOrbs, function(v)
    S.targetOrbs = v
    if not v then setAimlockTarget(nil) end
end, "Only saved, active orb marks can be selected")
addToggle(controlPage, "Player targets", S.targetPlayers, function(v) S.targetPlayers = v end)
addToggle(controlPage, "NPC targets", S.targetNPCs, function(v) S.targetNPCs = v end)
addToggle(controlPage, "Show target mode buttons", S._showModeBtns == true, function(v)
    S._showModeBtns = v
    refreshModeButtons()
end)
addActionRow(controlPage, {
    { label = "SWITCH LEFT", color = COLORS.accentDark, callback = function() switchTarget(-1) end },
    { label = "SWITCH RIGHT", color = COLORS.accentDark, callback = function() switchTarget(1) end },
})
addSection(controlPage, "Live state")
local targetStateCard = addCard(controlPage, 60)
local targetState = makeLabel(targetStateCard, "No target selected",
    UDim2.new(1, -28, 0, 22), COLORS.muted, Enum.Font.GothamSemibold)
targetState.Position = UDim2.new(0, 14, 0, 9)
local orbCountState = makeLabel(targetStateCard, "0 saved orb marks",
    UDim2.new(1, -28, 0, 18), COLORS.muted, Enum.Font.Gotham)
orbCountState.Position = UDim2.new(0, 14, 0, 32)

addSection(orbPage, "Placement workflow")
addToggle(orbPage, "Orb system enabled", S.orbEnabled, function(v)
    S.orbEnabled = v
    if not v then cancelOrbSetup() end
end, "Orbs are local target markers")
addActionRow(orbPage, {
    { label = "START", color = COLORS.accentDark, callback = beginOrbSetup },
    { label = "SPAWN", color = COLORS.good, callback = function()
        if not OrbSystem.setupActive then beginOrbSetup() end
        createPreviewOrb()
    end },
    { label = "UNDO", color = COLORS.warning, callback = undoPreviewOrb },
})
addActionRow(orbPage, {
    { label = "SET", color = COLORS.good, callback = setPreviewOrbs },
    { label = "CANCEL", color = COLORS.danger, callback = cancelOrbSetup },
})
addToggle(orbPage, "Float mode", OrbSystem.floatMode, function(v)
    OrbSystem.floatMode = v
    if v and OrbSystem.setupActive and #OrbSystem.preview == 0 then createPreviewOrb() end
    for _, data in ipairs(OrbSystem.preview) do
        refreshOrbAppearance(data)
    end
end, "Preview follows the crosshair from near the player")
addActionRow(orbPage, {
    { label = "FORWARD (HOLD)", color = COLORS.accentDark, callback = function() end },
    { label = "BACKWARD (HOLD)", color = COLORS.accentDark, callback = function() end },
})
local holdButtons = orbPage:GetChildren()
for _, child in ipairs(holdButtons) do
    if child:IsA("Frame") and (child:FindFirstChild("FORWARD (HOLD)") or child:FindFirstChild("BACKWARD (HOLD)")) then
        -- The row is created below through direct button discovery.
    end
end
-- Hold state is bound to the visible action buttons by text, without adding
-- another per-frame connection.
for _, child in ipairs(orbPage:GetChildren()) do
    if child:IsA("Frame") then
        for _, button in ipairs(child:GetChildren()) do
            if button:IsA("TextButton") and button.Text == "FORWARD (HOLD)" then
                button.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        OrbSystem.forwardHeld = true
                    end
                end)
                button.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        OrbSystem.forwardHeld = false
                    end
                end)
            elseif button:IsA("TextButton") and button.Text == "BACKWARD (HOLD)" then
                button.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        OrbSystem.backwardHeld = true
                    end
                end)
                button.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        OrbSystem.backwardHeld = false
                    end
                end)
            end
        end
    end
end
addNumber(orbPage, "Orb health", S.orbHP, 1, 100000, function(v) S.orbHP = v end, "HP")
addNumber(orbPage, "Respawn time", S.orbRespawnTime, 0, 3600, function(v) S.orbRespawnTime = v end, "seconds")
addNumber(orbPage, "Orb size", S.orbSize, 0.2, 20, function(v)
    S.orbSize = v
    for _, data in ipairs(OrbSystem.saved) do
        if data.part then data.part.Size = Vector3.new(v, v, v) end
    end
    for _, data in ipairs(OrbSystem.preview) do
        if data.part then data.part.Size = Vector3.new(v, v, v) end
    end
end, "studs")
addNumber(orbPage, "Float speed", S.orbFloatSpeed, 1, 200, function(v) S.orbFloatSpeed = v end, "studs/s")
addNumber(orbPage, "Placement distance", S.orbMaxPlacementDistance, 1, 5000,
    function(v) S.orbMaxPlacementDistance = v end, "studs")
addNumber(orbPage, "Delete FOV ring", S.orbDeleteFOV, 5, 800, function(v) S.orbDeleteFOV = v end, "pixels")
addToggle(orbPage, "Delete mode", S.orbDeleteMode, function(v)
    S.orbDeleteMode = v
    if v then cancelOrbSetup() end
end, "Highlights every saved orb inside the ring")
addAction(orbPage, "DELETE HIGHLIGHTED ORBS", function()
    for data in pairs(OrbSystem.selected) do deleteOrb(data) end
    OrbSystem.selected = {}
end, COLORS.danger)

addSection(targetPage, "Selection rules")
addNumber(targetPage, "Target FOV radius", S.aimlockFOV, 10, 800,
    function(v) S.aimlockFOV = v end, "pixels")
addNumber(targetPage, "Target range", S.aimlockRange, 50, 5000,
    function(v) S.aimlockRange = v end, "studs")
addToggle(targetPage, "Nearest target in FOV", S.targetBasedOffDistance, function(v)
    S.targetBasedOffDistance = v
    Aimlock.distanceDeadTarget = nil
    setAimlockTarget(nil)
end)
addToggle(targetPage, "Sticky target until death", S.targetDistanceSticky, function(v)
    S.targetDistanceSticky = v
    if not v then Aimlock.distanceDeadTarget = nil end
end)
addToggle(targetPage, "Team check", S.aimlockTeamCheck, function(v) S.aimlockTeamCheck = v end)
addToggle(targetPage, "Smart team check", S.aimlockSmartTeamCheck, function(v)
    S.aimlockSmartTeamCheck = v
    smartTeamLastScan = 0
    if v then rebuildSmartTeams() end
end)
addToggle(targetPage, "Friend check", S.aimlockFriendCheck, function(v) S.aimlockFriendCheck = v end)
addToggle(targetPage, "Wall check", S.aimlockWallCheck, function(v) S.aimlockWallCheck = v end)
addToggle(targetPage, "Ignore transparent walls", S.aimlockIgnoreTransparentWalls,
    function(v) S.aimlockIgnoreTransparentWalls = v end)
addNumber(targetPage, "Transparency threshold", S.aimlockTransparencyThreshold, 0, 1,
    function(v) S.aimlockTransparencyThreshold = v end, "0 - 1")
addToggle(targetPage, "Check CanCollide walls", S.aimlockCanCollideWallCheck,
    function(v) S.aimlockCanCollideWallCheck = v end)
addTextInput(targetPage, "Aim part", S.aimlockPart, function(v)
    if v ~= "" then S.aimlockPart = v end
end, "Head")
addToggle(targetPage, "Switch targets", S.switchTargetsEnabled, function(v)
    S.switchTargetsEnabled = v
end)

addSection(behaviourPage, "Lock mode")
addToggle(behaviourPage, "Sticky lock", S.aimlockStickyLock, function(v) S.aimlockStickyLock = v end)
addToggle(behaviourPage, "Hold-to-aim", S.aimlockHoldToAim, function(v) S.aimlockHoldToAim = v end)
addToggle(behaviourPage, "Cursor mode", S.aimlockCursorMode, function(v) S.aimlockCursorMode = v end)
addNumber(behaviourPage, "Reacquire delay", S.aimlockReacquireDelay, 0, 3,
    function(v) S.aimlockReacquireDelay = v end, "seconds")
addNumber(behaviourPage, "Smoothing", math.floor(S.aimlockSmoothing * 20 + 0.5), 1, 20,
    function(v) S.aimlockSmoothing = v / 20 end, "1 - 20")
addNumber(behaviourPage, "Max degrees per frame", S.aimlockMaxDegPerFrame, 0, 45,
    function(v) S.aimlockMaxDegPerFrame = v end, "degrees")
addNumber(behaviourPage, "Humanizer", S.aimlockHumanize, 0, 40,
    function(v) S.aimlockHumanize = v end, "pixels")
addNumber(behaviourPage, "Miss chance", S.aimlockMissChance, 0, 40,
    function(v) S.aimlockMissChance = v end, "percent")
addToggle(behaviourPage, "Enable switch targets", S.switchTargetsEnabled, function(v)
    S.switchTargetsEnabled = v
end)
addToggle(behaviourPage, "Target players", S.targetPlayers, function(v)
    S.targetPlayers = v
    refreshModeButtons()
end)
addToggle(behaviourPage, "Target NPCs", S.targetNPCs, function(v)
    S.targetNPCs = v
    refreshModeButtons()
end)

addSection(visualPage, "NPC visual telemetry")
addToggle(visualPage, "NPC boxes", S.espEnabled, function(v)
    S.espEnabled = v
    if not v then clearAllESPBoxes() end
end)
addToggle(visualPage, "Name tags", S.espNameTag, function(v) S.espNameTag = v end)
addToggle(visualPage, "Health bar", S.espHealthBar, function(v) S.espHealthBar = v end)
addToggle(visualPage, "Show Health", S.espShowHealth, function(v)
    S.espShowHealth = v
    if v then S.espEnabled = true end
end,
    "Circle beside the box plus torso health text")
addNumber(visualPage, "NPC display distance", S.espDistance, 50, 2000,
    function(v) S.espDistance = v end, "studs")
addNumber(visualPage, "NPC box size", S.espBoxSize, 8, 120, function(v)
    S.espBoxSize = v
    clearAllESPBoxes()
end, "pixels")
addNumber(visualPage, "Box red", S.espBoxColorR, 0, 255,
    function(v) S.espBoxColorR = v end, "0 - 255")
addNumber(visualPage, "Box green", S.espBoxColorG, 0, 255,
    function(v) S.espBoxColorG = v end, "0 - 255")
addNumber(visualPage, "Box blue", S.espBoxColorB, 0, 255,
    function(v) S.espBoxColorB = v end, "0 - 255")
addNumber(visualPage, "Health display distance", S.espHealthDisplayDistance, 10, 5000,
    function(v) S.espHealthDisplayDistance = v end, "studs")
addSection(visualPage, "Crosshair")
addToggle(visualPage, "Show FOV ring", S.aimlockShowFOV, function(v)
    S.aimlockShowFOV = v
    if Aimlock.fovCircle then Aimlock.fovCircle.Visible = v end
end)
addNumber(visualPage, "FOV ring size", S.aimlockFOVRingSize, 1, 350, function(v)
    S.aimlockFOVRingSize = v
    if Aimlock.fovCircle then
        Aimlock.fovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    end
end, "pixels")
addNumber(visualPage, "FOV red", S.aimlockFOVColorR, 0, 255, function(v)
    S.aimlockFOVColorR = v
    if Aimlock.fovStroke then
        Aimlock.fovStroke.Color = Color3.fromRGB(v, S.aimlockFOVColorG, S.aimlockFOVColorB)
    end
end, "0 - 255")
addNumber(visualPage, "FOV green", S.aimlockFOVColorG, 0, 255, function(v)
    S.aimlockFOVColorG = v
    if Aimlock.fovStroke then
        Aimlock.fovStroke.Color = Color3.fromRGB(S.aimlockFOVColorR, v, S.aimlockFOVColorB)
    end
end, "0 - 255")
addNumber(visualPage, "FOV blue", S.aimlockFOVColorB, 0, 255, function(v)
    S.aimlockFOVColorB = v
    if Aimlock.fovStroke then
        Aimlock.fovStroke.Color = Color3.fromRGB(S.aimlockFOVColorR, S.aimlockFOVColorG, v)
    end
end, "0 - 255")
addToggle(visualPage, "Cross-shaped crosshair", S.aimlockCrosshairShape == "cross", function(v)
    S.aimlockCrosshairShape = v and "cross" or "dot"
    syncCrosshairShape()
end)
addNumber(visualPage, "Crosshair X", S.aimlockCrosshairPos.X.Scale, 0, 1,
    function(v)
        S.aimlockCrosshairPos = UDim2.new(v, 0,
            S.aimlockCrosshairPos.Y.Scale, S.aimlockCrosshairPos.Y.Offset)
    end, "0 - 1")
addNumber(visualPage, "Crosshair Y", S.aimlockCrosshairPos.Y.Scale, 0, 1,
    function(v)
        S.aimlockCrosshairPos = UDim2.new(S.aimlockCrosshairPos.X.Scale,
            S.aimlockCrosshairPos.X.Offset, v, 0)
    end, "0 - 1")
addNumber(visualPage, "Crosshair move speed", S.aimlockCrosshairMoveSpeed, 1, 2000,
    function(v) S.aimlockCrosshairMoveSpeed = v end, "pixels/s")
addNumber(visualPage, "Crosshair opacity", S.aimlockCrosshairOpacity, 0, 1,
    function(v)
        S.aimlockCrosshairOpacity = v
        if Aimlock.crosshairDot then Aimlock.crosshairDot.BackgroundTransparency = v end
        if Aimlock.crosshairImage then Aimlock.crosshairImage.ImageTransparency = v end
    end, "0 - 1")
addTextInput(visualPage, "Crosshair image ID", S.aimlockCrosshairImage, function(v)
    S.aimlockCrosshairImage = v
    if Aimlock.crosshairImage then
        Aimlock.crosshairImage.Image = v ~= "" and v or ""
    end
end, "rbxassetid://...")
addAction(visualPage, "EDIT CROSSHAIR POSITION", enterCrosshairEditMode, COLORS.accentDark)

addSection(rotationPage, "Target part rotation")
makeRotationEditor(rotationPage, "Player Target Part Rotation", "playerTP",
    "playerTPEnabled", "playerTPRate", "playerTPUnit", "playerTPMiss")
makeRotationEditor(rotationPage, "NPC Target Part Rotation", "npcTP",
    "npcTPEnabled", "npcTPRate", "npcTPUnit", "npcTPMiss")
addSection(rotationPage, "Sitting profiles")
makeRotationEditor(rotationPage, "Player Sitting Rotation", "playerSitTP",
    "playerSitTPEnabled", "playerSitTPRate", "playerSitTPUnit", "playerSitTPMiss")
makeRotationEditor(rotationPage, "NPC Sitting Rotation", "npcSitTP",
    "npcSitTPEnabled", "npcSitTPRate", "npcSitTPUnit", "npcSitTPMiss")
addToggle(rotationPage, "Sit rotation part — players", S.playerSitRotation, function(v)
    S.playerSitRotation = v
end, "Uses HumanoidRootPart while the target is sitting")
addToggle(rotationPage, "Sit rotation part — NPCs", S.npcSitRotation, function(v)
    S.npcSitRotation = v
end, "Same seated reference for NPC humanoids")
addSection(rotationPage, "Prediction")
addToggle(rotationPage, "Smart prediction", S.aimlockSmartAI, function(v) S.aimlockSmartAI = v end)
addToggle(rotationPage, "Acceleration prediction", S.aimlockPredictAccel, function(v)
    S.aimlockPredictAccel = v
end)
addNumber(rotationPage, "Prediction strength", math.floor(S.aimlockPredictStrength * 10 + 0.5), 0, 10,
    function(v) S.aimlockPredictStrength = v / 10 end, "0 - 10")
addNumber(rotationPage, "Smoothing", S.aimlockSmoothing, 0.05, 1,
    function(v) S.aimlockSmoothing = v end, "0.05 - 1")

local function playerListOptions()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(names, player.Name) end
    end
    table.sort(names)
    return names
end

local function teamListOptions()
    local names, seen = {}, {}
    for _, team in ipairs(Teams:GetTeams()) do
        if not seen[team.Name] then
            seen[team.Name] = true
            table.insert(names, team.Name)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Team and not seen[player.Team.Name] then
            seen[player.Team.Name] = true
            table.insert(names, player.Team.Name)
        end
    end
    table.sort(names)
    return names
end

addSection(lockPage, "Priority targets")
addToggle(lockPage, "Enable lock list", S.targetLockEnabled,
    function(v) S.targetLockEnabled = v end,
    "Priority players bypass the friend check")
addMultiList(lockPage, "Lock list", playerListOptions,
    function() return S.targetLockList end,
    function(value) S.targetLockList = value end)
addSection(lockPage, "Ignore rules")
addMultiList(lockPage, "Ignore list", playerListOptions,
    function() return S.ignoreList end,
    function(value) S.ignoreList = value end)
addMultiList(lockPage, "Ignored teams", teamListOptions,
    function() return S.aimlockIgnoreTeams end,
    function(value) S.aimlockIgnoreTeams = value end)

addSection(keybindPage, "Keyboard controls")
addKeybind(keybindPage, "Aimlock", S.aimlockKey, function(v) S.aimlockKey = v end)
addKeybind(keybindPage, "Open / close panel", S.panelKey, function(v) S.panelKey = v end)
addKeybind(keybindPage, "Orb setup", S.orbSetupKey, function(v) S.orbSetupKey = v end)
addKeybind(keybindPage, "Spawn orb", S.orbSpawnKey, function(v) S.orbSpawnKey = v end)
addKeybind(keybindPage, "Undo preview orb", S.orbUndoKey, function(v) S.orbUndoKey = v end)
addKeybind(keybindPage, "Set preview orbs", S.orbSetKey, function(v) S.orbSetKey = v end)
addKeybind(keybindPage, "Cancel orb setup", S.orbCancelKey, function(v) S.orbCancelKey = v end)
addKeybind(keybindPage, "Delete mode", S.orbDeleteModeKey,
    function(v) S.orbDeleteModeKey = v end)
addKeybind(keybindPage, "Float forward", S.orbForwardKey,
    function(v) S.orbForwardKey = v end)
addKeybind(keybindPage, "Float backward", S.orbBackwardKey,
    function(v) S.orbBackwardKey = v end)
addKeybind(keybindPage, "Switch target left", S.switchLeftKey,
    function(v) S.switchLeftKey = v end)
addKeybind(keybindPage, "Switch target right", S.switchRightKey,
    function(v) S.switchRightKey = v end)
local keyHintCard = addCard(keybindPage, 62)
local keyHint = makeLabel(keyHintCard,
    "Mobile users can use the D button and on-screen controls instead of keyboard shortcuts.",
    UDim2.new(1, -28, 1, 0), COLORS.muted, Enum.Font.Gotham)
keyHint.Position = UDim2.new(0, 14, 0, 0)
keyHint.TextSize = 10
keyHint.TextWrapped = true

addSection(configPage, "Interface")
addAction(configPage, "EDIT FLOATING BUTTON LAYOUT", enterEditMode, COLORS.accentDark)
addAction(configPage, "RESET FLOATING BUTTONS", function()
    for _, entry in ipairs(buttonRegistry) do
        entry.obj.frame.Position = D[entry.sKey]
        S[entry.sKey] = D[entry.sKey]
    end
end, COLORS.warning)
addAction(configPage, "RESET D BUTTON POSITION", function()
    dButton.Position = UDim2.new(0, 34, 0.5, 0)
end, COLORS.warning)
addAction(configPage, "HIDE CONTROL CENTER", function() window.Visible = false end)
local hintCard = addCard(configPage, 58)
local hintText = makeLabel(hintCard, "UI scale: 50% PC / 60% mobile.  Resize the viewport to recalculate.",
    UDim2.new(1, -28, 1, 0), COLORS.muted, Enum.Font.Gotham)
hintText.Position = UDim2.new(0, 14, 0, 0)
hintText.TextSize = 11
hintText.TextWrapped = true

-- ── Orb delete ring + highlight pass ─────────────────────────
local deleteRing = Instance.new("Frame")
deleteRing.Name = "OrbDeleteFOV"
deleteRing.AnchorPoint = Vector2.new(0.5, 0.5)
deleteRing.Position = S.aimlockCrosshairPos
deleteRing.Size = UDim2.new(0, S.orbDeleteFOV * 2, 0, S.orbDeleteFOV * 2)
deleteRing.BackgroundTransparency = 1
deleteRing.BorderSizePixel = 0
deleteRing.Visible = false
deleteRing.ZIndex = 4
deleteRing.Parent = SG
addCorner(deleteRing, 100)
local deleteStroke = addStroke(deleteRing, COLORS.warning, 2, 0.08)
OrbSystem.deleteRing = deleteRing

local function updateOrbDeleteVisuals()
    local center = crosshairScreenPos()
    local radius = math.clamp(tonumber(S.orbDeleteFOV) or 120, 5, 800)
    deleteRing.Position = UDim2.new(
        S.aimlockCrosshairPos.X.Scale, S.aimlockCrosshairPos.X.Offset,
        S.aimlockCrosshairPos.Y.Scale, S.aimlockCrosshairPos.Y.Offset)
    deleteRing.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    deleteRing.Visible = S.orbDeleteMode == true
    deleteStroke.Color = S.orbDeleteMode and COLORS.warning or COLORS.border
    OrbSystem.selected = {}

    for _, data in ipairs(OrbSystem.saved) do
        local part = data.part
        if part and part.Parent then
            if not data.highlight then
                local selection = Instance.new("SelectionBox")
                selection.Name = "OrbDeleteHighlight"
                selection.LineThickness = 0.06
                selection.SurfaceTransparency = 1
                selection.Adornee = part
                selection.Visible = false
                selection.Parent = OrbSystem.folder
                data.highlight = selection
            end
            local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
            local dx, dy = screen.X - center.X, screen.Y - center.Y
            local inside = S.orbDeleteMode and onScreen and screen.Z > 0
                and dx * dx + dy * dy <= radius * radius
            data.highlight.Visible = inside
            data.highlight.Color3 = data.state == "Respawning"
                and COLORS.warning or COLORS.accent
            if inside then OrbSystem.selected[data] = true end
        end
    end
end

local orbVisualAccum = 0
RunService.Heartbeat:Connect(function(dt)
    updateOrbs(dt)
    refreshOrbQuickBar()
    orbVisualAccum = orbVisualAccum + dt
    if orbVisualAccum >= 0.1 then
        orbVisualAccum = 0
        updateOrbDeleteVisuals()
    end
    if Aimlock.target and targetState then
        targetState.Text = "Locked: " .. tostring(Aimlock.target.Name)
        targetState.TextColor3 = COLORS.good
    elseif targetState then
        targetState.Text = "No target selected"
        targetState.TextColor3 = COLORS.muted
    end
    if orbCountState then
        orbCountState.Text = tostring(#OrbSystem.saved) .. " saved orb marks"
    end
    local on = S.aimlockEnabled == true
    statusDot.BackgroundColor3 = on and COLORS.good or COLORS.danger
    statusText.Text = on and "ON" or "OFF"
    statusText.TextColor3 = on and COLORS.good or COLORS.muted
end)

-- Window dragging uses one input connection and does not run per frame.
do
    local dragInput, dragStart, startPosition
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
            dragStart = input.Position
            startPosition = window.Position
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input ~= dragInput or not dragStart or not startPosition then return end
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput, dragStart, startPosition = nil, nil, nil
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode
    if key == S.panelKey then
        window.Visible = not window.Visible
    elseif key == S.orbSetupKey then
        beginOrbSetup()
    elseif key == S.orbSpawnKey then
        if not OrbSystem.setupActive then beginOrbSetup() end
        createPreviewOrb()
    elseif key == S.orbUndoKey then
        undoPreviewOrb()
    elseif key == S.orbSetKey then
        setPreviewOrbs()
    elseif key == S.orbCancelKey then
        cancelOrbSetup()
    elseif key == S.orbDeleteModeKey then
        S.orbDeleteMode = not S.orbDeleteMode
        if S.orbDeleteMode then cancelOrbSetup() end
    elseif key == S.orbForwardKey then
        OrbSystem.forwardHeld = true
    elseif key == S.orbBackwardKey then
        OrbSystem.backwardHeld = true
    elseif key == S.switchLeftKey and S.switchTargetsEnabled then
        switchTarget(-1)
    elseif key == S.switchRightKey and S.switchTargetsEnabled then
        switchTarget(1)
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == S.orbForwardKey then OrbSystem.forwardHeld = false end
    if input.KeyCode == S.orbBackwardKey then OrbSystem.backwardHeld = false end
end)

-- Start on the control page.  The panel is visible by default so the
-- placement workflow is discoverable immediately after the script loads.
(function()
    for _, entry in pairs(pages) do entry.page.Visible = false end
end)()
pages.Control.page.Visible = true
navButtons.Control.BackgroundColor3 = COLORS.accentDark
navButtons.Control.TextColor3 = COLORS.text
activePage = "Control"
if _G.__FlyScript_UpdateAimlockBtn then pcall(_G.__FlyScript_UpdateAimlockBtn) end
