clear
use "data/2024/budapest.dta"
egen szavazokor = group(MAZ TAZ TEVK szavkor)

local partok mkkp mihazank tisza lmp fidesz dk momentum 
local kispartok neppartjan munkaspart szolidaritas 
local jeloltek karacsony vitezy grundtner ervenytelen 

generate total = karacsony + vitezy + grundtner
generate part_total = mkkp + mihazank + neppartjan + munkaspart + szolidaritas + tisza + lmp + fidesz + dk
generate kispartok = neppartjan + munkaspart + szolidaritas
generate fidesz_share = fidesz / part_total
foreach p in `partok' {
    generate `p'_X_fidesz = `p' * fidesz_share
}

foreach jelolt in `jeloltek' {
    regress `jelolt' `partok' kispartok if part_total>0, noconstant
    foreach part in `partok' {
        scalar `jelolt'_`part' = _b[`part']
        *assert inrange(`jelolt'_`part', 0, 1)
    }
    predict `jelolt'_predict, xb
    generate ae_`jelolt' = abs(`jelolt'_predict - `jelolt') / total * 100
    scatter `jelolt' `jelolt'_predict, msize(tiny)

    * evaluate model
    summarize ae_`jelolt' if `jelolt'>0 & `jelolt'_predict>0, detail
    scalar hiba_`jelolt' = r(p95)
}

* manually adjust models so that each party has a share between 0 and 1
local karacsony0 fidesz lmp mihazank
local karacsony1 dk momentum
local vitezy0 dk
local vitezy1 lmp

foreach jelolt in karacsony vitezy {
    generate `jelolt'_minusz = `jelolt'
    foreach one in ``jelolt'1' {
        replace `jelolt'_minusz = `jelolt'_minusz - `one' if `jelolt' > 0
    } 
}
regress karacsony_minusz mkkp tisza kispartok if part_total>0, noconstant
regress vitezy_minusz mkkp mihazank tisza fidesz kispartok if part_total>0, noconstant

* estimate total number of votes by combination of parties and candidates
collapse (sum) `partok'
expand 4
egen index = seq()
generate jelolt = "karacsony" if index == 1
replace jelolt = "vitezy" if index == 2
replace jelolt = "grundtner" if index == 3
replace jelolt = "ervenytelen" if index == 4

foreach part in `partok' {
    rename `part' `part'_szavazatok
    generate `part' = 0
    foreach jelolt in `jeloltek' {
        replace `part' = `jelolt'_`part' * `part'_szavazatok if jelolt == "`jelolt'"
    }
}

list jelolt `partok'
