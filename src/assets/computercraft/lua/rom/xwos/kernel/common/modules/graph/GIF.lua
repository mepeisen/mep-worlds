-- +---------------------+-----------+---------------------+
-- |                     |           |                     |
-- |                     |    GIF    |                     |
-- |                     |           |                     |
-- +---------------------+-----------+---------------------+

local version = "Version 1.3.0pr1"

-- Loads and renders GIF files in ComputerCraft.
-- Capable of handling animations.
-- http://www.computercraft.info/forums2/index.php?/topic/23056-gif-renderer

---------------------------------------------
------------Variable Declarations------------
---------------------------------------------

if not bbpack then os.loadAPI("bbpack") end

local CCPal = io.lines and  -- CC 1.55 adds this function, and also changes the colours, so...
		{[0] = {240,240,240},{242,178, 51},{229,127,216},{153,178,242},
		{222,222,108},{127,204, 25},{242,178,204},{ 76, 76, 76},
		{153,153,153},{ 76,153,178},{178,102,229},{ 51,102,204},
		{127,102, 76},{ 87,166, 78},{204, 76, 76},{ 25, 25, 25}}
	or
		{[0] = {240,240,240},{235,136, 68},{195, 84,205},{102,137,211},
		{222,222,108},{65,205, 52},{216,129,152},{ 67, 67, 67},
		{153,153,153},{ 40,118,151},{123, 47,190},{ 37, 49,146},
		{ 81, 48, 26},{ 59, 81, 26},{179, 49, 44},{  0,  0,  0}}

local GIF87a, GIF89a, colourNum = {71,73,70,56,55,97}, {71,73,70,56,57,97}, {}

do
	local hex = "0123456789abcdef"
	for i = 1, 16 do colourNum[i - 1] = hex:sub(i, i) end
	for i = 1, 16 do colourNum[hex:sub(i, i)] = i - 1 end
end

---------------------------------------------
------------Function Declarations------------
---------------------------------------------

local function snooze()
	local myEvent = tostring({})
	os.queueEvent(myEvent)
	os.pullEvent(myEvent)
end

