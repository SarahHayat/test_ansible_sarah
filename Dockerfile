# Alpine version has to be used to install psycopg2 dependencies
FROM python:3.8.5-alpine

ENV PYTHONUNBUFFERED 1
ARG project_dir="/code"

RUN mkdir -p $project_dir
WORKDIR $project_dir

RUN apk update \
    && apk add \
    bash \
    build-base \
    gcc \
    jpeg-dev \
    musl-dev \
    postgresql-dev \
    python3-dev \
    zlib-dev \
    gettext \

RUN pip install --upgrade pip

ADD . $project_dir/
