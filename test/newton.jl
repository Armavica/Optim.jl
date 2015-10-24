using Optim

function f(x::Vector)
    (x[1] - 5.0)^4
end

function g!(x::Vector, storage::Vector)
    storage[1] = 4.0 * (x[1] - 5.0)^3
end

function h!(x::Vector, storage::Matrix)
    storage[1, 1] = 12.0 * (x[1] - 5.0)^2
end

d = TwiceDifferentiableFunction(f, g!, h!)

results = Optim.optimize(d, [0.0], method=Newton())
@assert length(results.trace.states) == 0
@assert results.gr_converged
@assert norm(results.minimum - [5.0]) < 0.01

eta = 0.9

function f(x::Vector)
  (1.0 / 2.0) * (x[1]^2 + eta * x[2]^2)
end

function g!(x::Vector, storage::Vector)
  storage[1] = x[1]
  storage[2] = eta * x[2]
end

function h!(x::Vector, storage::Matrix)
  storage[1, 1] = 1.0
  storage[1, 2] = 0.0
  storage[2, 1] = 0.0
  storage[2, 2] = eta
end

d = TwiceDifferentiableFunction(f, g!, h!)
results = Optim.optimize(d, [127.0, 921.0], method=Newton())
@assert length(results.trace.states) == 0
@assert results.gr_converged
@assert norm(results.minimum - [0.0, 0.0]) < 0.01

# Test Optim.newton for all twice differentiable functions in Optim.UnconstrainedProblems.examples
for (name, prob) in Optim.UnconstrainedProblems.examples
	if prob.istwicedifferentiable
		ddf = TwiceDifferentiableFunction(prob.f, prob.g!,prob.h!)
		res = Optim.optimize(ddf, prob.initial_x, method=Newton())
		@assert norm(res.minimum - prob.solutions) < 1e-2
	end
end
