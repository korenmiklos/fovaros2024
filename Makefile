data/2024/budapest_becsles.csv: code/estimate.do data/2024/budapest.dta
	stata -b do $<
data/2024/budapest.dta: code/clean.do data/2024/budapest_party_list.csv data/2024/fopolgarmester.csv
	stata -b do $<
data/2024/budapest_party_list.csv: code/scrape_party_list.py
	poetry run python $<
data/2024/fopolgarmester.csv: code/scrape_mayor_data.py
	poetry run python $<