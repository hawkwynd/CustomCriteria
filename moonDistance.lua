-- Global begins here --------------------------------------------------------------------

::Global::

last_helium_boxel = ''
MINIMUM_HELIUM_FOR_NOTIFICATION = 29

---------------------------
-- 1.5: UNDISCOVERED SYSTEM
---------------------------
--Any system with a previously undiscovered primary star will trigger this notification.
triggerForUndiscoveredSystem = true
triggerForSmallObject       = true
triggerRadiusNotification   = true
smallBodyThreshold          = 400000 -- (400000 == 400 km)
spaceTaterThreshold         = 200000 -- 200 km 
kmInLS		                = 299792458				-- how many kilometers per light second
terraMoonThreshold          = 2
triggerForGeoSignals        = true 

-- trigger for Materials on surface check
triggerForMaterials         = true

-- trigger for Orbital Distance report
triggerForOrbitalDistance   = true

-- Prime Photo Body check 
function getOrbitalDistance(scan)
    local payload = ""
    local orbitalDistance = Round( scan.SemiMajorAxis/kmInLS, 2)
    if orbitalDistance < .4 then 
        payload = string.char(10) .. "Surface Photo opportunity"
    end

    return payload

end


function round(n)
    return math.floor((math.floor(n*2) + 1)/2)
end

function Round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end


function comma_value(amount)
    local formatted = amount
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
  end

  -- Max and average levels crunched from EDAstro's Surface Materials spreadsheet, available here:
-- https://edastro.com/mapcharts/files.html
-- and a python script of my own making (but mostly made by the authors of the dask and pandas libraries)
-- If you want a copy

maxLevels = {
    ['antimony']=1.82,
    ['arsenic']=3.03,
    ['cadmium']=3.77,
    ['carbon']=33.91,
    ['chromium']=18.7,
    ['germanium']=6.54,
    ['iron']=48.85,
    ['manganese']=17.36,
    ['mercury']=2.13,
    ['molybdenum']=3.18,
    ['nickel']=36.94,
    ['niobium']=3.32,
    ['phosphorus']=21.71,
    ['polonium']=2.09,
    ['ruthenium']=2.97,
    ['selenium']=6.15,
    ['sulphur']=40.33,
    ['technetium']=1.74,
    ['tellurium']=1.75,
    ['tin']=3.25,
    ['tungsten']=2.68,
    ['vanadium']=16.98,
    ['yttrium']=2.87,
    ['zinc']=12.29,
    ['zirconium']=5.58
}
avgLevels = {
    ['antimony']=0.91,
    ['arsenic']=1.97,
    ['cadmium']=1.33,
    ['carbon']=18.47,
    ['chromium']=7.73,
    ['germanium']=4.29,
    ['iron']=17.17,
    ['manganese']=7.12,
    ['mercury']=0.75,
    ['molybdenum']=1.12,
    ['nickel']=12.99,
    ['niobium']=1.17,
    ['phosphorus']=11.83,
    ['polonium']=0.48,
    ['ruthenium']=1.07,
    ['selenium']=3.69,
    ['sulphur']=21.97,
    ['technetium']=0.62,
    ['tellurium']=1.1,
    ['tin']=1.07,
    ['tungsten']=1.5,
    ['vanadium']=4.33,
    ['yttrium']=1.04,
    ['zinc']=4.77,
    ['zirconium']=2.1
}

-- Percent below max value that's labeled as "high", by default 0.25 = 75% below maximum known value
desperationLevel = 0.50

-- Whether above average values should trigger a notification
aboveAverage = true

-- Similar to desperationLevel, but as the percent above the average value (0.25)
aboveAverageLevel = 1.0

-- List all of the materials that you want to be alerted for here
wantedMaterials = { 'tungsten', 'cadmium', 'polonium','nickel','carbon','vanadium','niobium','germanium','yttrium','arsenic'}

function makeTable(s)
    words = {}
    for word in s:gmatch("%w+") do 
        table.insert(words, word) 
    end
    
    return words
end


function getBodyType( scan )
    return scan.BodyType ~=nill 
end

-- Return gravity of the body in g force
function getBodyGravity(scan)
    local gravityCalc = (scan.SurfaceGravity/9.81)
    if gravityCalc ~=nill then 
        return round( gravityCalc, 2) .. 'g'
    end
end

