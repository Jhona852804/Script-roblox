-- DarkUI.lua - Library pronta para executores (carregue com loadstring)
-- Uso rápido:
-- local DarkUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/DarkUI.lua"))()
-- local ui = DarkUI.init({
--     Title = "Meu Painel",
--     Icon = "🐔",
--     Position = UDim2.new(0.5, -210, 0.5, -260),
--     Size = UDim2.new(0, 420, 0, 520),
--     ContentAreaPosition = nil,          -- opcional: UDim2 absoluto relativo ao main (se nil usa offset abaixo do title)
--     ContentAreaOffset = 8,              -- offset em pixels abaixo do title (usado se ContentAreaPosition == nil)
--     CategoriesBarHeight = 34            -- altura do bar de categorias
-- })
-- local geral = ui.addCategory("Geral")
-- ui.addButton(geral, "Test", function() print("clicou") end)
-- ui.addToggle(geral, "Ativar", false, function(s) print(s) end)

local DarkUILib = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- defaults (somente locais)
local DEFAULT = {
    BG = Color3.fromRGB(0,0,0),
    STROKE = Color3.fromRGB(30,30,30),
    CORNER = UDim.new(0,8),
    STROKE_THICK = 1,
    TITLE_HEIGHT = 48,
    DEFAULT_SIZE = UDim2.new(0,420,0,520),
    DEFAULT_POS = UDim2.new(0.5, -210, 0.5, -260)
}

