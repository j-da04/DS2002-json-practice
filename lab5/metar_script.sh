#!/bin/bash

# Fetch METAR data from NOAA
curl -s "https://aviationweather.gov/api/data/metar?ids=KMCI&format=json&taf=false&hours=12&bbox=40%2C-90%2C45%2C-85" -o aviation.json

# Print the first 6 receiptTime values
echo "Timestamps:"
jq -r '.[].receiptTime' aviation.json | head -n 6

# Calculate the average temperature, excluding null values
temps=$(jq -r '.[].temp // empty' aviation.json)
sum=0
count=0

for t in $temps; do
  sum=$(awk "BEGIN {print $sum + $t}")
  count=$((count + 1))
done

if [ "$count" -gt 0 ]; then
  avg=$(awk "BEGIN {print $sum / $count}")
  echo "Average Temperature: $avg°C"
else
  echo "Average Temperature: N/A"
fi

# Check for cloudiness (if more than half the entries are not clear)
cloudy_count=$(jq -r '.[] | select(.clouds[].cover != "CLR") | .clouds[].cover' aviation.json | wc -l)
total_entries=$(jq length aviation.json)
half=$((total_entries / 2))

if [ "$cloudy_count" -gt "$half" ]; then
  echo "Mostly Cloudy: true"
else
  echo "Mostly Cloudy: false"
fi
