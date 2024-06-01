using Makie, GeoMakie, GeoJSON, ColorSchemes, SeisIO, Dates, GraphNeuralNetworks

function plot_grapes(preds,lon_vals,lat_vals, event_location, input_graphs)
    figs = Array{Figure}(undef, 0)
    state = GeoJSON.read(read(".\\PNW-GRAPES\\wa_state_bnd.json", String))
    fig = Figure()
    ga = GeoAxis(
        fig[1, 1], width = Relative(1), height = Relative(1); 
        dest = "+proj=comill", title ="GRAPES Prediction")
# Establish the canvas for plotting
    Makie.xlims!(ga, -123, -121)
    Makie.ylims!(ga, 47, 49)    
    poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5)    
# Create a color map
    color_map = ColorSchemes.inferno
    for ii in 1:length(preds)
        fig = Figure()
        ga = GeoAxis(
            fig[1, 1], width = Relative(1), height = Relative(1); 
            dest = "+proj=comill", title ="GRAPES Prediction")
# Establish the canvas for plotting
        Makie.xlims!(ga, -123, -121)
        Makie.ylims!(ga, 47, 49)    
        poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5) 
        pred_values = preds[ii].ndata.x
        pred_range = (minimum(pred_values), maximum(pred_values))
        cbar_p_range = [minimum(pred_values),maximum(pred_values)]
        cbar_p_labels = string.(cbar_p_range)
        for i in 1:length(pred_values)
            x = lon_vals[i]
            y = lat_vals[i]
            Makie.scatter!(ga, x, y, color=pred_values[i],colormap=color_map, colorrange=pred_range, markersize=15, marker=:circle, label = "Station", rasterize = 5, colorbar_title = "Predicted PGA")
        end
        Makie.scatter!(ga, -event_location.lon, event_location.lat, color=:red, markersize=20, marker=:star5, label = "Event Location", rasterize = 5)
    end
    for ii in 1:length(input_graphs)
        real_values = input_graphs[ii].gdata.u
        real_range = (minimum(real_values), maximum(real_values))
        ga2 = GeoAxis(
            fig[1, 2]; 
            dest = "+proj=comill", title ="GRAPES Real Data")
        poly!(ga2, state; strokewidth = 0.7, color=:green, rasterize = 5)
        Makie.xlims!(ga2, -123, -121)
        Makie.ylims!(ga2, 47, 49)
        for i in 1:length(real_values)
            x = lon_vals[i]
            y = lat_vals[i]
            Makie.scatter!(ga2, x, y, color=real_values[i],colormap=color_map, colorrange=real_range, markersize=15, marker=:circle, label = "Station", rasterize = 5, colorbar_title = "Real Data")
        end
        Makie.scatter!(ga2, -event_location.lon, event_location.lat, color=:red, markersize=20, marker=:star5, label = "Event Location", rasterize = 5)
        push!(figs, fig)
    end
    return figs
end