FROM python:3.10-slim

ENV PYTHONUNBUFFERED True
ENV APP_HOME /app
WORKDIR $APP_HOME

COPY requirements.txt .

RUN pip install --no-cache-dir --requirement requirements.txt

COPY main.py .

CMD exec gunicorn --bind :$PORT --workers 1 --threads 1 --timeout 0 main:app
