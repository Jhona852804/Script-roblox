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
    Frame.Size = UDim2.new(0, 200, 0, 350)  
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
local playerWindow = createWindow("Player", UDim2.new(0.01, 0, 0.2, 0))
local objectsWindow = createWindow("Object 3D", UDim2.new(0.20, 0, 0.2, 0))
local visualWindow = createWindow("Visual", UDim2.new(0.39,0,0.2,0))
local TPWindow = createWindow("TP manager", UDim2.new(0.58, 0, 0.2, 0))
local utilitiesWindow = createWindow("Menu", UDim2.new(0.65, 0, 0.82, 0))
local listaWindow = createWindow("Player List", UDim2.new(500, 0, 0.2, 0))

-- 🏃‍♂️ Ajustar velocidade do jogador
local isSpeedIncreased = false -- Variável para controlar o estado da velocidade

createButton(playerWindow, "Speed", function()
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

createButton(playerWindow, "Inf Jump", function()
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
    local flySpeed = 50
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
end)

-------------------------------------------------------


-- Variável local para controlar o estado da colisão
local collisionEnabled = true

-- Função para alternar a colisão do personagem
local function toggleCollision()
    collisionEnabled = not collisionEnabled
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = collisionEnabled
        end
    end
end

-- Criando o botão na janela já existente (playerWindow)
createButton(playerWindow, "Collision", function()
    toggleCollision()
end)

----------------------------------------------------
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

---------------------------------------------- _ Fim da função AFK

-- 📍 Teleporte
createButton(TPWindow, "TP Forward", function()
    local root = character:WaitForChild("HumanoidRootPart")
    root.CFrame = root.CFrame * CFrame.new(0, 0, -10)
end)
  -- Controla o estado do botão
--------------------------------------
local teleportEnabled = 0  -- Controla o estado do botão (0 = apenas desenhar, 1 = teleportar e seguir, 2 = parar de seguir)
local line = nil  -- Armazena a linha globalmente
local connection = nil  -- Armazena a conexão globalmente
local followPlayer = nil  -- Armazena o jogador que está sendo seguido
local followConnection = nil  -- Conexão de seguimento para atualizar a posição
local freezeOffset = Vector3.new(2.5, 0, 0)  -- Define o "congelamento" da posição com uma distância fixa do jogador

createButton(TPWindow, "FollowTarget", function()
    -- Primeiro clique: apenas desenha a linha
    if teleportEnabled == 0 then
        teleportEnabled = 1  -- Passa para o próximo estado (de teleportar e seguir)

        -- Cria a linha se ela ainda não existir
        if not line then
            line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = Color3.fromRGB(255, 0, 0)
        end

        -- Atualiza a linha a cada frame
        connection = RunService.RenderStepped:Connect(function()
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

    -- Segundo clique: teleportar e começar a seguir
    elseif teleportEnabled == 1 then
        teleportEnabled = 2  -- Passa para o próximo estado (parar de seguir)

        -- Remove a linha imediatamente ao teleportar
        if line then
            line:Remove()
            line = nil
        end

        -- Desconecta a atualização da linha
        if connection then
            connection:Disconnect()
            connection = nil
        end

        -- Teleporta o personagem para o jogador alvo
        local closestPlayer = nil
        local closestDist = math.huge

        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos, onScreen = Camera:WorldToViewportPoint(otherPlayer.Character.HumanoidRootPart.Position)

                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local targetScreenPos = Vector2.new(targetPos.X, targetPos.Y)
                    local dist = (screenCenter - targetScreenPos).Magnitude

                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = otherPlayer
                    end
                end
            end
        end

        -- Se encontrou o jogador, teleporta e começa a seguir
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myCharacter = player.Character
            if myCharacter and myCharacter:FindFirstChild("HumanoidRootPart") then
                -- Teleporta o personagem para o jogador
                myCharacter.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame

                -- Inicia o seguimento com um offset de posição fixo
                followPlayer = closestPlayer
                followConnection = RunService.RenderStepped:Connect(function()
                    if followPlayer and followPlayer.Character then
                        -- A posição do personagem é "congelada" em relação ao jogador, com o offset
                        local targetPos = followPlayer.Character.HumanoidRootPart.Position + freezeOffset
                        myCharacter.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                    end
                end)
            end
        end

    -- Terceiro clique: parar de seguir
    elseif teleportEnabled == 2 then
        teleportEnabled = 0  -- Volta ao estado inicial (apenas desenhar)

        -- Para de seguir
        if followConnection then
            followConnection:Disconnect()  -- Desconecta a conexão de seguir
            followPlayer = nil  -- Reseta o jogador seguido
        end
    end
end)

-------------------------------------------------------
local teleportEnabled = false
local teleportEnabled = false  -- Controla o estado do botão
local line = nil  -- Armazena a linha globalmente
local connection = nil  -- Armazena a conexão globalmente

createButton(TPWindow, "TraceTP", function()
    if not teleportEnabled then
        teleportEnabled = true

        -- Cria a linha se ela ainda não existir
        if not line then
            line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = Color3.fromRGB(255, 0, 0)
        end

        -- Atualiza a linha a cada frame
        connection = RunService.RenderStepped:Connect(function()
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

    else
        teleportEnabled = false

        -- Remove a linha imediatamente ao teleportar
        if line then
            line:Remove()
            line = nil
        end

        -- Desconecta a atualização da linha
        if connection then
            connection:Disconnect()
            connection = nil
        end

        -- Teleporta o personagem para o jogador alvo
        local closestPlayer = nil
        local closestDist = math.huge

        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos, onScreen = Camera:WorldToViewportPoint(otherPlayer.Character.HumanoidRootPart.Position)

                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local targetScreenPos = Vector2.new(targetPos.X, targetPos.Y)
                    local dist = (screenCenter - targetScreenPos).Magnitude

                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = otherPlayer
                    end
                end
            end
        end

        -- Se encontrou o jogador, teleporta
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myCharacter = player.Character
            if myCharacter and myCharacter:FindFirstChild("HumanoidRootPart") then
                myCharacter.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)


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

-- TP ALL PLAYERS
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

createButton(TPWindow, "TP all players (V)", function()
local function desyncPlayer(target)
    local rootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        rootPart.Anchored = true  -- Congela para tentar desincronizar
        wait(0.1)  -- Pequeno atraso para burlar algumas verificações
        rootPart.Anchored = false  -- Descongela, mas pode estar fora de sincronia
        rootPart.CFrame = localPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        print("✅ Desync aplicado em:", target.Name)
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        desyncPlayer(player)
    end
end
end)


-- 🏗️ Criar objetos 3D
createButton(objectsWindow, "Light", function()
    -- Criar a parte (bloco)
    local lightBlock = Instance.new("Part")
    lightBlock.Size = Vector3.new(0.5, 0.5, 0.5) -- Tamanho do bloco
    lightBlock.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0) -- Posição inicial
    lightBlock.Anchored = false -- Habilita física
    lightBlock.Material = Enum.Material.Neon -- Dá um efeito brilhante
    lightBlock.BrickColor = BrickColor.new("Bright White") -- Cor do bloco
    lightBlock.Parent = game.Workspace

    -- Criar a luz dentro do bloco
    local light = Instance.new("PointLight")
    light.Parent = lightBlock
    light.Brightness = 5 -- Intensidade da luz
    light.Range = 65 -- Alcance da luz
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

createButton(objectsWindow, "Create cube", function()
    local cube = Instance.new("Part", game.Workspace)
    cube.Size = Vector3.new(5, 5, 5)
    cube.Position = character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    cube.BrickColor = BrickColor.new("Bright red")
    cube.Anchored = true
end)

createButton(objectsWindow, "Create sphere", function()
    local sphere = Instance.new("Part", game.Workspace)
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(5, 5, 5)
    sphere.Position = character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    sphere.BrickColor = BrickColor.new("Bright blue")
    sphere.Anchored = true
end)
----------------------------

--🎯 Targeting Line
createButton(visualWindow, "Targeting Circle", function()
    if circle then  
        circle:Remove()  -- Remove o círculo existente  
        circle = nil  

        if connection then  
            connection:Disconnect()  -- Para de atualizar o círculo  
            connection = nil  
        end  
        return  -- Sai da função para evitar recriar o círculo imediatamente  
    end  

    circle = Drawing.new("Circle")  
    circle.Thickness = 2  
    circle.Color = Color3.fromRGB(255, 0, 0)
    circle.Radius = 30  -- Ajuste o raio conforme necessário
    circle.Filled = false
    connection = RunService.RenderStepped:Connect(function()
        local closestPlayer = nil  
        local closestDist = math.huge  

        for _, otherPlayer in pairs(Players:GetPlayers()) do  
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then  
                local targetPos, onScreen = Camera:WorldToViewportPoint(otherPlayer.Character.Head.Position)
                
                if onScreen then  
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)  
                    local targetScreenPos = Vector2.new(targetPos.X, targetPos.Y)  
                    local dist = (screenCenter - targetScreenPos).Magnitude  

                    if dist < closestDist then  
                        closestDist = dist  
                        closestPlayer = otherPlayer  
                    end  
                end  
            end  
        end  

        if closestPlayer then  
            local targetPos = Camera:WorldToViewportPoint(closestPlayer.Character.Head.Position)  
            circle.Position = Vector2.new(targetPos.X, targetPos.Y)  
            circle.Visible = true  
        else  
            circle.Visible = false  
        end  
    end)
end)
-- 🎯 Targeting Line
local line = nil  
local connection = nil  

createButton(visualWindow, "Targeting Line", function()  
    if line then  
        line:Remove()  -- Remove a linha existente  
        line = nil  

        if connection then  
            connection:Disconnect()  -- Para de atualizar a linha  
            connection = nil  
        end  
        return  -- Sai da função para evitar recriar a linha imediatamente  
    end  

    line = Drawing.new("Line")  
    line.Thickness = 2  
    line.Color = Color3.fromRGB(255, 0, 0)  

    connection = RunService.RenderStepped:Connect(function()  
        local closestPlayer = nil  
        local closestDist = math.huge  

        for _, otherPlayer in pairs(Players:GetPlayers()) do  
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then  
                local targetPos, onScreen = Camera:WorldToViewportPoint(otherPlayer.Character.HumanoidRootPart.Position)  
                
                if onScreen then  
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)  
                    local targetScreenPos = Vector2.new(targetPos.X, targetPos.Y)  
                    local dist = (screenCenter - targetScreenPos).Magnitude  

                    if dist < closestDist then  
                        closestDist = dist  
                        closestPlayer = otherPlayer  
                    end  
                end  
            end  
        end  

        if closestPlayer then  
            local targetPos = Camera:WorldToViewportPoint(closestPlayer.Character.HumanoidRootPart.Position)  
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)  
            line.To = Vector2.new(targetPos.X, targetPos.Y)  
            line.Visible = true  
        else  
            line.Visible = false  
        end  
    end)  
end)

