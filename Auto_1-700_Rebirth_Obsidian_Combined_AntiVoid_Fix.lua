--// OBSIDIAN - AUTO 1-700 REBIRTH
--// ONE TOGGLE
--// PLACE 3177438863 -> Bandit/Rebirth/Upgrade/Brawly -> Crimson
--// PLACE 7040546583 -> Calci Army + LockOn/Skill101 + Rebirth
--// If the game changes PlaceId, the same toggle continues automatically.

local Obsidian = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"
))()

local Window = Obsidian:CreateWindow({
    Title = "Auto 1-700 Rebirth",
    Footer = "Combined Farm",
    Center = true,
    AutoShow = true
})

local Tab = Window:AddTab("Farm", "home")
local Box = Tab:AddLeftGroupbox("Auto Farm")

_G.Auto1_700 = false
local MainThread = nil
local ResetThread = nil

local RESET_INTERVAL = 20 * 60 -- 20 phút

-- Anti-void: nhớ vị trí hợp lệ gần nhất để cứu nhân vật nếu tween
-- bị physics/target lỗi kéo xuống dưới map.
local SafeCFrame = nil
local AntiVoidThread = nil
local VOID_Y = -100

local function GetSafeRoot()
    local character = game.Players.LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function StartAntiVoid()
    if AntiVoidThread then return end

    AntiVoidThread = task.spawn(function()
        while _G.Auto1_700 do
            local root = GetSafeRoot()

            if root then
                local pos = root.Position
                local velocity = root.AssemblyLinearVelocity

                -- Chỉ lưu vị trí khi nhân vật còn ở vùng map hợp lệ.
                if pos.Y > VOID_Y
                    and pos.Y < 100000
                    and velocity.Magnitude < 1000 then
                    SafeCFrame = root.CFrame
                end

                -- Đã rơi xuống void -> dừng vận tốc và đưa về vị trí an toàn.
                if pos.Y <= VOID_Y then
                    local recovery = SafeCFrame

                    if not recovery then
                        if game.PlaceId == 7040546583 then
                            recovery = CFrame.new(Vector3.new(
                                -1028.61804, 66.1857834, -1514.43213
                            ))
                        else
                            recovery = CFrame.new(Vector3.new(
                                2034.02405, 1154.9751, -122.715225
                            ))
                        end
                    end

                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.CFrame = recovery + Vector3.new(0, 4, 0)

                    task.wait(0.2)
                end
            end

            task.wait(0.05)
        end

        AntiVoidThread = nil
    end)
end

local function StopAntiVoid()
    if AntiVoidThread then
        task.cancel(AntiVoidThread)
        AntiVoidThread = nil
    end
    SafeCFrame = nil
end

-- Chờ nhân vật sống lại sau khi chết/reset.
local function WaitForCharacter()
    if not _G.Auto1_700 then return nil end

    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health > 0 then
        return character, humanoid
    end

    character = game.Players.LocalPlayer.CharacterAdded:Wait()
    if not _G.Auto1_700 then return nil end

    humanoid = character:WaitForChild("Humanoid", 10)
    return character, humanoid
end

local function StartResetWatcher()
    if ResetThread then return end

    ResetThread = task.spawn(function()
        while _G.Auto1_700 do
            local remaining = RESET_INTERVAL

            while _G.Auto1_700 and remaining > 0 do
                local step = math.min(1, remaining)
                task.wait(step)
                remaining -= step
            end

            if not _G.Auto1_700 then break end

            local character = game.Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                print("🔄 Auto 1-700: Reset sau 20 phút")
                humanoid.Health = 0
            end

            -- Cho Roblox respawn xong rồi mới đếm 20 phút tiếp theo.
            if _G.Auto1_700 then
                task.wait(3)
            end
        end

        ResetThread = nil
    end)
end

local function StopResetWatcher()
    _G.Auto1_700 = false
    ResetThread = nil
end

--==================================================
-- COMMON
--==================================================

