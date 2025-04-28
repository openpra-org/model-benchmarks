
chown /home/benchexec
root@7f1c68912220:/home/benchexec# benchexec /tasks/xfta/xfta.xml --read-only-dir=/ --full-access-dir=/sys/fs/cgroup --full-access-dir=/home/benchexec/ --full-access-dir=/root/.wine


# Fault Tree Benchmarking Tool

## Setup
1. Start by cloning this repository
2. Install `git-lfs` on your machine to access the model data
   1. On MacOS, install Homebrew and run `brew install git-lfs`

### Setup Git LFS
Once `git-lfs` is installed, run:

```shell
$ git lfs install
$ git lfs fetch --all
```

## Docker-Compose Instructions
```shell
$ export REPO_DIR=$(pwd)
$ MSYS_NO_PATHCONV=1 docker-compose build benchmark
$ MSYS_NO_PATHCONV=1 docker-compose run --rm benchmark
```


## Docker Instructions

1. Build the docker image locally:
```shell
$ MSYS_NO_PATHCONV=1 docker build -t ft-bench:benchexec .
```

2. Spin up a container using the built image, optionally mounting the current directory to the 
container internal folder `/mnt`:
```shell
$ MSYS_NO_PATHCONV=1 docker run --rm -it -v $(pwd):/mnt ft-bench:benchexec 
```
   
TODO:
* [ ] Document steps to run the benchexec script on bare-metal.

1. SCRAM: `benchexec scripts/scram-bench.xml --read-only-dir /`
2. SAPHSOLVE: `benchexec scripts/saphsolve-bench.xml --read-only-dir /`
3. XFTA: `benchexec scripts/xfta-bench.xml --read-only-dir /`
