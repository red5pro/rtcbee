# RTC Bee
The RTC Bee is a command-line program that runs a subscription "attack" on a server. One *RTC Bee* can have N *Bullets* (or stingers) that are fired concurrently.

* [Requirements](#build-requirements)
* [Building](#building)
* [Attacking](#attacking)
* [Notes](#notes)

# Requirements

## CLI

For the command-line based scripts, the following is required:

* chromium-browser
* python 2.7

### chromium-browser

To install the `chromium-browser`:

```sh
$ apt-get install -y chromium-browser
```

# Building

The current implementations are the command line scripts available in the [script](script) directory. There is no building necessary.

> Note: The original intent was to have the RTC Bee be Java-based just as the other bees (RTMPBee and RTSPBee) are. However, `chromedriver` seemed to occasionally be swallowed or lost when deployed on an AWS EC2 instance (which is the desired deploy for bees). As such, the work on the Java-based version has been halted as of January 28th, 2018.

# Attacking

* [Basic Subscription](#basic-subscription)
* [Stream Manager Subscription](#stream-manager-subscription)

## Basic Subscription

```sh
$ cd script
$ ./rtcbee.sh [viewer.jsp endpoint] [amount of streams to start] [amount of time to playback]
```

### Options

#### endpoint

The endpoint of the `viewer.jsp` page to subscribe to a stream. The `viewer.jsp` page is provided by default with the `live` webapp of the Red5 Pro Server distribution.

#### amount

The amount of bullets (stingers, a.k.a. stream connections) for the bee to have in the attack.

#### timeout

The amount of time to subscribe to stream. _The actual subscription time may differ from this amount. This is really the time lapse of start of subscription until end._

#### Example

```sh
$ ./rtcbee.sh "https://your.red5pro-deploy.com/live/viewer.jsp?host=your.red5pro-deploy.com&stream=streamname" 10 10
```

## Stream Manager Subscription

```sh
$ cd script
$ ./rtcbee_sm.sh [stream-manager subscribe API endpoint] [app context] [stream name] [amount of streams to start] [amount of time to playback]
```

### Options

#### stream-manager API endpoint

The API request endpoint that will return Edge server information.

#### context

The webapp context name that the stream would be available in at the edge IP returned.

#### stream name

The stream name to subscribe to at the edge IP returned.

#### timeout

The amount of time to subscribe to stream. _The actual subscription time may differ from this amount. This is really the time lapse of start of subscription until end._

#### Example

```sh
$ ./rtcbee_sm.sh "https://stream-manager.url/streammanager/api/2.0/event/live/streamname?action=subscribe" live todd 10 10
```

