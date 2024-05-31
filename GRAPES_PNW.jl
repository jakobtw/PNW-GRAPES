using SeisIO, Dates, GRAPES, CairoMakie, GeoMakie, GeoJSON, GraphNeuralNetworks, ColorSchemes, Makie

ts = "2019-07-12T09:50:30" #time start
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
#S = SeisData(S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12)
S_true = SeisData(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S19)

#Source parameters for M4.6 Roosevelt, WA EQ
origin_time = DateTime(2019, 7, 12, 9, 51, 38)
event_location = EQLoc(lat= 47.873, lon= 122.016, dep=28.8)
sample_time = origin_time + Second(6) #this is from GRAPES example, not sure how much time is needed

#set up the parameters for the GRAPES model
rawT = 4.0 # second of input window
predictT= 60.0 # seconds to extract future PGA
k = 10 # nearest neighbors when i did 20 it gave me (k < Nrows)
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
        S_true, 
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
#Index predictions like this
preds[30]
#Validate Predictions
vec(preds[20].ndata.x) .- vec(input_graphs[20].gdata.u)
#Index the predictions / true values like this
preds[20].ndata.x
input_graphs[20].gdata.u


# load the state boundary data given by Steven Walters
state = GeoJSON.read(read(".\\PNW-GRAPES\\wa_state_bnd.json", String))

# Establish the canvas for plotting
fig = Figure()
ga = GeoAxis(
    fig[1, 1]; 
    dest = "+proj=comill", title ="GRAPES Prediction")
    
poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5)

# Create a color map
color_map = ColorSchemes.inferno

# Get the values from preds[whatever index you want to plot]
pred_values = preds[25].ndata.x

# Get the range of pred_values for colorrange
pred_range = (minimum(pred_values), maximum(pred_values))

#plot prediction data
for i in 1:length(pred_values)
    x = lon_vals[i]
    y = lat_vals[i]
    Makie.scatter!(ga, x, y, color=pred_values[i],colormap=color_map, colorrange=pred_range, markersize=10, marker=:circle, label = "Station", rasterize = 5)
end
fig

#Get the values from input_graphs[whatever index you want to plot]
real_values = input_graphs[25].gdata.u

# Get the range of real_values for colorrange
real_range = (minimum(real_values), maximum(real_values))

fig = Figure()
ga = GeoAxis(
    fig[1, 1]; 
    dest = "+proj=comill", title ="GRAPES Real Data")
    
poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5)
#plot real data
for i in 1:length(real_values)
    x = lon_vals[i]
    y = lat_vals[i]
    Makie.scatter!(ga, x, y, color=real_values[i],colormap=color_map, colorrange=real_range, markersize=10, marker=:circle, label = "Station", rasterize = 5)
end
fig

