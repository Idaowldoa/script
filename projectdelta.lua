repeat task.wait() until game:IsLoaded() or game:GetService("Players").LocalPlayer.Character and workspace.CurrentCamera
if not executed then getgenv().executed = true else print('Already Executed') return end

getgenv().config = {
    -- Target
    Showtargetstatus = false,
    Showlinetotarget = {
        Enable = false,
        Color = Color3.fromRGB(255,0,0)
    },

    --PVPSetting
    PVPSetting = {
        ShowFOV = false,
        FOV = 120,
        Color = Color3.fromRGB(255,255,255),
        SilentAim = {
            Enable = false,
            Players = false,
            NPCs = false,
            Part = "Head",  -- Head , UpperTorse , etc..
        },
    },

    -- ESP
    ESP = {

        -- Players ESP
        Enable = false,
        Distance = 1000,
        Info = {
            Name = false,
            Distance = false
        },
        Box = {
            Enable = false,
            BoxStyle = "Cornor", -- Cornor , Full , 3D
            Color = Color3.fromRGB(255,255,255)
        },
        Tracer = {
            Enable = false,
            TracerOrigin = "Bottom", -- Bottom , Top , Mouse , Center
            Color = Color3.fromRGB(255,255,255)
        },
        Skeleton = {
            Enable = false,
            Color = Color3.fromRGB(255,255,255)
        },
        Refresh = 1/144,

        -- NPC Esp 
        NPC = {
            Enable = false,
            Name = {
                Enable = false,
                Color = Color3.fromRGB(204,0,102)
            },
            Chams = {
                Enable = false,
                Color = Color3.fromRGB(204,0,102)
            }
        },
        -- Other ESP
        OtherESP = {
            Exit = {
                Enable = false,
                Color = Color3.fromRGB(0, 255, 255)
            },
            Corpse = {
                Enable = false,
                Color = Color3.fromRGB(0,255,0)
            }
        },
    },
    World = {
        HideLeaf = false,
        HideGrass = false,
        HideCloud = false,
    },
    Zoom = {
        Enable = false,
        Default = 70,
        NormalZoom = 10
    }
}

print('Loading Script')

-- Map Variable 
local lighting = game:GetService("Lighting")

-- Player Variable
local player = game:GetService("Players")
local localplayer = player.LocalPlayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid")
local humanoidrootpart = character:FindFirstChild("HumanoidRootPart")

-- Userinputservice - manager 
local userinputservice = game:GetService("UserInputService")

-- Mouse and camera
local camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
local mouse = localplayer:GetMouse()
-- Ui Variable 
local coregui = game:GetService("CoreGui")

--nil Variable

-- Game Folder
local allexit = workspace.NoCollision.ExitLocations
local Dropitem = workspace.DroppedItems
local treefolder = workspace.SpawnerZones.Foliage
local npcfolder = workspace.AiZones


-- Make label target undermouse
local Screengui = Instance.new("ScreenGui", localplayer:WaitForChild("PlayerGui"))
local label = Instance.new("TextLabel")
label.Name = "showtarget"
label.Parent = Screengui
label.BackgroundTransparency = 1
label.TextTransparency = 1
label.BorderColor3 = Color3.fromRGB(0, 0, 0)
label.BorderSizePixel = 0
label.Size = UDim2.new(0, 200, 0, 50)
label.Font = Enum.Font.SourceSans
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.TextSize = 15.000
label.TextWrapped = true
label.Position = UDim2.fromOffset(mouse.X , mouse.Y + 20)
label.AnchorPoint = Vector2.new(0.5, -1)

-- Make SilentAim FOV 
local fovCircle = Drawing.new("Circle")
fovCircle.NumSides = 64
fovCircle.Radius = config.PVPSetting.FOV
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Visible = config.PVPSetting.ShowFOV
fovCircle.ZIndex = 999
fovCircle.Color = config.PVPSetting.Color
fovCircle.Position = camera.ViewportSize / 2

-- Make Line to Target
local tracerLine = Drawing.new("Line")
tracerLine.Thickness = 1
tracerLine.Color = config.Showlinetotarget.Color
tracerLine.Transparency = 1
tracerLine.Visible = config.Showlinetotarget.Enable

-- ESP Table
local Drawings = {
    ESP = {},
    Tracers = {},
    Boxes = {},
    Healthbars = {},
    Names = {},
    Distances = {},
    Snaplines = {},
    Skeleton = {}
}
-- function gettargetfromfov SilentAim
local findtarget = {}
function findtarget.isinfov(pos)
    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
    if not onScreen then return false end

    local screenCenter = camera.ViewportSize / 2
    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
    return distance <= fovCircle.Radius
end
function findtarget.Playersandbot()
    local pb = {}
        if config.PVPSetting.SilentAim.Players then
            for _ , v in pairs(player:GetPlayers()) do
                if v ~= localplayer and v.Character then
                    local vroot = v.Character:FindFirstChild("HumanoidRootPart")
                    if vroot then
                        table.insert(pb,v.Character)
                    end
                end
            end
        end
        if config.PVPSetting.SilentAim.NPCs then
            for _, v in pairs(npcfolder:GetDescendants()) do
                local root = v:FindFirstChild("HumanoidRootPart")
                if root then
                    table.insert(pb,v)
                end
            end
        end
    return pb
