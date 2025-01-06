local CS = game:GetService("CollectionService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local holdGrip = script.HoldGrip
local currentHoldGrip = nil
local target = nil

local camera = game.Workspace.CurrentCamera

local holdDistance = 10

local setNetworkOwner = game.ReplicatedStorage:WaitForChild("SetNetworkOwner")
local getNetworkOwner = game.ReplicatedStorage:WaitForChild("GetNetworkOwner")

local dragSystem = {}

function dragSystem.startDragging()
	target = mouse.Target
	
	if CS:HasTag(target, "Draggable") and target.Anchored == false then
		
		local cameraCFrame = camera.CFrame
		local targetPosition = cameraCFrame.Position + cameraCFrame.LookVector * holdDistance
		
		if not getNetworkOwner:InvokeServer(target) then
			setNetworkOwner:FireServer(target)
		end
		
		if not target:FindFirstChild("HoldGrip") then
			currentHoldGrip = holdGrip:Clone()
			currentHoldGrip.Parent = target
			
			currentHoldGrip.Position = target.Position
			
			local weld = Instance.new('WeldConstraint', currentHoldGrip)
			weld.Part0 = currentHoldGrip
			weld.Part1 = target
		end
		
		currentHoldGrip.AlignPosition.Position = targetPosition
		
		print("test")
	else
		target = nil
	end
end

function dragSystem.updateDragPosition()
	if currentHoldGrip and target then
		local cameraCFrame = camera.CFrame
		local targetPosition = cameraCFrame.Position + cameraCFrame.LookVector * holdDistance
		currentHoldGrip.AlignPosition.Position = targetPosition
	end
end

function dragSystem.dragStopped()
	if currentHoldGrip and target then
		if currentHoldGrip:FindFirstChild("WeldConstraint") then
			currentHoldGrip.WeldConstraint:Destroy()
		end
		
		local target_ = target
		target = nil
		
		local currentHoldGrip_ = currentHoldGrip
		currentHoldGrip = nil
		
		currentHoldGrip_:Destroy()
		
		setNetworkOwner:FireServer(target_)
	end
end

return dragSystem
