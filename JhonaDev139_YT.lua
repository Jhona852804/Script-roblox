local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local espEnabled = false
local espLines = {}
local espColor = Color3.fromRGB(255, 255, 255)  -- Cor inicial: Branco
local ESP_Window = nil
local ESP_Ativo = false
local originalPosition = nil
local isFrozen = false

-- Tabela para armazenar as janelas criadas
local windows = {}

-- Função para criar janelas móveis
local function createWindow(title, position)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui

    local Frame = Instance.new("Frame", ScreenGui)
    local UIListLayout = Instance.new("UIListLayout", Frame)
    local TitleLabel = Instance.new("TextLabel", Frame)

    -- Configuração da janela  
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)  
    Frame.Position = position  
    Frame.Size = UDim2.new(0, 200, 0, 300)  
    Frame.Active = true  
    Frame.Draggable = true  

    -- Configuração do título da janela
    TitleLabel.Text = title  
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)  
    TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
    TitleLabel.Font = Enum.Font.SourceSansBold  
    TitleLabel.TextSize = 18  

    -- Layout para organizar os botões
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder  
    UIListLayout.Padding = UDim.new(0, 10)  

    windows[title] = ScreenGui
    return Frame
end

-- Função para criar botões
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton", parent)
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.MouseButton1Click:Connect(callback)
end
local function createHoldButton(parent, text, onHold, onRelease)
    local button = Instance.new("TextButton", parent)
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    
    local holding = false

    button.MouseButton1Down:Connect(function()
        holding = true
        spawn(function()
            while holding do
                onHold()
                wait(0.1) -- Intervalo de execução (ajuste conforme necessário)
            end
        end)
    end)

    button.MouseButton1Up:Connect(function()
        holding = false
        if onRelease then onRelease() end
    end)

    button.MouseLeave:Connect(function()
        holding = false
        if onRelease then onRelease() end
    end)
end

-- Criando janelas para categorias
local playerWindow = createWindow("Jogador", UDim2.new(0.01, 0, 0.2, 0))
local objectsWindow = createWindow("Objetos 3D", UDim2.new(0.20, 0, 0.2, 0))
local visualWindow = createWindow("visual", UDim2.new(0.39,0,0.2,0))
local TPWindow = createWindow("TP manager", UDim2.new(0.58, 0, 0.2, 0))
local utilitiesWindow = createWindow("Utilitários", UDim2.new(0.65, 0, 0.82, 0))
local listaWindow = createWindow("Player List", UDim2.new(0.77, 0, 0.2, 0))

-- 🏃‍♂️ Ajustar velocidade do jogador
local isSpeedIncreased = false -- Variável para controlar o estado da velocidade

createButton(playerWindow, "Alternar Velocidade", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if isSpeedIncreased then
            humanoid.WalkSpeed = 16 -- Velocidade normal padrão do Roblox
        else
            humanoid.WalkSpeed = 100 -- Velocidade aumentada
        end
        isSpeedIncreased = not isSpeedIncreased -- Alterna o estado
    end
end)

-- botão de pulo
local isJumpIncreased = false -- Variável para controlar o estado do pulo

-- permite que o jogador pule no ar
local allowAirJump = false -- Variável para controlar o estado
local jumped = false -- Variável para detectar o pulo

createButton(playerWindow, "Alternar Pulo no Ar", function()
    allowAirJump = not allowAirJump -- Alterna o estado
end)

-- Evento para permitir o pulo no ar
game:GetService("UserInputService").JumpRequest:Connect(function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if allowAirJump then
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Permite pular no ar
            end
        end
    end
end)

createButton(playerWindow, "super jump", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if isJumpIncreased then
            humanoid.JumpPower = 50 -- Valor padrão do Roblox
        else
            humanoid.JumpPower = 150 -- Super pulo
        end
        isJumpIncreased = not isJumpIncreased -- Alterna o estado
    end
end)


-- sistema do fly

createButton(playerWindow, "Fly", function()
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
    local flySpeed = 20
    local movement = {up = 0, forward = 0}
    local flyConnection

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
    createHoldButton(buttonContainer, "+Y (Subir)", 
        function() movement.up = 3 end, 
        function() movement.up = 0 end
    )
    createHoldButton(buttonContainer, "-Y (Descer)", 
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
end)

------- função de ANT AFK 
-- Variável para controlar o estado do ant AFK
local antAFKEnabled = false

-- Função para mostrar a notificação
local function showNotification(message)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 0.1, 0)  -- Exibido na parte superior centralizada
    notification.Text = message
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextSize = 20
    notification.TextStrokeTransparency = 0.8
    notification.Parent = game.CoreGui

    -- Remover a notificação após 3 segundos
    wait(3)
    notification:Destroy()
end

-- Função para manter o jogador ativo e impedir o AFK
local function preventAFK()
    while antAFKEnabled do
        -- Movimenta o jogador para evitar ser kikado
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.1) 
        wait(10)  -- Repite a movimentação a cada 10 segundos
    end
end

