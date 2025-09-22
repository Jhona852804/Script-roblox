-- ProceduralBackroomsServer_Fix.lua
-- COLOQUE ESTE ARQUIVO EM ServerScriptService (Script)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")


print("[Backrooms] Server script starting...")


-- ====== CONFIG ======
local CELL_SIZE = 55
local VISIBILITY_RADIUS = 2
local MIN_ROOM = Vector3.new(20,8,20)
local MAX_ROOM = Vector3.new(40,12,36)
local WALL_THICKNESS = 1
local DOOR_WIDTH_RANGE = {4,8}
local DOOR_HEIGHT = 6


local TILE_SIZE = 4
local PIT_CHANCE = 0.18
local PIT_MAX_TILE_W = 6
local PIT_MAX_TILE_H = 6
local PIT_MAX_DEPTH = 20


local LIGHT_RANGE = 28
local LIGHT_BRIGHTNESS = 2.4
local FLICKER_ENABLED = true
local FLICKER_CHANCE = 0.12
local FLICKER_INTERVAL = {0.05, 0.18}


local REMOTE_NAME = "Backrooms_PitEvent"


-- ====== UTIL ======
local function clamp(v, a, b) if v < a then return a end if v > b then return b end return v end
local function lerp(a,b,t) return a + (b-a) * t end


math.randomseed(tick() + os.time())


-- ROOT folder
local ROOT = Workspace:FindFirstChild("ProceduralBackrooms")
if not ROOT then
    ROOT = Instance.new("Folder")
    ROOT.Name = "ProceduralBackrooms"
    ROOT.Parent = Workspace
end


-- Função para criar piso em uma posição
local function createFloorTile(position, size)
    local tile = Instance.new("Part")
    tile.Size = size
    tile.Anchored = true
    tile.CanCollide = true
    tile.Position = position
    tile.Material = Enum.Material.Concrete
    tile.Color = Color3.fromRGB(80, 80, 80)
    tile.Parent = ROOT
end


-- Exemplo: gerar chão para cada célula (sem tampar buracos)
for _, cell in ipairs(generatedCells) do
    if not cell.isPit then
        createFloorTile(
            Vector3.new(cell.x, 0, cell.z), -- altura alinhada com o mapa
            Vector3.new(50, 1, 50) -- mesmo tamanho da célula
        )
    end
end

-- RemoteEvent
local pitEvent = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not pitEvent then
    pitEvent = Instance.new("RemoteEvent")
    pitEvent.Name = REMOTE_NAME
    pitEvent.Parent = ReplicatedStorage
    print("[Backrooms] RemoteEvent created in ReplicatedStorage:", REMOTE_NAME)
end


-- storage
local rooms = {} -- key -> meta
local pits = {}  -- list of pits for detection


local function coordKey(x,y) return tostring(x)..","..tostring(y) end
local function getGridFromPosition(pos)
    local gx = math.floor((pos.X + CELL_SIZE/2)/CELL_SIZE)
    local gy = math.floor((pos.Z + CELL_SIZE/2)/CELL_SIZE)
    return gx, gy
end
local function randomRoomSize()
    return Vector3.new(
        math.random(MIN_ROOM.X, MAX_ROOM.X),
        math.random(MIN_ROOM.Y, MAX_ROOM.Y),
        math.random(MIN_ROOM.Z, MAX_ROOM.Z)
    )
end


local function makeWallPart(parent, size, pos, material, name)
    local p = Instance.new("Part")
    p.Name = name or "Wall"
    p.Anchored = true
    p.CanCollide = true
    p.Size = size
    p.Position = pos
    p.Material = material or Enum.Material.SmoothPlastic
    p.BrickColor = BrickColor.new("Medium stone grey")
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end


-- flat neon plate light
local function attachFlatCeilingLight(parent, center, size)
    local padding = 2
    local maxX = math.max(0, size.X/2 - padding)
    local maxZ = math.max(0, size.Z/2 - padding)
    local offsetX = (math.random()*2 - 1) * maxX * 0.35
    local offsetZ = (math.random()*2 - 1) * maxZ * 0.35


    local plateW = math.clamp and math.clamp(math.random(6, 14), 6, size.X - 4) or clamp(math.random(6,14),6,size.X-4)
    local plateL = math.clamp and math.clamp(math.random(6, 14), 6, size.Z - 4) or clamp(math.random(6,14),6,size.Z-4)
    local plateThickness = 0.4


    local plate = Instance.new("Part")
    plate.Name = "CeilingLightPlate"
    plate.Size = Vector3.new(plateW, plateThickness, plateL)
    plate.Anchored = true
    plate.CanCollide = false
    plate.Material = Enum.Material.Neon
    plate.BrickColor = BrickColor.new("New Yeller")
    plate.Position = center + Vector3.new(offsetX, size.Y/2 - (plateThickness/2 + 0.5), offsetZ)
    plate.Parent = parent


    local pl = Instance.new("PointLight")
    pl.Parent = plate
    pl.Color = Color3.fromRGB(255,240,180)
    pl.Range = LIGHT_RANGE
    pl.Brightness = LIGHT_BRIGHTNESS


    if FLICKER_ENABLED then
        coroutine.wrap(function()
            while plate and plate.Parent do
                if math.random() < FLICKER_CHANCE then
                    local orig = pl.Brightness
                    pl.Brightness = math.max(0.25, orig * 0.25)
                    wait(math.random() * (FLICKER_INTERVAL[2]-FLICKER_INTERVAL[1]) + FLICKER_INTERVAL[1])
                    if pl and pl.Parent then pl.Brightness = orig end
                end
                wait(0.3 + math.random()*0.8)
            end
        end)()
    end
    return plate
