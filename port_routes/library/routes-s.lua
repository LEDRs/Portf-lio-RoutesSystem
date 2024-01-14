------------------/ Resource /------------------
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Leo Developer - Portfólio] O Resource "..getResourceName(resource).." Foi Iniciado Com Sucesso!")
end)

------------------/ Comandos /------------------
addCommandHandler("pos", function(player)
    local posX, posY, posZ = getElementPosition(player)
    outputChatBox("x = "..posX..", y = "..posY..", z = "..posZ)
end)

------------------/ Iniciar Rotas /------------------
local markers = {}

for i, v in ipairs(CONFIG.MARKERS_START) do
    local marker_ = createMarker(v.x, v.y, v.z -1, "cylinder", 1.5, 255, 255, 255, 255)
    markers["marker"] = marker_
end

addEventHandler("onMarkerHit", markers["marker"], function(player)
    local accName = getAccountName(getPlayerAccount(player))
    for i, v in ipairs(CONFIG.MARKERS_START) do
        if (isObjectInACLGroup("user."..accName, aclGetGroup(v.acl))) then
            exports["port_infobox"]:addNotification(player, "Digite /"..CONFIG.COMMAND_START.." Para Iniciar a Rota", "info")
        end
    end
end)

addCommandHandler(CONFIG.COMMAND_START, function(player)
    local accName = getAccountName(getPlayerAccount(player))
    local dataRota = getElementData(player, "EmRota")
    local dataMarker = getElementData(player, "MarkerID")

    for i, v in ipairs(CONFIG.MARKERS_START) do
        if (isObjectInACLGroup("user."..accName, aclGetGroup(v.acl))) then
            if (isElementWithinMarker(player, markers["marker"])) then
                if (not dataRota) then
                    setElementData(player, "EmRota", true)
                    exports["port_infobox"]:addNotification(player, "Rota Iniciada Com Sucesso!")
                    processRoute(player)
                else
                    exports["port_infobox"]:addNotification(player, "Você já está em uma rota!", "error")
                end
            else
                exports["port_infobox"]:addNotification(player, "Você Precisa Ir No Marker Para Iniciar a Rota!", "error")
            end
        else
            exports["port_infobox"]:addNotification(player, "Você Não Possui Permissão Para Iniciar a Rota", "error")
        end
    end
end)

function processRoute(player)
    local currentMarker = 1
    local markers = {}

    for _, v in ipairs(CONFIG.MARKERS) do
        local nextMarker = createMarker(v.x, v.y, v.z - 1, "cylinder", 1.5, 255, 255, 255, 255)
        setElementData(nextMarker, "MarkerID", currentMarker)
        local blip = createBlip(v.x, v.y, v.z, 4)

        table.insert(markers, {marker = nextMarker, blip = blip})
        
        addEventHandler("onMarkerHit", nextMarker, function()
            exports["port_infobox"]:addNotification(player, "Aguarde...", "info")
            setPedAnimation(player, "bomber", "bom_plant_crouch_in", -1, true, false, false, false)
            local moneyGive = math.random(3500, 10800)
            local money = givePlayerMoney(player, moneyGive)
            setTimer(
                function()
                    destroyElement(markers[currentMarker].marker)
                    destroyElement(markers[currentMarker].blip)
                    exports["port_infobox"]:addNotification(player, "Ganho Nessa Rota: "..moneyGive..", Vá Para o Próximo Local Em Seu GPS!", "info")
                    currentMarker = currentMarker + 1
                    setPedAnimation(player)

                    if currentMarker > #CONFIG.MARKERS then
                        exports["port_infobox"]:addNotification(player, "Rota Finalizada Com Sucesso!")
                        removeElementData(player, "EmRota")
                    end
                end,
                5000,
                1
            )
        end)
    end
end