local function waitUntilEnabled(seconds)
    local finish = os.clock() + seconds
    while _G.Auto1_700 and os.clock() < finish do
        task.wait()
    end
    return _G.Auto1_700
end

--==================================================
-- PLACE 3177438863
--==================================================

local function RunPlace3177438863()
    if not _G.Auto1_700 then return end
    WaitForCharacter()
    if not _G.Auto1_700 then return end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local LP = Players.LocalPlayer

    local SKILL_DELAY = 0.25
    local TWEEN_SPEED = 180
    local MIN_STRENGTH = 200000
    local MIN_REBIRTH = 2
    local HIGH_STRENGTH = 60000000
    local TARGET_REBIRTH = 50

    local WAIT_POS = Vector3.new(
        2034.02405,
        1149.9751,
        -122.715225
    )

    local SkillRemote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("SkillRemote")

    local RebirthRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("PlayerLevelService")
        :WaitForChild("RF")
        :WaitForChild("RequestRebirth")

    local PromptRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("PromptService")
        :WaitForChild("RE")
        :WaitForChild("Prompt")

    local Stats = LP:WaitForChild("Stats")
    local Strength = Stats:WaitForChild("Strength")
    local Rebirth = Stats:WaitForChild("Rebirth")

    local function getRoot()
        local char = LP.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getRootPart(mob)
        return mob and (
            mob:FindFirstChild("HumanoidRootPart")
            or mob.PrimaryPart
            or mob:FindFirstChildWhichIsA("BasePart")
        )
    end

    local function getHumanoid(mob)
        return mob and mob:FindFirstChildOfClass("Humanoid")
    end

    local function findMob(name)
        local folder = workspace
            :WaitForChild("World Mobs")
            :WaitForChild("Mobs")

        for _, mob in ipairs(folder:GetChildren()) do
            if not _G.Auto1_700 then return nil end

            if mob.Name == name then
                local hum = getHumanoid(mob)
                if hum and hum.Health > 0 then
                    return mob
                end
            end
        end
        return nil
    end

    local function tweenTo(cf)
        if not _G.Auto1_700 then return false end

        local root = getRoot()
        if not root then return false end

        local distance = (root.Position - cf.Position).Magnitude
        local duration = math.max(distance / TWEEN_SPEED, 0.05)

        local tween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = cf}
        )

        tween:Play()

        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Auto1_700 then
                tween:Cancel()
                return false
            end
            task.wait()
        end

        return true
    end

    local function tweenAboveMob(mob)
        local mobRoot = getRootPart(mob)
        if not mobRoot then return false end

        -- Không tween theo mob nếu target đã nằm ngoài vùng map.
        if mobRoot.Position.Y <= VOID_Y or mobRoot.Position.Y > 100000 then
            return false
        end

        local pos = mobRoot.Position + Vector3.new(0, 8, 0)
        return tweenTo(CFrame.lookAt(pos, mobRoot.Position))
    end

    local function attackMob(mob)
        if not _G.Auto1_700 then return end

        local root = getRoot()
        local mobRoot = getRootPart(mob)
        if not root or not mobRoot then return end

        local target = mobRoot.Position
        local above = target + Vector3.new(0, 8, 0)
        local cf = CFrame.lookAt(above, target)

        root.CFrame = cf

        SkillRemote:FireServer({
            ["Camera"] = cf,
            ["SkillId"] = "1",
            ["Began"] = true,
            ["CFrame"] = cf,
            ["Typ\208\181"] = 1,
            ["Aim"] = target
        })
    end

    local function farmMob(name)
        local currentMob = nil

        while _G.Auto1_700 and game.PlaceId == 3177438863 do
            local mob = findMob(name)

            if not mob then
                return false
            end

            if currentMob ~= mob then
                currentMob = mob

                if not tweenAboveMob(mob) then
                    return false
                end
            end

            local hum = getHumanoid(mob)

            if not hum or hum.Health <= 0 then
                currentMob = nil
            else
                attackMob(mob)
                task.wait(SKILL_DELAY)
            end
        end

        return false
    end

    local function doRebirthUntil(target)
        local lastValue = Rebirth.Value
        local noChange = 0

        while _G.Auto1_700
            and game.PlaceId == 3177438863
            and Rebirth.Value < target do

            pcall(function()
                RebirthRemote:InvokeServer(true)
            end)

            task.wait(0.2)

            if Rebirth.Value == lastValue then
                noChange += 1
            else
                lastValue = Rebirth.Value
                noChange = 0
            end

            if noChange >= 10 then
                return false
            end
        end

        return Rebirth.Value >= target
    end

    local function upgrade(path)
        if not _G.Auto1_700 then return end

        PromptRemote:FireServer({
            ["Timer"] = 15,
            ["Description"] =
                "Upgrade Energy Blast>" .. path ..
                " for 1 Skill Points?",
            ["LeftButton"] = "Upgrade",
            ["PathName"] = path,
            ["Prompt"] = "UpgradeSkill",
            ["RightButton"] = "Return",
            ["SkillId"] = "101"
        }, "Upgrade")
    end

    local function upgradeOneMinute()
        local finish = os.clock() + 60

        while _G.Auto1_700
            and game.PlaceId == 3177438863
            and os.clock() < finish do

            upgrade("Path1")
            task.wait(0.5)

            upgrade("Path2")
            task.wait(0.5)
        end
    end

    local function crimson()
        if not _G.Auto1_700 then return end

        PromptRemote:FireServer({
            ["UniqueTag"] = "TeleporterGui",
            ["Description"] = "Join World [Crimson Planet]?",
            ["LeftButton"] = "Join",
            ["Timer"] = 30,
            ["Prompt"] = "TeleportDirect",
            ["RightButton"] = "Cancel",
            ["PlaceDataId"] = 2
        }, "Join")
    end

    while _G.Auto1_700 and game.PlaceId == 3177438863 do
        local str = tonumber(Strength.Value) or 0
        local reb = tonumber(Rebirth.Value) or 0

        if reb > 50 then
            crimson()
            task.wait(1)

            -- Keep the toggle ON. If the teleport changes PlaceId,
            -- the outer controller will start the Calci system.
            break

        elseif str > HIGH_STRENGTH then
            local success = doRebirthUntil(TARGET_REBIRTH)

            if success or Rebirth.Value >= TARGET_REBIRTH then
                crimson()
                task.wait(1)
                break
            end

        elseif str >= MIN_STRENGTH and reb >= MIN_REBIRTH then
            local brawly = findMob("Brawly Minion")

            if brawly then
                farmMob("Brawly Minion")
            else
                tweenTo(CFrame.new(WAIT_POS))

                while _G.Auto1_700
                    and game.PlaceId == 3177438863 do

                    brawly = findMob("Brawly Minion")
                    if brawly then break end
                    task.wait(0.25)
                end
            end

        elseif str >= MIN_STRENGTH then
            local before = Rebirth.Value
            doRebirthUntil(999999)

            if _G.Auto1_700 and Rebirth.Value == before then
                upgradeOneMinute()
            end

        else
            farmMob("Bandit")
        end

        task.wait(0.1)
    end