end


-- tiled floor
local function createTiledFloor(folder, center, size, holeTiles)
    local tiles = {}
    local tilesX = math.max(1, math.floor(size.X / TILE_SIZE))
    local tilesZ = math.max(1, math.floor(size.Z / TILE_SIZE))
    local realTileW = size.X / tilesX
    local realTileL = size.Z / tilesZ


    local startX = center.X - size.X/2 + realTileW/2
    local startZ = center.Z - size.Z/2 + realTileL/2
    local y = center.Y - size.Y/2 + (WALL_THICKNESS/2)


    for i=1,tilesX do
        for j=1,tilesZ do
            local key = tostring(i)..","..tostring(j)
            if not (holeTiles and holeTiles[key]) then
                local pos = Vector3.new(startX + (i-1)*realTileW, y, startZ + (j-1)*realTileL)
                local p = Instance.new("Part")
                p.Name = "FloorTile_"..i.."_"..j
                p.Size = Vector3.new(realTileW, WALL_THICKNESS, realTileL)
                p.Anchored = true
                p.CanCollide = true
                p.Position = pos
                p.Material = Enum.Material.Concrete
                p.BrickColor = BrickColor.new("Medium stone grey")
                p.Parent = folder
                tiles[key] = p
            end
        end
    end
    return tiles, tilesX, tilesZ
end


-- create pit and layers; returns holeTiles and bounds
local function createPitInRoom(folder, center, size)
    local tilesX = math.max(1, math.floor(size.X / TILE_SIZE))
    local tilesZ = math.max(1, math.floor(size.Z / TILE_SIZE))
    if tilesX < 3 or tilesZ < 3 then return nil end


    local pitW_tiles = math.random(2, math.min(PIT_MAX_TILE_W, tilesX-1))
    local pitH_tiles = math.random(2, math.min(PIT_MAX_TILE_H, tilesZ-1))
    local start_i = math.random(2, tilesX - pitW_tiles)
    local start_j = math.random(2, tilesZ - pitH_tiles)


    local holeTiles = {}
    for i = start_i, start_i + pitW_tiles - 1 do
        for j = start_j, start_j + pitH_tiles - 1 do
            holeTiles[tostring(i)..","..tostring(j)] = true
        end
    end


    local depth = math.random(8, PIT_MAX_DEPTH)
    local topY = center.Y - size.Y/2
    local bottomY = topY - depth


    local layers = math.max(2, math.floor(depth / 4))
    local layerSizeDecay = 0.78
    local basePlateSizeX = pitW_tiles * TILE_SIZE * 0.9
    local basePlateSizeZ = pitH_tiles * TILE_SIZE * 0.9


    local tileWidth = size.X / tilesX
    local tileLength = size.Z / tilesZ
    local holeCenterX = center.X - size.X/2 + (start_i - 1) * tileWidth + (pitW_tiles * tileWidth)/2
    local holeCenterZ = center.Z - size.Z/2 + (start_j - 1) * tileLength + (pitH_tiles * tileLength)/2


    for layer = 1, layers do
        local pct = layer / layers
        local lx = basePlateSizeX * (1 - (1 - layerSizeDecay) * pct)
        local lz = basePlateSizeZ * (1 - (1 - layerSizeDecay) * pct)
        local ly = topY - (depth * (pct * 0.95)) - 2
        local plate = Instance.new("Part")
        plate.Name = "PitLayer_"..layer
        plate.Size = Vector3.new(lx, 0.6, lz)
        plate.Anchored = true
        plate.CanCollide = true
        plate.Position = Vector3.new(holeCenterX, ly - (0.6/2), holeCenterZ)
        plate.Material = Enum.Material.WoodPlanks
        plate.BrickColor = BrickColor.new("Reddish brown")
        plate.Parent = folder


        if math.random() < 0.6 then
            local box = Instance.new("Part")
            box.Name = "PitObject_"..layer
            box.Size = Vector3.new(clamp(lx*0.25,1,6), math.random(2,5), clamp(lz*0.25,1,6))
            box.Anchored = true
            box.CanCollide = true
            box.Position = plate.Position + Vector3.new((math.random()-0.5)*(lx*0.4), box.Size.Y/2 + 0.3, (math.random()-0.5)*(lz*0.4))
            box.Material = Enum.Material.Metal
            box.BrickColor = BrickColor.new("Dark stone grey")
            box.Parent = folder
        end


        local plPart = Instance.new("Part")
        plPart.Name = "PitLightPart_"..layer
        plPart.Size = Vector3.new(1,1,1)
        plPart.Anchored = true
        plPart.CanCollide = false
        plPart.Transparency = 1
        plPart.Position = plate.Position + Vector3.new(0, 1.2, 0)
        plPart.Parent = folder


        local pl = Instance.new("PointLight")
        pl.Parent = plPart
        pl.Color = Color3.fromRGB(200,180,150)
        pl.Range = math.max(6, LIGHT_RANGE * (1 - pct*0.9))
        pl.Brightness = math.max(0.12, LIGHT_BRIGHTNESS * (1 - pct*0.9))
    end


    local holeMinX = holeCenterX - (pitW_tiles * tileWidth)/2
    local holeMaxX = holeMinX + pitW_tiles * tileWidth
    local holeMinZ = holeCenterZ - (pitH_tiles * tileLength)/2
    local holeMaxZ = holeMinZ + pitH_tiles * tileLength


    return holeTiles, holeMinX, holeMaxX, holeMinZ, holeMaxZ, topY, bottomY, depth
