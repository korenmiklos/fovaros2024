local partok mkkp mihazank neppartjan munkaspart szolidaritas tisza lmp fidesz dk momentum ervenytelen
local jeloltek karacsony vitezy grundtner ervenytelen

generate total = karacsony + vitezy + grundtner

foreach jelolt in `jeloltek' {
    regress `jelolt' `partok', noconstant
    foreach part in `partok' {
        assert inrange(`jelolt'_`part', 0, 1)
        scalar `jelolt'_`part' = _b[`part']
    }
    predict `jelolt'_predict, xb
    generate ae_`jelolt' = abs(`jelolt'_predict - `jelolt') / total * 100

    * evaluate model
    summarize ae_`jelolt', detail
    scalar hiba_`jelolt' = r(p95)
}

* estimate total number of votes by combination of parties and candidates
collapse (sum) `partok', by(szavazokor)
expand 4
egen index = seq(), by(szavazokor)
generate jelolt = "karacsony" if index == 1
replace jelolt = "vitezy" if index == 2
replace jelolt = "grundtner" if index == 3
replace jelolt = "ervenytelen" if index == 4

foreach part in `partok' {
    rename `part' `part'_szavazatok
    generate `part' = 0
    foreach jelolt in `jeloltek' {
        replace `part' = `jelolt'_`part' * `part'_szavazatok if jelolt == "`jelolt'""
    }
}

list jelolt `partok'
