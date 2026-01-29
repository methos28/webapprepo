FROM python:3.11-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/methos28/webapprepo.git

WORKDIR /webapprepo

RUN pip3 install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim

COPY --from=builder /install /usr/local

COPY --from=builder /webapprepo /webapprepo

WORKDIR /webapprepo

EXPOSE 80

ENTRYPOINT ["python", "./app.py"]
CMD ["--host=0.0.0.0", "--port=80"]
