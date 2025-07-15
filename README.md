<p align="center">
  <h1 align="center"><big>PlayerMouse</big></h1>
</p>

**PlayerMouse** is a Roblox Module that re-implements the [Mouse instance](https://create.roblox.com/docs/reference/engine/classes/Mouse) but more customizable and provides more parameters for connected functions to work with.<br>
The module can also easily integrate with existing code, thanks to a similar structure but more up-to-date with extra features like `mouse.TargetFilterArray` and `mouse.MousePos`

**PlayerMouse** also includes more parameters for connected functions, like for `mouse.WheelForward` and `mouse.WheelBackward` without interfering with any existing parameters.

Example Usage:
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerMouse = require(ReplicatedStorage.PlayerMouse)

local player = Players.LocalPlayer
local mouse = PlayerMouse.New()

mouse.Button2Up:Connect(function()
	print("Button2Up")
end)

mouse.WheelForward:Connect(function(...)
	print("Scroll wheel forward", ...)
end)

mouse.WheelBackward:Connect(function(...)
	print("Scroll wheel backward", ...)
end)
```

Created by [Zalthen](https://www.roblox.com/users/1377987741/profile)
