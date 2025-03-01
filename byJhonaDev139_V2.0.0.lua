local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local espEnabled = false
local espLines = {}
local espColor = Color3.fromRGB(255, 255, 255)  -- Cor inicial: Branco

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

-- Criando janelas para categorias
local playerWindow = createWindow("Jogador", UDim2.new(0.1, 0, 0.3, 0))
local objectsWindow = createWindow("Objetos 3D", UDim2.new(0.3, 0, 0.3, 0))
local visualWindow = createWindow("visual", UDim2.new(0.5,0,0.3,0))
local TPWindow = createWindow("TP manager", UDim2.new(0.7, 0, 0.3, 0))
local utilitiesWindow = createWindow("Utilitários", UDim2.new(0.7, 0, 0.3, 0))


-- **Funções e Botões para a Categoria Jogador**
createButton(playerWindow, "Aumentar Velocidade", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 100 -- Altera a velocidade do jogador
    end
end)
-- botão de speed
createButton(playerWindow, "Speed Edit", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Cria a janela para a configuração de velocidade
        local editSpeedWindow = createWindow("Speed config", UDim2.new(0.5, 0, 0.3, 0))

        -- Cria o campo de texto para digitar a velocidade
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0, 200, 0, 50)
        textBox.Position = UDim2.new(0.5, -100, 0.5, -50)
        textBox.PlaceholderText = "Digite a velocidade"
        textBox.Parent = editSpeedWindow

        -- Cria o botão "Ok"
        local okButton = Instance.new("TextButton")
        okButton.Size = UDim2.new(0, 100, 0, 40)
        okButton.Position = UDim2.new(0.5, -50, 0.5, 10)
        okButton.Text = "Ok"
        okButton.Parent = editSpeedWindow

        -- Cria o botão "Fechar"
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 100, 0, 40)
        closeButton.Position = UDim2.new(0.5, -50, 0.5, 60)
        closeButton.Text = "Fechar"
        closeButton.Parent = editSpeedWindow

        -- Cria o botão "Reset Speed" para parar o loop
        local resetSpeedButton = Instance.new("TextButton")
        resetSpeedButton.Size = UDim2.new(0, 100, 0, 40)
        resetSpeedButton.Position = UDim2.new(0.5, -50, 0.5, 110)
        resetSpeedButton.Text = "Reset Speed"
        resetSpeedButton.Parent = editSpeedWindow

        -- Variável para armazenar o loop de velocidade
        local speedLoop

        -- Função para aplicar e manter a velocidade
        local function setSpeed(speedInput)
            -- Cancela o loop atual, se houver
            if speedLoop then
                speedLoop:Disconnect()
            end

            -- Aplica a nova velocidade
            humanoid.WalkSpeed = speedInput

            -- Cria um novo loop para manter a velocidade
            speedLoop = game:GetService("RunService").Heartbeat:Connect(function()
                humanoid.WalkSpeed = speedInput
            end)
        end

        -- Ao clicar no botão "Ok", altera a velocidade
        okButton.MouseButton1Click:Connect(function()
            local speedInput = tonumber(textBox.Text) -- Converte o texto digitado para número
            if speedInput then
                setSpeed(speedInput) -- Aplica a nova velocidade
            else
                -- Se o valor não for válido, exibe uma mensagem (você pode adicionar um alerta aqui)
                print("Valor de velocidade inválido")
            end
        end)

        -- Ao clicar no botão "Reset Speed", reseta a velocidade para o valor padrão
        resetSpeedButton.MouseButton1Click:Connect(function()
            -- Cancela o loop de velocidade
            if speedLoop then
                speedLoop:Disconnect()
            end

            -- Reseta a velocidade para o valor normal (padrão)
            humanoid.WalkSpeed = 16
        end)

        -- Ao clicar no botão "Fechar", fecha a janela
        closeButton.MouseButton1Click:Connect(function()
            editSpeedWindow:Destroy() -- Remove a janela
        end)
    end
end)

-- Botão de super pulo
createButton(playerWindow, "Super Pulo", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = 150 -- Aumenta a altura do pulo
    end
end)
createButton(TPWindow, "TP Forward", function()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame * CFrame.new(0, 0, -10)
    end
end)
createButton(TPWindow, "TP Safe", function()  
    local root = character:FindFirstChild("HumanoidRootPart")  
    if root then  
        root.CFrame = CFrame.new(0, 50, -8)  
    end  
end)  

