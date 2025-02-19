# clean workspace
rm(list = ls())

# data download
dataURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"

if(!file.exists("activity.csv")){
  temp_zipfile <- tempfile()
  download.file(dataURL, destfile = temp_zipfile, method = "curl")
  unzip(temp_zipfile)
  unlink(temp_zipfile)
}

# Load Data
activitydata <- read.csv("activity.csv")

# Change date to Date variable
activitydata$date <- as.Date(activitydata$date, "%Y-%m-%d")

# What is mean total number of steps taken per day?
# Total steps variable
total.stepsbyday <- aggregate(steps ~ date, data = activitydata, FUN = sum, na.rm = TRUE)

# Plot of Total Number of Steps Taken by Day
barplot(total.stepsbyday$steps, col = "grey", xlab = "Days", ylab = "Steps by Day", main = "Total Number of Steps Taken by Day")

# Histogram - stored for future use
histogram1 <- hist(total.stepsbyday$steps, col = "grey", ylim = c(0,30), xlab = "Total Steps per Day", main = "Total Steps by Day Histogram")

grid()
text(x = histogram1$mids, y = histogram1$counts, labels = histogram1$counts, pos = 3, cex = 1, col = "black")

# Calculate and report the mean and median of the total number of steps taken per day
mean.totalsteps <- mean(total.stepsbyday$steps)
median.totalsteps <- median(total.stepsbyday$steps)

# What is the average daily activity pattern?
# Time series plot
par(mar=c(5.1,4.1,5.2,2.1))
ts.avgsteps <- aggregate(steps ~ interval, data = activitydata, mean, na.rm = TRUE)

plot(steps ~ interval, data = ts.avgsteps, type = "l", col= "blue3", xlab = "5 minute interval", ylab = "Average Steps", main = "Average Number of Steps by Interval")
grid()

# Which 5 minute interval, on average across all days in the dataset, contains the maximum number of steps?
maxsteps <- max(ts.avgsteps$steps)
maxsteps.interval <- ts.avgsteps[which.max(ts.avgsteps$steps),1]

# Imputing Missing Values
NA_value <- sum(is.na(activitydata))

# Mean Imputation
# Split NA out of dataset
NAsubset <- activitydata[is.na(activitydata$steps),]
NotNAsubset <- activitydata[!is.na(activitydata$steps),]

# Replace missing values with mean for steps per interval
for (i in ts.avgsteps) { NAsubset$steps[NAsubset$interval == i] <- ts.avgsteps$steps[ts.avgsteps$interval ==i]
}

# merge datasets together
library(dplyr)
activitydata.imputed <- rbind(NAsubset, NotNAsubset)
activitydata.imputed <- arrange(activitydata.imputed, date, interval)

# Histogram of Number of Steps per Day with Imputed Data and calculate and repot mean and median total number of steps per day. 
total.stepsbyday2 <- aggregate(steps ~ date, data = activitydata.imputed, FUN = sum)

mean.totalsteps2 <- mean(total.stepsbyday2$steps)
median.totalsteps2 <- median(total.stepsbyday2$steps)

# Histogram Display
par(mfrow = c(1,2), oma = c(0,0,2,0))

plot(histogram1, col = "grey", ylim = c(0,40), xlab = "Total Steps per Day", main = "(NA Removed")
grid()
text(x = histogram1$mids, y=histogram1$counts, labels = histogram1$counts, pos = 3, cex = 1, col = "black")

histogram2 <- hist(total.stepsbyday2$steps, col = "grey", ylim = c(0,40), xlab = "Total Steps per Day", main = "(NA Imputed")
grid()
text(x = histogram2$mids, y = histogram2$counts, labels = histogram2$counts, pos = 3, cex = 1, col = "black")

mtext("Total Number of Steps Taken per Day", outer = TRUE)

# Are there differences in patterns between weekdays and weekends?
Sys.setlocale(category = "LC_TIME", locale = foo)

activitydata.imputed$day <- ifelse(weekdays(activitydata.imputed$date, abbreviate = TRUE) == "Sat" | weekdays(activitydata.imputed$date, abbreviate = TRUE) == "Sun", "weekend", "weekday")
activitydata.imputed$day <- as.factor(activitydata.imputed$day)

library(lattice)

ts.avgsteps.week <- aggregate(steps ~ interval + day, data = activitydata.imputed, FUN = mean)

xyplot(steps ~ interval | day, data = ts.avgsteps.week, type = c("l", "g"), layout = c(1,2))
