local dragSystem = {}

local target = nil
local distance = 10
local grip = nil
local attachment0 = nil

local grips = game.Workspace:WaitForChild("Grips")

function dragSystem.startDragging(player: Player)
	local CS = game:GetService("CollectionService")

	local setNetworkOwner = game.ReplicatedStorage:WaitForChild("SetNetworkOwner")
	local getNetworkOwner = game.ReplicatedStorage:WaitForChild("GetNetworkOwner")

	local mouse = player:GetMouse()
	target = mouse.Target
	local camera = workspace.CurrentCamera

	if target and CS:HasTag(target, "Draggable") and target.Name ~= "Baseplate" then
		if target.Anchored then
			warn("Cannot drag an anchored part")
			target = nil
			return
		end

		if not getNetworkOwner:InvokeServer(target) then
			setNetworkOwner:FireServer(target)
		end

		local partPosition = camera.CFrame.Position + ((mouse.Hit.Position - camera.CFrame.Position).Unit * distance)

		grip = script.HoldGrip:Clone()
		grip.Position = partPosition
		grip.Parent = grips

		attachment0 = Instance.new("Attachment")
		attachment0.Position = partPosition
		attachment0.Name = "Attach0"
		attachment0.Parent = target

		grip.AlignPosition.Attachment0 = attachment0
	else
		target = nil
	end
end

function dragSystem.dragUpdate(player: Player)
	if target and attachment0 then
		local mouse = player:GetMouse()
		local camera = game.Workspace.CurrentCamera

		local partPosition = camera.CFrame.Position + ((mouse.Hit.Position - camera.CFrame.Position).Unit * distance)
		attachment0.Position = partPosition
	end
end

function dragSystem.dragStopped()
	if target then
		local setNetworkOwner = game.ReplicatedStorage:WaitForChild("SetNetworkOwner")

		local target_ = target
		target = nil

		if attachment0 then
			attachment0:Destroy()
			attachment0 = nil
		end

		if grip then
			grip:Destroy()
			grip = nil
		end

		setNetworkOwner:FireServer(target_)
	end
end

return dragSystem
