local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local UserInputService = game:GetService("UserInputService")

local cooldownTime = 3
local keysPressed = {
	W = false,
	S = false,
	A = false,
	D = false,
	Q = false
}

local cooldowns = {
	AD = 0,  
	WS = 0  
}

local animations = {
	Left = "rbxassetid://104351297621630",
	Right = "rbxassetid://76993408625009",
	Forward = "rbxassetid://128213246719278",
	Backward = "rbxassetid://103812165141063"
}

local function playAnimation(direction)
	local humanoid = char:WaitForChild("Humanoid")
	local anim = Instance.new("Animation")
	anim.Name = "DashAnim"
	anim.AnimationId = animations[direction]
	anim.Parent = script

	local animation = humanoid:LoadAnimation(anim)
	animation:Play()
	anim:Destroy()
end

local function createDashVelocity(direction, initialDirection, speed, isGrounded)
	local humRootPart = char:WaitForChild("HumanoidRootPart")
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1, 1, 1) * 100000

	if isGrounded then
		bodyVel.Velocity = initialDirection * (speed * 2)
	else
		bodyVel.Velocity = initialDirection * speed
	end

	bodyVel.Parent = humRootPart
	game:GetService("Debris"):AddItem(bodyVel, 0.2)
end

local function isGrounded()
	local humanoid = char:WaitForChild("Humanoid")
	local ray = Ray.new(char.HumanoidRootPart.Position, Vector3.new(0, -5, 0))
	local hit = workspace:FindPartOnRay(ray, char)
	return hit and hit.CanCollide
end

local function dash(direction, initialDirection, speed)
	local currentTime = tick()
	local cooldownKey = (direction == "Left" or direction == "Right") and "AD" or "WS"

	if currentTime - cooldowns[cooldownKey] < cooldownTime then return end
	cooldowns[cooldownKey] = currentTime

	playAnimation(direction)

	local grounded = isGrounded()

	createDashVelocity(direction, initialDirection, speed, grounded)
end

local function getDashDirection()
	local humRootPart = char:WaitForChild("HumanoidRootPart")
	local lookVector = humRootPart.CFrame.lookVector
	local rightVector = humRootPart.CFrame.RightVector

	if keysPressed["W"] then
		if keysPressed["A"] then
			return "Left", (lookVector - rightVector).Unit
		elseif keysPressed["D"] then
			return "Right", (lookVector + rightVector).Unit
		else
			return "Forward", lookVector
		end
	elseif keysPressed["S"] then
		if keysPressed["A"] then
			return "Left", (-lookVector - rightVector).Unit
		elseif keysPressed["D"] then
			return "Right", (-lookVector + rightVector).Unit
		else
			return "Backward", -lookVector
		end
	elseif keysPressed["A"] then
		return "Left", -rightVector
	elseif keysPressed["D"] then
		return "Right", rightVector
	end

	return nil
end

local function onInput(input, gameProcessed)
	if gameProcessed then return end

	local keyName = input.KeyCode.Name
	if keysPressed[keyName] ~= nil then
		if input.UserInputState == Enum.UserInputState.Begin then
			keysPressed[keyName] = true

			if keyName == "Q" then
				local dashDirection, initialDirection = getDashDirection()
				if dashDirection then
					local speed = (dashDirection == "Left" or dashDirection == "Right") and 80 or 95
					dash(dashDirection, initialDirection, speed)
				end
			end
		elseif input.UserInputState == Enum.UserInputState.End then
			keysPressed[keyName] = false
		end
	end
end

UserInputService.InputBegan:Connect(onInput)
UserInputService.InputEnded:Connect(onInput)