-- Função para atualizar ESP Names  
local espNameColor = Color3.new(1, 1, 1) -- Cor padrão para ESP Names

-- Função para criar ou atualizar ESP Name
local function updateESPNameColor(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local label = hrp:FindFirstChild("ESPLabel")

        -- Criar o label caso não exista
        if not label then
            label = Instance.new("BillboardGui", hrp)
            label.Size = UDim2.new(0, 100, 0, 10)
            label.Adornee = hrp
            label.AlwaysOnTop = true
            label.Name = "ESPLabel"

            local frame = Instance.new("Frame", label)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1

            local textLabel = Instance.new("TextLabel", frame)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = target.Name
            textLabel.TextColor3 = espNameColor
            textLabel.BackgroundTransparency = 1
            textLabel.TextScaled = true
            textLabel.Name = "ESPText"
        end
    end
end

-- Atualiza a cor do ESP dinamicamente
RunService.RenderStepped:Connect(function()
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local label = hrp:FindFirstChild("ESPLabel")
            if label and label:FindFirstChild("Frame") and label.Frame:FindFirstChild("ESPText") then
                label.Frame.ESPText.TextColor3 = espNameColor
            end
        end
    end
end)

-- Função para remover os ESP Names
local function removeESPNames()
    for _, target in pairs(Players:GetPlayers()) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local label = hrp:FindFirstChild("ESPLabel")
            if label then
                label:Destroy()
            end
        end
    end
end

-- Função para abrir a janela de personalização de cores
local function openESPNameConfigWindow()
    local espNameConfigWindow = createWindow("ESP Names Config", UDim2.new(0.5, 0, 0.3, 0))

    -- Botões para mudar a cor do ESP Name
    createButton(espNameConfigWindow, "Branco", function() espNameColor = Color3.new(1, 1, 1) end)
    createButton(espNameConfigWindow, "Vermelho", function() espNameColor = Color3.new(1, 0, 0) end)
    createButton(espNameConfigWindow, "Azul", function() espNameColor = Color3.new(0, 0, 1) end)
    createButton(espNameConfigWindow, "Verde", function() espNameColor = Color3.new(0, 1, 0) end)
    createButton(espNameConfigWindow, "Ciano", function() espNameColor = Color3.new(0, 1, 1) end)
    createButton(espNameConfigWindow, "Roxo", function() espNameColor = Color3.new(1, 0, 1) end)

    -- Botão para parar o ESP Names
    createButton(espNameConfigWindow, "Parar ESP", function()
        removeESPNames()
        espNameConfigWindow:Destroy()
    end)

    -- Botão para fechar a janela
    createButton(espNameConfigWindow, "Fechar", function()
        espNameConfigWindow:Destroy()
    end)

    -- Criar ESP para todos os jogadores
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player then
            updateESPNameColor(target)
        end
    end
end

-- Botão para abrir a janela de personalização
createButton(visualWindow, "ESP Names", function()
    openESPNameConfigWindow()
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
createButton(visualWindow, "Esp line ", function()
    espEnabled = not espEnabled
end)




-- ESP
local espEnabled = false  
local highlightObjects = {}  
local espWindow = nil  
local rgbRunning = false  
local currentColor = Color3.fromRGB(255, 0, 0)  

-- Função para aplicar ESP em um jogador
local function applyESP(player)
    if player.Character and espEnabled then
        if highlightObjects[player] then
            highlightObjects[player]:Destroy() -- Remove o ESP antigo se já existir
        end

        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = currentColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlightObjects[player] = highlight
    end
end

-- Função para configurar ESP para jogadores novos e reaparecimentos
local function setupPlayer(player)
    if player.Character then
        applyESP(player)
    end
    player.CharacterAdded:Connect(function()
        applyESP(player)
    end)
end

-- Aplica ESP a jogadores existentes
for _, player in pairs(game.Players:GetPlayers()) do
    setupPlayer(player)
end

-- Ativa ESP para novos jogadores
game.Players.PlayerAdded:Connect(setupPlayer)

-- Função para ativar/desativar ESP e abrir a janela de personalização
createButton(visualWindow, "Chams", function()
    espEnabled = not espEnabled

    if not espEnabled then
        rgbRunning = false
    end

    if espWindow then
        espWindow.Visible = espEnabled
    else
        -- Criando a janela de personalização
        espWindow = Instance.new("Frame")
        espWindow.Size = UDim2.new(0, 300, 0, 440)
        espWindow.Position = UDim2.new(0, 1000, 0, 100)
        espWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        espWindow.Visible = espEnabled
        espWindow.Active = true  
        espWindow.Draggable = true
            
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = "Personalizar ESP"
        titleLabel.Size = UDim2.new(0, 280, 0, 30)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Parent = espWindow

        local function createColorPresetButton(name, color, yPosition)
            local button = Instance.new("TextButton")
            button.Text = name
            button.Size = UDim2.new(0, 280, 0, 30)
            button.Position = UDim2.new(0, 10, 0, yPosition)
            button.BackgroundColor3 = color
            button.Parent = espWindow

            button.MouseButton1Click:Connect(function()
                rgbRunning = false
                currentColor = color
                for _, highlight in pairs(highlightObjects) do
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                end
            end)
        end

        local colorPresets = {
            {"Vermelho", Color3.fromRGB(255, 0, 0)},
            {"Verde", Color3.fromRGB(0, 255, 0)},
            {"Azul", Color3.fromRGB(0, 0, 255)},
            {"Amarelo", Color3.fromRGB(255, 255, 0)},
            {"Rosa", Color3.fromRGB(255, 0, 255)},
            {"Ciano", Color3.fromRGB(0, 255, 255)}
        }

        for i, colorData in ipairs(colorPresets) do
            createColorPresetButton(colorData[1], colorData[2], 50 + (i - 1) * 40)
        end

        -- Efeito RGB
        local rgbEffectButton = Instance.new("TextButton")
        rgbEffectButton.Text = "Efeito RGB"
        rgbEffectButton.Size = UDim2.new(0, 280, 0, 30)
        rgbEffectButton.Position = UDim2.new(0, 10, 0, 275)
        rgbEffectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        rgbEffectButton.Parent = espWindow

        rgbEffectButton.MouseButton1Click:Connect(function()
            rgbRunning = not rgbRunning
            if rgbRunning then
                while rgbRunning do
                    for i = 0, 255, 5 do
                        if not rgbRunning then break end
                        local color = Color3.fromRGB(i, 255 - i, i)
                        for _, highlight in pairs(highlightObjects) do
                            highlight.FillColor = color
                            highlight.OutlineColor = color
                        end
                        wait(0.1)
                    end
                    for i = 255, 0, -5 do
                        if not rgbRunning then break end
                        local color = Color3.fromRGB(i, 255 - i, i)
                        for _, highlight in pairs(highlightObjects) do
                            highlight.FillColor = color
                            highlight.OutlineColor = color
                        end
                        wait(0.1)
                    end
                end
            end
        end)

        -- Botão para desativar o ESP
        local stopESPButton = Instance.new("TextButton")
        stopESPButton.Text = "stop esp"
        stopESPButton.Size = UDim2.new(0, 280, 0, 30)
        stopESPButton.Position = UDim2.new(0, 10, 0, 310)
        stopESPButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        stopESPButton.Parent = espWindow

        stopESPButton.MouseButton1Click:Connect(function()
            espEnabled = false
            rgbRunning = false
            espWindow.Visible = false

            for player, highlight in pairs(highlightObjects) do
                if highlight.Parent then
                    highlight:Destroy()
                end
            end
            highlightObjects = {}
        end)

        -- Botão para fechar a janela de personalização
        local closeButton = Instance.new("TextButton")
        closeButton.Text = "Close"
        closeButton.Size = UDim2.new(0, 280, 0, 30)
        closeButton.Position = UDim2.new(0, 10, 0, 350)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        closeButton.Parent = espWindow

        closeButton.MouseButton1Click:Connect(function()
            espWindow.Visible = false
        end)

        espWindow.Parent = visualWindow
    end

    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            applyESP(player)
        end
    else
        for player, highlight in pairs(highlightObjects) do
            if highlight.Parent then
                highlight:Destroy()
            end
        end
        highlightObjects = {}
    end
end)
---------------------------------
-- FOG
local fogEnabled = true  -- Estado do fog
local fogStart = 0
local fogEnd = 1000
local fogStartConnection, fogEndConnection  -- Conexões para congelar valores

local function toggleFog()
    local lighting = game:GetService("Lighting")

    if fogEnabled then
        -- Salva os valores atuais antes de remover o fog
        fogStart = lighting.FogStart
        fogEnd = lighting.FogEnd
        
        -- Remove o fog
        lighting.FogStart = 100000
        lighting.FogEnd = 100000
        
        -- Congela os valores para impedir mudanças externas
        fogStartConnection = lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
            lighting.FogStart = 100000
        end)
        fogEndConnection = lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
            lighting.FogEnd = 100000
        end)
    else
        -- Restaura os valores originais
        lighting.FogStart = fogStart
        lighting.FogEnd = fogEnd
        
        -- Descongela, permitindo que o jogo altere novamente
        if fogStartConnection then fogStartConnection:Disconnect() end
        if fogEndConnection then fogEndConnection:Disconnect() end
    end

    -- Notificação visual
    game:GetService("StarterGui"):SetCore("SendNotification", {  
        Title = "Fog Toggle",  
        Text = fogEnabled and "Fog ON" or "Fog OFF",  
        Icon = fogEnabled and "rbxassetid://7072721443" or "rbxassetid://7072719333",  
        Duration = 3  
    })  

    fogEnabled = not fogEnabled  -- Alterna o estado
