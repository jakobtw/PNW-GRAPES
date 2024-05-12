using SeisBase
# This is a quick test for julia's Seisbase package to pull single events and plot them using Plots

# Get the start and end time in UTC
ts = "2019-07-12T09:50:00" #time start
te = "2019-07-12T09:53:00" #time end
# later want to use a location dependant function to get the start time and set an end time

# Get the seisdata "S", downloading from FDSN, taking by a UW station named EVGW, from IRIS server
S = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=false, rr=false, w= true, autoname=true)
SeisBase.findchan("ENN", S) #This finds the specific channel to index
#This gets us the lat and lon of the station we are using
lat = S.loc[2].lat
loc = S.loc[2].lon

using Plots

#Plots the event
Plots.plot(S[2].x, label="ENN", legend=:topleft, title="Seismic Station UW.EVGW", xlabel="Time (s)", ylabel="Amplitude")
#Personal Projects to add
# Seisnoise to make plots nicer, make plot have more features such as time axis
# Make some sort of Pandas DF equvialent and Obspy way to pull events, gather station data to calculate arrival time