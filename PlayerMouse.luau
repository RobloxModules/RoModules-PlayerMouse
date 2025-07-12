-- a custom implementation of roblox's Mouse object
-- one that supports more features & is up-to-date
-- and can also easily integrate with existing mouse object code
--
-- Zalthen

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Mouse = {}
Mouse.__index = Mouse

function Mouse.New(player: Player, hitRange: number?)
	local self = setmetatable({}, Mouse)
	self.Events = {}
	self.Player = player
	
	self.HitRange = (typeof(hitRange) == "number") and hitRange or 4096
	self.Hit = CFrame.new()
	self.Origin = CFrame.new()
	self.UnitRay = CFrame.new()
	self.Icon = UserInputService.MouseIcon
	self.__PreviousIcon = UserInputService.MouseIcon
	
	self.TargetFilterArray = {}
	self.TargetFilter = nil
	self.TargetSurface = nil
	self.Target = nil
	
	self.__PreviousMousePos = Vector2.new(0, 0)
	self.MousePos = Vector2.new(0, 0)
	self.X = 0
	self.Y = 0
	
	self.__TimestampSinceLastNonIdle = 0
	self.TimeIdle = 0
	
	self.__MoveBindable = Instance.new("BindableEvent")
	self.__IdleBindable = Instance.new("BindableEvent")
	
	self.__Button1Down = Instance.new("BindableEvent")
	self.__Button2Down = Instance.new("BindableEvent")
	
	self.__Button1Up = Instance.new("BindableEvent")
	self.__Button2Up = Instance.new("BindableEvent")
	
	self.__WheelForward = Instance.new("BindableEvent")
	self.__WheelBackward = Instance.new("BindableEvent")
	
	self.__KeyDown = Instance.new("BindableEvent")
	self.__KeyUp = Instance.new("BindableEvent")
	
	self.Events[1] = RunService.PreRender:Connect(function()
		self.MousePos = UserInputService:GetMouseLocation()
		self.X = self.MousePos.X
		self.Y = self.MousePos.Y
		
		local hasEventFired = false
		if self.MousePos ~= self.__PreviousMousePos then
			self.__MoveBindable:Fire(self.MousePos, self.__PreviousMousePos)
			hasEventFired = true
		end
		
		if not hasEventFired then
			self.TimeIdle = os.clock() - self.__TimestampSinceLastNonIdle
			self.__IdleBindable:Fire(self.__TimestampSinceLastNonIdle)
		else
			self.__TimestampSinceLastNonIdle = os.clock()
			self.TimeIdle = 0
		end
		
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.FilterDescendantsInstances = self.TargetFilterArray or {}
		
		if self.TargetFilter then
			table.insert(rayParams.FilterDescendantsInstances, self.TargetFilter)
		end
		
		local camera = workspace.CurrentCamera
		local ray = camera:ViewportPointToRay(self.X, self.Y)
		
		local rayResult = workspace:Raycast(ray.Origin, ray.Direction * self.HitRange, rayParams)
		if rayResult and rayResult.Instance then
			self.Hit = CFrame.lookAt(rayResult.Position, rayResult.Position + ray.Direction)
			self.TargetSurface = rayResult.Normal
			self.Target = rayResult.Instance
		else
			self.Hit = CFrame.lookAt(ray.Origin + (ray.Direction * self.HitRange), ray.Origin + (ray.Direction * (self.HitRange + 1)))
			self.TargetSurface = nil
			self.Target = nil
		end
		
		if self.Icon ~= self.__PreviousIcon then
			UserInputService.MouseIcon = self.Icon
		else
			self.Icon = UserInputService.MouseIcon
		end
		
		self.UnitRay = CFrame.lookAt(ray.Origin, ray.Origin + (ray.Direction.Unit))
		self.Origin = CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
		
		self.__PreviousMousePos = self.MousePos
		self.__PreviousIcon = self.Icon
	end)
	
	self.Events[2] = UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.__Button1Down:Fire()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.__Button2Down:Fire()
		end
		
		if input.KeyCode then
			self.__KeyDown:Fire(input.KeyCode.Name)
		end
	end)
	
	self.Events[3] = UserInputService.InputChanged:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if input.Position.Z > 0 then
				self.__WheelForward:Fire(input.Position.Z)
			elseif input.Position.Z < 0 then
				self.__WheelBackward:Fire(input.Position.Z)
			end
		end
	end)
	
	self.Events[4] = UserInputService.InputEnded:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.__Button1Up:Fire()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.__Button2Up:Fire()
		end
		
		if input.KeyCode then
			self.__KeyUp:Fire(input.KeyCode.Name)
		end
	end)
	
	self.Move = {
		Connect = function(_, callback)
			return self.__MoveBindable.Event:Connect(callback)
		end
	}
	
	self.Idle = {
		Connect = function(_, callback)
			return self.__IdleBindable.Event:Connect(callback)
		end
	}
	
	self.Button1Down = {
		Connect = function(_, callback)
			return self.__Button1Down.Event:Connect(callback)
		end
	}
	
	self.Button2Down = {
		Connect = function(_, callback)
			return self.__Button2Down.Event:Connect(callback)
		end
	}
	
	self.Button1Up = {
		Connect = function(_, callback)
			return self.__Button1Up.Event:Connect(callback)
		end
	}
	
	self.Button2Up = {
		Connect = function(_, callback)
			return self.__Button2Up.Event:Connect(callback)
		end
	}
	
	self.WheelForward = {
		Connect = function(_, callback)
			return self.__WheelForward.Event:Connect(callback)
		end
	}
	
	self.WheelBackward = {
		Connect = function(_, callback)
			return self.__WheelBackward.Event:Connect(callback)
		end
	}
	
	
	self.KeyDown = {
		Connect = function(_, callback)
			warn("Using deprecated event 'mouse.KeyDown', please use 'UserInputService.InputBegan' instead.")
			warn("This event also has a slightly different behavior, the event fires for all keys.")
			return self.__KeyDown.Event:Connect(callback)
		end	
	}
	
	self.KeyUp = {
		Connect = function(_, callback)
			warn("Using deprecated event 'mouse.KeyUp', please use 'UserInputService.InputEnded' instead.")
			warn("This event also has a slightly different behavior, the event fires for all keys.")
			return self.__KeyUp.Event:Connect(callback)
		end
	}
	
	return self
end

function Mouse:Destroy()
	self.__MoveBindable:Destroy()
	self.__IdleBindable:Destroy()
	
	for i, event in ipairs(self.Events) do
		event:Disconnect()
		self.Events[i] = nil
	end
	
	self = nil
end

return Mouse
