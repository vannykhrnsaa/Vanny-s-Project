install.packages("tseries")
install.packages("TSA")
install.packages("forecast")
install.packages("lmtest", update="TRUE")
install.packages("zoo")
install.packages("FinTS")
install.packages("rugarch")
library(rugarch)
library(readr)
library(TSA)
library(zoo)
library(xts)
library(quantmod)
library(tseries)
library(forecast)
library(lmtest)
library(FinTS)

df = read_csv('C:/Users/vanny/Documents/UI/KULIAH/S5/EKONOM/TLKMM.csv')
df <- df[nrow(df):1, ]
View(df)

dfs <- ts((df$Terakhir), start=2014, end = c(2024,12), frequency=12)
plot(dfs)

#Cek stasioner
adf.test(df$Terakhir)
##0.6382>0.05 maka non stasioner

#Coba saat diferensial ke 1
d1<-diff(df$Terakhir, lag=1)
adf.test(d1)
##0.01<0.05 maka stasioner setlah diferensiasi 1

#Plot d1
d1 <- ts((d1), start=2014, end = 2024, frequency=12)
plot(d1)

#ACF/PACF
acf(as.numeric(d1))
pacf(as.numeric(d1))
eacf(as.numeric(d1))
## Kemungkinan modelnya (0,1,0), (1,1,1), (2,1,1)

#Cek Best Model ARIMA
m1arima <-Arima(d1, order=c(0,1,0))
m2arima <-Arima(d1, order=c(1,1,1))
m3arima <-Arima(d1, order=c(2,1,1))

summary(m1arima)
summary(m2arima)
summary(m3arima)
##Dari AICnya m2arima=--21.52
##Best model terbaik ARIMA(3,1,1)

#Uji independensi residual ARIMA (0,1,0)
checkresiduals(m1arima)
##Ljung box, 0.01<0.05 tidak mengandung autokorelasi

#Uji independensi residual ARIMA (1,1,1)
checkresiduals(m2arima)
##Ljung box, 0.9828>0.05 mengandung korelasi

#Uji independensi residual ARIMA (2,1,1)
checkresiduals(m3arima)
##Ljung box, 0.9753>0.05 mengandung korelasi

#Uji Normalitas residual ARIMA (0,1,0)
jarque.bera.test(residuals(m1arima))
##0.8323>0.05
#Gak normal

#Uji Normalitas residual ARIMA (1,1,1)
jarque.bera.test(residuals(m2arima))
##0.223>0.05
#Normal

#Uji Normalitas residual ARIMA (2,1,1)
jarque.bera.test(residuals(m3arima))
##0.1744>0.05
#Normal

#Uji ARCH-LM ARIMA (0,1,0)
r1 <- residuals(m1arima)
sr1 <- r1^2
ArchTest(r1)
##0.027<0.005

#Uji ARCH-LM ARIMA (1,1,1)
r2 <- residuals(m2arima)
sr2 <- r2^2
ArchTest(r2)
##0.347>0.005

#Uji ARCH-LM ARIMA (2,1,1)
r3 <- residuals(m3arima)
sr3 <- r3^2
ArchTest(r3)
##0.374>0.005


###Menerapkan persimony, walaupun AIC model 1 paling besar tetapi yang punya
###ARCH cuma model 1 yaitu (0,1,0)

#Plot ACF dan PACF ARIMA (0,1,0)
par(mfrow=c(1,2))
acf(as.vector(sr1), main='ACF of Squared Residual ARIMA (0,1,0)')
pacf(as.vector(sr1), main= 'PACF of Squared Residual ARIMA (0,1,0)')
eacf(sr1)
##lag yang signif till 1 (ACF) dan 1 (PACF)


#GARCH MODELING 
spec_garch <- ugarchspec(variance.model = list(model = "sGARCH",
                                               garchOrder = c(2, 1)),
                         mean.model = list(armaOrder = c(0,0)),
                         distribution.model = "norm")

garch<-ugarchfit(spec_garch, sr1)
garch

#Garch dengan tstudent
spec_garch <- ugarchspec(variance.model = list(model = "sGARCH",
                                               garchOrder = c(1, 1)),
                         mean.model = list(armaOrder = c(0,0)),
                         distribution.model = "std")
garch<-ugarchfit(spec_garch, sr1)
garch

#Uji ARCH pada GARCH
rg <- residuals(garch)
srg <- rg^2
ArchTest(rg)

#Fungsi Forecasting
forecast <- ugarchforecast(fitORspec = garch, data = df$Terakhir, n.ahead = 5)

# Ambil hasil forecast dari forecast object
forecast_values <- forecast@forecast$seriesFor[,1]

# Ambil 5 data aktual terakhir dari dataset
data_aktual <- tail(df$Terakhir, 5)

# Buat data frame untuk membandingkan data aktual dengan forecast
banding <- data.frame(
  "Aktual" = data_aktual,
  "Ramalan" = forecast_values)

# Buat data frame untuk 5 data terakhir
banding <- data.frame(
  "Waktu" = seq_along(data_aktual),  # Buat indeks waktu
  "Aktual" = data_aktual,
  "Ramalan" = forecast_values)

# Plot menggunakan ggplot2
ggplot(banding, aes(x = Waktu)) +
  geom_line(aes(y = Aktual, color = "Aktual"),
            size = 1.2) +  
  geom_line(aes(y = Ramalan, color = "Ramalan"),
            size = 1.2, linetype = "dashed") + 
  labs(title = "Perbandingan Data Aktual dan Forecast Model GARCH",
       x = "Waktu",
       y = "Nilai",
       color = "Legenda") +
  theme_minimal() +
  theme(legend.position = "top")
