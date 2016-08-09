---
title: Atelier Docker
author:
 - Yoan Blanc
date: 2016-08-15
institute: HE-Arc
lang: fr
---

# Préparatifs

```console
$ uname -r
4.6.4-1
$ docker -v
Docker version 1.11.2
$ docker-compose -v
docker-compose version 1.7.1
```

<aside class="notes">
Ayez au moins deux terminaux (_shells_) à disposition.
</aside>

---

# Objectifs

1. Se familiariser avec un _container_ Linux.
2. Créer une application PHP dans un conteneur.
3. Scalabilité horizontale de notre application.

---

## Plongeons.

```console
docker run --interactive \
           --tty \
           --hostname demo \
           --name demo \
           alpine:3.4 \
           /bin/sh
```

<aside class="notes">
[Alpine Linux](http://alpinelinux.org/) est basé sur Busybox et musl libc.
</aside>

---

### Quiz 1

Que manque-t-il?

```console
$ ls -l /
```
<aside class="notes">
Réponse : `bootfs`.
</aside>

---

## Virtualisation d'OS

```shell
/ # uname -a
Linux demo 4.6.4-1-ARCH

(Ctrl-p Ctrl-q)

[yoan@x1]$ uname -a
Linux x1 4.6.4-1-ARCH
```

---

![VMs vs Docker](docker-vs-vm.png)

---

## Histoire

* 1972 IBM VM/370
* 1999 FreeBSD jails
* 2001 Linux VServers
* 2004 Solaris Zones
* 2005 OpenVZ
* 2007 cgroups (Google)
* 2008 LXC
* 2011 dotCloud (Docker)
* 2013 systemd-nspawn
* 2015 [Open Container Initiative](http://opencontainers.org)

---

## Le _“Cloud”_

* Amazon (Xen)
* Citrix Cloud.com (Xen)
* Google Compute Engine (KVM)
* Microsoft Azure (Hyper-V)
* Digital Ocean (KVM)
* Samsung Joyent (SmartOS)
* Verizon (VMware)
* Infomaniak (KVM)
* HE-Arc (OpenVZ)

<aside class=notes>
SmartOS (Joyent, Samsung) = illumos (OpenSolaris) + KVM.
</aside>

---

## Espace de noms

```
/ # ps ax
```

<aside class="notes">
Qu'est-ce qui est étonnant ici? Pas de `init`.

[Problème de zombies...](https://github.com/krallin/tini)
</aside>

---

## _Control Groups_

```
$ docker stats

$ docker update --memory 2GB demo
```
<aside class="notes">
Quota sur les ressources telles que mémoire et CPU.
</aside>

---

## _Copy on Write_ (CoW)

```
/ # echo "Hello World!" > hello.txt

$ docker diff ...
```

---

## Réseau virtuel

```
/ # ip addr

$ ip addr
$ docker network list
$ sudo brctl show
```

---

## Arrêt, redémarrage

```
/ # exit
$ docker ps -a

$ docker start demo

$ docker attach demo
/ # more hello.txt

Ctrl-p + Ctrl-q
$ docker stop demo
```

---

## Exportation

```console
$ docker export -o hello.tar ...
$ tar xf hello.tar
```

---

## Sauvegarde, distribution

```console
$ docker commit demo hearc/hello
$ docker images
```

---

## _Capabilities_


```shell
/ # hostname
demo

/ # hostname hello

hostname: sethostname:
 Operation not permitted
```

---

### `--cap-add=SYS_ADMIN`

```shell
$ docker run -it \
             --cap-add=SYS_ADMIN \
             alpine:3.4 \
             /bin/sh

/ # hostname hello
```

---

## _SECure COMPuting_

Masquage de certains _sys calls_ <br>(par défaut 44 sur 300+).

```console
/ # date --set "2016-08-01 00:00"

date: can't set date: Operation not permitted
```

<aside class="notes">
Chevauchement avec les _capabilities_.

Merci Google Chrome!
</aside>

---

### Plus de sécurité

* AppArmor (SuSE, Ubuntu)
* SELinux (NSA, Red Hat, CentOS, etc.)

---

### _Inter-Container Communication_

Par défaut, deux containers peuvent communiquer entre eux.

```console
$ docker run -it \
             -h demo2 \
             alpine:3.4 \
             /bin/sh

/ # ping -c 3 172.17.0.2
```

---

### ICC (Suite)

Désactiver globalement la communication entre conteneurs.

```shell
# /usr/bin/docker daemon --icc=false ....
```

<aside class=notes>
Ceci est recommandé.
</aside>

---

## Créer un réseau

```shell
$ docker network create mynet
$ docker run -itd \
             --net=mynet \
             --name=demo \
             alpine:3.4 \
             /bin/sh

$ docker attach demo

/ # ip addr
```

---

### Plusieurs réseaux

```
$ docker network create myothernet
$ docker network connect myothernet demo
$ docker attach demo

/ # ip addr
```

---

## Créer un volume

```
$ docker volume create --name myvolume

$ docker run -it \
             --volume myvolume:/data \
             alpine:3.4 /bin/sh

$ docker run -it \
             -v myvolume:/data:ro \
             alpine:3.4 /bin/sh
```

<aside class="notes">
E.g. une base de données, un site web (nginx vs php-fpm), etc.

Plugins : GlusterFS, GCE, Contiv (Ceph), etc.
</aside>

---

## Problèmes actuels

1. Systèmes découplés
2. Itérations rapides
3. Environnement hétérogène
4. Montée en charge horizontale

---

## Créer un système découplé

### Application PHP

    $ docker run -p 8080:80 php:7.0-apache

    $ docker exec -it ... /bin/sh
    # echo '<?php phpinfo();' > /var/www/html/index.php
    # pecl install redis
    # docker-php-ext-enable redis
    # apache2ctl restart

    $ docker cp index.php ...:/var/www/html

    $ docker run redis:3.2-alpine

    $ docker commit ... hearc/php
    $ docker run --link ...:redis -p 8080:80 hearc/php
    $ docker cp ...

### Dockerfile

    $ docker stop
    $ docker rm ...
    $ docker rmi

    $ docker build -t hearc/php .
    $ docker run -d --link redis -p 8080:80 hearc/php

### Docker-compose

    $ docker-compose build
    $ docker-compose up
    $ docker-compose

## Going bigger

TODO

---

### Distribute

 * Kubernetes (Google)
 * CoreOS (Google Ventures)
 * Docker Swarm (1.12)

---

## Links

http://prakhar.me/docker-curriculum/
https://medium.com/google-cloud/docker-swarm-on-google-cloud-platform-c9925bd7863c
https://devblogs.nvidia.com/parallelforall/nvidia-docker-gpu-server-application-deployment-made-easy/
http://research.google.com/pubs/pub43438.html
https://blog.jessfraz.com/post/docker-containers-on-the-desktop/
https://seanmcgary.com/posts/run-docker-containers-with-systemd-nspawn
https://www.opencontainers.org/
https://blog.docker.com/2013/08/containers-docker-how-secure-are-they/
http://www.slideshare.net/ctankersley/docker-for-php-developers-jetbrains
https://medium.com/@lherrera/life-and-death-of-a-container-146dfc62f808
https://blog.docker.com/2016/02/docker-engine-1-10-security/
https://www.linux.com/news/containers-vs-hypervisors-choosing-best-virtualization-technology
