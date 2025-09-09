-- Script protegido (GitHub)

-- checa se foi carregado no ambiente certo
if not getfenv(1)["xA9k32_f"] then
    game.Players.LocalPlayer:Kick("Script inválido")
    return
end

-- referência segura de funções importantes (anti-sobrescrita)
local _print = print
local _kick = game.Players.LocalPlayer.Kick

-- função crítica
local function coreFunc()
    _print("Script rodando com segurança ✅")
end

-- anti-removal simples: se coreFunc for removida, jogo fecha
task.spawn(function()
    while task.wait(2) do
        if not coreFunc then
            _kick(game.Players.LocalPlayer, "Função removida / script corrompido")
            break
        end
    end
end)

-- execução principal
coreFunc()
