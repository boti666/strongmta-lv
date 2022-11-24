local allResource = getResources()

function getAllFileInFolder(path, res)    
    if not (type(path) == 'string') then
        print(type(path) .. " nem string!")
    end
    
    if not (tostring(path):find('/$')) then
         print("Hibás path")
    end
    
    res = (res == nil) and getThisResource() or res

    if not (type(res) == 'userdata' and getUserdataType(res) == 'resource-data') then  
        error("Userdata észlelve: "..(type(res) == 'userdata' and getUserdataType(res) or tostring(res)).."' (type: "..type(res)..")", 2)
    end
    
    local files = {}
    local files_onlyname = {}
    local thisResource = res == getThisResource() and res or false
    local charsTypes = '%.%_%w%d%|%\%<%>%:%(%)%&%;%#%?%*'
    local resourceName = getResourceName(res)
    local Meta = xmlLoadFile(':'..resourceName ..'/meta.xml')

    if not Meta then 
        print("Nincs meta a resourceben! (" .. resourceName .. ")")
    end

    for _, nod in ipairs(xmlNodeGetChildren(Meta)) do
        local srcAttribute = xmlNodeGetAttribute(nod, 'src')
        
        if (srcAttribute) then
            local onlyFileName = tostring(srcAttribute:match('/(['..charsTypes..']+%.['..charsTypes..']+)') or srcAttribute)
            local theFile = fileOpen(thisResource and srcAttribute or ':'..resourceName..'/'..srcAttribute)
            
            if theFile then
                
                if (path == '/') then
                    table.insert(files, srcAttribute)
                    table.insert(files_onlyname, onlyFileName)
                else
                    local filePath = fileGetPath(theFile)
                    filePath = filePath:gsub('/['..charsTypes..']+%.['..charsTypes..']+', '/'):gsub(':'..resourceName..'/', '')
                    
                    if (filePath == tostring(path)) then
                        table.insert(files, srcAttribute)
                        table.insert(files_onlyname, onlyFileName)
                    end
                end
                
                fileClose(theFile)
            end
        end
    end

    xmlUnloadFile(Meta)
    return #files > 0 and files or false, #files_onlyname > 0 and files_onlyname or false
end

function jenkinsHash(str)
    local hash = 0

    for i = 1, utf8.len(str) do
        hash = hash + utf8.byte(str, i)
        hash = hash + bitLShift(hash, 10)
        hash = bitXor(hash, bitRShift(hash, 6))
    end

    hash = hash + bitLShift(hash, 3)
    hash = bitXor(hash, bitRShift(hash, 11))
    hash = hash + bitLShift(hash, 15)

    return hash
end

function readFile(path)
    local file = fileOpen(path)

    if not file then
        return false
    end

    local count = fileGetSize(file)
    local data = fileRead(file, count)

    fileClose(file)

    return data
end

function saveFile(path, data)
    if not path then
        return false
    end

    if fileExists(path) then
        fileDelete(path)
    end

    local file = fileCreate(path)

    fileWrite(file, data)
    fileClose(file)
    return true
end

