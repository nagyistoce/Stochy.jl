import Stochy: Empirical, recoversamples

# Empirical.
hist = [0=>2, 1=>3, 2=>5]
erp = Empirical(hist)
@test erp.n == 10
@test all([x in support(erp) for x in 0:2])
@test length(support(erp)) == 3
for x in 0:2
    @test_approx_eq log(hist[x]*.1) score(erp,x)
end

@test all([sample(erp) in 0:2 for _ in 1:5])

samples = recoversamples(erp)
@test length(samples) == 10
for (x,c) in hist
    @test sum(samples .== x) == c
end

# Categorical.
c = Categorical([0.4,0.6])
@test sample(c) in 1:2
@test score(c,1) == log(0.4)
@test score(c,2) == log(0.6)
@test support(c) == 1:2

c = Categorical([0.4,0.6], [:a,:b])
@test sample(c) in [:a,:b]
@test score(c,:a) == log(0.4)
@test score(c,:b) == log(0.6)
@test support(c) == [:a,:b]

# Dirichlet.
d = Dirichlet(1.,2)
s = sample(d)
@test length(s) == 2
@test_approx_eq sum(s) 1

# Normal.
n = Normal(0,1)
s = sample(n)
@test 0 < exp(score(n,s)) < 1

# Hellinger distance.
p = Categorical([0=>0.25,1=>0.25,2=>0.5])
q = Empirical([0=>2,2=>3])
@test_approx_eq_eps 0.36885 hellingerdistance(p,q) 1e-5
@test_throws ErrorException hellingerdistance(q,q)
q = Empirical([3=>1]) # Different support to p.
@test_throws ErrorException hellingerdistance(p,q)
