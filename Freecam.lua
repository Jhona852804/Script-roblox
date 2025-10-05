:)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Freecam variables
local freecamEnabled = false
local freecamConnection
local originalCameraType
local originalCameraSubject

-- Movement variables
local moveVector = Vector3.new(0, 0, 0)
local lookVector = Vector2.new(0, 0)
local currentVelocity = Vector3.new(0, 0, 0) -- For smooth stopping
local speed = 100
local sensitivity = 0.2
local mobileSensitivity = 0.4
local dampingFactor = 0.98 -- How quickly movement stops (0 = instant stop, 1 = never stops)

-- Desktop key bindings
local keys = {
    W = false,
    A = false,
    S = false,
    D = false
}

-- Mobile variables
local thumbstickFrame
local thumbstickKnob
local thumbstickRadius = 50
local isDragging = false
local currentTouch = nil
local dragStart = Vector2.new(0, 0)

-- Movement disabling variables
local walkingDisabled = false
local movementConnections = {}

-- Create GUI (no button, just container)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FreecamGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Create mobile thumbstick (only for mobile)
if isMobile then
    -- Movement thumbstick
    thumbstickFrame = Instance.new("Frame")
    thumbstickFrame.Name = "ThumbstickFrame"
    thumbstickFrame.Parent = screenGui
    thumbstickFrame.Size = UDim2.new(0, 120, 0, 120)
    thumbstickFrame.AnchorPoint = Vector2.new(0, 1) 
    thumbstickFrame.Position = UDim2.new(0, 30, 1, -30)
    thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    thumbstickFrame.BackgroundTransparency = 0.7
    thumbstickFrame.BorderSizePixel = 0
    thumbstickFrame.Visible = false
    thumbstickFrame.ZIndex = 5
    
    local thumbstickFrameCorner = Instance.new("UICorner")
    thumbstickFrameCorner.CornerRadius = UDim.new(1, 0)
    thumbstickFrameCorner.Parent = thumbstickFrame
    
    -- Thumbstick knob
    thumbstickKnob = Instance.new("Frame")
    thumbstickKnob.Name = "ThumbstickKnob"
    thumbstickKnob.Parent = thumbstickFrame
    thumbstickKnob.Size = UDim2.new(0, 40, 0, 40)
    thumbstickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
    thumbstickKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumbstickKnob.BackgroundTransparency = 0.3
    thumbstickKnob.BorderSizePixel = 0
    thumbstickKnob.ZIndex = 6
    
    local thumbstickKnobCorner = Instance.new("UICorner")
    thumbstickKnobCorner.CornerRadius = UDim.new(1, 0)
    thumbstickKnobCorner.Parent = thumbstickKnob
    
    thumbstickRadius = thumbstickFrame.AbsoluteSize.X/2 - 20
end

-- Function to disable character movement
local function disableMovement()
    if walkingDisabled then return end
    walkingDisabled = true
    
    -- Disable movement keys on desktop
    if not isMobile then
        local function disableAction(actionName, inputState, inputObj)
            return Enum.ContextActionResult.Sink
        end
        
        ContextActionService:BindAction("DisableMovement", disableAction, false, 
            Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)
    end
    
    -- Disable mobile touch walking
    if isMobile then
        -- Disable touch-to-move
        local function disableTouchMove(actionName, inputState, inputObj)
            return Enum.ContextActionResult.Sink
        end
        ContextActionService:BindAction("DisableTouchMove", disableTouchMove, false, Enum.UserInputType.Touch)
    end
    
    -- Stop character movement
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 0
        player.Character.Humanoid.JumpPower = 0
        player.Character.Humanoid.JumpHeight = 0
    end
end

-- Function to enable character movement
local function enableMovement()
    if not walkingDisabled then return end
    walkingDisabled = false
    
    -- Re-enable movement
    ContextActionService:UnbindAction("DisableMovement")
    ContextActionService:UnbindAction("DisableTouchMove")
    
    -- Restore character movement
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        player.Character.Humanoid.JumpPower = 50
        player.Character.Humanoid.JumpHeight = 7.2
    end
end

-- Desktop input handling
local function onKeyDown(key)
    if keys[key.KeyCode.Name] ~= nil then
        keys[key.KeyCode.Name] = true
    end
end

local function onKeyUp(key)
    if keys[key.KeyCode.Name] ~= nil then
        keys[key.KeyCode.Name] = false
    end
end

local function onMouseMoved(input)
    if freecamEnabled and not isMobile then
        lookVector = lookVector + Vector2.new(input.Delta.X, input.Delta.Y) * sensitivity
        lookVector = Vector2.new(lookVector.X, math.clamp(lookVector.Y, -80, 80))
    end
end

