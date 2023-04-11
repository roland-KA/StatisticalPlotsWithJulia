### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 8950a060-8e81-11eb-3eb4-1b229695b237
begin
	using Gadfly
	using DataFrames
	using PlutoUI
	using CSV
	using Downloads
end

# ╔═╡ c9b89216-8e2c-4b5d-9922-a7d5913db9a4
html"""
<div style="
position: absolute;
width: calc(100% - 30px);
border: 50vw solid SteelBlue;
border-top: 500px solid SteelBlue;
border-bottom: none;
box-sizing: content-box;
left: calc(-50vw + 15px);
top: -500px;
height: 300px;
pointer-events: none;
"></div>

<div style="
height: 300px;
width: 100%;
background: SteelBlue;
color: #88BBD6;
padding-top: 68px;
padding-left: 5px;
">

<span style="
font-family: Vollkorn, serif;
font-weight: 700;
font-feature-settings: 'lnum', 'pnum';
"> 

<p style="
font-family: Alegreya sans;
font-size: 1.4rem;
font-weight: 300;
opacity: 1.0;
color: #CDCDCD;
">Data Visualization</p>
<p style="text-align: left; font-size: 2.8rem;">
Basic diagrams with Gadfly
</p>

<p style="
font-family: 'Alegreya Sans'; 
font-size: 0.7rem; 
font-weight: 300;
color: #CDCDCD;">
<br><br><br><br>
&copy  Dr. Roland Schätzle
</p>
"""

# ╔═╡ 05b12772-8e86-11eb-367d-2918810d07ee
PlutoUI.TableOfContents(title = "Basic diagrams with Gadfly")

# ╔═╡ 6781bb71-7991-4cf5-935d-a829d85c8073
md"""
**Acknowledgement**: The examples in this notebook are based on the YouTube tutorial [Julia Analysis for Beginners](https://youtu.be/s7ZRVCvdKAo) from the channel *"Julia for talented amateurs"* (which offers a lot of useful and entertaining tutorials on Julia and several other languages as well as some Web technologies). 
"""

# ╔═╡ c48bc160-8e85-11eb-29d9-abf89b2b4415
md"""
# Data: Countries, Population and GDP
"""

# ╔═╡ 559796f0-8e83-11eb-3cf0-bb4d71b71dd0
md"""
First we load the data we will use in the diagrams. There is a CSV file (`countries.csv`) with data about population and GDP for all countries around the world. The numbers about population are given in million people. The GDP numbers (which contain "missing" values) are millions USD.
"""

# ╔═╡ bc550d90-8e84-11eb-09d8-b13d0dd4d569
begin
	Downloads.download("https://raw.githubusercontent.com/roland-KA/StatisticalPlotsWithJulia/main/data/countries.csv", "countries.csv")
	countries = CSV.read("countries.csv", DataFrame)
	dropmissing!(countries)
	countries.GDPperCapita = countries.GDP ./ countries.Pop2019
end

# ╔═╡ cf79f490-8fb9-11eb-316f-59bffc4a3e2e
countries

# ╔═╡ d3bf9030-8e8a-11eb-2bd7-43a1b9e0d096
md"""
## Group and aggregate regions
"""

# ╔═╡ f5edb740-8e8a-11eb-3ccb-cfffc7f946be
regions = groupby(select(countries, Not([:Country, :Subregion])), :Region)

# ╔═╡ 23bfd700-8e8d-11eb-2526-39f52a86908c
regions_cum = combine(regions, :Pop2018 => sum, :Pop2019 => sum, :PopChangeAbs => sum, :GDP => sum, renamecols = false)

# ╔═╡ 9e6a3986-889c-4947-ba96-84bd46f55982
begin
	round2 = x -> round(x; digits = 2) 
	transform!(regions_cum, 
		:Pop2018 => ByRow(round2) => :Pop2018,
		:Pop2019 => ByRow(round2) => :Pop2019,
		:PopChangeAbs => ByRow(round2) => :PopChangeAbs)
