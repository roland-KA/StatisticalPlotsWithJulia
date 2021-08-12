### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 61c31884-4e1a-4f71-aa47-a0573d3e341a
begin
	using VegaLite
	using DataFrames
	using PlutoUI
	using CSV
	using Downloads
end

# ╔═╡ f4588c88-48d4-473e-b0d7-daa9ba1f0a00
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
Basic diagrams with VegaLite
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

# ╔═╡ d8a90b71-b2ce-4766-83a7-f134ebd91298
PlutoUI.TableOfContents(title = "VegaLite")

# ╔═╡ 8d71d310-4db1-4921-8c86-26221f2ceb5a
md"""
# Data: Countries, Population and GDP

Load and prepare basic data for use in the following diagrams. For more information see the Pluto notebook "Basic diagrams with Gadfly".
"""

# ╔═╡ 5932694a-acae-4a1c-a2bb-ba0ec538c467
begin
	Downloads.download("https://raw.githubusercontent.com/roland-KA/StatisticalPlotsWithJulia/main/data/countries.csv", "countries.csv")
	countries = CSV.read("countries.csv", DataFrame)
	dropmissing!(countries)
	countries.GDPperCapita = countries.GDP ./ countries.Pop2019
	
	# group and aggregate regions
	regions = groupby(select(
			select(countries, Not(:Country)), Not(:Subregion)), :Region)
	regions_cum = combine(regions, 
		:Pop2018 => sum, :Pop2019 => sum, :PopChangeAbs => sum, :GDP => sum,
		renamecols = false)
	
	# group and aggregate subregions
	subregions = groupby(select(countries, Not(:Country)), :Subregion)
	subregions_cum = combine(subregions, :Region => first, 
		:Pop2018 => sum, :Pop2019 => sum, :PopChangeAbs => sum, :GDP => sum,
		renamecols = false)
end

# ╔═╡ d1bbe6fa-1f02-4158-a91f-7f4b3d641256
regions_cum

# ╔═╡ f791a7b9-549c-4f2d-b493-8bd3da683f3b
md"""
# Bar Plots
"""

# ╔═╡ 157e4e4a-a7d6-4c98-8843-d837a2232f36
md"""
## Population by Region
"""

# ╔═╡ ed0b8989-8f4e-4890-909e-218761ba4ea2
md"""
A bar plot to compare the population of the different regions in 2019.

First, a simple version using default values for several aspects of the diagram.
"""

# ╔═╡ 17ea91b1-db35-43b1-8cf0-f91f070b3049
let
regions_cum |>
	@vlplot(
		width = 600, height = 300,
		:bar,
		x = :Region, y = :Pop2019, color = :Region
	)
end

# ╔═╡ 17ebb9cc-1080-41f6-a914-f73afbb8e957
md"""
The second version uses serveral formatting options. It has different labels (x-axis, y-axis, title) as well as a more readable number format on the y-axis.
"""

# ╔═╡ afe3969f-6ff9-4c12-88ce-62dc2c3b2b3e
let
regions_cum |>
	@vlplot(
		width = 600, height = 300,
		title = "Population by Region, 2019",
		:bar,
		x = {:Region, title = "Region", axis = {labelAngle = 0}},
		y = {:Pop2019, title = "Population [millions]"},
		color = :Region,
		config = {background = "ghostwhite"}
	)
end

# ╔═╡ 9f9924c4-a937-4dea-b045-ba8101c2971b
md"""
## Population by Subregion
"""

# ╔═╡ a2fa5c60-aaf1-4a12-bb17-d260c41b85a6
md"""
Next we have a look at the population of the subregions.
"""

# ╔═╡ 55b9aa0b-da52-4a8c-a7b8-4bf25da2ca2f
let
subregions_cum |>
	@vlplot(
		width = 600, height = 300,
		:bar,
		x = :Subregion,	y = :Pop2019, color = :Region
	)
end

# ╔═╡ ea4f0f45-7fb3-4faa-bdb9-5b4a1df04280
md"""
As there are quite a few subregions, a horizontal bar diagram might be more readable. Apart from that we adapt the labels.
"""