end
function findtarget.target()
    local closestTarget = nil
    local closestAngle = 180
    for _, v in pairs(findtarget.Playersandbot()) do
        local vroot = v:FindFirstChild("HumanoidRootPart")
        if vroot then
            local screenPos, onScreen = camera:WorldToViewportPoint(vroot.Position)

            if onScreen and findtarget.isinfov(vroot.Position) then
                local cameraDir = camera.CFrame.LookVector
                local dirToTarget = (vroot.Position - camera.CFrame.Position).Unit
                local angle = math.deg(math.acos(cameraDir:Dot(dirToTarget)))

                if angle < closestAngle then
                    closestAngle = angle
                    closestTarget = vroot
                end
            end
        end
    end
    --[[for _, v in pairs(player:GetPlayers()) do
        if v ~= localplayer and v.Character then
            local vroot = v.Character:FindFirstChild("HumanoidRootPart")
            if vroot then
                local screenPos, onScreen = camera:WorldToViewportPoint(vroot.Position)

                if onScreen and findtarget.isinfov(vroot.Position) then
                    local cameraDir = camera.CFrame.LookVector
                    local dirToTarget = (vroot.Position - camera.CFrame.Position).Unit
                    local angle = math.deg(math.acos(cameraDir:Dot(dirToTarget)))

                    if angle < closestAngle then
                        closestAngle = angle
                        closestTarget = vroot
                    end
                end
            end
        end
    end]]

    return closestTarget
end

-- function esp exit 
local function espexit()
    if config.ESP.OtherESP.Exit.Enable then
        for _, exit in pairs(allexit:GetChildren()) do
            local espexit = exit:FindFirstChild("Board")
            local distance = (humanoidrootpart.Position - exit.Position).Magnitude
            local displayDistance = string.format("%.0f", distance)
            
            if not espexit and config.ESP.OtherESP.Exit.Enable then
                local board = Instance.new("BillboardGui")
                local Label = Instance.new("TextLabel")

                board.Parent = exit
                board.Name = "Board"
                board.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                board.Active = true
                board.AlwaysOnTop = true
                board.LightInfluence = 1.000
                board.Size = UDim2.new(0, 200, 0, 50)

                Label.Parent = board
                Label.Name = "Label"
                Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Label.BackgroundTransparency = 1.000
                Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Label.BorderSizePixel = 0
                Label.Size = UDim2.new(0, 200, 0, 50)
                Label.Font = Enum.Font.SourceSans
                Label.Text = "Exit Location " .. displayDistance .. " studs away"
                Label.TextColor3 = config.ESP.OtherESP.Exit.Color
                Label.TextSize = 14.000
                Label.TextTransparency = 0
            else
                espexit:FindFirstChild("Label").Text = "Exit Location " .. displayDistance .. " studs away"
            end
        end
    else
        for _, exit in pairs(allexit:GetChildren()) do
            local espexit = exit:FindFirstChild("Board")
            if espexit then
                espexit:Destroy()
            end
        end
    end
end

-- local function ESP Corpse
local function ESPCorpse()
    if config.ESP.OtherESP.Corpse.Enable then
        for _, corpse in pairs(Dropitem:GetChildren()) do
            if corpse:FindFirstChild("Humanoid") then
                if corpse.Humanoid.Health == 0 then
                    local espcorpse = corpse:FindFirstChild("Board")
                    
                    if not espcorpse then
                        local board = Instance.new("BillboardGui")
                        local Label = Instance.new("TextLabel")            

                        board.Parent = corpse
                        board.Name = "Board"
                        board.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                        board.Active = true
                        board.AlwaysOnTop = true
                        board.LightInfluence = 1.000
                        board.Size = UDim2.new(0, 200, 0, 50)

                        Label.Parent = board
                        Label.Name = "Label"
                        Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Label.BackgroundTransparency = 1.000
                        Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Label.BorderSizePixel = 0
                        Label.Size = UDim2.new(0, 200, 0, 50)
                        Label.Font = Enum.Font.SourceSans
                        Label.Text = corpse.Name .. " Corpse"
                        Label.TextColor3 = config.ESP.OtherESP.Corpse.Color
                        Label.TextSize = 14.000
                        Label.TextTransparency = 0
                    else
                        local label = espcorpse:FindFirstChild("Label")
                        if label then
                            label.Text = corpse.Name .. " Corpse"
                            label.TextColor3 = config.ESP.OtherESP.Corpse.Color
                        end
                    end
                else
                    local espcorpse = corpse:FindFirstChild("Board")
                    if espcorpse then
                        espcorpse:Destroy()
                    end
                end
            end
        end
    else
        for _, corpse in pairs(Dropitem:GetChildren()) do
            local espcorpse = corpse:FindFirstChild("Board")
            if espcorpse then
                espcorpse:Destroy()
            end
        end
    end
end

