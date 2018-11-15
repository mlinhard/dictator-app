# Dictator App

## Building

Run `build.sh` to create a docker image `docker.io/mlinhard/dictator-app:<version>`

## Running

Run with:

```
docker run -it -p 8080:8080 --network host \
    -e ACTIVEMQ_HOST=localhost \
    -e ACTIVEMQ_PORT=61616 \
    -e ACTIVEMQ_USER=dictator \
    -e ACTIVEMQ_PASSWORD=ourleader \
    docker.io/mlinhard/dictator-app:`git describe --tags`
```

## API Access

GET the official propaganda article

```
curl -H "Content-type: application/json" http://localhost:8080/api/news/article
```

POST an article

```
curl -d '{"title":"hello", "content":"a message"}' -H "Content-type: application/json" http://localhost:8080/api/news/article
```


# ActiveMQ Server

## Building

Run `build-activemq.sh` to create a docker image `docker.io/mlinhard/dictator-activemq:<version>`

```
docker run -it --rm \
  -p 8161:8161 \
  -p 61616:61616 \
  -e ARTEMIS_USERNAME=dictator \
  -e ARTEMIS_PASSWORD=ourleader \
  -v /home/mlinhard/Downloads/artemis1:/var/lib/artemis/data:rw,z \
  docker.io/mlinhard/dictator-activemq:`git describe --tags`
```


