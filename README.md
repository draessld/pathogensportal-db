# pathogensportal-db

Datová vrstva Pathogen Portalu: **scrapery** externích zdrojů, **schéma databáze** a **generátor
JSON podkladů** pro grafy na webu. Používá se samostatně i jako **git submodule** portálu
[`pathogensportal`](https://github.com/draessld/pathogensportal).

## Struktura

```
scrapers/          scrapery zdrojů (MZČR, ECDC, SZÚ, ÚZIS ISIN)
run_all.py         spustí všechny scrapery  -> $DATA_DIR
generate_json.py   $DATA_DIR (CSV) -> $OUTPUT_DIR (chart JSON pro Chart.js)
db/init.sql        schéma PostgreSQL (tabulky pathogens, dashboard_data)
nextstrain/        podklady pro fylogenetické analýzy
Dockerfile         kontejner `datascrapper` (scrape + generate)
```

## Datový tok

```
externí zdroje ──scrapers──> $DATA_DIR/*.csv ──generate_json──> $OUTPUT_DIR/*.json ──> web (Chart.js)
```

> Pozn.: `db/init.sql` je schéma pro **budoucí** DB vrstvu — současné scrapery zapisují do CSV,
> do PostgreSQL zatím nepíšou.

## Přenositelnost (důležité)

Všechny cesty jsou konfigurovatelné přes proměnné prostředí, takže repo funguje samostatně
i vložené do jiného projektu:

| Proměnná | Výchozí | Význam |
|---|---|---|
| `DATA_DIR` | `./data` | kam se ukládají stažená CSV |
| `OUTPUT_DIR` | `./output/charts` | kam se generuje chart JSON |

## Použití

```bash
pip install -r requirements.txt
python run_all.py          # stáhne data do ./data
python generate_json.py    # vygeneruje ./output/charts/*.json
```

Jako submodule portálu (vygeneruje rovnou do frontendu):
```bash
OUTPUT_DIR=../frontend/static/data/charts python generate_json.py
```

Kontejner:
```bash
docker build -t datascrapper .
docker run --rm -v "$PWD/data:/data" -v "$PWD/output:/output" datascrapper
```

## Jak to konzumuje portál

Portál má tento repozitář jako **git submodule** a používá ho dvěma způsoby:
1. **Chart JSON** — vygenerovaný výstup se commituje do `frontend/static/data/charts/`
   (web zůstává čistě statický, bez závislosti při buildu).
2. **Kontejnery** *(výhledově)* — `datascrapper` se builduje z tohoto adresáře a `pathogen-db`
   (PostgreSQL) použije `db/init.sql` jako schéma.
