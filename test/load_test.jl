using EarthSciMLData
using Dates
using ModelingToolkit

fs = EarthSciMLData.GEOSFPFileSet("4x5", "A3dyn")
t = DateTime(2022, 5, 1)
@test EarthSciMLData.url(fs, t) == "http://geoschemdata.wustl.edu/ExtData/GEOS_4x5/GEOS_FP/2022/05/GEOSFP.20220501.A3dyn.4x5.nc"

@test endswith(EarthSciMLData.localpath(fs, t), joinpath("GEOS_4x5", "GEOS_FP", "2022", "05", "GEOSFP.20220501.A3dyn.4x5.nc"))

ti = EarthSciMLData.DataFrequencyInfo(fs, t)
epp = EarthSciMLData.endpoints(ti)

@test epp[1] == (DateTime("2022-05-01T00:00:00"), DateTime("2022-05-01T03:00:00"))
@test epp[8] == (DateTime("2022-05-01T21:00:00"), DateTime("2022-05-02T00:00:00"))

dat = EarthSciMLData.loadslice(fs, t, "U")
@test size(dat.data) == (72, 46, 72)
@test dat.dimnames == ["lon", "lat", "lev"]

itp = EarthSciMLData.DataSetInterpolator(fs, "U")

@test EarthSciMLData.dimnames(itp, t) == ["lon", "lat", "lev"]
@test EarthSciMLData.varnames(fs, t) == ["U", "OMEGA", "RH", "DTRAIN", "V"]

@testset "interpolation" begin
    uvals = []
    times = DateTime(2022, 5, 1):Hour(1):DateTime(2022, 5, 3)
    for t ∈ times
        push!(uvals, interp!(itp, t, 1.0, 0.0, 1.0))
    end
    for i ∈ 4:3:length(uvals)-1
        @test uvals[i] ≈ (uvals[i-1] + uvals[i+1]) / 2
    end
    want_uvals = [-0.0474265694618225, 0.06403500636418662, 0.1116628348827362, 0.0954569160938263, 0.07925099730491639, 
                -0.011302002271016437, -0.1762020826339722, -0.34110216299692797, -0.5013981193304062, -0.6570899516344071]
    @test uvals[1:10] ≈ want_uvals
end