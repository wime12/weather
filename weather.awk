#!/usr/bin/awk -f /home/wilfried/.awklib/getxml.awk -f

BEGIN {
  while (getXML(ARGV[1], 1)) {
    if (XTYPE == "TAG" && XITEM ~ /^yweather:/) {
      tagName = XITEM;
      sub(/^yweather:/, "", tagName);
      if (tagName == "forecast") {
	forecast += 1;
	for (attributeName in XATTR)
	  data[tagName,forecast,attributeName] = XATTR[attributeName];
      } else
	  for (attributeName in XATTR)
	    data[tagName,attributeName] = XATTR[attributeName];
    }
    if (XERROR) {
      print "Parsing error"
      exit 1
    }
  }

  printf("Weather report for %s, %s, %s:\n", data["location", "city"],
	 data["location", "country"], data["condition", "date"])
  printf("Condition:\t%s °%s, %s\n", data["condition", "temp"], data["units", "temperature"],
	 data["condition", "text"])
  printf("Wind:\t\t%s %s %s, %s °%s\n", data["wind", "speed"], data["units", "speed"],
	 wind_direction(data["wind", "direction"]), data["wind", "chill"],
	 data["units", "temperature"])
  printf("Atmosphere:\t%s%%, %s %s %s\n", data["atmosphere", "humidity"],
	 data["atmosphere", "pressure"], data["units", "pressure"],
	 pressure_direction(data["atmosphere", "rising"]))
  printf("Sun:\t\t%s - %s\n", data["astronomy", "sunrise"], data["astronomy", "sunset"])
  printf("Forecast:\n")
  for (i = 1; i <= 5; i++) {
    printf("\t%s, %s: %s °%s - %s °%s, %s\n",
	   data["forecast", i, "day"], data["forecast_" i, "date"],
	   data["forecast", i, "low"], data["units", "temperature"],
	   data["forecast", i, "high"], data["units", "temperature"],
	   data["forecast", i, "text"])
  }
}

function pressure_direction(n) {
  if (n == 0) return "steady"
  else
    if (n == 1) return "falling"
  else
    if (n == 2) return "rising"
}

function wind_direction(n) {
  if      ((  0    <= n) && (n <  11.25)) return "N"
  else if (( 11.25 <= n) && (n <  33.75)) return "NNE"
  else if (( 33.75 <= n) && (n <  56.25)) return "NE"
  else if (( 56.25 <= n) && (n <  78.75)) return "ENE"
  else if (( 78.75 <= n) && (n < 101.25)) return "E"
  else if ((101.25 <= n) && (n < 123.75)) return "ESE"
  else if ((123.75 <= n) && (n < 146.25)) return "SE"
  else if ((146.25 <= n) && (n < 168.75)) return "SSE"
  else if ((168.75 <= n) && (n < 191.25)) return "S"
  else if ((191.25 <= n) && (n < 213.75)) return "SSW"
  else if ((213.75 <= n) && (n < 236.25)) return "SW"
  else if ((236.25 <= n) && (n < 258.75)) return "WSW"
  else if ((258.75 <= n) && (n < 281.25)) return "W"
  else if ((281.25 <= n) && (n < 303.75)) return "WNW"
  else if ((303.75 <= n) && (n < 326.25)) return "NW"
  else if ((326.25 <= n) && (n < 348.75)) return "NNW"
  else if ((348.75 <= n) && (n <= 360))   return "N"
}
