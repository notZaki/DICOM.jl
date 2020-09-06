export rtstruct_regions

abstract type AbstractCoordinates end
struct Coordinate3D{T} <: AbstractCoordinates
    x::T
    y::T
    z::T
end

function rtstruct_regions(dcm)
    regions = dcm[tag"RT ROI Observations Sequence"]
    regiondict = Dict()
    for region in regions
        label = region[tag"ROI Observation Label"]
        refnum = region[tag"Referenced ROI Number"]
        contours = get_contours(dcm, refnum)
        contourdict = Dict()
        for contour in contours
            contourdata = contour[tag"Contour Data"]
            coordinates = [Coordinate3D(p...) for p in Iterators.partition(contourdata, 3)]
            push!(contourdict, first(coordinates).z => coordinates)
        end
        push!(regiondict, label => contourdict)
    end
    return regiondict
end

function get_contours(dcm, refnum)
    allcontours = dcm[tag"ROI Contour Sequence"]
    contours = filter(x -> x[tag"Referenced ROI Number"] == refnum, allcontours)
    return only(contours)[tag"Contour Sequence"]
end
