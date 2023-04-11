### A Pluto.jl notebook ###
# v0.19.22

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
	regions = groupby(
			select(countries, Not([:Country, :Subregion])), :Region)
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
regions_cum |>
	@vlplot(
		width = 600, height = 300,
		:bar,
		x = :Region, y = :Pop2019, color = :Region
	)

# ╔═╡ 17ebb9cc-1080-41f6-a914-f73afbb8e957
md"""
The second version uses serveral formatting options. It has different labels (x-axis, y-axis, title) as well as a more readable label format on the x-axis.
"""

# ╔═╡ afe3969f-6ff9-4c12-88ce-62dc2c3b2b3e
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

# ╔═╡ 9f9924c4-a937-4dea-b045-ba8101c2971b
md"""
## Population by Subregion
"""

# ╔═╡ a2fa5c60-aaf1-4a12-bb17-d260c41b85a6
md"""
Next we have a look at the population of the subregions.
"""

# ╔═╡ 55b9aa0b-da52-4a8c-a7b8-4bf25da2ca2f
subregions_cum |>
	@vlplot(
		width = 600, height = 300,
		:bar,
		x = :Subregion,	y = :Pop2019, color = :Region
	)

# ╔═╡ ea4f0f45-7fb3-4faa-bdb9-5b4a1df04280
md"""
As there are quite a few subregions, a horizontal bar diagram might be more readable. Apart from that we adapt the labels.
"""

# ╔═╡ 94bfd9c5-2877-417e-a18c-4983f243fc85
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

# ╔═╡ 0d84e074-af24-4823-a355-57a3485edc36
md"""
It get's even more readable, if we sort the subregions by population size before rendering the diagram.
"""

# ╔═╡ 9f72a8e5-8777-40c0-a6af-75b1a2aa7115
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
countries |>
	@vlplot(
		width = 600, height = 300,
		:point,
		x = :Pop2019, y = :PopChangePct, color = :Region
	)

# ╔═╡ e0b07b43-4446-43f5-814a-0642ece326e7
md"""
The distribution of the data is quite skewed. So a logarithmic scale on the x-axis might give a better insight of the data. And again, we add some labels.
"""

# ╔═╡ 1dc24d9c-8d8d-479c-b9e1-79792ee2ab0c
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

# ╔═╡ ec791080-6c52-4c80-b7ca-43b604d4ede1
md"""
# Histograms
"""

# ╔═╡ 389e95fc-d410-481e-a753-f36ec70fa931
md"""
## Distribution of GDP per Capita
"""

# ╔═╡ f2753a4d-7bcd-4866-b59c-5568385e88c3
countries |>
	@vlplot(
		width = 600, height = 300,
		:bar,
		x = {:GDPperCapita, bin = true}, y = "count()"
	)

# ╔═╡ 5782433d-5ab6-4a9c-a6fd-04610edb1dd8
md"""
The labels on the x-axis are set automatically to match class boundaries. And a reasonable bin size has been chosen by default.
"""

# ╔═╡ e46e377d-a637-4ba8-a9ba-789d6e6415f3
md"""
And again with labels (and the same number of bins as in the Gadfly example).
"""

# ╔═╡ 56892be5-2c1c-40a8-b0cd-d958d71a8845
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
countries |>
	@vlplot(
		title = "GDP per Capita by Region, 2019",
		width = 600, height = 300,
		:boxplot,
		# transform = [{filter = "datum.GDPperCapita <= 100000"}],
		x = {:Region, title = "Region", axis = {labelAngle = 0}}, 
		y = {:GDPperCapita, title = "GDP per Capita [USD]"}, 
		color = :Region,
		config = {background = "ghostwhite"}
	)

# ╔═╡ f1777ba0-7414-4963-803e-d7335fecc3a9
md"""
In order to restrict the GDP values to values <= 100.000, VegaLite uses a different logic than Gadfly. In Gadfly this is done by restricting the coordinate system on the y-axis to values between 0 and 100.000 (via `Coord` and `ymax = 100000`), but a `scale = {domain = [0, 100000]}` on the y-axis doesn't produce the desired result here.

In VegaLite the range of *data* used (i.e. the `GDPperCapita` values themselfes) have to be restricted to that range. This is done using a `filter`-command within a `transform` (and results in a different plot!).

"""

# ╔═╡ 64bdab07-2d6e-4517-b581-35370390fed9
md"""
## Violin Plot: GDP per Capita by Region, 2019
"""

# ╔═╡ da36a333-1639-4a4a-a05b-75e0d04784cc
countries |>
	@vlplot(
		title = "GDP per Capita by Region, 2019",
		height = 400,
		mark = {:area, orient = "horizontal"},
		
		transform = [
			#{filter = "datum.GDPperCapita <= 100000"},
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

# ╔═╡ 72b9a687-30ef-47ea-81d7-ba563eaeb714
md"""
As VegaLite doesn't support violin plots as a `mark` on it's own, they have to be constructed using density plots and listed in a row using the `column` dimension (here: five density plots, one for each region).
"""

# ╔═╡ 7bb96854-2752-488f-b5fd-55dcfd3077ce
md"""
*Note*: The GDP values can be restricted to values <= 100.000 using a `filter`. To do that, the line starting with `filter` has to be uncommented.
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
CSV = "~0.10.9"
DataFrames = "~1.5.0"
PlutoUI = "~0.7.50"
VegaLite = "~2.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "SnoopPrecompile", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "c700cce799b51c9045473de751e9319bdd1c6e94"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.9"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "89a9db8d28102b094992472d333674bd1a83ce2a"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.1"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

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

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

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

[[HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "37e4657cd56b11abe3d10cd4a1ec5fbdb4180263"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.4"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "8d928db71efdc942f10e751564e6bbea1e600dfe"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "1.0.1"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[NodeJS]]
deps = ["Pkg"]
git-tree-sha1 = "905224bbdd4b555c69bb964514cfa387616f0d3a"
uuid = "2bd173c7-0d6d-553b-b6af-13a54713934c"
version = "1.3.0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

[[OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "548793c7859e28ef026dba514752275ee871169f"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "0b829474fed270a4b0ab07117dce9b9a2fa7581a"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.12"

[[Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Vega]]
deps = ["DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "JSONSchema", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "Setfield", "TableTraits", "TableTraitsUtils", "URIParser"]
git-tree-sha1 = "c6bd0c396ce433dce24c4a64d5a5ab6dc8e40382"
uuid = "239c3e63-733f-47ad-beb7-a12fde22c578"
version = "2.3.1"

[[VegaLite]]
deps = ["Base64", "DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "TableTraits", "TableTraitsUtils", "URIParser", "Vega"]
git-tree-sha1 = "3e23f28af36da21bfb4acef08b144f92ad205660"
uuid = "112f6efa-9a02-5b7d-90c0-432ed331239a"
version = "2.6.0"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─f4588c88-48d4-473e-b0d7-daa9ba1f0a00
# ╠═61c31884-4e1a-4f71-aa47-a0573d3e341a
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
