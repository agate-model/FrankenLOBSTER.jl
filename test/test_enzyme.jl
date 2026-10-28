using Agate
using Enzyme
using ForwardDiff
using FrankenLOBSTER
using Test
using Oceananigans.Biogeochemistry:
    required_biogeochemical_tracers, required_biogeochemical_auxiliary_fields

@testset "Enzyme FrankenLOBSTER Agate-core gradients" begin
    bgc = FrankenLOBSTER.construct(; scalar_type=Float64).runtime
    active = Agate.Runtime.active_parameters(
        bgc; maximum_growth_rate=(:P_1,), nitrate_ammonia_inhibition=true
    )
    state = (
        NO₃=2.0, NH₄=0.2, DOM=0.1,
        solid_waste=0.0, inorganic_waste=0.0, dissolved_waste=0.0,
        P_1=0.02, P_2=0.01, Z_1=0.005, Z_2=0.005, H_1=0.01,
    )
    drivers = (; PAR=100.0, T=20.0)
    args = (
        0.0, 0.0, 0.0, 0.0,
        (getproperty(state, name) for name in required_biogeochemical_tracers(bgc))...,
        (getproperty(drivers, name) for name in required_biogeochemical_auxiliary_fields(bgc))...,
    )
    diagnostic(p) = Agate.Runtime.parameterized(
        bgc, p; active_parameters=active
    )(Val(:P_1), args...)

    p0 = copy(active.values)
    gradient = zeros(length(p0))
    Enzyme.autodiff(
        Enzyme.set_runtime_activity(Enzyme.Reverse), Enzyme.Const(diagnostic),
        Enzyme.Active, Enzyme.Duplicated(p0, gradient),
    )
    @test all(isfinite, gradient)
    @test gradient[1] > 0 && gradient[2] < 0
    @test isapprox(gradient, ForwardDiff.gradient(diagnostic, p0); rtol=1e-5, atol=1e-10)
end
