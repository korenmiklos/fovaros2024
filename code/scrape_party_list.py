import requests
import json
import pandas as pd

# SET A VALID VALASZTAS.HU TIMESTAMP HERE
timestamp = '06092233'

data = [json.loads(requests.get(f'https://vtr.valasztas.hu/onk2024/data/{timestamp}/szavossz/01/SzeredmTelep-01-0{(2-len(str(i+1)))*"0"+str(i+1)}.json').content) for i in range(23)]

dt = []
jelolt = {1:"MKKP",2:"Mi Hazank",3:"Nep Partjan",4:"Munkaspart",5:"Szolidaritas",6:"TISZA",7:"Vitezy-LMP",8:"FIDESZ",9:"DK-MSZP-PARBESZED",10:"MOMENTUM"}
for ker in data:
    for x in ker['data']['tevk_csoport']:
        if x['eredmenyek'][0]['valaltip']!="F":
            continue
        for y in x['eredmenyek'][0]['tetelek']:
            dt.append({"Valasztas":"Fovarosi lista","MAZ":ker['data']['maz'],"TAZ":ker['data']['taz'],"Telepules":ker['data']['telnev'],"TEVK":x['tevk'],"Lista":jelolt[y['szavlap_sorsz']],'Szavazat':y['szavazat']})

pd.DataFrame(dt).to_csv('data/2024/budapest_party_list.csv', index=False)