function checkRawMatContent( scan )
    local resResult = false
    local resTitle  = ''
    local resDesc   = ''

    if scan.Landable then
        for material in materials(scan.Materials) do
            local wanted = false
            for index, value in ipairs(wantedMaterials) do
                if value == material.name then
                    wanted = true
                    break
                end
            end

            if wanted then
                local matName = material.name
                local percent = tonumber(material.percent)

                if percent ~= nil and percent >= ((1 - desperationLevel) * tonumber(maxLevels[matName])) then
                    resResult = true
                    resDesc = 'Content: ' .. string.format("%.1f", percent) .. ' %'
                    if scan.Volcanism ~= nil and scan.Volcanism ~= '' then
                        resTitle = 'High ' .. matName .. ' content with volcanism'
                    else
                        resTitle = 'High ' .. matName .. ' content'
                    end

                elseif aboveAverage and percent ~= nil and percent > ((1 - aboveAverageLevel) * tonumber(avgLevels[matName])) then
                    resResult = true
                    resDesc = 'Content: ' .. string.format("%.1f", percent) .. ' %'
                    if scan.Volcanism ~= nil and scan.Volcanism ~= '' then
                        resTitle = 'Above average ' .. matName .. ' content with volcanism'
                    else
                        resTitle = 'Above average ' .. matName .. ' content'
                    end
                end
            end
        end
    end

   return resResult, resTitle, resDesc
end



::End:: -- Global

-- Begin Criteria sections ----------------------------------------------------------------


------------------------------------------------------------------------------
-- Moon's distance to parent. Used for poss photo shoots, and other funky shit
------------------------------------------------------------------------------

::Criteria::

local result = parents and parents[0].ParentType == 'Planet'

if result then
    
    -- if scan.PlanetClass ~=nil then 
    --     BodyType = scan.PlanetClass
    -- end
    local canLand    = ''
    local matDetails = ''
    local isLandable = ''
    
    
    if triggerRadiusNotification and scan.Landable  then --adds "landable" text to the notification if moon is landable

        local radiusKm      = math.floor(scan.Radius/1000)
        local bodyType      = scan.PlanetClass
        local gravityCalc   = getBodyGravity(scan)
        local matContent    = ''
        local orbitalDistance = Round( scan.SemiMajorAxis/kmInLS, 2)
        local geoSignals    = geoSignals 

            if radiusKm <= 200 then
                bodyType = 'Cute Space tater ' .. bodyType
            end
            if radiusKm >= 201 and radiusKm <= 399 then 
                bodyType = 'Little ' .. bodyType
            end
        
            if radiusKm >= 400 and radiusKm <= 999 then 
                bodyType = 'Medium ' .. bodyType
            end 
            if radiusKm >= 1000 and radiusKm < 3000 then 
                bodyType = 'Bloated ' .. bodyType
            end
            if radiusKm >= 3001 and radiusKm < 6000 then
                bodyType = 'Huge ' .. bodyType
            end
            if radiusKm >= 6001 then
                bodyType = 'Enormous ' .. bodyType
            end
            
            canLand = 'Landable ' .. bodyType 

            if geoSignals then 
                canLand = ' with ' .. geoSignals .. ' geoSignals'
            end 
            
            -- If we're under 0.4 ls from the parent
            canLand = canLand .. getOrbitalDistance(scan)

            if resDesc then
                canLand = canLand .. resTitle 
                if resResult then 
                    matContent = resDesc
                end 

                return true, canLand, 'Radius: ' .. math.floor(scan.Radius/1000) .. ' km' ..  string.char(10) ..'Oribtal distance: ' .. orbitalDistance.. ' ls' .. string.char(10).. 'Gravity: ' .. gravityCalc .. string.char(10) 

            end

    end -- triggerRadiusNotification

end -- result
::End::



::Criteria::
if triggerForOrbitalDistance and scan.Landable then 
    
    local resResult, resTitle, resDesc
    local orbitalDistance = Round( scan.SemiMajorAxis/kmInLS, 2)

    -- if orbitalDistance < .4 then 
        resTitle, resResult, resDesc = checkRawMatContent( scan )

        return resResult, resTitle, resDesc

    -- end
end
::End::


--------------------------------------------------------
-- RINGS - COUNT AND CHECK and send helium percentile.
--------------------------------------------------------

