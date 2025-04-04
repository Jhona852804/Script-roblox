-- Serviços e variáveis iniciais
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local character = player.Character or player.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")

local espEnabled = false
local espLines = {}
local espColor = Color3.fromRGB(255, 255, 255)
local ESP_Window = nil
local ESP_Ativo = false
local originalPosition = nil
local isFrozen = false
local hrp = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")





-- Cria a ScreenGui e define como pai (use game.CoreGui ou PlayerGui conforme preferir)
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
titleLabel.Text = "By JhonaDev139_YT     V3.0.0"
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

local speedToggle = false       -- false: velocidade normal; true: velocidade aumentada
local normalSpeed = 16          -- Velocidade padrão do Roblox
local boostedSpeed = 100        -- Velocidade "autá" (aumentada)
local isJumpIncreased = false -- Variável para controlar o estado do pulo

-- permite que o jogador pule no ar
local jumped = false -- Variável para detectar o pulo

local allowAirJump = false -- Controla se o jogador pode pular no ar
local collisionEnabled = true
local antAFKEnabled = false
local connection = nil  

local fogEnabled = true  -- Estado do fog
local fogStart = 0
local fogEnd = 1000
local fogStartConnection, fogEndConnection  -- Conexões para congelar valores

local teleportEnabled = 0  -- Controla o estado do botão (0 = apenas desenhar, 1 = teleportar e seguir, 2 = parar de seguir)
local line = nil  -- Armazena a linha globalmente  -- Armazena a conexão globalmente
local followConnection = nil  -- Conexão de seguimento para atualizar a posição
local followPlayer = nil  -- Armazena o jogador que está sendo seguido
local freezeOffset = Vector3.new(0,  3, 0)  -- Define o "congelamento" da posição com uma distância fixa do jogador
local chamsEnabled = false  -- Variável de controle
local lagProtectionEnabled = false -- Variável de controle
local teleportEnabled = false  -- Controla o estado do botão


-- Tabela que armazena as categorias e suas respectivas ações
local categories = {
	
    ["Player"] = {
    	
        {name = "Speed", func = function()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if not speedToggle then
                    humanoid.WalkSpeed = boostedSpeed
                    speedToggle = true
                    print("Velocidade aumentada para " .. boostedSpeed)
                else
                    humanoid.WalkSpeed = normalSpeed
                    speedToggle = false
                    print("Velocidade normal restaurada (" .. normalSpeed .. ")")
                end
            else
                warn("Humanoid não encontrado!")
            end
        end},

        {name = "Inf jump", func = function()
            allowAirJump = not allowAirJump -- Alterna o estado
            print("Pulo no ar " .. (allowAirJump and "ativado" or "desativado"))
        end},

        {name = "Super jump", func = function()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if isJumpIncreased then
                    humanoid.JumpPower = 50 -- Valor padrão do Roblox
                else
                    humanoid.JumpPower = 150 -- Super pulo
                end
                isJumpIncreased = not isJumpIncreased -- Alterna o estado
            end
        end},
        


-- Função do botão de voo
{name = "Fly", func = function()
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
end},


{name = "Colision", func = function()
    
    -- Função para alternar a colisão do personagem
    local function toggleCollision()
        collisionEnabled = not collisionEnabled
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = collisionEnabled
            end
        end
    end

    -- Alterna a colisão imediatamente quando o botão for pressionado
    toggleCollision()
    end},
    
    {name = "Ant-AFK", func = function()
    

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
end},
    },-- Fechamento da tabela "Player"
    
    ["Visual"] = {
{name = "Chams", func = function()
    chamsEnabled = not chamsEnabled  -- Alternar entre ligado/desligado

    if chamsEnabled then
        -- Ativar Chams
        for _, player in pairs(game.Players:GetChildren()) do
            if player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ChamsEffect"
                highlight.Parent = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Vermelho
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)  -- Branco
            end
        end
        
        -- Adiciona Chams para novos jogadores que entrarem
        local connection = game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if chamsEnabled then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ChamsEffect"
                    highlight.Parent = character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end)
        end)
        
        table.insert(connections, connection) -- Salva a conexão para remover depois
    else
        -- Desativar Chams (removendo os Highlights)
        for _, player in pairs(game.Players:GetChildren()) do
            if player.Character then
                for _, v in pairs(player.Character:GetChildren()) do
                    if v:IsA("Highlight") and v.Name == "ChamsEffect" then
                        v:Destroy()
                    end
                end
            end
        end
        
        -- Remove os eventos armazenados
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}  -- Limpa a tabela
    end
end},

        {name = "Tergeting Line", func = function() 
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
end},





{name = "ESP name", func = function()
    
    local espNameColor = Color3.new(1, 1, 1) -- Cor padrão branca
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")

    -- Função para criar ou atualizar ESP Name
    local function updateESPName(target)
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local label = hrp:FindFirstChild("ESPLabel")

            if not label then
                label = Instance.new("BillboardGui", hrp)
                label.Size = UDim2.new(0, 70, 0, 10)
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

    -- Função para remover todos os ESP Names
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

    -- Função principal do botão (ativa/desativa ESP)
    if espEnabled then
        -- Se já estiver ativado, desativa
        removeESPNames()
        espEnabled = false
        print("ESP Name Desativado")
    else
        -- Se estiver desativado, ativa
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player then
                updateESPName(target)
            end
        end
        espEnabled = true
        print("ESP Name Ativado")
    end
end},

