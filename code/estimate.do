clear
use "data/2024/budapest.dta"
egen szavazokor = group(MAZ TAZ TEVK szavkor)

local partok mkkp mihazank tisza lmp fidesz dk momentum kispartok 
local jeloltek karacsony vitezy grundtner ervenytelen_fo 

generate total = karacsony + vitezy + grundtner
generate part_total = mkkp + mihazank + neppartjan + munkaspart + szolidaritas + tisza + lmp + fidesz + dk
generate kispartok = neppartjan + munkaspart + szolidaritas

local formula 0
foreach part in `partok' {
    local formula `formula' + normal({`part'})*`part'
}

foreach jelolt in `jeloltek' {
    nl (`jelolt' = `formula') if part_total>0, noconstant
    foreach part in `partok' {
        scalar `jelolt'_`part' = normal(_b[/`part'])
        *generate `jelolt'_X_`part' = `jelolt'_`part' * `part'
    }
    predict `jelolt'_predict
    generate ae_`jelolt' = abs(`jelolt'_predict - `jelolt') / total * 100
    scatter `jelolt' `jelolt'_predict, msize(tiny)

    * evaluate model
    summarize ae_`jelolt' if `jelolt'>0 & `jelolt'_predict>0, detail
    scalar hiba_`jelolt' = r(mean)
}

* estimate total number of votes by combination of parties and candidates
collapse (sum) `partok'
expand 4
egen index = seq()
generate jelolt = "karacsony" if index == 1
replace jelolt = "vitezy" if index == 2
replace jelolt = "grundtner" if index == 3
replace jelolt = "ervenytelen_fo" if index == 4

foreach part in `partok'  {
    rename `part' `part'_szavazatok
    generate `part' = 0
    foreach jelolt in `jeloltek' {
        replace `part' = `jelolt'_`part' * `part'_szavazatok if jelolt == "`jelolt'"
    }
    replace `part' = round(`part')
}

keep jelolt `partok' 
export delimited "data/2024/budapest_becsles.csv", replace
