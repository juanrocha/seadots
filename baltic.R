library(tidyverse)
library(sf)
library(fs)
library(stars)
library(tictoc)
library(furrr)
library(patchwork)
## Only needed for change point analysis
library(trend)
library(strucchange)
library(changepoint)
set.seed(2026)


btc <- st_read("~/Downloads/Intersect_EEZ_IHO_v5_20241010/Intersect_EEZ_IHO_v5_20241010.shp")
bbx <- btc |> 
    filter(IHO_Sea %in% c("Baltic Sea", "Gulf of Bothnia")) |> 
    st_bbox() |> st_as_stars()

rm(btc)

#### monthly dataset ####
fls <- dir_info(
    "~/Documents/Projects/DATA/BICEP_biological_carbon_pump/marine_primary_production_9km_monthly/") |> 
    filter(str_detect(path, "\\.nc$"))
fls

tst <- read_stars(fls$path[1], sub = "chl_a") |> 
    st_set_crs(6422)

tst |> st_transform(crs = 4326)

st_warp(tst, bbx) 

tic("reading stack")
dat <- read_stars(
    .x = fls$path,  proxy = TRUE, sub = 5, along = "time", #sub = "chl_a",
    #RasterIO = rasterio,
    quiet = TRUE)
toc() #2s

dat |> st_set_crs(6422)

lon <- st_get_dimension_values(dat, 'x')
lat <- st_get_dimension_values(dat, 'y')
time <- st_get_dimension_values(dat, "time")

btc <- st_tile()