# ╔═╡ 94bfd9c5-2877-417e-a18c-4983f243fc85
let
subregions_cum |>
	@vlplot(
		title = "Population by Subregion, 2019",
		width = 600, height = 300,
		:bar,
		x = {:Pop2019, title = "Population [millions]"}, 
		y = {:Subregion, title = "Subregion"}, 
		color = :Region,
		config = {background = "ghostwhite"}
	)
end

# ╔═╡ 0d84e074-af24-4823-a355-57a3485edc36
md"""
It get's even more readable, if we sort the subregions by population size before rendering the diagram.
"""

# ╔═╡ 9f72a8e5-8777-40c0-a6af-75b1a2aa7115
let
subregions_cum |>
	@vlplot(
		title = "Population by Subregion, 2019",
		width = 600, height = 300,
		:bar,
		x = {:Pop2019, title = "Population [millions]"}, 
		y = {:Subregion, sort = "-x", title = "Subregion"}, 
		color = :Region,
		config = {background = "ghostwhite"}
	)
end

# ╔═╡ 371dad4d-963c-42c9-a785-c477e124bcb4
md"""
The sorting can be done within VegaLite. `sort = "-x"` means: sort by x-values in descending order.
"""

# ╔═╡ 305f5666-2880-43dd-ae0b-7778ca4be212
md"""
# Scatter Plots
"""

# ╔═╡ f7e54982-88f4-4210-9343-ed187f65fa33
md"""
In the next step we have a look at the population at country level in relation to the growth rate. For this purpose a scatter plot is good way to show this relation.
"""

# ╔═╡ b38a4a8a-b655-4756-b396-bd6b2f97579c
let
	countries |>
		@vlplot(
			width = 600, height = 300,
			:point,
			x = :Pop2019, y = :PopChangePct, color = :Region
		)
end

# ╔═╡ e0b07b43-4446-43f5-814a-0642ece326e7
md"""
The distribution of the data is quite skewed. So a logarithmic scale on the x-axis might give a better insight of the data. And again, we add some labels.
"""

# ╔═╡ 1dc24d9c-8d8d-479c-b9e1-79792ee2ab0c
let
	countries |>
		@vlplot(
			title = "Population vs. Growth Rate, 2019",
			width = 600, height = 300,
			:point,
			x = {:Pop2019, title = "Population [millions]", 
				scale = {type = :log, base = 10}}, 
			y = {:PopChangePct, title = "Growth Rate [%]"}, 
			color = :Region,
			config = {background = "ghostwhite"}
		)
end

# ╔═╡ ec791080-6c52-4c80-b7ca-43b604d4ede1
md"""
# Histograms
"""

# ╔═╡ 389e95fc-d410-481e-a753-f36ec70fa931
md"""
## Distribution of GDP per Capita
"""

# ╔═╡ f2753a4d-7bcd-4866-b59c-5568385e88c3
let
	countries |>
		@vlplot(
			width = 600, height = 300,
			:bar,
			x = {:GDPperCapita, bin = true}, y = "count()"
		)
end

# ╔═╡ 5782433d-5ab6-4a9c-a6fd-04610edb1dd8
md"""
The labels on the x-axis are set automatically to match class boundaries. And a reasonable bin size has been chosen by default.
"""

# ╔═╡ e46e377d-a637-4ba8-a9ba-789d6e6415f3
md"""
And again with labels (and the same number of bins as in the Gadfly example).
"""

# ╔═╡ 56892be5-2c1c-40a8-b0cd-d958d71a8845
let
	countries |>
		@vlplot(
			title = "Distribution of GDP per Capita, 2019",
			width = 600, height = 300,
			:bar,
			x = {:GDPperCapita, bin = {maxbins = 20}, 
				title = "GDP per Capita [USD]"}, 
			y = {"count()", title = "Number of countries"},
			config = {background = "ghostwhite"}
		)
end

# ╔═╡ a6ce4860-949b-4e84-b884-6090b40c3b96
md"""
# Box Plots and Violin Plots
"""

# ╔═╡ 11e4f95f-3849-4260-aed4-e0ac29cad61f
md"""
In the next step we have a look at the distribution of GDP per Capita among the different regions.
"""

