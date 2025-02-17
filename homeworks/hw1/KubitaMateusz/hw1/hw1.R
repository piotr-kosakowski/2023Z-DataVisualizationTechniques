library(dplyr)

df <- read.csv("house_data.csv")

colnames(df)
dim(df)
apply(df, 2, function(x) sum(is.na(x))) # nie ma warto�ci NA w �adnej kolumnie


# 1. Jaka jest �rednia cena nieruchomo�ci z liczb� �azienek powy�ej mediany i 
#po�o�onych na wsch�d od po�udnika 122W?

df %>% 
  filter(bathrooms > median(bathrooms)) %>% 
  filter(long > -122) %>% 
  summarise(srednia_cena = mean(price))

# Odp: 625499.4

# 2. W kt�rym roku zbudowano najwi�cej nieruchomo�ci?


df %>%  
  count(yr_built) %>% 
  arrange(-n) %>% 
  head(3) 

# Odp: 2014

# 3. O ile procent wi�ksza jest mediana ceny budynk�w po�o�onych nad wod� w 
#por�wnaniu z tymi po�o�onymi nie nad wod�?

res1 <-
  df %>% 
  filter(waterfront == 1) %>% 
  summarise(median_price_water = median(price))

res2 <-
  df %>% 
  filter(waterfront == 0) %>% 
  summarise(median_price_NO_water = median(price))
res1
res2

perc_diff <- (res1$median_price_water-res2$median_price_NO_water)/res2$median_price_NO_water *100
perc_diff

# Odp: 211,1 %

# 4. Jaka jest �rednia powierzchnia wn�trza mieszkania dla najta�szych nieruchomo�ci 
#posiadaj�cych 1 pi�tro (tylko parter) wybudowanych w ka�dym roku?

df %>% 
  filter(floors == 1) %>% 
  group_by(yr_built) %>% 
  filter(price == min(price)) %>% 
  arrange(yr_built) %>% 
  ungroup() %>% 
  summarise(srednia_pow = mean(sqft_living)) %>% View()


# Odp: 1030.422

# 5. Czy jest r�nica w warto�ci pierwszego i trzeciego kwartyla jako�ci 
#wyko�czenia pomieszcze� pomi�dzy nieruchomo�ciami z jedn� i dwoma �azienkami? 
#Je�li tak, to jak r�ni si� Q1, a jak Q3 dla tych typ�w nieruchomo�ci?

df %>% 
  filter(bathrooms == 1) %>% 
  summarise(quantile(grade))
#Jenda �azienka : Q1 = 6, Q3 = 7

df %>% 
  filter(bathrooms == 2) %>% 
  summarise(quantile(grade))
#Dwie �azienki: Q1 = 7, Q3 = 8

# Odp: Tak, jest r�nica. Dla jednej �azienki: Q1 = 6, Q3 = 7. Dla dw�ch: Q1 = 7, Q3 = 8


# 6. Jaki jest odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy 
#a jaki tych na po�udniu? (P�noc i po�udnie definiujemy jako po�o�enie odpowiednio powy�ej i 
#poni�ej punktu znajduj�cego si� w po�owie mi�dzy najmniejsz� i najwi�ksz� szeroko�ci� geograficzn� w zbiorze danych)


df %>% 
  summarise(punkt_szer = (max(lat)+min(lat))/2) 
#szeroko�� geograficzna oddzielajacy p�noc i po�udnie: 47.46675
szer_geog_odd <- 47.46675

#polnoc
df %>% 
  filter(lat > szer_geog_odd) %>% 
  summarise(odst_miedzykwartylowy = IQR(price))
#poludnie
df %>% 
  filter(lat < szer_geog_odd) %>% 
  summarise(odst_miedzykwartylowy = IQR(price))

df %>% 
  mutate(pol_czy_pol = ifelse(lat > szer_geog_odd, "N", "S")) %>% 
  group_by(pol_czy_pol) %>% 
  summarise(odst_miedzykwartylowy = IQR(price))


# Odp: IQR dla mieszka� dla p�nocy = 321000, odpowiednio dla po�udnia = 122500

