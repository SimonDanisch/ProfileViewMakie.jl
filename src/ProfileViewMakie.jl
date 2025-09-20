module ProfileViewMakie

using Makie, FlameGraphs

@recipe ProfileView (flamegraph,) begin

    """
    Sets coloring function for the flamegraph.
    See https://timholy.github.io/FlameGraphs.jl/stable/reference/#FlameGraphs.FlameColors for more details.
    """
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


function plot!(recipe::ProfileView)
    flamegraph = recipe.flamegraph[]
    pixels = flamepixels(recipe.flamecolor[], flamegraph)
    tagimg = flametags(flamegraph, pixels)
    function inspector_label(self, i, pos)
        sf = tagimg[i...]
        @show sf
        @show propertynames(sf)
        return string(tagimg[i...])
    end
    image!(pixels; interpolate=false, inspector_label=inspector_label)
    scene = Makie.parent_scene(recipe)
    DataInspector(scene; fontsize=10)
    return
end


end
