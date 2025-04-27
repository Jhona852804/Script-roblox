local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaExecutorGui"
screenGui.Parent = game.CoreGui  -- ou: game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Função genérica para criar um botão (usado tanto para categorias quanto para ações)
 local function createButton(parent, buttonName, actionFunction)
    local btn = Instance.new("TextButton")
    btn.Name = buttonName
    btn.Size = UDim2.new(1, -10, 0, 30)  -- largura com margem e altura de 30 pixels
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = buttonName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = parent
    btn.Background.Transparency = 0.3

    if actionFunction then
        btn.MouseButton1Click:Connect(actionFunction)
    end
 end
local function createButton(parent, text, onClick)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = parent
    button.MouseButton1Click:Connect(onClick)
    return button
end

local function createHoldButton(parent, text, onHoldStart, onHoldStop)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = parent

    button.MouseButton1Down:Connect(onHoldStart)
    button.MouseButton1Up:Connect(onHoldStop)

    return button
end
local character = game.Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        print("HumanoidRootPart não encontrado")
        return 
    end

    -- Cria uma ScreenGui exclusiva para os controles de Fly
    local flyScreenGui = Instance.new("ScreenGui")
    flyScreenGui.Parent = game.CoreGui

    -- Cria a janela do Fly
    local flyWindow = Instance.new("Frame", flyScreenGui)
    flyWindow.Size = UDim2.new(0, 200, 0, 300)
    flyWindow.Position = UDim2.new(0.8, 0, 0.2, 0)
    flyWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    flyWindow.Active = true
    flyWindow.Draggable = true

    -- Título da janela
    local titleLabel = Instance.new("TextLabel", flyWindow)
    titleLabel.Text = "Fly Controls"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18

    -- Container para os botões, posicionado abaixo do título
    local buttonContainer = Instance.new("Frame", flyWindow)
    buttonContainer.Size = UDim2.new(1, 0, 1, -30)
    buttonContainer.Position = UDim2.new(0, 0, 0, 30)
    buttonContainer.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", buttonContainer)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)

    local flying = true
    local flySpeed = 50
    local movement = {up = 0, forward = 0}
    local flyConnection
    local lowPolyActive = false  -- Variável para controlar o estado

    -- Loop para atualizar a velocidade do personagem enquanto estiver voando
    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if flying then
            local camera = workspace.CurrentCamera
            local direction = camera.CFrame.LookVector * movement.forward
            local vertical = Vector3.new(0, movement.up, 0)
            rootPart.Velocity = (direction + vertical) * flySpeed
        end
    end)

    -- Botões de clique contínuo (hold) para controlar o movimento
    createHoldButton(buttonContainer, "+Y (go up)", 
        function() movement.up = 3 end, 
        function() movement.up = 0 end
    )
    createHoldButton(buttonContainer, "-Y (down)", 
        function() movement.up = -3 end, 
        function() movement.up = 0 end
    )
    createHoldButton(buttonContainer, "Forward", 
        function() movement.forward = 3 end, 
        function() movement.forward = 0 end
    )
    createHoldButton(buttonContainer, "Backward", 
        function() movement.forward = -3 end, 
        function() movement.forward = 0 end
    )

    -- Botão para parar o Fly e fechar a janela
    createButton(buttonContainer, "Stop Fly", function()
        flying = false
        if flyConnection then 
            flyConnection:Disconnect() 
        end
        flyScreenGui:Destroy()
        rootPart.Velocity = Vector3.new(0, 0, 0)
    end)
