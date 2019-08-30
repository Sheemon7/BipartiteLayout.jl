using BipartiteLayout
using LightGraphs, GraphPlot
using JuMP
using GLPK
using Distributions
using Cairo, Compose, Fontconfig

function generate_bipartite_graph(; na=5, nb=5, p=0.1)
    d = Geometric(p)
    g = SimpleGraph()
    for _ in 1:(na+nb)
        add_vertex!(g)
    end
    ns = min.(nb, rand(d, na))
    for (a,n) in enumerate(ns)
        for b in sample(1:nb, n)
            add_edge!(g, a, na+b)
        end
    end
    g
end

g = generate_bipartite_graph()
opt = with_optimizer(GLPK.Optimizer)
vis = BipartiteLayout.bipartite_layout(g, opt)
println(vis)
draw(SVG("res/g.svg", 16cm, max(na, nb)*1cm), vis)
vis = BipartiteLayout.bipartite_layout_random(g)
draw(SVG("res/g_rand.svg", 16cm, max(na, nb)*1cm), vis)