-- Mobile thumbstick handling
local function updateThumbstick(touchPos)
    if not thumbstickFrame or not thumbstickKnob then return end
    
    local frameCenter = Vector2.new(
        thumbstickFrame.AbsolutePosition.X + thumbstickFrame.AbsoluteSize.X/2,
        thumbstickFrame.AbsolutePosition.Y + thumbstickFrame.AbsoluteSize.Y/2
    )
    
    local delta = Vector2.new(touchPos.X - frameCenter.X, touchPos.Y - frameCenter.Y)
    local distance = math.min(delta.Magnitude, thumbstickRadius)
    local direction = Vector2.new(0, 0)
    
    if delta.Magnitude > 0 then
        direction = Vector2.new(delta.X / delta.Magnitude, delta.Y / delta.Magnitude)
    end
    
    -- Update knob position
    local knobPos = Vector2.new(frameCenter.X + direction.X * distance, frameCenter.Y + direction.Y * distance)
    thumbstickKnob.Position = UDim2.new(0, knobPos.X - thumbstickFrame.AbsolutePosition.X - 20, 
                                       0, knobPos.Y - thumbstickFrame.AbsolutePosition.Y - 20)
    
    -- Calculate movement vector
    local normalizedDistance = distance / thumbstickRadius
    moveVector = Vector3.new(direction.X * normalizedDistance, 0, -direction.Y * normalizedDistance)
end

local function resetThumbstick()
    if thumbstickKnob then
        thumbstickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
    end
    moveVector = Vector3.new(0, 0, 0)
end

-- Touch handling for camera look (anywhere on screen except thumbstick)
local function handleCameraTouch(input)
    if not freecamEnabled or not isMobile then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        -- Check if touch is not on thumbstick area
        local thumbstickBounds = false
        if thumbstickFrame and thumbstickFrame.Visible then
            local thumbPos = thumbstickFrame.AbsolutePosition
            local thumbSize = thumbstickFrame.AbsoluteSize
            thumbstickBounds = (input.Position.X >= thumbPos.X and input.Position.X <= thumbPos.X + thumbSize.X and
                               input.Position.Y >= thumbPos.Y and input.Position.Y <= thumbPos.Y + thumbSize.Y)
        end
        
        if not thumbstickBounds then
            if input.UserInputState == Enum.UserInputState.Begin then
                currentTouch = input
                dragStart = input.Position
            elseif input.UserInputState == Enum.UserInputState.Change and currentTouch == input then
                local delta = input.Position - dragStart
                lookVector = lookVector + Vector2.new(delta.X, delta.Y) * mobileSensitivity
                lookVector = Vector2.new(lookVector.X, math.clamp(lookVector.Y, -80, 80))
                dragStart = input.Position
            elseif input.UserInputState == Enum.UserInputState.End and currentTouch == input then
                currentTouch = nil
            end
        end
    end
end

-- Alternative freecam movement function with same functionality
local function updateFreecam()
    if not freecamEnabled then return end
    
    -- Initialize movement vector
    local inputMoveVector = Vector3.new()
    
    if not isMobile then
        -- Desktop controls - build movement vector based on key states (fixed direction)
        local forwardBackward = (keys.W and 1 or 0) + (keys.S and -1 or 0)  -- Fixed: W = forward (1), S = backward (-1)
        local leftRight = (keys.A and -1 or 0) + (keys.D and 1 or 0)
        inputMoveVector = Vector3.new(leftRight, 0, forwardBackward)
    else
        -- Mobile controls - use thumbstick movement vector
        inputMoveVector = moveVector
    end
    
    -- Calculate velocity based on input
    local targetVelocity = Vector3.new()
    if inputMoveVector.Magnitude > 0 then
        targetVelocity = inputMoveVector.Unit * speed
    end
    
    -- Update current velocity with smooth acceleration/deceleration
    currentVelocity = currentVelocity:Lerp(targetVelocity, inputMoveVector.Magnitude > 0 and 0.8 or dampingFactor)
    
    -- Build rotation matrix from look angles
    local yawRotation = CFrame.Angles(0, math.rad(-lookVector.X), 0)
    local pitchRotation = CFrame.Angles(math.rad(-lookVector.Y), 0, 0)
    local combinedRotation = yawRotation * pitchRotation
    
    -- Calculate new camera position
    local currentPosition = camera.CFrame.Position
    local rotatedCFrame = CFrame.new(currentPosition) * combinedRotation
    
    -- Apply movement if velocity is significant
    local newPosition = currentPosition
    if currentVelocity.Magnitude > 0.01 then
        local deltaTime = RunService.Heartbeat:Wait()
        local worldSpaceMovement = rotatedCFrame:VectorToWorldSpace(currentVelocity.Unit * currentVelocity.Magnitude * deltaTime)
        newPosition = currentPosition + worldSpaceMovement
    end
    
    -- Set final camera CFrame with faster interpolation
    local targetCFrame = CFrame.new(newPosition) * combinedRotation
    camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.3)
