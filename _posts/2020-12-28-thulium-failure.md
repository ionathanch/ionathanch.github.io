---
layout: post
title: "Thulium: Disk Failure"
tags:
  - server
categories:
  - Thulium
---

On 24 December 2020, my home server Thulium went down. Usually the cause of downtime is my home's public IP address changing, and I need to update the DDNS record with my domain name provider. This time it wasn't; when I tried to SSH in through the domain, I reached *something*, but it wouldn't let me in. I managed to SSH in through the local IP address and tried to reboot, but I got a *segmentation fault*, of all things. In the end, I rebooted the server manually by walking over to the other room and holding down the power button. I could then SSH in, my Docker containers were up, all was well.

On 27 December 2020, it happened all over again. This time, I could SSH in again, but everything was painfully slow. I checked `htop`: CPU and memory were doing fine. I checked my internet connection: that was fine too. It must be, then, a disk issue (obviously, since that's the title of this post).

<!--more-->

## Diagnosis

First, a few basic tests. Seeing how quickly I can write a bunch of bytes to disk seems like a good enough rudimentary metric. By the powers of the internet, I conjured up the appropriate `dd` command to do this, and found that it took about 0.81s to write 1 GB to disk on my laptop. Very nice. But on Thulium:

```bash
jonathan@thulium:~$ dd if=/dev/zero of=./test bs=512k count=2048 oflag=direct
2048+0 records in
2048+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 64.4742 s, 16.7 MB/s
```

Uh oh.

Time for a more reliable and conclusive test. Thanks to some Linux-savvy internet friends, I determined that I needed to use `smartmontools`. Here's a snippet of what `smartctl -a /dev/sda` gave me:

```bash
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   091   068   006    Pre-fail  Always       -       85481351
  3 Spin_Up_Time            0x0003   097   097   000    Pre-fail  Always       -       0
  4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       60
  5 Reallocated_Sector_Ct   0x0033   075   075   010    Pre-fail  Always       -       30680
  7 Seek_Error_Rate         0x000f   082   060   030    Pre-fail  Always       -       170773956
  9 Power_On_Hours          0x0032   073   073   000    Old_age   Always       -       23717
 10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       60
183 Runtime_Bad_Block       0x0032   097   097   000    Old_age   Always       -       3
184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
187 Reported_Uncorrect      0x0032   001   001   000    Old_age   Always       -       8566
188 Command_Timeout         0x0032   100   093   000    Old_age   Always       -       54 62 62
189 High_Fly_Writes         0x003a   073   073   000    Old_age   Always       -       27
190 Airflow_Temperature_Cel 0x0022   063   054   045    Old_age   Always       -       37 (Min/Max 36/38)
191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       42
193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       60
194 Temperature_Celsius     0x0022   037   046   000    Old_age   Always       -       37 (0 17 0 0 0)
197 Current_Pending_Sector  0x0012   096   095   000    Old_age   Always       -       760
198 Offline_Uncorrectable   0x0010   096   095   000    Old_age   Offline      -       760
199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       23718h+36m+46.063s
241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       9924139044
242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       2610062350
```

The raw values for the read and seek errors seem really high. (I later found out that these raw numbers aren't always to be trusted; furthermore, [this](http://www.users.on.net/~fzabkar/HDD/Seagate_SER_RRER_HEC.html) page seems to indicate that the normalized values above are actually not that bad.) But according to [Wikipedia](https://en.wikipedia.org/wiki/S.M.A.R.T.), the attributes I should really be looking at (excluding the ones with nonzero raw values) are:

* **Reallocated_Sector_Ct**: The number of bad sectors found (30680);
* **Reported_Uncorrect**: The number of errors that could not be recovered (8566);
* **Current_Pending_Sector**: The number of unstable sectors (760); and
* **Offline_Uncorrectable**: The number of uncorrectable sector read/write errors (760).

*Uh oh.*

Finally, I ran a long test with `smartctl -t long /dev/sda` and got back `Completed: read failure`. I guess I really do have to replace the disk then.

## Assessment

I wasn't going to buy a new hard drive. Then that would make me a Serious Server Maintainer, and I'm not ready for that kind of commitment. Luckily, I do have a few spare HDDs laying around. Allow me to introduce the cast:

| Name   | Location          | Model Family                | Model Number          | Capacity |
| ------ | ----------------- | --------------------------- | --------------------- | -------- |
| Sasha  | Thulium (primary) | Seagate Barracuda 7200.14   | ST1000DM003-1CH16     | 1 TB     |
| Monty  | Thulium (backup)  | Seagate Barracuda 7200.7    | ST3160827AS           | 160 GB   |
| Victor | (Unused) desktop  | Seagate Barracuda 7200.12   | ST3320418AS           | 320 GB   |
| Orion  | "External" backup | Western Digital Caviar Blue | WDC WD6400AAKS-75A7B0 | 640 GB   |
| Gerty  | ???               | Western Digital Caviar Blue | WDC WD1600AAJS-00PSA0 | 160 GB   |

I gave them all names so I would remember which hard drives I was talking (to myself) about without getting confused. Victor I used over the summer for programming until I bought my current laptop, Orion came from an old desktop and was housed in an external HDD casing to back up my photos to, and Gerty *must* have come from another old desktop as well but I honestly don't remember.

Here's a brief description of my current setup as well, with where all my data is:

* Sasha contains my Nextcloud setup and all of my other data;
* Monty contains a periodic (but asynchronous) backup of everything on Sasha;
* My laptop contains a synchronous copy of the Nextcloud data on Sasha;
* My phone contains all of my photos;
* Orion contains an asynchronous backup of my photos, which I manage manually and regularly; and
* Some SD card in my bedroom contains an outdated (i.e. pre-pandemic) copy of my photos.

I haven't been exactly vigilant in maintaining good data redundancy. I doubt that I ever will, since I'll only exert just enough effort to create a setup that I'll deem "good enough". But since I've been given a chance to rearrange some things, here's what I plan to do:

* Victor will be the primary Thulium drive, and will not only contain all of what Sasha currently has, but *also* a backup of all of my photos.
* Orion, being the larger disk, will be the backup Thulium drive, and will follow some of William's very complete but rather excessive [backup guide](https://www.williamjbowman.com/blog/2020/06/30/setting-up-your-backup-service/) to back up from Orion.
* Sasha will then be installed into my desktop, largely untouched, except with a GUI and my development tools installed, because I want to see just how long I can keep using it until it really dies out.
* Monty and Gerty will be retired and stored away.

In addition to this, on a regular basis, at my leisure, I will plug my phone into my laptop and manually copy photos into it. The photos will be synced to Thulium via Syncthing, rather than Nextcloud, since I won't have the need to browse through them on a foreign machine. I briefly considered syncing directly from my phone, but the initial sync would take incredibly long, and the directory structure of my photos backup is rather different from that on my phone. Maybe one day I'll settle for some automatic solution that won't involve my direct intervention (i.e. plugging my phone in).

So in the end, my Nextcloud will be synchronized in triplicate, my other Thulium data (including a feed aggregator and a collection of private repositories) will be synchronized in duplicate, and my photos will be partially asynchronously backed up in quadruplicate (excluding the SD card). I think it's good enough for me, especially when the biggest threat in my threat model isn't a disk failure but **me** doing silly things like wiping everything out from the terminal. I'm also using Nextcloud because of a few other features it has, which is why my entire setup isn't exclusively through something like Borg.

Just to be cautious, I ran `smartctl -t long /dev/sdX` on Orion and Victor, which were estimated to take 140 and 74 minutes respectively. Since I'm accessing them on my laptop through a USB connection to an external enclosure, the disk might be put on standby, according to [this](https://sourceforge.net/p/smartmontools/mailman/message/32461042/) thread, so I followed its instructions to copy a few bytes every minutes to keep it awake. Still, that didn't stop me from running `smartctl -c long /dev/sdX` every two minutes or so to check the progress.

Aside from health tests, there's also performance tests that can be run. Here are some results from running `hdparm -Tt /dev/sdX`:

```bash
/dev/sda: # Victor
 Timing cached reads: 9434 MB in  2.00 seconds = 4725.97 MB/sec
 Timing buffered disk reads: 276 MB in  3.02 seconds =  91.50 MB/sec
/dev/sdb: # Orion
 Timing cached reads: 8806 MB in  2.00 seconds = 4411.38 MB/sec
 Timing buffered disk reads: 312 MB in  3.00 seconds = 103.91 MB/sec
/dev/sdc: # Sasha
 Timing cached reads: 24778 MB in  1.99 seconds = 12470.19 MB/sec
 Timing buffered disk reads: 546 MB in  3.01 seconds = 181.67 MB/sec
/dev/sda: # Monty
 Timing cached reads: 1534 MB in  2.00 seconds = 766.34 MB/sec
 Timing buffered disk reads: 152 MB in  3.13 seconds =  48.55 MB/sec
/dev/sdb: # Gerty
 Timing cached reads: 1516 MB in  2.00 seconds = 758.06 MB/sec
 Timing buffered disk reads: 312 MB in  3.00 seconds = 71.10 MB/sec
```

I also used `gnome-disks` from `gnome-disk-utility` to benchmark read/write rates and access times more robustly than just using `dd` above. Sasha's average read/write rates and access times were 31.1 MB/s, 38.8 MB/s, and 62.26 ms. For comparison, Gerty's were 62.3 MB/s, 49.4 MB/s, and 13.63 ms.

## Treatment

I haven't looked into directly copying from Sasha to Orion byte-for-byte, but I don't think that would work anyway, so I'm reinstalling Ubuntu Server on Orion and setting everything up from scratch. The good thing is that I have all of my old blog posts to refer to for this step, and in fact I'll reproduce them here as well for convenience, since three years ago I was kind of fumbling around anyway (not that I've ever stopped fumbling).

### Step -1: Replace the Server Completely

Several problems were encountered from the get-go, each one worse than the other. First, I burned a Ubuntu Server ISO to my USB drive using `pv ubuntu-20.04.1-live-server-amd64.iso > /dev/sdb` as root, but got a weird `isolinux.bin is missing or corrupt` error when trying to boot from it. I ended up using `gnome-disks` to erase the drive, then write ("restore", in their terms) the ISO.

Then I tried to boot from the drive, but only got `Error 1962: No operating system found. Press any key to repeat boot sequence.` Changing from UEFI boot to legacy boot and changing from AHCI to IDE (and combinations thereof) in the BIOS didn't work. In the end, I moved Victor from the original server computer to the desktop computer it originally came from, and things booted up fine. I'm not really sure what's going on here, but this took me an entire day to figure out, so I'm going to leave it at what works. I'm basically turning my desktop computer into the server at this point, and the computer that was originally the server will become a regular desktop.

### Step 0: Basic Setup

The first step is to enable the ethernet connection. `sudo lshw -class network` tells me that the interface is named `enp0s25`, and `sudo ip link set up enp0s25` followed by `sudo dhclient enp0s25` enables it with DHCP. After updating and upgrading my packages, I set up the same static IP I had before. Unfortunately, it appears Ubuntu Server no longer uses the same incantations I had used two and a half year ago; now it's all about `netplan`. In `/etc/netplan/00-installer-config.yaml` goes the following:

```yaml
network:
  ethernets:
    enp0s25:
      dhcp4: false
      addresses: [192.168.0.69/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [84.200.69.80, 84.200.70.40]
  version: 2
```

The `/24` at the end of the IP address is the *subnet prefix length*, which appears to correspond to a netmask of `255.255.255.0` (I still don't know what this means). Since the router's IP address is `192.168.0.0`, the gateway is the same but ending in `.1`. The DNS nameservers listed here are from DNSWatch. Then `sudo netplan apply` applies these settings, giving the server a static IP address of `192.168.0.69`. Nice.

During the setup of Ubuntu Server, there was an option to copy my SSH keys from Github, so now that the server is connected to the internet, and my router is still forwarding ports, I can SSH right in without needing to fiddle with `PasswordAuthentication` in `/etc/ssh/sshd_config` and using `ssh-copy-id`. I still need to give Thulium its own SSH keys, though, with `ssh-keygen`. I also added new ports to forward for Syncthing, 22000 for TCP and 21027 for UDP, through my router's settings at `http://192.168.0.1`.

Now to enable the firewall:

```bash
$ sudo ufw app list
Available applications:
  Nginx Full
  Nginx HTTP
  Nginx HTTPS
  OpenSSH
$ sudo ufw allow "Nginx Full"
$ sudo ufw allow "OpenSSH"
$ sudo ufw allow 22000/tcp # TCP port for Syncthing
$ sudo ufw allow 21027/udp # UDP port for Syncthing
$ sudo ufw enable # `sudo ufw reload` to load new rules if already enabled
$ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
Nginx Full                 ALLOW       Anywhere
OpenSSH                    ALLOW       Anywhere
Nginx Full (v6)            ALLOW       Anywhere (v6)
OpenSSH (v6)               ALLOW       Anywhere (v6)
```

### Step 1: Web Servers and Docker Containers

Setting up all of my Nginx configurations is easy, since I have them all committed [here](https://github.com/ionathanch/sites-available). For recreating my SSL certificates, I not only need to install `certbot`, but also `python3-certbot-nginx`. Then running `sudo certbot --nginx -d` followed by the comma-separated domains installs certificates for those domains (and `--expand -d` followed by a superset of those domains expands the certificate). I also have a daily cron job to update my DDNS with my public IP address:

```bash
#!/bin/sh

curl --silent --output /dev/null "https://dynamicdns.park-your-domain.com/update?host=@&domain=ert.space&password=secretpasswordhere"
curl --silent --output /dev/null "https://dynamicdns.park-your-domain.com/update?host=@&domain=ionathan.ch&password=secretpasswordhere"
```

Docker is a bit trickier. I do have all of my Docker Compose configurations [here](https://github.com/ionathanch/docker-compose), but none of the data is there. But first to pull the images that I need for Gitea, TTRSS, and Nextcloud:

```bash
$ sudo apt install docker.io docker-compose # No longer docker-ce, it seems
$ sudo gpasswd -a jonathan docker           # Add myself to the docker group so I can use it without sudo
$ newgrp docker                             # Log in to docker group
$ docker pull gitea/gitea                   # Gitea
$ docker pull nextcloud                     # Nextcloud
$ docker pull x86dev/docker-ttrss           # Tiny Tiny RSS
$ docker pull syncthing/syncthing           # Syncthing
```

The first container I set up was for TTRSS. I had some strange Docker Compose setting that uses someone else's old Postgres image, so I switched over to the recommended `postgres:alpine` image. In the process of setting things up, I found a [bug](https://github.com/x86dev/docker-ttrss/pull/45) this this particular image for TTRSS. After that was all resolved, I imported my old OPML settings for TTRSS. Easy peasy!

The second was Gitea. There were several options, in decreasing order of difficulty: I could set up a new instance of Gitea completely and re-add my repositories one by one (painful); I could create a Docker image from the data back over on Sasha and somehow integrate that with Docker Compose to keep using the same config file but at the same time use that image (confusing); or I could literally copy all of the files from Sasha over to Victor, `docker-compose up`, and see if that works. To my surprise, the latter really did work! I think I have my past self to thank for setting up the volumes so that the entire `/data/` directory in the Gitea image exists in my `docker/gitea/` directory, but I won't look too much into it.

Next to set up was Syncthing. I created a new Docker Compose configuration for it [here](https://github.com/ionathanch/docker-compose/blob/master/syncthing/docker-compose.yml) since my old one seems to have disappeared (and they now have an official Docker image!). There doesn't seem to be anything else to configure, except for the other end, which will be the Windows boot of my laptop. This I will do later on, but I'm sure things are unlikely to go terribly wrong.

Finally, I have my Nextcloud instance to set up. I decided to try the Gitea technique here as well. Because there were a *lot* of files to copy over and I also needed to preserve *everything* from timestamps to permissions, I used `rsync -av --progress` (archive, verbose, show progress) instead of the usual `cp`. This worked perfectly as well, and I also got a minor upgrade to Nextcloud. I noticed there was a locally-deleted folder that wasn't deleted in the web client,and it didn't seem to be a file lock problem since `DELETE FROM oc_file_locks WHERE lock=-1;` didn't get rid of it, so I had to use `SELECT fileid FROM oc_filecache WHERE storage=2 AND path LIKE '%[file]%'` to get its primary key, making sure there's just the one entry, and `DELETE FROM oc_filecache WHERE fileid=[fileid]` to delete it.

EDIT: I noticed that under Settings > Administration > Basic Settings > Background jobs, the background jobs were not run for months. Presumably the first time I set Nextcloud up, I had also set up background jobs, but forgot to take note of it. I ended up choosing the Cron option, using `sudo crontab -u root -e` to add the following:

```cron
*/5 * * * * docker exec -u www-data nextcloud php cron.php
```

I might as well clean up my Nextcloud files while I'm here. During copying I noticed that I had a lot of old course textbook PDFs that should be easy to obtain <del>on LibGen</del> through legal and not illegal methods, so I think I'll be getting rid of those. I also added exclusion rules `*.gnucash.*.gnucash` and `*.gnucash.*.log` to get rid of those pesky backup files. I could probably also add `*~`, usually generated from Racket files by DrRacket, but I haven't noticed any syncing issues with those (as opposed to with GNUCash).

As for the Docker Compose files from all my old containers, I think I'll keep those around, even though I doubt I'll ever be running a MediaWiki or a Ghost or a Funkwhale here again.

### Step 2: Borgification

So far, all of my Docker-related files are in `/srv/docker/`, while other sites being served are in `/srv/www/`. These will be the directories I want to back up with Borg to Orion, which is mounted at `/backup`. Since I need root permission to read these files, all of the commands below are as root.

```bash
$ borg init --encryption keyfile /backup/borg # Initializes a Borg repo and stores the keyfile in ~/.config/borg
$ touch ~/borg-exclude # Create a Borg exclusion patterns file (empty, for now)
$ borg create --stats --exclude-from ~/borg-exclude /backup/borg::$(date +'%FT%T') /srv # Create the initial backup
$ borg list # Check that the backup was actually created
```

If later I find that there's certain patterns of files I want to exclude, I can add them to `borg-exclude`. Now that I've checked that Borg works (although not whether I can restore from it), I'll add an hourly backup cron job. First, I need to copy the configs to `/root/.config/borg`, since these cron jobs will be run by root. Then into `/etc/cron.hourly/borg-backup` goes the following (and `chmod +x` to make it executable):

```bash
#!/bin/sh

borg create --exclude-from ~/borg-exclude /backup/borg::$(date +'%FT%T') /srv
```

And finally, I'll add a daily cron job `/etc/cron.daily/borg-prune` to prune the backups I have. I'll keep 24 hourly backups, 7 daily ones, and 2 weekly ones. If something has gone wrong with my server and I haven't noticed in two weeks, I may have bigger problems in my life.

```bash
#!/bin/sh

borg prune -H 24 -d 7 -w 2 /backup/borg
```

As an aside, I had originally named these scripts ending in `.sh`, and I tested them by running as root, but when I checked a while later, they didn't seem to have been run: there weren't any new backups listed. Hidden in the Arch Linux wiki for cron was this note:

> Cronie uses run-parts to carry out scripts in the different directories. The filenames should not include any dot (.) since run-parts in its default mode will silently ignore them. The names must consist only of upper and lower-case letters, digits, underscores and minus-hyphens.

So the extension is the culprit! Running `run-parts --test /etc/cron.hourly` (`--report` to actually run the scripts) also indicated that no scripts would be run. Removing those extra `.sh` extensions seems to be the solution.

Borg backups should be easily restored by `borg mount`ing them and then copying them with `rsync -av --progress`. This takes care of my Nextcloud and Gitea files. All the TTRSS files, on the other hand, are in a Docker volume, but as seen above, setting up a fresh container isn't all that hard; I just need the OPML file with the feeds and settings. Unfortunately, TTRSS doesn't provide a public URL to fetch the settings, so I'll do it once now, and hopefully remember to copy them over whenever I change a notable preference. I'll set up yet another daily cron job to fetch the public feeds, although I don't expect any of my feeds to change within periods of months.

```bash
#!/bin/sh

curl -o /srv/docker/ttrss/ttrss.opml "https://rss.ionathan.ch/opml.php?op=publish&key=secretkeyhere"
```

### Step 3: Ubuntu Server as a Desktop

Now that everything I want has been copied over from Sasha to Victor, I can use Sasha as a desktop disk (until it dies for good), back in the computer that it originally was in. I do have a good amount of uncopied files on it, like my entire music library in Funkwhale, so I don't want to wipe it just yet. I'll only remove all the Nginx sites enabled, remove all Docker containers, and add a GUI.

But the computer had other plans.

{% include image.html
           img="assets/images/error-1962.jpg"
           title="Error 1962: No operating system found. Press any key to repeat boot sequence."
           caption="No operating system found on Sasha, despite there very clearly having been one two days ago." %}

I'll fiddle around with this some more, but I doubt I'll get anywhere. I really don't want to wipe out anything on Sasha, so it might just stay in there forever, motionless, unspinning, unused.

**UPDATE**: Even though installing Ubuntu Server on Victor (and even Orion!) and using Sasha with the original computer gave me an Error 1962, it seems that installing an OS (Manjaro KDE, to be precise, but I doubt it matters) on Gerty (or Monty? I've already mixed them up) is perfectly fine. I suspect that it's because the computer itself is old, and those two disks are older than Victor and Orion, and there was some sort of incompatability that revealed itself as an Error 1962. With Sasha, the error was likely genuine: it's a failing disk, after all. So I'm going to continue using Gerty and Monty both in that computer as a desktop for now. Manjaro KDE really is nice.

## Postmortem

Days spent: 3 😩

Hard drives rearranged: 5

Extra screws: 4 (how???)

Packages installed: `smartmontools`, `gnome-disk-utility`, `nginx`, `certbot`, `python3-certbot-nginx`, `docker.io`, `docker-compose`, `sqlite3`, `borgbackup`

## References

* Interpreting SER and RRER values: [http://www.users.on.net/~fzabkar/HDD/Seagate_SER_RRER_HEC.html](http://www.users.on.net/~fzabkar/HDD/Seagate_SER_RRER_HEC.html)
* SMART attributes: [https://en.wikipedia.org/wiki/S.M.A.R.T.](https://en.wikipedia.org/wiki/S.M.A.R.T.)
* Interrupted `smartctl` long tests: [https://sourceforge.net/p/smartmontools/mailman/message/32461042/](https://sourceforge.net/p/smartmontools/mailman/message/32461042/)
* Benchmarking: [https://wiki.archlinux.org/index.php/Benchmarking](https://wiki.archlinux.org/index.php/Benchmarking)
* Burning an ISO to a USB: [https://unix.stackexchange.com/questions/224277/](https://unix.stackexchange.com/questions/224277/)
* Using Certbot: [https://certbot.eff.org/docs/using.html#nginx](https://certbot.eff.org/docs/using.html#nginx)
* Migrating Nextcloud: [https://docs.nextcloud.com/server/15/admin_manual/maintenance/migrating.html](https://docs.nextcloud.com/server/15/admin_manual/maintenance/migrating.html)
* Syncthing with Docker: [https://github.com/syncthing/syncthing/blob/main/README-Docker.md](https://github.com/syncthing/syncthing/blob/main/README-Docker.md)
* Setting up backups: [https://www.williamjbowman.com/blog/2020/06/30/setting-up-your-backup-service/](https://www.williamjbowman.com/blog/2020/06/30/setting-up-your-backup-service/)
* Using Borg: [https://borgbackup.readthedocs.io/en/stable/quickstart.html](https://borgbackup.readthedocs.io/en/stable/quickstart.html)
* Cron: [https://wiki.archlinux.org/index.php/Cron](https://wiki.archlinux.org/index.php/Cron)
