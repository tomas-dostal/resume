# Resume

This repository allows you to create a self-hosted [jsonresume](https://jsonresume.org/) CV / generate your CV with docker. [Running instance](https://cv.xn--dostl-0qa.eu/)

## Usage

Build
```sh
docker build -t resume .
```

Execute nginx with your resume on port 8080
```sh
docker run resume:latest -d # run as a daemon
```

Accessible paths:
- [localhost:8080/](http://localhost:8080/) root html resume
- [localhost:8080/cv.pdf](http://localhost:8080/cv.pdf) pdf of your resume


Copy pdf directly from the container

```sh
docker cp $(docker create --rm resume:latest):/app/static/cv.pdf ./

# first create (and later remove) the container, because we can not copy from an image. Then copy the /app/static/cv.pdf to the current directory ./

```

## Why?

That's a good question. First of all, I wanted to continue using my current [jsonresume](https://jsonresume.org/), however, I didn't like the approach of installing all the deprecated npm packages to my server and hope. With multistage Dockerfile, I can generate static files in an image with all the requirements and later serve just what is needed in a lightweight image. Besides, I'd like to switch to docker anyway, as I find it more convenient to maintain.
