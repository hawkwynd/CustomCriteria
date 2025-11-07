-- Raw mats
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'arsenic')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'cadmium')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'germanium')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'niobium')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'polonium')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'vanadium')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
::Criteria::
resResult, resTitle, resDesc = checkRawMatContent(scan, 'yttrium')
if resResult then
    return resResult, resTitle, resDesc
end
::End::
