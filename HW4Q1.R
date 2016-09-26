library(gstat)
library(raster)
library(maptools)
library(sp)
library(rgdal)
library(automap)


wd <- 'D:/GEOG5330/R/week4-bckronkosky'
setwd(wd)

gwshape             <- readOGR(dsn = wd,layer = 'oa')
gwdata              <- data.frame(gwshape@coords,gwshape$WTE2013)
colnames(gwdata)    <- c('x','y','WTE2013')
gwdata              <- gwdata[gwdata[,3]!=0,]
coordinates(gwdata) <- ~x+y
gwdata@proj4string  <- crs(gwshape)


gwvg <- variogram(WTE2013~1,gwdata)

gwvg.fit <- fit.variogram(gwvg,model=vgm(psill = 8552,
                                         range = 65776,
                                         nugget = 0,
                                         model = 'Gau'
                                         )
                          )

plot(gwvg,gwvg.fit, main='GW 2013 Variogram')

gwgrid <-
SpatialPoints(raster(extent(gwdata),nrows = 25,ncol = 25,crs = crs(gwdata)),
              proj4string = crs(gwdata)
             )

gwkrig               <- krige(WTE2013~1,gwdata,gwgrid,model=gwvg.fit)

predict              <- data.frame(gwkrig$var1.pred,gwkrig@coords)
coordinates(predict) <- ~x+y
gridded(predict)=T
plot(raster(predict), main="GW 2013 Predict Map")
points(gwdata, pch=16)

var                  <- data.frame(gwkrig$var1.var,gwkrig@coords)
coordinates(var)     <- ~x+y
gridded(var)=T
plot(raster(var), main=" GW 2013 Variance Map")
points(gwdata, pch=16)

cv                   <- krige.cv(WTE2013~1,gwdata,gwgrid, model=gwvg.fit,nfold=nrow(gwdata)) 
sqrt(sum(cv$residual^2))





