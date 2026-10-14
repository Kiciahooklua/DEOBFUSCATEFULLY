-- Fully deobfuscated and readable version.
-- Obfuscated identifiers were renamed; runtime logic and control flow were preserved.

-- [[ Protected with Custom Lua/Luau Pipeline (Seed: 8052516) ]]
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local UserInputService=game:GetService('UserInputService')
local HttpService=game:GetService('HttpService')
local Camera=workspace.CurrentCamera
local LocalPlayer=Players.LocalPlayer
local Config={['Enabled']=true,['HoldToAim']=false,['AimKey']=Enum.UserInputType.MouseButton2,['TargetPart']='Head',['FOVRadius']=100,['ShowFOV']=true,['Smoothing']=0.25,['UseDeltaTime']=true,['TeamCheck']=true,['WallCheck']=true,['Friends']={},['SwitchThreshold']=0.6,['TriggerBot']=false,['TriggerMode']=3,['ScopeFOV']=45,['ScopeDelay']=0.28,['TriggerDelay']=0.035,['TriggerMaxPierce']=5,['SwapKey']=Enum.KeyCode.X}
local configFileName='Raybals_Config.json'
local
function saveConfig()
local configToSave={['Enabled']=Config.Enabled,['HoldToAim']=Config.HoldToAim,['TargetPart']=Config.TargetPart,['FOVRadius']=Config.FOVRadius,['ShowFOV']=Config.ShowFOV,['Smoothing']=Config.Smoothing,['TeamCheck']=Config.TeamCheck,['WallCheck']=Config.WallCheck,['TriggerBot']=Config.TriggerBot,['TriggerMode']=Config.TriggerMode,['ScopeFOV']=Config.ScopeFOV,['ScopeDelay']=Config.ScopeDelay,['TriggerDelay']=Config.TriggerDelay,['SwitchThreshold']=Config.SwitchThreshold}
local localVar013,localVar002=pcall(
function()
return HttpService:JSONEncode(configToSave)
end)
if localVar013 and localVar002 then
if writefile then pcall(writefile,configFileName,localVar002)
end _G.Raybals_SavedConfig=configToSave
end
end
local
function loadConfig()
local localVar019=nil
if isfile and readfile then
local fileCheckOk,localVar009=pcall(isfile,configFileName)
if fileCheckOk and localVar009 then
local localVar001,configJson=pcall(readfile,configFileName)
if localVar001 and configJson and configJson~='' then
local localVar005,localVar015=pcall(
function()
return HttpService:JSONDecode(configJson)
end)
if localVar005 and type(localVar015)=='table' then localVar019=localVar015
end
end
end
end
if not (localVar019) and _G.Raybals_SavedConfig and type(_G.Raybals_SavedConfig)=='table' then localVar019=_G.Raybals_SavedConfig
end
if localVar019 then
if localVar019.Enabled~=nil then Config.Enabled=localVar019.Enabled
end
if localVar019.HoldToAim~=nil then Config.HoldToAim=localVar019.HoldToAim
end
if localVar019.TargetPart~=nil then Config.TargetPart=localVar019.TargetPart
end
if localVar019.FOVRadius~=nil then Config.FOVRadius=localVar019.FOVRadius
end
if localVar019.ShowFOV~=nil then Config.ShowFOV=localVar019.ShowFOV
end
if localVar019.Smoothing~=nil then Config.Smoothing=localVar019.Smoothing
end
if localVar019.TeamCheck~=nil then Config.TeamCheck=localVar019.TeamCheck
end
if localVar019.WallCheck~=nil then Config.WallCheck=localVar019.WallCheck
end
if localVar019.TriggerBot~=nil then Config.TriggerBot=localVar019.TriggerBot
end
if localVar019.TriggerMode~=nil then Config.TriggerMode=localVar019.TriggerMode
end
if localVar019.ScopeFOV~=nil then Config.ScopeFOV=localVar019.ScopeFOV
end
if localVar019.ScopeDelay~=nil then Config.ScopeDelay=localVar019.ScopeDelay
end
if localVar019.TriggerDelay~=nil then Config.TriggerDelay=localVar019.TriggerDelay
end
if localVar019.SwitchThreshold~=nil then Config.SwitchThreshold=localVar019.SwitchThreshold
end
end
end loadConfig()
if not (Config.Enabled) and not (Config.TriggerBot) then Config.Enabled=true Config.TriggerBot=false
elseif Config.Enabled and Config.TriggerBot then Config.TriggerBot=false
end
local currentTarget=nil
local aimActive=not (Config.HoldToAim) and Config.Enabled
local lastMouseMoveTime=0
local lastTriggerTime=0
local triggerStartTime=0
local isRightMouseDown=false
local rightMouseDownTime=0
local triggerCooldown=0.12
local initialScopeFOV=90
local scopeStartTime=0
local
function isScoped()
local cameraFov=Camera.FieldOfView
local now=tick()
if not (isRightMouseDown) and cameraFov>60 then initialScopeFOV=cameraFov scopeStartTime=0
end
local scopeReady=isRightMouseDown or cameraFov<=initialScopeFOV-12
if not (scopeReady) then scopeStartTime=0
return false
end
if scopeStartTime==0 then scopeStartTime=rightMouseDownTime>0 and rightMouseDownTime or now
end
local localVar002=Config.ScopeDelay or 0.28
if now-scopeStartTime<localVar002 then
return false
end
local scopeFovLimit=Config.ScopeFOV or 45
if cameraFov>scopeFovLimit and cameraFov>initialScopeFOV-22 then
return false
end
return true
end
local
function getCharacterModel(player)
if not (player) then
return nil
end
if player.Character and player.Character.Parent then
return player.Character
end
local charactersFolder=workspace:FindFirstChild('Characters')
if charactersFolder then
local namedModel=charactersFolder:FindFirstChild(player.Name)
if namedModel and namedModel:IsA('Model') then
return namedModel
end
for folderIndex,folderChild in ipairs(charactersFolder:GetChildren()) do
if folderChild:IsA('Folder') or folderChild:IsA('Model') then
local playerModel=folderChild:FindFirstChild(player.Name)
if playerModel and playerModel:IsA('Model') then
return playerModel
end
end
end
end
local playerModel=workspace:FindFirstChild(player.Name)
if playerModel and playerModel:IsA('Model') then
return playerModel
end
return nil
end
local ignoredParentNames={['workspace']=true,['characters']=true,['players']=true,['map']=true,['world']=true,['entities']=true}
local
function getTeamIdentifier(playerModel)
if not (playerModel) then
return nil
end
local charactersFolder=workspace:FindFirstChild('Characters')
if not (charactersFolder) then
return nil
end
for folderIndex,folder in ipairs(charactersFolder:GetChildren()) do
if (folder:IsA('Folder') or folder:IsA('Model')) and folder.Name~=playerModel.Name then
local playerModel=folder:FindFirstChild(playerModel.Name)
if playerModel then
return folder.Name
end
end
end
local character=playerModel.Character
if character and character.Parent and character.Parent~=charactersFolder and character.Parent.Parent==charactersFolder then
local parentName=character.Parent.Name
if not (ignoredParentNames[parentName:lower()]) then
return parentName
end
end
return nil
end
local
function getTeamId(modelA,modelB)
local
function getTeamIdFromInstance(candidatePart)
if not (candidatePart) then
return nil
end
for index,attributeName in ipairs({'TeamID','TeamId','teamId','Team','team','TeamNumber'}) do
local attributeValue=candidatePart:GetAttribute(attributeName)
if attributeValue~=nil then
local teamValue=tostring(attributeValue)
if teamValue~='0' and teamValue~='-1' and teamValue:lower()~='ffa' and teamValue:lower()~='neutral' and teamValue~='' then
return teamValue
end
end
end
return nil
end
return getTeamIdFromInstance(modelA) or getTeamIdFromInstance(modelB)
end
local
function hasGreenHighlight(model)
if not (model) then
return false
end
local highlight=model:FindFirstChildOfClass('Highlight')
if highlight and highlight.Enabled and highlight.OutlineTransparency<0.8 then
local outlineColor=highlight.OutlineColor
if outlineColor and outlineColor.G>0.4 and outlineColor.G>outlineColor.R*1.3 and outlineColor.G>outlineColor.B*1.3 then
return true
end
end
for child,child in ipairs(model:GetChildren()) do
if child:IsA('Highlight') and child.Enabled and child.OutlineTransparency<0.8 then
local outlineColor=child.OutlineColor
if outlineColor and outlineColor.G>0.4 and outlineColor.G>outlineColor.R*1.3 and outlineColor.G>outlineColor.B*1.3 then
return true
end
end
end
return false
end
local localTeamCache={['val']=nil,['time']=0}
local
function getLocalTeam()
local currentTime=tick()
if currentTime-localTeamCache.time<0.35 then
return localTeamCache.val
end
local localTeam=getTeamIdentifier(LocalPlayer) localTeamCache.val=localTeam localTeamCache.time=currentTime
return localTeam
end
local
function isSameTeam(targetPlayer,targetModel)
if not (Config.TeamCheck) then
return false
end
if not (targetPlayer) or targetPlayer==LocalPlayer then
return true
end
local targetCharacter=targetModel or getCharacterModel(targetPlayer)
local localCharacter=LocalPlayer.Character or getCharacterModel(LocalPlayer)
local localTeamId=getLocalTeam()
local targetTeam=getTeamIdentifier(targetPlayer)
if localTeamId and targetTeam then
return localTeamId==targetTeam
end
local localTeamId=getTeamId(LocalPlayer,localCharacter)
local targetTeamId=getTeamId(targetPlayer,targetCharacter)
if localTeamId and targetTeamId then
return localTeamId==targetTeamId
end
if targetCharacter and hasGreenHighlight(targetCharacter) then
return true
end
return false
end
local teamCache={}
local
function isSameTeamCached(player,targetModel)
if not (Config.TeamCheck) then
return false
end
if not (player) or player==LocalPlayer then
return true
end
local now=tick()
local cachedTeam=teamCache[player]
if cachedTeam and now-cachedTeam.time<0.35 then
return cachedTeam.isTeam
end
local cachedIsTeam=isSameTeam(player,targetModel) teamCache[player]={['isTeam']=cachedIsTeam,['time']=now}
return cachedIsTeam
end Players.PlayerRemoving:Connect(
function(player) teamCache[player]=nil
end)
local
function hasLineOfSight(targetModel)
if not (Config.WallCheck) then
return true
end
local cameraPosition=Camera.CFrame.Position
local targetPart=targetModel:FindFirstChild(Config.TargetPart) or targetModel:FindFirstChild('HumanoidRootPart')
if not (targetPart) then
return false
end
local direction=targetPart.Position-cameraPosition
local distance=direction.Magnitude
local distance=RaycastParams.new() distance.FilterType=Enum.RaycastFilterType.Exclude distance.FilterDescendantsInstances={LocalPlayer.Character or LocalPlayer,targetModel}
local raycastResult=workspace:Raycast(cameraPosition,direction.Unit*distance,distance)
return raycastResult==nil
end
local ignoredPartNames={['HumanoidRootPart']=true,['Handle']=true}
local ignoredParentNamesForPierce={['ignore']=true,['debris']=true,['effects']=true,['particles']=true,['bullets']=true,['projectiles']=true,['sounds']=true,['fx']=true,['vfx']=true,['rays']=true}
local
function shouldIgnoreRaycastPart(part)
if not (part.CanCollide) then
return true
end
if part.Transparency>=0.9 then
return true
end
if ignoredPartNames[part.Name] then
return true
end
local parent=part.Parent
if parent then
if parent:IsA('Accessory') or parent:IsA('Tool') or parent:IsA('BackpackItem') then
return true
end
if parent:IsA('Model') and parent:FindFirstChildOfClass('Humanoid') then
return true
end
if ignoredParentNamesForPierce[parent.Name:lower()] then
return true
end
end
if part:FindFirstChildOfClass('ForceField') or parent and parent:FindFirstChildOfClass('ForceField') then
return true
end
if part.Transparency>=0.75 then
return true
end
return false
end
local pierceRaycastParams=RaycastParams.new() pierceRaycastParams.FilterType=Enum.RaycastFilterType.Exclude
local raycastFilter=table.create(32)
local raycastFilterCount=0
local
function resetRaycastFilter() table.clear(raycastFilter) raycastFilterCount=0
end
local
function addRaycastFilter(instance) raycastFilterCount=raycastFilterCount+(1) raycastFilter[raycastFilterCount]=instance
end
local
function isValidTarget(targetPlayer,direction)
local humanoid=direction:FindFirstChildOfClass('Humanoid')
if not (humanoid) or humanoid.Health<=0 then
return false
end
if humanoid:GetState()==Enum.HumanoidStateType.Dead then
return false
end
if Config.TeamCheck and isSameTeamCached(targetPlayer,direction) then
return false
end
if Config.Friends[targetPlayer.Name] then
return false
end
return true
end
local
function findTriggerTarget(origin,direction,localVar001) resetRaycastFilter()
if LocalPlayer.Character then addRaycastFilter(LocalPlayer.Character)
end
local currentOrigin=origin
local rayVector=direction*localVar001
for pierceIndex=1,Config.TriggerMaxPierce do pierceRaycastParams.FilterDescendantsInstances=raycastFilter
local raycastResult=workspace:Raycast(currentOrigin,rayVector,pierceRaycastParams)
if not (raycastResult) then
return nil
end
local hitPart=raycastResult.Instance
local hitModel=hitPart.Parent
if hitModel and hitModel:IsA('Model') and hitModel:FindFirstChildOfClass('Humanoid') then
local hitPlayer=Players:GetPlayerFromCharacter(hitModel) or Players:FindFirstChild(hitModel.Name)
if hitPlayer and hitPlayer~=LocalPlayer and isValidTarget(hitPlayer,hitModel) then
return hitPlayer,hitPart,raycastResult.Position
end addRaycastFilter(hitModel)
elseif hitModel and (hitModel:IsA('Accessory') or hitModel:IsA('Tool')) then
local accessoryOwner=hitModel.Parent
if accessoryOwner and accessoryOwner:IsA('Model') and accessoryOwner:FindFirstChildOfClass('Humanoid') then
local accessoryPlayer=Players:GetPlayerFromCharacter(accessoryOwner) or Players:FindFirstChild(accessoryOwner.Name)
if accessoryPlayer and accessoryPlayer~=LocalPlayer and isValidTarget(accessoryPlayer,accessoryOwner) then
return accessoryPlayer,hitPart,raycastResult.Position
end addRaycastFilter(accessoryOwner)
else addRaycastFilter(hitPart)
end
elseif shouldIgnoreRaycastPart(hitPart) then addRaycastFilter(hitPart)
else
return nil
end
local nextOrigin=raycastResult.Position+raycastResult.Normal*0.01
local remainingDistance=localVar001-(nextOrigin-origin).Magnitude
if remainingDistance<1 then
return nil
end rayVector=direction*remainingDistance currentOrigin=nextOrigin
end
return nil
end
local
function getScreenDistanceFromCenter(worldPosition)
local viewportSize=Camera.ViewportSize
local screenCenter=Vector2.new(viewportSize.X/2,viewportSize.Y/2)
local screenPoint,onScreen=Camera:WorldToViewportPoint(worldPosition)
if not (onScreen) or screenPoint.Z<=0 then
return math.huge,false
end
local localVar008=Vector2.new(screenPoint.X,screenPoint.Y)
return (localVar008-screenCenter).Magnitude,true
end
local
function findBestTarget()
local bestPlayer=nil
local bestScreenDistance=math.huge
for playerIndex,candidatePlayer in ipairs(Players:GetPlayers()) do
if candidatePlayer==LocalPlayer then
continue
end
if Config.Friends[candidatePlayer.Name] then
continue
end
local candidateModel=getCharacterModel(candidatePlayer)
if not (candidateModel) then
continue
end
local candidatePart=candidateModel:FindFirstChild(Config.TargetPart) or candidateModel:FindFirstChild('HumanoidRootPart')
if not (candidatePart) then
continue
end
local screenDistance,onScreen=getScreenDistanceFromCenter(candidatePart.Position)
if not (onScreen) then
continue
end
if screenDistance>Config.FOVRadius then
continue
end
local humanoid=candidateModel:FindFirstChild('Humanoid')
if not (humanoid) or humanoid.Health<=0 then
continue
end
if isSameTeamCached(candidatePlayer,candidateModel) then
continue
end
if not (hasLineOfSight(candidateModel)) then
continue
end
if screenDistance<bestScreenDistance then bestScreenDistance=screenDistance bestPlayer=candidatePlayer
end
end
if currentTarget and bestPlayer and bestPlayer~=currentTarget then
local currentTargetModel=getCharacterModel(currentTarget)
if currentTargetModel then
local currentTargetPart=currentTargetModel:FindFirstChild(Config.TargetPart) or currentTargetModel:FindFirstChild('HumanoidRootPart')
if currentTargetPart then
local currentTargetDistance,currentTargetOnScreen=getScreenDistanceFromCenter(currentTargetPart.Position)
if currentTargetOnScreen and currentTargetDistance<=Config.FOVRadius*1.3 then
if bestScreenDistance>currentTargetDistance*Config.SwitchThreshold then
return currentTarget
end
end
end
end
end
return bestPlayer
end
local
function isTargetValid(player)
if not (player) then
return false
end
local targetModel=getCharacterModel(player)
if not (targetModel) then
return false
end
local humanoid=targetModel:FindFirstChild('Humanoid')
if not (humanoid) or humanoid.Health<=0 then
return false
end
local targetPart=targetModel:FindFirstChild(Config.TargetPart) or targetModel:FindFirstChild('HumanoidRootPart')
if not (targetPart) then
return false
end
local screenDistance,onScreen=getScreenDistanceFromCenter(targetPart.Position)
if not (onScreen) then
return false
end
if screenDistance>Config.FOVRadius*1.3 then
return false
end
if isSameTeamCached(player,targetModel) then
return false
end
if not (hasLineOfSight(targetModel)) then
return false
end
return true
end
local
function aimAtTarget(deltaTime)
if not (currentTarget) then
return
end
local targetModel=getCharacterModel(currentTarget)
if not (targetModel) then
return
end
local targetPart=targetModel:FindFirstChild(Config.TargetPart) or targetModel:FindFirstChild('HumanoidRootPart')
if not (targetPart) then
return
end
local targetPosition=targetPart.Position
local screenPoint,onScreen=Camera:WorldToViewportPoint(targetPosition)
if not (onScreen) or screenPoint.Z<=0 then
return
end
local viewportSize=Camera.ViewportSize
local centerX=viewportSize.X/2
local centerY=viewportSize.Y/2
local offsetX=screenPoint.X-centerX
local offsetY=screenPoint.Y-centerY
local smoothFactor=Config.Smoothing
if Config.UseDeltaTime then smoothFactor=1-math.pow(1-Config.Smoothing,deltaTime*60)
end smoothFactor=math.clamp(smoothFactor,0.01,1)
local moveX=offsetX*smoothFactor
local moveY=offsetY*smoothFactor
if math.abs(moveX)<0.5 and math.abs(moveY)<0.5 then
return
end mousemoverel(moveX,moveY)
end
local fovCircle=Drawing.new('Circle') fovCircle.Thickness=1.5 fovCircle.Color=Color3.fromRGB(255,40,40) fovCircle.Transparency=0.6 fovCircle.Filled=false fovCircle.Visible=Config.ShowFOV fovCircle.Radius=Config.FOVRadius
local screenGui=Instance.new('ScreenGui') screenGui.Name='RaybalsV2' screenGui.ResetOnSpawn=false screenGui.Enabled=false pcall(
function()
if syn and syn.protect_gui then syn.protect_gui(screenGui) screenGui.Parent=game:GetService('CoreGui')
elseif gethui then screenGui.Parent=gethui()
else screenGui.Parent=game:GetService('CoreGui')
end
end)
local mainFrame=Instance.new('Frame') mainFrame.Name='Main' mainFrame.Size=UDim2.new(0,220,0,515) mainFrame.Position=UDim2.new(0.78,0,0.15,0) mainFrame.BackgroundColor3=Color3.fromRGB(18,18,22) mainFrame.BorderSizePixel=0 mainFrame.Active=true mainFrame.Draggable=true mainFrame.Parent=screenGui
local mainCorner=Instance.new('UICorner') mainCorner.CornerRadius=UDim.new(0,6) mainCorner.Parent=mainFrame
local mainStroke=Instance.new('UIStroke') mainStroke.Color=Color3.fromRGB(255,40,40) mainStroke.Thickness=1 mainStroke.Parent=mainFrame
local titleBar=Instance.new('Frame') titleBar.Size=UDim2.new(1,0,0,32) titleBar.BackgroundColor3=Color3.fromRGB(25,25,30) titleBar.BorderSizePixel=0 titleBar.Parent=mainFrame
local titleCorner=Instance.new('UICorner') titleCorner.CornerRadius=UDim.new(0,6) titleCorner.Parent=titleBar
local titleLabel=Instance.new('TextLabel') titleLabel.Size=UDim2.new(1,-(85),1,0) titleLabel.Position=UDim2.new(0,10,0,0) titleLabel.BackgroundTransparency=1 titleLabel.Text='VERITAS' titleLabel.TextColor3=Color3.fromRGB(255,40,40) titleLabel.TextSize=16 titleLabel.Font=Enum.Font.GothamBold titleLabel.TextXAlignment=Enum.TextXAlignment.Left titleLabel.Parent=titleBar
local badgeLabel=Instance.new('TextLabel') badgeLabel.Name='Badge' badgeLabel.Size=UDim2.new(0,42,0,18) badgeLabel.Position=UDim2.new(1,-(76),0.5,-(9)) badgeLabel.BackgroundColor3=Color3.fromRGB(38,18,22) badgeLabel.BorderSizePixel=0 badgeLabel.Font=Enum.Font.GothamBold badgeLabel.Text='S-GAG' badgeLabel.TextColor3=Color3.fromRGB(255,65,65) badgeLabel.TextSize=9 badgeLabel.Parent=titleBar
local badgeCorner=Instance.new('UICorner') badgeCorner.CornerRadius=UDim.new(0,4) badgeCorner.Parent=badgeLabel
local badgeStroke=Instance.new('UIStroke') badgeStroke.Color=Color3.fromRGB(160,30,30) badgeStroke.Thickness=1 badgeStroke.Transparency=0.2 badgeStroke.Parent=badgeLabel
local uiCollapsed=false
local collapseButton=Instance.new('TextButton') collapseButton.Size=UDim2.new(0,32,0,32) collapseButton.Position=UDim2.new(1,-(32),0,0) collapseButton.BackgroundTransparency=1 collapseButton.Text='-' collapseButton.TextColor3=Color3.fromRGB(200,200,200) collapseButton.TextSize=20 collapseButton.Font=Enum.Font.GothamBold collapseButton.Parent=titleBar
local contentFrame=Instance.new('Frame') contentFrame.Name='Content' contentFrame.Size=UDim2.new(1,-(16),1,-(40)) contentFrame.Position=UDim2.new(0,8,0,36) contentFrame.BackgroundTransparency=1 contentFrame.Parent=mainFrame
local contentLayout=Instance.new('UIListLayout') contentLayout.SortOrder=Enum.SortOrder.LayoutOrder contentLayout.Padding=UDim.new(0,4) contentLayout.Parent=contentFrame
local
function createToggle(name,initialValue,layoutOrder,onChanged)
local button=Instance.new('TextButton') button.Name=name button.Size=UDim2.new(1,0,0,28) button.LayoutOrder=layoutOrder button.BackgroundColor3=initialValue and Color3.fromRGB(180,30,30) or Color3.fromRGB(40,40,48) button.Text=name..': '..(initialValue and 'ON' or 'OFF') button.TextColor3=Color3.fromRGB(230,230,230) button.TextSize=13 button.Font=Enum.Font.GothamSemibold button.Parent=contentFrame
local corner=Instance.new('UICorner') corner.CornerRadius=UDim.new(0,4) corner.Parent=button
local value=initialValue
local
function setValue(newValue) value=newValue button.Text=name..': '..(value and 'ON' or 'OFF') button.BackgroundColor3=value and Color3.fromRGB(180,30,30) or Color3.fromRGB(40,40,48)
end button.MouseButton1Click:Connect(
function() setValue(not (value)) onChanged(value) saveConfig()
end)
return {['Button']=button,['Set']=
function(self,skipSave) setValue(self) onChanged(self)
if not (skipSave) then saveConfig()
end
end,['Get']=
function()
return value
end}
end
local
function createNumberSetting(name,initialValue,layoutOrder,onChanged)
local settingFrame=Instance.new('Frame') settingFrame.Name=name settingFrame.Size=UDim2.new(1,0,0,28) settingFrame.LayoutOrder=layoutOrder settingFrame.BackgroundColor3=Color3.fromRGB(30,30,36) settingFrame.BorderSizePixel=0 settingFrame.Parent=contentFrame
local corner=Instance.new('UICorner') corner.CornerRadius=UDim.new(0,4) corner.Parent=settingFrame
local label=Instance.new('TextLabel') label.Size=UDim2.new(0.5,0,1,0) label.Position=UDim2.new(0,8,0,0) label.BackgroundTransparency=1 label.Text=name label.TextColor3=Color3.fromRGB(180,180,180) label.TextSize=12 label.Font=Enum.Font.Gotham label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=settingFrame
local textBox=Instance.new('TextBox') textBox.Size=UDim2.new(0.4,0,0.8,0) textBox.Position=UDim2.new(0.55,0,0.1,0) textBox.BackgroundColor3=Color3.fromRGB(22,22,28) textBox.Text=tostring(initialValue) textBox.TextColor3=Color3.fromRGB(255,255,255) textBox.TextSize=12 textBox.Font=Enum.Font.GothamSemibold textBox.Parent=settingFrame
local corner=Instance.new('UICorner') corner.CornerRadius=UDim.new(0,3) corner.Parent=textBox textBox.FocusLost:Connect(
function(enterPressed)
if enterPressed then
local numberValue=tonumber(textBox.Text)
if numberValue then onChanged(numberValue) saveConfig()
else textBox.Text=tostring(initialValue)
end
end
end)
return settingFrame
end
local
function createCycleSetting(name,options,selectedIndex,layoutOrder,onChanged)
local selectedIndex=selectedIndex
local button=Instance.new('TextButton') button.Name=name button.Size=UDim2.new(1,0,0,28) button.LayoutOrder=layoutOrder button.BackgroundColor3=Color3.fromRGB(40,40,48) button.Text=name..': '..options[selectedIndex] button.TextColor3=Color3.fromRGB(230,230,230) button.TextSize=13 button.Font=Enum.Font.GothamSemibold button.Parent=contentFrame
local corner=Instance.new('UICorner') corner.CornerRadius=UDim.new(0,4) corner.Parent=button button.MouseButton1Click:Connect(
function() selectedIndex=selectedIndex%#(options)+1 button.Text=name..': '..options[selectedIndex] onChanged(options[selectedIndex]) saveConfig()
end)
return button
end
local aimbotToggle=createToggle('Aimbot',Config.Enabled,1,
function(newValue) Config.Enabled=newValue aimActive=not (Config.HoldToAim) and newValue
if not (newValue) then currentTarget=nil
end
end) createCycleSetting('Mode',{'Toggle','Hold'},Config.HoldToAim and 2 or 1,2,
function(localVar007) Config.HoldToAim=localVar007=='Hold'
if not (Config.HoldToAim) then aimActive=Config.Enabled
else aimActive=false
end
end) createCycleSetting('Target',{'Head','HumanoidRootPart'},Config.TargetPart=='HumanoidRootPart' and 2 or 1,3,
function(localVar010) Config.TargetPart=localVar010
end) createToggle('Team Check',Config.TeamCheck,4,
function(localVar017) Config.TeamCheck=localVar017
end) createToggle('Wall Check',Config.WallCheck,5,
function(localVar004) Config.WallCheck=localVar004
end) createToggle('FOV Circle',Config.ShowFOV,6,
function(localVar014) Config.ShowFOV=localVar014 fovCircle.Visible=localVar014
end) createNumberSetting('FOV',Config.FOVRadius,7,
function(localVar011) Config.FOVRadius=math.clamp(localVar011,10,800) fovCircle.Radius=Config.FOVRadius
end) createNumberSetting('Smooth',Config.Smoothing,8,
function(localVar003) Config.Smoothing=math.clamp(localVar003,0.01,1)
end)
local triggerSeparator=Instance.new('TextLabel') triggerSeparator.Name='TriggerSep' triggerSeparator.Size=UDim2.new(1,0,0,20) triggerSeparator.LayoutOrder=9 triggerSeparator.BackgroundTransparency=1 triggerSeparator.Text='-- TRIGGERBOT --' triggerSeparator.TextColor3=Color3.fromRGB(255,40,40) triggerSeparator.TextSize=11 triggerSeparator.Font=Enum.Font.GothamBold triggerSeparator.Parent=contentFrame
local triggerBotToggle=createToggle('TriggerBot',Config.TriggerBot,10,
function(enabled) Config.TriggerBot=enabled
end)
local scopeSettleSetting
local scopeFovSetting
local
function localVar006()
local localVar018=Config.TriggerMode==3
if scopeSettleSetting then scopeSettleSetting.Visible=localVar018
end
if scopeFovSetting then scopeFovSetting.Visible=localVar018
end
if not (uiCollapsed) then
local localVar012=localVar018 and 515 or 445 mainFrame.Size=UDim2.new(0,220,0,localVar012)
end
end createCycleSetting('Trigger Mode',{'Always','Hold RMB','Scoped'},Config.TriggerMode and (Config.TriggerMode<=3 and Config.TriggerMode or 3) or 1,11,
function(localVar016)
if localVar016=='Always' then Config.TriggerMode=1
elseif localVar016=='Hold RMB' then Config.TriggerMode=2
elseif localVar016=='Scoped' then Config.TriggerMode=3
else Config.TriggerMode=1
end localVar006()
end) scopeSettleSetting=createNumberSetting('Scope Settle (ms)',math.floor(Config.ScopeDelay*1000),12,
function(milliseconds)
if milliseconds>=1 then Config.ScopeDelay=math.clamp(milliseconds/1000,0.05,1)
else Config.ScopeDelay=math.clamp(milliseconds,0.05,1)
end
end) scopeFovSetting=createNumberSetting('Scope Max FOV',Config.ScopeFOV or 45,13,
function(fov) Config.ScopeFOV=math.clamp(fov,15,80)
end) createNumberSetting('Fire Delay (ms)',math.floor(Config.TriggerDelay*1000),14,
function(milliseconds)
if milliseconds>=1 then Config.TriggerDelay=math.clamp(milliseconds/1000,0,2)
else Config.TriggerDelay=math.clamp(milliseconds,0,2)
end
end)
local swapInfoLabel=Instance.new('TextLabel') swapInfoLabel.Name='SwapInfo' swapInfoLabel.Size=UDim2.new(1,0,0,22) swapInfoLabel.LayoutOrder=15 swapInfoLabel.BackgroundTransparency=1 swapInfoLabel.Text='[X] Toggle Aim <-> Trigger' swapInfoLabel.TextColor3=Color3.fromRGB(160,160,175) swapInfoLabel.TextSize=11 swapInfoLabel.Font=Enum.Font.GothamMedium swapInfoLabel.Parent=contentFrame localVar006()
local
function swapAimAndTrigger()
if Config.Enabled then
if aimbotToggle then aimbotToggle.Set(false,true)
end
if triggerBotToggle then triggerBotToggle.Set(true,false)
end
else
if aimbotToggle then aimbotToggle.Set(true,true)
end
if triggerBotToggle then triggerBotToggle.Set(false,false)
end
end
end collapseButton.MouseButton1Click:Connect(
function() uiCollapsed=not (uiCollapsed) contentFrame.Visible=not (uiCollapsed)
local expandedHeight=Config.TriggerMode==3 and 515 or 445 mainFrame.Size=uiCollapsed and UDim2.new(0,220,0,32) or UDim2.new(0,220,0,expandedHeight) collapseButton.Text=uiCollapsed and '+' or '-'
end) UserInputService.InputBegan:Connect(
function(input,gameProcessed)
if input.UserInputType==Enum.UserInputType.MouseButton2 then isRightMouseDown=true rightMouseDownTime=tick()
end
if input.KeyCode==Enum.KeyCode.F5 or input.KeyCode==Enum.KeyCode.RightShift or input.KeyCode==Enum.KeyCode.Insert then screenGui.Enabled=not (screenGui.Enabled)
return
end
if gameProcessed then
return
end
if input.KeyCode==(Config.SwapKey or Enum.KeyCode.X) then swapAimAndTrigger()
return
end
if input.UserInputType==Config.AimKey and Config.HoldToAim and Config.Enabled then aimActive=true
end
end) UserInputService.InputEnded:Connect(
function(input,gameProcessed)
if input.UserInputType==Enum.UserInputType.MouseButton2 then isRightMouseDown=false rightMouseDownTime=0
end
if gameProcessed then
return
end
if input.UserInputType==Config.AimKey and Config.HoldToAim then aimActive=false currentTarget=nil
end
end) UserInputService.WindowFocusReleased:Connect(
function() isRightMouseDown=false rightMouseDownTime=0
end) UserInputService.InputChanged:Connect(
function(input)
if input.UserInputType==Enum.UserInputType.MouseMovement then lastMouseMoveTime=tick()
end
end)
local renderConnection=RunService.RenderStepped:Connect(
function(deltaTime)
local viewportSize=Camera.ViewportSize fovCircle.Position=Vector2.new(viewportSize.X/2,viewportSize.Y/2) fovCircle.Radius=Config.FOVRadius fovCircle.Visible=Config.ShowFOV
if Config.Enabled and aimActive then
if not (isTargetValid(currentTarget)) then currentTarget=nil
end
if not (currentTarget) then currentTarget=findBestTarget()
else
local newTarget=findBestTarget()
if newTarget and newTarget~=currentTarget then currentTarget=newTarget
end
end
if currentTarget then aimAtTarget(deltaTime)
end
else currentTarget=nil
end
if Config.TriggerBot then
local shouldTrigger=false
if Config.TriggerMode==1 then shouldTrigger=true
elseif Config.TriggerMode==2 then shouldTrigger=UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or isRightMouseDown
elseif Config.TriggerMode==3 then shouldTrigger=isScoped()
end
if shouldTrigger then
local mouse=LocalPlayer:GetMouse()
local unitRay=mouse.UnitRay
local hitPlayer,hitPart,hitPosition=findTriggerTarget(unitRay.Origin,unitRay.Direction,1000)
if hitPlayer then
local now=tick()
if triggerStartTime==0 then triggerStartTime=now
end
local delayReady=now-triggerStartTime>=Config.TriggerDelay
local cooldownReady=now-lastTriggerTime>=triggerCooldown
if delayReady and cooldownReady then lastTriggerTime=now triggerStartTime=0
if mouse1press then mouse1press() task.delay(0.01,
function()
if mouse1release then mouse1release()
end
end)
elseif mouse1click then mouse1click()
else task.spawn(
function()
local virtualInputManager=game:GetService('VirtualInputManager') virtualInputManager:SendMouseButtonEvent(mouse.X,mouse.Y,0,true,game,1) task.wait(0.01) virtualInputManager:SendMouseButtonEvent(mouse.X,mouse.Y,0,false,game,1)
end)
end
end
else triggerStartTime=0
end
else triggerStartTime=0
end
else triggerStartTime=0
end
end)
local
function cleanup() pcall(
function()
if renderConnection then renderConnection:Disconnect()
end
end) pcall(
function() fovCircle:Remove()
end) pcall(
function() screenGui:Destroy()
end)
end
if _G.RaybalsCleanup then pcall(_G.RaybalsCleanup)
end _G.RaybalsCleanup=cleanup