createButton(TPWindow, "TP Elev", function()  
    local root = character:FindFirstChild("HumanoidRootPart")  
    if root then  
        root.CFrame = CFrame.new(0, 3, -8)  
    end  
end)  

-- **Funções e Botões para a Categoria Objetos 3D**
local function createBlock(name, position)
    -- Criar o modelo do bloco
    local block = Instance.new("Part")
    block.Name = name
    block.Size = Vector3.new(1, 1, 1)  -- Tamanho do bloco
    block.Position = position  -- Posição do bloco
    block.Anchored = false  -- Desmarca "Anchored" para permitir física
    block.CanCollide = true  -- Permitir colisão com outros objetos
    block.BrickColor = BrickColor.Random()  -- Cor aleatória para o bloco
    block.Parent = game.Workspace  -- Adiciona o bloco no workspace

    -- Adicionar a física
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)  -- Definir força máxima
    bodyVelocity.Velocity = Vector3.new(0, 50, 0)  -- Velocidade inicial para fazer o bloco "subir" ou ter um impulso
    bodyVelocity.Parent = block  -- Adiciona o BodyVelocity ao bloco

    -- Adicionar a luz ao bloco
    local pointLight = Instance.new("PointLight")  -- Criar uma fonte de luz
    pointLight.Parent = block  -- Adiciona a luz ao bloco
    pointLight.Range = 50  -- Definir o alcance da luz
    pointLight.Brightness = 5  -- Definir o brilho da luz
    pointLight.Color = Color3.fromRGB(255, 255, 0)  -- Definir a cor da luz (amarelo, mas você pode escolher qualquer cor)
end

-- Função para criar o botão de adicionar bloco
createButton(objectsWindow, "Adicionar Bloco", function()
    -- Criar o bloco um pouco à frente do jogador
    local blockName = "Bloco"  -- Nome padrão para o bloco
    local playerPosition = character.HumanoidRootPart.Position  -- Posição do jogador
    local offset = Vector3.new(0, 3, 0)  -- Ajuste de posição (um pouco à frente do jogador)

    -- Criar o bloco na posição ajustada
    local blockPosition = playerPosition + offset
    createBlock(blockName, blockPosition)  -- Cria o bloco
end)

