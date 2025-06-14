return function(parentFrame, particleCount, maxDistance)
	local RunService = game:GetService("RunService")

	-- Configurações
	particleCount = particleCount or 30
	maxDistance = maxDistance or 100

	-- Cria partículas (pequenos frames)
	local particles = {}
	for i = 1, particleCount do
		local p = Instance.new("Frame")
		p.Size = UDim2.new(0, 3, 0, 3)
		p.Position = UDim2.new(0, math.random(0, parentFrame.AbsoluteSize.X), 0, math.random(0, parentFrame.AbsoluteSize.Y))
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.BorderSizePixel = 0
		p.BackgroundTransparency = 0.2
		p.Parent = parentFrame
		p.ZIndex = 1
		particles[#particles + 1] = {
			frame = p,
			velocity = Vector2.new(math.random(-1,1), math.random(-1,1))
		}
	end

	-- Renderiza as partículas e linhas
	RunService.RenderStepped:Connect(function()
		for i, a in ipairs(particles) do
			local f = a.frame
			local pos = f.Position
			local vel = a.velocity

			-- Move
			local newX = pos.X.Offset + vel.X
			local newY = pos.Y.Offset + vel.Y

			-- Rebote nas bordas
			if newX < 0 or newX > parentFrame.AbsoluteSize.X then a.velocity = Vector2.new(-vel.X, vel.Y) end
			if newY < 0 or newY > parentFrame.AbsoluteSize.Y then a.velocity = Vector2.new(vel.X, -vel.Y) end

			f.Position = UDim2.new(0, math.clamp(newX, 0, parentFrame.AbsoluteSize.X), 0, math.clamp(newY, 0, parentFrame.AbsoluteSize.Y))
		end

		-- (Opcional) Desenhar linhas entre partículas próximas
		-- Skipped por performance dentro de UI; seria necessário desenhar com `Drawing` API (usado fora da UI).
	end)
end