-- safe call wrapper
local function safeCall(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("DarkUI callback error:", err) end
    end
end

-- API init
function DarkUILib.init(config)
    config = config or {}
    local player = Players.LocalPlayer
    if not player then error("DarkUI: jogador local não encontrado (execute no cliente).") end
    local playerGui = player:WaitForChild("PlayerGui")

    -- instance config
    local titleText = tostring(config.Title or "Painel")
    local iconText = tostring(config.Icon or "🐔")
    local mainPos = config.Position or DEFAULT.DEFAULT_POS
    local mainSize = config.Size or DEFAULT.DEFAULT_SIZE
    local contentExplicitPos = config.ContentAreaPosition -- optional: UDim2
    local contentOffset = tonumber(config.ContentAreaOffset) or 8
    local categoriesBarHeight = tonumber(config.CategoriesBarHeight) or 34

    -- storage per instance
    local categories = {} -- { {name=..., button=..., contentFrame=..., scroll=...} }
    local currentCategory = nil

    -- style helpers
    local function applyStyle(inst, cornerRadius, strokeThickness)
        cornerRadius = cornerRadius or DEFAULT.CORNER
        strokeThickness = strokeThickness or DEFAULT.STROKE_THICK
        local uc = Instance.new("UICorner")
        uc.CornerRadius = cornerRadius
        uc.Parent = inst
        local us = Instance.new("UIStroke")
        us.Color = DEFAULT.STROKE
        us.Thickness = strokeThickness
        us.Parent = inst
    end

    local function createTextButton(opts)
        local btn = Instance.new("TextButton")
        btn.Size = opts.Size or UDim2.new(1,0,0,36)
        btn.BackgroundColor3 = DEFAULT.BG
        btn.TextColor3 = opts.TextColor or Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = opts.Font or Enum.Font.SourceSans
        btn.Text = opts.Text or ""
        btn.AutoButtonColor = true
        if opts.Parent then btn.Parent = opts.Parent end
        applyStyle(btn)
        return btn
    end

    local function createTextLabel(opts)
        local lbl = Instance.new("TextLabel")
        lbl.Size = opts.Size or UDim2.new(1,0,0,30)
        lbl.BackgroundColor3 = opts.BackgroundColor or DEFAULT.BG
        lbl.TextColor3 = opts.TextColor or Color3.new(1,1,1)
        lbl.TextScaled = true
        lbl.Font = opts.Font or Enum.Font.SourceSans
        lbl.Text = opts.Text or ""
        if opts.Parent then lbl.Parent = opts.Parent end
        applyStyle(lbl)
        return lbl
    end

    local function createFrame(opts)
        local fr = Instance.new("Frame")
        fr.Size = opts.Size or UDim2.new(1,0,1,0)
        fr.BackgroundColor3 = opts.BackgroundColor or DEFAULT.BG
        fr.ClipsDescendants = opts.ClipsDescendants == nil and true or opts.ClipsDescendants
        if opts.Parent then fr.Parent = opts.Parent end
        applyStyle(fr)
        return fr
    end

    -- build ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = ("DarkUI_%d"):format(tick() * 1000):gsub("%.", "")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- main window
    local main = createFrame{ Size = mainSize, Parent = screenGui }
    main.Name = "DarkUI_Main"
    main.Position = mainPos
    main.Active = true
    main.AnchorPoint = Vector2.new(0,0)

    -- title bar
    local titleBar = createFrame{ Size = UDim2.new(1,0,0,DEFAULT.TITLE_HEIGHT), Parent = main }
    titleBar.Name = "TitleBar"
    titleBar.ClipsDescendants = false

    local titleLayout = Instance.new("UIListLayout", titleBar)
    titleLayout.FillDirection = Enum.FillDirection.Horizontal
    titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    titleLayout.Padding = UDim.new(0,8)

    local iconHolder = createFrame{ Size = UDim2.new(0,48,0,36), Parent = titleBar }
    iconHolder.BackgroundTransparency = 0
    local iconLabel = createTextLabel{ Size = UDim2.new(1,0,1,0), Text = iconText, Parent = iconHolder }
    iconLabel.BackgroundTransparency = 1

    local titleLabel = createTextLabel{ Size = UDim2.new(1,0,1,0), Text = titleText, Parent = titleBar }
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local minimizeBtn = createTextButton{ Size = UDim2.new(0,40,0,36), Text = "—", Parent = titleBar }

    -- minimized bar (secondary title)
    local minimizedBar = createFrame{ Size = UDim2.new(0,200,0,40), Parent = screenGui }
    minimizedBar.Name = "DarkUI_Minimized"
    minimizedBar.Position = UDim2.new(0.5, -100, 0.5, -240)
    minimizedBar.Visible = false
    applyStyle(minimizedBar)
    local miniLayout = Instance.new("UIListLayout", minimizedBar)
    miniLayout.FillDirection = Enum.FillDirection.Horizontal
    miniLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    miniLayout.Padding = UDim.new(0,8)
    local miniIcon = createTextLabel{ Size = UDim2.new(0,32,0,32), Text = iconText, Parent = minimizedBar }
    miniIcon.BackgroundTransparency = 1
    local miniLabel = createTextLabel{ Size = UDim2.new(1,0,1,0), Text = titleText, Parent = minimizedBar }
    miniLabel.BackgroundTransparency = 1

    -- contentArea: position calculado para evitar sobreposição
    local contentAreaPos = contentExplicitPos
    if not contentAreaPos then
        local topY = DEFAULT.TITLE_HEIGHT + contentOffset -- pixels below top of main
        contentAreaPos = UDim2.new(0, 8, 0, topY)
    end
    -- contentArea size default: main size minus top/title and margins
    local contentAreaSize = config.ContentAreaSize or UDim2.new(1, -16, 1, -( (contentExplicitPos and 0) or (DEFAULT.TITLE_HEIGHT + (contentOffset + 8)) ))

    local contentArea = createFrame{ Size = contentAreaSize, Position = contentAreaPos, Parent = main }
    contentArea.Name = "ContentArea"
    contentArea.ClipsDescendants = true

    -- apply padding inside contentArea to control spacing (so children follow relative positions)
    local contentPadding = Instance.new("UIPadding", contentArea)
    contentPadding.PaddingTop = UDim.new(0,100)
    contentPadding.PaddingLeft = UDim.new(0,8)
    contentPadding.PaddingRight = UDim.new(0,8)
    contentPadding.PaddingBottom = UDim.new(0,8)

    -- categoriesBar placed at top of contentArea (relative)
    local categoriesBar = createFrame{ Size = UDim2.new(1, -16, 0, categoriesBarHeight), Position = UDim2.new(0,8,0,8), Parent = contentArea }
    categoriesBar.Name = "CategoriesBar"
    -- ensure categoriesBar stays inside contentArea: use Automatic constraints via Clipping and explicit sizing

    local catList = Instance.new("UIListLayout", categoriesBar)
    catList.FillDirection = Enum.FillDirection.Horizontal
    catList.Padding = UDim.new(0,8)
    catList.HorizontalAlignment = Enum.HorizontalAlignment.Left

    -- pagesHolder below categoriesBar: compute position and size to avoid overlap
    local pagesHolderY = 8 + categoriesBarHeight + 8 -- top padding + catbar height + gap
    local pagesHolder = Instance.new("Frame", contentArea)
    pagesHolder.Name = "PagesHolder"
    pagesHolder.BackgroundTransparency = 1
    pagesHolder.Position = UDim2.new(0,8,0,pagesHolderY)
    pagesHolder.Size = UDim2.new(1, -16, 1, -(pagesHolderY + 8)) -- bottom gap
    pagesHolder.ClipsDescendants = true

    -- helpers to create category content frames
    local function createCategoryFrame(name)
        local frame = Instance.new("Frame")
        frame.Name = name .. "_Content"
        frame.Size = UDim2.new(1,0,1,0)
        frame.BackgroundColor3 = DEFAULT.BG
        frame.Parent = pagesHolder
        frame.Visible = false
        frame.ClipsDescendants = true
        applyStyle(frame)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Scroll"
        scroll.Size = UDim2.new(1, -16, 1, -16)
        scroll.Position = UDim2.new(0,8,0,8)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 8
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = frame

        local list = Instance.new("UIListLayout", scroll)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0,8)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local padding = Instance.new("UIPadding", scroll)
        padding.PaddingTop = UDim.new(0,6)
        padding.PaddingBottom = UDim.new(0,6)
        padding.PaddingLeft = UDim.new(0,6)
        padding.PaddingRight = UDim.new(0,6)

        return frame, scroll
    end

    local function createCategoryButton(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,96,1, -8)
        btn.AutoButtonColor = true
        btn.BackgroundColor3 = DEFAULT.BG
        btn.Text = name
        btn.TextScaled = true
        btn.Font = Enum.Font.SourceSans
        btn.Parent = categoriesBar
        applyStyle(btn)
        return btn
    end

    local function showCategory(targetName)
        for _,c in ipairs(categories) do
            if c.contentFrame then
                if c.name == targetName then
                    c.contentFrame.Visible = true
                    c.button.BackgroundColor3 = Color3.fromRGB(12,12,12)
                else
                    c.contentFrame.Visible = false
                    c.button.BackgroundColor3 = DEFAULT.BG
                end
            end
        end
        currentCategory = targetName
    end

    local function createCategoryButtonItem(containerScroll, text, callback)
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 44)
        item.BackgroundColor3 = DEFAULT.BG
        item.Parent = containerScroll
        applyStyle(item)

        local btn = Instance.new("TextButton", item)
        btn.Size = UDim2.new(1, -12, 1, -8)
        btn.Position = UDim2.new(0,6,0,4)
        btn.BackgroundColor3 = DEFAULT.BG
        btn.Text = text
        btn.TextScaled = true
        btn.Font = Enum.Font.SourceSans
        btn.AutoButtonColor = true
        applyStyle(btn)

        btn.MouseButton1Click:Connect(function()
            safeCall(callback)
        end)
    end

    local function createCategoryToggleItem(containerScroll, text, initialState, callback)
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1,0,0,44)
        item.BackgroundColor3 = DEFAULT.BG
        item.Parent = containerScroll
        applyStyle(item)

        local label = Instance.new("TextLabel", item)
        label.Size = UDim2.new(0.7, -12, 1, -8)
        label.Position = UDim2.new(0,6,0,4)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans

        local toggleBtn = Instance.new("TextButton", item)
        toggleBtn.Size = UDim2.new(0.3, -12, 1, -8)
        toggleBtn.Position = UDim2.new(0.7, 6, 0, 4)
        toggleBtn.BackgroundColor3 = DEFAULT.BG
        toggleBtn.TextScaled = true
        toggleBtn.Font = Enum.Font.SourceSans
        toggleBtn.AutoButtonColor = true
        applyStyle(toggleBtn)

        local state = not not initialState
        local function updateVisual()
            toggleBtn.Text = state and "ON" or "OFF"
        end
        updateVisual()

        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            updateVisual()
            safeCall(callback, state)
        end)
    end

    -- instance API
    local instanceAPI = {}

    function instanceAPI.addCategory(name)
        assert(type(name) == "string", "addCategory: name must be string")
        local btn = createCategoryButton(name)
        local frame, scroll = createCategoryFrame(name)
        table.insert(categories, { name = name, button = btn, contentFrame = frame, scroll = scroll })
        btn.MouseButton1Click:Connect(function() showCategory(name) end)
        if #categories == 1 then showCategory(name) end
        return frame
    end

    function instanceAPI.addButton(categoryFrame, text, callback)
        assert(categoryFrame and categoryFrame:FindFirstChild("Scroll"), "addButton: categoria inválida")
        createCategoryButtonItem(categoryFrame.Scroll, text or "Button", callback)
    end

    function instanceAPI.addToggle(categoryFrame, text, initialState, callback)
        assert(categoryFrame and categoryFrame:FindFirstChild("Scroll"), "addToggle: categoria inválida")
        createCategoryToggleItem(categoryFrame.Scroll, text or "Toggle", initialState, callback)
    end

    function instanceAPI.setTitle(newTitle)
        titleLabel.Text = tostring(newTitle or "")
        miniLabel.Text = tostring(newTitle or "")
    end

    function instanceAPI.setIcon(newIcon)
        iconLabel.Text = tostring(newIcon or "")
        miniIcon.Text = tostring(newIcon or "")
    end

    function instanceAPI.open()
        main.Visible = true
        minimizedBar.Visible = false
        screenGui.Parent = playerGui
    end

    function instanceAPI.minimize()
        main.Visible = false
        titleBar.Visible = false
        minimizedBar.Visible = true
        screenGui.Parent = playerGui
    end

    function instanceAPI.destroy()
        pcall(function() screenGui:Destroy() end)
    end

    -- dragging only via titleBar / minimizedBar
    do
        local dragging = false
        local dragInput, dragStart, startPos
        local function onDragStarted(input)
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = main.AbsolutePosition
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
        local function onDragChanged(input)
            if not dragging or not dragInput then return end
            local delta = input.Position - dragStart
            local newX = startPos.X + delta.X
            local newY = startPos.Y + delta.Y
            local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
            local clampedX = math.clamp(newX, 0, screenSize.X - main.AbsoluteSize.X)
            local clampedY = math.clamp(newY, 0, screenSize.Y - main.AbsoluteSize.Y)
            main.Position = UDim2.new(0, clampedX, 0, clampedY)
        end
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then onDragStarted(input) end
        end)
        minimizedBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then onDragStarted(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput then onDragChanged(input) end
        end)
    end

    -- minimize / restore
    minimizeBtn.MouseButton1Click:Connect(function() instanceAPI.minimize() end)
    minimizedBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then instanceAPI.open() end
    end)

    -- ensure parent & visibility
    screenGui.Parent = playerGui
    main.Visible = true
    minimizedBar.Visible = false

    -- return instance API
    return instanceAPI
end

return DarkUILib
