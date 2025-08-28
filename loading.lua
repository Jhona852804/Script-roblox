local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Criação da ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingMessage"
screenGui.Parent = gui

-- Criação do Frame de aviso
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.4, 0, 0.08, 0) -- largura 40% da tela, altura 8%
frame.Position = UDim2.new(0.3, 0, -0.1, 0) -- começa fora da tela (em cima)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.Parent = screenGui

-- Bordas arredondadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Texto
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 1, -10)
label.Position = UDim2.new(0, 5, 0, 5)
label.BackgroundTransparency = 1
label.Text = "Carregando - Aguarde"
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Parent = frame

-- Animação de entrada (de cima para o topo fixo)
TweenService:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.3, 0, 0.05, 0) -- topo da tela
}):Play()

-- Após 3 segundos, iniciar saída
task.delay(3, function()
    -- Primeiro desce um pouco
    local tweenDown = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
        Position = UDim2.new(0.3, 0, 0.1, 0)
    })
    tweenDown:Play()
    tweenDown.Completed:Wait()

    -- Depois sobe para fora da tela
    local tweenUp = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.3, 0, -0.2, 0)
    })
    tweenUp:Play()
    tweenUp.Completed:Wait()

    screenGui:Destroy()
end)
