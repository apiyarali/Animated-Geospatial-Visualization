#spherical.R
#Reads a file of city names, latitudes, and longitudes
sph.makeCityDF <- function(fname) {
  DF <- read.csv(fname, stringsAsFactors = FALSE)
  return(DF)
}
testDF <- sph.makeCityDF("cities.csv");testDF

sph.addCity <- function(name, lat, long){
  
  newCityDF <- data.frame(Name=name, Lat=lat, Long=long, stringsAsFactors = FALSE)
  return(newCityDF)
}

#testNew <- sph.addCity("Toronto", 43, 65); testNew

#Looks up a city in the dataframe and returns latitude and longitude
sph.latlong <- function(DF, name){
  k <- which(DF$Name == name)
  stopifnot (length(k)==1)  #name must exist and be unique
  return(c(DF$Lat[k],DF$Long[k]))
}
#v <- sph.latlong(testDF,"Boston");v

#Makes a unit vector from the specified latitude and longitude
#Accepts a vector in place of two separate arguments
sph.makeXYZ <- function(lat, long, degrees = TRUE){
  if (length(lat) == 2){
    long <- lat[2]
    lat <- lat[1]
  }
  if (degrees){
    lat <- lat*pi/180
    long<- long*pi/180
  }
  return( round(c(cos(lat)*cos(long),cos(lat)*sin(long),sin(lat)), digits = 4))
}
#A <- sph.makeXYZ(v);A

#Dot product operator
"%.%" <- function(v,w) sum(v*w)

#Cross product operator
"%x%" <- function(v,w) {
  stopifnot(length(v)== 3, length(w)== 3)
  c(v[2]*w[3]-v[3]*w[2],v[3]*w[1]-v[1]*w[3],v[1]*w[2]-v[2]*w[1])
}

#Calculates the great-circle distance between two cities
sph.distance <- function(A,B,unit = "radians"){
  d <- acos(A%.%B)
  switch(unit,
    miles = 2*6220*d/pi,
    kilometers = 20000*d/pi,
    degrees = 180*d /pi,
    radians = d)
}

#B <- sph.makeXYZ(sph.latlong(testDF, "London"));B
#sph.distance(A,B, unit = "miles")
#sph.distance(A,B, unit = "kilometers")
#dAB <- sph.distance(A,B)

#Makes the vector at A tangent to the great circle from A to B
sph.directionVector <- function(A,B){
  d <- sph.distance(A,B)
  return(round((B - A*cos(d))/sin(d), digits = 4))
}

#vAB <- sph.directionVector(A,B); vAB

#Makes the direction vector from A to the North Pole
sph.directionNorth <- function(A){
  pole <- c(0,0,1)
  d <- sph.distance(A,pole)
  return((pole - A*cos(d))/sin(d))
}

#sph.directionNorth(A)

#Makes the direction vector heading due east from A
sph.directionEast <- function(A){
  return(sph.directionNorth(A)%x%A)
}


#sph.directionEast(A)

#Finds the compass heading (East is 0 degrees) of v at A
sph.compass <- function(A,v, degrees = TRUE){
  angleEast <- acos(v%.%sph.directionEast(A))
  goesNorth <- v%.%sph.directionNorth(A) > 0
  theta <- ifelse(goesNorth,angleEast,2*pi - angleEast)
  return(ifelse(degrees, theta*180/pi, theta))
}

#sph.compass(A,vAB)
  
#Makes the point at distance d in radians from A
#along the great circle route to B
sph.makePoint <- function(A,v,d){
  return(A*cos(d)+v*sin(d))
}
#sph.makePoint(A, vAB,dAB )

#Vectorized version - accepts a vector of distances
sph.makePoints <- Vectorize(sph.makePoint,"d")
#sph.makePoints(A, vAB,c(0, dAB/2, dAB) )

#Makes a matrix whose columns are n+1 equally spaced points along the route
sph.makeRoute <- function(A,B,n = 50) {
  vAB <- sph.directionVector(A,B)
  d <- sph.distance(A,B)
  seq <- (0:n)*d/n
  sph.makePoints(A, vAB, seq)
}


