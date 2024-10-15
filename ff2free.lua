if getgenv().bleach then warn("Bleachhack is already executed") return end
getgenv().bleach = true


local debris = game:GetService("Debris")
local contentProvider = game:GetService("ContentProvider")
local scriptContext = game:GetService("ScriptContext")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local statsService = game:GetService("Stats")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local values = replicatedStorage:FindFirstChild("Values")

local IS_PRACTICE = game.PlaceId == 8206123457
local IS_SOLARA = string.match(getexecutorname(), "Solara")
local AC_BYPASS = false

if not values or IS_PRACTICE then
	if replicatedStorage:FindFirstChild("Values") then
		replicatedStorage:FindFirstChild("Values"):Destroy()
	end
	values = Instance.new("Folder")
	local status = Instance.new("StringValue")
	status.Name = "Status"
	status.Value = "InPlay"
	status.Parent = values
	values.Parent = replicatedStorage
	values.Name = "Values"
end

loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

if not LPH_OBFUSCATED then
    getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
  end
  

  local ReplicatedStorage = game:GetService("ReplicatedStorage")
  

  local Handshake = ReplicatedStorage.Remotes.CharacterSoundEvent
  local Hooks = {}
  local HandshakeInts = {}
  
  LPH_NO_VIRTUALIZE(function()
    for i, v in getgc() do
        if typeof(v) == "function" and islclosure(v) then
            if (#getprotos(v) == 1) and table.find(getconstants(getproto(v, 1)), 4000001) then
                hookfunction(v, function() end)
            end
        end
    end
  end)()
  
  Hooks.__namecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
  
    if not checkcaller() and (self == Handshake) and (Method == "fireServer") and (string.find(Args[1], "AC")) then
        if (#HandshakeInts == 0) then
            HandshakeInts = {table.unpack(Args[2], 2, 18)}
        else
            for i, v in HandshakeInts do
                Args[2][i + 1] = v
            end
        end
    end
  
    return Hooks.__namecall(self, ...)
  end))
  
  task.wait(1)

if not isfolder("bleachhack") then
	makefolder("bleachhack")
end

local ping = 0
local fps = 0

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/devdoroz/bleachhack-ui-lib/main/zpublictracking.lua"))()
local UI = Lib:Create()

local configSavingUI = game:GetObjects("rbxassetid://18187656247")[1]:Clone()
configSavingUI.Parent = (gethui and gethui()) or game:GetService("CoreGui")
configSavingUI.Enabled = false

local Catching = UI:CreateCategory("Catching", "")
local Player = UI:CreateCategory("Player", "")
local Configs = UI:CreateCategory("Configs", "")

function getPing()
	return statsService.PerformanceStats.Ping:GetValue()
end

function getServerPing()
	return statsService.Network.ServerStatsItem['Data Ping']:GetValue()
end

function findClosestBall()
	local lowestDistance = math.huge
	local nearestBall = nil

	local character = player.Character

	for index, ball in pairs(workspace:GetChildren()) do
		if ball.Name ~= "Football" then continue end
		if not ball:IsA("BasePart") then continue end
		if not character:FindFirstChild("HumanoidRootPart") then continue end
		local distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude

		if distance < lowestDistance then
			nearestBall = ball
			lowestDistance = distance
		end
	end

	return nearestBall
end

function beamProjectile(g, v0, x0, t1)
	local c = 0.5*0.5*0.5;
	local p3 = 0.5*g*t1*t1 + v0*t1 + x0;
	local p2 = p3 - (g*t1*t1 + v0*t1)/3;
	local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2;

	local curve0 = (p1 - x0).magnitude;
	local curve1 = (p2 - p3).magnitude;

	local b = (x0 - p3).unit;
	local r1 = (p1 - x0).unit;
	local u1 = r1:Cross(b).unit;
	local r2 = (p2 - p3).unit;
	local u2 = r2:Cross(b).unit;
	b = u1:Cross(r1).unit;

	local cf1 = CFrame.new(
		x0.x, x0.y, x0.z,
		r1.x, u1.x, b.x,
		r1.y, u1.y, b.y,
		r1.z, u1.z, b.z
	)

	local cf2 = CFrame.new(
		p3.x, p3.y, p3.z,
		r2.x, u2.x, b.x,
		r2.y, u2.y, b.y,
		r2.z, u2.z, b.z
	)

	return curve0, -curve1, cf1, cf2;
