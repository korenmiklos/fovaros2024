import requests
import json
import pandas as pd

from timestamp import timestamp

data = [json.loads(requests.get(f'https://vtr.valasztas.hu/onk2024/data/{timestamp}/szavossz/01/SzavkorJkv-01-0{(2-len(str(i+1)))*"0"+str(i+1)}.json').content) for i in range(23)]
dt = []
jelolt = {1:"Grundtner",2:"Vitezy",3:"Szentkiralyi",4:"Karacsony"}
for ker in data:
    for y in ker['data']['tevk_csoport']:
        tevk = y['tevk']
        for x in y['jegyzokonyvek']:
            if x['szl_elteres']>0:
                correction = x['szl_elteres']
            else:
                correction = 0
            if x['valaltip']!="2":
                continue
            for y in x['tetelek']:
                dt.append({"Valasztas":"Fopolgarmester","MAZ":ker['data']['maz'],"TAZ":ker['data']['taz'],"Telepules":ker['data']['telnev'],"TEVK":tevk,"Jelolt":jelolt[y['szavlap_sorsz']],'Szavazat':max(y['szavazat']-correction,0),'szavkor':x['sorsz']})
            dt.append({"Valasztas":"Fopolgarmester","MAZ":ker['data']['maz'],"TAZ":ker['data']['taz'],"Telepules":ker['data']['telnev'],"TEVK":tevk,"Jelolt":'ervenytelen','Szavazat':x['szl_ervenytelen'],'szavkor':x['sorsz']})
             

pd.DataFrame(dt).to_csv('data/2024/fopolgarmester.csv', index=False)
