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
local listaWindow = createWindow("Player List", UDim2.new(0.7, 0, 0.3, 0))

-- 🏃‍♂️ Ajustar velocidade do jogador
createButton(playerWindow, "Aumentar Velocidade", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 100 end
end)

createButton(playerWindow, "Super Pulo", function()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.JumpPower = 150 end
end)

-- 📍 Teleporte
createButton(TPWindow, "TP Forward", function()
    local root = character:WaitForChild("HumanoidRootPart")
    root.CFrame = root.CFrame * CFrame.new(0, 0, -10)
end)

createButton(TPWindow, "TP Safe", function()
    local root = character:WaitForChild("HumanoidRootPart")
    root.CFrame = CFrame.new(0, 50, -8)
end)

-- 🏗️ Criar objetos 3D
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
createButton(visualWindow, "Ativar ESP", function()
    espEnabled = not espEnabled
end)


-- Criar um ScrollingFrame para permitir a rolagem da lista de jogadores
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Parent = listaWindow
playerListFrame.Size = UDim2.new(1, 0, 1, 0)  -- Ocupa toda a janela
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- Inicialmente sem tamanho
playerListFrame.ScrollBarThickness = 10  -- Espessura da barra de rolagem
playerListFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left

-- Função para abrir a janela "Troll" com botões de ações para o player escolhido
local function openTrollWindow(targetPlayer)
    local trollWindow = createWindow("Troll - " .. targetPlayer.Name, UDim2.new(0.5, 0, 0.4, 0))

    -- Botões para ações do player...
    -- (o restante da função permanece o mesmo)
end

-- Função para atualizar a lista de jogadores
local function updatePlayerList()
    -- Limpar os botões antigos antes de atualizar
    for _, child in pairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Criar um botão para cada jogador na lista
    local buttonHeight = 50  -- Altura de cada botão
    local totalHeight = 0  -- Altura total necessária para todos os botões

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then  -- Ignorar o próprio jogador
            local button = createButton(playerListFrame, targetPlayer.Name, function()
                openTrollWindow(targetPlayer)
            end)
            button.Size = UDim2.new(1, 0, 0, buttonHeight)  -- Definir o tamanho do botão
            button.Position = UDim2.new(0, 0, 0, totalHeight)  -- Ajustar a posição do botão
            totalHeight = totalHeight + buttonHeight  -- Atualizar a altura total

            -- Atualizar o tamanho do canvas para permitir a rolagem
            playerListFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
    end
end

-- Atualiza a lista sempre que um jogador entra ou sai
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Atualiza a lista inicialmente
updatePlayerList()

-- 🔚 Encerrar Script
createButton(utilitiesWindow, "Encerrar Script", function()
    -- Garantir que a janela de utilitários seja destruída corretamente
    for _, gui in pairs(windows) do 
        gui:Destroy() 
    end
    espEnabled = false
    for _, line in pairs(espLines) do 
        line:Remove() 
    end
    espLines = {}
    RunService:UnbindFromRenderStep("ESPUpdate")
end)
