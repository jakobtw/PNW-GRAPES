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
ts = "2019-07-12T09:50:00" #time start
te = "2019-07-12T09:53:00" #time end

# Get the seisdata "S", downloading from FDSN, taking by a UW stations, from IRIS server
S1 = get_data("FDSN","UW.EVGW.",src="IRIS", s=ts,t=te, detrend=false, rr=false, w= true, autoname=true)
S2 = get_data("FDSN", "UW.LEOT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S3 = get_data("FDSN", "UW.TOLT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S4 = get_data("FDSN", "UW.QBRO", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S5 = get_data("FDSN", "UW.BEVT", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S6 = get_data("FDSN", "UW.EARN", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)
S7 = get_data("FDSN", "UW.MS99", src="IRIS", s=ts, t=te, detrend=false, rr=false, w=true, autoname=true)

```
GRAPES uses multiple channels for its prediction. The more the better! With this pull we currently have 21 channels split into 7 different SeisData objects, so for convience we will push them all into 1 object "S"!

```julia
#Push all the channels into one
S = SeisData(S1, S2, S3, S4, S5, S6, S7)
```
Now the model needs some parameters for the event. The numbers are taken from GRAPES' test procedure.
```julia
#Source parameters for M4.6 Roosevelt, WA EQ
origin_time = DateTime(2019, 7, 12, 9, 51, 38)
event_location = EQLoc(lat= 47.873, lon= 122.016, dep=28.8)
sample_time = origin_time + Second(6)
```


## Publications
T. Clements et al (Paper is not published yet)