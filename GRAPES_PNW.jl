using SeisIO, Dates, GRAPES, CairoMakie, GeoMakie, GeoJSON, GraphNeuralNetworks, ColorSchemes, Makie, Statistics, Plots

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
S10 = get_data("FDSN", "UW.QKEV", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S11 = get_data("FDSN", "UW.QOCL", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S12_station = get_data("FDSN", "UW.MANO", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S13 = get_data("FDSN", "UW.OHC", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S14_station = get_data("FDSN", "UW.RVW2", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S15 = get_data("FDSN", "UW.KIMR", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S16 = get_data("FDSN", "UW.TLW1", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S17_station = get_data("FDSN", "UW.RATT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S18 = get_data("FDSN", "UW.QNWT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S19 = get_data("FDSN", "UW.QSNZ", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S20 = get_data("FDSN", "UW.QMIN", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S21 = get_data("FDSN", "UW.QSNL", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S22 = get_data("FDSN", "UW.SCC", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S23 = get_data("FDSN", "UW.QBOV", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S24 = get_data("FDSN", "UW.QESB", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S25 = get_data("FDSN", "UW.EARN", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S26 = get_data("FDSN", "UW.QKTN", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S27 = get_data("FDSN", "UW.BEVT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S28 = get_data("FDSN", "UW.QFAL", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S28 = get_data("FDSN", "UW.QBIT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S29 = get_data("FDSN", "UW.QNKP", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S30 = get_data("FDSN", "UW.NOWS", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)
S31 = get_data("FDSN", "UW.ALCT", src="IRIS", s=ts, t=te, detrend=true, rr=false, w=true, autoname=true)








display(S13_station)


#Prune the stations with too many channels for just first 3
S12 = pull(S12_station, 1:3)
S14 = pull(S14_station, 1:3)
S17 = pull(S17_station, 1:3)


#Push all the channels into one
#S = SeisData(S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12)
S = SeisData(S1,S2,S3,S4,S5,S6,S7,S8,S10,S11,S12,S14,S15,S16,S17,S18,S19,S20,S21,S22,S23,S24,S25,S26,S27,S28,S29,S30,S31)

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

S[6].gain
S[1].x=  S[1].x ./ S[1].gain
S[1].x


#Source parameters for M4.6 Roosevelt, WA EQ
origin_time = DateTime(2019, 7, 12, 9, 51, 38)
event_location = EQLoc(lat= 47.873, lon= 122.016, dep=28.8)
sample_time = origin_time + Second(6) #this is from GRAPES example, not sure how much time is needed

#set up the parameters for the GRAPES model
rawT = 4.0 # second of input window
predictT= 60.0 # seconds to extract future PGA
k = 13 # nearest neighbors when i did 20 it gave me (k < Nrows)
maxdist = 30000.0 # meters (meters from or of what?)
logpga = true # return try PGA in log10(pga [cm/s^2])

# Calculate the difference in seconds
time_start = DateTime(ts, "yyyy-mm-ddTHH:MM:SS")
time_end = DateTime(te, "yyyy-mm-ddTHH:MM:SS")
difference_in_seconds = Dates.value(Dates.Second(time_end - time_start))

#120/4 = 30 so we need 30 GNN graphs
input_graphs = Array{GNNGraph}(undef, 30)
N = length(input_graphs)
preds = Array{GNNGraph}(undef, N)

#Initate the model
model = load_GRAPES_model() #Thank you Tim
lon_vals = Array{Vector{Float64}}(undef, 1)
lat_vals = Array{Vector{Float64}}(undef, 1)

#For loop that generaltes g (GNNGraph) and predictions for each station
for ii in 1:N
    sample_time = origin_time + Second(ii*3)
    g, distance_from_earthquake, lon, lat = generate_graph(
        S, 
        rawT, 
        predictT, 
        event_location, 
        sample_time, 
        k=k, 
        maxdist=maxdist, 
        logpga=logpga, 
    )
    input_graphs[ii] = g
    preds[ii] = model(input_graphs[ii])
    lon_vals = lon
    lat_vals = lat
end
preds
input_graphs[1].gdata.u
#Index predictions like this
preds[23]
#Validate Predictions
vec(preds[8].ndata.x) .- vec(input_graphs[8].gdata.u)
#Index the predictions / true values like this
preds[20].ndata.x
input_graphs[20].gdata.u

#Getting the MAE of the predictions
differences = abs.(vec(preds[8].ndata.x) .- vec(input_graphs[8].gdata.u))
#MAE
mae = mean(differences)

#Plot the predictions and true values
include(".\\func\\plot_grapes.jl")
grapes_figs = plot_grapes(preds, lon_vals, lat_vals, event_location, input_graphs)
for i = 1:30
    display(grapes_figs[i])
end
save("GRAPES_plot.png", grapes_figs[8])

#Creating MAE plot
mae = []
for i = 1:30
    differences = abs.(vec(preds[i].ndata.x) .- vec(input_graphs[i].gdata.u))
    push!(mae, mean(differences))
end
p = Plots.plot(1:30, mae, xlabel="Time (s)", ylabel="Mean Absolute Error", title="Mean Absolute Error of GRAPES Predictions", label ="MAE")
display(p)
save("GRAPES_MAE_plot.png", p)