# ╔═╡ 8e15d66c-0e8f-4842-bc6c-65f0c49934b7
md"""
## Box Plot: GDP per Capita by Region, 2019
"""

# ╔═╡ 8580f7b7-564d-4469-a022-4bdd3a1b4453
let
	countries |>
		@vlplot(
			title = "GDP per Capita by Region, 2019",
			width = 600, height = 300,
			:boxplot,
			transform = [{filter = "datum.GDPperCapita <= 100000"}],
			x = {:Region, title = "Region", axis = {labelAngle = 0}}, 
			y = {:GDPperCapita, title = "GDP per Capita [USD]"}, 
			color = :Region,
			config = {background = "ghostwhite"}
		)
end

# ╔═╡ f1777ba0-7414-4963-803e-d7335fecc3a9
md"""
In order to restrict the GDP values to values <= 100.000, VegaLite uses a different logic than Gadfly. In Gadfly this is done by restricting the coordinate system on the y-axis to values between 0 and 100.000 (via `Coord` and `ymax = 100000`), but a `scale = {domain = [0, 100000]}` on the y-axis doesn't produce the desired result here.

In VegaLite the range of *data* used (i.e. the `GDPperCapita` values themselfes) have to be restricted to that range. This is done using a `filter`-command within a `transform`.

"""

# ╔═╡ 64bdab07-2d6e-4517-b581-35370390fed9
md"""
## Violin Plot: GDP per Capita by Region, 2019
"""

# ╔═╡ da36a333-1639-4a4a-a05b-75e0d04784cc
let
	countries |>
		@vlplot(
			title = "GDP per Capita by Region, 2019",
			height = 300,
			mark = {:area, orient = "horizontal"},
		
			transform = [
				{filter = "datum.GDPperCapita <= 100000"},
				{density = "GDPperCapita", groupby = ["Region"]}
			],
		
			x = {"density:q", stack = "center", impute = nothing, title = nothing,
				axis = {labels = false}}, 
			y = {"value:q", title = "GDP per Capita [USD]", axis = {labelAngle = 0}}, 
		
			column = {"Region", 
				header = {titleOrient = "bottom", labelOrient = "bottom"}},
			color = :Region,
		
			config = {background = "ghostwhite"},
			width = 120, spacing = 0
		)
end

# ╔═╡ 72b9a687-30ef-47ea-81d7-ba563eaeb714
md"""
As VegaLite doesn't support violin plots as a `mark` on it's own, they have to be constructed using density plots and listed in a row using the `column` dimension (here: five density plots, one for each region).
"""

