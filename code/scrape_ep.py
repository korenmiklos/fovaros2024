import requests
import json
from csv import DictWriter

from timestamp import ep_timestamp
URL = 'https://vtr.valasztas.hu/ep2024/data/{ep_timestamp}/szavossz/{maz:02d}/SzavkorJkv-{maz:02d}-{taz:03d}.json'


def get_json(maz, taz):
    return json.loads(requests.get(URL.format(maz=maz, taz=taz, ep_timestamp=ep_timestamp)).content)

def parse_json(data):
    data = data['data']
    maz = data['maz']
    taz = data['taz']
    for szkor in data['jegyzokonyvek']:
        szavazokor = szkor['sorsz']
        valasztopolgar = szkor['vp_osszes']
        megjelent = szkor['szk_megjelent']
        urnaban = szkor['szl_belyegzett_urna']
        ervenytelen = szkor['szl_ervenytelen']
        for jelolt in szkor['tetelek']:
            yield {
                'maz': maz,
                'taz': taz,
                'szavazokor': szavazokor,
                'valasztopolgar': valasztopolgar,
                'megjelent': megjelent,
                'urnaban': urnaban,
                'ervenytelen': ervenytelen,
                'jelolt': jelolt['szavlap_sorsz'],
                'szavazat': jelolt['szavazat'],
            }

def main():
    with open('data/2024/ep.csv', 'wt') as f:
        writer = DictWriter(f, fieldnames=['maz', 'taz', 'szavazokor', 'valasztopolgar', 'megjelent', 'urnaban', 'ervenytelen', 'jelolt', 'szavazat'])
        writer.writeheader()
        for taz in range(1, 23):
            data = get_json(1, taz)
            for row in parse_json(data):
                writer.writerow(row)

if __name__ == '__main__':
    main()