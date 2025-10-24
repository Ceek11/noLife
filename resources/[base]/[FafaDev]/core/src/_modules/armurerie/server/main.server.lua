TBL_ARMURERIE = {}
local str_file_location = 'data/armurerie.json'

function FUN_LOAD_ARMURERIE()
    local str_file_content = LoadResourceFile(GetCurrentResourceName(), str_file_location)
    if str_file_content then
        local tbl_armurerie = json.decode(str_file_content)
        for _, armurerie in pairs(tbl_armurerie) do
            TBL_ARMURERIE[armurerie.name] = armurerie
        end
    end
end

CORE.register_server_callback("fafadev:to_server:get_armurerie", function(source, cb)
    cb(TBL_ARMURERIE)
end)

CORE.register_server_callback("fafadev:to_server:get_armurerie_weapons", function(source, cb, society)
    MySQL.Async.fetchAll("SELECT * FROM armurerie_weapons WHERE society = ?", {society}, function(result)
        if result and #result > 0 then
            local weapons = json.decode(result[1].weapons)
            local cleanWeapons = {}
            
            for _, weapon in pairs(weapons) do
                if weapon.quantity > 0 then
                    table.insert(cleanWeapons, weapon)
                end
            end
            
            if #cleanWeapons ~= #weapons then
                if #cleanWeapons > 0 then
                    MySQL.Async.execute("UPDATE armurerie_weapons SET weapons = ? WHERE society = ?", {
                        json.encode(cleanWeapons), society
                    })
                else
                    MySQL.Async.execute("DELETE FROM armurerie_weapons WHERE society = ?", {society})
                end
            end
            
            cb(cleanWeapons)
        else
            cb({})
        end
    end)
end)

