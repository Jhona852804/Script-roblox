local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaExecutorGui"
screenGui.Parent = game.CoreGui  -- ou: game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Cria a janela principal (MainFrame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui
mainFrame.Active = true      -- necessário para receber input
mainFrame.Draggable = true   -- torna a janela arrastável
mainFrame.BackgroundTransparency = 0.5  -- Deixa 50% transparente (0 = opaco, 1 = totalmente invisível)

-- Cria a barra de título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
titleLabel.Text = "By JhonaDev139"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = mainFrame

-- Painel Esquerdo para Categorias
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 120, 1, -30)
leftPanel.Position = UDim2.new(0, 0, 0, 30)
leftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
leftPanel.BorderSizePixel = 1
leftPanel.Parent = mainFrame
leftPanel.BackgroundTransparency = 0.3  -- 50% transparente

-- Layout para organizar os botões de categorias com espaçamento
local leftLayout = Instance.new("UIListLayout")
leftLayout.Parent = leftPanel
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Padding = UDim.new(0, 5)  -- espaçamento de 5 pixels

-- Painel Direito para Ações
local rightPanel = Instance.new("Frame")
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(1, -120, 1, -30)
rightPanel.Position = UDim2.new(0, 120, 0, 31)
rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightPanel.BorderSizePixel = 1
rightPanel.Parent = mainFrame
rightPanel.BackgroundTransparency = 0.3

-- Layout para organizar os botões de ações com espaçamento
local rightLayout = Instance.new("UIListLayout")
rightLayout.Parent = rightPanel
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Padding = UDim.new(0, 5)

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
