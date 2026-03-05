FROM apache/superset:latest

USER root

RUN apt-get update && apt-get install -y \
    pkg-config \
    libmariadb-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Find and use the correct pip in the venv, or fallback to system pip
RUN if [ -f /app/.venv/bin/pip ]; then /app/.venv/bin/pip install psycopg2-binary mysqlclient; \
    elif [ -f /app/.venv/bin/python ]; then /app/.venv/bin/python -m pip install psycopg2-binary mysqlclient; \
    else pip install psycopg2-binary mysqlclient && cp -r /usr/local/lib/python3.*/dist-packages/psycopg2* /app/.venv/lib/python3.*/site-packages/ 2>/dev/null || true; \
    fi

ENV ADMIN_USERNAME $ADMIN_USERNAME
ENV ADMIN_EMAIL $ADMIN_EMAIL
ENV ADMIN_PASSWORD $ADMIN_PASSWORD
ENV DATABASE $DATABASE

COPY /config/superset_init.sh ./superset_init.sh
RUN chmod +x ./superset_init.sh

COPY /config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py
ENV SECRET_KEY $SECRET_KEY

USER superset

ENTRYPOINT [ "./superset_init.sh" ]