end

# ╔═╡ de492a20-8e8a-11eb-2d58-31ed5bae6dad
md"""
## Group and aggregate subregions
"""

# ╔═╡ a0c72660-8e86-11eb-03cb-11cfb56456a2
subregions = groupby(select(countries, Not(:Country)), :Subregion)

# ╔═╡ 76a23350-8e88-11eb-3731-e7bfb26a28e6
subregions_cum = combine(subregions, :Region => first, :Pop2018 => sum, :Pop2019 => sum, :PopChangeAbs => sum, :GDP => sum, renamecols = false)

# ╔═╡ e132919e-8e8e-11eb-14c4-099bd51a67f3
md"""
# Bar Plots
"""

# ╔═╡ 2135a580-8e94-11eb-28da-515f320b6f8b
md"""
## Population by Region
"""

# ╔═╡ 4d4bc190-8e8f-11eb-2e35-ed5e2fcdd4d2
md"""
A bar plot to compare the population of the different regions in 2019.

First, a simple version using default values for several aspects of the diagram.
"""

# ╔═╡ cded2bd0-8e81-11eb-3369-6d58e490e8e3
set_default_plot_size(18cm, 10cm)

# ╔═╡ ec296c52-8e8e-11eb-09f2-7da8aad8883c
barplot1 = plot(regions_cum, 
	x = :Region, y = :Pop2019, color = :Region, 
	Geom.bar)

# ╔═╡ c5f6de90-8e8f-11eb-3956-2fc2c986a88b
md"""
The second version uses serveral formatting options. It has different labels (x-axis, y-axis, title) as well as a more readable number format on the y-axis.
"""

# ╔═╡ ff5cc730-8e8f-11eb-3d46-3d11d24ac9e9
barplot2 = plot(regions_cum, 
	x = :Region, y = :Pop2019, color = :Region, 
	Geom.bar,
	Guide.xlabel("Region"),
	Guide.ylabel("Population [millions]"),
	Guide.title("Population by Region, 2019"),
	Scale.y_continuous(format = :plain),
	Theme(background_color = "ghostwhite", bar_spacing = 1mm)	
)

# ╔═╡ 32998d00-8e94-11eb-3114-375e43db5210
md"""
## Population by Subregion
"""

# ╔═╡ 0fcd6320-8e92-11eb-3748-ef5b04bf55e6
md"""
Next we have a look at the population of the subregions.
"""

# ╔═╡ 1e9e43b0-8e92-11eb-3607-7db0b9d63e1e
barplot3 = plot(subregions_cum, 
	x = :Subregion, y = :Pop2019, color = :Region, 
	Geom.bar)

# ╔═╡ a3d9c720-8e92-11eb-388d-cf787ea1d206
md"""
As there are quite a few subregions, a horizontal bar diagram might be more readable. Apart from that we adapt the labels.
"""

# ╔═╡ d34eac50-8e92-11eb-38ce-8984b5958f39
barplot4 = plot(subregions_cum, 
	x = :Pop2019, y = :Subregion, color = :Region, 
	Geom.bar(orientation = :horizontal),
	Guide.title("Population by Subregion, 2019"),
	Guide.ylabel("Subregion"),
	Guide.xlabel("Population [millions]"),
	Scale.x_continuous(format = :plain),
	Theme(background_color = "ghostwhite", bar_spacing = 1mm)
)

# ╔═╡ 9b53cff0-8e93-11eb-197d-7fcdf985adf7
md"""
It get's even more readable, if we sort the subregions by population size before rendering the diagram.
"""

# ╔═╡ b4ba5860-8e93-11eb-3a81-0bb1bd36aca2
subregions_cum_sorted = sort(subregions_cum, :Pop2019)

