# `minio_stack`

This is how minio was deployed as a docker swarm service:

    swx environment set MINIO_ACCESS_KEY "AKIA$(pwgen 16 1 | tr '[a-z]' '[A-Z]')" | cut -d= -f2- | docker secret create access_key -
    swx environment set MINIO_SECRET_KEY "$(pwgen 40 1 -C)" | cut -d= -f2- | docker secret create secret_key -

## environment variables

    MINIO_ENABLE_FSMETA
    MINIO_TRACE
    MINIO_PROFILER
    MINIO_BROWSER
    MINIO_ACCESS_KEY
    MINIO_SECRET_KEY
    MINIO_CACHE_SIZE
    MINIO_CACHE_EXPIRY
    MINIO_MAXCONN
    MINIO_PROFILE_DIR

