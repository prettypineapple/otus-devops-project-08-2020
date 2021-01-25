FROM python:3.6.0-alpine

WORKDIR /app
COPY . .

RUN apk --no-cache --update add build-base gcc musl-dev && \
    pip install -r /app/requirements.txt -r /app/requirements-test.txt && \
    apk del build-base gcc musl-dev

ENV MONGO=mongodb
ENV MONGO_PORT=27017
ENV RMQ_HOST=rabbitmq
ENV RMQ_QUEUE=urls
ENV RMQ_USERNAME=user
ENV RMQ_PASSWORD=password
ENV CHECK_INTERVAL=60
ENV EXCLUDE_URLS=".*github.com"

CMD ["python3", "-u", "crawler/crawler.py", "https://vitkhab.github.io/search_engine_test_site"]
