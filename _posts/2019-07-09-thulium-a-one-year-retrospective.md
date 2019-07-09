---
layout: post
title: "Thulium: A One-Year Retrospective"
excerpt_separator: "<!--more-->"
tags:
  - server
categories:
  - Thulium
---

A few months ago, on the 15th of April, was the one-year anniversary of [ert.space](https://ert.space) and the Thulium server, still running happily in its desktop tower, now with an extra 2 GB of RAM. Even if I didn't have the [Thulium posts]({% link category/thulium.md %}) to remind me, I would always have the timely bill for the domain name. Over the past year, a multitude of services and Docker containers have risen and fallen, replaced or abandoned or, rarely, taken up a more permanent post. In 2018, I began with the following:

<!--more-->

* [Syncthing](https://syncthing.net/), for synchronizing my files across my devices
* [h5ai](https://larsjung.de/h5ai/), as a site for browsing those synced files
* [Gitea](https://gitea.io/en-us/), for hosting my private repositories
* [Ghost](https://ghost.org/), as the primary site for these blog posts
* [Linux Dash](https://github.com/afaqurk/linux-dash), for monitoring my server from the browser


Soon after came a few other services:

* [Nextcloud](https://nextcloud.com/) replaced Syncthing and h5ai as a file synchronizer where I could also browse my files via the browser
* [Tiny Tiny RSS](https://tt-rss.org/) took up residence as a replacement for Feedly, which itself was a replacement for the long-defunct Google Reader
* [Uptime Robot](https://uptimerobot.com/), *not* a self-hosted solution, became my primary method of being notified of server downtimes, which for the most part was caused by home IP address changes making my DDNS be out of date, replacing Linux Dash, which was useless during these outages anyway
* [Standard Notes](https://standardnotes.org/) was my primary note-taking app for a while, replacing Google Keep, but I shut that down recently after a Docker fiasco wherein I accidentally wiped the database volume, replacing it with the [Notes](https://apps.nextcloud.com/apps/notes) app in Nextcloud
* [Funkwhale](https://funkwhale.audio/) took a lot of work everything working and the music syncing properly, and then they came out with a one-container image *after* I had set my instance up, but now that I have a sizeable SD card I'm considering keeping all my music locally since I don't have the data to stream anyway
* After some [extensive research](https://cybre.space/@nonphatic/102243127353051678) on self-hosted wikis, I briefly hosted [MediaWiki](https://www.mediawiki.org/wiki/MediaWiki), but I found MediaWiki's markup language to be just *terrible, so I soon replaced it with [reStructuredText files](https://github.com/ionathanch/ionchypedia) built and hosted by [Read the Docs](https://readthedocs.org/)

I also experimented with my own instances of [Pleroma](https://pleroma.social/), [PixelFed](https://pixelfed.org/) (no federation or importing from Instagram as of the publication of this post), and [Mattermost](https://mattermost.com/) (a bit too heavy for the purposes of messaging with just my family, see [this](https://cybre.space/@nonphatic/100142236071395351) thread; I also considered Rocket.Chat and Zulip). There might also possibly be other services I've forgotten about that I never got working, or that I got working but never registered a subdomain CNAME record for; the main point is that I've come to host a *lot* of short-lived stuff on my server. Now only these remain:

* [ExertSpace](https://ex.ert.space/) running Nextcloud for my files;
* [Gitbert on Gitea](https://gitb.ert.space/) continues to hold my repos;
* [ress.ert.space](https://ress.ert.space/), originally a pun on RSS, points to my TTRSS aggregator, although I'm considering changing its URL;
* [conc.ert.space](https://conc.ert.space/), a URL I'm quite proud of, is the Funkwhale instance which may be taken down soon;
* [ionchypedia](https://wiki.ert.space/en/latest/) is the personal wiki I have hosted by Read the Docs; and finally,
* [⟨ortho|normal⟩](https://hilb.ert.space/), this very site, is a Jekyll static site hosted by Github Pages, which was easy to set up given that posts in Ghost are already in Markdown.

With ionchypedia and ⟨ortho|normal⟩, I have the option to host the sites myself if I wish to do so, possibly even moving my repositories to Gitbert and setting up commit hooks to build the sites with Sphinx (reST) and Jekyll (Markdown). Once my Funkwhale instance goes down, there will really only be three things I'm self-hosting. And it's for the best! I will continue to experiment with self-hosted services, of course, since I *can*, but I think now there's a few things I'd consider first before establishing something for the long-term on my server.

* **I don't *have* to host everything myself.** This is another one of the reasons I might be shutting Funkwhale down: I use Spotify *far* more often than I do my own music streamer, because they have far more music and playlists than I could ever curate. Somebody else already provides something way better than anything I could host myself realistically, and it's not worth struggling to use something that doesn't fit my needs just to say that I self-host it.
* **Not everything needs to be private.** For something like Nextcloud or Gitea, where I intend for my data to be easily accessible but to me only, it makes sense to self-host services that allow me to easily access them, but for things like my wiki and my blog where the content is supposed to be public anyway, it doesn't matter that it's stored or served from my server or someone else's.
* **Multi-user services aren't really appropriate when I only want something for myself.** Pleroma and PixelFed and Funkwhale and MediaWiki, these were all meant to be social platforms for many users, even if they do have single-user or private settings, and that means their complexity of maintenance is geared towards that as well. I may consider hosting PixelFed once it matures enough (and has an official Docker image) to replace Instagram, but for now, I am satisfied with using someone else's instances or finding alternatives.
* **Thulium should enrich my tech life, not burden it.** Let me tell you, Standard Notes and Funkwhale were *extremely* difficult to set up. On top of that, there's all the updating and management to do for each one of them. Ultimately, if a service causes more struggles (e.g. wiping all my data on an attempt to update my Docker image) than joys (no more worrying about running out of space on Google Drive!), it shouldn't deserve a permanent place on my server.

And so that's that! But not to sound like I'm cutting out all the lovely Docker containers from my life—I still have some further projects I may consider valuable. A password manager for instance, since I currently rely so much on Firefox's password manager, and it seems like the kind of private data I should like to host myself (I'm looking into [Bitwarden](https://bitwarden.com/), [sysPass](https://syspass.org/en), and [Passit](https://passit.io/)). Maybe some archival solution for all my old files scattered between two computers and two external hard drives. Perhaps I'll finally host my own email server! The possibilities, like I've said, are [finitely large](https://cybre.space/@nonphatic/99848732232210447).

To another year of Thulium! 🎉
