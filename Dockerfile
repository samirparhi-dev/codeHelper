# base image
FROM python:3.12


WORKDIR /app

COPY . /app

RUN apt-get update && \
    pip install --upgrade pip && \
    pip install -r requirements.txt


EXPOSE 8000

RUN python wheatherinfo.py
