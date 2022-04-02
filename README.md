# Statistical Plots with Julia

I'm teaching a course on data science at [Baden-Württemberg Cooperative State University  Karlsruhe](https://www.karlsruhe.dhbw.de/en/general/about-us.html). Among other things, the course covers the topic 'data visualization', where I use the concept of the *grammar of graphics* (see: Leland Wilkinson, *The Grammar of Graphics*, Springer-Verlag 1999) as a theoretical foundation. 

The Julia graphics packages `Gadfly.jl` and `VegaLite.jl` are presented as two different approaches on how the *grammar of graphics* can be implemented. In this context Pluto notebooks have been created (see the `notebooks` folder) which show basic statistical plots (bar charts, histograms, scatter plots etc.) based on the aforementioned packages so that a direct comparison between them is possible.

The notebook `DV-Basics-Gadfly.jl` serves as the reference model and contains more detailed explanations. In the notebook `DV-Basics-VegaLite.jl` the diagrams from the Gadfly notebook have been reproduced using VegaLite (as close as possible).

Suggestions on how to improve the examples, especially when it comes to use the full potential of the respective graphics packages, are highly welcome!

Updates:
- A notebook with plots using `Plots.jl` and `StatsPlots.jl` has been added (`DV-Basics-Plots.jl`). Unfortunately not all examples could be reproduced.
- A notebook with plots using `Makie.jl` and `AlgebraOfGraphics.jl` has been added (`DV-Basics-AlgebraOfGraphics.jl`). But there are still some unresolved issues.
