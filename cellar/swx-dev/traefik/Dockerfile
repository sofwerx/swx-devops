FROM traefik:1.4-alpine

RUN apk --no-cache add bash
ADD run.sh /run.sh

ENTRYPOINT /run.sh

CMD traefik
