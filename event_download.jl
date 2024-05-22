using SeisIO, Dates, GRAPES, CairoMakie, GeoMakie, GeoJSON

ts = "2019-07-12T09:50:00" #time start
te = "2019-07-12T09:53:00" #time end

#pull data from station as S1...S6 to get more than 20 channels
S1 = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=false, rr=false, w= true, autoname=true)
S2 = get_data("FDSN", "UW.LEOT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S3 = get_data("FDSN", "UW.TOLT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S4 = get_data("FDSN", "UW.QBRO", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S5 = get_data("FDSN", "UW.BEVT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S6 = get_data("FDSN", "UW.EARN", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S7 = get_data("FDSN", "UW.MS99", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)

#Push all the channels into one
S = SeisData(S1, S2, S3, S4, S5, S6, S7)

#Source parameters for M4.6 Roosevelt, WA EQ
origin_time = DateTime(2019, 7, 12, 9, 51, 38)
event_location = EQLoc(lat= 47.873, lon= 122.016, dep=28.8)
sample_time = origin_time + Second(6) #this is from GRAPES example, not sure how much time is needed

#this graph set up is from the example in the GRAPES repo
rawT = 4.0 # second of input window
predictT= 60.0 # seconds to extract future PGA
k = 5 # nearest neighbors when i did 20 it gave me (k < Nrows)
maxdist = 30000.0 # meters (meters from or of what?)
logpga = true # return try PGA in log10(pga [cm/s^2])

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

    g #7num_nodes 39num_edges, it is 400x3x1x7, 400 from the sampling time, 3 by channels, 1x7 not sure
    
    model = load_GRAPES_model() #Thanks Tim

    prediction = model(g)
    vec(prediction.ndata.x) .- vec(g.gdata.u)
    #Need to now understand amount of error, plotting error, pulling more stations?


# load the state boundary data given by Steven Walters
state = GeoJSON.read(read(".\\PNW-GRAPES\\wa_state_bnd.json", String))

# Establish the canvas for plotting
fig = Figure()
ga = GeoAxis(
    fig[1, 1]; 
    dest = "+proj=comill", title ="GRAPES Prediction")
    
poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5)

#plot station data
for i in 1:length(S)
    x = S.loc[i].lon
    y = S.loc[i].lat
    scatter!(ga, x, y, color=:red, markersize=10, marker=:circle, label = "Station", rasterize = 5)
end
fig