#3D plotting functions
sph.blankPlot3D <- function(){
  par (mar = c(0,0,0,0))   #no margins
  plot3d(NULL, NULL,  xlim = c(-1.1,1.1),ylim = c(-1.1,1.1), 
    zlim = c(-1.1,1.1),asp = 1,axes = FALSE, xlab = "", ylab = "",zlab = "",)
  drawParallel <- function(phi){
    A <- matrix(nrow = 3, ncol = 180)
    for (i in (1:180)){
      A[,i] <- sph.makeXYZ(phi,2*i)
    }
    plot3d(x=A[1,],y=A[2,],z=A[3,], type = "l", add = TRUE, col = "light blue")
  }
  for (phi in c(-60, -30, 0, 30, 60)){
    drawParallel(phi)
  }
  drawMeridian <- function(theta){
    A <- matrix(nrow = 3, ncol = 180)
    for (i in (0:180)){
      A[,i] <- sph.makeXYZ(i-90,theta)
    }
    plot3d(A[1,], A[2,],A[3,],type = "l", col = "light blue", add = TRUE)
  }
  for (theta in c(-150, -120, -90, -60, -30, 0, 30, 60, 90, 120, 150, 180)){
    drawMeridian(theta)
  } 
}
#sph.blankPlot3D()



#Adds all cities to the map
sph.showCities3D <- function(DF){
  m <- matrix(nrow = 3, ncol = nrow(DF))
  for (i in 1:nrow(DF)){
    m[,i] <- sph.makeXYZ(DF$Lat[i],DF$Long[i])
    if(DF$Long[i] < 0){
      color <- "red"
    } else {
      color <- "black"
    }
    
    text3d(m[1,i],m[2,i],m[3,i],DF$Name[i], cex = 0.8, col=color)
  }
}
#sph.showCities3D(testDF)

#Adds the route between two given cities to the plot
sph.plotRoute3D <- function(DF,cityA,cityB,cex = 1,nstop = 0,showNames=FALSE){
  vA <- sph.latlong(DF,cityA)
  A <- sph.makeXYZ(vA)
  arrow3d(c(0,0,0),A,type = "lines",barblen = 0.03, col = "pink")
  vB <- sph.latlong(DF,cityB)
  B <- sph.makeXYZ(vB)
  arrow3d(c(0,0,0),B,type = "lines",barblen = 0.03, col = "pink")
  m <- sph.makeRoute(A,B)
  if (nstop > 0) {
    mp <- sph.makeRoute(A,B, n = nstop+1)
  }
  if (showNames){
    text3d(A[1],A[2],A[3],cityA, cex = cex)
    text3d(B[1],B[2],B[3],cityB, cex = cex)
  }
  plot3d(m[1,],m[2,],m[3,],type = "l", col = "red",add = TRUE)
  if (nstop > 0) {
    plot3d(mp[1,],mp[2,],mp[3,],type = "p", col = "red", cex = 1.5, add = TRUE)
  }
  pole <- A%x%B
  m <- cbind(pole,-pole)
  plot3d(m[1,],m[2,],m[3,],type = "l", col = "green",add = TRUE)
}

#sph.plotRoute3D(testDF,"Boston","London", nstop = 0)

sph.plotNewRoute3D <- function(DF,cityA,cityB,cex = 1,nstop = 0,showNames=FALSE){
  vA <- sph.latlong(DF,cityA)
  vB <- sph.latlong(DF,cityB)
  
  m <- matrix(nrow = 3, ncol = 51)
  
  #x <- (vA[2]+(0:50)*abs((vB[2]-vA[2]))/50)
  
  #x <- (vA[2]+(0:50)*abs((vB[2]-vA[2]))/50)*pi/180
  #y <- sph.merc(vA[1])+(0:50)*abs((sph.merc(vB[1])-sph.merc(vA[1])))/50
  
  #x <- (pi/180) * (((1:51) * (vB[2] - vA[2])/50) + vA[2])
  #y <- sph.merc((((1:51) * (vB[1] - vA[1])/50) + vA[1]))-180
  
  x <- (vA[2]+(0:50)*abs((vB[2]-vA[2]))/50)*pi/180
  y <- sph.merc(vA[1])+(0:50)*(sph.merc(vB[1])-sph.merc(vA[1]))/50
  
  for (i in (0:50)){
    long <- 180*x[i+1]/pi
    lat <- sph.invMerc(y[i+1])
    m[,i+1] <- sph.makeXYZ(lat, long)
  }
  
  plot3d(m[1,], m[2,], m[3,], type = "l", col = "red",add = TRUE)
  
  rglwidget()
  
}


