# Docker image to carry out the standard machine learning statistical analysis procedure

This repository houses a Docker image and the infrastructure used to create and deploy it to [Docker Hub](https://hub.docker.com/repository/docker/alfaro96/analysis).

## Building

The Docker image can be built using the following command:

```bash
docker build -f Dockerfile -t alfaro96/analysis
```

## Pulling

Alternatively, the Docker image can be pulled from [Docker Hub](https://hub.docker.com/repository/docker/alfaro96/analysis):

```bash
docker pull alfaro96/analysis
```

## Running

After building or pulling the `alfaro96/analysis` image, you can use `docker run` to run the image. In particular, to format and export the experimental results:

---

**Note**: The `-v` flag share directories between the Docker container and your machine. Without `-v`, your work will be wiped once the container quits. Check out the [`docker run` documentation](https://docs.docker.com/engine/reference/run/) for more information.

---

```bash
docker run -p 8888:8888 -v $PWD:/home/jovyan/work alfaro96/analysis format --source results --destination tables
```

or use `docker-compose run`:

```bash
docker-compose run format --source results --destination tables
```

On the other hand, to analyze the experimental results and generate a report:

```bash
docker run -p 8888:8888 -v $PWD:/home/jovyan/work alfaro96/analysis analysis --source tables --destination reports
```

or:

```bash
docker-compose run analysis --source tables --destination reports
```