::Criteria::
if scan.Rings and scan.PlanetClass then 

    local ringCount = scan.Rings.Count
    local ringy    = ' ring'
    
    if ringCount > 1 then 
        ringy = ringy .. 's'
    end

    local ringsData  =  ''
    local heliumPercentile = '';

    -- Display Helium atmosphere percentage if we're scanning a gas bag.
    if(scan.StarSystem and scan.PlanetClass and (string.match(scan.PlanetClass,'Helium') or string.match(scan.PlanetClass,'Sudarsky') or string.match(scan.PlanetClass, 'Gas giant') )) then
    for mat in materials(scan.AtmosphereComposition) do
            if mat.name == 'Helium' and mat.percent >= MINIMUM_HELIUM_FOR_NOTIFICATION then 
                heliumPercentile = string.format("%.2f", mat.percent) .. '% Helium'
            end
        end
    end 

    for ring in rings( scan.Rings ) do

            if (string.find( ring.ringclass, 'Icy')) then
                ringsData = ringsData .. ring.name:sub(-6) ..  ': Icy' .. string.char(10)
            end

            if (string.find( ring.ringclass, 'Rocky')) then
                ringsData = ringsData .. ring.name:sub(-6) ..  ': Rocky' .. string.char(10)
            end

            if (string.find( ring.ringclass, 'Metalic')) then
                ringsData = ringsData .. ring.name:sub(-6) .. ': Metallic' .. string.char(10)
            end
            if (string.find( ring.ringclass, 'MetalRich')) then
                ringsData = ringsData  .. ring.name:sub(-6) .. ': Metal-rich' .. string.char(10) 
            end
            
    end
       
    local radiusKm      = math.floor(scan.Radius/1000)
    local gravityCalc   = getBodyGravity(scan)
    local landableString = ''
    local orbitalDistance = Round( scan.SemiMajorAxis/kmInLS, 2)
    local canLand       =  ''

    if scan.Landable then 
        canLand = string.char(10) .. 'Gravity: ' .. gravityCalc
        landableString = 'Landable '
    end 


    return landableString .. scan.PlanetClass .. ' with ' .. ringCount .. ringy ..string.char(10) .. heliumPercentile, ringsData:sub(1, -2) .. string.char(10) .. 'Radius: ' .. radiusKm .. ' km' .. string.char(10) .. 'Orbital Distance: ' .. orbitalDistance .. ' ls' .. canLand

end
::End::

-----------------------
-- LANADBLES 
-----------------------

::Criteria::
if scan.Landable then 
    return "Landable " ..scan.PlanetClass , "Radius " .. math.floor(scan.Radius/1000) .. "km"
end
::End::

-----------------------
-- UNDISCOVERED SYSTEM 
-----------------------
::Criteria::
if triggerForUndiscoveredSystem == true then
	if scan.ScanType ~= "NavBeaconDetail" and scan.PlanetClass ~= "Barycentre" and not scan.WasDiscovered and scan.DistanceFromArrivalLS == 0 then
		return true, "Undiscovered system", "Primary Star Type: " .. scan.StarType .. scan.Luminosity .." Age: ".. scan.Age_MY .. " million years"
	end
end
::End::

--------------------------
-- 4.1: GEOLOGICAL SIGNALS
--------------------------
--Triggers for any body containing geological signals, returns the number of signals, the type of volcanism present, and the average surface temp.
::Criteria::
if triggerForGeoSignals == true then
	if scan.Landable then

        local photoOp           = getOrbitalDistance( scan )
        local first             = scan.Volcanism:sub(1,1)
        local last              = scan.Volcanism:sub(2)
        local radiusKm          = math.floor(scan.Radius/1000)
        local gravityCalc       = getBodyGravity(scan)
        local orbitalDistance   = Round( scan.SemiMajorAxis/kmInLS, 2)

        -- local atmosphere = scan.atmosphere 
        
	    if geosignals > 0 then
            return true, "Landable " .. scan.PlanetClass .. ' with ' .. geosignals .. ' geologic signals' .. photoOp , 'Radius: ' .. radiusKm .. ' km' .. string.char(10).. 'Orbital Distance: ' .. orbitalDistance .. ' ls' .. string.char(10).. 'Gravity: ' .. gravityCalc .. 'g' .. string.char(10) ..first .. last 
	    end
	end
end
::End::

-- Helium rich boxel?
::Criteria::
if(scan.StarSystem and scan.PlanetClass and (string.match(scan.PlanetClass,'Helium') or string.match(scan.PlanetClass,'Sudarsky') or string.match(scan.PlanetClass, 'gas giant') )) then
    this_boxel = scan.StarSystem:gsub('[%d-]+$','')
    if(this_boxel ~= last_helium_boxel) then
        for mat in materials(scan.AtmosphereComposition) do
            if mat.name == 'Helium' and mat.percent >= MINIMUM_HELIUM_FOR_NOTIFICATION then
                last_helium_boxel = this_boxel
                return true,'Possible High Helium Boxel',string.format("%.2f", mat.percent) .. '% Helium'
            end
        end
    end
end

::End::