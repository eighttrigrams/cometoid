# Rationale

Once I heard Jaron Lanier saying something along the lines that
software has always this problem that it is always bound to its history. This is true, no matter how much you add or change features or refactor. But it is like it is, and I see it as a kind of spirit, which a piece of software retains. What it also means is that earlier decisions impact it disproportionately.

In Cometoid I wanted to use this "law" insofar as I started out from some very simple ideas, 
and then wanted to let the implications of these ideas be my guides. It is quite fascinating how one
thing follows the next naturally. It reminds me of the story of `curl` and how many years of work followed
some very basic initial things the author wanted to do to address his own needs at the time. And it also reminds
me of how weird axiomatic systems in general are. That so much stuff can "come out" of three or so axioms.

In Cometoid one thing I wanted was a completely abstract and general data model, such that the user
decides what concepts and relations actually "mean". I call this the Excel-approach, since the basic model
of cells does not presribe what they are used for. In the end I settled on having only **issues** and **contexts**,
and even these two are very similar.

Another thing that was important to me was to address the hierarchy problem where you build a hierarchy of things and then fix the shortcomings of this approach with tags or symlinks. I wanted issues to be part of multiple contexts by default. As an example let us have contexts `Library` and `Elixir`. Then and issue `Phoenix` should appear in both contexts, such that I can either see libraries (and filter by language) or see all my Elixir stuff (and maybe filter for the libraries).
