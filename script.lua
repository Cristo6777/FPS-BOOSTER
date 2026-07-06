local Player = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local GUI = Instance.new("ScreenGui")
GUI.Parent = Player:WaitForChild("PlayerGui")
GUI.ResetOnSpawn = false

-- Botón abrir/cerrar
local Toggle = Instance.new("TextButton")
Toggle.Parent = GUI
Toggle.Size = UDim2.new(0,100,0,30)
Toggle.Position = UDim2.new(0,10,0,100)
Toggle.Text = "UI"

-- Frame principal
local Frame = Instance.new("Frame")
Frame.Parent = GUI
Frame.Size = UDim2.new(0,220,0,170)
Frame.Position = UDim2.new(0,10,0,140)
Frame.Visible = false

-- Botón Pantalla Estirada
local Stretch = Instance.new("TextButton")
Stretch.Parent = Frame
Stretch.Size = UDim2.new(0,200,0,40)
Stretch.Position = UDim2.new(0,10,0,10)
Stretch.Text = "PANTALLA ESTIRADA"

-- Botón FPS Booster
local FPSButton = Instance.new("TextButton")
FPSButton.Parent = Frame
FPSButton.Size = UDim2.new(0,200,0,40)
FPSButton.Position = UDim2.new(0,10,0,60)
FPSButton.Text = "FPS BOOSTER"
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = Frame
InfoLabel.Size = UDim2.new(0,200,0,40)
InfoLabel.Position = UDim2.new(0,10,0,110)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.SourceSansBold
InfoLabel.TextSize = 14
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Text = "FPS: 0 | PING: 0ms"

local Frames = 0
local LastTime = tick()

RunService.RenderStepped:Connect(function()
    Frames += 1

    if tick() - LastTime >= 1 then
        local FPS = Frames
        Frames = 0
        LastTime = tick()

        local Ping = 0

        pcall(function()
            Ping = math.floor(
                Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            )
        end)

        if FPS >= 50 then
            InfoLabel.TextColor3 = Color3.fromRGB(0,255,0)
        elseif FPS >= 30 then
            InfoLabel.TextColor3 = Color3.fromRGB(255,255,0)
        else
            InfoLabel.TextColor3 = Color3.fromRGB(255,0,0)
        end

        InfoLabel.Text = "FPS: "..FPS.." | "..Ping.."ms"
    end
end)
Toggle.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
	Toggle.Text = Frame.Visible and "CERRAR UI" or "ABRIR UI"
end)

-- Pantalla estirada (efecto visual)
local StretchEnabled = false

Stretch.MouseButton1Click:Connect(function()
	StretchEnabled = not StretchEnabled

	if StretchEnabled then
		workspace.CurrentCamera.FieldOfView = 90
		Stretch.Text = "ESTIRADA: ON"
	else
		workspace.CurrentCamera.FieldOfView = 70
		Stretch.Text = "ESTIRADA: OFF"
	end
end)

-- FPS Booster
local FPSBoosted = false

FPSButton.MouseButton1Click:Connect(function()
	if FPSBoosted then return end
	FPSBoosted = true

	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _,v in ipairs(game:GetDescendants()) do
		pcall(function()

			if v:IsA("ParticleEmitter")
			or v:IsA("Trail")
			or v:IsA("Smoke")
			or v:IsA("Fire")
			or v:IsA("Sparkles") then
				v.Enabled = false
			end

			if v:IsA("PointLight")
			or v:IsA("SpotLight")
			or v:IsA("SurfaceLight") then
				v.Enabled = false
			end

			if v:IsA("BasePart") then
				v.CastShadow = false
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
			end

			if v:IsA("Sound") then
				v.Volume = 0
			end
		end)
	end

	if Terrain then
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
	end

	FPSButton.Text = "FPS BOOSTER: ON"
end)
local UIS = game:GetService("UserInputService")

local function MakeDraggable(Object)
	local Dragging = false
	local DragStart
	local StartPos

	Object.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPos = Object.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Object.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)

	UIS.InputChanged:Connect(function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch) then

			local Delta = Input.Position - DragStart

			Object.Position = UDim2.new(
				StartPos.X.Scale,
				StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale,
				StartPos.Y.Offset + Delta.Y
			)
		end
	end)
end

-- Hacer arrastrables
MakeDraggable(Toggle)
MakeDraggable(Frame)