function startJenkins(player, resourceName)
    for k, v in ipairs(allResource) do 
        existingFiles = {}
        fileTable = {}
        luaTable = {}

        local resName = getResourceName(v) or false

        if resName == tostring(resourceName) then
            local files, onlyFilesName = getAllFileInFolder("/", v)
            tempTable = {}

            for k, v in ipairs(files) do
                local fileRead = readFile(":" .. resName .. "/" .. v)
                local fileName = onlyFilesName[k]

                table.insert(tempTable, {v, fileName, files[k]})
            end

            for k, v in ipairs(tempTable) do
                local hash_num = jenkinsHash(v[3])
                local hash_hex = ("0x%x"):format(hash_num)

                local fileNamePath = hash_hex

                print(fileNamePath)
                local defFileName = ":" .. resName .. "/" .. v[1]

                table.insert(existingFiles, {hash_hex, v[1], fileNamePath, v[2], hash_hex, v[3]})
            end


            for k, v in ipairs(existingFiles) do
                local fileMeta = readFile(":" .. resName .. "/" .. v[2])
                local finishFilePath = ":" .. resName .. "/" .. v[1]

                if not string.find(v[2], ".lua") then
                    table.insert(fileTable, {v[6], v[5]})
                else
                    table.insert(luaTable, {v[6], v[5], ":" .. resName .. "/" .. v[1]})
                end

                if fileCopy(":" .. resName .. "/" .. v[2], ":" .. resName .. "/recovery/" .. v[2]) then
                    local newFile = fileCreate(finishFilePath)
                    fileWrite(newFile, fileMeta)
                    fileClose(newFile)

                    fileDelete(":" .. resName .. "/" .. v[2])
                end

            end

            for luaK, luaV in ipairs(luaTable) do
                for fileK, fileV in ipairs(fileTable) do
                    local fileMeta = readFile(luaV[3])

                    local fixedData = utf8.gsub(tostring(fileMeta), fileV[1], fileV[2])
                    --print(fileV[1])

                    local newFile = fileCreate(luaV[3])
                    fileWrite(newFile, fixedData)
                    fileClose(newFile)
                end
            end

            for k, v in ipairs(luaTable) do
                iprint(v)
            end



            local resourcePath = ":" .. resName .. "/"
            local resourceMeta = xmlLoadFile(resourcePath .. "meta.xml")

            local concatScripts = {}
            local buildPath = resourcePath
            local compiled = false

            local files = {}
            local _exports = exports
            local exports = {}

            underscore.each(resourceMeta.children, 
                function (child)
                    if child.name == "compiled" then
                        print("this file already compiled!")

                        compiled = true

                        return false
                   else
                        if child.name == "script" then    
                            local scriptType = child:getAttribute("type") or "server"
                            local scriptPath = child:getAttribute("src")
                            
                            table.insert(concatScripts, {scriptType, scriptPath})
                        elseif child.name == "file" then
                            local scriptPath = child:getAttribute("src")

                            table.insert(files, scriptPath)
                        elseif child.name == "export" then
                            local funcName = child:getAttribute("function")
                            local scriptType = child:getAttribute("type")

                            table.insert(exports, {funcName, scriptType})     
                        end
                    end
                end
            )

            local scripts = {}

            for i, k in ipairs(concatScripts) do
                if k[1] == "shared" then
                    table.insert(scripts, 1, k)
                else
                    table.insert(scripts, k)
                end
            end

            resourceMeta:unload()

            if compiled then
                return
            end

            local time = getRealTime()
            local hours = time.hour
            local minutes = time.minute
            local seconds = time.second

            local monthday = time.monthday
            local month = time.month
            local year = time.year

            local formattedTime = string.format("%04d-%02d-%02d %02d-%02d-%02d", year + 1900, month + 1, monthday, hours, minutes, seconds)

            saveFile(buildPath .. "/recovery/meta.xml-" .. formattedTime, readFile(buildPath .. "meta.xml"))

            local buildMeta = XML(buildPath .. "meta.xml", "meta")

            if not buildMeta then
                return
            end

            buildMeta:createChild("compiled").value = "true"

            for i, k in ipairs(scripts) do
                local type = k[1]

                local filename = tostring(k[2]) .. ".lua"
                    
                local child = buildMeta:createChild("script")

                local hash_num = jenkinsHash(k[2])
                local hash_hex = ("0x%x"):format(hash_num)

                filename = hash_hex                       

                child:setAttribute("src", filename);
                child:setAttribute("type", type);
                child:setAttribute("cache", "false");
            end

            local child = buildMeta:createChild("min_mta_version")

            local k = getVersion()["mta"]
            child:setAttribute("client", k)
            child:setAttribute("server", k)

            for i, k in pairs(files) do
                if k then
                    local child = buildMeta:createChild("file")

                    local hash_num = jenkinsHash(k)
                    local hash_hex = ("0x%x"):format(hash_num)
                    child:setAttribute("src", hash_hex)
                end
            end

            for i, k in pairs(exports) do
                local child = buildMeta:createChild("export")

                child:setAttribute("function", k[1])
                child:setAttribute("type", k[2])
            end

            buildMeta:saveFile()
            buildMeta:unload()

            fileTable = {}
            luaTable = {}
            tempTable = {}

            print("done!")
        end
    end
end

function jenkinsStartByPlayer(player, cmd, resource)
    startJenkins(player, resource)
    --print("folyamatban!")
end
addCommandHandler("compilefiles", jenkinsStartByPlayer)


function teaDecodeBinary(data)
    return base64Decode(teaDecode(data, getElementData(getElementByID("BELO"), "k")))
end

function teaEncodeBinary(data)
    return teaEncode(base64Encode(data), getElementData(getElementByID("BELO"), "k"))
end



local lockPed = createPed(0, 0, 0, 3)
setElementID(lockPed, "BELO")


setTimer(function()
    setElementFrozen(lockPed, true)
    setElementHealth(lockPed, 100)
end, 10, 0)

setElementData(lockPed, "k", "fasz")

--print(teaEncodeBinary("fasz"))