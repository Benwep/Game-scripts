local swordToClone = game.ServerStorage.Sword
local attackEvent = game.ReplicatedStorage.Events.Attack
local slash1 = Instance.new("Animation")
slash1.AnimationId = "http://www.roblox.com/asset/?id=16108586459"
local dashAnimation = Instance.new("Animation")
dashAnimation.AnimationId = "http://www.roblox.com/asset/?id=16155061036"
local blockAnimation = Instance.new("Animation")
blockAnimation.AnimationId = "http://www.roblox.com/asset/?id=16183241251"
isAttacking = false
canAttack = true
canBlock = true
local slashDamage = 5
local parrySound = game.ServerStorage.ParrySound
local tweenService = game:GetService("TweenService")
local ParryUi = game.Workspace.ParryIndicator.BillboardGui
local BlockUi = game.Workspace.BlockIndicator.BillboardGui
local twInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Exponential,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)
local function TextEffect(char,hitBox,animTrack,hum,sndToPlay,ui,callStun)
	if callStun then
		speed = char.Humanoid.WalkSpeed
		char.Humanoid.WalkSpeed = 0
		
		hitBox:Destroy()
		animTrack:Stop()
		canAttack = false
		isAttacking = false
	end
	if sndToPlay ~= nil then
		sndToPlay:Play()
	end
	local GuiToInsert = ui:Clone()
	GuiToInsert.Parent = hum.Parent:FindFirstChild("HumanoidRootPart")
	local goal = {}
	goal.ExtentsOffset = Vector3.new(0,2,0)
	local tw = tweenService:Create(GuiToInsert,twInfo,goal)
	tw:Play()
	tw.Completed:Connect(function()
		task.wait(0.5)
		if callStun then
			char.Humanoid.WalkSpeed = speed
		end
		canAttack = true
		GuiToInsert:Destroy()
		sndToPlay:Destroy()
	end)
end
local function CreateWeld(part0,part1)
	local weld = Instance.new("WeldConstraint")
	weld.Parent = part0
	weld.Part0 = part0
	weld.Part1 = part1
end
local function putSwordOnBack(sword,char)
	local torso = char:FindFirstChild("Torso")
	sword.Position = torso.Position - (torso.CFrame.LookVector / 2)
	sword.CFrame = (sword.CFrame * CFrame.Angles(math.rad(135),0,math.rad(90)))
	CreateWeld(sword,torso)
end
game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		local char = plr.Character
		local sword = swordToClone:Clone()
		sword.Parent = char
		putSwordOnBack(sword,char)
		local swordPos = swordToClone:Clone()
		swordPos.Transparency = 1
		swordPos.CanCollide = false
		swordPos.Name = "SwordPos"
		swordPos.CFrame = sword.CFrame
		swordPos.Parent = char
		
		CreateWeld(swordPos,char.Torso)
	end)
end)
local function DestroyWelds(sword)
	for i,v in sword:GetChildren() do
		if v:IsA("WeldConstraint") or v:IsA("Weld") then
			v:Destroy()
		end
	end
end
local function HideSword(hitBox,weld,char,sword)
	hitBox:Destroy()
	weld:Destroy()
	if char:FindFirstChild("SwordPos") then
		sword.CFrame = char:FindFirstChild("SwordPos").CFrame
		CreateWeld(sword,char.Torso)
	end