-- Criando o botão "ant AFK"
createButton(playerWindow, "ant AFK", function()
    if not antAFKEnabled then
        antAFKEnabled = true
        showNotification("ant AFK enabled")  -- Exibe a notificação que o ant AFK foi ativado
        spawn(preventAFK)  -- Começa a prevenir o AFK
    else
        antAFKEnabled = false
        showNotification("ant AFK disable")  -- Exibe a notificação que o ant AFK foi desativado
    end
end)
---------------------------------------------- _ Fim da função AFK

-- 📍 Teleporte
createButton(TPWindow, "TP Forward", function()
    local root = character:WaitForChild("HumanoidRootPart")
    root.CFrame = root.CFrame * CFrame.new(0, 0, -10)
end)

-- Variáveis globais para armazenar a posição original e o estado do TP


createButton(TPWindow, "TP Safe", function()
    local root = character:WaitForChild("HumanoidRootPart")

    if not isFrozen then
        -- Salva a posição original antes de teleportar
        originalPosition = root.Position

        -- Teleporta para a posição segura
        root.CFrame = CFrame.new(0, -10, 0)

        -- Congela o jogador removendo a gravidade
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0) -- Mantém ele parado
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000) -- Força máxima para impedir movimento
        bodyVelocity.Parent = root

        -- Marca como congelado
        isFrozen = true
    else
        -- Volta para a posição original
        root.CFrame = CFrame.new(originalPosition)

        -- Remove a força que mantinha ele congelado
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end

        -- Reseta o estado
        isFrozen = false
    end
end)

-- 🏗️ Criar objetos 3D
createButton(objectsWindow, "Criar luz", function()
    -- Criar a parte (bloco)
    local lightBlock = Instance.new("Part")
    lightBlock.Size = Vector3.new(1, 1, 1) -- Tamanho do bloco
    lightBlock.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0) -- Posição inicial
    lightBlock.Anchored = false -- Habilita física
    lightBlock.Material = Enum.Material.Neon -- Dá um efeito brilhante
    lightBlock.BrickColor = BrickColor.new("Bright red") -- Cor do bloco
    lightBlock.Parent = game.Workspace

    -- Criar a luz dentro do bloco
    local light = Instance.new("PointLight")
    light.Parent = lightBlock
    light.Brightness = 5 -- Intensidade da luz
    light.Range = 50 -- Alcance da luz
    light.Color = Color3.fromRGB(255, 255, 255) -- Cor da luz (Amarelo)

    -- Aplicar uma força inicial para o bloco cair naturalmente
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(math.random(-10, 10), 5, math.random(-10, 10)) -- Movimento inicial aleatório
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000) -- Força máxima para empurrar o bloco
    bodyVelocity.Parent = lightBlock

    -- Remover a força após 0.1 segundos para a física normal agir
    task.delay(0.1, function()
        bodyVelocity:Destroy()
    end)
end)

createButton(objectsWindow, "Criar Cubo", function()
    local cube = Instance.new("Part", game.Workspace)
    cube.Size = Vector3.new(1, 1, 1)
    cube.Position = character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
    cube.BrickColor = BrickColor.new("Bright red")
    cube.Anchored = true
end)

createButton(objectsWindow, "Criar Esfera", function()
    local sphere = Instance.new("Part", game.Workspace)
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(5, 5, 5)
    sphere.Position = character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    sphere.BrickColor = BrickColor.new("Bright blue")
    sphere.Anchored = true
end)

-- 🎯 Targeting Line
createButton(visualWindow, "Targeting Line", function()
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(255, 0, 0)

    RunService.RenderStepped:Connect(function()
        local closestPlayer = nil
        local closestDist = math.huge  -- Começa com uma distância muito grande

        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos, onScreen = Camera:WorldToViewportPoint(otherPlayer.Character.HumanoidRootPart.Position)
                
                if onScreen then
                    -- Calcula a distância do centro da tela
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local targetScreenPos = Vector2.new(targetPos.X, targetPos.Y)
                    local dist = (screenCenter - targetScreenPos).Magnitude

                    -- Se for o mais próximo, atualiza o alvo
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = otherPlayer
                    end
                end
            end
        end

        -- Se encontrou um jogador, desenha a linha
        if closestPlayer then
            local targetPos = Camera:WorldToViewportPoint(closestPlayer.Character.HumanoidRootPart.Position)
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To = Vector2.new(targetPos.X, targetPos.Y)
            line.Visible = true
        else
            line.Visible = false  -- Esconde a linha se ninguém for encontrado
        end
    end)
end)

-- 🔍 ESP Lines
local function UpdateESP()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    if not espLines[player] then
                        espLines[player] = Drawing.new("Line")
                        espLines[player].Thickness = 2
                        espLines[player].Color = espColor
                    end
                    espLines[player].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    espLines[player].To = Vector2.new(screenPos.X, screenPos.Y)
                    espLines[player].Visible = true
                else
                    if espLines[player] then
                        espLines[player].Visible = false
                    end
                end
            end
        end
    else
        for _, line in pairs(espLines) do
            line:Remove()
        end
        espLines = {}
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- 🚀 Ativar/Desativar ESP
createButton(visualWindow, "Ativar ESP ", function()
    espEnabled = not espEnabled
end)


