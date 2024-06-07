using Makie, GeoMakie, GeoJSON, ColorSchemes, SeisIO, Dates, GraphNeuralNetworks

function plot_grapes(preds,lon_vals,lat_vals, event_location, input_graphs)
    figs = Array{Figure}(undef, 0)
    state = GeoJSON.read(read(".\\PNW-GRAPES\\wa_state_bnd.json", String))
# Create a color map
    color_map = ColorSchemes.inferno
    for ii in eachindex(preds)
        real_range_array = Float32[]
        # Establish the canvas 1 for plotting
        fig = Figure()
        #Add a main title to the figure
        title_axis = Axis(fig[1, 1]; height = 50)
        hidexdecorations!(title_axis, ticks = false, grid = false)
        hideydecorations!(title_axis, ticks = false, grid = false)
        text!(title_axis, "$(ii*3) Seconds After Rupture", position = (0.5, 0.5), align = (:center, :center))
        ga = GeoAxis(
            fig[2, 1], width = Relative(1), height = Relative(1); 
            dest = "+proj=comill", title ="GRAPES Prediction")
        Makie.xlims!(ga, -123, -121)
        Makie.ylims!(ga, 47, 49)    
        poly!(ga, state; strokewidth = 0.7, color=:green, rasterize = 5) 
        # Establish the canvas 2 for plotting
        ga2 = GeoAxis(
            fig[2, 2]; 
            dest = "+proj=comill", title ="GRAPES Real Data")
        poly!(ga2, state; strokewidth = 0.7, color=:green, rasterize = 5)
        Makie.xlims!(ga2, -123, -121)
        Makie.ylims!(ga2, 47, 49)
        pred_values = preds[ii].ndata.x
        pred_range = (minimum(pred_values), maximum(pred_values))
        for i in eachindex(pred_values)
            x = lon_vals[i]
            y = lat_vals[i]
            Makie.scatter!(ga, x, y, color=pred_values[i],colormap=color_map, colorrange=pred_range, markersize=15, marker=:circle, label = "Station", rasterize = 5, colorbar_title = "Predicted PGA")
        end
        real_values = -input_graphs[ii].gdata.u
        real_range = (minimum(real_values), maximum(real_values))
        real_range_array = collect(real_range)
        for i in eachindex(real_values)
            x = lon_vals[i]
            y = lat_vals[i]
            Makie.scatter!(ga2, x, y, color = real_values[i],colormap=color_map, colorrange=real_range, markersize=15, marker=:circle, label = "Station", rasterize = 5, colorbar_title = "Real Data")
        end
        Makie.scatter!(ga2, -event_location.lon, event_location.lat, color=:red, markersize=20, marker=:star5, label = "Event Location", rasterize = 5)
        Makie.scatter!(ga, -event_location.lon, event_location.lat, color=:red, markersize=20, marker=:star5, label = "Event Location", rasterize = 5)
        Makie.Colorbar(fig[3,1], colormap=color_map, ticks = real_range_array, limits = real_range_array, label = "PGA", vertical=false, halign =:right)
        colgap!(fig.layout,-24)
        trim!(fig.layout)
        push!(figs, fig)
    end
    return figs
end