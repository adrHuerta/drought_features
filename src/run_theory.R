#### new function
#### run_theory() 
#### applied the run theory to a time series ()
## time_serie: a numeric vector with no NA values
## threshold: a numeric value in which the features (below) of run theory is measured
run_theory <- function(time_serie,
                       threshold = -.5)
{
  
  dataBase <- data.frame(time_serie = time_serie) %>%
    transform(masked = ifelse(time_serie >= threshold, 1, 0)) %>%
    transform(index = cumsum(masked), index_rev = cumsum(abs(masked-1)))

  ####  Duration, Severity, Intesity ####  

  dataBase[dataBase$masked == 0, ] %>%
    by(., .$index, function(z){
      
      data.frame(D = dim(z)[1],
                 S = abs(sum(z$time_serie)),
                 I = abs(sum(z$time_serie))/dim(z)[1],
                 date_ini = row.names(z)[1],
                 date_fin = row.names(z)[nrow(z)])
      
    }) %>% do.call(rbind, .) -> df1
  
  
  ####  Interarrival ####  
  
  dataBase[dataBase$masked != 0, ] %>%
    by(., .$index_rev, function(z){
      
      data.frame(Int = dim(z)[1])
      
    }) %>% unlist() -> Int
  
  # first condition 
  
  if ((dataBase$masked[1]) == 1){
    
    Int <- Int[-1] 
    
    } else {
      
      Int <- Int
      
      }
  
  # second contidition
  
  if (dataBase$masked[length(dataBase$masked)] == 1) {
    
    Int <- Int + df1$D
    
    } else { 
      
      n <- c(Int, 0 ) + df1$D
      Int <- n[-length(n)]
      
      }


  return(list(Duration = as.numeric(df1$D),
              Severity = as.numeric(df1$S),
              Intesity = as.numeric(df1$I),
              Date_Ini_Ev = as.character(df1$date_ini),
              Date_Fin_Ev = as.character(df1$date_fin),
              Interarrival = as.numeric(Int)))
  
}

#### old function
## SPI: SCI output
## spi_escala: SPI scale (used to omit NA values)
## umbral: threshold in which is computed the characteristic of SPI

drought.index<-function(SPI, 
                        spi_escala, 
                        umbral)
{
  #Calculo de parametros de sequia: Intensidad, Duraci?n, Severidad e Interarrival.
  #SPI: serie de tiempo
  #spi_escala: escala a en la que se calculo el spi
  #umbral: valor minimo para calcular los parametros
  #
  #Adrian Huerta
  SPI<-SPI[spi_escala:length(SPI)]
  #------------------------ severidad, duracion e intensidad ------------------------
  sdi<-SPI
  sdi[sdi >= umbral]<-NA
  idx<- 1 + cumsum(is.na(sdi))
  no.NA<-!is.na(sdi)
  D.S<-split(sdi[no.NA],idx[no.NA])
  
  D<-matrix(nrow=length(D.S),ncol=1)
  S<-matrix(nrow=length(D.S),ncol=1)
  for (i in 1:length(D.S)){
    D[i]<- length(D.S[[i]])
    S[i]<- -1*sum(D.S[[i]])
  }
  I<-S/D
  rm(idx,no.NA)
  
  #---------------------------------- Interarrival ----------------------------------
  int<-SPI
  int[int < umbral]<-NA
  idx<- 1 + cumsum(is.na(int))
  no.NA<-!is.na(int)
  I.n<-split(int[no.NA],idx[no.NA])
  
  intera.raw<-matrix(nrow=length(I.n),ncol=1)
  for (i in 1:length(I.n)){
    intera.raw[i]<- length(I.n[[i]])
  }
  
  #1era condici?n.
  if (is.na(int[1])==FALSE){
    intera.y<-intera.raw[c(-1),]} else
    {intera.y<-intera.raw }
  
  #2da condicion
  if (is.na(int[length(int)])==FALSE){
    interarrival<-intera.y+D} else
    { n<-c(intera.y,0)+D
    interarrival<-matrix(n[-length(n)],ncol=1)}
  
  return(list(Duracion=as.numeric(D),Severidad=as.numeric(S),Intensidad=as.numeric(I),Interarrival=as.numeric(interarrival)))
}