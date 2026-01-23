--==================================================
-- NEKO v5 FULL SINGLE FILE (Delta / R6 / Mobile)
-- Touch = AT1 -> AT7
-- Hold  = Auto AT1 -> AT7
--==================================================

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

--// PLAYER
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local Torso = char:WaitForChild("Torso")
local RA = char:WaitForChild("Right Arm")
local LA = char:WaitForChild("Left Arm")

--==================================================
-- REANIMATE (DELTA SAFE)
--==================================================
hum.BreakJointsOnDeath = false
hum.RequiresNeck = false
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

for _,v in pairs(char:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
		v.CanCollide = false
	end
end

RunService.Stepped:Connect(function()
	for _,v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			v.Velocity = Vector3.new(0,30,0)
		end
	end
end)

--==================================================
-- MOTOR
--==================================================
local Root = Torso:FindFirstChild("RootJoint")
local RSJ = Torso:FindFirstChild("Right Shoulder")
local LSJ = Torso:FindFirstChild("Left Shoulder")
local RHJ = Torso:FindFirstChild("Right Hip")
local LHJ = Torso:FindFirstChild("Left Hip")
local Neck = Torso:FindFirstChild("Neck")

local function LerpJoint(j, cf, s)
	j.C0 = j.C0:Lerp(cf, s)
end

--==================================================
-- SOUND
--==================================================
local Sounds = {
	Slash = {876316256,876316257,876316258},
	ClawOn = 911882856,
	ClawOff = 911882604,
	Jump = 12222142,
	Land = 13114759,
	Finisher = 138204323
}

local function PlaySound(id, parent, vol, pitch)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://"..id
	s.Volume = vol or 1
	s.PlaybackSpeed = pitch or 1
	s.RollOffMaxDistance = 80
	s.Parent = parent or SoundService
	s:Play()
	Debris:AddItem(s,5)
end

--==================================================
-- CLAWS + TAIL
--==================================================
local ClawsOn = false
local Claws = {}

local function NewPart(size, parent)
	local p = Instance.new("Part")
	p.Size = size
	p.Material = Enum.Material.Metal
	p.BrickColor = BrickColor.new("Really black")
	p.CanCollide = false
	p.Parent = parent
	return p
end

local function Weld(p0, p1, c0)
	local w = Instance.new("Motor6D")
	w.Part0 = p0
	w.Part1 = p1
	w.C0 = c0
	w.Parent = p0
end

for i=1,3 do
	local r = NewPart(Vector3.new(0.2,1,0.2), char)
	Weld(RA, r, CFrame.new((i-2)*0.3,-1,-0.5))
	table.insert(Claws,r)

	local l = NewPart(Vector3.new(0.2,1,0.2), char)
	Weld(LA, l, CFrame.new((i-2)*0.3,-1,-0.5))
	table.insert(Claws,l)
end

local Tail = NewPart(Vector3.new(0.4,0.4,2), char)
local TailW = Instance.new("Motor6D", Torso)
TailW.Part0 = Torso
TailW.Part1 = Tail
TailW.C0 = CFrame.new(0,-1,1)

local tailSine = 0

local function ToggleClaws()
	ClawsOn = not ClawsOn
	for _,v in pairs(Claws) do
		v.Transparency = ClawsOn and 0 or 1
	end
	PlaySound(ClawsOn and Sounds.ClawOn or Sounds.ClawOff, Torso,1)
end

--==================================================
-- HITBOX
--==================================================
local function Hitbox(part, dmg, time, size, offset)
	local hb = Instance.new("Part")
	hb.Size = size or Vector3.new(4,4,4)
	hb.Transparency = 1
	hb.CanCollide = false
	hb.Anchored = true
	hb.CFrame = part.CFrame * (offset or CFrame.new(0,0,-2))
	hb.Parent = workspace

	local con
	con = hb.Touched:Connect(function(hit)
		local h = hit.Parent:FindFirstChild("Humanoid")
		if h and hit.Parent ~= char then
			h:TakeDamage(dmg)
		end
	end)

	task.delay(time,function()
		if con then con:Disconnect() end
		hb:Destroy()
	end)
end

--==================================================
-- COMBO AT1 -> AT7
--==================================================
local attacking = false
local comboCD = 0.25

local function SlashSound()
	PlaySound(Sounds.Slash[math.random(#Sounds.Slash)], Torso,0.8,math.random(90,110)/100)
end

function AT1()
	if attacking then return end
	attacking=true
	SlashSound()
	LerpJoint(RSJ,CFrame.new(1.5,0.5,0)*CFrame.Angles(0,0,math.rad(80)),0.4)
	Hitbox(RA,10,0.15)
	task.wait(comboCD)
	attacking=false
end

function AT2()
	if attacking then return end
	attacking=true
	SlashSound()
	LerpJoint(LSJ,CFrame.new(-1.5,0.5,0)*CFrame.Angles(0,0,math.rad(-80)),0.4)
	Hitbox(LA,10,0.15)
	task.wait(comboCD)
	attacking=false
end

function AT3()
	if attacking then return end
	attacking=true
	SlashSound()
	Hitbox(RA,15,0.2)
	Hitbox(LA,15,0.2)
	task.wait(comboCD)
	attacking=false
end

function AT4()
	if attacking then return end
	attacking=true
	SlashSound()
	Torso.CFrame *= CFrame.Angles(0,math.rad(180),0)
	Hitbox(Torso,12,0.2,Vector3.new(6,4,6))
	task.wait(comboCD)
	attacking=false
end

function AT5()
	if attacking then return end
	attacking=true
	SlashSound()
	local bv=Instance.new("BodyVelocity",Torso)
	bv.MaxForce=Vector3.new(1e5,0,1e5)
	bv.Velocity=Torso.CFrame.LookVector*60
	Debris:AddItem(bv,0.15)
	Hitbox(Torso,18,0.15)
	task.wait(comboCD)
	attacking=false
end

function AT6()
	if attacking then return end
	attacking=true
	SlashSound()
	local bv=Instance.new("BodyVelocity",Torso)
	bv.MaxForce=Vector3.new(0,1e5,0)
	bv.Velocity=Vector3.new(0,45,0)
	Debris:AddItem(bv,0.2)
	Hitbox(RA,20,0.2,Vector3.new(4,6,4))
	task.wait(comboCD)
	attacking=false
end

function AT7()
	if attacking then return end
	attacking=true
	PlaySound(Sounds.Finisher,Torso,1.2)
	Hitbox(Torso,35,0.3,Vector3.new(8,6,8),CFrame.new(0,0,-3))
	task.wait(0.5)
	attacking=false
end

--==================================================
-- IDLE / WALK / JUMP
--==================================================
local sine = 0
local lastAir=false

RunService.RenderStepped:Connect(function(dt)
	sine += dt*2
	TailW.C0 = CFrame.new(0,-1,1)*CFrame.Angles(math.sin(sine)*0.3,math.sin(sine)*0.4,0)

	if hum.FloorMaterial==Enum.Material.Air then
		if not lastAir then
			lastAir=true
			PlaySound(Sounds.Jump,Torso,0.6)
		end
	else
		if lastAir then
			lastAir=false
			PlaySound(Sounds.Land,Torso,0.8)
		end
	end
end)

--==================================================
-- MOBILE TOUCH (NO UI)
--==================================================
local comboIndex=1
local holding=false

local function DoCombo()
	if comboIndex==1 then AT1()
	elseif comboIndex==2 then AT2()
	elseif comboIndex==3 then AT3()
	elseif comboIndex==4 then AT4()
	elseif comboIndex==5 then AT5()
	elseif comboIndex==6 then AT6()
	elseif comboIndex==7 then AT7()
	end
	comboIndex+=1
	if comboIndex>7 then comboIndex=1 end
end

UserInputService.TouchStarted:Connect(function(_,gp)
	if gp then return end
	holding=true
	task.spawn(function()
		task.wait(0.25)
		while holding do
			DoCombo()
			task.wait(0.35)
		end
	end)
end)

UserInputService.TouchEnded:Connect(function()
	holding=false
end)

--==================================================
-- KEYBOARD (OPTIONAL)
--==================================================
UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode==Enum.KeyCode.F then ToggleClaws() end
end)

--====================== END =======================