#Mercator projection plotting functions
#Draws a plot of a hemisphere with parallels and meridians

sph.merc <- function(lat){
  log(tan(pi/4+lat*pi/360))
}

sph.invMerc <- function(mercLat){
  (360 * (atan(exp(mercLat)) - (pi/4)))/pi
}
#(360 * (atan(exp(lat)) - (pi/4))) / pi


sph.blankPlot <- function(){
  par (mar = c(0,0,0,0))   #no margins
  plot(NULL,NULL,xlim = c(-pi,pi),ylim = c(-sph.merc(70),sph.merc(70)),asp = 1)
  drawParallel <- function(phi){
    points(x=c(-180,180),y=c(sph.merc(phi),sph.merc(phi)),
           type = "l", col = "light blue")
  }
  for (phi in 30*(-2:2)){
    drawParallel(phi)
  }
  drawMeridian <- function(theta){
    points(x=c(theta,theta),y=c(-sph.merc(70),sph.merc(70)), type = "l", col = "light blue")
  }
  for (theta in pi*c(-6:6)/6){
    drawMeridian(theta)
  } 
}
#sph.blankPlot()

#Adds all cities to the map
sph.showCities <- function(DF){
    m <- matrix(nrow = 2, ncol = nrow(DF))
    for (i in 1:nrow(DF)){
      m[1,i] <- DF$Long[i]*pi/180
      m[2,i] <- sph.merc(DF$Lat[i])
      
      if(DF$Long[i] < 0){
        color <- "red"
      } else {
        color <- "black"
      }
      
      text(m[1,i],m[2,i],DF$Name[i], cex = 0.8, col=color)
    }
    return(NULL)
}
#sph.showCities(testDF)
  
#Adds the route between two given cities to the plot
sph.plotRoute <- function(DF,cityA,cityB,cex = 1, nstop = 0,showNames = FALSE) {
  vA <- sph.latlong(DF,cityA)
  A <- sph.makeXYZ(vA)
  vB <- sph.latlong(DF,cityB)
  B <- sph.makeXYZ(vB)
  m <- sph.makeRoute(A,B)
  if (nstop > 0) {
    mp <- sph.makeRoute(A,B, n = nstop+1)
  }
    if(showNames){
      text(vA[2]*pi/180,sph.merc(vA[1]), cityA, cex = cex)
      text(vB[2]*pi/180,sph.merc(vB[1]), cityB, cex = cex)
    }
    lats <- asin(m[3,])
    longs <- atan2(m[2,],m[1,])
    points(longs,log(tan(pi/4+lats/2)),type = "l", col = "red")
    if (nstop > 0) {
      lats <- asin(mp[3,])
      longs <- atan2(mp[2,],mp[1,])
      points(longs,log(tan(pi/4+lats/2)),type = "p", col = "red")
    }
  }
#sph.plotRoute(testDF,"Rio","Kolkata", cex = 0.8, nstop = 5)

sph.plotRouteMerc <- function(DF,cityA,cityB,cex = 1, nstop = 0,showNames = FALSE){
  vA <- sph.latlong(DF,cityA)
  #A <- sph.makeXYZ(vA)
  vB <- sph.latlong(DF,cityB)
  #B <- sph.makeXYZ(vB)
  #m <- sph.makeRoute(A,B)
  
  #long, lat
  points(x=c((vA[2]*pi/180),(vB[2]*pi/180)),y=c(sph.merc(vA[1]),sph.merc(vB[1])),type = "l", col = "red")
  
}









