egen szavazokor = group(MAZ TAZ TEVK szavkor)

local partok mkkp mihazank tisza lmp fidesz dk momentum 
local kispartok neppartjan munkaspart szolidaritas 
local jeloltek karacsony vitezy grundtner 

generate total = karacsony + vitezy + grundtner
generate part_total = mkkp + mihazank + neppartjan + munkaspart + szolidaritas + tisza + lmp + fidesz + dk
foreach part in fidesz dk tisza {
    generate `part'_share = `part' / part_total
    foreach p in `partok' {
        generate `p'_X_`part' = `p' * `part'_share
    }
}

foreach jelolt in `jeloltek' {
    regress `jelolt' `partok' if part_total>0, noconstant
    foreach part in `partok' {
        scalar `jelolt'_`part' = _b[`part']
        *assert inrange(`jelolt'_`part', 0, 1)
    }
    predict `jelolt'_predict, xb
    generate ae_`jelolt' = abs(`jelolt'_predict - `jelolt') / total * 100
    scatter `jelolt' `jelolt'_predict, msize(tiny)

    * evaluate model
    summarize ae_`jelolt', detail
    scalar hiba_`jelolt' = r(p95)

    * check for nonlinearity
    regress `jelolt' `partok' *_X_fidesz
}

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