end

function getNearestPartToPartFromParts(part, parts)
	local lowestDistance = math.huge
	local nearestPart = nil

	for index, p in pairs(parts) do
		local distance = (part.Position - p.Position).Magnitude

		if distance < lowestDistance then
			nearestPart = p
			lowestDistance = distance
		end
	end

	return nearestPart
end

task.spawn(function()
	while true do
		task.wait(0.1)
		ping = ( getPing() + getServerPing() ) / 1000
	end
end)

task.spawn(function()
	runService.RenderStepped:Connect(function()
		fps += 1
		task.delay(1, function()
			fps -= 1
		end)
	end)
end)

--// catching

local fakeBalls = {}
local pullVectoredBalls = {}

local magnets = Catching:CreateModule("Magnets")
local magnetsType = magnets:CreateSwitch({
	Title = "Type",
	Range = {"Custom"}
})
local magnetsCustomRadius = magnets:CreateSlider({
	Title = "Custom Radius",
	Range = {0, 35},
	Value = 10
})
local showMagHitbox = magnets:CreateToggle({
	Title = "Show Hitbox"
})

firetouchinterest = (IS_SOLARA or string.match(getexecutorname(), "Wave")) and function(part2, part1, state)
	if AC_BYPASS then
		part1.CFrame = part2.CFrame
	else
		state = state == 1
		local fakeBall = fakeBalls[part1]
		if not fakeBall then return end

		local direction = (part2.Position - fakeBall.Position).Unit
		local distance = (part2.Position - fakeBall.Position).Magnitude

		for i = 1,5,1 do
			local percentage = i/5 + Random.new():NextNumber(0.01, 0.02)
			part1.CFrame = fakeBall.CFrame + (direction * distance * percentage)
		end
	end
end or firetouchinterest

local velocity = {}
local isCatching = false

local part = Instance.new("Part")
part.Transparency = 0.5
part.Anchored = true
part.CanCollide = false
part.CastShadow = false

local function onCharacterCatching(character)
	local arm = character:WaitForChild('Left Arm')

	arm.ChildAdded:Connect(function(child)
		if not child:IsA("Weld") then return end
		isCatching = true
		task.wait(1.7)
		isCatching = false
	end)
end


workspace.ChildAdded:Connect(function(ball)
	if ball.Name ~= "Football" then return end
	if not ball:IsA("BasePart") then return end
	task.wait()

	local lastPosition = ball.Position
	local lastCheck = os.clock()
	local initalVelocity = ball.AssemblyLinearVelocity

	if (IS_SOLARA or string.match(getexecutorname(), "Wave")) and ball:FindFirstChildWhichIsA("Trail") and not ball.Anchored and camera.CameraSubject ~= ball then
		local fakeBall = ball:Clone()
		fakeBall.Name = "FFootball"
		fakeBall.Parent = workspace
		fakeBall.Anchored = true
		fakeBall.CanCollide = false
		fakeBall:FindFirstChildWhichIsA('PointLight'):Destroy()
		ball.Transparency = 1
		local spiralDegrees = 0
		fakeBalls[ball] = fakeBall
		task.spawn(function()
			while ball.Parent == workspace do
				local dt = runService.Heartbeat:Wait()
				spiralDegrees += 1500 * dt
				initalVelocity += Vector3.new(0, -28 * dt, 0)
				fakeBall.Position += initalVelocity * dt
				fakeBall.CFrame = CFrame.lookAt(fakeBall.Position, fakeBall.Position + initalVelocity) * CFrame.Angles(math.rad(90), math.rad(spiralDegrees), 0)

				if ball:FindFirstChildWhichIsA("Trail") then
					ball:FindFirstChildWhichIsA("Trail").Enabled = false
				end	
			end
			fakeBall:Destroy()
		end)
	end

	while ball.Parent do
		task.wait(0.1)

		local t = (os.clock() - lastCheck)
		velocity[ball] = (ball.Position - lastPosition) / t

		lastCheck = os.clock()
		lastPosition = ball.Position
	end
end)

