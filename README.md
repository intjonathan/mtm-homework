# Metronome Take-home Code Screen

## Problem Statement
Attached, find the file `events.csv`, which contains a log of events with the
the format `customer_id, event_type, transaction_id, timestamp`.

Your task is to write a program that answers the following question:

> How many events did customer X send in the one hour buckets between timestamps A and B?

Choice of language, platform, and libraries is left up to you, as long as the
person evaluating your submission doesn't have to think too hard to figure out
how to run it. We all use recent macOS with recent Docker.

We expect this exercise to take 1-3 hours.

*Bonus:* Include an HTTP service that answers the same question.

## Usage

You may run the enclosed container directly from Docker hub:

`docker run -ti intjonathan/mtm-homework`

(See the [hub image page](https://hub.docker.com/r/intjonathan/mtm_homework) if needed.)

Or you may build locally:

`docker build -t intjonathan/mtm-homework . && docker run -ti intjonathan/mtm-homework`

From within the container shell, run:

`$ ./totaler.rb account_event_totals_1h`

This will emit help text. An example invocation would emit:

```bash

$ ./totaler.rb account_event_totals_1h events.csv 2021-03-01T04:00:00Z 2021-03-01T06:30:00Z
Input file: events.csv
Start time: 2021-03-01 04:00:00 UTC
End time: 2021-03-01 06:30:00 UTC

Timebucket: 2021-03-01 04:00:00 +0000
Customer ID: 30330c9c4e7173ba9474c46ee5191570 Calls: 36
Customer ID: b4f9279a0196e40632e947dd1a88e857 Calls: 408
Customer ID: 1abb42414607955dbf6088b99f837d8f Calls: 2
Customer ID: 009b178fa33bd5d0459d8b2cb825f9f4 Calls: 8

Timebucket: 2021-03-01 05:00:00 +0000
Customer ID: b4f9279a0196e40632e947dd1a88e857 Calls: 1133
Customer ID: 30330c9c4e7173ba9474c46ee5191570 Calls: 9
Customer ID: 009b178fa33bd5d0459d8b2cb825f9f4 Calls: 8

Timebucket: 2021-03-01 06:00:00 +0000
Customer ID: b4f9279a0196e40632e947dd1a88e857 Calls: 769
Customer ID: 30330c9c4e7173ba9474c46ee5191570 Calls: 9
Customer ID: 009b178fa33bd5d0459d8b2cb825f9f4 Calls: 8

```

Adding a truthy argument ('1', or 'true') to the end will emit json. The same invocation as above with that argument change would produce:

```json
{
  "2021-03-01 04:00:00 +0000": {
    "30330c9c4e7173ba9474c46ee5191570": 36,
    "b4f9279a0196e40632e947dd1a88e857": 408,
    "1abb42414607955dbf6088b99f837d8f": 2,
    "009b178fa33bd5d0459d8b2cb825f9f4": 8
  },
  "2021-03-01 05:00:00 +0000": {
    "b4f9279a0196e40632e947dd1a88e857": 1133,
    "30330c9c4e7173ba9474c46ee5191570": 9,
    "009b178fa33bd5d0459d8b2cb825f9f4": 8
  },
  "2021-03-01 06:00:00 +0000": {
    "b4f9279a0196e40632e947dd1a88e857": 769,
    "30330c9c4e7173ba9474c46ee5191570": 9,
    "009b178fa33bd5d0459d8b2cb825f9f4": 8
  }
}
```

## Aggregation Notes

Partial hours are not called out - if you ask for mid-hour boundaries, events will only be summed up to the second of start or end time. 

Events are considered part of the bucket at the beginning of the hour up to 59 seconds before the following. This forms a half-open interval, closed on the front side, like `[start_time, end_time)`.