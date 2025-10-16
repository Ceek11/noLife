function FUN_OPEN_CHEST_MENU(chestData)
    exports.ox_inventory:openInventory('stash', {id = chestData.name, owner = false})
end