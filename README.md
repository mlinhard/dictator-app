# Dictator App

## Building

Run `build.sh` to create a docker image `docker.io/mlinhard/dictator-app:<version>`

## Running

Run with:

```
docker run -it -p 8080:8080 docker.io/mlinhard/dictator-app:<version>
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