-- function ESP NPC 
local function ESPNPC()
    if config.ESP.NPC.Name.Enable then
        for _ , npcposition in pairs(npcfolder:GetChildren()) do
            for _, npc in pairs(npcposition:GetChildren()) do
                local hum = npc:FindFirstChild("Humanoid")
                if hum then
                    local espnpc = npc:FindFirstChild("Board")
                    if not espnpc and config.ESP.NPC.Name.Enable then
                        local board = Instance.new("BillboardGui")
                        local Label = Instance.new("TextLabel")            

                        board.Parent = npc
                        board.Name = "Board"
                        board.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                        board.Active = true
                        board.AlwaysOnTop = true
                        board.LightInfluence = 1.000
                        board.Size = UDim2.new(0, 200, 0, 50)

                        Label.Parent = board
                        Label.Name = "Label"
                        Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Label.BackgroundTransparency = 1.000
                        Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Label.BorderSizePixel = 0
                        Label.Size = UDim2.new(0, 200, 0, 50)
                        Label.Font = Enum.Font.SourceSans
                        Label.Text = "NPC : " ..npc.Name
                        Label.TextColor3 = config.ESP.NPC.Name.Color
                        Label.TextSize = 14.000
                        Label.TextTransparency = 0
                    end
                end
            end
        end
    else
        for _, npc in pairs(npcfolder:GetDescendants()) do
            local espnpc = npc:FindFirstChild("Board",true)
            if espnpc then
                espnpc:Destroy()
            end
        end
    end
    if config.ESP.NPC.Chams.Enable then
        for _, npcposition in pairs(npcfolder:GetChildren()) do
            for _, npc in pairs(npcposition:GetChildren()) do
                local cham = npc:FindFirstChild("hight")
                if not cham then
                    task.wait(2.5)
                    if npc:FindFirstChild("Humanoid") then
                        local hight = Instance.new("Highlight")
                        hight.Name = "hight"
                        hight.Parent = npc
                        hight.FillColor = config.ESP.NPC.Chams.Color
                        hight.OutlineColor = config.ESP.NPC.Chams.Color
                        hight.DepthMode = "Occluded"
                    end
                end
            end
        end
    else
        for _, npc in pairs(npcfolder:GetDescendants()) do
            local cham = npc:FindFirstChild("hight",true)
            if cham then
                cham:Destroy()
            end
        end
    end
end

-- function Hide world
local function Hide()
    for r4_83, r5_83 in pairs(treefolder:GetDescendants()) do
    if r5_83:FindFirstChildOfClass("SurfaceAppearance") then
      if config.World.HideLeaf == true then
        r5_83.Transparency = 1
      else
        r5_83.Transparency = 0
      end
    end
  end
end

-- Full Brightness 
function FullBrightness(booolean)
    if booolean then
        lighting.Brightness = 10
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        lighting.Brightness = 2
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end


-- ESP
local function CreateESP(player)
    if player == localplayer then return end
    local info = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    for _, text in pairs(info) do
        text.Visible = false
        text.Center = true
        text.Size = 14
        text.Color = Color3.fromRGB(255,255,255)
        text.Font = 2
        text.Outline = true
    end

    local box = {
        TopLeft = Drawing.new("Line"),
        TopRight = Drawing.new("Line"),
        BottomLeft = Drawing.new("Line"),
        BottomRight = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line"),
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line")
    }
    
    for _, line in pairs(box) do
        line.Visible = false
        line.Color = config.ESP.Box.Color
        line.Thickness = 1
    end


    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = config.ESP.Tracer.Color
    tracer.Thickness = 1

    local skeleton = {
        -- Spine & Head
        Head = Drawing.new("Line"),
        Neck = Drawing.new("Line"),
        UpperSpine = Drawing.new("Line"),
        LowerSpine = Drawing.new("Line"),
        
        -- Left Arm
        LeftShoulder = Drawing.new("Line"),
        LeftUpperArm = Drawing.new("Line"),
        LeftLowerArm = Drawing.new("Line"),
        LeftHand = Drawing.new("Line"),
        
        -- Right Arm
        RightShoulder = Drawing.new("Line"),
        RightUpperArm = Drawing.new("Line"),
        RightLowerArm = Drawing.new("Line"),
        RightHand = Drawing.new("Line"),
        
        -- Left Leg
        LeftHip = Drawing.new("Line"),
        LeftUpperLeg = Drawing.new("Line"),
        LeftLowerLeg = Drawing.new("Line"),
        LeftFoot = Drawing.new("Line"),
        
        -- Right Leg
        RightHip = Drawing.new("Line"),
        RightUpperLeg = Drawing.new("Line"),
        RightLowerLeg = Drawing.new("Line"),
        RightFoot = Drawing.new("Line")
    }

    for _, line in pairs(skeleton) do
        line.Visible = false
        line.Color = config.ESP.Skeleton.Color
        line.Thickness = 1
        line.Transparency = 0
    end

    Drawings.Skeleton[player] = skeleton
    
    Drawings.ESP[player] = {
        Box = box,
        Tracer = tracer,
        Info = info
    }
end
local function RemoveESP(player)
    local esp = Drawings.ESP[player]
    if esp then
        for _, obj in pairs(esp.Box) do 
            if obj then obj:Remove() end
        end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Info then
            for name, obj in pairs(esp.Info) do
                if obj then obj:Remove() end
            end
        end
        Drawings.ESP[player] = nil
    end
    
    local skeleton = Drawings.Skeleton[player]
    if skeleton then
        for _, line in pairs(skeleton) do
            if line then line:Remove() end
        end
        Drawings.Skeleton[player] = nil
    end
end
local function GetBoxCorners(cf, size)
    local corners = {
        Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
        Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
        Vector3.new(-size.X/2, size.Y/2, size.Z/2),
        Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
        Vector3.new(size.X/2, -size.Y/2, size.Z/2),
        Vector3.new(size.X/2, size.Y/2, -size.Z/2),
        Vector3.new(size.X/2, size.Y/2, size.Z/2)
    }
    
    for i, corner in ipairs(corners) do
        corners[i] = cf:PointToWorldSpace(corner)
    end
    
    return corners
