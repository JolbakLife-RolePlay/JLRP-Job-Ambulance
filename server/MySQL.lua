if Config.AutoAdjustDatabaseWithConfigJob then
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == RESOURCENAME then
            for k, v in pairs(Config.Job) do
                
                --jobs & job_grades
                local jobName = k
                local jobLabel = v.Label
                local jobResult = MySQL.single.await('SELECT * FROM jobs WHERE name = ?', { jobName })
                if jobResult then
                    if jobResult.label ~= jobLabel then
                        MySQL.update.await('UPDATE jobs SET label = ? WHERE name = ?', { jobLabel, jobName })
                    end
                else
                    MySQL.insert.await('INSERT INTO jobs (name, label, whitelisted) VALUES (?, ?, ?)', { jobName, jobLabel, 1 })
                end
                
                local tkeys = {}
                -- populate the table that holds the keys
                for j in pairs(v.Grades) do table.insert(tkeys, j) end
                -- sort the keys
                table.sort(tkeys)

                for l in ipairs(tkeys) do
                    local key = l - 1
                    local rank = v.Grades[tostring(key)]

                    local grade = tonumber(key)
                    local gradeName = rank.Name
                    local gradeLabel = rank.Label
                    local gradeSalary = rank.Salary
                    local gradeHasAccessToBossMenu = rank.AccessToBossMenu or false
                    gradeHasAccessToBossMenu = gradeHasAccessToBossMenu == true and 1 or 0

                    local gradeResult = MySQL.prepare.await('SELECT * FROM job_grades WHERE job_name = ? AND grade = ?', { jobName, grade })
                    if gradeResult and #gradeResult > 1 then MySQL.prepare.await('DELETE FROM job_grades WHERE job_name = ? AND grade = ?', { jobName, grade }) gradeResult = false end
                    if gradeResult then
                        if FRAMEWORKNAME == 'JLRP-Framework' then
                            if gradeResult.name ~= gradeName or gradeResult.label ~= gradeLabel or gradeResult.is_boss ~= gradeHasAccessToBossMenu or gradeResult.salary ~= gradeSalary then
                                MySQL.update.await('UPDATE job_grades SET name = ?, label = ?, is_boss = ?, salary = ? WHERE job_name = ? AND grade = ?', { gradeName, gradeLabel, gradeHasAccessToBossMenu, gradeSalary, jobName, grade })
                            end
                        else
                            if gradeResult.name ~= gradeName or gradeResult.label ~= gradeLabel or gradeResult.salary ~= gradeSalary then
                                MySQL.update.await('UPDATE job_grades SET name = ?, label = ?, salary = ? WHERE job_name = ? AND grade = ?', { gradeName, gradeLabel, gradeSalary, jobName, grade })
                            end
                        end
                    else
                        if FRAMEWORKNAME == 'JLRP-Framework' then
                            MySQL.insert.await('INSERT INTO job_grades (job_name, grade, name, label, is_boss, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', { jobName, grade, gradeName, gradeLabel, gradeHasAccessToBossMenu, gradeSalary, '{}', '{}' })
                        else
                            MySQL.insert.await('INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)', { jobName, grade, gradeName, gradeLabel, gradeSalary, '{}', '{}' })

                        end
                    end
                end

                --society & addons & datastore
                local addonAccountResult = MySQL.single.await('SELECT * FROM addon_account WHERE name = ?', { jobName })
                if addonAccountResult then
                    if addonAccountResult.label ~= jobLabel or addonAccountResult.shared ~= 1 then
                        MySQL.update.await('UPDATE addon_account SET label = ?, shared = ? WHERE name = ?', { jobLabel, 1, jobName })
                    end
                else
                    MySQL.insert.await('INSERT INTO addon_account (name, label, shared) VALUES (?, ?, ?)', { jobName, jobLabel, 1 })
                end

                local addonInventoryResult = MySQL.single.await('SELECT * FROM addon_inventory WHERE name = ?', { jobName })
                if addonInventoryResult then
                    if addonInventoryResult.label ~= jobLabel or addonInventoryResult.shared ~= 1 then
                        MySQL.update.await('UPDATE addon_inventory SET label = ?, shared = ? WHERE name = ?', { jobLabel, 1, jobName })
                    end
                else
                    MySQL.insert.await('INSERT INTO addon_inventory (name, label, shared) VALUES (?, ?, ?)', { jobName, jobLabel, 1 })
                end

                local datastoreResult = MySQL.single.await('SELECT * FROM datastore WHERE name = ?', { jobName })
                if datastoreResult then
                    if datastoreResult.label ~= jobLabel or datastoreResult.shared ~= 1 then
                        MySQL.update.await('UPDATE datastore SET label = ?, shared = ? WHERE name = ?', { jobLabel, 1, jobName })
                    end
                else
                    MySQL.insert.await('INSERT INTO datastore (name, label, shared) VALUES (?, ?, ?)', { jobName, jobLabel, 1 })
                end
            end
        end
    end)
end