# ╔═╡ 7bb96854-2752-488f-b5fd-55dcfd3077ce
md"""
*Note*: The GDP values on the y-axis in this diagram are restricted to values <= 100.000. To get the same result in the box plot above, the line starting with `transform` has to be uncommented.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
VegaLite = "112f6efa-9a02-5b7d-90c0-432ed331239a"

[compat]
CSV = "~0.8.5"
DataFrames = "~1.2.2"
PlutoUI = "~0.7.9"
VegaLite = "~2.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

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
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "0f5e8d0cb91a6386ba47bd1527b240bd5725fbae"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.10"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "MbedTLS", "Sockets"]
git-tree-sha1 = "c7ec02c4c6a039a98a15f955462cd7aea5df4508"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.8.19"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSONSchema]]
deps = ["HTTP", "JSON", "ZipFile"]
git-tree-sha1 = "b84ab8139afde82c7c65ba2b792fe12e01dd7307"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "0.3.3"

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

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f8c673ccc215eb50fcadb285f522420e29e69e1c"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "0.4.5"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[NodeJS]]
deps = ["Pkg"]
git-tree-sha1 = "905224bbdd4b555c69bb964514cfa387616f0d3a"
uuid = "2bd173c7-0d6d-553b-b6af-13a54713934c"
version = "1.3.0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

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

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "a3a337914a035b2d59c9cbe7f1a38aaba1265b02"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.6"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "fca29e68c5062722b5b4435594c3d1ba557072a3"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.7.1"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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

[[TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "8fc12ae66deac83e44454e61b02c37b326493233"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Vega]]
deps = ["DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "JSONSchema", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "Setfield", "TableTraits", "TableTraitsUtils", "URIParser"]
git-tree-sha1 = "43f83d3119a868874d18da6bca0f4b5b6aae53f7"
uuid = "239c3e63-733f-47ad-beb7-a12fde22c578"
version = "2.3.0"

[[VegaLite]]
deps = ["Base64", "DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "TableTraits", "TableTraitsUtils", "URIParser", "Vega"]
git-tree-sha1 = "3e23f28af36da21bfb4acef08b144f92ad205660"
uuid = "112f6efa-9a02-5b7d-90c0-432ed331239a"
version = "2.6.0"

[[ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "c3a5637e27e914a7a445b8d0ad063d701931e9f7"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.3"

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
# ╟─f4588c88-48d4-473e-b0d7-daa9ba1f0a00
# ╟─61c31884-4e1a-4f71-aa47-a0573d3e341a
# ╟─d8a90b71-b2ce-4766-83a7-f134ebd91298
# ╟─8d71d310-4db1-4921-8c86-26221f2ceb5a
# ╠═5932694a-acae-4a1c-a2bb-ba0ec538c467
# ╠═d1bbe6fa-1f02-4158-a91f-7f4b3d641256
# ╟─f791a7b9-549c-4f2d-b493-8bd3da683f3b
# ╟─157e4e4a-a7d6-4c98-8843-d837a2232f36
# ╟─ed0b8989-8f4e-4890-909e-218761ba4ea2
# ╠═17ea91b1-db35-43b1-8cf0-f91f070b3049
# ╟─17ebb9cc-1080-41f6-a914-f73afbb8e957
# ╠═afe3969f-6ff9-4c12-88ce-62dc2c3b2b3e
# ╟─9f9924c4-a937-4dea-b045-ba8101c2971b
# ╟─a2fa5c60-aaf1-4a12-bb17-d260c41b85a6
# ╠═55b9aa0b-da52-4a8c-a7b8-4bf25da2ca2f
# ╟─ea4f0f45-7fb3-4faa-bdb9-5b4a1df04280
# ╠═94bfd9c5-2877-417e-a18c-4983f243fc85
# ╟─0d84e074-af24-4823-a355-57a3485edc36
# ╠═9f72a8e5-8777-40c0-a6af-75b1a2aa7115
# ╟─371dad4d-963c-42c9-a785-c477e124bcb4
# ╟─305f5666-2880-43dd-ae0b-7778ca4be212
# ╟─f7e54982-88f4-4210-9343-ed187f65fa33
# ╠═b38a4a8a-b655-4756-b396-bd6b2f97579c
# ╟─e0b07b43-4446-43f5-814a-0642ece326e7
# ╠═1dc24d9c-8d8d-479c-b9e1-79792ee2ab0c
# ╟─ec791080-6c52-4c80-b7ca-43b604d4ede1
# ╟─389e95fc-d410-481e-a753-f36ec70fa931
# ╠═f2753a4d-7bcd-4866-b59c-5568385e88c3
# ╟─5782433d-5ab6-4a9c-a6fd-04610edb1dd8
# ╟─e46e377d-a637-4ba8-a9ba-789d6e6415f3
# ╠═56892be5-2c1c-40a8-b0cd-d958d71a8845
# ╟─a6ce4860-949b-4e84-b884-6090b40c3b96
# ╟─11e4f95f-3849-4260-aed4-e0ac29cad61f
# ╟─8e15d66c-0e8f-4842-bc6c-65f0c49934b7
# ╠═8580f7b7-564d-4469-a022-4bdd3a1b4453
# ╟─f1777ba0-7414-4963-803e-d7335fecc3a9
# ╟─64bdab07-2d6e-4517-b581-35370390fed9
# ╠═da36a333-1639-4a4a-a05b-75e0d04784cc
# ╟─72b9a687-30ef-47ea-81d7-ba563eaeb714
# ╟─7bb96854-2752-488f-b5fd-55dcfd3077ce
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