end
local function HideESP(player)
    local esp = Drawings.ESP[player]
    if esp then
        for _, obj in pairs(esp.Box) do 
            if obj then obj.Visible = false end
        end
        
        if esp.Tracer then esp.Tracer.Visible = false end
        if esp.Skeleton then esp.Skeleton.Visible = false end
        if esp.Info then
            if esp.Info.Name then esp.Info.Name.Visible = false end
            if esp.Info.Distance then esp.Info.Distance.Visible = false end
        end
    end
end
local function GetTracerOrigin()
    local origin = config.ESP.Tracer.TracerOrigin  -- ต้องใช้ config.ESP.Tracer.TracerOrigin
    
    if origin == "Bottom" then
        return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    elseif origin == "Top" then
        return Vector2.new(camera.ViewportSize.X/2, 0)
    elseif origin == "Mouse" then
        local mousePos = userinputservice:GetMouseLocation()
        return mousePos
    elseif origin == "Center" then
        return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    else
        return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    end
end
local function DisableESP()
    for _, plr in ipairs(player:GetPlayers()) do
        HideESP(plr)
        local skeleton = Drawings.Skeleton[plr]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
    end
end
local function UpdateESP(player)
    if not config.ESP.Enable then 
        HideESP(player)
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        return  
    end
    
    local esp = Drawings.ESP[player]
    if not esp then return end
    
    local character = player.Character
    if not character then 
        HideESP(player)
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        return 
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        HideESP(player)
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        return 
    end
    
    -- Early screen check to hide all drawings if player is off screen
    local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen or pos.Z <= 0 then
        HideESP(player)
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
    
    if not onScreen or pos.Z <= 0 then
        HideESP(player)
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local size = character:GetExtentsSize()
    local cf = rootPart.CFrame
    
    local top, top_onscreen = camera:WorldToViewportPoint(cf * CFrame.new(0, size.Y/2, 0).Position)
    local bottom, bottom_onscreen = camera:WorldToViewportPoint(cf * CFrame.new(0, -size.Y/2, 0).Position)
    
    if not top_onscreen or not bottom_onscreen then
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        return
    end
    
    local screenSize = bottom.Y - top.Y
    local boxWidth = screenSize * 0.65
    local boxPosition = Vector2.new(top.X - boxWidth/2, top.Y)
    local boxSize = Vector2.new(boxWidth, screenSize)
    
    -- Hide all box parts by default
    for _, obj in pairs(esp.Box) do
        obj.Visible = false
    end
    
    if config.ESP.Box.Enable then
        if config.ESP.Box.BoxStyle == "3D" then
            local front = {
                TL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position),
                TR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position),
                BL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position),
                BR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position)
            }
            
            local back = {
                TL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)).Position),
                TR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)).Position),
                BL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)).Position),
                BR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            }
            
            if not (front.TL.Z > 0 and front.TR.Z > 0 and front.BL.Z > 0 and front.BR.Z > 0 and
                   back.TL.Z > 0 and back.TR.Z > 0 and back.BL.Z > 0 and back.BR.Z > 0) then
                for _, obj in pairs(esp.Box) do obj.Visible = false end
                return
            end
            
            -- Convert to Vector2
            local function toVector2(v3) return Vector2.new(v3.X, v3.Y) end
            front.TL, front.TR = toVector2(front.TL), toVector2(front.TR)
            front.BL, front.BR = toVector2(front.BL), toVector2(front.BR)
            back.TL, back.TR = toVector2(back.TL), toVector2(back.TR)
            back.BL, back.BR = toVector2(back.BL), toVector2(back.BR)
            
            -- Front face
            esp.Box.TopLeft.From = front.TL
            esp.Box.TopLeft.To = front.TR
            esp.Box.TopLeft.Visible = true
            
            esp.Box.TopRight.From = front.TR
            esp.Box.TopRight.To = front.BR
            esp.Box.TopRight.Visible = true
            
            esp.Box.BottomLeft.From = front.BL
            esp.Box.BottomLeft.To = front.BR
            esp.Box.BottomLeft.Visible = true
            
            esp.Box.BottomRight.From = front.TL
            esp.Box.BottomRight.To = front.BL
            esp.Box.BottomRight.Visible = true
            
            -- Back face
            esp.Box.Left.From = back.TL
            esp.Box.Left.To = back.TR
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = back.TR
            esp.Box.Right.To = back.BR
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = back.BL
            esp.Box.Top.To = back.BR
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = back.TL
            esp.Box.Bottom.To = back.BL
            esp.Box.Bottom.Visible = true
            
            -- Connecting lines
            local function drawConnectingLine(from, to, visible)
                local line = Drawing.new("Line")
                line.Visible = visible
                line.Color = config.ESP.Box.Color
                line.Thickness = 1
                line.From = from
                line.To = to
                return line
            end
            
            -- Connect front to back
            local connectors = {
                drawConnectingLine(front.TL, back.TL, true),
                drawConnectingLine(front.TR, back.TR, true),
                drawConnectingLine(front.BL, back.BL, true),
                drawConnectingLine(front.BR, back.BR, true)
            }
            
            -- Clean up connecting lines after frame
            task.spawn(function()
                task.wait()
                for _, line in ipairs(connectors) do
                    line:Remove()
                end
            end)
            
        elseif config.ESP.Box.BoxStyle == "Cornor" then
            local cornerSize = boxWidth * 0.2
            
            esp.Box.TopLeft.From = boxPosition
            esp.Box.TopLeft.To = boxPosition + Vector2.new(cornerSize, 0)
            esp.Box.TopLeft.Visible = true
            
            esp.Box.TopRight.From = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.TopRight.To = boxPosition + Vector2.new(boxSize.X - cornerSize, 0)
            esp.Box.TopRight.Visible = true
            
            esp.Box.BottomLeft.From = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.BottomLeft.To = boxPosition + Vector2.new(cornerSize, boxSize.Y)
            esp.Box.BottomLeft.Visible = true
            
            esp.Box.BottomRight.From = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.BottomRight.To = boxPosition + Vector2.new(boxSize.X - cornerSize, boxSize.Y)
            esp.Box.BottomRight.Visible = true
            
            esp.Box.Left.From = boxPosition
            esp.Box.Left.To = boxPosition + Vector2.new(0, cornerSize)
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.Right.To = boxPosition + Vector2.new(boxSize.X, cornerSize)
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.Top.To = boxPosition + Vector2.new(0, boxSize.Y - cornerSize)
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.Bottom.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y - cornerSize)
            esp.Box.Bottom.Visible = true
            
        else -- Full box
            esp.Box.Left.From = boxPosition
            esp.Box.Left.To = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.Left.Visible = true
            
            esp.Box.Right.From = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.Right.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.Right.Visible = true
            
            esp.Box.Top.From = boxPosition
            esp.Box.Top.To = boxPosition + Vector2.new(boxSize.X, 0)
            esp.Box.Top.Visible = true
            
            esp.Box.Bottom.From = boxPosition + Vector2.new(0, boxSize.Y)
            esp.Box.Bottom.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y)
            esp.Box.Bottom.Visible = true
            
            esp.Box.TopLeft.Visible = false
            esp.Box.TopRight.Visible = false
            esp.Box.BottomLeft.Visible = false  
            esp.Box.BottomRight.Visible = false
        end
      
        for _, obj in pairs(esp.Box) do
            if obj.Visible then
                obj.Color = config.ESP.Box.Color
                obj.Thickness = 1
            end
        end     
    else
        for _, obj in pairs(esp.Box) do
            obj.Visible = false
        end
    end
    
    if config.ESP.Tracer.Enable then
        esp.Tracer.From = GetTracerOrigin()
        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp.Tracer.Color = config.ESP.Tracer.Color
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end
    
    
    if config.ESP.Info.Name and esp.Info and esp.Info.Name then
        esp.Info.Name.Text = player.DisplayName or player.Name
        esp.Info.Name.Position = Vector2.new(
            boxPosition.X + boxWidth/2,
            boxPosition.Y - 20
        )
        esp.Info.Name.Color = Color3.fromRGB(255,255,255)
        esp.Info.Name.Visible = true
    elseif esp.Info and esp.Info.Name then
        esp.Info.Name.Visible = false
    end
    if config.ESP.Info.Distance and esp.Info and esp.Info.Distance then
        esp.Info.Distance.Text = string.format("%.0f studs", distance)
        esp.Info.Distance.Position = Vector2.new(
            boxPosition.X + boxWidth/2,
            boxPosition.Y - 35
        )
        esp.Info.Distance.Color = Color3.fromRGB(255,255,255)
        esp.Info.Distance.Visible = true
    elseif esp.Info and esp.Info.Distance then
        esp.Info.Distance.Visible = false
    end
        if config.ESP.Skeleton.Enable then
            local function getBonePositions(character)
            if not character then return nil end
            
            local bones = {
                Head = character:FindFirstChild("Head"),
                UpperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
                LowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
                RootPart = character:FindFirstChild("HumanoidRootPart"),
                
                -- Left Arm
                LeftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
                LeftLowerArm = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm"),
                LeftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"),
                
                -- Right Arm
                RightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
                RightLowerArm = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm"),
                RightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"),
                
                -- Left Leg
                LeftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
                LeftLowerLeg = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg"),
                LeftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg"),
                
                -- Right Leg
                RightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
                RightLowerLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg"),
                RightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")
            }
            
            -- Verify we have the minimum required bones
            if not (bones.Head and bones.UpperTorso) then return nil end
            
            return bones
        end
        
        local function drawBone(from, to, line)
            if not from or not to then 
                line.Visible = false
                return 
            end
            
            -- Get center positions of the parts
            local fromPos = (from.CFrame * CFrame.new(0, 0, 0)).Position
            local toPos = (to.CFrame * CFrame.new(0, 0, 0)).Position
            
            -- Convert to screen positions with proper depth check
            local fromScreen, fromVisible = camera:WorldToViewportPoint(fromPos)
            local toScreen, toVisible = camera:WorldToViewportPoint(toPos)
            
            -- Only show if both points are visible and in front of camera
            if not (fromVisible and toVisible) or fromScreen.Z < 0 or toScreen.Z < 0 then
                line.Visible = false
                return
            end
            
            -- Check if points are within screen bounds
            local screenBounds = camera.ViewportSize
            if fromScreen.X < 0 or fromScreen.X > screenBounds.X or
            fromScreen.Y < 0 or fromScreen.Y > screenBounds.Y or
            toScreen.X < 0 or toScreen.X > screenBounds.X or
            toScreen.Y < 0 or toScreen.Y > screenBounds.Y then
                line.Visible = false
                return
            end
            
            -- Update line with screen positions
            line.From = Vector2.new(fromScreen.X, fromScreen.Y)
            line.To = Vector2.new(toScreen.X, toScreen.Y)
            line.Color = config.ESP.Skeleton.Color
            line.Thickness = 1
            line.Transparency = 1
            line.Visible = true
        end
        
        local bones = getBonePositions(character)
        if bones then
            local skeleton = Drawings.Skeleton[player]
            if skeleton then
                -- Spine & Head
                drawBone(bones.Head, bones.UpperTorso, skeleton.Head)
                drawBone(bones.UpperTorso, bones.LowerTorso, skeleton.UpperSpine)
                
                -- Left Arm Chain
                drawBone(bones.UpperTorso, bones.LeftUpperArm, skeleton.LeftShoulder)
                drawBone(bones.LeftUpperArm, bones.LeftLowerArm, skeleton.LeftUpperArm)
                drawBone(bones.LeftLowerArm, bones.LeftHand, skeleton.LeftLowerArm)
                
                -- Right Arm Chain
                drawBone(bones.UpperTorso, bones.RightUpperArm, skeleton.RightShoulder)
                drawBone(bones.RightUpperArm, bones.RightLowerArm, skeleton.RightUpperArm)
                drawBone(bones.RightLowerArm, bones.RightHand, skeleton.RightLowerArm)
                
                -- Left Leg Chain
                drawBone(bones.LowerTorso, bones.LeftUpperLeg, skeleton.LeftHip)
                drawBone(bones.LeftUpperLeg, bones.LeftLowerLeg, skeleton.LeftUpperLeg)
                drawBone(bones.LeftLowerLeg, bones.LeftFoot, skeleton.LeftLowerLeg)
                
                -- Right Leg Chain
                drawBone(bones.LowerTorso, bones.RightUpperLeg, skeleton.RightHip)
                drawBone(bones.RightUpperLeg, bones.RightLowerLeg, skeleton.RightUpperLeg)
                drawBone(bones.RightLowerLeg, bones.RightFoot, skeleton.RightLowerLeg)
            end
        end
    else
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
    end
