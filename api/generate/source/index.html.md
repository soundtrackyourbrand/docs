---
title: Docs | Soundtrack API

language_tabs: # must be one of https://git.io/vQNgJ
  - shell

toc_footers:
  - <a href='https://www.soundtrackyourbrand.com/api/apply'>Get your free credentials here</a>
  - <a href='https://join.slack.com/t/soundtrack-api/shared_invite/enQtNDMwMjY0Mzg2ODk2LTk0YWI4MjBmNzJiODg4MDFiZmYxYmI0NDk3ZmRiN2FlYjUyMGFmNTAxZjZhMjhhNmMzNmRlYmM4YjNkNDhjMDk'>Join our public Slack channel</a>
  - <a href='https://github.com/lord/slate'>Documentation Powered by Slate</a>

includes:

search: true
---

# Docs that doesn't suck

> **"I'm new to the Soundtrack API"**<br>
> These docs are structured for you, so just keep scrolling.

> **"I kind of know my way around"**<br>
> Search in the left nav bar, use our [playground](https://api.soundtrackyourbrand.com/v2/explore) and [reference](https://developer.soundtrackyourbrand.com/api/reference).

> **"I just want to start coding"**<br>
> Ensure you have credentials and head over to our [playground](https://api.soundtrackyourbrand.com/v2/explore).

This is the documentation for Soundtrack API. There's just too much shitty documentation out there, and we aim to be better than that. Feel free to do pull requests [straight into the repo](https://github.com/soundtrackyourbrand/docs/blob/master/api/generate/source/index.html.md) if you have any suggestions - or drop us a line in our [public Slack channel](https://join.slack.com/t/soundtrack-api/shared_invite/enQtNDMwMjY0Mzg2ODk2LTk0YWI4MjBmNzJiODg4MDFiZmYxYmI0NDk3ZmRiN2FlYjUyMGFmNTAxZjZhMjhhNmMzNmRlYmM4YjNkNDhjMDk).

Soundtrack is a complete music streaming service for businesses.  Soundtrack API lets you build display-, control- and monitoring apps on top of Soundtrack. You can learn more about Soundtrack [here](https://www.soundtrackyourbrand.com) and get inspired on how to use the API [here](https://www.soundtrackyourbrand.com/api).

<aside class="notice">
You'll need a <a href="https://business.soundtrackyourbrand.com/signup/">Soundtrack account</a> and an <a href="https://www.soundtrackyourbrand.com/api/apply">API token</a> to get started (unless you use <a href="#authorizing-as-a-user">this way</a> to authorize). Soundtrack API is free for all Soundtrack users.
</aside>


# Getting a grasp

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  nowPlaying(soundZone: "U291bmRabwsMWNhedTc1Nm8v") {
    track {
      name
      artists {
        name
      }
    }
  }
}
'
```
> **Response**

```json
{
  "data": {
    "nowPlaying": {
      "track": {
        "name": "Branches",
        "artists": [
          {
            "name": "Fluida"
          }
        ]
      }
    }
  }
}
```

We've built Soundtrack API using GraphQL. One big upside is that you only get what you ask for ([we list more upsides here](#graphql)).

To get a quick grasp of the API, lets take an example: you want to add some info in your app of what's currently playing in your store.

In this query, you ask for the **track name** and **name(s) of the artist(s)**. What do you get in response? A classic blob of all-data-existing-on-this-endpoint á la REST that you then need to parse? No, the response is... track name and artist(s) name(s).

There's obviously a bunch of more stuff you can fetch and control. Keep scrolling to explore some of it (for the full API reference [click here](https://developer.soundtrackyourbrand.com/api/reference)).


# The basics

It's not a pre-requisite to know the ins and outs of GraphQL, but we do recommend you to at least read our brief GraphQL intro [further down this page](#graphql).

## Your request

### Endpoint

```shell
https://api.soundtrackyourbrand.com/v2
```

There's only one endpoint, unless you're using [subscriptions](#subscriptions) (we'll come to that in a bit).

### Token

```shell
-H 'Authorization: Basic your_token'
```

For the token [you've received from Soundtrack](#), we use `Basic`-auth. Make sure to keep your token safe, we'll block any tokens that are compromised.

You can login without asking us for a token, given you have login credentials to Soundtrack. Just follow [these instructions](#authorizing-as-a-user).

### Content-Type

```shell
-H 'Content-Type: application/graphql'
```

To make things easier to read, these docs uses `application/graphql` as content-type.

> In production, use the below content-type and [adjust your queries](#parameterised-queries)

```shell
-H 'Content-Type: application/json'
```
In production, we recommend that you use [parameterised queries](#parameterised-queries) (`application/json`). It decreases the risk for injections and you'll be able to re-use more code.

### Body

```shell
-d '
{
  nowPlaying(soundZone: "soundzone_id") {
    track {
      name
      album {
        name
        image {
          url
        }
      }
    }
  }
}
'
```

Soundtrack API supports queries (get stuff), mutations (do stuff) and subscriptions (know when stuff changes). We'll describe all of these three in a bit, but what you need to know now is: regardless what you are doing, you need to send a `POST` body specifying what you want to get/do.

## Our response

```json
{
  "data": {
    "nowPlaying": {
      "track": {
        "name": "Sweet Addiction - Live Edit",
        "album": {
          "name": "Nous Horizon, Vol. 2 (Re-Works & Edits)",
          "image": {
            "url": "https://l.cdnurl.com/image/31bbda8605500ba6345bd61941fd3cc536ad779"
          }
        }
      }
    }
  }
}
```
We will respond with a `JSON`. Notice that the shape of the JSON in the response follows the shape of the query.

## Soundtrack hierarchy

We highly recommend that you play around with your Soundtrack account so you get an overview of the product prior to using the API. All guides and frequently asked questions regarding Soundtrack can be found on our [help pages](http://help.soundtrackyourbrand.com).

As you've seen in the examples, there's something called a "sound zone". In the table below, we've explained the different concepts you need to know about.

Concept | Description
--------- | -----------
Account | e.g. "Sven's burgers". Can have multiple locations.
Location | e.g. "Flagship Store, Stockholm". Can have multiple sound zones.
Sound zone | e.g. "Bar" or "Lobby". Can only have one device.
Device | One of the [supported player types](https://help.soundtrackbusiness.com/hc/en-us/articles/115002026372). Needed to play music.
User | Can control one or many accounts.

Each sound zone can only output one music stream. So if you want different music in different parts of the same location, you need multiple sound zones (and thus: multiple devices).

If you want the same music everywhere in the same location you’ll only need one sound zone (and one device) and then distribute the music using your audio system.

Each sound zone equals one subscription (which is what costs money).

## Asking what you don't know

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  me {
  ...on PublicAPIClient {
      accounts(first: 1) {
        edges {
          node {
            businessName
            locations(first: 1) {
              edges {
                node {
                  name
                	soundZones(first: 2) {
                    edges {
                      node {
                        id
                        name
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
'
```

As you saw in the [first example query](#getting-a-grasp), with a short query you'll get the info you need - given you know the `id` (e.g. the id of the sound zone). But how do you get to know what the `id` is? You ask Soundtrack API.

In this example, we want to know:

- The **businessName** of the first account we have access to (e.g. `Sven's Burger Corp.`)

- The **name** of the first **location** belonging to that account (e.g. `Flagship restaurant NYC`)

- The **id** and **name** of the first two **sound zones** belonging to that location (e.g. `{lLCwxazBn.., The Bar},{wwNHd3ZTg.., Restaurant area}`)

As you might notice, there are a two new concepts in this query:

- Introspection (the `me`-part) which allows you to explore what you have access to.

- Connections (the `edges`, `nodes` & `first: 1`) which enables pagination as well as some other things.

For the sake of structure, we'll let you drill down on introspection [here](#graphql) and connections [here](#connections).

# Type of actions

Soundtrack API supports queries, subscriptions and mutations.

 | Example, use case
---------- | -------
Queries | Fetch information that usually doesn't change (e.g. sound zone name)
Subscriptions | Fetch information that usually changes (e.g. what's currently playing)
Mutations | Make changes (e.g. skip to next track)

## Queries

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  soundZone(id:"soundzone_id") {
    name
    id
    isPaired
  }
}
'
```

> Response

```json
{
  "data": {
    "soundZone": {
      "name": "Staff room",
      "isPaired": true,
      "id": "U291bmRab25lLCwxanAzcjVsZTlkcy9m8v"
    }
  }
}
```

Use queries for getting information that you don't expect to change very often. For example: a sound zone id, the name of the account and a list of all your locations.

In the beginning of your query, there's the root query. If you have the id to your account or sound zone, you can input this id and instantly get the information you need. If you don't have the ids, just start off with `me` to get it, [as explained here](#asking-what-you-don-39-t-know). All root queries can be found in the [reference](https://developer.soundtrackyourbrand.com/api/reference/rootquerytype.doc.html).

In this example, we ask for the name and the id of a specific sound zone. We also ask whether it is paired to a player or not.

For queries, you actually don't need to start the body with `query` since GraphQL assumes it's a query if that initial string is missing. However, we recommend including it to make the code self-explanatory.

## Subscriptions

Use subscriptions for getting information you expect to change often. For example: what is currently playing, current playback state (played/paused) and current sound zone errors.

All subscriptions can be found in the [reference](https://developer.soundtrackyourbrand.com/api/reference/rootsubscriptiontype.doc.html).

### Endpoint & token

```plaintext
wss://api.soundtrackyourbrand.com/v2?Authorization=Basic%20your_token
```

For subscriptions there are two things you need to adjust: the endpoint and the way you supply your token.

The **endpoint** is `wss` instead of `https`. That's because we use [web sockets](https://en.wikipedia.org/wiki/WebSocket) for subscriptions (WSS = Web Sockets Secure).

You won't be using any headers, so the **token** need to be passed as a query parameter.

### Example

```plaintext
subscription nowPlaying {
  nowPlayingUpdate(input: {soundZone: "soundzone_id"}) {
    nowPlaying {
      track {
        name
        album {
          name
          image {
            url
            width
            height
          }
        }
        artists {
          name
        }
      }
    }
  }
}
```

> Initial response

```plaintext
"Your subscription data will appear here after server publication!"
```

> Response once there's data (this response will update)

```json
{
  "data": {
    "nowPlayingUpdate": {
      "nowPlaying": {
        "track": {
          "name": "Needs",
          "artists": [
            {
              "name": "Loure"
            }
          ],
          "album": {
            "name": "Smooth Talk EP",
            "image": {
              "width": 640,
              "url": "https://theurltothealbumartwork.com/07dc5282",
              "height": 640
            }
          }
        }
      }
    }
  }
}
```

<aside class="notice">
Since cURL doesn't support web sockets out-of-the box, we don't provide you with a cURL example. Instead: if you want to try subscriptions straight away, check out our <a href="https://api.soundtrackyourbrand.com/v2/explore">playground</a>.
</aside>

In this example we want to get enough information in order to build a neat display screen showing what's playing. For that we need the **name of the artist, album & track** as well as some **album art info**.

Once you fire away the request, you'll most likely get an initial response stating that there's not yet any data to display. Once there's anything that is changing, the response will update.

**"But I want to show what's playing when a user opens my app - they shouldn't have to wait!"**

Good thinking! In those cases you should have an initial query where you ask for what's playing. Then you'll let the subscription take over from there.

**"What if I the web socket connection is lost in one way or another?"**

It's up to you to handle this in your code. Maybe by sending a query (to fetch what's playing) and then re-try the subscription.

**"Why can't I just use queries instead of subscriptions?"**

With subscriptions you limit the amount of requests as well as avoid getting [rate limited](#rate-limit). Also, you get the info you need in a more timely manner which makes it easier for you to provide a great user experience!

## Mutations

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
mutation {
  setVolume(input: {soundZone:"soundzone_id", volume: 11}) {
      volume
  }
}
'
```

> Response

```json
{
  "data": {
    "setVolume": {
      "volume": 11
    }
  }
}
```

Use mutations to make changes. For example: change the volume, skip track and play/pause.

All mutations can be found in the [reference](https://developer.soundtrackyourbrand.com/api/reference/rootmutationtype.doc.html).

In this example you set the volume to 11 on a specific sound zone. You always need to ask for a response, so in this case we just ask for the volume.

# Errors

> Incorrect input (an account id that doesn't exist)

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  account(id:"QWNjb3VudCwsWNheXg3dTc1Nm8v") {
    businessName
  }
}
'
```

> Response (HTTP `200 OK`)

```json
{
  "errors": [
    {
      "path": [
        "account"
      ],
      "message": "Forbidden",
      "locations": [
        {
          "line": 2,
          "column": 0
        }
      ]
    }
  ],
  "data": {
    "account": null
  }
}
```

With GraphQL, a HTTP code stating `200 OK` doesn't always mean that you get the data you wanted. If the query executes but bumps into an error along the way, you'll get a `200` with an `errors`-object appended to the response body.

Error | Description | Example
---------- | ------- | -------
HTTP `5xx` or WebSocket `1xxx` | Server problems | e.g. server not available
HTTP `4xx` | Client problems | e.g. rate limited
HTTP `200` with `errors`-body | GraphQL problems | e.g. incorrect input

<aside class="notice">
Did you get an error message that you think could be improved? Please <a href="https://join.slack.com/t/soundtrack-api/shared_invite/enQtNDMwMjY0Mzg2ODk2LTk0YWI4MjBmNzJiODg4MDFiZmYxYmI0NDk3ZmRiN2FlYjUyMGFmNTAxZjZhMjhhNmMzNmRlYmM4YjNkNDhjMDkg">reach out on Slack</a> and let us know.
</aside>

# Rate limit

> Please note that the rate limit is subject to change since we continuously monitor how the API is used and make relevant updates.

The Soundtrack API enforces rate limiting. You start off with the maximum amount of tokens (18000) and for every call (query, mutation or subscription) you make, tokens will be deducted.

The number of tokens deducted depends on the complexity of the call you are making. But we don’t just take tokens from you - every second you get 5 tokens back.

Let’s say you make a query with a complexity of 100. Now you’re down to 17900. After 20 seconds you’re back to 18000 tokens (5 tokens per second). Simple, right?

## Queries & Mutations

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  account(id:"account_id") {
    businessName

    locations(first: 10) {
      edges {
        location: node {
          soundZones(first: 10) {
            edges {
              node {
                device {
                  id
                }
              }
            }
          }
        }
      }
    }
  }
}
'
```

Queries and mutations calculates the rate limit in the same way. Keep scrolling to understand how we rate limit subscriptions.

In this section's example you’re fetching the device information from the first ten sound zones for each of the first ten locations on a single account. In the same call, you’re also fetching the now playing information form one sound zone. Here’s how we calculate:

 | Cost
---------- | -------
accounts | 1
locations | 10
soundzones | 100 (10 sound zones on 10 locations)
device | 100 (10 devices on 10 sound zones)
**total** | **211**

A request’s cost is deducted from your tokens. **The cost is calculated based on the query, and not the data it would return if it were to execute**.

In the example above, even if each location only had one single sound zone, the cost for the sound zones would still be 100 (instead of 10). This means you should try to be conservative with how much data you ask for in deeply nested connections in order to preserve your tokens.

### "But I don't want to calculate!"

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  queryInfo {
    complexity
  }
  account(id:"account_id") {
    businessName
  }
}
'
```

> Response

```json
{
  "data": {
    "queryInfo": {
      "complexity": 1
    },
    "account": {
      "businessName": "The Halloumi Burger Joints"
    }
  }
}
```

Just append `queryInfo` to your query and we'll do the calculation for you (we currently don't have this for mutations nor subscriptions).

## Subscriptions

The maximum complexity of a subscription is 100.

# Explore

The best way to explore (and, in our opinion, the best documentation too!) is [our playground](https://api.soundtrackyourbrand.com/v2/explore).

Once you’ve added your Authorization header you can use it to create and run queries towards the Soundtrack API. There are documentation and auto-completion features.

Please keep in mind that all queries use live data and count towards your rate limit.

# Example app

> Find the example app [in this repo](https://github.com/soundtrackyourbrand/soundtrack_api-example_app). Feel free to contribute.

To get you started we’ve implemented a simple react-relay app. We’ve decided to create a frontend app since it is easy for you to get up and running locally. However, we strongly encourage you to not build a frontend application where the API client secret can be found in the source code.

Secrets found in public applications will be blocked. What you probably want to do is to build a backend service that implements whatever authentication layer that your app needs.

# Terms of use
> Read and comply to our [API Terms of Use](https://www.soundtrackyourbrand.com/legal/api-terms-of-use)

By using the Soundtrack API, you accept to our [API Terms of Use](https://www.soundtrackyourbrand.com/legal/api-terms-of-use). Please note that it should be clear to the end user that you are the one that has built and is maintaining the application. Using Soundtrack marketing material (except artwork provided via the API) needs Soundtrack Your Brand’s written consent. For example, you are not allowed to use our graphics (e.g. buttons) used in our products to create a similar experience.

Due to licensing restrictions, visitors are currently not allowed to control playback. For example, you are allowed to build an application where your authorized staff changes the playlist but the same functionality can’t be exposed to your visitors. Sharing track name, sharing url, etc. is however fine as this is regarded as non-interactive.

# Next level

Want to shape up your queries or just read more about a specific topic? We've gathered some good-to-knows here.

## GraphQL
The API is built using GraphQL, abiding by the [Relay Connection Specification](https://facebook.github.io/relay/graphql/connections.htm) in order to make it as easy as possible to use third party libraries, such as Relay or Apollo.

### What is GraphQL?

GraphQL is a query language for APIs. It describes the API as a graph of connected objects which can be queried with a single request. A single query can load data from multiple, deeply nested entities that would normally require multiple chained requests in a REST API.

This makes it easier for you as an application developer to get the data you need, but also improves performance since it minimises the number of requests you need to make.

GraphQL is an API query layer. This means that all queries you run is defined by the API in beforehand. You cannot select data based on any criteria you want, in contrast with other query languages such as SQL.

GraphQL is also an open standard with multiple server and client libraries, which makes it easy to get an application scaffold up and running.

Subscriptions in the Soundtrack API is powered by the [Phoenix framework](https://phoenixframework.org/). An implementation of this protocol can be found [here](https://github.com/absinthe-graphql/absinthe-socket/tree/master/packages/socket). Here are two noteworthy articles on subscriptions in GraphQL: [Subscriptions in GraphQL and Relay](http://graphql.org/blog/subscriptions-in-graphql-and-relay/) & [Javascript docs](https://hexdocs.pm/phoenix/js/).

### Why GraphQL?

Here are some of the reasons why we chose GraphQL:

- Being able to query for the exact data that you need makes it easier to quickly get up and running. And greatly improves the performance.

- GraphQL is strongly typed and has very good introspection features, which enables very good tooling for both exploring and using the API.

- There are good client libraries as well as IDE support.

- The ability to join multiple queries together is a big performance improvement.

### Libraries
If you’re building a backend implementation, all you need is an HTTP client and a JSON parser. If you’re building something for the frontend, Relay and Apollo are popular choices. Just make sure you don’t expose your API Credentials by accident (if we find any exposed credentials, we will revoke them).

### Additional reading

- [GraphQL’s official site](http://graphql.org/)

- [GraphQL Specification](http://facebook.github.io/graphql/October2016/)

- [How to GraphQL](https://www.howtographql.com/)

- [Relay Connection Specification](https://facebook.github.io/relay/graphql/connections.htm)

- There are many good talks on GraphQL on [YouTube](https://www.youtube.com/results?search_query=graphql)

## Introspection

Here's a good read on [introspection in GraphQL](https://graphql.org/learn/introspection/).

## Connections

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  node(id: "track_id") {
    ...on Track {
      name
      previewUrl
    }
  }
}
'
```

Every one to many relationship is modelled using a concept of connections, edges and nodes. This is according to [Relay’s Connection Specification](https://facebook.github.io/relay/graphql/connections.htm) and allows every such relationship to be paginated in a consistent manner.

### Node queries

Most of the central entities (account, sound zones, now playing) have specific top-level queries to find them by id.

For many other entities, you can use the more general `node` query to get a specific entity, should you need it. Use the [playground](https://api.soundtrackyourbrand.com/v2/explore) to see what entities implement the node interface (or see the [reference](https://developer.soundtrackyourbrand.com/api/reference/node.doc.html)).


> Pagination: first query

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  account(id: "account_id") {
    access {
      users(first: 5) {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          role
          node {
            name
            id
          }
        }
      }
    }
  }
}
'
```

> Pagination: second query

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
query {
  account(id: "account_id") {
    access {
      users(first: 5 after: "endCursor") {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          role
          node {
            name
            id
          }
        }
      }
    }
  }
}
'
```

### Pagination

You call the connection describing for example how many results you want and from what page, and then you go through the connection’s edges and get each node. The edge contains metadata about the relationship from the parent to the node, such as a user's role.

The first query would get the first five users who has access to the account. To get the next page, use the `endCursor` on the `pageInfo` as a cursor to the next query.

## Parameterised queries

> The JSON payload is as follows:

```json
{
    "query": "query",
    "parameters": {"parameter1": "value1"},
    "operationName": "only needed if the query has multiple operations"
}
```

> For example:

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/json' \
-d '
{
    "query": "query($id: ID!) { soundZone(id: $id) { name } }",
    "variables": { "id": "soundzone_id" }
}
'
```

> A more complex example:

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/json' \
-d '
{
    "query": "query soundZone($id: ID!) { soundZone(id: $id) { name } } query account($id: ID!) { account(id: $id) { businessName } }",
    "variables": { "id": "soundzone_id" },
    "operationName": "soundZone"
}
'
```

In production, we recommend that you use parameterised queries. It decreases the risk for injections and you'll be able to re-use more code.

In order to use parameterised queries, the API expects the `Content-Type` to be `application/json`.

## Fragments & multiple queries

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Authorization: Basic your_token' \
-H 'Content-Type: application/graphql' \
-d '
fragment nowPlayingFields on NowPlaying {
  startedAt
    track {
      name
      artists {
        name
      }
      album {
        image {
          url
          width
          height
        }
      }
    }
}

query {
  nowPlaying1: nowPlaying(soundZone: "soundzone_id_1") {
    ...nowPlayingFields
  }

  nowPlaying2: nowPlaying(soundZone: "soundzone_id_2") {
    ...nowPlayingFields
  }
}
'
```

This example combines multiple queries into a single query. This can be done for all GraphQL you want to run (as long as they are independent from each other) in order to save round trips. It also shows how you can use [GraphQL fragments](http://graphql.org/learn/queries/#fragments) to reduce the amount of boilerplate in your queries.

## Authorizing as a user

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Content-Type: application/graphql' \
-d '
mutation {
  loginUser(input: {email: "your_email", password: "your_password"}) {
    token
    refreshToken
  }
}
'
```

If you want to, you can skip asking for API client credentials and just get a token using your existing Soundtrack-credentials, using the `loginUser`-mutation. For the `loginUser`-mutation you (obviously...) don't need an authorization-header.

The response will contain two tokens:

* `token` is your access token which you will use in your other API calls (e.g. when making queries).
* `refreshToken` is used for obtaining a new `token`. We'll get back to this in a bit.

Note that since you're not logging in as an API client, you can't use `...on PublicAPIClient` in your `me`-query ([this example](#asking-what-you-don-39-t-know)). Instead, use `...on User`.

> If you use this way of authorizing, use `Bearer` and not `Basic`

```shell
-H 'Authorization: Bearer your_token'
```

### Using `token`
You use the access `token` in the same way as already described in these docs, except that you should use `Bearer` instead of `Basic` in your authorization header (for [subscriptions](#subscriptions): as a query parameter)

The token won't be valid forever. That's why you need to use your `refreshToken` as soon as you get `HTTP 401` on your requests.

### Using `refreshToken`

```shell
curl -XPOST https://api.soundtrackyourbrand.com/v2 \
-H 'Content-Type: application/graphql' \
-d '
mutation{
  refreshLogin(input:{refreshToken: "your_refresh_token"}){
    token
    refreshToken
  }
}
'
```

The `refreshToken` will enable you to fetch a new access `token`. Once you get the response, replace your old `token` with the new one.

Always make it a habit to request the `refreshToken` as well, since it also can change.

If your `refreshToken` is outdated (your app might have been offline), remember that you always can use the `loginUser`-mutation to get a new one.
