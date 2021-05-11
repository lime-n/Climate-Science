getNcTime <- function(nc) {
  require(lubridate)
  ncdims <- names(nc$dim) #get netcdf dimensions
  timevar <- ncdims[which(ncdims %in% c("time", "Time", "datetime", "Datetime", "date", "Date"))[1]] #find time variable
  times <- ncvar_get(nc, timevar)
  if (length(timevar)==0) stop("ERROR! Could not identify the correct time variable")
  timeatt <- ncatt_get(nc, timevar) #get attributes
  timedef <- strsplit(timeatt$units, " ")[[1]]
  timeunit <- timedef[1]
  tz <- timedef[5]
  timestart <- strsplit(timedef[4], ":")[[1]]
  if (length(timestart) != 3 || timestart[1] > 24 || timestart[2] > 60 || timestart[3] > 60 || any(timestart < 0)) {
    cat("Warning:", timestart, "not a valid start time. Assuming 00:00:00\n")
    warning(paste("Warning:", timestart, "not a valid start time. Assuming 00:00:00\n"))
    timedef[4] <- "00:00:00"
  }
  if (! tz %in% OlsonNames()) {
    cat("Warning:", tz, "not a valid timezone. Assuming UTC\n")
    warning(paste("Warning:", timestart, "not a valid start time. Assuming 00:00:00\n"))
    tz <- "UTC"
  }
  timestart <- ymd_hms(paste(timedef[3], timedef[4]), tz=tz)
  f <- switch(tolower(timeunit), #Find the correct lubridate time function based on the unit
              seconds=seconds, second=seconds, sec=seconds,
              minutes=minutes, minute=minutes, min=minutes,
              hours=hours,     hour=hours,     h=hours,
              days=days,       day=days,       d=days,
              months=months,   month=months,   m=months,
              years=years,     year=years,     yr=years,
              NA
  )
  suppressWarnings(if (is.na(f)) stop("Could not understand the time unit format"))
  timestart + f(times)
}
