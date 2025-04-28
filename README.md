# PRA Model Benchmarking Tool

<a href="https://doi.org/10.5281/zenodo.15297777"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.15297777.svg" alt="DOI"></a>
Instrumentation for automating benchmarks using benchexec in Docker.

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

1. SCRAM: `benchexec tasks/scram.xml --read-only-dir /`
2. SAPHSOLVE: `benchexec tasks/saphsolve.xml --read-only-dir /`
3. XFTA: `benchexec tasks/xfta/xfta.xml --read-only-dir /`
4. FTREX: `benchexec scripts/ftrex/ftrex.xml --read-only-dir /`
