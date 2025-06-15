local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Criando a UI principal
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Save position V1"
gui.ResetOnSpawn = false

-- Janela principal
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 220, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Título
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Salvador de Posições"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.BackgroundTransparency = 1

-- Botão de salvar posição
local saveBtn = Instance.new("TextButton", mainFrame)
saveBtn.Size = UDim2.new(1, -20, 0, 30)
saveBtn.Position = UDim2.new(0, 10, 0, 40)
saveBtn.Text = "Salvar Posição"
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 16
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
saveBtn.BorderSizePixel = 0

-- Janela de posições salvas
local savedFrame = Instance.new("ScrollingFrame", mainFrame)
savedFrame.Position = UDim2.new(0, 10, 0, 80)
savedFrame.Size = UDim2.new(1, -20, 1, -90)
savedFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
savedFrame.ScrollBarThickness = 6
savedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
savedFrame.BorderSizePixel = 0

local savedLayout = Instance.new("UIListLayout", savedFrame)
savedLayout.Padding = UDim.new(0, 5)

-- Função para criar botão de posição salva
local function criarBotaoDePosicao(pos)
	local btn = Instance.new("TextButton", savedFrame)
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Text = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.BorderSizePixel = 0

	btn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
		end
	end)

	savedFrame.CanvasSize = UDim2.new(0, 0, 0, savedLayout.AbsoluteContentSize.Y + 5)
end

-- Salvando posição
saveBtn.MouseButton1Click:Connect(function()
	local pos = rootPart.Position
	criarBotaoDePosicao(pos)
end)