### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 8950a060-8e81-11eb-3eb4-1b229695b237
let
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
regions = groupby(select(select(countries, Not(:Country)), Not(:Subregion)), :Region)

# ╔═╡ 23bfd700-8e8d-11eb-2526-39f52a86908c
regions_cum = combine(regions, :Pop2018 => sum, :Pop2019 => sum, :PopChangeAbs => sum, :GDP => sum, renamecols = false)

# ╔═╡ 9e6a3986-889c-4947-ba96-84bd46f55982
begin
	round2 = x -> round(x; digits = 2) 
	transform(regions_cum, 
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
	Scale.x_log10(format = :plain, labels = x -> string(10^x)),  # x = log of the orig. x-value
	Theme(background_color = "ghostwhite")
)

# ╔═╡ 29346633-bb5d-4e8e-8dda-4ca7dda21140
md"""
# Histograms
"""

# ╔═╡ ac0e6452-b4f0-4d83-96c6-f45322e20ec7
md"""
Bar plots and historgrams have the same geometry (in the sense of the "grammar of graphics"). Nonetheless they are used for different purposes:
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
CSV = "~0.8.5"
DataFrames = "~1.2.1"
Gadfly = "~1.3.3"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "JSON", "Missings", "Printf", "RecipesBase", "Statistics", "StructTypes", "Unicode"]
git-tree-sha1 = "1562002780515d2573a4fb0c3715e4e57481075e"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f53ca8d41e4753c41cdafa6ec5f7ce914b34be54"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.13"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "c6461fc7c35a4bb8d00905df7adafcff1fe3a6bc"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoupledFields]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6c9671364c68c1158ac2524ac881536195b7e7bc"
uuid = "7ad07ef1-bdf2-5661-9d2b-286fd4296dac"
version = "0.2.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "a19645616f37a2c2c3077a44bc0d3e73e13441d7"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.1"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "abe4ad222b26af3337262b8afb28fab8d215e9f8"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a837fdf80f333415b69684ba8e8ae6ba76de6aaa"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.24.18"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "693210145367e7685d8604aee33d9bfb85db8b31"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.11.9"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Gadfly]]
deps = ["Base64", "CategoricalArrays", "Colors", "Compose", "Contour", "CoupledFields", "DataAPI", "DataStructures", "Dates", "Distributions", "DocStringExtensions", "Hexagons", "IndirectArrays", "IterTools", "JSON", "Juno", "KernelDensity", "LinearAlgebra", "Loess", "Measures", "Printf", "REPL", "Random", "Requires", "Showoff", "Statistics"]
git-tree-sha1 = "96da4818e4d481a29aa7d66aac1eb778432fb89a"
uuid = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
version = "1.3.3"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[Hexagons]]
deps = ["Test"]
git-tree-sha1 = "de4a6f9e7c4710ced6838ca906f81905f7385fd6"
uuid = "a1b4810d-1bce-5fbd-ac56-80944d57a21f"
version = "0.2.0"

[[IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "1470c80592cf1f0a35566ee5e93c5f8221ebc33a"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.3"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "b5254a86cf65944c68ed938e575f5c81d5dfe4cb"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.3"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "6a8a2a625ab0dea913aba95c11370589e0239ff0"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.6"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "4f825c6da64aebaa22cc058ecfceed1ab9af1c7e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.3"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
git-tree-sha1 = "37d210f612d70f3f7d57d488cb3b6eff56ad4e41"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.0"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "35927c2c11da0a86bcd482464b93dadd09ce420f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.5"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "508822dca004bf62e210609148511ad03ce8f1d8"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "5b2f81eeb66bcfe379947c500aae773c85c31033"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.8"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2f6792d523d7448bbe2fec99eca9218f06cc746d"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.8"

[[StatsFuns]]
deps = ["LogExpFunctions", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "30cd8c360c54081f806b1ee14d2eecbef3c04c49"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.8"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "e36adc471280e8b346ea24c5c87ba0571204be7a"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.7.2"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "8ed4a3ea724dac32670b062be3ef1c1de6773ae8"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.4.4"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─c9b89216-8e2c-4b5d-9922-a7d5913db9a4
# ╟─8950a060-8e81-11eb-3eb4-1b229695b237
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
