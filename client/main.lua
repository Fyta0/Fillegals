local PlayerData = {}

-- Initialisation ESX
Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    ESX.PlayerData.job = job
end)


Citizen.CreateThread(function()
	while true do
    Wait(0)
    
    for _, v in pairs(Config.Zones) do 

      local coords = GetEntityCoords(GetPlayerPed(-1))
      local dist   = Vdist(coords.x, coords.y, coords.z, v.x, v.y, v.z)

      if ESX.PlayerData.job.name == Config.JobName then
        DrawMarker(v.type, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.501, 1.5001, 0.5001, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
        
        if dist <= 1.5 then
          AddTextEntry('HELP_NOTIFICATION', 'Appuyez sur ~INPUT_CONTEXT~ pour interagir')
                    DisplayHelpTextThisFrame('HELP_NOTIFICATION', false)

          if IsControlJustPressed(0, 38) then
            TriggerServerEvent("Fillegals:checkInventory")
          end
        end
      end
    end
  end
end)

RegisterNetEvent("Fillegals:openInventory")
AddEventHandler("Fillegals:openInventory", function()
  openInventory()
end)

RegisterNetEvent('selectelement', function(data)
local itemName = data.itemName
    local itemLabel = data.itemLabel
    local itemCount = data.itemCount

    local input = lib.inputDialog("Entrez la quantité à détruire", {
        {type = 'number', label = 'Quantité à détruire', required = true, min = 1, max = itemCount, placeholder = 'Entrez la quantité'}
    })

    if not input then
        ESX.ShowNotification("Action annulée.")
        return
    end

    local amount = tonumber(input[1])

    if amount > 0 then
        if amount > itemCount then
            ESX.ShowNotification("Vous ne pouvez pas détruire plus que ce que vous possédez.", 'error', 10000)
            else
                TriggerServerEvent('Fillegals:depositItems', itemName, amount)
                lib.hideContext(true)
            end
            else
            ESX.ShowNotification("Quantité invalide !")
            end
    openInventory()
end)

function openInventory()
    
    local elements = {}
    local elements2 = {}

    ESX.TriggerServerCallback('Fillegals:getInventory', function(result)

        table.insert(elements, {
            title = "Destruction d'object illégal",
            value = "deposit"
        })

        for i = 1, #result.items, 1 do
            local invitem = result.items[i]
            
            for k, v in ipairs(Config.Items) do
                if invitem.count > 0 and invitem.name == v then
                    
                    local itemImage = ('nui://ox_inventory/web/images/' .. invitem.name .. '.png')  -- Image de l'item
                    table.insert(elements2, {
                        title = invitem.count .. ' x ' .. invitem.label,
                        value = invitem.name,
                        count = invitem.count,
                        icon = itemImage,  -- L'URL de l'icône
                        event = 'selectelement',
                        args = {                 
                            itemName = invitem.name,
                            itemLabel = invitem.label,
                            itemCount = invitem.count
                        }
                    })
                end
            end
        end    

        if #elements2 > 0 then

            lib.registerContext({
                id = 'destroy_menu',
                title = "DESTRUCTION",
                canClose = true,
                options = {
                    {
                        title = "Détruire des objects illégaux",
                        description = "Sélectionner un object",
                        menu = 'deposit_menu',  -- Ouvrir un sous-menu pour détruire
                        icon = 'trash',
                    },
                    
                }
            })

            lib.registerContext({
                id = 'deposit_menu',
                title = "Sélectionner un object",
                menu = 'destroy_menu',
                onBack = function()
                end,
                options = elements2,
            })

            lib.showContext('destroy_menu')
        else
            ESX.ShowNotification("~r~Vous n'avez aucun object valide à détruire.")
        end

    end)
end