local function simpleWindow(terminal, xPos, yPos, width, height)
	local results, curX, curY = {}, 1, 1
	
	results.clear = function(colour)
		local text = string.rep(colour, width)
		for y = 1, height do results[y] = text end
	end
	
	results.draw = function(x1, y1, x2, y2)
		if x1 then
			local text = string.rep(" ", x2 - x1 + 1)
			for y = y1, y2 do
				local snip = results[y]:sub(x1, x2)
				terminal.setCursorPos(xPos + x1 - 1, yPos + y - 1)
				terminal.blit(text, snip, snip)
			end
		else
			local text = string.rep(" ", width)
			for y = 1, height do
				terminal.setCursorPos(xPos, yPos + y - 1)
				terminal.blit(text, results[y], results[y])
			end
		end
	end
	
	results.setCursorPos = function(newX, newY)
		curX, curY = newX, newY
	end
	
	results.blit = function(_, _, colString)
		if curY < 1 or curY > height or curX > width or curX + #colString < 2 then return end
		
		local ending = (curX + #colString - 1 > width) and (width - curX + 1) or #colString
		if curX < 1 then
			colString = colString:sub(2 - curX, ending)
			curX = 1
		elseif ending ~= #colString then colString = colString:sub(1, ending) end
		
		if curX > 1 then
			if curX + #colString - 1 < width then
				results[curY] = results[curY]:sub(1, curX - 1) .. colString .. results[curY]:sub(curX + #colString)
			else
				results[curY] = results[curY]:sub(1, curX - 1) .. colString
			end
		elseif #colString < width then
			results[curY] = colString .. results[curY]:sub(curX + #colString)
		else results[curY] = colString end
	end
	
	return results
end

-- ComputerCraft builds prior to 1.74 lack term.blit(). This function implements a substitute:
local function checkTerm(terminal)
	if not terminal.blit then terminal.blit = function(_, _, backCol)
		local counter, lastChar = 1, backCol:sub(1, 1)

		for i = 2, #backCol do if backCol:sub(i, i) ~= lastChar then
			terminal.setBackgroundColour(bit.blshift(1, colourNum[lastChar]))
			terminal.write(string.rep(" ", counter))
			counter, lastChar = 1, backCol:sub(i, i)
		else counter = counter + 1 end end

		terminal.setBackgroundColour(bit.blshift(1, colourNum[lastChar]))
		terminal.write(string.rep(" ", counter))
		
		snooze()
	end end
end

if term.setPaletteColour then
	function applyPalette(image, terminal)
		terminal = terminal or term

		local col, pal = 1, image.pal

		for i = 0, #pal do
			local thisCol = pal[i]
			terminal.setPaletteColour(col, thisCol[1] / 255, thisCol[2] / 255, thisCol[3] / 255)
			col = col * 2
		end
	end
end

function drawGIF(image, xPos, yPos, terminal)
	xPos, yPos, terminal = xPos or 1, yPos or 1, terminal or term
	if type(image[1][1]) == "table" then image = image[1] end
	checkTerm(terminal)
	
	for y = 1, image.yend do
		local x, ystart, imageY = image.xstart + 1, image.ystart, image[y]
		for i = 1, #imageY do
			local imageYI = imageY[i]
			if type(imageYI) == "number" then
				x = x + imageYI
			else
				terminal.setCursorPos(x + xPos - 1, y + ystart + yPos - 1)
				terminal.blit(string.rep(" ", #imageYI), imageYI, imageYI)
				x = x + #imageYI
			end
		end
	end
end

function animateGIF(image, xPos, yPos, terminal)
	if terminal == term or not terminal then terminal = term.current() end
	checkTerm(terminal)
	local buffer = simpleWindow(terminal, xPos, yPos, image.width, image.height)
		
	while true do for i = 1, #image do
		local imageI, imageIneg1 = image[i], image[i - 1]
		if i == 1 then buffer.clear(image.backgroundCol2) end
		
		drawGIF(imageI, 1, 1, buffer)
		
		if i == 1 then
			buffer.draw()
		elseif imageIneg1.disposal == 2 then
			buffer.draw(math.min(imageIneg1.xstart, imageI.xstart) + 1, math.min(imageIneg1.ystart, imageI.ystart) + 1, math.max(imageIneg1.xstart + imageIneg1.xend, imageI.xstart + imageI.xend), math.max(imageIneg1.ystart + imageIneg1.yend, imageI.ystart + imageI.yend))
		else
			buffer.draw(imageI.xstart + 1, imageI.ystart + 1, imageI.xstart + imageI.xend, imageI.ystart + imageI.yend)
		end
		
		sleep(imageI.delay)
		
		if imageI.disposal == 2 then
			local blit = string.rep(image.backgroundCol2, imageI.xend)
			for y = 1, imageI.yend do
				buffer.setCursorPos(imageI.xstart + 1, y + imageI.ystart)
				buffer.blit(nil, nil, blit)
			end
		end
	end end
end

local function rasteriseGIF(image)
	local results, buffer = {["width"] = image.width, ["height"] = image.height, ["backgroundCol"] = image.backgroundCol, ["backgroundCol2"] = image.backgroundCol2, ["pal"] = image.pal}, {}
	
	for i = 1, image.height do
		local temp = {}
		for j = 1, image.width do temp[j] = " " end
		buffer[i] = temp
	end
	
	for i = 1, #image do
		local thisImg = image[i]
		local xStart, yStart = thisImg.xstart + 1, thisImg.ystart
		
		for y = 1, thisImg.yend do
			local x, thisImgY, buffY = xStart, thisImg[y], buffer[y + yStart]
			for i = 1, #thisImgY do
				local thisImgYI = thisImgY[i]
				if type(thisImgYI) == "number" then
					x = x + thisImgYI
				elseif type(thisImgYI) == "string" then
					for j = 1, #thisImgYI do buffY[x + j - 1] = colourNum[thisImgYI:sub(j, j)] end
					x = x + #thisImgYI
				else
					for j = 1, #thisImgYI do buffY[x + j - 1] = thisImgYI[j] end
					x = x + #thisImgYI
				end
			end
		end

		local resultsI = {["delay"] = thisImg.delay or 0.1}
		for j = 1, #buffer do
			local newRow, buffRow = {}, buffer[j]
			for k = 1, #buffRow do newRow[k] = buffRow[k] end
			resultsI[j] = newRow
		end
		results[i] = resultsI

		if thisImg.disposal == 2 then
			local xEnd = thisImg.xstart + thisImg.xend
			for y = yStart + 1, yStart + thisImg.yend do
				local bufferY = buffer[y]
				for x = xStart, xEnd do bufferY[x] = " " end
			end
		end

		snooze()
	end

	return results	
end

function flattenGIF(image, optimise, prerastered)
	if not prerastered then image = rasteriseGIF(image) end
	
	local width, bump, cacheImg = image.width, 0
	for i = 1, #image do
		local prevImg, thisImg, nextImg, same = image[i - 1 - bump], image[i - bump], image[i + 1 - bump], true
		if not thisImg then break end
		local txStart, txEnd, tyStart, tyEnd, cxStart, cxEnd, cyStart, cyEnd = image.width, 1, image.height, 1
		if cacheImg then cxStart, cxEnd, cyStart, cyEnd = cacheImg.xstart, cacheImg.xend, cacheImg.ystart, cacheImg.yend end
		
		if optimise and i > 1 then
			local prevDisp = prevImg.disposal
			for y = 1, #thisImg do
				local thisImgY, cacheImgY = thisImg[y], cacheImg[y]
				for x = 1, width do if thisImgY[x] ~= ((prevDisp == 2 and not (x < cxStart + 1 or y < cyStart + 1 or x > cxStart + cxEnd or y > cyStart + cyEnd)) and " " or cacheImgY[x]) then
					same = false
					if y < tyStart + 1 then tyStart = y - 1 end
					if y > tyEnd then tyEnd = y end
					if x < txStart + 1 then txStart = x - 1 end
					if x > txEnd then txEnd = x end
					snooze()
				end end
			end
		elseif optimise == false then
			same = false
			for y = 1, #thisImg do
				local thisImgY = thisImg[y]
				for x = 1, width do if thisImgY[x] ~= " " then
					if y < tyStart + 1 then tyStart = y - 1 end
					if y > tyEnd then tyEnd = y end
					if x < txStart + 1 then txStart = x - 1 end
					if x > txEnd then txEnd = x end
				end end
				snooze()
			end
		else
			same, txStart, txEnd, tyStart, tyEnd = false, 0, width, 0, #thisImg
		end
		
		if same and i > 1 then
			image[i - 1 - bump].delay = prevImg.delay + thisImg.delay
			table.remove(image, i - bump)
			bump = bump + 1
			snooze()
		else
			if i - bump ~= #image and optimise ~= nil then
				local obscured = true
				for y = 1, #thisImg do
					local thisImgY, nextImgY = thisImg[y], nextImg[y]
					for x = 1, width do if thisImgY[x] ~= " " and nextImgY[x] == " " then
						obscured = false
						if y < tyStart + 1 then tyStart = y - 1 end
						if y > tyEnd then tyEnd = y end
						if x < txStart + 1 then txStart = x - 1 end
						if x > txEnd then txEnd = x end
					end end
					snooze()
				end
				thisImg.disposal = obscured and 1 or 2
			else thisImg.disposal = 1 end

			if txStart > txEnd then txStart, txEnd, tyStart, tyEnd = 0, 1, 0, 1 end
			
			local nxStart, nxEnd, nyStart, nyEnd, cacheDisp = txStart, txEnd - txStart, tyStart, tyEnd - tyStart, cacheImg and cacheImg.disposal
			newImg = {["delay"] = thisImg.delay, ["disposal"] = thisImg.disposal, ["xstart"] = nxStart, ["xend"] = nxEnd, ["ystart"] = nyStart, ["yend"] = nyEnd}
			
			for y = 1, nyEnd do
				local skip, chars, temp, thisImgY, cacheImgY = 0, {}, {}, thisImg[y + nyStart], cacheImg and cacheImg[y + nyStart]
				for x = nxStart + 1, nxStart + nxEnd do
					local thisVal = thisImgY[x]
					if optimise ~= nil and cacheImg and thisVal == cacheImgY[x] and (cacheDisp == 1 or (cacheDisp == 2 and (x < cxStart + 1 or y + nyStart < cyStart + 1 or x > cxStart + cxEnd or y + nyStart > cyStart + cyEnd))) then thisVal = " " end
					
					if thisVal == " " then
						skip = skip + 1
						if #chars > 0 then
							temp[#temp + 1] = (image.pal and image.pal[1][4]) and chars or table.concat(chars)
							chars = {}
						end
					else
						chars[#chars + 1] = (image.pal and image.pal[1][4]) and thisVal or colourNum[thisVal]
						if skip > 0 then
							temp[#temp + 1] = skip
							skip = 0
						end
					end
				end
				if skip == 0 then temp[#temp + 1] = (image.pal and image.pal[1][4]) and chars or table.concat(chars) end
				newImg[y] = temp
				snooze()
			end
			thisImg.xstart, thisImg.xend, thisImg.ystart, thisImg.yend = txStart, txEnd, tyStart, tyEnd
			cacheImg = thisImg
			image[i - bump] = newImg
		end
	end
	
	return image
end

function resizeGIF(image, width, height)
	if not width then width = math.floor(height / image.height * image.width) end
	if not height then height = math.floor(width / image.width * image.height) end
	local xInc, yInc, pal = image.width / width, image.height / height, image.pal or CCPal
	image = rasteriseGIF(image)
	
	for i = 1, #image do
		local oldFrame, yPos2 = image[i], 1
		local newFrame = {["delay"] = oldFrame.delay or 0.1}
		for y = 1, height do
			local thisLine, xPos2 = {}, 1
			for x = 1, width do
				local remY, R, G, B, totalWeight, yPos = yInc, 0, 0, 0, 0, yPos2
				while remY > 0 do
					local remX, maxInc, oldFrameY, xPos, yWeight = xInc, (math.floor(yPos) == yPos) and 1 or (math.ceil(yPos) - yPos), oldFrame[math.min(math.floor(yPos), image.height)], xPos2
					if remY < maxInc then yWeight = remY remY = 0 else yWeight = maxInc remY = remY - maxInc end
					while remX > 0 do
						local maxInc, thisChar, xWeight = (math.floor(xPos) == xPos) and 1 or (math.ceil(xPos) - xPos), oldFrameY[math.min(math.floor(xPos), image.width)]
						if remX < maxInc then xWeight = remX remX = 0 else xWeight = maxInc remX = remX - maxInc end

						if thisChar ~= " " then
							local thisWeight = xWeight * yWeight
							totalWeight, thisChar = totalWeight + thisWeight, pal[thisChar]
							R, G, B = R + thisChar[1] * thisWeight, G + thisChar[2] * thisWeight, B + thisChar[3] * thisWeight
						end
						
						xPos = (maxInc < 1 and xWeight == maxInc) and math.ceil(xPos) or (xPos + xWeight)
					end
					yPos = (maxInc < 1 and yWeight == maxInc) and math.ceil(yPos) or (yPos + yWeight)
				end
				
				if totalWeight > (xInc * yInc) / 2 then
					local closest, difference = 0, 10000
					R, G, B = R / totalWeight, G / totalWeight, B / totalWeight
					for j = 0, #pal do
						local thisDiff = math.abs(pal[j][1] - R) + math.abs(pal[j][2] - G) + math.abs(pal[j][3] - B)
						if thisDiff < difference then
							difference = thisDiff
							closest = j
							if difference == 0 then break end
						end
					end
					thisLine[#thisLine + 1] = closest
				else thisLine[#thisLine + 1] = " " end
				xPos2 = xPos2 + xInc
			end
			yPos2 = yPos2 + yInc
			newFrame[y] = thisLine
			snooze()
		end
		image[i] = newFrame
	end
	
	image.width, image.height = width, height
	
	return flattenGIF(image, false, true)
end

function loadGIF(targetfile, pal)
	local results, fileread = {["backgroundCol"] = 0}, fs.open(targetfile, "rb")
	if not fileread then error("GIF.loadGIF(): Unable to open " .. targetfile .. " for input.", 2) end
	
	if type(pal) == "string" then
		local file = fs.open(pal, "r")
		pal = textutils.unserialize(file.readAll())
		file.close()
		for i = 1, #pal do
			local palI = pal[i]
			if not palI[5] then palI[5] = 0 end
		end
		if not pal[0] then pal[0] = {1000, 1000, 1000, "minecraft:air", 0} end
		results.pal = pal
	elseif pal then
		-- Construct a reduced palette from the GIF's own.
		if not fileread.readAll then error("Installed version of CC does not support palette alterations.") end

		pal = {}
		
		fileread.read(10)
		local temp, counter = fileread.read(), 0
		fileread.read(2)

		-- Read in global palette:
		if bit.band(temp, 128) == 128 then for i = 1, 2 ^ (bit.band(temp, 7) + 1) do
			local thisCol, found = fileread.read(3), false

			for i = 1, counter do if pal[i] == thisCol then
				found = true
				break
			end end

			if not found then
				counter = counter + 1
				pal[counter] = thisCol
			end
		end end
		
		-- Read in any additional palettes:
		while true do
			local record = fileread.read()
			
			if record == 33 then
				fileread.read()
				
				while true do
					record = fileread.read()
					if record == 0 then break end
					fileread.read(record)
					snooze()
				end
			elseif record == 44 then
				fileread.read(8)
				
				record = fileread.read()

				if bit.band(record, 128) == 128 then for i = 1, 2 ^ (bit.band(record, 7) + 1) do
					local thisCol, found = fileread.read(3), false

					for i = 1, counter do if pal[i] == thisCol then
						found = true
						break
					end end

					if not found then
						counter = counter + 1
						pal[counter] = thisCol
					end
				end end
				
				fileread.read()
				
				while true do
					record = fileread.read()
					if record == 0 then break end
					fileread.read(record)
					snooze()
				end
			elseif record == 59 then
				fileread.close()
				break
			else
				error("Malformed record")
			end
		end

		-- Condense palette:
		for i = 1, counter do pal[i] = {pal[i]:byte(1, 3)} end
		
		while #pal > 16 do
			local matches, tally, bestDiff, curLen = {}, tally, 1000, #pal
			
			for i = 1, curLen - 1 do
				local palI, found = pal[i], false
				
				for j = i + 1, curLen do
					local palJ = pal[j]
					local thisDiff = math.abs(palJ[1] - palI[1]) + math.abs(palJ[2] - palI[2]) + math.abs(palJ[3] - palI[3])
					
					if thisDiff < bestDiff then
						matches, tally, bestDiff, found = {[j] = i}, 1, thisDiff, true
					elseif thisDiff == bestDiff and not matches[j] and not matches[i] and not found then
						matches[j], tally, found = i, tally + 1, true
					end
				end
			end
			
			local counter, max = 1, (curLen - tally > 15) and tally or (curLen - 16)
			for i, j in pairs(matches) do
				local palI, palJ = pal[i], pal[j]
				--print(#pal,i,j,type(palI),type(palJ))
				pal[i] = {math.floor((palI[1] + palJ[1]) / 2), math.floor((palI[2] + palJ[2]) / 2), math.floor((palI[3] + palJ[3]) / 2)}
				pal[j], counter = "remove", counter + 1
				if counter > max then break end
			end
			
			for i = curLen, 1, -1 do if pal[i] == "remove" then table.remove(pal, i) end end
		end
		
		pal[0] = pal[#pal]
		pal[#pal] = nil
		results.pal = pal
		
		fileread = fs.open(targetfile, "rb")
	else pal = CCPal end
	
	local readByte = fileread.read
	
	local readBytes = fileread.readAll and
		function(num)
			local output = readByte(num)
			return {output:byte(1, #output)}
		end
	or
		function(num)
			local output = {}
			for i = 1, num do output[#output + 1] = readByte() end
			return output
		end
	
	local function readInt()
		local results = readByte()
		return results + readByte() * 256
	end

	-- GIF signature:
	local temp = readBytes(6)
	for i = 1, 6 do if temp[i] ~= GIF87a[i] and temp[i] ~= GIF89a[i] then
		fileread.close()
		error("GIF.loadGIF(): " .. targetfile .. " does not appear to be a GIF.", 2)
	end end

	-- Screen discriptor:
	local width = readInt()
	local height = readInt()
	results.width, results.height = width, height
	
	local cacheFrame, cacheBackup = {}
	for y = 1, height do 
		local cacheFrameY = {}
		for x = 1, width do cacheFrameY[x] = " " end
		cacheFrame[y] = cacheFrameY
	end
		
	temp = readByte()
	local globalColourCount = 2 ^ (bit.band(temp, 7) + 1)
	readInt()  -- This is the background colour, which we'll ignore, and instead pick something that contrasts the image later.
	snooze()

	-- Palette:
	local globalPal = bit.band(temp, 128) == 128
	if globalPal then
		globalPal = {}
		for i = 0, globalColourCount - 1 do globalPal[i] = readBytes(3) end
	end
	
	-- Read image records:
	while true do
		local thisImg, interlace, thisPal, transparent = {}
		
		-- Read image headers:
		while true do
			snooze()
			local record = readByte()

			if record == 33 then
				record = readByte()

				-- Gif extensions:
				if record == 249 then
					-- Graphics control extension:
					readByte()
					local flags = readByte()
					local isTransparent = bit.band(flags, 1) == 1
					thisImg.inputExpected = bit.band(flags, 2) == 2
					thisImg.disposal = bit.brshift(bit.band(flags, 28), 2)
					thisImg.delay = readInt()
					thisImg.delay = (thisImg.delay > 0) and (thisImg.delay / 100) or nil
					transparent = readByte()
					if not isTransparent then transparent = nil end
					readByte()
				elseif record == 254 then
					-- File comment:
					local fullComment = {}
					
					repeat
						local length = readByte()
						if length > 0 then fullComment[#fullComment + 1] = string.char(unpack(readBytes(length))) end
					until length == 0
							
					results.comment = table.concat(fullComment)
				elseif record == 1 then
					-- Plain text extension:
					readBytes(readByte())
					
					local fullText = {}
					
					repeat
						local length = readByte()
						if length > 0 then fullText[#fullText + 1] = string.char(unpack(readBytes(length))) end
					until length == 0
							
					results.text = table.concat(fullText)
				else
					-- All other extensions we skip past:
					repeat
						local length = readByte()
						if length > 0 then readBytes(length) end
					until length == 0
				end
			elseif record == 44 then
				-- Image descriptor:
				thisImg.xstart = readInt()
				thisImg.ystart = readInt()
				thisImg.xend = readInt()
				thisImg.yend = readInt()

				record = readByte()
				interlace = bit.band(record, 64) == 64

				if bit.band(record, 128) == 128 then
					-- Local colour map:
					thisPal = {[0] = readBytes(3)}
					for i = 2, 2 ^ (bit.band(record, 7) + 1) do thisPal[#thisPal + 1] = readBytes(3) end
				else
					-- Global colour map:
					thisPal = textutils.unserialize(textutils.serialize(globalPal))
				end
				
				local used = {}
				for i = 0, #thisPal do
					local closest, difference, thisPalI = 0, 10000, thisPal[i]

					for j = 0, #pal do
						local palJ = pal[j]
						local thisDiff = math.abs(palJ[1] - thisPalI[1]) + math.abs(palJ[2] - thisPalI[2]) + math.abs(palJ[3] - thisPalI[3])

						if thisDiff < difference then
							difference = thisDiff
							closest = j
							if difference == 0 then break end
						end
					end

					thisPal[i] = closest
					if i ~= transparent then used[closest + 1] = true end
				end
				
				local bgCol, bgCol2  = 2 ^ math.min(#used, 15), colourNum[math.min(#used, 15)]
				if bgCol > results.backgroundCol then
					results.backgroundCol = bgCol
					results.backgroundCol2 = bgCol2
				end
				
				-- Image data follows, go read it:
				break
			elseif record == 59 then
				-- End of file.
				fileread.close()
				return flattenGIF(results, false, true)
			end
		end
		
		local xStart, yStart, xEnd, yEnd = thisImg.xstart, thisImg.ystart, thisImg.xend, thisImg.yend
		
		if thisImg.disposal == 3 then
			cacheBackup = {}
			for y = 1, math.min(height - yStart, yEnd) do
				local cacheBackupY, cacheFrameY = {}, cacheFrame[y + yStart]
				for x = 1, math.min(width - xStart, xEnd) do cacheBackupY[x]  = cacheFrameY[x + xStart] end
				cacheBackup[y] = cacheBackupY
			end
		end
		
		-- Read image body:
		
		fileread = bbpack.open(fileread, "rb", 2 ^ fileread.read())
		readByte = fileread.read

		local y, passnum, stepsize = 1, 8, 8
		while y < yEnd + 1 do
			local cacheFrameY = cacheFrame[y + yStart]
			if y <= height then
				for x = 1, xEnd do
					local thisVal = readByte()
					if thisVal ~= transparent and x + xStart <= width then cacheFrameY[x + xStart] = thisPal[thisVal] end
				end
			else for x = 1, xEnd do readByte() end end
			
			if interlace then
				y = y + stepsize

				while y > yEnd and passnum > 1 do
					stepsize = passnum
					passnum = passnum / 2
					y = passnum + 1
				end
			else y = y + 1 end
			
			snooze()
		end
		
		for y = 1, height do
			local thisImgY, cacheFrameY = {}, cacheFrame[y]
			for x = 1, width do thisImgY[x] = cacheFrameY[x] end
			thisImg[y] = thisImgY
		end
		if not thisImg.delay then thisImg.delay = 0.1 end
		
		if thisImg.disposal == 2 then
			for y = 1, math.min(height - yStart, yEnd) do
				local cacheFrameY = cacheFrame[y + yStart]
				for x = 1, math.min(width - xStart, xEnd) do cacheFrameY[x + xStart] = " " end
			end
		elseif thisImg.disposal == 3 then
			for y = 1, math.min(height - yStart, yEnd) do
				local cacheFrameY, cacheBackupY = cacheFrame[y + yStart], cacheBackup[y]
				for x = 1, math.min(width - xStart, xEnd) do cacheFrameY[x + xStart] = cacheBackupY[x] end
			end
			cacheBackup = nil
		end
		
		fileread = fileread.extractHandle()
		readByte = fileread.read
		
		results[#results + 1] = thisImg
	end
end

function setBackgroundColour(image, colour)
	if type(colour) ~= "number" and not colourNum[colour] then error("GIF.setBackgroundColour: Bad colour.", 2) end
	
	if type(colour) == "number" then
		local counter = 0
		while colour > 1 do
			colour = bit.brshift(colour, 1)
			counter = counter + 1
		end
		image.backgroundCol = 2 ^ counter
		image.backgroundCol2 = colourNum[counter]
	else
		image.backgroundCol = 2 ^ colourNum[colour]
		image.backgroundCol2 = colour
	end
end
setBackgroundColor = setBackgroundColour

function toPaintutils(image)
	if type(image[1][1]) == "table" then image = image[1] end
	
	local results = {}
	
	if not image.yend then error("wtf",2) end
	for y = 1, image.yend do
		local resultsY, imageY = {}, image[y]
		local x = image.xstart + 1
		for i = 1, #imageY do
			local imageYI = imageY[i]
			if type(imageYI) == "number" then
				for j = 1, imageYI do resultsY[#resultsY + 1] = 0 end
			else
				for j = 1, #imageYI do resultsY[#resultsY + 1] = 2 ^ colourNum[imageYI:sub(j, j)] end
			end
		end
		results[y] = resultsY
	end
	
	for i = #results[1] + 1, image.xstart + image.xend do results[1][i] = 0 end
	
	return results
end

function buildGIF(...)
	local colourChar, hex, width, height, used = {[0] = " "}, "0123456789abcdef", 0, 0, 0
	for i = 1, 16 do colourChar[2 ^ (i - 1)] = hex:sub(i, i) end
	
	for i = 1, #arg do
		local argI = arg[i]
		if #argI > height then height = #argI end
		for y = 1, #argI do if #argI[y] > width then width = #argI[y] end end
	end
	
	for i = 1, #arg do
		local thisImage, argI = {["delay"] = 0.1}, arg[i]
		
		for y = 1, #argI do
			local thisLine, argIY = {}, argI[y]
			
			for x = 1, width do
				local argIYX = argIY[x] or 0
				if argIYX > used then used = argIYX end
				thisLine[x] = colourNum[colourChar[argIYX]] or " "
			end
				
			thisImage[y] = thisLine
		end
		
		for y = #argI + 1, height do
			local thisLine = {}
			for x = 1, width do thisLine[x] = " " end
			thisImage[y] = thisLine
		end
		
		arg[i] = thisImage
	end
	
	arg.width, arg.height, arg.backgroundCol, arg.backgroundCol2 = width, height, used, colourChar[used]
	
	return flattenGIF(arg, true, true)
end

function saveGIF(image, file)
	if not (image.width or image.xstart) then
		-- "paintutils" image.
		image = buildGIF(image)
	elseif not image.width then
		-- Single frame of an image.
		image = {width = image.xstart + image.xend, height = image.ystart + image.yend, image}
	end
	
	local file, power, transCol = fs.open(file, "wb"), 5
	if not file then error("Unable to open file for output.", 2) end
	local writeByte = file.write
	
	local function writeBytes(bytes)
		for i = 1, #bytes do writeByte(bytes[i]) end
	end
	
	local function writeInt(num)
		writeByte(bit.band(num, 255))
		writeByte(bit.brshift(num, 8))
	end

	-- GIF signature:
	writeBytes(GIF89a)
	
	-- Screen discriptor:
	writeInt(image.width)
	writeInt(image.height)
	
	if image.pal then
		local pal = image.pal
		power = 1
		while 2 ^ power < (#pal + 1) do power = power + 1 end
		writeByte(127 + power)
		transCol = 0
		writeInt(transCol)

		-- Palette:
		for i = 0, #pal do
			local palI = pal[i]
			for j = 1, 3 do writeByte(palI[j]) end
		end
		for i = #pal + 2, 2 ^ power do writeBytes({127, 127, 127}) end
	else
		writeByte(132)
		transCol = #CCPal + 1
		writeInt(transCol)

		-- Palette:
		for i = 0, 15 do writeBytes(CCPal[i]) end
		for i = 0, 15 do writeBytes({127, 127, 127}) end
	end
	
	-- Loop extension:
	if #image > 1 then
		writeBytes({33, 255, 11})
		for i = 1, 11 do writeByte(string.byte("NETSCAPE2.0", i)) end
		writeBytes({3, 1, 0, 0, 0})
	end
	
	-- Write image records:
	for i = 1, #image do
		local image = image[i]
		
		writeBytes({33, 249, 4})
		writeByte(image.disposal and (1 + bit.blshift(image.disposal, 2)) or 1)
		writeInt((not image.delay) and 0 or math.floor(image.delay * 100))
		writeInt(transCol)
		
		writeByte(44)
		writeInt(image.xstart)
		writeInt(image.ystart)
		writeInt(image.xend)
		writeInt(image.yend)
		writeByte(0)
		writeByte(power)

		file = bbpack.open(file, "wb", 2 ^ power)
		writeByte = file.write
		
		for y = 1, image.yend do
			local rowLen, imageY = 0, image[y]
			for i = 1, #imageY do
				local imageYI = imageY[i]
				if type(imageYI) == "number" then
					for j = 1, imageYI do writeByte(transCol) end
					rowLen = rowLen + imageYI
				elseif type(imageYI) == "string" then
					for j = 1, #imageYI do writeByte(colourNum[imageYI:sub(j, j)]) end
					rowLen = rowLen + #imageYI
				else
					for j = 1, #imageYI do writeByte(imageYI[j]) end
					rowLen = rowLen + #imageYI
				end
			end
			for i = 1, image.xend - rowLen do writeByte(transCol) end
			snooze()
		end
		
		file = file.extractHandle()
		writeByte = file.write
	end
	
	writeByte(59)
	file.close()
end