end

--==================================================
-- PLACE 7040546583 - CALCI ARMY
--==================================================

local function RunPlace7040546583()
    if not _G.Auto1_700 then return end
    WaitForCharacter()
    if not _G.Auto1_700 then return end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local LP = Players.LocalPlayer

    local SKILL1_DELAY = 0.25
    local LOCK_DELAY = 0.25
    local REBIRTH_DELAY = 0.25
    local TWEEN_SPEED = 180
    local LOCK_RADIUS = 200

    local WAIT_POS = Vector3.new(
        -1028.61804,
        61.1857834,
        -1514.43213
    )

    local SkillRemote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("SkillRemote")

    local LockOnRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("SkillManager")
        :WaitForChild("RE")
        :WaitForChild("LockedOnChanged")

    local RebirthRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.4.7")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("PlayerLevelService")
        :WaitForChild("RF")
        :WaitForChild("RequestRebirth")

    local function getRoot()
        local char = LP.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getMobRoot(mob)
        return mob and (
            mob:FindFirstChild("HumanoidRootPart")
            or mob.PrimaryPart
            or mob:FindFirstChildWhichIsA("BasePart")
        )
    end

    local function getHumanoid(mob)
        return mob and mob:FindFirstChildOfClass("Humanoid")
    end

    local function getCalciList()
        local folder = workspace
            :WaitForChild("World Mobs")
            :WaitForChild("Mobs")

        local result = {}

        for _, mob in ipairs(folder:GetChildren()) do
            if mob.Name == "Calci Army" then
                local hum = getHumanoid(mob)
                local root = getMobRoot(mob)

                if hum and hum.Health > 0 and root then
                    table.insert(result, mob)
                end
            end
        end

        return result
    end

    local currentTweenTarget = nil

    local function getRandomLockTarget(exclude)
        local root = getRoot()
        if not root then return nil end

        local list = {}

        for _, mob in ipairs(getCalciList()) do
            if mob ~= exclude then
                local mobRoot = getMobRoot(mob)

                if mobRoot then
                    local distance =
                        (root.Position - mobRoot.Position).Magnitude

                    if distance <= LOCK_RADIUS then
                        table.insert(list, mob)
                    end
                end
            end
        end

        if #list == 0 then return nil end
        return list[math.random(1, #list)]
    end

    local function tweenAbove(mob)
        if not _G.Auto1_700 then return false end

        local root = getRoot()
        local mobRoot = getMobRoot(mob)
        if not root or not mobRoot then return false end

        -- Tránh đuổi theo target đã bị rơi/teleport xuống void.
        if mobRoot.Position.Y <= VOID_Y or mobRoot.Position.Y > 100000 then
            return false
        end

        local position =
            mobRoot.Position + Vector3.new(0, 8, 0)

        local cf =
            CFrame.lookAt(position, mobRoot.Position)

        local distance =
            (root.Position - position).Magnitude

        local duration =
            math.max(distance / TWEEN_SPEED, 0.05)

        local tween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = cf}
        )

        tween:Play()

        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Auto1_700
                or game.PlaceId ~= 7040546583 then

                tween:Cancel()
                return false
            end
            task.wait()
        end

        return true
    end

    local function tweenWait()
        if not _G.Auto1_700 then return end

        local root = getRoot()
        if not root then return end

        local distance =
            (root.Position - WAIT_POS).Magnitude

        local duration =
            math.max(distance / TWEEN_SPEED, 0.05)

        local tween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(WAIT_POS)}
        )

        tween:Play()

        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Auto1_700
                or game.PlaceId ~= 7040546583 then

                tween:Cancel()
                return
            end
            task.wait()
        end
    end

    local function skill1(mob)
        if not _G.Auto1_700 then return end

        local root = getRoot()
        local mobRoot = getMobRoot(mob)
        if not root or not mobRoot then return end

        local target = mobRoot.Position
        local above = target + Vector3.new(0, 8, 0)
        local cf = CFrame.lookAt(above, target)

        root.CFrame = cf

        SkillRemote:FireServer({
            ["Camera"] = cf,
            ["SkillId"] = "1",
            ["Began"] = true,
            ["CFrame"] = cf,
            ["Typ\208\181"] = 1,
            ["Aim"] = target
        })
    end

    local function lockSkill101(mob)
        if not _G.Auto1_700 then return end

        local mobRoot = getMobRoot(mob)
        local root = getRoot()

        if not mobRoot or not root then return end

        local target = mobRoot.Position
        local above = target + Vector3.new(0, 8, 0)
        local cf = CFrame.lookAt(above, target)

        LockOnRemote:FireServer(mob)

        SkillRemote:FireServer({
            ["Camera"] = cf,
            ["SkillId"] = "101",
            ["Began"] = true,
            ["CFrame"] = cf,
            ["Typ\208\181"] = 1,
            ["Aim"] = target
        })
    end

    -- One controller thread runs all three Calci systems.
    local calciRunning = true

    task.spawn(function()
        while _G.Auto1_700
            and calciRunning
            and game.PlaceId == 7040546583 do

            local list = getCalciList()

            if #list == 0 then
                currentTweenTarget = nil
                tweenWait()
                task.wait(0.1)
            else
                if not currentTweenTarget
                    or not getHumanoid(currentTweenTarget)
                    or getHumanoid(currentTweenTarget).Health <= 0
                    or not getMobRoot(currentTweenTarget) then

                    currentTweenTarget =
                        list[math.random(1, #list)]

                    if not tweenAbove(currentTweenTarget) then
                        break
                    end
                end

                if currentTweenTarget then
                    local hum = getHumanoid(currentTweenTarget)

                    if hum and hum.Health > 0 then
                        skill1(currentTweenTarget)
                    else
                        currentTweenTarget = nil
                    end
                end

                task.wait(SKILL1_DELAY)
            end
        end
    end)

    task.spawn(function()
        while _G.Auto1_700
            and calciRunning
            and game.PlaceId == 7040546583 do

            local target =
                getRandomLockTarget(currentTweenTarget)

            if target then
                pcall(function()
                    lockSkill101(target)
                end)
            end

            task.wait(LOCK_DELAY)
        end
    end)

    task.spawn(function()
        while _G.Auto1_700
            and calciRunning
            and game.PlaceId == 7040546583 do

            pcall(function()
                RebirthRemote:InvokeServer(true)
            end)

            task.wait(REBIRTH_DELAY)
        end
    end)

    -- Wait while Calci is the active PlaceId.
    while _G.Auto1_700
        and game.PlaceId == 7040546583 do
        task.wait(0.25)
    end

    calciRunning = false
end

--==================================================
-- ONE MAIN CONTROLLER
--==================================================

local function StartAuto1700()
    if MainThread then return end

    _G.Auto1_700 = true
    StartAntiVoid()

    MainThread = task.spawn(function()
        while _G.Auto1_700 do

            -- Nếu vừa chết/reset thì đợi character mới rồi farm tiếp.
            if not WaitForCharacter() then
                break
            end

            local place = game.PlaceId

            if place == 3177438863 then
                RunPlace3177438863()

            elseif place == 7040546583 then
                RunPlace7040546583()

            else
                warn("❌ Auto 1-700: PlaceId không được hỗ trợ:", place)
                task.wait(1)
            end

            task.wait(0.25)
        end

        MainThread = nil
    end)
end

local function StopAuto1700()
    _G.Auto1_700 = false
    StopAntiVoid()

    if ResetThread then
        task.cancel(ResetThread)
        ResetThread = nil
    end
    print("🛑 Auto 1-700 Rebirth OFF")
end

--==================================================
-- ONE TOGGLE ONLY
--==================================================

Box:AddToggle("Auto1700", {
    Text = "Auto 1-700 Rebirth",
    Default = false,

    Callback = function(Value)
        if Value then
            StartAuto1700()
            StartResetWatcher()
            print("✅ Auto 1-700 Rebirth ON | Reset mỗi 20 phút")
        else
            StopAuto1700()
        end
    end
})

Obsidian:Notify({
    Title = "Auto 1-700 Rebirth",
    Description = "Đã load - chỉ có 1 nút ON/OFF",
    Time = 3
})
--// ANTI FALL - OBSIDIAN
--// Toggle ON/OFF | Default ON

--==================================================
-- ANTI FALL
--==================================================

local RunService = game:GetService("RunService")
local AntiFall = true
local AntiFallConnection = nil

local function StartAntiFall()
    if AntiFallConnection then return end

    AntiFallConnection = RunService.Heartbeat:Connect(function()
        if not AntiFall then return end

        local Character = game.Players.LocalPlayer.Character
        if not Character then return end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end

        local Velocity = Root.AssemblyLinearVelocity

        if Velocity.Y < 0 then
            Root.AssemblyLinearVelocity = Vector3.new(
                Velocity.X,
                0,
                Velocity.Z
            )
        end
    end)
end

local function StopAntiFall()
    if AntiFallConnection then
        AntiFallConnection:Disconnect()
        AntiFallConnection = nil
    end
end

--==================================================
-- ANTI FALL TOGGLE
--==================================================

Box:AddToggle("AntiFall", {
    Text = "Anti Fall",
    Default = true,

    Callback = function(Value)
        AntiFall = Value

        if Value then
            StartAntiFall()
        else
            StopAntiFall()
        end
    end
})

-- Bật sẵn
StartAntiFall()
--==================================================
-- AUTO TOOLBAR SELECTION
--==================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("ToolService")
    :WaitForChild("RE")
    :WaitForChild("UpdatePlayerToolbarSelection")

local SelectedNumber = 1
local AutoToolbar = false
local ToolbarThread = nil

local function StartToolbar()
    if ToolbarThread then return end

    ToolbarThread = task.spawn(function()
        while AutoToolbar do
            ToolRemote:FireServer(SelectedNumber)
            task.wait(0.1)
        end

        ToolbarThread = nil
    end)
end

local function StopToolbar()
    AutoToolbar = false
    ToolbarThread = nil
end

Box:AddDropdown("ToolbarNumber", {
    Values = {"1", "2", "3", "4", "5", "6"},
    Default = "1",
    Multi = false,
    Text = "Select Number",

    Callback = function(Value)
        SelectedNumber = tonumber(Value)

        -- Chọn số là tự động kích hoạt
        AutoToolbar = true
        StartToolbar()
    end
})
local BasicBox = Tab:AddRightGroupbox("Basic")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local BasicEnabled = false
local BasicThread = nil

--==================================================
-- BASIC SKILL ARGS
--==================================================

local args = {
    [1] = {
        ["Camera"] = CFrame.new(
            1397.9259033203125,
            600.5099487304688,
            -2905.99951171875,
            -1.1920927533992653e-07,
            0.258819043636322,
            -0.965925931930542,
            0,
            0.965925931930542,
            0.258819043636322,
            1,
            3.085363076138492e-08,
            -1.1514732989326149e-07
        ),

        ["SkillId"] = "10",
        ["Began"] = true,

        ["CFrame"] = CFrame.new(
            1410,
            595.57470703125,
            -2905.99951171875,
            -1.1920927533992653e-07,
            0,
            -1,
            0,
            1,
            0,
            1,
            0,
            -1.1920927533992653e-07
        ),

        ["Typ\208\181"] = 1,

        ["Aim"] = Vector3.new(
            1460,
            595.57470703125,
            -2905.99951171875
        )
    }
}

--==================================================
-- CHECK MODE
--==================================================

local function HasMode()
    local Characters = workspace:FindFirstChild("Characters")
    local Character = Characters
        and Characters:FindFirstChild(LocalPlayer.Name)

    if not Character then
        return false
    end

    return Character:FindFirstChild("Mode") ~= nil
end

--==================================================
-- START BASIC
--==================================================

local function StartBasic()

    if BasicThread then
        return
    end

    BasicThread = task.spawn(function()

        while BasicEnabled do

            if not HasMode() then
                SkillRemote:FireServer(unpack(args))
            end

            task.wait(0.1)
        end

        BasicThread = nil
    end)
end

--==================================================
-- STOP BASIC
--==================================================

local function StopBasic()

    BasicEnabled = false

end

--==================================================
-- BASIC TOGGLE
--==================================================

BasicBox:AddToggle("Basic", {
    Text = "auto transform",
    Default = true,

    Callback = function(Value)

        BasicEnabled = Value

        if Value then
            StartBasic()
        else
            StopBasic()
        end

    end
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local Running = false

--// Skill 9
local function UseSkill9()
    local args = {
        [1] = {
            ["Camera"] = CFrame.new(
                1362.0875244140625,
                601.2300415039062,
                -2982.91015625,
                0.8348132967948914,
                -0.18300960958004,
                0.5192247629165649,
                0,
                0.9431307319160461,
                0.332422465085984,
                -0.55053323507309,
                -0.277510702610016,
                0.7873380184173584
            ),

            ["SkillId"] = "9",
            ["Toggle"] = true,
            ["Began"] = true,

            ["CFrame"] = CFrame.new(
                1355.59716796875,
                595.374755859375,
                -2992.751953125,
                -0.192925050854683,
                -1.74180647682931e-09,
                -0.981213510036469,
                -2.9545856872204e-09,
                1,
                -1.19422827182802e-09,
                0.981213510036468,
                2.66868283027577e-09,
                -0.192925050854683
            ),

            ["Typ\208\181"] = 1,

            ["Aim"] = Vector3.new(
                1404.6578369140625,
                595.374755859375,
                -2983.105712890625
            )
        }
    }

    SkillRemote:FireServer(unpack(args))
end

--// ON / OFF
BasicBox:AddToggle("Basic", {
    Text = "Auto fusion",
    Default = false,

    Callback = function(Value)
        Running = Value

        if Value then
            task.spawn(function()
                while Running do
                    UseSkill9()

                    --// 9 giây / lần
                    task.wait(9)
                end
            end)
        end
    end
})

Library:Toggle(true)
--// BOX PHẢI
--// Auto Skill 8
--// Có TechniqueEffect = không kích hoạt
--// Không có TechniqueEffect = kích hoạt

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local SkillRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("SkillRemote")

local AutoSkill8 = false

local function GetCharacter()
    local Characters = workspace:FindFirstChild("Characters")
    if not Characters then
        return nil
    end

    return Characters:FindFirstChild(LocalPlayer.Name)
end

local function ActivateSkill()
    local Character = GetCharacter()
    if not Character then
        return
    end

    -- Có TechniqueEffect thì KHÔNG kích hoạt
    if Character:FindFirstChild("TechniqueEffect") then
        return
    end

    local args = {
        [1] = {
            ["Camera"] = CFrame.new(
                1357.5260009765625,
                601.8997192382812,
                -2944.33154296875,
                -0.27307000756263733,
                -0.37132728099823,
                0.887439489364624,
                0,
                0.9224998950958252,
                0.3859974145889282,
                -0.9619942307472229,
                0.1054043173789978,
                -0.25190702080726624
            ),

            ["SkillId"] = "8",
            ["Began"] = true,

            ["CFrame"] = CFrame.new(
                1346.4329833984375,
                595.374755859375,
                -2941.1826171875,
                0.177979975938797,
                -5.2889873813910526e-08,
                -0.9840341210365295,
                7.853634187426906e-09,
                1,
                -5.2327543187402625e-08,
                0.9840341210365295,
                1.5850102341730121,
                0.177979975938797
            ),

            ["Typ\208\181"] = 1,

            ["Aim"] = Vector3.new(
                1395.6346435546875,
                595.374755859375,
                -2950.08154296875
            )
        }
    }

    SkillRemote:FireServer(unpack(args))
end


--// THÊM NÚT VÀO BOX PHẢI
BasicBox:AddToggle("Basic", {
    Text = "Auto beast [work all kaioken]",
    Default = false,

    Callback = function(Value)
        AutoSkill8 = Value
    end
})


--// LOOP
task.spawn(function()
    while task.wait(0.1) do
        if AutoSkill8 then
            ActivateSkill()
        end
    end
end)
