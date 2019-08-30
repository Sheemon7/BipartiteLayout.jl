module BipartiteLayout

using JuMP
using LightGraphs
using GraphPlot, Colors
using Random

function solve_bipartite_layout(g, opt, bm, a, b, na, nb)
    ia, ib = Dict(v => i for (i,v) in enumerate(a)), Dict(v => i for (i,v) in enumerate(b))
    m = Model()

    @variable(m, A[1:na,1:na], Bin)
    @variable(m, B[1:nb,1:nb], Bin)
    @variable(m, Z[1:ne(g)])

    for i in 1:na @constraint(m, sum(A[i, :]) == 1) end
    for j in 1:na @constraint(m, sum(A[:, j]) == 1) end
    for i in 1:nb @constraint(m, sum(B[i, :]) == 1) end
    for j in 1:nb @constraint(m, sum(B[:, j]) == 1) end
    for (i,e) in enumerate(edges(g))
        u = bm[src(e)] == 1 ? ia[src(e)] : ib[src(e)]
        v = bm[dst(e)] == 1 ? ia[dst(e)] : ib[dst(e)]
        uX = bm[src(e)] == 1 ? A : B
        vX = bm[dst(e)] == 1 ? A : B
        un = bm[src(e)] == 1 ? na : nb
        vn = bm[dst(e)] == 1 ? na : nb
        @constraint(m, -Z[i] <= sum(uX[u, :] .* collect(1:un)) - sum(vX[v, :] .* collect(1:vn)))
        @constraint(m, sum(uX[u, :] .* collect(1:un)) - sum(vX[v, :] .* collect(1:vn)) <= Z[i])
    end
    @objective(m, Min, sum(Z))

    # print(m)
    optimize!(m, opt)
    println("Objective value: ", objective_value(m))

    locs_y = [bm[v] == 1 ? -1.0 : 1.0 for v in 1:nv(g)]
    r = range(-1, 1, length=max(na, nb))
    locs_x = zeros(nv(g))
    for (i,v) in enumerate(a)
        s = round(Int, sum(value.(A[i, :]) .* collect(1:na)))
        locs_x[v] = r[s] 
    end
    for (i,v) in enumerate(b)
        s = round(Int, sum(value.(B[i, :]) .* collect(1:nb)))
        locs_x[v] = r[s] 
    end
    locs_x, locs_y
end

function bipartite_layout(g, opt)
    bm = bipartite_map(g)
    a, b = findall(bm .== 1), findall(bm .== 2)
    na, nb = length(a), length(b)
    locs_x, locs_y = solve_bipartite_layout(g, opt, bm, a, b, na, nb)
    nodelabel = 1:nv(g)
    cs = [colorant"lightseagreen", colorant"orange"]
    nodefillc = cs[[bm[v] for v in 1:nv(g)]]
    gplot(g, locs_x, locs_y, nodelabel=nodelabel, nodefillc=nodefillc)
end

function bipartite_layout_random(g)
    bm = bipartite_map(g)
    a, b = findall(bm .== 1), findall(bm .== 2)
    na, nb = length(a), length(b)
    locs_y = [bm[v] == 1 ? -1.0 : 1.0 for v in 1:nv(g)]
    r = range(-1, 1, length=max(na, nb))
    ra, rb = shuffle(r[1:na]), shuffle(r[1:nb])
    locs_x = zeros(nv(g))
    for (i,v) in enumerate(a)
        locs_x[v] = ra[i]
    end
    for (i,v) in enumerate(b)
        locs_x[v] = rb[i]
    end
    nodelabel = 1:nv(g)
    cs = [colorant"lightseagreen", colorant"orange"]
    nodefillc = cs[[bm[v] for v in 1:nv(g)]]
    gplot(g, locs_x, locs_y, nodelabel=nodelabel, nodefillc=nodefillc)
end

export bipartite_layout

end
