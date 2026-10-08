using Random
Random.seed!(1)
println(VERSION, "  ", Sys.MACHINE, "  threads=", Threads.nthreads())

n = 110_000 # number of Regex objects created per round
suffixes = ["RBF", "LIN", "DAL", "???F", "RBIK", "LINK", "AUS"]
ids = [string(2026, "/", lpad(rand(1:99_999_999), 8, '0'), "-", rand(suffixes)) for _ in 1:n]
expected = [filter(c -> !(isdigit(c) || c == '/' || c == '-'), s) for s in ids] # same result without a regex

for round in 1:30
    letters = Vector{String}(undef, n)
    for i in 1:n
        letters[i] = replace(ids[i], Regex("[\\d/-]") => "") # a new Regex in every iteration
    end
    letters == expected || error("round $round: wrong regex result (silent corruption)")

    # allocation churn similar to the real workload (deepcopy of a table-like structure, GC runs finalizers)
    cols = Any[copy(ids), rand(n), collect(1:n), [rand() < 0.1 ? missing : s for s in ids]]
    for _ in 1:10
        c2 = deepcopy(cols)
        c2[1] == ids || error("round $round: deepcopy result differs (silent corruption)")
    end
    GC.gc()
    println("round $round ok"); flush(stdout)
end
println("finished without error")