-- ESP Box (EM DESENVOLVIMENTO)
-- Variáveis do ESP Box
local espBoxEnabled = false
local espBoxColor = Color3.fromRGB(255, 255, 255)
local espBoxes = {}

-- Função para criar ESP Box
local function createESPBox(target)
    if espBoxes[target] then return end -- Se já existir, não cria de novo

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 0)
    box.Adornee = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = espBoxColor
    box.Parent = game.CoreGui

    espBoxes[target] = box
end

-- Função para atualizar ESP Boxes
local function updateESPBoxes()
    if not espBoxEnabled then
        for _, box in pairs(espBoxes) do
            if box then box:Destroy() end
        end
        espBoxes = {}
        return
    end

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[target] then
                createESPBox(target)
            end

            local box = espBoxes[target]
            if box then
                box.Color3 = espBoxColor
            end
        elseif espBoxes[target] then
            espBoxes[target]:Destroy()
            espBoxes[target] = nil
        end
    end
end

-- Loop para atualizar os ESP Boxes
RunService.RenderStepped:Connect(updateESPBoxes)

-- Criar botão ESP Box no visualWindow
createButton(visualWindow, "ESP box ❗(em desenvolvimento)", function()
    -- Criar janela ESP Config se não existir
    local espWindow = createWindow("ESP conf")

    -- Botões de cor
    local colors = {
        {"Vermelho", Color3.fromRGB(255, 0, 0)},
        {"Verde", Color3.fromRGB(0, 255, 0)},
        {"Azul", Color3.fromRGB(0, 0, 255)},
        {"Ciano", Color3.fromRGB(0, 255, 255)},
        {"Roxo", Color3.fromRGB(128, 0, 128)}
    }

    for _, colorData in ipairs(colors) do
        createButton(espWindow, colorData[1], function()
            espBoxColor = colorData[2]
        end)
    end

    -- Botão para ativar/desativar ESP Box
    createButton(espWindow, "Parar ESP", function()
        espBoxEnabled = false
    end)

    -- Botão para fechar a janela
    createButton(espWindow, "Fechar", function()
        espWindow:Destroy()
    end)

    -- Ativar ESP Box se não estiver ativo
    espBoxEnabled = true
end)

-----------------------------------------------------:
local function createItemIDWindow()  
    local itemWindow = createWindow("Item ID", UDim2.new(0.5, 0, 0.3, 0))  
  
    local TextBox = Instance.new("TextBox", itemWindow)  
    TextBox.Size = UDim2.new(1, -10, 0, 30)  
    TextBox.Position = UDim2.new(0, 5, 0, 40)  
    TextBox.PlaceholderText = "Digite o ID do item"  
    TextBox.Text = ""  
    TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)  
    TextBox.Font = Enum.Font.SourceSans  
    TextBox.TextSize = 18  
  
    local OkButton = Instance.new("TextButton", itemWindow)  
    OkButton.Size = UDim2.new(1, -10, 0, 30)  
    OkButton.Position = UDim2.new(0, 5, 0, 80)  
    OkButton.Text = "OK"  
    OkButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  
    OkButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
    OkButton.Font = Enum.Font.SourceSansBold  
    OkButton.TextSize = 18  
  
    OkButton.MouseButton1Click:Connect(function()  
    local itemID = tonumber(TextBox.Text) -- Converte para número  
    if itemID then  
        local remote = game.ReplicatedStorage:FindFirstChild("GiveItem") -- Nome do evento remoto  
        if remote then  
            remote:FireServer(itemID)  
            -- Notificação de sucesso  
            game:GetService("StarterGui"):SetCore("SendNotification", {  
                Title = "Sucesso!",  
                Text = "Tentando pegar o item com ID: " .. itemID,  
                Icon = "rbxassetid://6031068427", -- Substitua por um ícone, ou deixe em branco  
                Duration = 3  
            })  
        else  
            -- Notificação de erro (evento não encontrado)  
            game:GetService("StarterGui"):SetCore("SendNotification", {  
                Title = "Erro",  
                Text = "Evento remoto 'GiveItem' não encontrado.",  
                Icon = "rbxassetid://6031280882",  
                Duration = 3  
            })  
        end  
    else  
        -- Notificação de erro (ID inválido)  
        game:GetService("StarterGui"):SetCore("SendNotification", {  
            Title = "Erro",  
            Text = "Por favor, digite um número válido.",  
            Icon = "rbxassetid://6031094678",  
            Duration = 3  
        })  
    end  
end)  
end  
-- Botão para abrir a janela de pegar item por ID  
createButton(playerWindow, "Pegar Item por ID", createItemIDWindow)
-- 🔚 Encerrar Script
createButton(utilitiesWindow, "Encerrar Script", function()
    for _, gui in pairs(windows) do gui:Destroy() end
    espEnabled = false
    for _, line in pairs(espLines) do line:Remove() end
    espLines = {}
    RunService:UnbindFromRenderStep("ESPUpdate")
end)

------------------------------------------------------