task.spawn(function()
	while true do
		task.wait()
		local ball = findClosestBall(); if not ball then part.Parent = nil continue end
		local character = player.Character

		if not character then continue end

		local catchPart = getNearestPartToPartFromParts(ball, {character:FindFirstChild("CatchLeft"), character:FindFirstChild("CatchRight")})

		if not catchPart then continue end
		if not velocity[ball] then continue end
		if not magnets.Value then continue end

		if IS_SOLARA and not IS_PRACTICE and values.PlayType.Value ~= "normal" then
			continue
		end

		local distance = (catchPart.Position - ball.Position).Magnitude
		local radius = magnetsCustomRadius.Value
		part.Position = (fakeBalls[ball] or ball).Position
		part.Size = Vector3.new(radius, radius, radius)
		part.Parent = showMagHitbox.Value and workspace or nil
		part.Color = Color3.fromRGB(173, 173, 173)

		if not isCatching and IS_SOLARA then continue end

		if distance < radius then
			firetouchinterest(catchPart, ball, 0)
			firetouchinterest(catchPart, ball, 1)
		end
	end
end)

onCharacterCatching(player.Character)
player.CharacterAdded:Connect(onCharacterCatching)

--// player

local jumpPower = Player:CreateModule("JumpPower")
local jumpPowerValue = jumpPower:CreateSlider({
	Title = "Power",
	Range = {50, 70}
})

local function onCharacterMovement(character)
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.Jumping:Connect(function()
		if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end
		task.wait(.1)
		if jumpPower.Value then
			humanoidRootPart.AssemblyLinearVelocity += Vector3.new(0, jumpPowerValue.Value - 50, 0)
		end
	end)
end

onCharacterMovement(player.Character)
player.CharacterAdded:Connect(onCharacterMovement)

--// configs

local Save = Configs:CreateModule("Save", true, function()
	configSavingUI.Enabled = true

	local configName = nil

	local connection; connection = configSavingUI.Frame.ConfirmButton.MouseButton1Click:Connect(function()
		configName = configSavingUI.Frame.ConfigName.Text
		connection:Disconnect()
	end)

	repeat task.wait() until configName

	configSavingUI.Enabled = false

	local exported = UI:Export()

	writefile("bleachhack/"..configName..".json", exported)
end)

local Load = Configs:CreateModule("Load", true, function()
	configSavingUI.Enabled = true

	local configName = nil

	local connection; connection = configSavingUI.Frame.ConfirmButton.MouseButton1Click:Connect(function()
		configName = configSavingUI.Frame.ConfigName.Text
		connection:Disconnect()
	end)

	repeat task.wait() until configName

	configSavingUI.Enabled = false

	if not isfile("bleachhack/"..configName..".json") then return end

	local contents = readfile("bleachhack/"..configName..".json")

	UI:Import(contents)
end)

do
	local HttpService = game:GetService("HttpService")
	local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
	local requestUrl = 'http://127.0.0.1:6463/rpc?v=1'
	local discord_invite = 'bleachhack'

	local requestData = {
		cmd = 'INVITE_BROWSER',
		args = {
			code = discord_invite
		},
		nonce = HttpService:GenerateGUID(false)
	}

	local headers = {
		['Content-Type'] = 'application/json',
		['Origin'] = 'https://discord.com'
	}

	local success, response = pcall(httprequest, {
		Url = requestUrl,
		Method = 'POST',
		Headers = headers,
		Body = HttpService:JSONEncode(requestData)
	})
end
