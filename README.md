# PNW-GRAPES
GRAPES.jl is a Julia-language code for earthquake early warning, I am using it to predict PNW events.

## Overview
This project is using the GRAPES graph nerual network model made by Tim Clements for the U.S. Geological Survey found [here.](https://code.usgs.gov/esc/grapes.jl) This model can be used in real time with sesimic stations to predict peak ground acceleration (PGA), as an earthquake starts to rupture for earthquake early warning systems (EEWS). This repository shows how to pull Pacific Northwest sesimic events and use GRAPES to predict the PGA, to ultimately see how the model can be applied in other areas it was not trained on.

## Installation
First we need to install a specific version of SeisIO
```julia
pkg> add https://github.com/tclements/SeisIO.jl.git
```
Then to install GRAPES
```julia
pkg> add https://code.usgs.gov/esc/grapes.jl.git
```

## Acquirng Seismic Data
To run GRAPES you need three objects. a `GNNGraph` and three vectors `distance_from_earthquake`, `lon`, `lat`. These are dependant on what station you are gathering the event from. We will be using SeisIO to download the data for GRAPES to run.

### Finding an event
We will be getting the [2019 M4.6 earthquake waveform that occured near Roosevelt, Washington](https://earthquake.usgs.gov/earthquakes/eventpage/uw61535372/executive). From the USGS website we can see what stations caputed the event, for this tutorial I will be using the Everett Gateway Middle School station (EVGW).


### Pulling events into Julia using SeisIO
SeisIO documentation can be found [here.](https://seisio.readthedocs.io/en/latest/index.html)

```julia
using SeisIO

# Get the start and end time in UTC for the event 
ts = "2019-07-12T09:50:30" #time start
te = "2019-07-12T09:53:30" #time end

# Get the seisdata "S", downloading from FDSN, taking by a UW stations, from IRIS server
S1 = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=false, rr=false, w= true, autoname=true)
S2 = get_data("FDSN", "UW.LEOT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S3 = get_data("FDSN", "UW.TOLT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S4 = get_data("FDSN", "UW.QBRO", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S5 = get_data("FDSN", "UW.BEVT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S6 = get_data("FDSN", "UW.EARN", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S7 = get_data("FDSN", "UW.MS99", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
# add as many stations as you can
```
## If the stations use instraments you do not want to use you can extract the channels by
``` julia
S7 = pull(S7_channels, 1:3) 
#this is pulling the 1st 2nd and 3rd channel from an arbitrary S7_Channel
```
GRAPES uses multiple channels for its prediction. The more the better! I am currently using 54 channels from 18 different SeisData objects, so for convience we will push them all into 1 object "S"!

```julia
#Push all the channels into one
S = SeisData(S1, S2, S3, S4, S5, S6, S7) #, Sn)
```
## Setting up GRAPES
Now the model needs some parameters for the event. The numbers are taken from GRAPES' test procedure.
```julia
#Source parameters for M4.6 Roosevelt, WA EQ
origin_time = DateTime(2019, 7, 12, 9, 51, 38)
event_location = EQLoc(lat= 47.873, lon= 122.016, dep=28.8)
sample_time = origin_time + Second(6)
# parameters for GRAPES model
rawT = 4.0 # second of input window
predictT= 60.0 # seconds to extract future PGA
k = 10 # nearest neighbors when i did 20 it gave me (k < Nrows)
maxdist = 30000.0 # meters (meters from or of what?)
logpga = true # return try PGA in log10(pga [cm/s^2])
```

RawT is the input window for the model, how much space you are giving the model to make a prediction. The K controls the nearest neighbor, this is very important because if you do not have many channels you will need to reduce or else they will all be connected and causing an error.

Then to contain my input_graphs (the true values) my predictions from the model, longitude and latitude values for each station I create the following arrays

```julia
input_graphs = Array{GNNGraph}(undef, 30)
N = length(input_graphs)
preds = Array{GNNGraph}(undef, N)
lon_vals = Array{Vector{Float64}}(undef, 1)
lat_vals = Array{Vector{Float64}}(undef, 1)
```
These will be very useful for all graphing needs later on.

### Running Grapes

Then for the for loop, instead of batching the data like Tim does in his paper, We decided to run a for loop since we are only doing a single event. For this we want to be increases in each increment the sample_time, see below:

```julia
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
```

This appends values for each array we created before, the input_graph and preds are tensors with the first dimension being the number of stations, make sure these match. To validate your results this code will give us a quick way to measure the difference between GRAPES predicited value and the actual value from the Roosevelt event.

```julia
#Validate Predictions
vec(preds[20].ndata.x) .- vec(input_graphs[20].gdata.u)
```

This is predicted the 20th iteration which is about 60 seconds into our 3 minute graphs which is after the earthquake has ruptured.

### Plotting the events
I used Makie and GeoMakie for plotting, the state JSON file was made graciously by [Steven Walters](https://environment.uw.edu/faculty/steven-walters/), thank you so much again!

I will show how to plot the prediction values:
First you need to establish the canvas and geoaxis
```julia
using Makie, GeoMakie
fig = figure() #creates a blank canvas
ga = GeoAxis(
    fig[1,1], width = Relative(1), height = Relative(1.5); 
    dest = "+proj=comill", title ="GRAPES Prediction") 
    ```
    
This creates our canvas and GeoAxis, the dest chooses the projection type. Now we create a polygon of the JSON file previously mentioned here

```julia
# load the state boundary data given by Steven Walters
state = GeoJSON.read(read(".\\PNW-GRAPES\\wa_state_bnd.json", String))
poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5)
```
And now pick a specific time spot for when you want to plot, I am doing 25 or 75 Seconds after rupture.

```julia
# Get the values from preds[whatever index you want to plot]
pred_values = preds[25].ndata.x

# Create a color map
using ColorSchemes
color_map = ColorSchemes.inferno

# Get the range of pred_values for colorrange
pred_range = (minimum(pred_values), maximum(pred_values))
cbar_p_range = [minimum(pred_values),maximum(pred_values)]
cbar_p_labels = string.(cbar_p_range)
#plot prediction data
for i in 1:length(pred_values)
    x = lon_vals[i]
    y = lat_vals[i]
    Makie.scatter!(ga, x, y, color=pred_values[i],colormap=color_map, colorrange=pred_range, markersize=10, marker=:circle, label = "Station", rasterize = 5)
end
Makie.Colorbar(fig[1, 2], label = "Predicted PGA", ticks = cbar_p_range, limits = cbar_p_range) #, width = Relative(0.1), height = Relative(0.8)
fig
```
This will then give you a plot of the GRAPES predictions with a color_map of your choosing!

Many thanks to Timothy Clements and Steven Walters for their contributions to my project and thank you to Marine Denolle for advising me and helping me with this throughout the quarter!


## Publications
T. Clements et al (Paper is not published yet)