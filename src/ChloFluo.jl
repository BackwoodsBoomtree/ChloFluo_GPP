module ChloFluo

using NCDatasets
using Statistics
using GriddingMachine
using Dates

# export public functions
export save_nc, sif_qc, calc_yield, calc_apar, calc_luemax

# include("GPP/calc_gpp.jl")

include("APARchl/calc_apar.jl"    )
include("APARchl/calc_SIFyield.jl")
include("APARchl/sif_qc.jl"       )

include("LUE/calc_LUE.jl")

include("save/save_nc.jl")

# include("stress/calc_LSWImax.jl")
# include("stress/calc_stress.jl")
# include("stress/calc_temp_daily.jl")
# include("stress/calc_Tscalar.jl")
# include("stress/calc_Wscalar.jl")
# include("stress/topt_min_max.jl")

end