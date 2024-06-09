clear all
import delimited "data/2024/budapest_party_list.csv", clear varnames(1) case(preserve) encoding(UTF-8)

generate lista = "mkkp" if Lista == "MKKP"
replace lista = "mihazank" if Lista == "Mi Hazank"
replace lista = "neppartjan" if Lista == "Nep Partjan"
replace lista = "munkaspart" if Lista == "Munkaspart"
replace lista = "szolidaritas" if Lista == "Szolidaritas"
replace lista = "tisza" if Lista == "TISZA"
replace lista = "lmp" if Lista == "Vitezy-LMP"
replace lista = "fidesz" if Lista == "FIDESZ"
replace lista = "dk" if Lista == "DK-MSZP-PARBESZED"
replace lista = "momentum" if Lista == "MOMENTUM"
replace lista = "ervenytelen" if Lista == "ervenytelen"

drop Lista

reshape wide Szavazat, i(MAZ TAZ TEVK szavkor) j(lista) string
rename Szavazat* *

tempfile lista
save "`lista'", replace

import delimited "data/2024/fopolgarmester.csv", clear varnames(1) case(preserve) encoding(UTF-8)
* Szentkiralyi dropped out
drop if Jelolt == "Szentkiralyi"
reshape wide Szavazat, i(MAZ TAZ TEVK szavkor) j(Jelolt) string
rename Szavazat* *

rename Karacsony karacsony
rename Vitezy vitezy
rename Grundtner grundtner
rename ervenytelen ervenytelen_fo

merge 1:1 MAZ TAZ TEVK szavkor using "`lista'",
save "data/2024/budapest.dta", replace