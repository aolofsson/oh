# Contributing to "OH"

If you are interested in contributing to the Open Hardware librarya, here are some instructions to get you started. Thank you!

### Coding Guidelines
* Language: Verilog, VHDL, Chisel or any other open source language
* Style: A coding manual to be published soon (stay tuned)

### Contribution advice
* Keep changes small (especially if you are a new contributor)  
* You are responsible for not breaking something with your PR
* Include examples/test code for pull request

### Contribution Conventions
* If it's a bug fix branch, name it XXXX-something where XXXX is the number of
the issue.
* If it's a feature branch, create an enhancement issue to announce your
  intentions, and name it XXXX-something where XXXX is the number of the issue.
* Pull requests descriptions should be as clear as possible and include a
reference to all the issues that they address. 
* Commit messages must start with a capitalized and short summary (max. 50
chars) written in the imperative, followed by an optional, more detailed
explanatory text which is separated from the summary by an empty line.
* Code review comments may be added to your pull request. Discuss, then make 
the suggested modifications and push additional commits to your feature branch. Be sure to post a comment after pushing. The new commits will show up in the 
pull request automatically, but the reviewers will not be notified unless you
comment.
* Pull requests must be cleanly rebased ontop of master without multiple branches mixed into the PR.
* Before the pull request is merged, make sure that you squash your commits into
logical units of work using `git rebase -i` and `git push -f`. After every
commit the test suite should be passing. Include documentation changes in the
same commit so that a revert would remove all traces of the feature or fix.


### How to submit a pull request?

1. Modify the code
2. Run and pass the regression suite
3. Submit a pull request:
 
### How to file a bug report?
For standard issues like bugs and documentation errors please fill out an [issue ticket](https://github.com/parallella/oh/issues)

### How to submit a feature proposals?

0. Check the [Parallella forum](https://forums.parallella.org/) and [Issue Manager](https://github.com/parallella/oh/issues) for work in progress
1. Describe the problem the proposal solves
2. Provide a compelling use case
3. Post and discuss your proposal on the [Parallella forum](https://forums.parallella.org/)
4. Submit a pull request that modifies the documentation and adding new documentation as necessary

### Signoff Requirement

All major code contribution requires a sign-off. The sign-off is a simple line at the end of the explanation for the patch, which certifies that you wrote it or otherwise have the right to pass it on as an open-source patch.  The rules are pretty simple: if you can certify the below (from
[developercertificate.org](http://developercertificate.org/)):

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
660 York Street, Suite 102,
San Francisco, CA 94110 USA

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

Then you just add a line to every git commit message:

    Signed-off-by: Joe Smith <joe.smith@email.com>

Using your real name (sorry, no pseudonyms or anonymous contributions.)

If you set your `user.name` and `user.email` git configs, you can sign your
commit automatically with `git commit -s`.
