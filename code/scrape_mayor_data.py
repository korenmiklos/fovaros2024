import requests
import json
import pandas as pd

# SET A VALID VALASZTAS.HU TIMESTAMP HERE
timestamp = '06092233'

data = [json.loads(requests.get(f'https://vtr.valasztas.hu/onk2024/data/{timestamp}/szavossz/01/SzeredmTelep-01-0{(2-len(str(i+1)))*"0"+str(i+1)}.json').content) for i in range(23)]

dt = []
jelolt = {1:"Grundtner",2:"Vitezy",3:"Szentkiralyi",4:"Karacsony"}
for ker in data:
    for x in ker['data']['tevk_csoport']:
        if x['eredmenyek'][0]['valaltip']!="2":
            continue
        for y in x['eredmenyek'][0]['tetelek']:
            dt.append({"Valasztas":"Fopolgarmester","MAZ":ker['data']['maz'],"TAZ":ker['data']['taz'],"Telepules":ker['data']['telnev'],"TEVK":x['tevk'],"Jelolt":jelolt[y['szavlap_sorsz']],'Szavazat':y['szavazat']})

pd.DataFrame(dt).to_csv('data/2024/fopolgarmester.csv', index=False)
