-- Services
local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Настройки
local friendColor  = Color3.fromRGB(0, 200, 0)   -- цвет для своих
local enemyColor   = Color3.fromRGB(200, 0, 0)   -- цвет для врагов
local fillTrans    = 0.6                         -- прозрачность заливки (0 = сплошной, 1 = невидимый)
local outlineTrans = 1.0                         -- прозрачность контура (1 = нет контура)

-- Хранение Highlight для каждого игрока
local highlights = {}

-- Функция создания/обновления chams для персонажа
local function applyChams(player)
    local character = player.Character
    if not character then return end

    -- Удаляем старый Highlight (если есть)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end

    -- Создаём новый Highlight
    local hl = Instance.new("Highlight")
    hl.Adornee           = character
    hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency  = fillTrans
    hl.OutlineTransparency = outlineTrans
    -- задаём цвет в зависимости от команды
    if player ~= LocalPlayer and player.Team == LocalPlayer.Team then
        hl.FillColor = friendColor
    else
        hl.FillColor = enemyColor
    end
    hl.Parent = character

    highlights[player] = hl
end

-- Следим за появлением персонажа у каждого игрока
local function onPlayerAdded(player)
    -- если персонаж уже есть (при старте)
    if player.Character then
        applyChams(player)
    end

    -- при спавне персонажа
    player.CharacterAdded:Connect(function()
        -- небольшая задержка, чтобы модель полностью загрузилась
        wait(0.1)
        applyChams(player)
    end)

    -- если игрок сменил команду — обновляем цвет
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if highlights[player] then
            if player.Team == LocalPlayer.Team then
                highlights[player].FillColor = friendColor
            else
                highlights[player].FillColor = enemyColor
            end
        end
    end)
end

-- Убираем Highlight при выходе игрока
local function onPlayerRemoving(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end

-- Подписываемся на существующих и новых игроков
for _, pl in ipairs(Players:GetPlayers()) do
    onPlayerAdded(pl)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