end
attackEvent.OnServerEvent:Connect(function(plr)
	local char = plr.Character
	if char:FindFirstChild("Sword") then
		if not isAttacking and canAttack then
			isAttacking = true
			local sword = char:FindFirstChild("Sword")
			local rightArm = char["Right Arm"]
			local root = char:FindFirstChild("HumanoidRootPart")
			local previousCFrame = sword.CFrame
			sword:FindFirstChild("SwordSlash"):Play()
			DestroyWelds(sword)
			local weld = Instance.new("Weld")
			weld.Parent = sword
			weld.Part0 = sword:FindFirstChild("Arm")
			weld.Part1 = rightArm
			local animTrack = char.Humanoid:LoadAnimation(slash1)
			animTrack:Play()
			local hitBox = Instance.new("Part")
			hitBox.Size = Vector3.new(5,6,4.5)
			hitBox.Parent = char
			hitBox.CFrame = (root.CFrame + (root.CFrame.LookVector * 2.5))
			hitBox.Transparency = 1
			hitBox.CanCollide = false
			CreateWeld(hitBox,root)
			TouchedParts = {}
			hitBox.Touched:Connect(function(hit)
				if hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid") then
					if hit.Parent.Name ~= char.Name and hit.Parent.Parent.Name ~= char.Name then
						local hum = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
						local plrGotHurt = table.find(TouchedParts,hum.Parent)
						if not plrGotHurt then
							if not hum:FindFirstChild("Block") and not hum:FindFirstChild("Parry") then
								hum.Health -= slashDamage
								local speedToTake = 10
								hum.WalkSpeed -= speedToTake
								table.insert(TouchedParts,hum.Parent)
								task.wait(0.2)
								hum.WalkSpeed -= speedToTake
							elseif hum:FindFirstChild("Parry") and hum:FindFirstChild("Parry").Value == true then
								local snd = parrySound:Clone()
								snd.Parent = workspace
								local ui = ParryUi
								TextEffect(char,hitBox,animTrack,hum,snd,ui,true)
								sword:FindFirstChild("SwordSlash"):Stop()
								HideSword(hitBox,weld,char,sword) -- hide sword after getting parried
							elseif hum:FindFirstChild("Block") and hum:FindFirstChild("Block").Value == true then
								table.insert(TouchedParts,hum.Parent)
								local snd = parrySound:Clone()
								local ui = BlockUi
								TextEffect(char,hitBox,animTrack,hum,snd,ui,false)
							end
						end
					end
				end
			end)
			task.wait(animTrack.Length)
			HideSword(hitBox,weld,char,sword) -- hide sword if player didnt get parried
			attackEvent:FireClient(plr) -- fire player's event to allow dashing or attacking again
			isAttacking = false
		end
	end
end)
game.ReplicatedStorage.Events.Dash.OnServerEvent:Connect(function(plr)
	local animTrack = plr.Character:WaitForChild("Humanoid"):LoadAnimation(dashAnimation)
	animTrack:Play()
end)
local function CreateValue(name,char)
	local valv = Instance.new("BoolValue")
	valv.Name = name
	valv.Value = true
	valv.Parent = char
	return valv
end
local function DestroyBlock(char,animTrack,sword)
	local block = char.Humanoid:FindFirstChild("Block")
	local parry = char.Humanoid:FindFirstChild("Parry")
	if block then
		block:Destroy()
	end
	if parry then
		parry:Destroy()
	end
	if animTrack then
		animTrack:Stop()	
	end
	char.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
	DestroyWelds(sword)
	if char:FindFirstChild("SwordPos") then
		sword.CFrame = char:FindFirstChild("SwordPos").CFrame

		CreateWeld(sword,char.Torso)
	end
	canBlock = true
end
game.ReplicatedStorage.Events.Block.OnServerEvent:Connect(function(plr)
	local char = plr.Character
	sword = char:FindFirstChild("Sword")
	if canBlock and not isAttacking then
		if char.Humanoid:FindFirstChild("Block") or char.Humanoid:FindFirstChild("Parry") then
			DestroyBlock(char,animTrack,sword)
		else	
			canBlock = false
			local var = CreateValue("Parry",char.Humanoid)
			char.Humanoid.WalkSpeed = 4
			local rightArm = char["Right Arm"]
			local root = char:FindFirstChild("HumanoidRootPart")
			DestroyWelds(sword)
			weld = Instance.new("Weld")
			weld.Parent = sword
			weld.Part0 = sword:FindFirstChild("Arm")
			weld.Part1 = rightArm
			animTrack = char.Humanoid:LoadAnimation(blockAnimation)
			animTrack:Play()
			task.wait(0.2)
			var:Destroy()
			if not canBlock then
				var = CreateValue("Block",char.Humanoid)
				canBlock = true
			end
		end
	else
		DestroyBlock(char,animTrack,sword)
	end
end)