end

-- Enable freecam
local function enableFreecam()
    if freecamEnabled then return end
    
    freecamEnabled = true
    
    -- Hide default mobile controls
    if isMobile then
        local touchGui = playerGui:FindFirstChild("TouchGui")
        if touchGui then
            local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if touchControlFrame then
                local dynamicThumbstickFrame = touchControlFrame:FindFirstChild("DynamicThumbstickFrame")
                if dynamicThumbstickFrame then
                    dynamicThumbstickFrame.Visible = false
                end
            end
        end
    end
    
    -- Disable character movement
    disableMovement()
    
    -- Store original camera settings
    originalCameraType = camera.CameraType
    originalCameraSubject = camera.CameraSubject
    
    -- Set camera to scriptable
    camera.CameraType = Enum.CameraType.Scriptable
    
    if not isMobile then
        -- Desktop input connections
        table.insert(movementConnections, UserInputService.InputBegan:Connect(onKeyDown))
        table.insert(movementConnections, UserInputService.InputEnded:Connect(onKeyUp))
        table.insert(movementConnections, UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                onMouseMoved(input)
            end
        end))
        
        -- Lock mouse cursor
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        -- Show mobile thumbstick
        if thumbstickFrame then 
            thumbstickFrame.Visible = true 
            
            -- Connect thumbstick touch handling
            table.insert(movementConnections, thumbstickFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    updateThumbstick(input.Position)
                end
            end))
            
            table.insert(movementConnections, thumbstickFrame.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch and isDragging then
                    updateThumbstick(input.Position)
                end
            end))
            
            table.insert(movementConnections, thumbstickFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                    resetThumbstick()
                end
            end))
        end
        
        -- Connect mobile camera touch
        table.insert(movementConnections, UserInputService.InputChanged:Connect(handleCameraTouch))
        table.insert(movementConnections, UserInputService.InputBegan:Connect(handleCameraTouch))
        table.insert(movementConnections, UserInputService.InputEnded:Connect(handleCameraTouch))
    end
    
    -- Start update loop
    freecamConnection = RunService.Heartbeat:Connect(updateFreecam)
    
    print("Freecam enabled! Type /freecam to disable.")
end

-- Disable freecam
local function disableFreecam()
    if not freecamEnabled then return end
    
    freecamEnabled = false
    
    -- Show default mobile controls again
    if isMobile then
        local touchGui = playerGui:FindFirstChild("TouchGui")
        if touchGui then
            local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if touchControlFrame then
                local dynamicThumbstickFrame = touchControlFrame:FindFirstChild("DynamicThumbstickFrame")
                if dynamicThumbstickFrame then
                    dynamicThumbstickFrame.Visible = true
                end
            end
        end
    end
    
    -- Re-enable character movement
    enableMovement()
    
    -- Restore original camera settings
    camera.CameraType = originalCameraType or Enum.CameraType.Custom
    camera.CameraSubject = originalCameraSubject or (player.Character and player.Character:FindFirstChild("Humanoid"))
    
    -- Disconnect all connections
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end
    
    for _, connection in pairs(movementConnections) do
        connection:Disconnect()
    end
    movementConnections = {}
    
    -- Hide mobile controls
    if isMobile then
        if thumbstickFrame then thumbstickFrame.Visible = false end
        resetThumbstick()
    end
    
    -- Reset variables
    moveVector = Vector3.new(0, 0, 0)
    currentVelocity = Vector3.new(0, 0, 0) -- Reset velocity for smooth stopping
    isDragging = false
    currentTouch = nil
    
    -- Unlock mouse cursor
    if not isMobile then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    print("Freecam disabled! Type /freecam to enable.")
end

-- Toggle function
local function toggleFreecam()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

-- Chat command handling with TextChatService only
local lastCommandTime = 0
local commandCooldown = 0.5 -- Half second cooldown between commands

local function handleChatMessage(textChatMessage)
    -- Check if the message is from the local player
    if textChatMessage.TextSource and textChatMessage.TextSource.UserId == player.UserId then
        local currentTime = tick()
        if currentTime - lastCommandTime < commandCooldown then
            return -- Ignore if too soon after last command
        end
        
        local message = textChatMessage.Text
        if message:lower() == "/freecam" then
            lastCommandTime = currentTime
            toggleFreecam()
        end
    end
end

-- Connect to TextChatService
TextChatService.OnIncomingMessage = handleChatMessage

-- player leaving or dying
player.CharacterRemoving:Connect(function()
    if freecamEnabled then
        disableFreecam()
    end
end)

-- Disable freecam when player dies
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if freecamEnabled then
            disableFreecam()
        end
    end)
end)

-- Handle existing character
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            if freecamEnabled then
                disableFreecam()
            end
        end)
    end
end
