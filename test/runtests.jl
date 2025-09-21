using ProfileViewMakie
using Test
using Profile
using CairoMakie

f, ax, pl = ProfileViewMakie.@profileview rand(5000, 5000)
save("profileview.png", f)
@test isfile("profileview.png")

Profile.clear()
Profile.@profile rand(3000, 3000)
g = ProfileViewMakie.flamegraph()
f, ax, pl = profileview(g)
save("profileview2.png", f)
@test isfile("profileview2.png")

rm("profileview.png")
rm("profileview2.png")