# 7. Jaka liczba �azienek wyst�puje najcz�ciej i najrzadziej w nieruchomo�ciach 
#niepo�o�onych nad wod�, 
#kt�rych powierzchnia wewn�trzna na kondygnacj� nie przekracza 1800 sqft?

df %>% 
  filter(sqft_living/floors <= 1800) %>% 
  filter(waterfront == 0) %>% 
  count(bathrooms) %>% 
  arrange(n) %>% 
  View()

# Odp: Najrzadziej 4.75 �azienki (chcia�bym wiedzie� co to znaczy 0.75 �azienki), najcz�ciej 2.5 �azienki


# 8. Znajd� kody pocztowe, w kt�rych znajduje si� ponad 550 nieruchomo�ci. 
#Dla ka�dego z nich podaj odchylenie standardowe powierzchni dzia�ki oraz 
#najpopularniejsz� liczb� �azienek

zipcodes_more_than_550 <-
  df %>% 
  count(zipcode) %>% 
  filter(n > 550) %>% 
  select(zipcode)


zipcodes_keys <- zipcodes_more_than_550$zipcode
zipcodes_keys


find_sd_and_most_common_bathrooms_n <- function(zipcode_szukane){
  res_bath <- df %>% 
    filter(zipcode == zipcode_szukane) %>% 
    count(bathrooms) %>% 
    arrange(-n) %>% 
    head(1)
  
  print(res_bath)
  
  res_sd <- df %>% 
    filter(zipcode == zipcode_szukane) %>% 
    summarise(dev = sd(sqft_lot))
  
  print(res_sd)

}
find_sd_and_most_common_bathrooms_n(98038)
find_sd_and_most_common_bathrooms_n(98052)
find_sd_and_most_common_bathrooms_n(98103)
find_sd_and_most_common_bathrooms_n(98115)
find_sd_and_most_common_bathrooms_n(98117)


# Odp: 
#Kod pocztowy: 98038, �azienki: 2.5, odchylenie: 63111.11
#Kod pocztowy: 98117, �azienki: 1, odchylenie: 2318.662
#Kod pocztowy: 98115, �azienki: 1, odchylenie: 2675.302
#Kod pocztowy: 98103, �azienki: 1, odchylenie: 1832.009
#Kod pocztowy: 98052, �azienki: 2.5, odchylenie: 10276.19
#

# 9. Por�wnaj �redni� oraz median� ceny nieruchomo�ci, kt�rych powierzchnia mieszkalna znajduje 
#si� w przedzia�ach (0, 2000], (2000,4000] oraz (4000, +Inf) sqft, nieznajduj�cych si� przy wodzie.

  
res1 <- 
  df %>% 
  filter(waterfront == 0) %>% 
  filter(sqft_living >0 & sqft_living <= 2000) %>% 
  summarise(srednia_cena = mean(price),
            mediana_ceny = median(price))
res2 <-
  df %>% 
  filter(waterfront == 0) %>% 
  filter(sqft_living >2000 & sqft_living <= 4000) %>% 
  summarise(srednia_cena = mean(price),
            mediana_ceny = median(price))

res3 <-
  df %>% 
  filter(waterfront == 0) %>% 
  filter(sqft_living >= 4000) %>% 
  summarise(srednia_cena = mean(price),
            mediana_ceny = median(price))

res1
res2
res3

# Odp: 
# Przedzial (0, 2000]: srednia cena = 385084.3, mediana = 359000
# Przedzial (2000,4000]: srednia cena = 645419, mediana = 595000
# Przedzial (4000, +Inf): srednia cena = 1441227, mediana = 1250000

# 10. Jaka jest najmniejsza cena za metr kwadratowy nieruchomo�ci? 
#(bierzemy pod uwag� tylko powierzchni� wewn�trz mieszkania)

#stala aby zamienic feet squared to meters squared = 0.092903

df %>% 
  mutate(meters_squared_living =0.092903*sqft_living ) %>% 
  mutate(price_for_meter = price/meters_squared_living) %>% 
  select(price_for_meter) %>% 
  arrange(price_for_meter) %>% head(5)


# Odp: 942.7923
