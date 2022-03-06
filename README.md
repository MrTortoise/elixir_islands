# elixir_islands

I wrote some code without being paid to do so!!!
Its basically definatley not battleships

## The long plan

I want to go through some genetic algorithm stuff and this game will end up being an interesting one to fire at it.

## The short plan

Remeber elixir, get supervisors down again (they can be janky to test as you need unique names and have to think about all the concurrency stuff)
Fun problems that are in any system - but here you control everything.


admittedly its going through a book as really looking to get into phoenix live view and channels.
So please don't think the actual solution code here is mine!

The book has no tests though! and a few things have changed in the language so having to update them. So, having fun taking the book and figuring out how it would read if it was test driven.
Turns out in a lot of cases I think clarity in the book would of been higher - as the reasons for doing things when they are done would be *far* clearer a lot of the time. This however would involve more complex topics like OTP up front - evolving data models in TDD would make for a **much** longer book.

Also I am amazed at the build and test time (70 tests in 0.2s) - it needs to run in a container, yet the CI time is almost as fast as i can go from push in a terminal to alt-tabbing and hitting refresh on github.  Compared to js / dotnet etc (that said i have no selenium tests etc yet) its phenomenally fast (even if just comparing unit tests).

Forgot how much i like doctests in elixir.
[Eg like here](islands_engine/lib/islands_engine/rules.ex)

if whoerver reads this installs elixir you can run the tests with
```bash
mix test
```

last time i worked through this book i followed along with all the console stuff to test ... took fucking ages didnt get as far in a week as i hav ein 2 days by using tests (because rerunning a load of console commands to get to a state is fiddly as fuck)
