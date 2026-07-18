FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Cesty jsou konfigurovatelné — kontejner je tím pádem přenositelný.
ENV DATA_DIR=/data \
    OUTPUT_DIR=/output/charts

# Stáhne data a vygeneruje chart JSON (běh na vyžádání / z cronu):
#   docker compose run --rm datascrapper
CMD ["sh", "-c", "python run_all.py && python generate_json.py"]