end

-- runservice
local lastUpdate = 0
local runservice = game:GetService("RunService")
runservice.Heartbeat:Connect(function()

    

    label.Position = UDim2.fromOffset(mouse.X , mouse.Y + 20)
    local currenttarget = findtarget.target()
    
    if config.Showtargetstatus then label.TextTransparency = 0 else label.TextTransparency = 1 end
    if currenttarget then
        local health = string.format("%.0f", currenttarget.Parent.Humanoid.Health)
        label.Text = "Target : " .. currenttarget.Parent.Name
        label.TextColor3 = Color3.fromRGB(0, 255, 0)
        label.Text = "Target : " .. currenttarget.Parent.Name .."\nHealth : " .. tostring(health)
    else
        label.Text = "No Target"
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    if config.Showlinetotarget.Enable and currenttarget then
        local targetPos, onScreen = camera:WorldToViewportPoint(currenttarget.Position)
        tracerLine.Visible = true
        tracerLine.From = camera.ViewportSize / 2 tracerLine.To = Vector2.new(targetPos.X, targetPos.Y)
    else
        tracerLine.Visible = false
    end

    fovCircle.Visible = config.PVPSetting.ShowFOV
    fovCircle.Radius = config.PVPSetting.FOV

    -- Make Other ESP
    espexit()
    ESPCorpse()
    ESPNPC()

    if config.Zoom.Enable then
        camera.FieldOfView = config.Zoom.NormalZoom
    else
        camera.FieldOfView = config.Zoom.Default
    end
    if config.ZoomMode == "Toggle" then
        local zoomToggle = Toggles['Zoom']  -- ตรวจสอบชื่อ toggle
        if zoomToggle and zoomToggle.Value ~= config.Zoom.Enable then
            zoomToggle:SetValue(config.Zoom.Enable)
        end
    end
    
    -- Loop ESP
    if config.ESP.Enable then 
        local currentTime = tick()
        if currentTime - lastUpdate >= config.ESP.Refresh then
            for _, player in ipairs(player:GetPlayers()) do
                if player ~= localplayer then
                    if not Drawings.ESP[player] then
                        CreateESP(player)
                    end
                    UpdateESP(player)
                end
            end
            lastUpdate = currentTime
        end
    else
        DisableESP()
    end
end)