{name = "Esp Line", func = function()
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

    espEnabled = not espEnabled
end},

        {name = "Targeting Circle", func = function() 
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
    circle.Radius = 10  -- Ajuste o raio conforme necessário
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
end},

{name = "Fog", func = function()
    

    local function toggleFog()
        local lighting = game:GetService("Lighting")

        -- Alterna o estado antes de aplicar as mudanças
        fogEnabled = not fogEnabled  

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

        -- Notificação visual correta
        game:GetService("StarterGui"):SetCore("SendNotification", {  
            Title = "Fog Toggle",  
            Text = fogEnabled and "Fog OFF" or "Fog ON",  
            Icon = fogEnabled and "rbxassetid://7072721443" or "rbxassetid://7072719333",  
            Duration = 3  
        })  
    end

    -- Chama a função para ativar/desativar o efeito
    toggleFog()

end},

    }, -- FECHAR A CATEGORIA
    
        ["TP tool"] = {
        	
        {name = "TP forward", func = function()
            local root = character:WaitForChild("HumanoidRootPart")
    root.CFrame = root.CFrame * CFrame.new(0, 0, -10)
    end},
    {name = "TP safe", func = function ()
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
    end},
    
            	{name = "TP Follow ", func = function()
   

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
end},
    
        {name = "Targeting TP", func = function()
        local connections = {}
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
    end},
},
    ["MENU"] = {
    	{name = "ant-lag", func = function()
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
    
        if not antAFKEnabled then
        antAFKEnabled = true
        showNotification("ant AFK enabled")  -- Exibe a notificação que o ant AFK foi ativado
        spawn(preventAFK)  -- Começa a prevenir o AFK
    else
        antAFKEnabled = false
        showNotification("ant AFK disable")  -- Exibe a notificação que o ant AFK foi desativado
    end
    end},
    
    {name = "Item ID", func = function()
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
end},
    
    
    
    },
        ["3D"] = {
        
{name = "Light Orb", func = function()
    local player = game.Players.LocalPlayer
local character = player.Character
if not character or not character:FindFirstChild("HumanoidRootPart") then return end

-- Criando a esfera
local orb = Instance.new("Part")
orb.Shape = Enum.PartType.Ball
orb.Size = Vector3.new(0.2, 0.2, 0.2)
orb.Position = character.HumanoidRootPart.Position + Vector3.new(0, 5, 5)
orb.Anchored = false
orb.Material = Enum.Material.Neon
orb.BrickColor = BrickColor.new("Bright yellow")
orb.Parent = game.Workspace

-- Criando o brilho na esfera
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 1
highlight.Parent = orb

-- Criando a luz
local light = Instance.new("PointLight")
light.Parent = orb
light.Brightness = 2
light.Range = 10
light.Color = Color3.fromRGB(255, 255, 0)

-- Criando a GUI para o texto
local billboardGui = Instance.new("BillboardGui")
billboardGui.Size = UDim2.new(0, 200, 0, 50)
billboardGui.StudsOffset = Vector3.new(0, 1, 0)
billboardGui.AlwaysOnTop = true
billboardGui.Parent = orb

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.Parent = billboardGui

-- Criando o efeito de flutuação
local floatOffset = 0
local floatDirection = 1

-- Monitorando a posição do jogador e ajustando a luz
game:GetService("RunService").RenderStepped:Connect(function()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local orbPos = orb.Position
    local playerPos = character.HumanoidRootPart.Position
    local distance = (orbPos - playerPos).Magnitude

    -- Se estiver longe demais, começa a seguir
    if distance > 20 then
        local direction = (playerPos - orbPos).unit
        orb.Position = orb.Position + direction * 0.5
    end

    -- Efeito de flutuação
    floatOffset = floatOffset + (floatDirection * 0.01)
    if floatOffset > 0.3 or floatOffset < -0.3 then
        floatDirection = -floatDirection
    end
    orb.Position = Vector3.new(orb.Position.X, playerPos.Y + 5 + math.sin(tick() * 2) * 0.3, orb.Position.Z)

    -- Ajustando a luz dependendo da iluminação ambiente
    local lightLevel = game.Lighting.Ambient
    if lightLevel.r + lightLevel.g + lightLevel.b < 0.1 then -- Somando os canais RGB
        light.Brightness = 10
        light.Color = Color3.fromRGB(255, 255, 255)
        textLabel.Text = "A escuridão nos faz enxergar além..."
    else
        light.Brightness = 2
        light.Color = Color3.fromRGB(255, 255, 0)
        textLabel.Text = ""
    end

    -- Mudança de mensagem baseada na situação
    local playersNear = 0
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local otherPos = otherPlayer.Character.HumanoidRootPart.Position
            if (playerPos - otherPos).Magnitude < 15 then
                playersNear = playersNear + 1
            end
        end
    end

    if playersNear >= 5 then
        textLabel.Text = "Rodeado por muitos, mas será que estou realmente acompanhado?"
    end

    -- Verifica a vida do jogador
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health / humanoid.MaxHealth <= 0.3 then
        textLabel.Text = "Mesmo nas sombras da dor, a luz ainda brilha..."
    end
end)
end},






        {name = "Orbit Light", func = function()
        
    
    if not hrp then return end -- Evita erros caso o HRP não exista

    -- Criar o bloco de luz
    local lightBlock = Instance.new("Part")
    lightBlock.Size = Vector3.new(0.2,0.2,0.2) -- Tamanho do bloco
    lightBlock.Anchored = true -- Precisa estar ancorado para orbitar corretamente
    lightBlock.Material = Enum.Material.Neon -- Dá um efeito brilhante
    lightBlock.BrickColor = BrickColor.new("Bright white") -- Cor do bloco
    lightBlock.Parent = game.Workspace

    -- Criar a luz dentro do bloco
    local light = Instance.new("PointLight")
    light.Parent = lightBlock
    light.Brightness = 2.5 -- Intensidade da luz
    light.Range = 50 -- Alcance da luz
    light.Color = Color3.fromRGB(255, 255, 255) -- Cor da luz

    -- Variáveis para órbita
    local radius = 3 -- Distância do bloco em relação ao personagem
    local speed = 2 -- Velocidade da órbita
    local angle = 0

    -- Atualizar a posição do bloco a cada frame
    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        if hrp.Parent then
            angle = angle + speed * deltaTime -- Atualiza o ângulo ao longo do tempo
            local offsetX = math.cos(angle) * radius
            local offsetZ = math.sin(angle) * radius
            lightBlock.Position = hrp.Position + Vector3.new(offsetX, 0, offsetZ) -- Mantém o bloco acima do personagem
        else
            -- Se o personagem morrer ou desaparecer, remove o bloco e desconecta
            connection:Disconnect()
            lightBlock:Destroy()
        end
    end)
end},

        {name = "Light", func = function()
    local lightBlock = Instance.new("Part")
    lightBlock.Size = Vector3.new(0.2,0.2,0.2) -- Tamanho do bloco
    lightBlock.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0) -- Posição inicial
    lightBlock.Anchored = false -- Habilita física
    lightBlock.Material = Enum.Material.Neon -- Dá um efeito brilhante
    lightBlock.BrickColor = BrickColor.new("Bright white") -- Cor do bloco
    lightBlock.Parent = game.Workspace

    -- Criar a luz dentro do bloco
    local light = Instance.new("PointLight")
    light.Parent = lightBlock
    light.Brightness = 5 -- Intensidade da luz
    light.Range = 50 -- Alcance da luz
    light.Color = Color3.fromRGB(255, 255, 255) -- Cor da luz

    -- Aplicar uma força inicial para o bloco cair naturalmente
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(math.random(-10, 10), 5, math.random(-10, 10)) -- Movimento inicial aleatório
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000) -- Força máxima para empurrar o bloco
    bodyVelocity.Parent = lightBlock

    -- Remover a força após 0.1 segundos para a física normal agir
    task.delay(0.1, function()
        bodyVelocity:Destroy()
    end)
    end},
    
    {name = "Cubo", func = function()
    local cube = Instance.new("Part", game.Workspace)
    cube.Size = Vector3.new(5, 5, 5)
    cube.Position = character.HumanoidRootPart.Position + Vector3.new(0, 0, -5)
    cube.BrickColor = BrickColor.new("Bright white")
    cube.Anchored = true
    end},
    {name = "sphere", func = function()
    local sphere = Instance.new("Part", game.Workspace)
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(5, 5, 5)
    sphere.Position = character.HumanoidRootPart.Position + Vector3.new(0, 0, -5)
    sphere.BrickColor = BrickColor.new("Bright blue")
    sphere.Anchored = true
    end},
        
},

}
    

-- Evento para permitir o pulo no ar (fora da tabela do botão)
game:GetService("UserInputService").JumpRequest:Connect(function()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and allowAirJump then
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Permite pular no ar
            end
        end
    end
end)



-- Função para limpar os botões de ação existentes no painel direito
local function clearRightPanel()
    for _, child in ipairs(rightPanel:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

-- Função para carregar as ações de uma categoria no painel direito
local function loadActions(categoryName)
    clearRightPanel()
    local actions = categories[categoryName]
    if actions then
        for _, action in ipairs(actions) do
            createButton(rightPanel, action.name, action.func)
        end
    end
end

-- Função para criar os botões de categorias no painel esquerdo
local function loadCategories()
    for categoryName, _ in pairs(categories) do
        createButton(leftPanel, categoryName, function()
            loadActions(categoryName)
        end)
    end
end

-- Inicializa os botões de categorias e carrega uma categoria padrão (a primeira encontrada)
loadCategories()
for categoryName, _ in pairs(categories) do
    loadActions(categoryName)
    break
end
