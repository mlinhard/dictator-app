# Dictator App

## Intro

Dictator App is a demo application for demonstrating Blue/Green deployment of an application that uses ActiveMQ. 
It helps autocratic regimes to censor news articles.

The app consists of three components

- **NewsEndpoint** - REST Endpoint (`POST /api/news/article`) that receives new articles in format `{"title":"Something", "content":"Some content"}`
  and posts it to the `ArticleSubmissions` queue for further processing by `CensorshipService`.
- **CensorshipService** - Processes the `ArticleSubmissions` queue, looks at the content of the articles and decides whether it will mark the
  article as `OK` or `CENSORED` before it sends them to `PublishedArticles` queue.
- **PublishingService** - Processes the `PublishedArticles` queue. It will log the article content to `STDOUT` only if it has been marked as `OK` by the censors.

![docs/img/dictator-app.png|](docs/img/dictator-app.png)

## Building

### Building the app

Run `build.sh` to create a docker image `dictator-app:<version>`.

### Building the ActiveMQ server

Run `build-activemq.sh` to create a docker image `dictator-activemq:<version>`

## Running

### Running ActiveMQ server

```
export ARTEMIS_DATA_DIR=/tmp/artemis1
bin/run-docker-mq.sh 61616 8161 5445 5672 1883 61613 172.17.0.3 61617
export ARTEMIS_DATA_DIR=/tmp/artemis2
bin/run-docker-mq.sh 61617 8162 5446 5673 1884 61618 172.17.0.2 61616
```

- NOTE: Change `ARTEMIS_DATA_DIR` value for something that makes sense for your system.
- NOTE: assign target IPs based on your docker env

### Running the app

```
bin/run-docker-app.sh 8080 172.17.0.2 61616
bin/run-docker-app.sh 8081 172.17.0.3 61617
```

- NOTE: assign target IPs based on your docker env

## API Access

GET the official propaganda article

```
curl -H "Content-type: application/json" http://localhost:8080/api/news/article
```

POST an article

```
curl -d '{"title":"hello", "content":"a message"}' -H "Content-type: application/json" http://localhost:8080/api/news/article
```

## Google Cluster Kubernetes setup

1. Create a test cluster, either [manually](https://console.cloud.google.com/kubernetes/list?authuser=1&project=aqueous-charger-221113&template=standard-cluster) or using `gcloud` CLI, e.g:

```
gcloud container clusters create learning-cluster \
    --num-nodes 4 \
    --machine-type g1-small \
    --zone europe-west1-c

gcloud container clusters get-credentials learning-cluster
```

2. Copy `build.conf.example` to `build.conf` and fill in your values.

3. Create Kubernetes objects

```
bin/kube-apply.sh
```

4. Manual: Change load-balancer IP to static and set your DNS so that the address e.g. `example.com` in `APP_DOMAIN` (in build.conf) points to it

5. If your address is `example.com`, you should be able to access these services:
- [dictator-app.example.com](http://dictator-app.example.com)
- [dictator-mq-b.example.com](http://dictator-mq-b.example.com)
- [dictator-mq-g.example.com](http://dictator-mq-g.example.com)

6. You can check status of your services using
```
bin/kube-info.sh
```

- NOTE: to run some of the scripts, you need to install [jq](https://stedolan.github.io/jq/) and [curl](https://curl.haxx.se/).

## Blue/Green Deployment

### 1 Initial state

After deployment of the first version `1.0` you'll have the following scenario

![Initial deployment](docs/img/dictator-deployment-normal.png)

### 2 Candidate deployment

Deploy candidate (version `2.0`). This can be done using the script
```
bin/kube-deploy-candidate.sh
```
You'll end up with something like this

![Candidate deployed](docs/img/dictator-deployment-candidate.png)

This creates a separate service `dictator-app-candidate` which you can run End-to-end tests against. This will be a new pod configured with completely separate MQ server `dictator-mq-g`

### 3 Candidate promotion

After you checked that the version `2.0` behaves correctly (with it's independent MQ `dictator-mq-g`), you can remove the old version and direct all of the production traffic to the new pod. 
After this you'll also gracefully shutdown version `1.0` pod. This may leave some unprocessed messages in it's MQ server `dictator-mq-b`.

![Candidate promoted](docs/img/dictator-deployment-promoted.png)

You can promote candidate using

```
bin/kube-promote-candidate.sh
```

### 4 Handling unprocessed old messages

The unprocessed messages can now be fed via bridge to the new active MQ server `dictator-mq-g`. There's **N-1 compatibility** between versions `1.0` and `2.0` messages, i.e. version `2.0` app 
can process version `1.0` messages.

![Bridging](docs/img/dictator-deployment-bridge.png)

After all of the messages are transferred via the ActiveMQ [Core bridge](https://activemq.apache.org/artemis/docs/1.0.0/core-bridges.html), the bridge can be shut down.

To create and destroy bridges, you can use these commands
```
bin/create-bridge.sh b
bin/destroy-bridge.sh b
```
- NOTE: These will create and destroy bridge `dictator-mq-b` -> `dictator-mq-g`. Use letter `g` instead of `b` to create and destroy the opposite direction bridge.
  These work with ActiveMQ Artemis Jolokia REST API.

![All unprocessed messages transfered](docs/img/dictator-deployment-old-ver-depleted.png)

### 5 Wait until old messages are processed

Before we can switch roles of `dictator-mq-b` and `dictator-mq-g` and deploy another version, we need to wait until all of the `1.0` messages are processed, so that we don't need to maintain
compatibility between another version and this one. You can check the status with `bin/check-queues.sh` command.

![All old messages processed](docs/img/dictator-deployment-old-ver-processed.png)