# ╔═╡ ecbb59d0-8e93-11eb-18b0-4dfbce7307ba
barplot5 = plot(subregions_cum_sorted, 
	x = :Pop2019, y = :Subregion, color = :Region, 
	Geom.bar(orientation = :horizontal),
	Guide.title("Population by Subregion, 2019"),
	Guide.ylabel("Subregion"),
	Guide.xlabel("Population [millions]"),
	Scale.x_continuous(format = :plain),
	Theme(background_color = "ghostwhite", bar_spacing = 1mm)	
)

# ╔═╡ 90854850-8e94-11eb-2975-95bb352479f7
md"""
# Scatter Plots
"""

# ╔═╡ 99ead4a0-8e94-11eb-05f1-b72dfdaa3cd1
md"""
In the next step we have a look at the population at country level in relation to the growth rate. For this purpose a scatter plot is good way to show this relation. 
"""

# ╔═╡ c084ba40-8e94-11eb-18c8-05d2f0239508
scatterplot1 = plot(countries,
	x = :Pop2019, y = :PopChangePct, color = :Region,
	Geom.point)

# ╔═╡ 8db9fde0-8e95-11eb-2bc8-914c09a89ca8
md"""
The distribution of the data is quite skewed. So a logarithmic scale on the x-axis might give a better insight of the data. And again, we add some labels.
"""

# ╔═╡ c58a7970-8e95-11eb-23e7-bdda8c608b66
scatterplot2 = plot(countries,
	x = :Pop2019, y = :PopChangePct, color = :Region,
	Geom.point,
	Guide.title("Population vs Growth Rate, 2019"),
	Guide.ylabel("Growth Rate [%]"),
	Guide.xlabel("Population [millions]"),
	Scale.x_log10(format = :plain, labels = x -> string(round(10^x, digits = 2))),  # x = log of the orig. x-value
	Theme(background_color = "ghostwhite")
)

# ╔═╡ 29346633-bb5d-4e8e-8dda-4ca7dda21140
md"""
# Histograms
"""

# ╔═╡ ac0e6452-b4f0-4d83-96c6-f45322e20ec7
md"""
Bar plots and histograms have the same geometry (in the sense of the "grammar of graphics"). Nonetheless they are used for different purposes:
- A bar plot uses *nominal data* on the x-axis and *quantitative data* on the y-axis. The height of the bars is proportional to the number of occurences within each class of the x-axis.
- A histogram uses *quantitative data* on the x-axis which is split into class intervals, in order to show the distibution of the data.
  - The *area* of each bar represents the *percentage* of occurences in the respective class.
  - The area of all bars sums up to 1 (= 100%).
  - The *height* of a bar represents *percentage per horizontal unit* (or crowding).

... but there are some variations to this definition (for details see e.g. [Wikipedia - Histogram](https://en.wikipedia.org/wiki/Histogram)).
"""

# ╔═╡ d9267b96-876e-499d-a941-aa9276129c89
md"""
## Distribution of GDP per Capita
"""

# ╔═╡ 12be259c-5383-43b5-9b50-eb4dcd83002f
hist1 = plot(countries,
	x = :GDPperCapita, Geom.histogram)

# ╔═╡ e54c01a2-fcfe-48ba-89c8-471dfc6a42ed
md"""
With fewer bins, we get more of a classification. And again we add labels etc.
"""

# ╔═╡ 10a8a44c-9244-4641-8ea3-d5511d69f7c3
hist2 = plot(countries,
	x = :GDPperCapita, 
	Geom.histogram(bincount = 20),
	Guide.title("Distribution of GDP per Capita, 2019"),
	Guide.xlabel("GDP per Capita [USD]"),
	Guide.ylabel("Number of countries"),
	Scale.x_continuous(format = :plain),
	Theme(background_color = "ghostwhite")
)

# ╔═╡ 8af7f600-8fb9-11eb-32e4-199e69d6cfde
md"""
# Box Plots and Violin Plots
"""

# ╔═╡ e46f4ac0-8fba-11eb-0f2d-87a72e1fca7b
md"""
In the next step we have a look at the distribution of GDP per Capita among the different regions.
"""