end

-- Botão para ativar/desativar o fog
createButton(visualWindow, "Fog", toggleFog)
-----------------------------------------------------------

-- 🔚 Encerrar Script
createButton(utilitiesWindow, "Stop Script", function()
    for _, gui in pairs(windows) do gui:Destroy() end
    espEnabled = false
    for _, line in pairs(espLines) do line:Remove() end
    espLines = {}
    RunService:UnbindFromRenderStep("ESPUpdate")
end)



local lagProtectionEnabled = false -- Variável de controle

createButton(utilitiesWindow, "Anti-Lag", function()
    lagProtectionEnabled = not lagProtectionEnabled -- Alterna entre ativado e desativado

    -- Exibe a notificação com ícones diferentes dependendo do estado
    game:GetService("StarterGui"):SetCore("SendNotification", {  
        Title = "Anti-Lag",  
        Text = lagProtectionEnabled and "Ant lag ON" or "Ant lag OFF",  
        Icon = lagProtectionEnabled and "rbxassetid://6031071063" or "rbxassetid://6031071050",  -- Ícones diferentes para ON e OFF
        Duration = 3  
    })

    if lagProtectionEnabled then
        print("Anti-Lag ativado!") -- Mensagem opcional para depuração

        -- Monitorar e remover spam de objetos
        antiLagConnection = game:GetService("RunService").Stepped:Connect(function()
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Part") or obj:IsA("Sound") then
                    if obj:GetChildren() and #obj:GetChildren() > 50 then
                        obj:Destroy() -- Remove spam de objetos
                    end
                end
            end
        end)

        -- Detectar loops de lag e suavizar FPS
        fpsProtection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
            if deltaTime > 0.1 then
                warn("Possível lag detectado! Limitando FPS...")
                game:GetService("RunService").RenderStepped:Wait(0.03)
            end
        end)

        -- Monitorar consumo de memória
        memoryCheck = task.spawn(function()
            while lagProtectionEnabled do
                local memoryUsage = collectgarbage("count") / 1024
                if memoryUsage > 500 then
                    warn("Memória muito alta! Limpando objetos inúteis...")
                    collectgarbage()
                end
                wait(5)
            end
        end)

    else
        

        -- Desconectar os eventos para parar a proteção
        if antiLagConnection then antiLagConnection:Disconnect() end
        if fpsProtection then fpsProtection:Disconnect() end
        if memoryCheck then task.cancel(memoryCheck) end
    end
end)

createButton(utilitiesWindow, "ant AFK", function()
    if not antAFKEnabled then
        antAFKEnabled = true
        showNotification("ant AFK enabled")  -- Exibe a notificação que o ant AFK foi ativado
        spawn(preventAFK)  -- Começa a prevenir o AFK
    else
        antAFKEnabled = false
        showNotification("ant AFK disable")  -- Exibe a notificação que o ant AFK foi desativado
    end
end)

-----------------------------------------------------------
-- botão de item ID
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
                Title = "Sucess!",  
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
createButton(utilitiesWindow, "Get item ID", createItemIDWindow)

-----------------------------------------------------:

