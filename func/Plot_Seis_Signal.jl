#Copy pulling data from GRAPES_PNW.jl
using SeisIO, Dates, GRAPES, CairoMakie, GeoMakie, GeoJSON, GraphNeuralNetworks, ColorSchemes, Makie, Plots

ts = "2019-07-12T09:51:30" #time start
te = "2019-07-12T09:53:30" #time end


#Pull Data from multiple stations for single event
S1 = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=true, rr=false, w= true, autoname=true)
S2 = get_data("FDSN", "UW.LEOT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S3 = get_data("FDSN", "UW.TOLT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S4 = get_data("FDSN", "UW.QBRO", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S5 = get_data("FDSN", "UW.BEVT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S6 = get_data("FDSN", "UW.EARN", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S7 = get_data("FDSN", "UW.MS99", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S8 = get_data("FDSN", "UW.SWID", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S9 = get_data("FDSN", "UW.QGFY", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S10 = get_data("FDSN", "UW.MBKE", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S11 = get_data("FDSN", "UW.QKEV", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S12 = get_data("FDSN", "UW.QOCL", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S13_station = get_data("FDSN", "UW.MANO", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S14 = get_data("FDSN", "UW.OHC", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S15_station = get_data("FDSN", "UW.RVW2", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S16 = get_data("FDSN", "UW.KIMR", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S17 = get_data("FDSN", "UW.TLW1", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S18_station = get_data("FDSN", "UW.RATT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)





#Prune the stations with too many channels for just first 3
S13 = pull(S13_station, 1:3)
S15 = pull(S15_station, 1:3)
S18 = pull(S18_station, 1:3)


#Push all the channels into one
S = SeisData(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18)

#Remove Gain from the stations
for i in 1:length(S)
    println("Before division:")
    println("Gain: ", S[i].gain)
    println("First 3 x values: ", S[i].x[1:3])

    newS = S[i]
    newS.x = newS.x ./ newS.gain
    # Create a new SeisData object with the modified x values
    #new_S = SeisData(S[i].x ./ S[i].gain)


    if newS.units == "m/s"
        # Take the derivative of S[i].x
        derivative = diff(newS.x)

        # Append a zero at the end to keep the same length
        derivative = vcat(derivative, 0) * S[i].fs

        # Replace S[i].x with its derivative
        newS.x = derivative
    end
    S[i] = newS
    println("After division:")
    println("First 3 x values: ", S[i].x[1:3])
end

# lat and lon of Roosevelt EQ
event_location = EQLoc(lat= 47.873, lon= -122.016, dep=28.8)

# Create an empty plot
P = Plots.plot()
for i in 1:3:length(S)

    # Calculate the time vector for the current signal
    tvec = collect(0:1/S[i].fs:length(S[i].x)/S[i].fs)
    # Calculate the distance from the event location for the current signal
    dist = sqrt.((S.loc[i].lat - event_location.lat).^2 .+ (S.loc[i].lon .- event_location.lon).^2 .* 110)
    
    # Add the current signal to the plot
    Plots.plot!(P, tvec[1:length(tvec)-1], S[i].x * (10^6) .+ dist .* ones(length(S[i].x)), xlabel="Time (s)", ylabel="Distance from Earthquake rupture (km)", title="Seismic Signals from the Roosevelt Earthquake", legend=false)

    # Add the station name to the plot
    Plots.annotate!(P, tvec[end], S[i].x[end] * (10^6) + dist, Plots.text(S[i].name, 5, :right))
end
display(P)
Plots.savefig(P, "Seismic_Signals_from_the_Roosevelt_Earthquake.png")