-- Make ESP
player.PlayerAdded:Connect(CreateESP)
player.PlayerRemoving:Connect(RemoveESP)
for _, player in ipairs(player:GetPlayers()) do
    if player ~= localplayer then
        CreateESP(player)
    end
end


-- Fire Remote
local Fireprojectileremote = game:GetService("ReplicatedStorage").Remotes.FireProjectile 
local ProjectileInflictremote = game:GetService("ReplicatedStorage").Remotes.ProjectileInflict

local function fireprojectile(vec3,number1,number2)
    Fireprojectileremote:InvokeServer(vec3,number1,number2)
end
local function projectileinflict(part,CFrame,number1,number2)
    ProjectileInflictremote:FireServer(part,CFrame,number1,number2)
end

--[[example
Fireprojectileremote:InvokeServer(
    Vector3.new(0/0, 0/0, 0/0),
    5571,
    1764958762.861
)

ProjectileInflictremote:FireServer(
    workspace.AiZones.GasStation.HighwayBandit.Head,
    CFrame.new(0, 0.010009765625, -0.00048828125, -0.57047295570374, -2.0698644220829e-07, 0.82131630182266, -0.032824587076902, 0.99920105934143, -0.022799160331488, -0.82066011428833, -0.03996567428112, -0.57001727819443),
    5571,
    0/0
)]]

