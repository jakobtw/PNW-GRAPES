#Copy pulling data from GRAPES_PNW.jl

tvec = collect(0:1/S1[1].fs:length(S1[1].x)/S1[1].fs)
tvec_date = u2d.(tvec[1:length(tvec)-1] .+ S1[1].t[1,2]*1e-6) 
# Create the plot
fig = Figure()
for iii in 1:3:length(S)
    P = Plots.plot(tvec[1:length(tvec)-1],S[iii].x)
    display(P)
end
P = Plots.plot(tvec[1:length(tvec)-1],S1[1].x)
display(P)