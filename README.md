# LINDAS Triplestore Benchmark

Welcome to the LINDAS Triplestore Benchmark repository!

This repository has been built by Zazuko GmbH on mandate of the Swiss Federal Archives with the aim of comparing the performance of different triplestores.
A series of SPARQL queries were extracted from the Swiss government SPARQL endpoint, LINDAS, to constitute the benchmarking testbed.


## Baseline Comparison

A benchmark results file run on the LINDAS endpoint using the Stardog&reg; triplestore is provided as a baseline for comparison.

## Requirements

Ensure you have the following prerequisites ready:

- [k6](https://k6.io/docs/get-started/installation/)
- A snapshot of the LINDAS dataset, which you can download [here](https://bar-files.opendata.swiss/owncloud/index.php/s/S9iryd7DYLe2kQz).
  The dataset is approximately 2.3 GB compressed and 60GB uncompressed.
- A triplestore that you wish to test against.
- The above referenced dataset uploaded into the triplestore.

We use [k6](https://k6.io/) to benchmark the queries.
We also provide a quick way to check if the triplestore is compliant with the queries that are run against LINDAS.

## Quick Start

All SPARQL queries that are used in the differents tests are stored in the `queries` folder.

<!---
In case you add/remove/rename a query, you need to update the `query-files.json` file, by running the following command:

```sh
./scripts/update-query-list.sh
```
--->

In case you want to know the query file from an ID shown in the results, you can run the following command:

```sh
jq -r '.[x,y,z]' query-files.json
```

by replacing `x`, `y`, and `z` by the IDs you want to know the query file.
You can specify as many IDs as you want.

### Conformity Test

Check that your triplestore is able to support some common queries against the LINDAS dataset:

```sh
k6 run \
  -e SPARQL_ENDPOINT=https://example.com/query \
  -e SPARQL_USERNAME=user \
  -e SPARQL_PASSWORD=secret \
  lindas-conformity.js
```

The query timeout is set to 5min.
The script has a limit of 1 day to run.

This will run the queries against the triplestore and check if they are able to return a result.
The results are stored in a file `./results/summary-conformity.json`.

And to inspect results in a human-readable format, run the following command (`jq` is required):

```sh
./scripts/summary-conformity-simple.sh
```

### Benchmark

Run the benchmark against your triplestore:

```sh
k6 run \
  -e SPARQL_ENDPOINT=https://example.com/query \
  -e SPARQL_USERNAME=user \
  -e SPARQL_PASSWORD=secret \
  lindas-benchmark.js
```

In case you want to run the benchmark on some specific queries (it can be useful in order to check that it can hit your endpoint as expected), you can add those parameters:

- `-e START=0`: The index of the first query to run (default: `0`)
- `-e END=801`: The index of the last query to run (default: `801`)

The index starts at `0`.

The query timeout is set to 2min30s.

It will run 10 virtual users, that will run the maximum number of queries they can against the triplestore during 120s, and this for each query.

The results are stored in a file `./results/summary-benchmark-YYYY-MM-DDTHH-MM-SS.json`.

To inspect the results in a human-readable format, run the following command (`jq` is required):

```sh
./scripts/summary-benchmark.sh ./results/summary-benchmark-YYYY-MM-DDTHH-MM-SS.json
```

by updating the path to the JSON file you want to inspect.

## Graphical results rendering

By using [Gitpod](https://gitpod.io/?autostart=true&editor=code#https://github.com/SwissFederalArchives/lindas-benchmark), the benchmark results can be graphically summarized by running `benchmark-analysis.ipynb`

<!--- [![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/?autostart=true&editor=code#https://github.com/zazuko/lindas-benchmark) --->