--Hook
local old; old = hookmetamethod(game,"__namecall",newcclosure(function(self,...)
    local args = {...}
    local method = getnamecallmethod()
    if tostring(self) == "FireProjectile" and method == "InvokeServer" and config.PVPSetting.SilentAim.Enable then
        local valid = old(self,...)
        local target = findtarget.target()
        if target and valid then
            local Hitbox = target.Parent:FindFirstChild(config.PVPSetting.SilentAim.Part)
            if Hitbox then
                projectileinflict(Hitbox,Hitbox.CFrame:ToObjectSpace(CFrame.new(Hitbox.Position + Vector3.new(0,1,0) * 0.01)),args[2],(0/0))
            end
        end
        return valid
    end
    return old(self,...)
end))
--Ui Library
task.defer(function()
    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
    local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
    local Window = Library:CreateWindow({ Title = 'Xelarp | Last Updated 11/01/2026', Center = true, AutoShow = true, TabPadding = 8, MenuFadeTime = 0.2})

    -- Tabs 
    local Tabs = {
        Main = Window:AddTab('Main'),
        Visual = Window:AddTab('ESP'),
        ['UI Settings'] = Window:AddTab('UI Settings'),
    }

    -- MainTab

    -- Profile 
    local Profile = Tabs.Main:AddLeftGroupbox('Xelarp Credits')
    Profile:AddLabel('Main Developer : Young Q')
    Profile:AddLabel('Contributor : Saikrok Scripter')
    Profile:AddLabel('This is Beta Script')
    Profile:AddLabel('🟢 Working Well')
    -- PVPSettinggroupbox 
    local SilentAimggroupbox = Tabs.Main:AddLeftGroupbox('https://discord.gg/saikrokisaanservice')

    SilentAimggroupbox:AddToggle('Show Target Toggle', {Text = 'Show target under mouse', Default = false, Callback = function(Value) config.Showtargetstatus = Value end})
    SilentAimggroupbox:AddToggle('Show Line to target', {Text = 'Show Line to target', Default = false, Callback = function(Value) config.Showlinetotarget.Enable = Value end}):AddColorPicker('Linetotarget ColorPicker', { Default = Color3.new(255, 0, 0), Transparency = 0, Callback = function(Value) tracerLine.Color = Value end})
    SilentAimggroupbox:AddToggle('Show Silent FOV', {Text = 'Show Silent FOV',Default = false,Callback = function(Value) config.PVPSetting.ShowFOV = Value end}):AddColorPicker('FovColorPicker', { Default = Color3.new(255, 255, 255), Transparency = 0, Callback = function(Value) fovCircle.Color = Value end})
    SilentAimggroupbox:AddSlider('FOV Radius', { Text = 'FOV Radius', Default = 30, Min = 5, Max = 500, Rounding = 1, Compact = false, Callback = function(Value) config.PVPSetting.FOV = Value end})
    SilentAimggroupbox:AddToggle('Zoom', {Text = 'Zoom ( Only Toggle )',Default = false,}):AddKeyPicker('KeyPicker', { Default = 'Z', SyncToggleState = false, Mode = 'Toggle', --[[ Modes: Always, Toggle, Hold]] Text = 'Keybind Zoom', NoUI = false, Callback = function(Value) config.Zoom.Enable = Value end,})
    SilentAimggroupbox:AddDivider()

    
    SilentAimggroupbox:AddToggle('Enable SilentAim', {Text = 'Enable SilentAim',Default = false,}):AddKeyPicker('KeyPicker', { Default = 'MB2', SyncToggleState = false, Mode = 'Toggle', --[[ Modes: Always, Toggle, Hold]] Text = 'Keybind SilentAim', NoUI = false, Callback = function(Value) config.PVPSetting.SilentAim.Enable = Value end,})
    SilentAimggroupbox:AddToggle('SilentAim Players', {Text = 'SilentAim Players', Default = false, Callback = function(Value) config.PVPSetting.SilentAim.Players = Value end})
    SilentAimggroupbox:AddToggle('SilentAim NPCs', {Text = 'SilentAim NPCs', Default = false, Callback = function(Value) config.PVPSetting.SilentAim.NPCs = Value end})
    SilentAimggroupbox:AddDropdown('Select SilentAim Part', { Values = { 'Head', 'UpperTorso', 'LowerTorso', }, Default = 1, Multi = false, Text = 'Select SilentAim Part', Callback = function(Value) config.PVPSetting.SilentAim.Part = Value end})
    -- ESP Tab

    local Espplayers = Tabs.Visual:AddLeftGroupbox('ESP Players')

    Espplayers:AddToggle('Enable ESP', {Text = 'Enable ESP', Default = false, Callback = function(Value) config.ESP.Enable = Value end})
    Espplayers:AddToggle('ESP Name', {Text = 'ESP Name', Default = false, Callback = function(Value) config.ESP.Info.Name = Value end})
    Espplayers:AddToggle('ESP Distance', {Text = 'ESP Distance', Default = false, Callback = function(Value) config.ESP.Info.Distance = Value end})
    Espplayers:AddToggle('ESP Box', {Text = 'ESP Box', Default = false, Callback = function(Value) config.ESP.Box.Enable = Value end}):AddColorPicker('ESP Box ColorPicker', { Default = Color3.fromRGB(255,255,255), Transparency = 0, Callback = function(Value) config.ESP.Box.Color = Value end})
    Espplayers:AddDropdown('Box Style', { Values = { "Cornor" , "Full" , "3D" }, Default = "Cornor", Multi = false, Text = 'Box Style', Callback = function(Value) config.ESP.Box.BoxStyle = Value end})
    
    Espplayers:AddToggle('Tracer Box', {Text = 'Tracer Box', Default = false, Callback = function(Value) config.ESP.Tracer.Enable = Value end}):AddColorPicker('ESP Tracer ColorPicker', { Default = Color3.fromRGB(255,255,255), Transparency = 0, Callback = function(Value) config.ESP.Tracer.Color = Value end})
    Espplayers:AddDropdown('Tracer Style', { Values = { "Bottom" , "Top" , "Mouse" , "Center"}, Default = 1, Multi = false, Text = 'Tracer Style', Callback = function(Value) config.ESP.Tracer.TracerOrigin = Value end})
    Espplayers:AddToggle('Skeleton', {Text = 'Skeleton', Default = false, Callback = function(Value) config.ESP.Skeleton.Enable = Value end}):AddColorPicker('ESP Skeleton ColorPicker', { Default = Color3.fromRGB(255,255,255), Transparency = 0, Callback = function(Value) config.ESP.Skeleton.Color = Value end})

    -- 
    local npcespgroupbox = Tabs.Visual:AddRightGroupbox('NPC ESP')
    npcespgroupbox:AddToggle('Enable NPC Name', {Text = 'Enable NPC Name', Default = false, Callback = function(Value) config.ESP.NPC.Name.Enable = Value end}):AddColorPicker('ESP NPC Name ColorPicker', { Default = Color3.fromRGB(204,0,102), Transparency = 0, Callback = function(Value) config.ESP.NPC.Name.Color = Value ESPNPC() end})
    npcespgroupbox:AddToggle('Enable NPC Cham when Visible', {Text = 'Enable NPC Cham when Visible', Default = false, Callback = function(Value) config.ESP.NPC.Chams.Enable = Value end}):AddColorPicker('ESP NPC Name ColorPicker', { Default = Color3.fromRGB(204,0,102), Transparency = 0, Callback = function(Value) config.ESP.NPC.Chams.Color = Value ESPNPC() end})

    -- Others ESP
    local otherespgroupbox = Tabs.Visual:AddRightGroupbox('Other ESP')
    -- ESP Exit
    otherespgroupbox:AddToggle('ESP Exit', {Text = 'ESP Exit', Default = false, Callback = function(Value) config.ESP.OtherESP.Exit.Enable = Value end}):AddColorPicker('ESP Box ColorPicker', { Default = Color3.fromRGB(0, 255, 255), Transparency = 0, Callback = function(Value) config.ESP.OtherESP.Exit.Color = Value end})
    -- ESP Corpse
    otherespgroupbox:AddToggle('ESP Corpse', {Text = 'ESP Corpse', Default = false, Callback = function(Value) config.ESP.OtherESP.Corpse.Enable = Value end}):AddColorPicker('ESP Box ColorPicker', { Default = Color3.fromRGB(0,255,0), Transparency = 0, Callback = function(Value) config.ESP.OtherESP.Corpse.Color = Value end})

    otherespgroupbox:AddDivider()
    otherespgroupbox:AddLabel('World')
    otherespgroupbox:AddToggle('Full Brightness', {Text = 'Full Brightness', Default = false, Callback = function(Value) FullBrightness(Value) end})
    otherespgroupbox:AddToggle('No Fog', {Text = 'No Fog', Default = false, Callback = function(Value) if Value then game.Lighting.Atmosphere.Density = 0 else game.Lighting.Atmosphere.Density = 0 end end})
    otherespgroupbox:AddToggle('Hide Leaf', {Text = 'Hide Leaf', Default = false, Callback = function(Value) config.World.HideLeaf = Value Hide() end})
    otherespgroupbox:AddToggle('Hide Grass', {Text = 'Hide Grass', Default = false, Callback = function(Value) sethiddenproperty(workspace.Terrain, "Decoration", not Value) end})
    otherespgroupbox:AddToggle('Hide Cloud', {Text = 'Hide Cloud', Default = false, Callback = function(Value) config.World.HideCloud = Value if config.World.HideCloud then  if workspace.Terrain:FindFirstChild("Clouds") then workspace.Terrain.Clouds.Enabled = not config.World.HideCloud end end end}) 










    local FrameTimer = tick()
    local FrameCounter = 0;
    local FPS = 60;
    local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
        FrameCounter = FrameCounter + 1 ;

        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter;
            FrameTimer = tick();
            FrameCounter = 0;
        end;

        Library:SetWatermark(('Xelarp | %s fps | %s ms'):format(
            math.floor(FPS),
            math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
        ));
    end);


    -- Setting Ui
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
    Library.ToggleKeybind = Options.MenuKeybind
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('MyScriptHub')
    SaveManager:SetFolder('MyScriptHub/specific-game')
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    Library.KeybindFrame.Visible = true
    print('Script Loaded')
end)

-- Loop 10 Second
task.defer(function()
    while task.wait(10) do
        Hide()
    end
end)