local uiEnabled = false
local ui = script.Parent.Parent.Parent.StoreGui
local player = game.Players.LocalPlayer
local remote = game.ReplicatedStorage.BuyItem

local succesfulColor = Color3.new(0.0509804, 1, 0)
local errorColor = Color3.new(1, 0, 0)
local messageText = ui.Message

currentItemIndex = 1
currentItem = nil
local itemsFolder = game.ReplicatedStorage:WaitForChild("StoreItems")

local soundsFolder = ui.ItemInfo.Sounds
local switchSnd = soundsFolder:WaitForChild("SwitchSound")
local buySnd = soundsFolder:WaitForChild("BuySound")
local errorSnd = soundsFolder:WaitForChild("ErrorSound")

local StarterGui = game:GetService("StarterGui")

local outline = Instance.new("Highlight")
outline.FillTransparency = 1

local TweenService = game:GetService("TweenService")
local TwInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Exponential,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)
debounce = false

local function updateGui()
	ui.ItemInfo.ItemTitle.Text = currentItem.Name
	ui.ItemInfo.ItemDescription.Text = currentItem:FindFirstChild("Description").Value
	ui.ItemInfo.ItemPrice.Text = tostring(currentItem:FindFirstChild("Price").Value) .. " bux"
end
local function placeItem(itemIndex)
	currentItem = itemsFolder:GetChildren()[itemIndex]:Clone()
	currentItem.Parent = workspace
	currentItem.Position = game.Workspace.Store.ItemPos.Position
end

script.Parent.Activated:Connect(function()
	if uiEnabled == true then
		uiEnabled = false
		ui.Visible = false
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	else
		uiEnabled = true
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		game.Workspace.CurrentCamera.CFrame = game.Workspace.StoreCamera.CFrame
		ui.Visible = true
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		if currentItem == nil then
			placeItem(1)
			
			ItemOutline = outline:Clone()
			ItemOutline.Parent = currentItem
			updateGui()
		end
	end
end)

local function MoveObject(axisX)
	local itemToDestroy = currentItem
	switchSnd:Play()

	local goal = {}
	goal.Position = currentItem.Position - Vector3.new(axisX,0,0)
	local tw = TweenService:Create(currentItem,TwInfo,goal)
	tw:Play()
	tw.Completed:Connect(function()
		itemToDestroy:Destroy()
		debounce = false
	end)

	placeItem(currentItemIndex)
	currentItem.Position += Vector3.new(axisX,0,0)
	goal.Position = currentItem.Position - Vector3.new(axisX,0,0)
	tw = TweenService:Create(currentItem,TwInfo,goal)
	tw:Play()

	ItemOutline = outline:Clone()
	ItemOutline.Parent = currentItem
	updateGui()
end

ui.Left.Activated:Connect(function()
	if not debounce then
		debounce = true
		if currentItemIndex == 1 then
			currentItemIndex = #itemsFolder:GetChildren()
			MoveObject(6)
		else
			currentItemIndex -= 1
			MoveObject(6)
		end
	end

end)
ui.Right.Activated:Connect(function()
	if not debounce then
		debounce = true
		if currentItemIndex == #itemsFolder:GetChildren() then
			currentItemIndex = 1
			MoveObject(-6)
		else
			currentItemIndex += 1
			MoveObject(-6)
		end
	end

end)

ui.ItemInfo.BuyButton.Activated:Connect(function()
	if player:FindFirstChild("leaderstats") then
		if player:FindFirstChild("leaderstats"):FindFirstChild("Cash") then
			local plrCash = player:FindFirstChild("leaderstats"):FindFirstChild("Cash").Value
			
			if plrCash >= currentItem:FindFirstChild("Price").Value then
				remote:FireServer(currentItem.Name)
			else
				remote:FireServer(currentItem.Name)
			end
		end
	end
end)

remote.OnClientEvent:Connect(function(success)
	if success then
		buySnd:Play()
		local notification = messageText:Clone()
		notification.Parent = messageText.Parent
		notification.TextColor3 = succesfulColor
		notification.Visible = true
		notification.Text = "Successfuly bought!"
		
		notification.Position += UDim2.new(0,0,0.5,0)
		local goal = {}
		goal.Position = (notification.Position) - UDim2.new(0,0,0.6,0)
		
		local tw = TweenService:Create(notification,TwInfo,goal)
		tw:Play()
		tw.Completed:Connect(function()
			task.wait(2)
			
			goal.Position = (notification.Position) - UDim2.new(0,0,3,0)

			local tw = TweenService:Create(notification,TwInfo,goal)
			tw:Play()
			
			tw.Completed:Connect(function()
				notification:Destroy()
			end)
		end)
	else
		errorSnd:Play()
		local notification = messageText:Clone()
		notification.Parent = messageText.Parent
		notification.TextColor3 = errorColor
		notification.Visible = true
		notification.Text = "Error, not enough funds!"

		notification.Position += UDim2.new(0,0,0.5,0)
		local goal = {}
		goal.Position = (notification.Position) - UDim2.new(0,0,0.6,0)

		local tw = TweenService:Create(notification,TwInfo,goal)
		tw:Play()
		tw.Completed:Connect(function()
			task.wait(2)

			goal.Position = (notification.Position) - UDim2.new(0,0,3,0)

			local tw = TweenService:Create(notification,TwInfo,goal)
			tw:Play()

			tw.Completed:Connect(function()
				notification:Destroy()
			end)
		end)
	end
end)