# ╔═╡ 0d5fae10-8fbc-11eb-32dc-8bb821422b95
md"""
## Box Plot: GDP per Capita by Region
"""

# ╔═╡ f45ddae0-8fbb-11eb-2db7-471f23f3c6cc
boxplot = plot(countries,
	x = :Region, y = :GDPperCapita, color = :Region,
	Geom.boxplot,
	Guide.title("GDP per Capita by Region, 2019"),
	Guide.xlabel("Region"),
	Guide.ylabel("GDP per Capita [USD]"),
	Scale.y_continuous(format = :plain),
	# Coord.cartesian(ymin = 0, ymax = 100000),
	Theme(background_color = "ghostwhite")
)

# ╔═╡ 18f33df2-8fbc-11eb-2ae4-f96bdcc6bba2
md"""
## Violin Plot: GDP per Capita by Region
"""

# ╔═╡ f88978a0-8fba-11eb-0f5a-ddfcaed5ca98
violin = plot(countries,
	x = :Region, y = :GDPperCapita, color = :Region,
	Geom.violin,
	Guide.title("GDP per Capita by Region, 2019"),
	Guide.xlabel("Region"),
	Guide.ylabel("GDP per Capita [USD]"),
	Scale.y_continuous(format = :plain),
	Coord.cartesian(ymin = 0, ymax = 100000),
	Theme(background_color = "ghostwhite")
)

