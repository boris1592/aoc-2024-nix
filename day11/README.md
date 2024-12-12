# Regarding part 2

Solved the second part with zig. I'm pretty sure, it might be impossible with pure nix, since it doesn't have any efficient way of memoizing function return values (even though all of them are pure) like Haskell does (using mutability under the hood). With immutable cache (clonning the cache and adding a value to it after every recursive call) it just runs out of memory.
