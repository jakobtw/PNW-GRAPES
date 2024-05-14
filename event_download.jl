using SeisIO, Dates

ts = "2019-07-12T09:50:00" #time start
te = "2019-07-12T09:53:00" #time end

#pull data from station as S
S = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=false, rr=false, w= true, autoname=true)
SeisIO.findchan("ENN", S) #This finds the specific channel to index
#pull specific channel out
C = pull(S,2)
#turn the channel into seisdata format
D = SeisData(C)

using Plots
#Plot to see if same
Plots.plot(S[2].x, label="ENN", legend=:topleft, title="Seismic Station UW.EVGW", xlabel="Time (s)", ylabel="Amplitude")

#get lat lon and depth
lat = S.loc[2].lat
lon = S.loc[2].lon
dep = S.loc[2].dep
#Source parameters for GRAPES input
origin_time = DateTime(2019, 7, 12, 9, 51, 38)
event_location = EQLoc(lat= 47.85, lon= -122.15, dep=0.1)
sample_time = origin_time + Second(6) #this is from GRAPES example, not sure how much time is needed

#set up graph for model
using GRAPES
#this graph set up is from the example in the GRAPES repo
rawT = 4.0 # second of input window
predictT= 60.0 # seconds to extract future PGA
k = 20 # nearest neighbors when i did 20 it gave me (k < Nrows)
maxdist = 30000.0 # meters (meters from or of what?)
logpga = true # return try PGA in log10(pga [cm/s^2])

length(D.x[1]) #I am getting K< Nrows but is the length of the data nrows? need to see with Tim

g, distance_from_earthquake, lon, lat = generate_graph(
        D, 
        rawT, 
        predictT, 
        event_location, 
        sample_time, 
        k=k, 
        maxdist=maxdist, 
        logpga=logpga, 
    )
