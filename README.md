# PNW-GRAPES
GRAPES.jl is a Julia-language code for earthquake early warning, I am using it to predict PNW events.

## Overview
This project is using the GRAPES graph nerual network model made by Tim Clements for the U.S. Geological Survey found [here.](https://code.usgs.gov/esc/grapes.jl) This model can be used in real time with sesimic stations to predict peak ground acceleration (PGA), as an earthquake starts to rupture for earthquake early warning systems (EEWS). This repository shows how to pull Pacific Northwest sesimic events and use GRAPES to predict the PGA, to ultimately see how the model can be applied in other areas it was not trained on.

## Acquirng Seismic Data
To run GRAPES you need three objects. a 'GNNGraph' and three vectors 'distance_from_earthquake', 'lon', 'lat'. These are dependant on what station you are gathering the event from.

### Finding an event

### Pulling event into Julia using SeisBase
SeisBase documentation can be found [here.](https://juliaseismo.github.io/SeisBase.jl/dev/)


## Publications
T. Clements et al (Paper is not published yet)