# ╔═╡ d27484da-1487-45fe-a1d2-816656476e25
md"""
*Note*: The GDP values on the y-axis in this diagram are restricted to values <= 100.000. To get the same result in the box plot above, the line starting with `Coord` has to be uncommented.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.3"
DataFrames = "~1.3.2"
Gadfly = "~1.3.4"
PlutoUI = "~0.7.37"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "f89c32a129bef56529e2358f30a36f348ee15098"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5f5a975d996026a8dd877c35fe26a7b8179c02ba"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.6"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "80ca332f6dcb2508adba68f22f551adb2d00a624"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.3"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "78bee250c6826e1cf805a88b7f1e86025275d208"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.46.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "d853e57661ba3a57abcdaa201f4c9917a93487a2"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.4"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.CoupledFields]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6c9671364c68c1158ac2524ac881536195b7e7bc"
uuid = "7ad07ef1-bdf2-5661-9d2b-286fd4296dac"
version = "0.2.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "daa21eb85147f72e41f6352a57fccea377e310a9"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "6180800cebb409d7eeef8b2a9a562107b9705be5"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.67"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Gadfly]]
deps = ["Base64", "CategoricalArrays", "Colors", "Compose", "Contour", "CoupledFields", "DataAPI", "DataStructures", "Dates", "Distributions", "DocStringExtensions", "Hexagons", "IndirectArrays", "IterTools", "JSON", "Juno", "KernelDensity", "LinearAlgebra", "Loess", "Measures", "Printf", "REPL", "Random", "Requires", "Showoff", "Statistics"]
git-tree-sha1 = "13b402ae74c0558a83c02daa2f3314ddb2d515d3"
uuid = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
version = "1.3.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.Hexagons]]
deps = ["Test"]
git-tree-sha1 = "de4a6f9e7c4710ced6838ca906f81905f7385fd6"
uuid = "a1b4810d-1bce-5fbd-ac56-80944d57a21f"
version = "0.2.0"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "d19f9edd8c34760dca2de2b503f969d8700ed288"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.4"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "64f138f9453a018c8f3562e7bae54edc059af249"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.4"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "e595b205efd49508358f7dc670a940c790204629"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.0.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0044b23da09b5608b4ecacb4e5e6c6332f833a7e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "db8481cf5d6278a121184809e9eb1628943c7704"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.13"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "85bc4b051546db130aeb1e8a696f1da6d4497200"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.5"

[[deps.StaticArraysCore]]
git-tree-sha1 = "5b413a57dd3cea38497d745ce088ac8592fbb5be"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.1.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "ed5d390c7addb70e90fd1eb783dcb9897922cbfa"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.8"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─c9b89216-8e2c-4b5d-9922-a7d5913db9a4
# ╠═8950a060-8e81-11eb-3eb4-1b229695b237
# ╟─05b12772-8e86-11eb-367d-2918810d07ee
# ╟─6781bb71-7991-4cf5-935d-a829d85c8073
# ╟─c48bc160-8e85-11eb-29d9-abf89b2b4415
# ╟─559796f0-8e83-11eb-3cf0-bb4d71b71dd0
# ╠═bc550d90-8e84-11eb-09d8-b13d0dd4d569
# ╠═cf79f490-8fb9-11eb-316f-59bffc4a3e2e
# ╟─d3bf9030-8e8a-11eb-2bd7-43a1b9e0d096
# ╠═f5edb740-8e8a-11eb-3ccb-cfffc7f946be
# ╠═23bfd700-8e8d-11eb-2526-39f52a86908c
# ╠═9e6a3986-889c-4947-ba96-84bd46f55982
# ╟─de492a20-8e8a-11eb-2d58-31ed5bae6dad
# ╠═a0c72660-8e86-11eb-03cb-11cfb56456a2
# ╠═76a23350-8e88-11eb-3731-e7bfb26a28e6
# ╟─e132919e-8e8e-11eb-14c4-099bd51a67f3
# ╟─2135a580-8e94-11eb-28da-515f320b6f8b
# ╟─4d4bc190-8e8f-11eb-2e35-ed5e2fcdd4d2
# ╠═cded2bd0-8e81-11eb-3369-6d58e490e8e3
# ╠═ec296c52-8e8e-11eb-09f2-7da8aad8883c
# ╟─c5f6de90-8e8f-11eb-3956-2fc2c986a88b
# ╠═ff5cc730-8e8f-11eb-3d46-3d11d24ac9e9
# ╟─32998d00-8e94-11eb-3114-375e43db5210
# ╟─0fcd6320-8e92-11eb-3748-ef5b04bf55e6
# ╠═1e9e43b0-8e92-11eb-3607-7db0b9d63e1e
# ╟─a3d9c720-8e92-11eb-388d-cf787ea1d206
# ╠═d34eac50-8e92-11eb-38ce-8984b5958f39
# ╟─9b53cff0-8e93-11eb-197d-7fcdf985adf7
# ╠═b4ba5860-8e93-11eb-3a81-0bb1bd36aca2
# ╠═ecbb59d0-8e93-11eb-18b0-4dfbce7307ba
# ╟─90854850-8e94-11eb-2975-95bb352479f7
# ╟─99ead4a0-8e94-11eb-05f1-b72dfdaa3cd1
# ╠═c084ba40-8e94-11eb-18c8-05d2f0239508
# ╟─8db9fde0-8e95-11eb-2bc8-914c09a89ca8
# ╠═c58a7970-8e95-11eb-23e7-bdda8c608b66
# ╟─29346633-bb5d-4e8e-8dda-4ca7dda21140
# ╟─ac0e6452-b4f0-4d83-96c6-f45322e20ec7
# ╟─d9267b96-876e-499d-a941-aa9276129c89
# ╠═12be259c-5383-43b5-9b50-eb4dcd83002f
# ╟─e54c01a2-fcfe-48ba-89c8-471dfc6a42ed
# ╠═10a8a44c-9244-4641-8ea3-d5511d69f7c3
# ╟─8af7f600-8fb9-11eb-32e4-199e69d6cfde
# ╟─e46f4ac0-8fba-11eb-0f2d-87a72e1fca7b
# ╟─0d5fae10-8fbc-11eb-32dc-8bb821422b95
# ╠═f45ddae0-8fbb-11eb-2db7-471f23f3c6cc
# ╟─18f33df2-8fbc-11eb-2ae4-f96bdcc6bba2
# ╠═f88978a0-8fba-11eb-0f5a-ddfcaed5ca98
# ╟─d27484da-1487-45fe-a1d2-816656476e25
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
