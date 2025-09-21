module ProfileViewMakie

using Makie, FlameGraphs, Profile

"""
    profileview(flamegraph; flamecolor = FlameColors())

Creates an interactive flame graph visualization for Julia profiling data using Makie.jl.

## Arguments
- `flamegraph`: A flame graph object from FlameGraphs.jl containing profiling data

## Usage Examples

### Using the `@profileview` macro
```julia
using ProfileViewMakie

# Profile and visualize in one step
data = ProfileViewMakie.@profileview rand(5000, 5000)
```

### Manual profiling and visualization
```julia
using ProfileViewMakie
using Profile

# Clear previous profiling data
Profile.clear()

# Profile your code
Profile.@profile rand(3000, 3000)

# Generate flame graph and visualize
g = ProfileViewMakie.flamegraph()
profileview(g)
```

## Features
- Interactive inspection with DataInspector showing file names, line numbers, and function names
- Customizable coloring using FlameGraphs.jl color schemes
- Hover tooltips displaying detailed stack frame information
"""
@recipe ProfileView (flamegraph,) begin
    flamecolor = FlameColors()
end

# From ProfileView
function long_info_str(sf)
    if sf.file == :none && sf.line == 0
        # some flamegraph producers don't provide file/line info as they are not applicable
        # The above values together are identifiers for such cases
        string(sf.func) # might not actually be a func, just a name
    elseif sf.linfo isa Core.MethodInstance
        string(sf.file, ':', sf.line, ", ", sf.linfo)
    else
        string(sf.file, ':', sf.line, ", ", sf.func, " [inlined]")
    end
end

function short_info_str(sf)
    if sf.file == :none && sf.line == 0
        # some flamegraph producers don't provide file/line info as they are not applicable
        # The above values together are identifiers for such cases
        string(sf.func) # might not actually be a func, just a name
    else
        string(basename(string(sf.file)), ":", sf.line, " ", sf.func)
    end
end

function Makie.plot!(recipe::ProfileView)
    flamegraph = recipe.flamegraph[]
    pixels = flamepixels(recipe.flamecolor[], flamegraph)
    tagimg = flametags(flamegraph, pixels)
    function inspector_label(self, i, pos)
        sf = tagimg[i...]
        return string(tagimg[i...])
    end
    image!(recipe, pixels; interpolate=false, inspector_label=inspector_label)
    scene = Makie.parent_scene(recipe)
    DataInspector(scene; fontsize=10)
    return
end

macro profileview(expr)
    return quote
        Profile.clear()
        Profile.@profile $expr
        g = flamegraph()
        profileview(g)
    end
end

end
