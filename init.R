# init.R

# init ----
library(RSelenium)
library(rvest)
library(dplyr)

# start a chrome browser
# rD <- rsDriver()
# remDr <- rD[["client"]]
# remDr$getStatus() # check server status

remDr <- rsDriver(browser = "phantomjs")
remDr$open()
remDr$navigate("http://www.google.com/ncr")
remDr$close()
remDr$closeServer()

# 1. login ----
remDr$navigate("https://www.myetapp.gov.my/v6/login.jsp?rndId=1622439290393")
webElem <- remDr$findElement(using = "id", value = "username")
# webElem$highlightElement()
webElem$sendKeysToElement(list("890414015534", key = "enter"))
webElem <- remDr$findElement(using = "name", value = "password")
webElem$sendKeysToElement(list("P@ssword2"))
webElem <- remDr$findElement(using = "id", value = "button")
webElem$clickElement()

# 2. Menu Pemberimilikan ----
asas_tanah <- "" 
hak_milik <- "" 
tajuk_fail <- "" 
warta <-  ""
# next loop -- start here
remDr$navigate("https://www.myetapp.gov.my/v6/c/1292294080761?_portal_module=ekptg.view.online.htp.permohonan.FrmTerimaPohon1Online")
webElem <- remDr$findElement(using = "id", value = "socNegeri")
webElem$sendKeysToElement(list("11 - TERENGGANU"))
Sys.sleep(1)
webElem <- remDr$findElement(using = "name", value = "txtTajukFail")
webElem$clearElement()
webElem$sendKeysToElement(list("guntung"))
webElem <- remDr$findElement(using = "name", value = "cmdCari") # button
webElem$clickElement()

# 2.1 If record avail? ----
# (1st record only, otherwise go to step 3)
webElem <- remDr$findElement('xpath', "//*[@id='Fekptg_view_online_htp_permohonan_FrmTerimaPohon1Online']/table/tbody/tr[4]/td/fieldset/table[2]/tbody/tr[2]/td[4]") #[2] 1st rec
tajuk_fail <- webElem$getElementText()
webElem <- remDr$findElement('xpath', "//*[@id='Fekptg_view_online_htp_permohonan_FrmTerimaPohon1Online']/table/tbody/tr[4]/td/fieldset/table[2]/tbody/tr[2]/td[3]/a[1]")
ruj_fail <- webElem$getElementText()
webElem$clickElement()
# webElem$highlightElement()

# 3. Maklumat Permohonan ----
webElem <- remDr$findElement(using = "class", value = "stylobutton100") # button
webElem$clickElement()  # button
Sys.sleep(1)

# 3.1 Maklumat asas tanah ----
no_lot <- ""
keluasan <- ""
webElem <- remDr$findElement(using = "xpath", value = "//*[@id='TabbedPanels1']/div/div[1]/table/tbody/tr[2]/td[4]") # [2] 1st record
no_lot <- webElem$getElementText()
webElem <- remDr$findElement(using = "xpath", value = "//*[@id='TabbedPanels1']/div/div[1]/table/tbody/tr[2]/td[7]")
keluasan <- webElem$getElementText()
df_tanah <- tibble("No_fail" = ruj_fail[[1]], "Nama Tapak" = tajuk_fail[[1]], "No PT" = no_lot[[1]],
                   "Keluasan" = keluasan[[1]])

# 4. Rekod hak milik ---- 
# Tiada rekod skip ke 5.Data
remDr$navigate("https://www.myetapp.gov.my/v6/c/1292294080761?_portal_module=ekptg.view.online.htp.rekod.FrmRekodPendaftaranTanah")
Sys.sleep(1)
webElem <- remDr$findElement(using = "id", value = "txtNoFailC")
webElem$sendKeysToElement(list(ruj_fail[[1]]))
webElem <- remDr$findElement(using = "name", value = "btnCari") # button
webElem$clickElement()
Sys.sleep(1)

# 4.1 senarai hak milik ---- 
# Tiada rekod skip ke 5.Data
webElem <- remDr$findElement(using = "xpath", 
                             value = "//*[@id='Fekptg_view_online_htp_rekod_FrmRekodPendaftaranTanah']/table/tbody/tr[2]/td/fieldset[2]/table/tbody/tr[3]") #[3] 1st record
hak_milik <- webElem$getElementText()

webElem <- remDr$findElement(using = "xpath", 
                             value = "//*[@id='Fekptg_view_online_htp_rekod_FrmRekodPendaftaranTanah']/table/tbody/tr[2]/td/fieldset[2]/table/tbody/tr[3]/td[2]/a")
webElem$clickElement()

# Maklumat rizab ----
webElem <- remDr$findElement(using = "xpath", 
                           value = "//*[@id='Fekptg_view_online_htp_rekod_FrmRekodPendaftaranTanah']/table/tbody/tr[2]/td/fieldset/fieldset[3]/table/tbody/tr/td[1]/table/tbody")
warta <- webElem$getElementText()

# 5. Data Tanah ----
hak_milik_lst <- strsplit(hak_milik[[1]],"\n") %>% unlist()
warta_lst <- strsplit(warta[[1]], "\n") %>% unlist()
area <- keluasan[[1]]
if(length(warta_lst) > 0){
  area <- warta_lst[(which(warta_lst=="Luas Bersamaan")) + 1]
}

df_tanah <- mutate(df_tanah,"Tarikh Warta/Daftar" = warta_lst[2], "No PT" = hak_milik_lst[3],
                   "No Geran" = hak_milik_lst[2], "Keluasan" = area)

readr::write_csv(df_tanah,file = "tanah.dat", append = TRUE)
                  
# Extracting table df_rizab[[12]]
# df_rizab <- remDr$getPageSource()[[1]] %>% 
#   rvest::read_html() %>%
#   rvest::html_table()
# 
# webElem <- remDr$findElement(using = "xpath", 
#                              value = "//*[@id='Fekptg_view_online_htp_rekod_FrmRekodPendaftaranTanah']/table/tbody/tr[2]/td/fieldset[2]/table/tbody")
# df_rizab <- webElem$getElementText()
# 
# luas_tanah <- webElem$getElementText()
# webElem <- remDr$findElement(using = "name", value = "Cetak") # button previu
# webElem$clickElement()
# 
# # Cetak
# remDr$navigate("https://www.myetapp.gov.my/v6/servlet/ekptg.report.htp.MaklumatFailHakmilikRizab?template=MaklumatHakmilik&idHakmilik=161085831")

# stop the selenium server ----
save.image("tanah.RData")
rD[["server"]]$stop()
