# Run first !!!!!!!!!! 
library(geometry)
#library(sf)
#library(concaveman)
library(readxl)
library(matlab)
library(pracma)
library(dismo)

# Load data 
rm(list=ls())
my_data <- read_excel(file.choose())
mm = matrix(0, max(my_data$t), max(my_data$d) * 2)

# Adjust tracking to reference and re arrange the data table
m = 1
for (n in 1:(size(mm,2)/2)) {
  mm[my_data$t[my_data$d == n], m] = my_data$x[my_data$d == n]
  mm[my_data$t[my_data$d == n], m + 1] = my_data$y[my_data$d == n]
  m = m + 2
}

nnn = mm[, colSums(mm != 0) > 0]
nnn[nnn == 0] = NA

oddvals <- seq(1, ncol(nnn), by = 2)
even = seq(2, ncol(nnn), by = 2)

nnn[, oddvals] = nnn[, oddvals] - nnn[, 1]
nnn[, even] = nnn[, even] - nnn[, 2]
# nnn[, 1] = NULL
nn = subset(nnn, select = -c(1:2))

# Plotting trajectories
plot(
  nn[, 1],
  nn[, 2],
  type = "l",
  col = 1,
  xlim = c(-40, 30),
  ylim = c(-40, 30),
  asp = 1
)

xxx = zeros(size(nn,1), 2)
xxx[, 1] = nn[, 1]
xxx[, 2] = nn[, 2]
xxx = na.omit(xxx)

area = zeros(size(nn, 2) / 2, 1)
skip_to_next <- FALSE
messaage="one was a problematic guy thank you my love"
tryCatch(convHull(xxx), error = function(e) { skip_to_next <<- TRUE})
if(skip_to_next) {  
  area[n, 1] = NA
  print(messaage)
} else {
  polygons <- convHull(xxx)
  area[1, 1] = polygons@polygons@polygons[[1]]@Polygons[[1]]@area * 107.8^2
  # Comment below to remove the borders
  # lines(polygons@polygons@polygons[[1]]@Polygons[[1]]@coords, col = n, lwd = 2)
}

# lines(polygons, col = 1, lwd = 2)

m = 3
for (n in 2:(size(nn, 2) / 2)) {
  xxx = zeros(size(nn,1), 2)
  lines(nn[, m], nn[, m + 1], col = n)
  
  xxx[, 1] = nn[, m]
  xxx[, 2] = nn[, m + 1]
  xxx = na.omit(xxx)
  
  skip_to_next <- FALSE
  tryCatch(convHull(xxx), error = function(e) { skip_to_next <<- TRUE})
  if(skip_to_next) {  
    area[n, 1] = NA
    print(messaage)
  } else {
    polygons <- convHull(xxx)
    area[n, 1] = polygons@polygons@polygons[[1]]@Polygons[[1]]@area * 107.8^2
    # Comment below to remove the borders
    # lines(polygons@polygons@polygons[[1]]@Polygons[[1]]@coords, col = n, lwd = 2)
  }
  
  m = m + 2
}

# Plotting trajectories with lines
plot(
  nn[, 1],
  nn[, 2],
  type = "l",
  col = 1,
  xlim = c(-40, 30),
  ylim = c(-40, 30),
  asp = 1
)

xxx = zeros(size(nn,1), 2)
xxx[, 1] = nn[, 1]
xxx[, 2] = nn[, 2]
xxx = na.omit(xxx)

area = zeros(size(nn, 2) / 2, 1)
skip_to_next <- FALSE
tryCatch(convHull(xxx), error = function(e) { skip_to_next <<- TRUE})
if(skip_to_next) {  
  area[n, 1] = NA
} else {
  polygons <- convHull(xxx)
  area[1, 1] = polygons@polygons@polygons[[1]]@Polygons[[1]]@area * 107.8^2
  # Comment below to remove the borders
  lines(polygons@polygons@polygons[[1]]@Polygons[[1]]@coords, col = n, lwd = 2)
}

# lines(polygons, col = 1, lwd = 2)

m = 3
for (n in 2:(size(nn, 2) / 2)) {
  xxx = zeros(size(nn,1), 2)
  lines(nn[, m], nn[, m + 1], col = n)
  
  xxx[, 1] = nn[, m]
  xxx[, 2] = nn[, m + 1]
  xxx = na.omit(xxx)
  
  skip_to_next <- FALSE
  tryCatch(convHull(xxx), error = function(e) { skip_to_next <<- TRUE})
  if(skip_to_next) {  
    area[n, 1] = NA
  } else {
    polygons <- convHull(xxx)
    area[n, 1] = polygons@polygons@polygons[[1]]@Polygons[[1]]@area * 107.8^2
    # Comment below to remove the borders
    lines(polygons@polygons@polygons[[1]]@Polygons[[1]]@coords, col = n, lwd = 2)
  }
  
  m = m + 2
}

# Compute speed of aggregates
speed = zeros(size(nn, 1) - 1, size(nn, 2) / 2)
m = 1
for (n in 1:(size(nn, 2) / 2)) {
  speed[, n] = ((nn[2:size(nn, 1), m] - nn[1:size(nn, 1) - 1, m]) ^ 2 + (nn[2:size(nn, 1), m + 1] - nn[1:size(nn, 1) - 1, m + 1]) ^ 2) ^ 0.5 * 107.8 / 5
  m = m + 2
}
average_speed = zeros(size(speed, 2), 1)
average_speed[, 1] = t(colMeans(speed, na.rm = TRUE))

# Split
fusion = speed
fusion[speed >= -1] = 1

a = zeros(size(fusion, 1), 1)
a[, 1] = rowSums(fusion, na.rm = TRUE)
a[a == 0] = NaN
split_fusion = sum(abs(a[1:size(a, 1) - 1, 1] - a[2:size(a, 1), 1]), na.rm = TRUE)

# Distance
dist=speed*5
tot_dist = zeros(size(speed, 2), 1)
tot_dist[, 1]=t(colSums(dist, na.rm = TRUE))
plot(tot_dist,area)

# Time when they stay together/ residency time
changes_in_foci = zeros((size(fusion, 1)-1), 1)

for (x in 1:(size(a,1)-1)) {
  changes_in_foci[x,1]=a[x, 1] - a[x+1, 1]
}
j=1
matrix_for_distri=zeros((size(fusion, 1)-1), 1)
l=0
numbers_for_distri=0
h=0

for (n in 1:nrow(changes_in_foci)) {
  if (changes_in_foci[n,1]==0) { 
    while(changes_in_foci[(colSums(matrix_for_distri)+h+l+1),1]==0) { 
      numbers_for_distri=numbers_for_distri+1
      l=l+1
      if ((colSums(matrix_for_distri)+h+l+1) > nrow(changes_in_foci)) {
        break
      }
    }
    
    matrix_for_distri[n,1]=numbers_for_distri
    numbers_for_distri=0
    l=0
  } else {
    h=h+1
  }
}

time_for_distri=zeros((size(fusion, 1)-1), 1)
for (n in 1:size(fusion, 1)-1) {
  time_for_distri[n]=5*matrix_for_distri[n]
}

# Remove the first row. We do not know what the state of the foci were in the previous ones, therefore we must remove it and count with the remaining data
newtime_for_distri=time_for_distri[-1,] 
# Convert all the zeroes to NA
newtime_for_distri[newtime_for_distri==0]<-NA 
newtime_for_distri=as.data.frame(newtime_for_distri)