createButton(objectsWindow, "Criar Cubo", function()
    local cube = Instance.new("Part", game.Workspace)
    cube.Size = Vector3.new(5, 5, 5)
    cube.Position = character.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
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

-- função para criar o esp name

local espNameColor = Color3.new(1, 1, 1) -- Cor padrão para ESP Names  
local espName = {} -- Tabela para armazenar os labels ESP

-- Função para atualizar o ESP Name
local function updateESPNameColor(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local label = hrp:FindFirstChild("ESPLabel")

        -- Criar o label caso não exista
        if not label then
            label = Instance.new("BillboardGui", hrp)
            label.Size = UDim2.new(0, 200, 0, 50)
            label.AlwaysOnTop = true
            label.Name = "ESPLabel"

            local textLabel = Instance.new("TextLabel", label)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = target.Name
            textLabel.TextColor3 = espNameColor
            textLabel.BackgroundTransparency = 1
        else
            -- Caso o label já exista, apenas atualiza a cor
            local textLabel = label:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.TextColor3 = espNameColor
            end
        end
    end
end

-- Função para remover os ESP Names
local function removeESPNames()
    for _, target in pairs(game.Players:GetPlayers()) do
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
    createButton(espNameConfigWindow, "Branco", function() 
        espNameColor = Color3.new(1, 1, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Vermelho", function() 
        espNameColor = Color3.new(1, 0, 0)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Azul", function() 
        espNameColor = Color3.new(0, 0, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Verde", function() 
        espNameColor = Color3.new(0, 1, 0)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Ciano", function() 
        espNameColor = Color3.new(0, 1, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Roxo", function() 
        espNameColor = Color3.new(1, 0, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)

    -- Botão para fechar a janela
    createButton(espNameConfigWindow, "Fechar", function()
        espNameConfigWindow:Destroy()
    end)

    -- Botão para parar o ESP Names
    createButton(espNameConfigWindow, "Parar ESP", function()
        removeESPNames()
        espNameConfigWindow:Destroy()
    end)
end

-- Botão para abrir a janela de personalização
createButton(visualWindow, "ESP Names", function()
    openESPNameConfigWindow()
end)
end

-- função para criar Targeting Line
createButton(visualWindow, "Targeting Line", function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    -- Verifica se o personagem do jogador está carregado corretamente
    if humanoidRootPart then
        -- Cria um objeto de desenho de linha
        local line = Drawing.new("Line")
        line.Visible = true
        line.Thickness = 2 -- Define a espessura da linha
        line.Color = Color3.fromRGB(255, 0, 0) -- Define a cor da linha (vermelho)

        -- Atualiza a posição da linha para que ela siga o jogador
        game:GetService("RunService").RenderStepped:Connect(function()
            if humanoidRootPart.Parent and humanoidRootPart.Parent:FindFirstChild("HumanoidRootPart") then
                -- Converte as posições 3D para 2D na tela
                local targetPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                
                if onScreen then
                    line.From = Vector2.new(targetPosition.X, targetPosition.Y)

                    -- Percorre todos os jogadores para apontar para os outros
                    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                        if otherPlayer ~= player then -- Ignora o próprio jogador
                            local targetCharacter = otherPlayer.Character
                            local targetHumanoidRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
                            
                            if targetHumanoidRootPart then
                                -- Converte a posição do outro jogador para a tela
                                local targetScreenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetHumanoidRootPart.Position)
                                if onScreen then
                                    line.To = Vector2.new(targetScreenPosition.X, targetScreenPosition.Y)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)


-- Função para desenhar as linhas do ESP para todos os jogadores
local function DrawESP()
    -- Limpar as linhas antigas
    for _, line in pairs(espLines) do
        line:Remove()
    end
    espLines = {}

    -- Loop para desenhar as linhas para todos os jogadores
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local line = Drawing.new("Line")
            line.From = game.Workspace.CurrentCamera.CFrame.Position  -- Posição do jogador local
            line.To = rootPart.Position
            line.Color = espColor
            line.Thickness = 2
            line.Transparency = 1
            table.insert(espLines, line)
        end
    end
end

-- Função para atualizar as linhas do ESP
local function UpdateESP()
    if espEnabled then
        DrawESP()
    end
end

-- Função para criar a janela de configuração
local function CreateESPConfigWindow()
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Janela de configuração
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 250)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui

    -- Título da janela
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "ESP Config"
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    -- Botões de cor
    local colors = {"White", "Red", "Blue", "Green", "Cyan", "Purple"}
    local yOffset = 40

    for _, colorName in pairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(1, 0, 0, 30)
        colorButton.Position = UDim2.new(0, 0, 0, yOffset)
        colorButton.Text = colorName
        colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        colorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        colorButton.Parent = frame

        -- Definindo a cor quando o botão for clicado
        colorButton.MouseButton1Click:Connect(function()
            if colorName == "White" then
                espColor = Color3.fromRGB(255, 255, 255)
            elseif colorName == "Red" then
                espColor = Color3.fromRGB(255, 0, 0)
            elseif colorName == "Blue" then
                espColor = Color3.fromRGB(0, 0, 255)
            elseif colorName == "Green" then
                espColor = Color3.fromRGB(0, 255, 0)
            elseif colorName == "Cyan" then
                espColor = Color3.fromRGB(0, 255, 255)
            elseif colorName == "Purple" then
                espColor = Color3.fromRGB(255, 0, 255)
            end
            UpdateESP()
        end)

        yOffset = yOffset + 35
    end

    -- Botão de fechar a janela
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 0, 30)
    closeButton.Position = UDim2.new(0, 0, 0, yOffset)
    closeButton.Text = "Fechar"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Botão para parar o ESP
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(1, 0, 0, 30)
    stopButton.Position = UDim2.new(0, 0, 0, yOffset + 35)
    stopButton.Text = "Parar ESP"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    stopButton.Parent = frame

    stopButton.MouseButton1Click:Connect(function()
        espEnabled = false
        UpdateESP()
    end)
end

-- Função para ativar/desativar o ESP
local function ToggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        UpdateESP()
    else
        -- Limpar as linhas quando desativado
        for _, line in pairs(espLines) do
            line:Remove()
        end
        espLines = {}
    end
end

-- Criando a janela de configuração quando o jogador pressionar a tecla 'E'
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        CreateESPConfigWindow()
    end
end)

-- Comando para ativar/desativar o ESP (exemplo)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleESP()
    end
end)
end
-- **Funções e Botões para a Categoria Utilitários**

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
                Duration = 3local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local espEnabled = false
local espLines = {}
local espColor = Color3.fromRGB(255, 255, 255)  -- Cor inicial: Branco

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

-- Criando janelas para categorias
local playerWindow = createWindow("Jogador", UDim2.new(0.1, 0, 0.3, 0))
local objectsWindow = createWindow("Objetos 3D", UDim2.new(0.3, 0, 0.3, 0))
local visualWindow = createWindow("visual", UDim2.new(0.5,0,0.3,0))
local TPWindow = createWindow("TP manager", UDim2.new(0.7, 0, 0.3, 0))
local utilitiesWindow = createWindow("Utilitários", UDim2.new(0.7, 0, 0.3, 0))


-- **Funções e Botões para a Categoria Jogador**
createButton(playerWindow, "Aumentar Velocidade", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 100 -- Altera a velocidade do jogador
    end
end)
-- botão de speed
createButton(playerWindow, "Speed Edit", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Cria a janela para a configuração de velocidade
        local editSpeedWindow = createWindow("Speed config", UDim2.new(0.5, 0, 0.3, 0))

        -- Cria o campo de texto para digitar a velocidade
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0, 200, 0, 50)
        textBox.Position = UDim2.new(0.5, -100, 0.5, -50)
        textBox.PlaceholderText = "Digite a velocidade"
        textBox.Parent = editSpeedWindow

        -- Cria o botão "Ok"
        local okButton = Instance.new("TextButton")
        okButton.Size = UDim2.new(0, 100, 0, 40)
        okButton.Position = UDim2.new(0.5, -50, 0.5, 10)
        okButton.Text = "Ok"
        okButton.Parent = editSpeedWindow

        -- Cria o botão "Fechar"
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 100, 0, 40)
        closeButton.Position = UDim2.new(0.5, -50, 0.5, 60)
        closeButton.Text = "Fechar"
        closeButton.Parent = editSpeedWindow

        -- Cria o botão "Reset Speed" para parar o loop
        local resetSpeedButton = Instance.new("TextButton")
        resetSpeedButton.Size = UDim2.new(0, 100, 0, 40)
        resetSpeedButton.Position = UDim2.new(0.5, -50, 0.5, 110)
        resetSpeedButton.Text = "Reset Speed"
        resetSpeedButton.Parent = editSpeedWindow

        -- Variável para armazenar o loop de velocidade
        local speedLoop

        -- Função para aplicar e manter a velocidade
        local function setSpeed(speedInput)
            -- Cancela o loop atual, se houver
            if speedLoop then
                speedLoop:Disconnect()
            end

            -- Aplica a nova velocidade
            humanoid.WalkSpeed = speedInput

            -- Cria um novo loop para manter a velocidade
            speedLoop = game:GetService("RunService").Heartbeat:Connect(function()
                humanoid.WalkSpeed = speedInput
            end)
        end

        -- Ao clicar no botão "Ok", altera a velocidade
        okButton.MouseButton1Click:Connect(function()
            local speedInput = tonumber(textBox.Text) -- Converte o texto digitado para número
            if speedInput then
                setSpeed(speedInput) -- Aplica a nova velocidade
            else
                -- Se o valor não for válido, exibe uma mensagem (você pode adicionar um alerta aqui)
                print("Valor de velocidade inválido")
            end
        end)

        -- Ao clicar no botão "Reset Speed", reseta a velocidade para o valor padrão
        resetSpeedButton.MouseButton1Click:Connect(function()
            -- Cancela o loop de velocidade
            if speedLoop then
                speedLoop:Disconnect()
            end

            -- Reseta a velocidade para o valor normal (padrão)
            humanoid.WalkSpeed = 16
        end)

        -- Ao clicar no botão "Fechar", fecha a janela
        closeButton.MouseButton1Click:Connect(function()
            editSpeedWindow:Destroy() -- Remove a janela
        end)
    end
end)

