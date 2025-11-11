::Global::

triggerForUndiscoveredSystem    = true 
triggerForGeoSignals            = true 
triggerForNarrowRings           = true
last_helium_boxel               = ''
MINIMUM_HELIUM_FOR_NOTIFICATION = 29


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
    ['tungsten']=0.94,
    ['vanadium']=4.33,
    ['yttrium']=1.04,
    ['zinc']=4.77,
    ['zirconium']=2.1
}

-- Percent below max value that's labeled as "high", by default 0.25 = 75% below maximum known value
desperationLevel = 0.25

-- Whether above average values should trigger a notification
aboveAverage = true

-- Similar to desperationLevel, but as the percent above the average value
aboveAverageLevel = 0.0

-- List all of the materials that you want to be alerted for

wantedMaterials = {'germanium','polonium', 'tungsten', 'vanadium', 'arsenic', 'boron', 'molybdenum', 'niobium', 'rhenium', 'ruthenium', 'selenium', 'tellurium', 'yytrium', 'zirconium'}

-- how many kilometers per light second
kmInLS = 299792458				


-- Random Smart ass comment 
function randomSmartAlec( event ) 
    local smartAlec = {}

    math.randomseed(os.time()) -- create a random seed

    if event == "scan" then 
        smartAlec = {"Good work, now have a mokie treat!", "Great Job, Slapnut!", "o7 Commander!", "You rockstar!!"}
    end 
    if event == "sloppy" then 
        smartAlec = {"What a mess, some commander left a beer bottle.", "Oh wow, what a trashy looking system.", "Look it that - clutter everywhere!", "Another good system turned to crap!", "Let's get the hell out of here.","I smell ass...","This system is junk! Move along!", "I got bad feeling about this one...", "Another tainted system, we must be in or near the boo-blay."} 
    end 

    local randomIndex = math.random(#smartAlec )
    
    return smartAlec[randomIndex]

end

-- round to number 
function round(n)
    return math.floor((math.floor(n*2) + 1)/2)
end

-- uppercase 1st letter of string
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

-- bodysizer 
function bodySizer( radiusKm, pClass  )

    local bodyType = ''

        if radiusKm <= 200 then
                bodyType = 'Cute Space tater ' .. pClass
            end
            if radiusKm >= 201 and radiusKm <= 399 then 
                bodyType = 'Itty Bitty ' .. pClass
            end
        
            if radiusKm >= 400 and radiusKm <= 999 then 
                bodyType = 'Goldilocks ' .. pClass
            end 
            if radiusKm >= 1000 and radiusKm < 3000 then 
                bodyType = 'Gerthy ' .. pClass
            end
            if radiusKm >= 3001 and radiusKm < 6000 then
                bodyType = 'Fatso ' .. pClass
            end
            if radiusKm >= 6001 then
                bodyType = 'Monstrous ' .. pClass
            end
            return bodyType
        end             
-- Verify that the body contains one or more of our materials 
-- and report the percentage levels 

function checkRawMatContent( scan )

    local resResult     = false
    local radiusKm      = math.floor(scan.Radius/1000)
    local resTitle      = "Landable " .. bodySizer( radiusKm, scan.PlanetClass )
    local foundWanted   = ''
    local maxMatsPerLine= 2 -- max number of mats per line in details 
    local matsPerLine   = 0 -- counter of mats per line in details 
    local matName       = ''
    local percentage    = 0
    local gravityCalc   = (scan.SurfaceGravity/9.81)
    local realTemp      = tonumber(string.format('%.1f', scan.SurfaceTemperature)) .. "K"
    local atmosInfo     = "No Atmosphere"

    for material in materials( scan.Materials ) do
            local wanted = false
            
            for index, value in ipairs(wantedMaterials) do
                if value == material.name then
                   wanted       = true
                   resResult    = true
                   
                --    matName = string.sub( firstToUpper( material.name ),1, 4 ) -- uppercase 1st letter of material name get 1st 4 chars 
                   matName    = firstToUpper( material.name ) -- uppercase 1st letter of material name get 1st 4 chars 
                   percentage = tonumber( material.percent )

                   foundWanted = foundWanted .. matName .. ":" .. string.format("%.1f", percentage ) .. "% "

                    if matsPerLine >= maxMatsPerLine then 
                        foundWanted = foundWanted .. string.char(10)
                    end 
                    
                    matsPerLine = matsPerLine+1

                    -- break
                end -- end if value == material.name 
            end -- for index, value in
           
            -- if wanted then
                -- if percent ~= nil and percent >= ( (1 - desperationLevel) * tonumber( maxLevels[matName] ) ) then
                --     resResult = true
                --     resDesc = matName .. ' content: ' .. string.format("%.1f", percent) .. ' %'
                --     if scan.Volcanism ~= nil and scan.Volcanism ~= '' then
                --         resTitle = 'High ' .. matName .. ' content with ' .. scan.Volcanism
                --     else
                --         resTitle = 'High ' .. matName .. ' content'
                --     end

                -- elseif aboveAverage and percent ~= nil and percent > ((1 - aboveAverageLevel) * tonumber(avgLevels[matName])) then

                --     resResult = true
                --     resDesc = matName .. ' content: ' .. string.format("%.1f", percent) .. ' %'

                --     if scan.Volcanism ~= nil and scan.Volcanism ~= '' then
                --         resTitle = 'Above average ' .. matName .. ' content with ' .. scan.Volcanism
                --     else
                --         resTitle = 'Above average ' .. matName .. ' content'
                --     end
                -- end

                
                -- end -- if wanted 
                
        end

        if matsPerLine <= maxMatsPerLine then 
            foundWanted = foundWanted .. string.char(10) 
        end 
            -- if wanted then 

        --  .. withAtmosphere info .. 
        -- for mat in materials(scan.AtmosphereComposition) do
        --     atmosInfo = atmosInfo .. mat.name .. ":" .. string.format("%.2f",mat.percent) .. '%' .. string.char(10)
        -- end

        if scan.Atmosphere then 
            atmosInfo = firstToUpper(scan.Atmosphere)
        end 


        return resResult, resTitle, foundWanted .. "Surface gravity: ".. getBodyGravity(scan) .. string.char(10) .. "Surface Temp: " .. realTemp .. string.char(10) .. atmosInfo

end -- function end

-- Return gravity of the body in g force
function getBodyGravity(scan)
    local gravityCalc = (scan.SurfaceGravity/9.81)
    if gravityCalc ~=nill then 
        return round( gravityCalc, 2) .. 'g'
    end
end


-- Prime Photo Body check 
function getOrbitalDistance( scan )
    local payload = ""
    local orbitalDistance = round( scan.SemiMajorAxis/kmInLS, 2 )
    if orbitalDistance < .4 then 
        payload = string.char(10) .. "Surface Photo opportunity"
    end

    return payload

end


::End::

-- --------------------------------------------------------
-- CRITERIA STARTS HERE
-- --------------------------------------------------------


::Criteria::
if scan.Landable then 
    local res, title, desc = checkRawMatContent(scan)

    if res then 
        return res, title, desc 
    end

end
::End::

-----------------------
-- UNDISCOVERED SYSTEM 
-----------------------
::Criteria::
if triggerForUndiscoveredSystem == true then
	if scan.ScanType ~= "NavBeaconDetail" and scan.PlanetClass ~= "Barycentre" and not scan.WasDiscovered and scan.DistanceFromArrivalLS == 0 then
		return true, "Undiscovered system", "Primary Star Type: " .. scan.StarType .. scan.Luminosity .. string.char(10).. "Age: ".. scan.Age_MY .. " my" ..string.char(10) .. randomSmartAlec("scan")
    end 
end
::End::

::Criteria::
if scan.ScanType ~= "NavBeaconDetail" and scan.PlanetClass ~= "Barycentre" and scan.WasDiscovered and scan.DistanceFromArrivalLS == 0 then
    return true, "*** Sloppy Seconds ALERT ***", "Already discovered system!" .. randomSmartAlec("sloppy")
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
        local orbitalDistance   = round( scan.SemiMajorAxis/kmInLS, 2)

        -- local atmosphere = scan.atmosphere 
        
	    if geosignals > 0 then
            return true, "Landable " .. scan.PlanetClass .. ' with ' .. geosignals .. ' geologic signals' .. photoOp , 'Radius: ' .. radiusKm .. ' km' .. string.char(10).. 'Orbital Distance: ' .. orbitalDistance .. ' ls' .. string.char(10).. 'Gravity: ' .. gravityCalc .. 'g' .. string.char(10) .. first .. last 
	    end
	end
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
    local orbitalDistance = round( scan.SemiMajorAxis/kmInLS, 2)
    local canLand       =  ''

    if scan.Landable then 
        canLand = string.char(10) .. 'Gravity: ' .. gravityCalc
        landableString = 'Landable '
    end 


    return landableString .. scan.PlanetClass .. ' with ' .. ringCount .. ringy ..string.char(10) .. heliumPercentile, ringsData:sub(1, -2) .. string.char(10) .. 'Radius: ' .. radiusKm .. ' km' .. string.char(10) .. 'Orbital Distance: ' .. orbitalDistance .. ' ls' .. canLand

end
::End::

---------------------------------------------
-- 3.7: TAYLOR'S RINGS AND OTHER NARROW RINGS
---------------------------------------------
--Narrow single ring - Single ring with a width less than 1/4th (25%) of its body's diameter (0.5 could be reduced to 0.4 for 20% max)
--Taylor's Ring - Thin single ring with a width less than 1/8th (12.5%) of its body's diameter.
-- ::Criteria::
-- if triggerForNarrowRings == true then
-- if (scan.Rings and scan.Rings.Count == 1 and string.find(scan.Rings[0].Name, ' Ring') and 
--    ((scan.Rings[0].OuterRad - scan.Rings[0].InnerRad) / (scan.Radius * 2) <= narrowRingThreshold)) then
-- 	local ringwidth = ((scan.Rings[0].OuterRad - scan.Rings[0].InnerRad) / 1000)
-- 	local diameter = scan.Radius/1000*2
-- 	local found = string.format('Narrow single ring only %.0f%% of body diameter', ringwidth/diameter*100)
-- 	if ((scan.Rings[0].OuterRad - scan.Rings[0].InnerRad) / (scan.Radius * 2) <= 0.125) then
-- 		found = "Taylor's Ring"
-- 	end
-- 	return true, found, string.format('Ring width: %.0f km, Body diameter: %.0f km (%.1f%%)', ringwidth, diameter, ringwidth/diameter*100)
-- 	.. string.char(10) .. scan.PlanetClass .. ', Distance from arrival: ' .. math.floor(scan.DistanceFromArrivalLS) .. ' LS'
-- 	end
-- end
-- ::End::