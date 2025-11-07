-- Criteria modified from the "Rare Materials" criteria by @vithigar#7510
-- Modified to have max and average levels for all materials, a "wanted materials" list, and the ability to notify for above average levels (if desired)

::Global::

kmInLS		        = 299792458				-- how many kilometers per light second
terraMoonThreshold  = 2

function round(n)
    return math.floor((math.floor(n*2) + 1)/2)
end

function convertAUKM( au )
    
  --l km = 149,597,871 × lau
  --l ls = 499.004784 × l au

    au = round(au) 
    ls = round(au / 500)

    return comma_value(au) .. ' au : ' .. comma_value(ls) .. ' ls'

    -- return  comma_value(au)
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

-- List all of the materials that you want to be alerted for here
wantedMaterials = {'germanium','polonium','iron', 'tungsten', 'sulfur', 'nickel', 'vanadium', 'arsenic'}

function checkRawMatContent(scan)
    local resResult = false
    local resTitle, resDesc = ''
    if scan.Landable then
        for material in materials(scan.Materials) do
            wanted = false
            for index, value in ipairs(wantedMaterials) do
                if value == material.name then
        wanted = true
                end
            end
            if wanted then
                
                local matName = material.name

                if material.percent ~=null and  tonumber(material.percent) >= ((1 - desperationLevel) * tonumber(maxLevels[matName])) then
                    resResult = true
                    resDesc = 'Content: ' .. string.format("%.1f", material.percent) .. ' %'
                    if scan.Volcanism ~= nil and scan.Volcanism ~= '' then
                        resTitle = 'High ' .. matName .. ' content with volcanism'
                    else
                        resTitle = 'High ' .. matName .. ' content'
                    end
                else if aboveAverage and tonumber(material.percent) > ((1 - aboveAverageLevel) * (tonumber(avgLevels[matName]))) then
                    resResult = true
                    resDesc = 'Content: ' .. string.format("%.1f", material.percent) .. ' %'
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
end

-- For use in Atmospheric Landables and Bios
function math.round(Value, Precision)
    return math.floor(Value * (10 ^ Precision)) / 10 ^ Precision
  end

::End:: -- Global Ends here

-- Begin Criteria sections 

-- undiscovered system
-- ::UndiscoveredSystem::
-- scan.ScanType ~= "NavBeaconDetail" and scan.PlanetClass ~= "Barycentre" and not scan.WasDiscovered and scan.DistanceFromArrivalLS == 0
-- ::Detail::
-- 'Type ' .. scan.StarType .. ' age ' .. comma_value(scan.Age_MY) .. ' my'

-- -- Materials Rare 
-- ::Criteria::
--     resResult, resTitle, resDesc = checkRawMatContent(scan)
--     if resResult then
--         return resResult, resTitle, resDesc
--     end
-- ::End::


-- Rings of Interest 

-- ::Criteria=Rings of Interest::
-- for ring in ringsOnly(scan.Rings) do
--   if (string.find(ring.ringclass, 'Icy')) then
--     return true, 'Icy Ring', math.floor(scan.DistanceFromArrivalLS) .. ' Ls'
--   -- elseif (string.find(ring.ringclass, 'Metalic')) then
--     -- return true, 'Metallic Ring', math.floor(scan.DistanceFromArrivalLS) .. ' Ls'
--   end
-- end
-- ::End::


-- ::Criteria=Atmospheric Landables and Bios::
-- if scan.Landable and scan.SurfacePressure > 0 and scan.Atmosphere ~= '' then
--   if biosignals > 0 then
--     return true, biosignals..' bio landable with '..scan.Atmosphere, math.round(scan.SurfacePressure * 0.00000986923, 2)..' atms, '..geosignals..' geological signals'
--   end
--   return true, 'Landable with '..scan.Atmosphere, math.round(scan.SurfacePressure * 0.00000986923, 2)..' atms, '..geosignals..' geological signals'
-- end
-- ::End::


-- ::Undiscovered Ammonia World:
-- scan.WasDiscovered == false and scan.PlanetClass == 'Ammonia world'
-- ::Detail::
-- 'Undiscovered Ammonia world ' .. math.floor(scan.SurfaceTemperature) .. ' K'

-- ::Undiscovered Water World::
-- scan.WasDiscovered == false and scan.PlanetClass == 'Water world'
-- ::Detail::
-- 'Undiscovered Water World ' .. math.floor(scan.SurfaceTemperature) .. ' K'

-- ::Undiscovered Earthlike World::
-- scan.WasDiscovered == false and scan.PlanetClass == 'Earthlike body'
-- ::Detail::
-- 'Undiscovered Earthlike Body ' .. math.floor(scan.SurfaceTemperature) .. ' K'


-- Close proximity moon to parent 
-- ::Moon Distance To Parent::
-- parents and parents[0].ParentType == 'Planet' and scan.landable and scan.Parents[0] == 'Planet'
-- ::Detail::
-- "Orbital Distance:" .. round(scan.SemiMajorAxis/kmInLS, 2) .. " ls"

-- --     if(parents and parents[0].ParentType == 'Planet') then 
-- --         if scan.Landable and scan.Parents[0] == 'Planet' then
-- --             local orbitDistance = (scan.SemiMajorAxis / kmInLS)
-- --                 return true, "Orbital distance: " .. round( orbitDistance,2 ) .. " LS", "Body Type: " .. scan.PlanetClass
-- --         end
-- --     end

::End::


-- -- Hot landable moon of ringed parent 
-- ::Criteria::
-- if scan.Landable and scan.SurfaceTemperature > 1000 and parents then
--   if parents[0].Scan and parents[0].ParentType == 'Planet' and parents[0].Scan.Rings then
--     return true, 'Hot Landable Moon of Ringed Parent', 'Temperature: ' .. math.floor(scan.SurfaceTemperature) .. ' K'
--   end
-- end
-- ::End::