rm(list = ls())

source('./src/run_theory.R')
`%>%` = magrittr::`%>%`

#### using example from SCI package ####

## create artificial data, resembling precipitation
set.seed(101)
n.years <- 60
date <- rep(1:n.years, each = 12) + 1950 + rep((0:11)/12, times = n.years)
PRECIP <- (0.25*sin( 2 * pi * date) + 0.3)*rgamma(n.years*12, shape = 3, scale = 1)
PRECIP[PRECIP < 0.1] <- 0

## apply SCI transformation (computing SPI)
spi.para <- SCI::fitSCI(PRECIP, first.mon = 1, time.scale = 6, distr = "gamma", p0 = TRUE)
spi <- SCI::transformSCI(PRECIP, first.mon = 1, obj = spi.para)

## creting XTS time serie
spi_dates <- seq(as.Date("1951-01-01"), length.out = length(date), by = "month")
spi <- xts::xts(spi, spi_dates)

## plot time series
xts::plot.xts(spi)
lattice::xyplot(spi)

## drough features
dght_features <- run_theory(time_serie = spi[6:length(spi)], 
                            threshold = -.5)

dght_features$Duration
dght_features$Severity
dght_features$Intesity
dght_features$Date_Ini_Ev
dght_features$Date_Fin_Ev
dght_features$Interarrival

## plot

library(ggplot2)

lapply(dght_features %>% names(), 
       function(x){
         data.frame(value = dght_features[[x]], 
                    feature = x) 
         }) %>% 
  .[c(1,2,3, 6)] %>% # deleting Dates output to plot
  do.call(rbind, .) %>%
  
  ggplot() + 
  facet_wrap(~feature, "free", nrow = 2, ncol = 2) + 
  geom_histogram(aes(x = value)) + 
  xlab("")
