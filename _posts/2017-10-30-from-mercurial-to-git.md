---
layout: post
title: "From Mercurial to Git"
excerpt_separator: "<!--more-->"
tags:
  - Git
  - Mercurial
  - hg-fast-export
  - BFG Repo Cleaner
  - version control
---

A few months ago I had to figure out how to migrate a 4 GB repository from Mercurial to Git, and trim the size down along the way. Luckily, I wasn’t the first one to have to do that, so there were a number of resources I could reference, namely [these](https://hackernoon.com/migrating-140-000-commits-from-mercurial-to-git-5cf46f134261) [two](http://www.mehdi-khalili.com/migrating-from-mercurial-to-git). But of course, every specific case has its own specific problems.

<!--more-->

We had enforced username-only author names for the sake of some TeamCity configuration, so in my case my commit author name was `jochan`. However, this was only a style rule and not enforced by Mercurial itself, which meant that the commits were rife with violations, from `jochan <jonathan.chan@domain>`, which was what TortoiseHg would automatically fill in for you, to `Jonathan Chan <jonathan.chan@domain>` to `Jonathan Chan` to `<jonathan.chan@domain>` to `jochan [jonathan.chan@domain]` to blank author names, somehow ― you get the gist. On the other hand, Git *requires* a username and an email. The first step was to obtain a table of everyone’s Active Directory username, full name, and emails from IT, then use it to parse the author names currently in the commit logs it into the mandatory `username <email>` format, and save the mapping `"hgformat"="gitformat"` to be used later. Luckily, the aberrant author names mostly followed regular patterns ― and I do mean *regular*.

```python
null_author             = re.compile("^<>$")
full_name_no_email      = re.compile("^([A-Z]\w*\s?)+$")
full_name_null_email    = re.compile("^([A-Z]\w*\s?)+<>$")
full_name_with_email    = re.compile("^([A-Z]\w*\s?)+<.+>$")
username_no_email       = re.compile("^\w*$")
username_null_email     = re.compile("^\w*\s?<>$")
username_with_email     = re.compile("^\w*\s?<.+>$")
username_sqr_email      = re.compile("^\w*\s?\[.*\]$")
username_rnd_name       = re.compile("^\w*\s?\(.*\)$")
username_address        = re.compile("^\w*@.*$")
any_any                 = re.compile("^.+<.*>$")
null_any                = re.compile("^<.*>$")
any_email               = re.compile("^.+\s\S+@\S+$")
any_null                = re.compile("^.+$")
```

A handlful of tens of thousands of commits were surprisingly quick to parse through to obtain the author names, counting ~200:

```bash
$ hg log | grep user: | sort | uniq | sed "s/user: *//" > authors.txt
$ python authors.py authors.txt > reformatted-authors.txt
```

Now we’re ready to migrate. I initially tried to do it on Windows, but I ran into a bunch of issues about Python and Mercurial imports and whatnot, so I gave up and ran it all on macOS, which worked perfectly (\*nix ftw!). Using [`hg-fast-export`](https://github.com/frej/fast-export) to plunk an existing Mercurial repository into an empty Git repository, there’s some tweaking to do first:

```bash
$ git init
$ git config core.ignoreCase false
```

According to `hg-fast-export`’s warning, with `ignoreCase` set to `false`, commits that only change the case of filenames will show up empty, which we definitely don’t want. Finally:

```bash
$ ./hg-fast-export.sh -r $source --force -A reformatted-authors.txt
$ git config --bool core.bare true
```

The `--force` flag was necessary to deal with closed branches, which prompt the [error](https://github.com/cosmin/git-hg/issues/12) `Repository has at least one unnamed head`. To update the Git repository with new changes from the Mercurial repository, it suffices to run the `hg-fast-export` script again, but there has to be **absolutely no changes** made to the Git repository, or else it would refuse to update. I set the repository to be bare at the end of my script just so that I could prevent myself from accidentally committing things to it while I was experimenting.

After being **absolutely certain** I no longer needed to migrate new changes, it was time to strip down the repository. At several points in the past, some large-ish SQL and ZIP files were unwittingly committed into the repository, which inflated its size quite significantly. The `.git` folder was still ~4 GB. To do this, I used [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/), a pun on the existing `git-filter-branch` and the Big Friendly Giant, I suppose. The instructions are straightforward:

```bash
$ java -jar $bfg_cleaner/bfg.jar --strip-blobs-bigger-than 40M $target
$ git reflog expire --expire=now --all
$ git gc --prune=now --aggressive
```

I experimented with several file sizes and chose 40 MB based on the size of the smallest SQL file it had found. Some Git-hosting services like GitHub do not allow files any larger than 50 MB. After this file stripping, the `.git` folder went down to ~1.5 GB in size. Success!

You might be aware that the most fundamental difference between Mercurial and Git is that Mercurial branches are a property of the commit (so a commit *belongs* to a branch), while Git branches are pointers (so a branch *points* to a commit). Like any modern repository, we frequently open, merge, and close branches to work on specific features; however, after migrating to Git, every single branch ever created came back into existence, since Git has no concept of a “closed” branch. My solution was to use Mercurial to give me a list of closed branches so that I could tag then delete them in Git.

```bash
$ hg heads --closed --template "{branch}\n" | tr " " "_" | sort > all.log
$ hg heads          --template "{branch}\n" | tr " " "_" | sort > open.log
$ comm -2 -3 all.log open.log > closed.log
$ for branch in `cat closed.log`; do \
    git tag "closed/$branch" $branch \
    git branch -df $branch \
  done
```

Confusingly, `hg heads` gives you a list of open branches, while `hg heads --closed` gives you a list of open *and* closed branches, so branches common between the two files (i.e. the open ones) need to be eliminated to get the closed branches. Additionally, spaces are allowed in Mercurial branch names (for some unfathomable reason) but not Git names, so I opted for an underscore replacement (yes, over the dash. fight me). I tagged them all under the group `closed` so that they would be easier to find and identify; furthermore, SourceTree appears to let you collapse branches in the same group.

Another annoying difference between Git and Mercurial is that Mercurial uses both glob and regex syntax for `.hgignore`, while Git only uses glob. And unfortunately, full translation only goes from glob to regex (because [globs aren’t regular](https://en.wikipedia.org/wiki/Glob_%28programming%29#Compared_to_regular_expressions)). While regex is one of my great loves of computing science, why would you need regex in an ignore file? What kind of complex file organization structures are you keeping? Who uses regex in `.*ignore` files? We do, apparently. We had tons of `.hgignore` files at different directory levels on every branch, and something had to be done. Albeit rough and naturally incomplete, this worked pretty well, since most of the regexes weren’t that complex, and most of them could have been implemented in glob anyway.

```bash
#!/bin/bash

git config --bool core.bare false
for branch in `git branch | sed "s/*/ /g"`; do
    git checkout $branch -f
    find . -name ".hgignore" > hgignore-files.log > gitignore-files.log
    for file in `cat hgignore-files.log`; do
        newfile=${file/hgignore/gitignore}
        echo $newfile >> gitignore-files.log
        cp $file $newfile
        sed -i.bak "s/syntax:/#syntax:/; s/^\^//; s/\$$//; s/\\\w\+/*/; s/\\\\\//\//g" $newfile
    done
    cat gitignore-files.log | xargs git add
    if [[ -s gitignore-files.log ]]; then
        git commit -m "Added .gitignore files."
    fi
done
```

Absolutely do not quote me on this. I won’t even try to explain what this does because I’ve forgotten most of it. This also commits the newly-minted `.gitignore` files for you, so you’ll end up with a non-bare repository.

And lastly, to push the repository and clean up all the extraneous files/logs/scripts:

```bash
$ git remote add origin <url>
$ git push --all origin -u
$ git clean -df
```

Now to do away with existing processes, steps piled on and hacked together, and implement [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)...
