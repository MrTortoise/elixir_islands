# elixir_islands

I wrote some code without being paid to do so!!!
Its basically definatley not battleships


admittedly its going through a book as really looking to get into phoenix live view and channels.
The book has no tests though! so having fun taking the book and figuring out how it would read if it was test driven.
Turns out in a lot of cases I think clarity in the book would of been higher - as the reasons for doing things when they are done would be *far* clearer a lot of the time. 

Also I am amazed at the build and test time - it needs to run in a container, yet the CI time is almost as fast as i can go from push in a terminal to alt-tabbing and hitting refresh on github.  Compared to js / dotnet etc (that said i have no selenium tests etc yet) its phenomenally fast (even if just comparing unit tests).

Forgot how much i like doctests in elixir.
[Eg like here](islands_engine/lib/islands_engine/rules.ex)

if whoerver reads this installs elixir you can run the tests with
```bash
mix test
```
