local mouse = game.Players.LocalPlayer:GetMouse()
local userInputService = game:GetService("UserInputService")
local root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local dashEvent = game.ReplicatedStorage.Events.Dash
local blockEvent = game.ReplicatedStorage.Events.Block
local attackEvent = game.ReplicatedStorage.Events.Attack
local char = game.Players.LocalPlayer.Character
attacking = false
blocking = false
canDash = true

attackEvent.OnClientEvent:Connect(function()
	-- server calls event to client once attack ended
	attacking = false
end)
function detectTool()
	tool = nil
	for i,v in char:GetChildren() do
		if v:IsA("Tool") then
			attacking = true -- to prevent attack if tool is equipped
			tool = v
		end
	end
	if tool then
		if char:FindFirstChild(tool.Name) then -- double check in case tool was unequipped previously
			attacking = true
		else
			attacking = false
		end
	else
		attacking = false
	end
end
mouse.Button1Up:Connect(function()
	detectTool(attacking)
	
	if not blocking and not attacking and canDash then
		attackEvent:FireServer()
		attacking = true
	end
end)
userInputService.InputBegan:Connect(function(input)
	detectTool()
	
	if not blocking and not attacking and canDash then
		if input.KeyCode == Enum.KeyCode.Q then
			canDash = false
			local dash = Instance.new("BodyVelocity")
			dash.MaxForce = Vector3.new(1,0,1) * 3000000
			dash.Velocity = root.CFrame.LookVector * 100
			dash.Parent = root

			dashEvent:FireServer()
			for count = 1 ,8 do
				wait(0.1)
				dash.Velocity *= 0.7
			end
			dash:Destroy()
			canDash = true
		elseif input.KeyCode == Enum.KeyCode.F then
			blocking = true
			blockEvent:FireServer()
			task.wait(0.5)
		end
	end
end)

userInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		if blocking then
			blockEvent:FireServer()
			blocking = false
			
			task.wait(0.5)
		end
	end
end)