end


-- cria a sala
local function createRoomAtGrid(x,y)
    local key = coordKey(x,y)
    if rooms[key] then return rooms[key] end


    local size = randomRoomSize()
    local center = Vector3.new(x * CELL_SIZE, size.Y/2, y * CELL_SIZE)
    local folder = Instance.new("Folder")
    folder.Name = "Room_" .. key
    folder.Parent = ROOT

    -- ceiling (placeholder)
    makeWallPart(folder, Vector3.new(size.X, WALL_THICKNESS, size.Z), center + Vector3.new(0, size.Y/2 - WALL_THICKNESS/2, 0), Enum.Material.Concrete, "Ceiling")


    local doors = {N=false, S=false, E=false, W=false}
    local neighbors = {
        N = coordKey(x, y+1),
        S = coordKey(x, y-1),
        E = coordKey(x+1, y),
        W = coordKey(x-1, y)
    }
    for dir, nkey in pairs(neighbors) do
        if rooms[nkey] then
            doors[dir] = true
            local other = rooms[nkey]
            if other then
                if dir=="N" then other.doors.S = true end
                if dir=="S" then other.doors.N = true end
                if dir=="E" then other.doors.W = true end
                if dir=="W" then other.doors.E = true end
            end
        end
    end


    -- pit?
    local holeTiles, pitMeta = nil, nil
    if math.random() < PIT_CHANCE then
        holeTiles, hx1, hx2, hz1, hz2, topY, bottomY, depth = createPitInRoom(folder, center, size)
        if hx1 then
            pitMeta = {minX = hx1, maxX = hx2, minZ = hz1, maxZ = hz2, topY = topY, bottomY = bottomY, depth = depth}
            table.insert(pits, pitMeta)
            print("[Backrooms] Pit created at:", key, "depth:", depth)
        end
    end


    -- tiled floor
    createTiledFloor(folder, center, size, holeTiles)


    -- walls with doors (same approach simplified)
    local halfGap = 0.5
    local function createWallWithOptionalDoor(side)
        local door = doors[side]
        local doorWidth = door and math.random(DOOR_WIDTH_RANGE[1], DOOR_WIDTH_RANGE[2]) or 0
        local wallHeight = size.Y
        if side == "N" or side == "S" then
            local zOffset = (side=="N") and size.Z/2 or -size.Z/2
            if door then
                local leftWidth = (size.X - doorWidth) / 2
                makeWallPart(folder, Vector3.new(leftWidth, wallHeight, WALL_THICKNESS), center + Vector3.new(- (doorWidth/2 + leftWidth/2), 0, zOffset + (halfGap * (side=="N" and 1 or -1))), Enum.Material.Plastic, side .. "_Wall_Left")
                makeWallPart(folder, Vector3.new(leftWidth, wallHeight, WALL_THICKNESS), center + Vector3.new((doorWidth/2 + leftWidth/2), 0, zOffset + (halfGap * (side=="N" and 1 or -1))), Enum.Material.Plastic, side .. "_Wall_Right")
            else
                makeWallPart(folder, Vector3.new(size.X, wallHeight, WALL_THICKNESS), center + Vector3.new(0,0, zOffset + (halfGap * (side=="N" and 1 or -1))), Enum.Material.Plastic, side .. "_Wall_Full")
            end
        else
            local xOffset = (side=="E") and size.X/2 or -size.X/2
            if door then
                local leftWidth = (size.Z - doorWidth) / 2
                makeWallPart(folder, Vector3.new(WALL_THICKNESS, wallHeight, leftWidth), center + Vector3.new(xOffset + (halfGap * (side=="E" and 1 or -1)), 0, - (doorWidth/2 + leftWidth/2)), Enum.Material.Plastic, side .. "_Wall_Left")
                makeWallPart(folder, Vector3.new(WALL_THICKNESS, wallHeight, leftWidth), center + Vector3.new(xOffset + (halfGap * (side=="E" and 1 or -1)), 0, (doorWidth/2 + leftWidth/2)), Enum.Material.Plastic, side .. "_Wall_Right")
            else
                makeWallPart(folder, Vector3.new(WALL_THICKNESS, wallHeight, size.Z), center + Vector3.new(xOffset + (halfGap * (side=="E" and 1 or -1)), 0, 0), Enum.Material.Plastic, side .. "_Wall_Full")
            end
        end
    end


    createWallWithOptionalDoor("N")
    createWallWithOptionalDoor("S")
    createWallWithOptionalDoor("E")
    createWallWithOptionalDoor("W")


    -- add 1-2 ceiling lights
    local lightCount = (math.random() < 0.22) and 2 or 1
    for i=1,lightCount do
        attachFlatCeilingLight(folder, center, size)
    end


    -- register
    rooms[key] = {folder = folder, gridX = x, gridY = y, center = center, size = size, doors = doors, pit = pitMeta}
    print("[Backrooms] Created room at", key, "center:", center)
    return rooms[key]
