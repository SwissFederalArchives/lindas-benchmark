#!/bin/sh

# JSON results file
input_json="$1"
if [ -z "${input_json}" ]; then
  echo "Usage: $0 <results-json-file-path>"
  exit 1
fi

# Extract and print query information
jq -r '
  .root_group.groups[] as $group |
  ($group.name | split("#")[1]) as $query_number |
  ($group.checks[0].passes | tostring) as $passes |
  ($group.checks[0].fails | tostring) as $fails |
  "Query " + $query_number + ": \n  - " +
  $passes + "/" +
  (($passes | tonumber) + ($fails | tonumber) | tostring) + " passes (" +
  $fails + " failed)\n" +
  "  - avg: " + (.metrics["query_" + $query_number + "_duration"].values.avg | tostring) + " ms\n" +
  "  - min: " + (.metrics["query_" + $query_number + "_duration"].values.min | tostring) + " ms\n" +
  "  - med: " + (.metrics["query_" + $query_number + "_duration"].values.med | tostring) + " ms\n" +
  "  - max: " + (.metrics["query_" + $query_number + "_duration"].values.max | tostring) + " ms\n" +
  "  - p(90): " + (.metrics["query_" + $query_number + "_duration"].values["p(90)"] | tostring) + " ms\n" +
  "  - p(95): " + (.metrics["query_" + $query_number + "_duration"].values["p(95)"] | tostring) + " ms\n"
' "$input_json"

# Extract total information
total_queries=$(jq '.root_group.groups | length' "$input_json")
total_passes=$(jq '[.root_group.groups[].checks[0].passes] | add' "$input_json")
total_fails=$(jq '[.root_group.groups[].checks[0].fails] | add' "$input_json")
total_duration=$(jq '.state.testRunDurationMs' "$input_json")

echo
echo "TOTAL:"
echo "  - $total_queries queries ($total_passes passes, $total_fails failed)"
echo "  - $total_duration ms total duration time"
