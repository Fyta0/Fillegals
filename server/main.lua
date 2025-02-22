ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('Fillegals:getInventory', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  local items   = xPlayer.inventory
  local accounts =  nil
  local data  = nil

  cb({items = items})

end)

RegisterServerEvent("Fillegals:depositItems")
AddEventHandler("Fillegals:depositItems", function(item, count)
  local xPlayer = ESX.GetPlayerFromId(source)
if count > 0 then
        xPlayer.removeInventoryItem(item, count)
        giveMoney(count * Config.CountMoney)
        giveBonus(count * Config.BonusMoney)
      else
        TriggerClientEvent('esx:showNotification', _source, "Invalid Quantity")
      end
end)

RegisterServerEvent("Fillegals:checkInventory")
AddEventHandler("Fillegals:checkInventory", function()
  if hasItems() then
    TriggerClientEvent("Fillegals:openInventory", source)
  else
   print("test")
    end
end)

function giveMoney(money)
  ESX.GetPlayerFromId(source).addMoney(money)
end

function giveBonus(bonus)
    ESX.GetPlayerFromId(source).addMoney(bonus)
end

function hasItems()
  local xPlayer = ESX.GetPlayerFromId(source)
  local drugs = false
 

  for i,v in ipairs(Config.Items) do
    local inventoryItem = xPlayer.getInventoryItem(v)

    if inventoryItem then
      if inventoryItem.count > 0 then
        drugs = true
      end
    else 
    TriggerClientEvent('esx:showNotification', source, 'L\'objet : ~y~' .. v .. ' ~s~Dans le config n\'existe pas' , 'error', 10000)
    end
  end

  if drugs then
    return true
  else
    TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez rien a détruire', 'info', 10000)
    return false
  end
end