end


-- ensure neighborhood
local function ensureNeighborhood(cx, cy)
    createRoomAtGrid(cx, cy)
    local dirs = {{dx=0,dy=1},{dx=0,dy=-1},{dx=1,dy=0},{dx=-1,dy=0}}
    for _,d in ipairs(dirs) do
        createRoomAtGrid(cx + d.dx, cy + d.dy)
    end
end


-- generate around player
local function generateAroundPlayer(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local gx, gy = getGridFromPosition(hrp.Position)
    for dx = -VISIBILITY_RADIUS, VISIBILITY_RADIUS do
        for dy = -VISIBILITY_RADIUS, VISIBILITY_RADIUS do
            local dist = math.abs(dx) + math.abs(dy)
            if dist <= VISIBILITY_RADIUS then
                ensureNeighborhood(gx + dx, gy + dy)
            end
        end
    end
end


-- helper: check if point is inside pit
local function pointInPit(px, py, pz, pit)
    if not pit then return false end
    if px >= pit.minX and px <= pit.maxX and pz >= pit.minZ and pz <= pit.maxZ and py <= pit.topY and py >= pit.bottomY then
        return true
    end
    return false
end


-- track player pit state
local playerPitState = {}


-- heartbeat generation + pit detection (lightweight)
local tickCounter = 0
RunService.Heartbeat:Connect(function(dt)
    tickCounter = tickCounter + dt
    -- generate periodically (once por 0.3s)
    if tickCounter >= 0.3 then
        for _,player in ipairs(Players:GetPlayers()) do
            pcall(function() generateAroundPlayer(player) end)
        end
        tickCounter = 0
    end


    -- pit detection (less frequent can't be too heavy but ok)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local px, py, pz = hrp.Position.X, hrp.Position.Y, hrp.Position.Z
            local inAny, pitIndex, pitDepthPerc = false, nil, 0
            for i, pit in ipairs(pits) do
                if pointInPit(px,py,pz,pit) then
                    inAny = true
                    pitIndex = i
                    local denom = pit.topY - pit.bottomY
                    local perc = 0
                    if denom ~= 0 then perc = clamp((pit.topY - py) / denom, 0, 1) end
                    pitDepthPerc = perc
                    break
                end
            end


            local prev = playerPitState[player.UserId]
            if inAny and prev ~= pitIndex then
                playerPitState[player.UserId] = pitIndex
                pitEvent:FireClient(player, {action="enter", depth=pitDepthPerc})
            elseif inAny and prev == pitIndex then
                pitEvent:FireClient(player, {action="update", depth=pitDepthPerc})
            elseif (not inAny) and prev ~= nil then
                playerPitState[player.UserId] = nil
                pitEvent:FireClient(player, {action="exit"})
            end
        end
    end
end)


-- initial create at origin so you can see something immediately in Studio
createRoomAtGrid(0,0)
print("[Backrooms] Initial room created at 0,0")
