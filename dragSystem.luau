-- Made by Cheeseserowy
-- It doesn't work on a normal roblox part,
-- tested on a meshpart and its working perfectly.

local CS = game:GetService("CollectionService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local holdGrip = script.HoldGrip
local currentHoldGrip = nil
local target = nil

local camera = game.Workspace.CurrentCamera

local newPosition = nil
local newOrientation = nil
local holdDistance = 10

local setNetworkOwner = game.ReplicatedStorage:WaitForChild("SetNetworkOwner")
local getNetworkOwner = game.ReplicatedStorage:WaitForChild("GetNetworkOwner")

local dragSystem = {}

local function updatePosition()
	local cameraCFrame = camera.CFrame
	newPosition = cameraCFrame.Position + cameraCFrame.LookVector * holdDistance
	currentHoldGrip.AlignPosition.Position = newPosition
	newOrientation = CFrame.lookAt(Vector3.new(0, 0, 0), camera.CFrame.LookVector)
	currentHoldGrip.AlignOrientation.CFrame = newOrientation
end

function dragSystem.startDragging()
	target = mouse.Target

	if CS:HasTag(target, "Draggable") and target.Anchored == false then
		local cameraCFrame = camera.CFrame
		newPosition = cameraCFrame.Position + cameraCFrame.LookVector * holdDistance
		newOrientation = CFrame.lookAt(Vector3.new(0, 0, 0), camera.CFrame.LookVector)

		if not target:FindFirstChild("HoldGrip") then
			currentHoldGrip = holdGrip:Clone()
			currentHoldGrip.Parent = target
			currentHoldGrip.AlignPosition.Position = target.Position
			currentHoldGrip.Position = target.Position

			local weld = Instance.new('WeldConstraint', currentHoldGrip)
			weld.Part0 = currentHoldGrip
			weld.Part1 = target
		end

		if not getNetworkOwner:InvokeServer(target) then
			setNetworkOwner:FireServer(target)
		end

		updatePosition()
	else
		target = nil
	end
end

function dragSystem.updateDragPosition()
	if currentHoldGrip and target then
		updatePosition()
	end
end

function dragSystem.dragStopped()
	if currentHoldGrip and target then
		currentHoldGrip.AlignPosition:Destroy()

		if currentHoldGrip:FindFirstChild("WeldConstraint") then
			currentHoldGrip.WeldConstraint:Destroy()
		end

		local target_ = target
		target = nil

		local currentHoldGrip_ = currentHoldGrip
		currentHoldGrip = nil

		currentHoldGrip_:Destroy()

		newPosition = nil

		setNetworkOwner:FireServer(target_)
	end
end

function dragSystem.wheelForward()
	if target and currentHoldGrip then
		if holdDistance < 20 then
			holdDistance += 1

			updatePosition()
		end
	end
end

function dragSystem.wheelBackward()
	if target and currentHoldGrip then
		if holdDistance > 3 then
			holdDistance -= 1

			updatePosition()
		end
	end
end

return dragSystem

