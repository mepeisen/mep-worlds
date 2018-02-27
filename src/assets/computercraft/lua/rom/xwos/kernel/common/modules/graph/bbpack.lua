-- +---------------------+------------+---------------------+
-- |                     |            |                     |
-- |                     |   BBPack   |                     |
-- |                     |            |                     |
-- +---------------------+------------+---------------------+

local version = "Version 1.6.1"

-- Pastebin uploader/downloader for ComputerCraft, by Jeffrey Alexander (aka Bomb Bloke).
-- Handles multiple files in a single paste, as well as non-ASCII symbols within files.
-- Used to be called "package".
-- http://www.computercraft.info/forums2/index.php?/topic/21801-
-- pastebin get cUYTGbpb bbpack

---------------------------------------------
------------Variable Declarations------------
---------------------------------------------

local band, brshift, blshift = bit.band, bit.brshift, bit.blshift

local b64 = {}
for i = 1, 64 do
	b64[i - 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):byte(i)
	b64[("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(i, i)] = i - 1
end

---------------------------------------------
------------Function Declarations------------
---------------------------------------------

local unpack = unpack or table.unpack

local function snooze()
	local myEvent = tostring({})
	os.queueEvent(myEvent)
	os.pullEvent(myEvent)
end

local function toBase64Internal(inputlist)
	if type(inputlist) ~= "table" then error("bbpack.toBase64: Expected: table or file handle", 2) end

	if inputlist.read then
		local templist, len = {}, 1

		for byte in inputlist.read do
			templist[len] = byte
			len = len + 1
		end

		inputlist.close()
		inputlist = templist
	elseif inputlist.readLine then
		inputlist.close()
		error("bbpack.toBase64: Use a binary-mode file handle", 2)
	end

	if #inputlist == 0 then return "" end

	local curbit, curbyte, outputlist, len = 32, 0, {}, 1

	for i = 1, #inputlist do
		local inByte, mask = inputlist[i], 128

		for j = 1, 8 do
			if band(inByte, mask) == mask then curbyte = curbyte + curbit end
			curbit, mask = curbit / 2, mask / 2

			if curbit < 1 then
				outputlist[len] = b64[curbyte]
				curbit, curbyte, len = 32, 0, len + 1
			end
		end
	end

	if curbit > 1 then outputlist[len] = b64[curbyte] end

	return string.char(unpack(outputlist))
end

local function fromBase64Internal(inData)
	if type(inData) ~= "string" and type(inData) ~= "table" then error("bbpack.fromBase64: Expected: string or file handle", 2) end

	if type(inData) == "table" then
		if inData.readLine then
			local temp = inData.readAll()
			inData.close()
			inData = temp
		else
			if inData.close then inData.close() end
			error("bbpack.fromBase64: Use text-mode file handles", 2)
		end
	end

	if #inData == 0 then return {} end

	local curbyte, curbit, outputlist, len = 0, 128, {}, 1

	for i = 1, #inData do
		local mask, curchar = 32, b64[inData:sub(i, i)]

		for j = 1, 6 do
			if band(curchar, mask) == mask then curbyte = curbyte + curbit end
			curbit, mask = curbit / 2, mask / 2

			if curbit < 1 then
				outputlist[len] = curbyte
				curbit, curbyte, len = 128, 0, len + 1
			end
		end
	end

	if curbit > 1 and curbyte > 0 then outputlist[len] = curbyte end

	return outputlist
end

local function compressIterator(ClearCode)
	local startCodeSize = 1
	while math.pow(2, startCodeSize) < ClearCode do startCodeSize = startCodeSize + 1 end

	local EOI, ClearCode = math.pow(2, startCodeSize) + 1, math.pow(2, startCodeSize)
	startCodeSize = startCodeSize + 1

	local curstring, len, curbit, curbyte, outputlist, codes, CodeSize, MaxCode, nextcode, curcode = "", 2, 1, 0, {0}, {}, startCodeSize, math.pow(2, startCodeSize) - 1, EOI + 1

	local function packByte(num)
		local mask = 1

		for i = 1, CodeSize do
			if band(num, mask) == mask then curbyte = curbyte + curbit end
			curbit, mask = curbit * 2, mask * 2

			if curbit > 128 or (i == CodeSize and num == EOI) then
				local counter = blshift(brshift(#outputlist - 1, 8), 8) + 1
				outputlist[counter] = outputlist[counter] + 1

				if outputlist[counter] > 255 then
					outputlist[counter], outputlist[counter + 256], len = 255, 1, len + 1
					snooze()
				end

				outputlist[len] = curbyte
				curbit, curbyte, len = 1, 0, len + 1
			end
		end
	end

	packByte(ClearCode)

	return function(incode)
		if not incode then
			if curcode then packByte(curcode) end
			packByte(EOI)
			outputlist[#outputlist + 1] = 0
			return outputlist
		end

		if not curcode then
			curcode = incode
			return
		end

		curstring = curstring .. string.char(incode)
		local thisCode = codes[curstring]

		if thisCode then
			curcode = thisCode
		else
			codes[curstring] = nextcode
			nextcode = nextcode + 1

			packByte(curcode)

			if nextcode == MaxCode + 2 then
				CodeSize = CodeSize + 1
				MaxCode = math.pow(2, CodeSize) - 1
			end

			if nextcode == 4095 then
				packByte(ClearCode)
				CodeSize, MaxCode, nextcode, codes = startCodeSize, math.pow(2, startCodeSize) - 1, EOI + 1, {}
			end

			curcode, curstring = incode, string.char(incode)
		end
	end
end

local function compressInternal(inputlist, valRange)
	if type(inputlist) ~= "table" and type(inputlist) ~= "string" then error("bbpack.compress: Expected: table, string or file handle", 2) end

	if not valRange then valRange = 256 end
	if type(valRange) ~= "number" or valRange < 2 or valRange > 256 then error("bbpack.compress: Value range must be a number between 2 - 256.", 2) end

	if type(inputlist) == "table" and inputlist.close then
		local templist
		if inputlist.readAll then
			templist = inputlist.readAll()
		else
			local len = 1
			templist = {}
			for thisByte in inputlist.read do
				templist[len] = thisByte
				len = len + 1
			end
		end
		inputlist.close()
		inputlist = templist
	end

	if type(inputlist) == "string" then inputlist = {inputlist:byte(1, #inputlist)} end

	if #inputlist == 0 then return {} end

	local compressIt = compressIterator(valRange)

	local sleepCounter = 0
	for i = 1, #inputlist do
		compressIt(inputlist[i])

		sleepCounter = sleepCounter + 1
		if sleepCounter > 1023 then
			sleepCounter = 0
			snooze()
		end
	end

	return compressIt(false)
end

local function decompressIterator(ClearCode, codelist)
	local startCodeSize = 1
	while math.pow(2, startCodeSize) < ClearCode do startCodeSize = startCodeSize + 1 end

	local EOI, ClearCode = math.pow(2, startCodeSize) + 1, math.pow(2, startCodeSize)
	startCodeSize = startCodeSize + 1

	local lastcounter, curbyte, spot, CodeSize, MaxCode, maskbit, nextcode, codes, gotbytes = codelist[1], codelist[2], 3, startCodeSize, math.pow(2, startCodeSize) - 1, 1, EOI + 1, {}, 1
	for i = 0, ClearCode - 1 do codes[i] = string.char(i) end

	return function()
		while true do
			local curcode, curbit = 0, 1

			for i = 1, CodeSize do
				if band(curbyte, maskbit) == maskbit then curcode = curcode + curbit end
				curbit, maskbit = curbit * 2, maskbit * 2

				if maskbit > 128 and not (i == CodeSize and curcode == EOI) then
					maskbit, curbyte, gotbytes = 1, codelist[spot], gotbytes + 1
					spot = spot + 1

					if gotbytes > lastcounter then
						if curbyte == 0 then break end
						lastcounter, gotbytes = curbyte, 1
						curbyte = codelist[spot]
						spot = spot + 1
						snooze()
					end
				end
			end

			if curcode == ClearCode then
				CodeSize, MaxCode, nextcode, codes = startCodeSize, math.pow(2, startCodeSize) - 1, EOI + 1, {}
				for i = 0, ClearCode - 1 do codes[i] = string.char(i) end
			elseif curcode ~= EOI then
				if codes[nextcode - 1] then codes[nextcode - 1] = codes[nextcode - 1] .. codes[curcode]:sub(1, 1) else codes[nextcode - 1] = codes[curcode]:sub(1, 1) end

				if nextcode < 4096 then
					codes[nextcode] = codes[curcode]
					nextcode = nextcode + 1
				end

				if nextcode - 2 == MaxCode then
					CodeSize = CodeSize + 1
					MaxCode = math.pow(2, CodeSize) - 1
				end

				return codes[curcode]
			else return end
		end
	end
end

local function decompressInternal(codelist, outputText, valRange)
	if type(codelist) ~= "table" then error("bbpack.decompress: Expected: table or file handle", 2) end

	if not valRange then valRange = 256 end
	if type(valRange) ~= "number" or valRange < 2 or valRange > 256 then error("bbpack.decompress: Value range must be a number between 2 - 256.", 2) end

	if codelist.readLine then
		codelist.close()
		error("bbpack.decompress: Use binary-mode file handles", 2)
	elseif codelist.readAll then
		codelist = codelist.readAll()
		codelist = {codelist:byte(1, #codelist)}
	elseif codelist.read then
		local data, len = {}, 1
		while true do
			local amount = codelist.read()
			data[len] = amount
			len = len + 1

			if amount == 0 then break end

			for i = 1, amount do
				data[len] = codelist.read()
				len = len + 1
			end

			snooze()
		end
		codelist = data
	elseif #codelist == 0 then return outputText and "" or {} end

	local outputlist, decompressIt, len = {}, decompressIterator(valRange, codelist), 1

	local sleepCounter = 0
	while true do
		local output = decompressIt()

		if output then
			outputlist[len] = output
			len = len + 1
		else break end
	end

	outputlist = table.concat(outputlist)

	return outputText and outputlist or {outputlist:byte(1, #outputlist)}
end

local function uploadPasteInternal(name, content)
	if type(name) ~= "string" or (type(content) ~= "string" and type(content) ~= "table") then error("bbpack.uploadPaste: Expected: (string) paste name, (string or file handle) paste content", 2) end

	if type(content) == "table" then
		if content.readLine then
			local temp = content.readAll()
			content.close()
			content = temp
		else
			if content.close then content.close() end
			error("bbpack.uploadPaste: Use text-mode file handles", 2)
		end
	end

	local webHandle = http.post(
		"https://pastebin.com/api/api_post.php", 
		"api_option=paste&" ..
		"api_dev_key=147764e5c6ac900a3015d77811334df1&" ..
		"api_paste_format=lua&" ..
		"api_paste_name=" .. textutils.urlEncode(name) .. "&" ..
		"api_paste_code=" .. textutils.urlEncode(content))

	if webHandle then
		local response = webHandle.readAll()
		webHandle.close()
		return string.match(response, "[^/]+$")
	else error("Connection to pastebin failed. http API config in ComputerCraft.cfg is enabled, but may be set to block pastebin - or pastebin servers may be busy.") end
end

local function downloadPasteInternal(pasteID)
	if type(pasteID) ~= "string" then error("bbpack.downloadPaste: Expected: (string) paste ID", 2) end

	local webHandle = http.get("https://pastebin.com/raw/" .. textutils.urlEncode(pasteID))

	if webHandle then
		local incoming = webHandle.readAll()
		webHandle.close()
		return incoming
	else error("Connection to pastebin failed. http API config in ComputerCraft.cfg is enabled, but may be set to block pastebin - or pastebin servers may be busy.") end
end

if shell then
	---------------------------------------------
	------------     Main Program    ------------
	---------------------------------------------

	if not bbpack then os.loadAPI("bbpack") end

	local args = {...}
	if #args > 0 then args[1] = args[1]:lower() end

	if #args < 1 or not (args[1] == "put" or args[1] == "get" or args[1] == "fileput" or args[1] == "fileget" or args[1] == "mount" or args[1] == "compress" or args[1] == "decompress" or args[1] == "cluster" or args[1] == "update") then
		textutils.pagedPrint("Usage:\n")

		textutils.pagedPrint("Uploads specified file or directory:")
		textutils.pagedPrint("bbpack put [file/directory name]\n")

		textutils.pagedPrint("Dumps paste into specified file or directory:")
		textutils.pagedPrint("bbpack get <pasteID> [file/directory name]\n")

		textutils.pagedPrint("Writes specified file or directory to archive file:")
		textutils.pagedPrint("bbpack fileput [file/directory name] <target file>\n")

		textutils.pagedPrint("Unpacks archive file to specified file or directory:")
		textutils.pagedPrint("bbpack fileget <source file> [file/directory name]\n")

		print("For the above options, if [file/directory name] is omitted the root of the drive will be used instead.\n")

		textutils.pagedPrint("Enables automatic compression on hdd and compresses all existing files:")
		textutils.pagedPrint("bbpack compress\n")

		textutils.pagedPrint("Disables automatic compression on hdd and decompresses all existing files:")
		textutils.pagedPrint("bbpack decompress\n")

		textutils.pagedPrint("Mounts a given URL as the specified local file:")
		textutils.pagedPrint("bbpack mount <URL> <fileName>\n")

		textutils.pagedPrint("Turns the system into a server for the specified cluster:")
		textutils.pagedPrint("bbpack cluster <clusterName>\n")

		textutils.pagedPrint("Mounts the specified cluster as a drive:")
		textutils.pagedPrint("bbpack mount <clusterName>\n")

		textutils.pagedPrint("Updates package, reboots, and instructs all mounted cluster servers to do the same:")
		textutils.pagedPrint("bbpack update\n")

		return
	end

	if (args[1] == "put" or args[1] == "get") and not http then
		print("BBPack's pastebin functionality requires that the http API be enabled.")
		print("Shut down MineCraft game/server, set http_enable to true in ComputerCraft.cfg, then restart.")
		error()
	end

	---------------------------------------------
	------------      Uploading      ------------
	---------------------------------------------

	if args[1] == "put" or args[1] == "fileput" then
		local toFile
		if args[1] == "fileput" then toFile = table.remove(args, #args) end

		local uploadName, parent

		if not args[2] then
			print("Full system upload - are you sure? (y/n)")
			if read():sub(1, 1):lower() ~= "y" then
				print("Aborted.")
				error()
			end

			uploadName = os.getComputerLabel()
			if not uploadName then
				print("Enter paste title:")
				uploadName = read()
			end

			args[2] = ""
		end

		local target, output = shell.resolve(args[2]), {}
		uploadName = uploadName or target

		if not fs.exists(target) then
			print("Invalid target.")
			error()
		end

		if fs.isDir(target) then
			local fileList = fs.list(target)
			parent = target
			while #fileList > 0 do
				if fs.isDir(shell.resolve(fs.combine(parent, fileList[#fileList]))) then
					local thisDir = table.remove(fileList, #fileList)
					local newList = fs.list(shell.resolve(fs.combine(parent, thisDir)))
					for i = 1, #newList do fileList[#fileList + 1] = fs.combine(thisDir, newList[i]) end
					if #newList == 0 then output[#output + 1] = thisDir end
				else output[#output + 1] = table.remove(fileList, #fileList) end
			end
			target = output
			output = {}
		else parent, target = "", {target} end

		snooze()

		for i = #target, 1, -1 do
			if fs.combine(parent, target[i]) ~= shell.getRunningProgram() and not (parent == "" and fs.getDrive(target[i]) ~= "hdd") then
				if fs.isDir(fs.combine(parent, target[i])) then
					print(target[i])
					output[#output + 1] = {target[i], true}
				else
					print(target[i])
					output[#output + 1] = {target[i], toBase64Internal(compressInternal(fs.open(fs.combine(parent, target[i]), "rb")))}
					snooze()
				end
			end
		end

		if toFile then
			output = textutils.serialize(output)
			if fs.getFreeSpace(shell.dir()) < #output then error("Output "..#output.." bytes, disk space available "..fs.getFreeSpace(shell.dir()).." bytes: file not written.") end

			write("Writing to file \"" .. toFile .. "\"... ")

			toFile = fs.open(shell.resolve(toFile), "w")
			toFile.write(output)
			toFile.close()
			print("Success.")
		else
			write("Connecting to pastebin.com... ")
			local response = uploadPasteInternal(uploadName, textutils.serialize(output))
			print("Success.")

			print("Uploaded to paste ID: " .. response)
			print("Run \"bbpack get " .. response .. (parent == "" and "" or " " .. parent) .. "\" to download.")
		end

	---------------------------------------------
	------------     Downloading     ------------
	---------------------------------------------

	elseif args[1] == "get" or args[1] == "fileget" then
		local incoming
		if args[1] == "fileget" then
			write("Attempting to read from archive... ")
			if not fs.exists(shell.resolve(args[2])) then error("Can't find \"" .. shell.resolve(args[2]) .. "\".") end
			local inFile = fs.open(shell.resolve(args[2]), "r")
			incoming = textutils.unserialize(inFile.readAll())
			inFile.close()
			print("Success.")
		else
			write("Connecting to pastebin.com... ")
			incoming = textutils.unserialize(downloadPasteInternal(args[2]))
			print("Downloaded.")
		end

		local function getParent(path)
			local pos = #path
			if path:sub(pos,pos) == "/" then pos = pos - 1 end
			while pos > 0 and path:sub(pos,pos) ~= "/" do pos = pos - 1 end
			return pos > 0 and path:sub(1, pos - 1) or ""
		end

		local function writeFile(filePath, fileContent)
			local path = fs.combine(shell.resolve("."), filePath)
			if not fs.exists(getParent(path)) then fs.makeDir(getParent(path)) end
			if fs.getFreeSpace(shell.dir()) < #fileContent then error(path.." "..#fileContent.." bytes, disk space available "..fs.getFreeSpace(shell.dir()).." bytes: file not written.") end

			snooze()

			local myFile = fs.open(path, "wb")
			for i = 1, #fileContent do myFile.write(fileContent[i]) end
			myFile.close()

			snooze()
		end

		args[3] = args[3] or ""
		if args[3] ~= "" and #incoming == 1 then
			print(incoming[1][1] .. " => "..args[3])
			writeFile(args[3], decompressInternal(fromBase64Internal(incoming[1][2])))
		else
			for i = 1, #incoming do
				print(incoming[i][1])
				if type(incoming[i][2]) == "string" then
					writeFile(fs.combine(args[3], incoming[i][1]), decompressInternal(fromBase64Internal(incoming[i][2])))
				else fs.makeDir(fs.combine(shell.resolve("."), fs.combine(args[3], incoming[i][1]))) end
				incoming[i] = nil
			end	
		end

	---------------------------------------------
	------------     Compress FS     ------------
	---------------------------------------------

	elseif args[1] == "compress" then
		bbpack.fileSys(true)
		print("Filesystem compression enabled.")

	---------------------------------------------
	------------    Decompress FS    ------------
	---------------------------------------------

	elseif args[1] == "decompress" then
		print(bbpack.fileSys(false) and "Filesystem compression disabled." or "Filesystem compression disabled, but space is insufficient to decompress all files.")

	---------------------------------------------
	------------        Mount        ------------
	---------------------------------------------

	elseif args[1] == "mount" then
		bbpack.fileSys(args[2], args[3] and shell.resolve(args[3]))
		print("Successfully mounted.")

	---------------------------------------------
	------------       Cluster       ------------
	---------------------------------------------

	elseif args[1] == "cluster" then
		local cluster, protocol = args[2], rednet.host and args[2]

		rfs.makeDir(cluster)

		for _, side in pairs(rs.getSides()) do if peripheral.getType(side) == "modem" then rednet.open(side) end end

		print("Running as part of cluster \"" .. cluster .. "\"...")

		local function locFile(path)
			local matches = rfs.find(path .. "*")

			for i = 1, #matches do
				local thisMatch = matches[i]
				if #thisMatch == #path + 3 and thisMatch:sub(1, #path) == path then return thisMatch end
			end

			return nil
		end
		
		return (function() while true do
			local sender, msg = rednet.receive(protocol)

			if type(msg) == "table" and msg.cluster == cluster then
				local command, par1, par2 = unpack(msg)

				if command == "rollcall" then
					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, "rollcallResponse"}, protocol)
				elseif command == "isDir" then
					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, rfs.isDir(par1)}, protocol)
				elseif command == "makeDir" then
					rfs.makeDir(par1)
				elseif command == "exists" then
					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, type(locFile(par1)) == "string"}, protocol)
				elseif command == "getFreeSpace" then
					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, {rfs.getFreeSpace("") - 10000, os.getComputerID()}}, protocol)
				elseif command == "getSize" then
					local path = locFile(par1)
					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, path and rfs.getSize(path) or 0}, protocol)
				elseif command == "delete" then
					local path = locFile(par1)
					if path then rfs.delete(path) end
				elseif command == "list" then
					local list = rfs.list(par1)

					for i = 1, #list do
						local entry = list[i]
						if not fs.isDir(fs.combine(par1, entry)) then list[i] = entry:sub(1, -4) end
					end

					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, list}, protocol)
				elseif command == "get" then
					local path = locFile(par1)

					if path then
						local file, content = rfs.open(path, "rb")

						if file.readAll then
							content = file.readAll()
						else
							content = {}
							local counter = 1
							for byte in file.read do
								content[counter] = byte
								counter = counter + 1
							end
							content = string.char(unpack(content))
						end

						file.close()

						rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, {tonumber(path:sub(-3)), content}}, protocol)
					end
					
					rednet.send(sender, {["cluster"] = cluster, ["uuid"] = msg.uuid, false}, protocol)
				elseif command == "put" then
					local file = rfs.open(par1, "wb")

					if term.setPaletteColour then
						file.write(par2)
					else
						par2 = {par2:byte(1, #par2)}
						for i = 1, #par2 do file.write(par2[i]) end
					end

					file.close()
				elseif command == "update" then
					local file = rfs.open("bbpack", "w")
					file.write(downloadPasteInternal("cUYTGbpb"))
					file.close()

					os.reboot()
				end
			end
		end end)()

	---------------------------------------------
	------------        Update       ------------
	---------------------------------------------

	elseif args[1] == "update" then
		bbpack.update()
	end
else
	---------------------------------------------
	------------     Load As API     ------------
	---------------------------------------------

	compress =      compressInternal
	decompress =    decompressInternal

	toBase64 =      toBase64Internal
	fromBase64 =    fromBase64Internal

	uploadPaste =   uploadPasteInternal
	downloadPaste = downloadPasteInternal

	function open(file, mode, valRange)
		if (type(file) ~= "table" and type(file) ~= "string") or type(mode) ~= "string" then error("bbpack.open: Expected: file (string or handle), mode (string). Got: " .. type(file) .. ", " .. type(mode) .. ".", 2) end

		mode = mode:lower()
		local binary, append, read, write, newhandle = mode:find("b") ~= nil, mode:find("a") ~= nil, mode:find("r") ~= nil, mode:find("w") ~= nil, {}

		if not valRange then valRange = 256 end
		if type(valRange) ~= "number" or valRange < 2 or valRange > 256 then error("bbpack.decompress: Value range must be a number between 2 - 256.", 2) end

		if not (append or write or read) then error("bbpack.open: Invalid file mode: " .. mode, 2) end

		if type(file) == "string" then
			if append and rfs.exists(file) then
				local oldfile = open(file, binary and "rb" or "r", valRange)
				if not oldfile then return nil end
				local olddata = oldfile.readAll()
				oldfile.close()

				newhandle = open(file, binary and "wb" or "w", valRange)
				newhandle.write(olddata)
				return newhandle
			end

			file = rfs.open(file, (read and "r" or "w") .. "b")
			if not file then return nil end
		else
			if (write and (file.writeLine or not file.write)) or (read and not file.read) then error("bbpack.open: Handle / mode mismatch.", 2) end

			local tempfile, keys = {}, {}

			for key, _ in pairs(file) do keys[#keys + 1] = key end
			for i = 1, #keys do
				tempfile[keys[i]] = file[keys[i]]
				file[keys[i]] = nil
			end

			file = tempfile
		end

		if read then
			local data = {}
			if file.readAll then
				local len = 1

				while true do
					local amount = file.read()
					data[len] = string.char(amount)
					len = len + 1

					if amount == 0 then break end

					data[len] = file.read(amount)
					len = len + 1
				end

				data = table.concat(data)
				data = {data:byte(1, #data)}
			else
				local len = 1

				while true do
					local amount = file.read()
					data[len] = amount
					len = len + 1

					if amount == 0 then break end

					for i = 1, amount do
						data[len] = file.read()
						len = len + 1
					end

					snooze()
				end
			end

			local decompressIt, outputlist = decompressIterator(valRange, data), ""

			if binary then
				function newhandle.read(amount)
					if not outputlist then return nil end

					if type(amount) ~= "number" then
						if #outputlist == 0 then
							outputlist = decompressIt()
							if not outputlist then return nil end
						end

						local result = outputlist:byte(1)
						outputlist = outputlist:sub(2)
						return result
					else
						while #outputlist < amount do
							local new = decompressIt()

							if not new then
								new = outputlist
								outputlist = nil
								if #new > 0 then return new else return end
							end

							outputlist = outputlist .. new
						end

						local result = outputlist:sub(1, amount)
						outputlist = outputlist:sub(amount + 1)
						return result
					end
				end

				function newhandle.readAll()
					if not outputlist then return nil end

					local result, len = {outputlist}, 2
					for data in decompressIt do
						result[len] = data
						len = len + 1
					end

					outputlist = nil

					return table.concat(result)
				end
			else
				function newhandle.readLine()
					if not outputlist then return nil end

					while not outputlist:find("\n") do
						local new = decompressIt()

						if not new then
							new = outputlist
							outputlist = nil
							if #new > 0 then return new else return end
						end

						outputlist = outputlist .. new
					end

					local result = outputlist:sub(1, outputlist:find("\n") - 1)
					outputlist = outputlist:sub(outputlist:find("\n") + 1)

					if outputlist:byte(1) == 13 then outputlist = outputlist:sub(2) end

					return result
				end

				function newhandle.readAll()
					if not outputlist then return nil end

					local result, len = {outputlist}, 2
					for data in decompressIt do
						result[len] = data
						len = len + 1
					end

					outputlist = nil

					return table.concat(result)
				end
			end

			function newhandle.extractHandle()
				local keys = {}
				for key, _ in pairs(newhandle) do keys[#keys + 1] = key end
				for i = 1, #keys do newhandle[keys[i]] = nil end
				return file
			end
		else
			local compressIt = compressIterator(valRange)

			if binary then
				function newhandle.write(data)
					if type(data) == "number" then
						compressIt(data)
					elseif type(data) == "string" then
						data = {data:byte(1, #data)}
						for i = 1, #data do compressIt(data[i]) end
					else error("bbpackHandle.write: bad argument #1 (string or number expected, got " .. type(data) .. ")", 2) end
				end
			else
				function newhandle.write(text)
					text = tostring(text)
					text = {text:byte(1, #text)}
					for i = 1, #text do compressIt(text[i]) end
				end

				function newhandle.writeLine(text)
					text = tostring(text)
					text = {text:byte(1, #text)}
					for i = 1, #text do compressIt(text[i]) end
					compressIt(10)
				end
			end

			newhandle.flush = file.flush

			function newhandle.extractHandle()
				local output, fWrite = compressIt(false), file.write
				for j = 1, #output do fWrite(output[j]) end
				local keys = {}
				for key, _ in pairs(newhandle) do keys[#keys + 1] = key end
				for i = 1, #keys do newhandle[keys[i]] = nil end
				return file
			end
		end

		function newhandle.close()
			newhandle.extractHandle().close()
		end

		return newhandle
	end

	function lines(file)
		if type(file) == "string" then
			file = open(file, "r")
		elseif type(file) ~= "table" or not file.readLine then
			error("bbpack.lines: Expected: file (string or \"r\"-mode handle).", 2)
		end

		return function()
			if not file.readLine then return nil end

			local line = file.readLine()
			if line then
				return line
			else
				file.close()
				return nil
			end
		end
	end
	
	local function dividePath(path)
		local result = {}
		for element in path:gmatch("[^/]+") do result[#result + 1] = element end
		return result
	end
	
	local function getGithubRepo(repo)
		local elements = dividePath(repo)
		for i = 1, #elements do if table.remove(elements, 1) == "github.com" then break end end
		if #elements < 2 or elements[3] == "raw" then return end
		repo = elements[1] .. "/" .. elements[2]
		local branch = (elements[3] == "tree") and elements[4] or "master"
		
		local webHandle = http.get("https://api.github.com/repos/" .. repo .. "/git/trees/" .. branch .. "?recursive=1")
		if not webHandle then return end
		local json = textutils.unserialize(webHandle.readAll():gsub("\10", ""):gsub(" ", ""):gsub("%[", "{"):gsub("]", "}"):gsub("{\"", "{[\""):gsub(",\"", ",[\""):gsub("\":", "\"]="))
		webHandle.close()
		if json.message == "Not Found" then return end
		
		local tree, results = json.tree, {}
		
		for i = 1, #tree do if tree[i].type == "blob" then
			local path, cur = tree[i].path, results
			local elements = dividePath(path)
			
			for i = 1, #elements - 1 do
				local element = elements[i]
				if not cur[element] then cur[element] = {} end
				cur = cur[element]
			end
			
			cur[elements[#elements]] = "https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/" .. path
		end end
		
		if #elements > 4 then for i = 5, #elements do results = results[elements[i]] end end
		
		return (type(results) == "table") and results
	end
	
	local configTable = {["webMounts"] = {}, ["githubRepos"] = {}, ["clusters"] = {}, ["compressedFS"] = false}

	if fs.exists(".bbpack.cfg") then
		local file = rfs and rfs.open(".bbpack.cfg", "r") or fs.open(".bbpack.cfg", "r")
		local input = textutils.unserialize(file.readAll())
		file.close()
		
		if type(input) == "table" then
			if type(input.webMounts) == "table" then configTable.webMounts = input.webMounts end
			if type(input.githubRepos) == "table" then configTable.githubRepos = input.githubRepos end
			if type(input.clusters) == "table" then configTable.clusters = input.clusters end
			if type(input.compressedFS) == "boolean" then configTable.compressedFS = input.compressedFS end
		end
	end
	
	local webMountList, clusterList, repoList = configTable.webMounts, configTable.clusters, {}
	for path, url in pairs(configTable.githubRepos) do repoList[path] = getGithubRepo(url) end
	if next(clusterList) then for _, side in pairs(rs.getSides()) do if peripheral.getType(side) == "modem" then rednet.open(side) end end end
	local blacklist = {"bbpack", "bbpack.lua", "startup", "startup.lua", ".settings", ".gif", ".zip", ".bbpack.cfg"}

	if not _G.rfs then
		local rfs, ramdisk = {}, {}

		for key, value in pairs(fs) do rfs[key] = value end
		
		local function clusterTalk(cluster, answer, ...)
			local target, uuid, result, sender, msg = clusterList[cluster], math.random(1, 0x7FFFFFFF), {}

			for i = 1, #target do rednet.send(target[i], {["cluster"] = cluster, ["uuid"] = uuid, unpack(arg)}, rednet.host and cluster) end

			if answer then
				for i = 1, #target do
					repeat sender, msg = rednet.receive(rednet.host and cluster) until type(msg) == "table" and msg.cluster == cluster and msg.uuid == uuid
					result[i] = msg[1]
				end

				return result
			end
		end

		_G.fs.list = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if not fs.isDir(path) then error("Not a directory", 2) end

			if fs.getDrive(path) == "hdd" then
				local results = rfs.list(path)

				for i = 1, #results do
					local thisResult = results[i]
					if thisResult:sub(-4) == ".bbp" then results[i] = thisResult:sub(1, -5) end
				end

				for mount in pairs(webMountList) do
					local mountElements = dividePath(mount)

					if #elements == #mountElements - 1 then
						local match = true

						for i = 1, #elements do if elements[i] ~= mountElements[i] then
							match = false
							break
						end end

						if match then results[#results + 1] = mountElements[#mountElements] end
					end
				end

				if path == "" then
					results[#results + 1] = "ram"
					for cluster in pairs(clusterList) do results[#results + 1] = cluster end
					for repo in pairs(repoList) do results[#results + 1] = repo end
				end

				table.sort(results)

				return results
			elseif clusterList[elements[1]] then
				local results = {}

				local lists = clusterTalk(elements[1], true, "list", path)
				for i = 1, #clusterList[elements[1]] do
					local subList = lists[i]

					for i = 1, #subList do
						local found, thisSub = false, subList[i]

						for j = 1, #results do if results[j] == thisSub then
							found = true
							break
						end end

						if not found then results[#results + 1] = thisSub end
					end
				end

				table.sort(results)

				return results
			elseif elements[1] == "ram" or repoList[elements[1]] then
				local cur, results = (elements[1] == "ram") and ramdisk or repoList[elements[1]], {}

				for i = 2, #elements do cur = cur[elements[i]] end

				for entry in pairs(cur) do results[#results + 1] = entry end

				table.sort(results)

				return results
			else
				return rfs.list(path)
			end
		end

		_G.fs.exists = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if webMountList[path] then
				return true
			elseif clusterList[elements[1]] then
				if #elements == 1 then return true end
				local list = clusterTalk(elements[1], true, "exists", path)
				for i = 1, #list do if list[i] then return true end end
				return false
			elseif elements[1] == "ram" or repoList[elements[1]] then
				local cur = (elements[1] == "ram") and ramdisk or repoList[elements[1]]

				for i = 2, #elements do
					cur = cur[elements[i]]
					if not cur then return false end
				end

				return true
			else
				return rfs.exists(path..".bbp") or rfs.exists(path)
			end
		end

		_G.fs.isDir = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			if not fs.exists(path) then return false end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if clusterList[elements[1]] then
				if #elements == 1 then return true end
				local list = clusterTalk(elements[1], true, "isDir", path)
				return list[1]
			elseif elements[1] == "ram" or repoList[elements[1]] then
				local cur = (elements[1] == "ram") and ramdisk or repoList[elements[1]]

				for i = 2, #elements do
					cur = cur[elements[i]]
				end

				return type(cur) == "table"
			else
				return rfs.isDir(path)
			end
		end

		_G.fs.isReadOnly = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if webMountList[path] or repoList[elements[1]] then
				return true
			elseif clusterList[elements[1]] or elements[1] == "ram" then
				return false
			else
				return rfs.isReadOnly(rfs.exists(path..".bbp") and (path..".bbp") or path)
			end
		end

		_G.fs.getDrive = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if clusterList[elements[1]] or elements[1] == "ram" or repoList[elements[1]] then
				return fs.exists(path) and elements[1]
			else
				return rfs.getDrive(rfs.exists(path..".bbp") and (path..".bbp") or path)
			end
		end

		_G.fs.getSize = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if webMountList[path] or repoList[elements[1]] then
				return 0
			elseif clusterList[elements[1]] then
				if #elements == 1 then return 0 end
				if not fs.exists(path) then error("No such file", 2) end

				local size, list = 0, clusterTalk(elements[1], true, "getSize", path)
				for i = 1, #clusterList[elements[1]] do size = size + list[i] end
				return size
			elseif elements[1] == "ram" then
				local cur = ramdisk

				for i = 2, #elements do
					cur = cur[elements[i]]
					if not cur then error("No such file", 2) end
				end

				return type(cur) == "string" and #cur or 0
			else
				return rfs.getSize(rfs.exists(path..".bbp") and (path..".bbp") or path)
			end
		end

		_G.fs.getFreeSpace = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if clusterList[elements[1]] then
				local size, list = 0, clusterTalk(elements[1], true, "getFreeSpace")
				for i = 1, #clusterList[elements[1]] do size = size + list[i][1] end
				return size
			elseif elements[1] == "ram" then
				return math.huge
			elseif repoList[elements[1]] then
				return 0
			else
				return rfs.getFreeSpace(path)
			end
		end

		_G.fs.makeDir = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if fs.exists(path) then
				if fs.isDir(path) then
					return
				else
					error("File exists", 2)
				end
			end

			if clusterList[elements[1]] then
				clusterTalk(elements[1], false, "makeDir", path)
			elseif elements[1] == "ram" then
				local cur = ramdisk

				for i = 2, #elements do
					local next = cur[elements[i]]

					if next then
						cur = next
					else
						cur[elements[i]] = {}
						cur = cur[elements[i]]
					end
				end
			elseif repoList[elements[1]] then
				error("Access denied", 2)
			else
				return rfs.makeDir(path)
			end
		end

		_G.fs.move = function(path1, path2)
			if type(path1) ~= "string" then error("bad argument #1 (expected string, got " .. type(path1) .. ")", 2 ) end
			if type(path2) ~= "string" then error("bad argument #2 (expected string, got " .. type(path2) .. ")", 2 ) end
			path1, path2 = fs.combine(path1, ""), fs.combine(path2, "")

			if not fs.exists(path1) then error("No such file", 2) end
			if fs.exists(path2) then error("File exists", 2) end
			if fs.isReadOnly(path1) or fs.isReadOnly(path2) or (#dividePath(path1) == 1 and fs.getDrive(path1) ~= "hdd") then error("Access denied", 2) end
			if #dividePath(path1) < #dividePath(path2) and path2:sub(#path1) == path1 then error("Can't copy a directory inside itself", 2) end
			-- ... and if we run out of space we'll just let things fall over at the writing level.

			if fs.isDir(path1) then
				fs.makeDir(path2)
				local list = fs.list(path1)
				for i = 1, #list do fs.move(fs.combine(path1, list[i]), fs.combine(path2, list[i])) end
			else
				local input, output = fs.open(path1, "rb"), fs.open(path2, "wb")

				if input.readAll then
					output.write(input.readAll())
				else
					for byte in input.read do output.write(byte) end
				end

				input.close()
				output.close()
			end

			fs.delete(path1)
		end

		_G.fs.copy = function(path1, path2)
			if type(path1) ~= "string" then error("bad argument #1 (expected string, got " .. type(path1) .. ")", 2 ) end
			if type(path2) ~= "string" then error("bad argument #2 (expected string, got " .. type(path2) .. ")", 2 ) end
			path1, path2 = fs.combine(path1, ""), fs.combine(path2, "")

			if not fs.exists(path1) then error("No such file", 2) end
			if fs.exists(path2) then error("File exists", 2) end
			if fs.isReadOnly(path2) then error("Access denied", 2) end
			if #dividePath(path1) < #dividePath(path2) and path2:sub(#path1) == path1 then error("Can't copy a directory inside itself", 2) end
			-- ... and if we run out of space we'll just let things fall over at the writing level.

			if fs.isDir(path1) then
				fs.makeDir(path2)
				local list = fs.list(path1)
				for i = 1, #list do fs.copy(fs.combine(path1, list[i]), fs.combine(path2, list[i])) end
			else
				local input, output = fs.open(path1, "rb"), fs.open(path2, "wb")

				if input.readAll then
					output.write(input.readAll())
				else
					for byte in input.read do output.write(byte) end
				end

				input.close()
				output.close()
			end
		end

		_G.fs.delete = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			if not fs.exists(path) then return end

			if webMountList[path] then
				webMountList[path] = nil
				local file = rfs.open(".bbpack.cfg", "w")
				file.write(textutils.serialize(configTable))
				file.close()
			elseif clusterList[elements[1]] then
				if #elements == 1 then
					clusterList[elements[1]] = nil
					local file = rfs.open(".bbpack.cfg", "w")
					file.write(textutils.serialize(configTable))
					file.close()
				else
					clusterTalk(elements[1], false, "delete", path)
				end
			elseif repoList[elements[1]] then
				if #elements == 1 then
					repoList[elements[1]], configTable.githubRepos[elements[1]] = nil, nil
					local file = rfs.open(".bbpack.cfg", "w")
					file.write(textutils.serialize(configTable))
					file.close()
				else
					error("Access denied", 2)
				end
			elseif elements[1] == "ram" then
				if #elements == 1 then error("Access denied", 2) end

				local cur = ramdisk

				for i = 2, #elements - 1 do
					cur = cur[elements[i]]
					if not cur then return end
				end

				cur[elements[#elements]] = nil
			else
				if fs.isDir(path) then
					local list = fs.list(path)
					
					for i = 1, #list do
						local ok, err = pcall(fs.delete, fs.combine(path, list[i]))
						if not ok then error(err:gsub("pcall: ", ""), 2) end
					end
					
					return rfs.delete(path)
				else
					return rfs.delete(rfs.exists(path..".bbp") and (path..".bbp") or path)
				end
			end
		end

		_G.fs.open = function(path, mode)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			if type(mode) ~= "string" then error("bad argument #2 (expected string, got " .. type(mode) .. ")", 2 ) end
			path = fs.combine(path, "")
			local elements = dividePath(path)

			mode = mode:lower()
			local binary, append, read, write = mode:find("b") ~= nil, mode:find("a") ~= nil, mode:find("r") ~= nil, mode:find("w") ~= nil

			if webMountList[path] or clusterList[elements[1]] or elements[1] == "ram" or repoList[elements[1]] then
				if not (append or write or read) then error("Invalid file mode: " .. mode, 2) end

				if read then
					if not fs.exists(path) or fs.isDir(path) then return nil, "No such file" end

					local data
					local handle = {["close"] = function() data = nil end}

					if webMountList[path] then
						local webHandle = http.get(webMountList[path], nil, term.setPaletteColour and true)
						data = webHandle.readAll()
						webHandle.close()
					elseif clusterList[elements[1]] then
						data = {}
						local list = clusterTalk(elements[1], true, "get", path)
						for i = 1, #clusterList[elements[1]] do if list[i] then data[list[i][1]] = list[i][2] end end
						data = table.concat(data)
						data = decompressInternal({data:byte(1, #data)}, true)
					elseif repoList[elements[1]] then
						data = repoList[elements[1]]
						for i = 2, #elements do data = data[elements[i]] end
						local webHandle = http.get(data, nil, term.setPaletteColour and true)
						data = webHandle.readAll()
						webHandle.close()
					else
						data = ramdisk
						for i = 2, #elements do data = data[elements[i]] end
					end

					if #data == 0 then data = nil end

					if binary then
						handle.read = function(amount)
							if not data then return nil end

							local result
							if type(amount) ~= "number" then
								result = data:byte(1)
								data = data:sub(2)
							else
								result = data:sub(1, amount)
								data = data:sub(amount + 1)
							end

							if #data == 0 then data = nil end
							return result
						end

						handle.readAll = function()
							if not data then return nil end

							local result = data
							data = nil
							return result
						end
					else
						handle.readLine = function()
							if not data then return nil end

							if data:find("\n") then
								local result = data:sub(1, data:find("\n") - 1)
								data = data:sub(data:find("\n") + 1)
								if data:byte(1) == 13 then data = data:sub(2) end
								return result
							else
								local result = data
								data = nil
								return data
							end
						end

						handle.readAll = function()
							if not data then return nil end

							local result = data
							data = nil
							return result
						end
					end

					return handle
				elseif write or append then
					if webMountList[path] or repoList[elements[1]] then return nil, "Access denied" end
					if fs.isDir(path) then return nil, "Cannot write to directory" end
					fs.makeDir(fs.getDir(path))

					local handle, output, counter = {}, {}, 1

					if binary then
						handle.write = function(data)
							if type(data) ~= "string" and type(data) ~= "number" then error("bad argument #1 (string or number expected, got " .. type(data) .. ")", 2) end
							output[counter] = type(data) == "number" and string.char(data) or data
							counter = counter + 1
						end
					else
						handle.write = function(data)
							output[counter] = tostring(data)
							counter = counter + 1
						end

						handle.writeLine = function(data)
							output[counter] = tostring(data)
							output[counter + 1] = "\n"
							counter = counter + 2
						end
					end

					local ramLink, ramIndex
					if clusterList[elements[1]] and append and fs.exists(path) then
						local data, list = {}, clusterTalk(elements[1], true, "get", path)
						for i = 1, #list do if list[i] then data[list[i][1]] = list[i][2] end end
						data = table.concat(data)
						output[1], counter = decompressInternal({data:byte(1, #data)}, true), 2
					elseif elements[1] == "ram" then
						ramLink = ramdisk
						for i = 2, #elements - 1 do ramLink = ramLink[elements[i]] end
						ramIndex = elements[#elements]
						if (append and not ramLink[ramIndex]) or not append then ramLink[ramIndex] = "" end
					end

					handle.flush = function()
						if clusterList[elements[1]] then
							output, counter = {table.concat(output)}, 1
							local data, segs, pos, totalSpace, thisCluster = string.char(unpack(compressInternal(output[1]))), 1, 1, fs.getFreeSpace(elements[1]), clusterList[elements[1]]
							if fs.exists(path) then totalSpace = totalSpace + fs.getSize(path) end
							if totalSpace < #data then error("Out of space", 2) end

							fs.delete(path)
							
							local spaceList = clusterTalk(elements[1], true, "getFreeSpace")
							
							for i = 1, #thisCluster do
								local thisSpace = spaceList[i][1]
								
								if thisSpace > 0 then
									local segString = tostring(segs)
									rednet.send(spaceList[i][2], {["cluster"] = elements[1], "put", path .. string.rep("0", 3 - #segString) .. segString, data:sub(pos, pos + thisSpace - 1)}, rednet.host and elements[1])
									pos, segs = pos + thisSpace, segs + 1
								end

								if pos > #data then break end
							end
						else
							output = table.concat(output)
							if append then output = ramLink[ramIndex] .. output end
							ramLink[ramIndex] = output
							output, counter, append = {}, 1, true
						end
					end

					handle.close = function()
						handle.flush()
						for key in pairs(handle) do handle[key] = function() end end
					end

					return handle
				end
			else
				if (write or append) and rfs.isReadOnly(path) then return nil, "Access denied" end

				for i = 1, #blacklist do
					local check = blacklist[i]
					if path:sub(-#check):lower() == check then return rfs.open(path, mode) end
				end

				if read then
					return rfs.exists(path .. ".bbp") and open(path .. ".bbp", mode) or rfs.open(path, mode)
				elseif configTable.compressedFS then
					if rfs.getDrive(elements[1]) and rfs.getDrive(elements[1]) ~= "hdd" then
						return rfs.open(path, mode)
					elseif append then
						if rfs.exists(path) then
							local file, content = rfs.open(path, binary and "rb" or "r")

							if file.readAll then
								content = file.readAll()
							else
								content = {}
								for byte in file.read do content[#content + 1] = byte end
								content = string.char(unpack(content))
							end

							file.close()

							rfs.delete(path)

							file = open(path .. ".bbp", binary and "wb" or "w")
							file.write(content)
							return file
						else return open(path .. ".bbp", mode) end
					elseif write then
						if rfs.exists(path) then rfs.delete(path) end
						return open(path .. ".bbp", mode)
					end
				else
					if append then
						if rfs.exists(path .. ".bbp") then
							local file = open(path .. ".bbp", binary and "rb" or "r")
							local content = file.readAll()
							file.close()

							rfs.delete(path .. ".bbp")

							file = rfs.open(path, binary and "wb" or "w")

							if file.writeLine or term.setPaletteColour then
								file.write(content)
							else
								content = {string.byte(1, #content)}
								for i = 1, #content do file.write(content[i]) end
							end

							return file
						else return rfs.open(path, mode) end
					elseif write then
						if rfs.exists(path .. ".bbp") then rfs.delete(path .. ".bbp") end
						return rfs.open(path, mode)
					end
				end

				error("Unsupported mode", 2)
			end
		end

		_G.fs.find = function(path)
			if type(path) ~= "string" then error("bad argument #1 (expected string, got " .. type(path) .. ")", 2 ) end
			local pathParts, results, curfolder = {}, {}, "/"
			for part in path:gmatch("[^/]+") do pathParts[#pathParts + 1] = part:gsub("*", "[^/]*") end
			if #pathParts == 0 then return {} end

			local prospects = fs.list(curfolder)
			for i = 1, #prospects do prospects[i] = {["parent"] = curfolder, ["depth"] = 1, ["name"] = prospects[i]} end

			while #prospects > 0 do
				local thisProspect = table.remove(prospects, 1)
				local fullPath = fs.combine(thisProspect.parent, thisProspect.name)

				if thisProspect.name == thisProspect.name:match(pathParts[thisProspect.depth]) then
					if thisProspect.depth == #pathParts then
						results[#results + 1] = fullPath
					elseif fs.isDir(fullPath) and thisProspect.depth < #pathParts then
						local newList = fs.list(fullPath)
						for i = 1, #newList do prospects[#prospects + 1] = {["parent"] = fullPath, ["depth"] = thisProspect.depth + 1, ["name"] = newList[i]} end
					end
				end
			end

			return results
		end

		_G.rfs = rfs
	end

	update = bbpack and bbpack.update or function()
		for cluster, ids in pairs(clusterList) do for i = 1, #ids do
			rednet.send(ids[i], {["cluster"] = cluster, "update"}, rednet.host and cluster)
		end end

		local file = rfs.open("bbpack", "w")
		file.write(downloadPasteInternal("cUYTGbpb"))
		file.close()

		os.reboot()
	end

	fileSys = bbpack and bbpack.fileSys or function(par1, par2)
		if type(par1) == "boolean" or (type(par1) == "string" and type(par2) == "boolean") then
			-- Compress / decompress hdd contents.
			local list
			if type(par1) == "boolean" then
				list = rfs.list("")
				configTable.compressedFS = par1
			else
				list = {par1}
				par1 = par2
			end

			while #list > 0 do
				local entry = list[#list]
				list[#list] = nil

				if rfs.getDrive(entry) == "hdd" and not webMountList[entry] then
					if rfs.isDir(entry) then
						local newList, curLen = rfs.list(entry), #list
						for i = 1, #newList do list[curLen + i] = fs.combine(entry, newList[i]) end
					else
						local blacklisted = false

						for i = 1, #blacklist do
							local check = blacklist[i]
							if entry:sub(-#check):lower() == check then
								blacklisted = true
								break
							end
						end

						if not blacklisted then
							if par1 and entry:sub(-4) ~= ".bbp" then
								-- Compress this file.
								local file, content = rfs.open(entry, "rb")
								if file.readAll then
									content = file.readAll()
								else
									content = {}
									local counter = 1
									for byte in file.read do
										content[counter] = byte
										counter = counter + 1
									end
									content = string.char(unpack(content))
								end
								file.close()
								
								content = compressInternal(content)
								if rfs.getFreeSpace(entry) + rfs.getSize(entry) < #content then return false end
								rfs.delete(entry)
								snooze()

								file = rfs.open(entry .. ".bbp", "wb")

								if term.setPaletteColor then
									file.write(string.char(unpack(content)))
								else
									for i = 1, #content do file.write(content[i]) end
								end

								file.close()

								snooze()
							elseif not par1 and entry:sub(-4) == ".bbp" then
								-- Decompress this file.
								local file = open(entry, "rb")
								local content = file.readAll()
								file.close()

								if rfs.getFreeSpace(entry) + rfs.getSize(entry) < #content then return false end
								rfs.delete(entry)
								snooze()

								file = rfs.open(entry:sub(1, -5), "wb")

								if term.setPaletteColor then
									file.write(content)
								else
									content = {content:byte(1, #content)}
									for i = 1, #content do file.write(content[i]) end
								end

								file.close()

								snooze()
							end
						end
					end
				end
			end
		elseif type(par1) == "string" and type(par2) == "string" then
			-- New web mount.
			local url, path = par1, fs.combine(par2, "")
			local elements = dividePath(path)
			
			local repo = getGithubRepo(url)
			if repo then
				if #elements > 1 then error("bbpack.mount: Github repos must be mounted at the root of your file system", 2) end
				repoList[path] = repo
				configTable.githubRepos[path] = url
			else
				if fs.getDrive(elements[1]) and fs.getDrive(elements[1]) ~= "hdd" then error("bbpack.mount: web mounts must be located on the main hdd", 2) end

				local get = http.get(url)
				if not get then error("bbpack.mount: Can't connect to URL: "..url, 2) end
				get.close()

				webMountList[path] = url
			end
		elseif type(par1) == "string" then
			-- New cluster mount.
			local cluster, uuid = par1, math.random(1, 0x7FFFFFFF)
			for _, side in pairs(rs.getSides()) do if peripheral.getType(side) == "modem" then rednet.open(side) end end
			rednet.broadcast({["cluster"] = cluster, ["uuid"] = uuid, "rollcall"}, rednet.host and cluster)
			clusterList[cluster] = nil
			local myTimer, map = os.startTimer(5), {}

			while true do
				local event, par1, par2 = os.pullEvent()

				if event == "timer" and par1 == myTimer then
					break
				elseif event == "rednet_message" and type(par2) == "table" and par2.cluster == cluster and par2.uuid == uuid and par2[1] == "rollcallResponse" then
					map[#map + 1] = par1
				end
			end

			if #map == 0 then error("bbpack.mount: Can't connect to cluster: " .. cluster, 2) end
			clusterList[cluster] = map
		end

		local file = rfs.open(".bbpack.cfg", "w")
		file.write(textutils.serialize(configTable))
		file.close()

		return true
	end
end