createButton(playerWindow, "Super Pulo", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = 150 -- Aumenta a altura do pulo
    end
end)
createButton(TPWindow, "TP Forward", function()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame * CFrame.new(0, 0, -10)
    end
end)
createButton(TPWindow, "TP Safe", function()  
    local root = character:FindFirstChild("HumanoidRootPart")  
    if root then  
        root.CFrame = CFrame.new(0, 50, -8)  
    end  
end)  

createButton(TPWindow, "TP Elev", function()  
    local root = character:FindFirstChild("HumanoidRootPart")  
    if root then  
        root.CFrame = CFrame.new(0, 3, -8)  
    end  
end)  

-- **Funções e Botões para a Categoria Objetos 3D**

local function createBlock(name, position)
    -- Criar o modelo do bloco
    local block = Instance.new("Part")
    block.Name = name
    block.Size = Vector3.new(1, 1, 1)  -- Tamanho do bloco
    block.Position = position  -- Posição do bloco
    block.Anchored = false  -- Desmarca "Anchored" para permitir física
    block.CanCollide = true  -- Permitir colisão com outros objetos
    block.BrickColor = BrickColor.Random()  -- Cor aleatória para o bloco
    block.Parent = game.Workspace  -- Adiciona o bloco no workspace

    -- Adicionar a física
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)  -- Definir força máxima
    bodyVelocity.Velocity = Vector3.new(0, 50, 0)  -- Velocidade inicial para fazer o bloco "subir" ou ter um impulso
    bodyVelocity.Parent = block  -- Adiciona o BodyVelocity ao bloco

    -- Adicionar a luz ao bloco
    local pointLight = Instance.new("PointLight")  -- Criar uma fonte de luz
    pointLight.Parent = block  -- Adiciona a luz ao bloco
    pointLight.Range = 50  -- Definir o alcance da luz
    pointLight.Brightness = 5  -- Definir o brilho da luz
    pointLight.Color = Color3.fromRGB(255, 255, 0)  -- Definir a cor da luz (amarelo, mas você pode escolher qualquer cor)
