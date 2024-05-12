# PNW-GRAPES
GRAPES.jl is a Julia-language code for earthquake early warning, I am using it to predict PNW events.

## Overview
This project is using the GRAPES graph nerual network model made by Tim Clements for the U.S. Geological Survey found [here.](https://code.usgs.gov/esc/grapes.jl) This model can be used in real time with sesimic stations to predict peak ground acceleration (PGA), as an earthquake starts to rupture for earthquake early warning systems (EEWS). This repository shows how to pull Pacific Northwest sesimic events and use GRAPES to predict the PGA, to ultimately see how the model can be applied in other areas it was not trained on.

## Acquirng Seismic Data
To run GRAPES you need three objects. a `GNNGraph` and three vectors `distance_from_earthquake`, `lon`, `lat`. These are dependant on what station you are gathering the event from. To get this information we are using the package [SeisBase](https://juliaseismo.github.io/SeisBase.jl/dev/).

### Finding an event
We will be getting the [2019 M4.6 earthquake waveform that occured near Roosevelt, Washington](https://earthquake.usgs.gov/earthquakes/eventpage/uw61535372/executive). From the USGS website we can see what stations caputed the event, for this tutorial I will be using the Everett Gateway Middle School station (EVGW).


### Pulling event into Julia using SeisBase
SeisBase documentation can be found [here.](https://juliaseismo.github.io/SeisBase.jl/dev/)

```julia
using SeisBase

# Get the start and end time in UTC
ts = "2019-07-12T09:50:00" #time start
te = "2019-07-12T09:53:00" #time end

# Get the seisdata "S", downloading from FDSN, taking by a UW station named EVGW, from IRIS server
S = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=false, rr=false, w= true, autoname=true)
SeisBase.findchan("ENN", S) #This finds the specific channel to index
#This gets us the lat and lon of the station we are using
lat = S.loc[2].lat
loc = S.loc[2].lon
```


## Publications
T. Clements et al (Paper is not published yet)