CORE.register_server_event("fafadev:to_server:buyWeapon", function(source, weaponName, quantity, price, society, requiredGrade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local totalPrice = price * quantity
    local grade = requiredGrade or 0
    
    MySQL.Async.fetchAll("SELECT money FROM addon_account_data WHERE account_name = ?", {"society_" .. society}, function(accountResult)
        if accountResult and #accountResult > 0 then
            local companyMoney = accountResult[1].money
            if companyMoney >= totalPrice then
                MySQL.Async.execute("UPDATE addon_account_data SET money = money - ? WHERE account_name = ?", {
                    totalPrice, "society_" .. society
                })
                
                MySQL.Async.fetchAll("SELECT * FROM armurerie_weapons WHERE society = ?", {society}, function(result)
                    local weapons = {}
                    if result and #result > 0 then
                        weapons = json.decode(result[1].weapons)
                    end
                    
                    local found = false
                    for i, weapon in pairs(weapons) do
                        if weapon.weapon == weaponName and weapon.grade == grade then
                            weapons[i].quantity = weapons[i].quantity + quantity
                            found = true
                            break
                        end
                    end
                    
                    if not found then
                        table.insert(weapons, {
                            weapon = weaponName,
                            grade = grade,
                            quantity = quantity
                        })
                    end
                    
                    if result and #result > 0 then
                        MySQL.Async.execute("UPDATE armurerie_weapons SET weapons = ? WHERE society = ?", {
                            json.encode(weapons), society
                        })
                    else
                        MySQL.Async.execute("INSERT INTO armurerie_weapons (society, weapons) VALUES (?, ?)", {
                            society, json.encode(weapons)
                        })
                    end
                end)
                
                local gradeText = grade > 0 and string.format(" (Grade %d+)", grade) or ""
                TriggerClientEvent('esx:showNotification', source, string.format("Vous avez acheté %dx %s%s pour %d$ (payé par l'entreprise)", quantity, weaponName, gradeText, totalPrice))
                
                TriggerClientEvent('fafadev:to_client:refresh_armurerie', -1)
                
            else
                TriggerClientEvent('esx:showNotification', source, "L'entreprise n'a pas assez d'argent !")
            end
        else
            TriggerClientEvent('esx:showNotification', source, "Compte entreprise introuvable !")
        end
    end)
end)

CORE.register_server_event("fafadev:to_server:takeWeapon", function(source, weaponName, society, requiredGrade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local playerGrade = 0
    if xPlayer.job and xPlayer.job.name == society then
        playerGrade = xPlayer.job.grade
    elseif xPlayer.job2 and xPlayer.job2.name == society then
        playerGrade = xPlayer.job2.grade
    end
    
    if requiredGrade > 0 and playerGrade < requiredGrade then
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas le grade requis pour cette arme !")
        return
    end
    
    MySQL.Async.fetchAll("SELECT * FROM armurerie_weapons WHERE society = ?", {society}, function(result)
        if result and #result > 0 then
            local weapons = json.decode(result[1].weapons)
            local found = false
            
            local normalizedWeaponName = weaponName
            if string.find(weaponName, "WEAPON_") then
                normalizedWeaponName = string.lower(weaponName)
            end
            
            for i, weapon in pairs(weapons) do
                local normalizedStockWeapon = weapon.weapon
                if string.find(weapon.weapon, "WEAPON_") then
                    normalizedStockWeapon = string.lower(weapon.weapon)
                end
                
                if normalizedStockWeapon == normalizedWeaponName and weapon.grade == requiredGrade then
                    if weapon.quantity > 0 then
                        weapons[i].quantity = weapons[i].quantity - 1
                        
                        xPlayer.addInventoryItem(weaponName, 1)
                        
                        local cleanWeapons = {}
                        for _, w in pairs(weapons) do
                            if w.quantity > 0 then
                                table.insert(cleanWeapons, w)
                            end
                        end
                        
                        if #cleanWeapons > 0 then
                            MySQL.Async.execute("UPDATE armurerie_weapons SET weapons = ? WHERE society = ?", {
                                json.encode(cleanWeapons), society
                            })
                        else
                            MySQL.Async.execute("DELETE FROM armurerie_weapons WHERE society = ?", {society})
                        end
                        
                        TriggerClientEvent('esx:showNotification', source, string.format("Vous avez récupéré 1x %s", weaponName))
                        
                        TriggerClientEvent('fafadev:to_client:refresh_armurerie', -1)
                        
                        found = true
                        break
                    else
                        TriggerClientEvent('esx:showNotification', source, "Cette arme n'est plus en stock !")
                        found = true
                        break
                    end
                end
            end
            
            if not found then
                TriggerClientEvent('esx:showNotification', source, "Cette arme n'est pas disponible dans le stock !")
            end
        else
            TriggerClientEvent('esx:showNotification', source, "Aucun stock disponible !")
        end
    end)
end)

CORE.register_server_event("fafadev:to_server:depositWeapon", function(source, weaponName, quantity, society, requiredGrade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local grade = 0
    if xPlayer.job and xPlayer.job.name == society then
        grade = xPlayer.job.grade
    elseif xPlayer.job2 and xPlayer.job2.name == society then
        grade = xPlayer.job2.grade
    end
    
    local playerItem = xPlayer.getInventoryItem(weaponName)
    if not playerItem or playerItem.count < quantity then
        TriggerClientEvent('esx:showNotification', source, string.format("Vous n'avez pas %dx %s dans votre inventaire !", quantity, weaponName))
        return
    end
    
    xPlayer.removeInventoryItem(weaponName, quantity)
    
    MySQL.Async.fetchAll("SELECT * FROM armurerie_weapons WHERE society = ?", {society}, function(result)
        local weapons = {}
        if result and #result > 0 then
            weapons = json.decode(result[1].weapons)
        end
        
        local found = false
        for i, weapon in pairs(weapons) do
            if weapon.weapon == weaponName and weapon.grade == grade then
                weapons[i].quantity = weapons[i].quantity + quantity
                found = true
                break
            end
        end
        
        if not found then
            table.insert(weapons, {
                weapon = weaponName,
                grade = grade,
                quantity = quantity
            })
        end
        
        if result and #result > 0 then
            MySQL.Async.execute("UPDATE armurerie_weapons SET weapons = ? WHERE society = ?", {
                json.encode(weapons), society
            })
        else
            MySQL.Async.execute("INSERT INTO armurerie_weapons (society, weapons) VALUES (?, ?)", {
                society, json.encode(weapons)
            })
        end
        
        local gradeText = grade > 0 and string.format(" (Grade %d+)", grade) or ""
        TriggerClientEvent('esx:showNotification', source, string.format("Vous avez déposé %dx %s%s dans le stock", quantity, weaponName, gradeText))
        
        TriggerClientEvent('fafadev:to_client:refresh_armurerie', -1)
    end)
end)

CORE.register_server_callback("fafadev:to_server:getPlayerWeapons", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb({})
        return 
    end
    
    local weapons = {}
    local inventory = xPlayer.getInventory()
    
    for _, item in pairs(inventory) do
        if item.name and (string.find(item.name, "weapon_") or string.find(item.name, "WEAPON_")) then
            local normalizedName = item.name
            if string.find(item.name, "WEAPON_") then
                normalizedName = string.lower(item.name)
            end
            table.insert(weapons, {
                name = normalizedName,
                label = item.label or item.name,
                count = item.count
            })
        end
    end
    cb(weapons)
end)