end

-- Função para criar o botão de adicionar bloco
createButton(objectsWindow, "Adicionar Bloco", function()
    -- Criar o bloco um pouco à frente do jogador
    local blockName = "Bloco"  -- Nome padrão para o bloco
    local playerPosition = character.HumanoidRootPart.Position  -- Posição do jogador
    local offset = Vector3.new(0, 3, 0)  -- Ajuste de posição (um pouco à frente do jogador)

    -- Criar o bloco na posição ajustada
    local blockPosition = playerPosition + offset
    createBlock(blockName, blockPosition)  -- Cria o bloco
end)

createButton(objectsWindow, "Criar Cubo", function()
    local cube = Instance.new("Part", game.Workspace)
    cube.Size = Vector3.new(5, 5, 5)
    cube.Position = character.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
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


local espNameColor = Color3.new(1, 1, 1) -- Cor padrão para ESP Names  
local espName = {} -- Tabela para armazenar os labels ESP

-- Função para atualizar o ESP Name
local function updateESPNameColor(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local label = hrp:FindFirstChild("ESPLabel")

        -- Criar o label caso não exista
        if not label then
            label = Instance.new("BillboardGui", hrp)
            label.Size = UDim2.new(0, 200, 0, 50)
            label.AlwaysOnTop = true
            label.Name = "ESPLabel"

            local textLabel = Instance.new("TextLabel", label)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = target.Name
            textLabel.TextColor3 = espNameColor
            textLabel.BackgroundTransparency = 1
        else
            -- Caso o label já exista, apenas atualiza a cor
            local textLabel = label:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.TextColor3 = espNameColor
            end
        end
    end
end

-- Função para remover os ESP Names
local function removeESPNames()
    for _, target in pairs(game.Players:GetPlayers()) do
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
    createButton(espNameConfigWindow, "Branco", function() 
        espNameColor = Color3.new(1, 1, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Vermelho", function() 
        espNameColor = Color3.new(1, 0, 0)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Azul", function() 
        espNameColor = Color3.new(0, 0, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Verde", function() 
        espNameColor = Color3.new(0, 1, 0)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Ciano", function() 
        espNameColor = Color3.new(0, 1, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)
    createButton(espNameConfigWindow, "Roxo", function() 
        espNameColor = Color3.new(1, 0, 1)
        -- Atualizar a cor de todos os ESP Names imediatamente
        for _, target in pairs(game.Players:GetPlayers()) do
            updateESPNameColor(target)
        end
    end)

    -- Botão para fechar a janela
    createButton(espNameConfigWindow, "Fechar", function()
        espNameConfigWindow:Destroy()
    end)

    -- Botão para parar o ESP Names
    createButton(espNameConfigWindow, "Parar ESP", function()
        removeESPNames()
        espNameConfigWindow:Destroy()
    end)
end

-- Botão para abrir a janela de personalização
createButton(visualWindow, "ESP Names", function()
    openESPNameConfigWindow()
end)
end


createButton(visualWindow, "Targeting Line", function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    -- Verifica se o personagem do jogador está carregado corretamente
    if humanoidRootPart then
        -- Cria um objeto de desenho de linha
        local line = Drawing.new("Line")
        line.Visible = true
        line.Thickness = 2 -- Define a espessura da linha
        line.Color = Color3.fromRGB(255, 0, 0) -- Define a cor da linha (vermelho)

        -- Atualiza a posição da linha para que ela siga o jogador
        game:GetService("RunService").RenderStepped:Connect(function()
            if humanoidRootPart.Parent and humanoidRootPart.Parent:FindFirstChild("HumanoidRootPart") then
                -- Converte as posições 3D para 2D na tela
                local targetPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                
                if onScreen then
                    line.From = Vector2.new(targetPosition.X, targetPosition.Y)

                    -- Percorre todos os jogadores para apontar para os outros
                    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                        if otherPlayer ~= player then -- Ignora o próprio jogador
                            local targetCharacter = otherPlayer.Character
                            local targetHumanoidRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
                            
                            if targetHumanoidRootPart then
                                -- Converte a posição do outro jogador para a tela
                                local targetScreenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetHumanoidRootPart.Position)
                                if onScreen then
                                    line.To = Vector2.new(targetScreenPosition.X, targetScreenPosition.Y)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Variáveis globais


-- Função para desenhar as linhas do ESP para todos os jogadores
local function DrawESP()
    -- Limpar as linhas antigas
    for _, line in pairs(espLines) do
        line:Remove()
    end
    espLines = {}

    -- Loop para desenhar as linhas para todos os jogadores
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local line = Drawing.new("Line")
            line.From = game.Workspace.CurrentCamera.CFrame.Position  -- Posição do jogador local
            line.To = rootPart.Position
            line.Color = espColor
            line.Thickness = 2
            line.Transparency = 1
            table.insert(espLines, line)
        end
    end
end

-- Função para atualizar as linhas do ESP
local function UpdateESP()
    if espEnabled then
        DrawESP()
    end
end



    -- Botões de cor
    local colors = {"White", "Red", "Blue", "Green", "Cyan", "Purple"}
    local yOffset = 40

    for _, colorName in pairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(1, 0, 0, 30)
        colorButton.Position = UDim2.new(0, 0, 0, yOffset)
        colorButton.Text = colorName
        colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        colorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        colorButton.Parent = frame

        -- Definindo a cor quando o botão for clicado
        colorButton.MouseButton1Click:Connect(function()
            if colorName == "White" then
                espColor = Color3.fromRGB(255, 255, 255)
            elseif colorName == "Red" then
                espColor = Color3.fromRGB(255, 0, 0)
            elseif colorName == "Blue" then
                espColor = Color3.fromRGB(0, 0, 255)
            elseif colorName == "Green" then
                espColor = Color3.fromRGB(0, 255, 0)
            elseif colorName == "Cyan" then
                espColor = Color3.fromRGB(0, 255, 255)
            elseif colorName == "Purple" then
                espColor = Color3.fromRGB(255, 0, 255)
            end
            UpdateESP()
        end)
         yOffset = yOffset + 35
    end

    -- Botão de fechar a janela
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 0, 30)
    closeButton.Position = UDim2.new(0, 0, 0, yOffset)
    closeButton.Text = "Fechar"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Botão para parar o ESP
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(1, 0, 0, 30)
    stopButton.Position = UDim2.new(0, 0, 0, yOffset + 35)
    stopButton.Text = "Parar ESP"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    stopButton.Parent = frame

    stopButton.MouseButton1Click:Connect(function()
        espEnabled = false
        UpdateESP()
    end)
end

-- Função para ativar/desativar o ESP
local function ToggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        UpdateESP()
    else
        -- Limpar as linhas quando desativado
        for _, line in pairs(espLines) do
            line:Remove()
        end
        espLines = {}
    end
end

-- Criando a janela de configuração quando o jogador pressionar a tecla 'E'
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        CreateESPConfigWindow()
    end
end)

-- Comando para ativar/desativar o ESP (exemplo)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleESP()
    end
end)
end
-- **Funções e Botões para a Categoria Utilitários**

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

-- Botão para fechar o script 
createButton(utilitiesWindow, "Encerrar Script", function()
    for _, gui in pairs(windows) do
        gui:Destroy()
    end
end)
