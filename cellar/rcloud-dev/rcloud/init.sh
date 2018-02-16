#!/bin/bash

cat <<EOH > /data/rcloud/conf/rcloud.conf
##------RCloud Configuration: For Docker Images ------
##: GitHub info below must be modified in order for RCloud to work!
Host: ${FQDN}
exec.auth: as-local
Cookie.Domain: ${FQDN}
EOH

if [ -n "${GITHUB_CLIENT_ID}" -a -n "${GITHUB_CLIENT_SECRET}" ]; then

  cat <<EOGHG >> /data/rcloud/conf/rcloud.conf
github.client.id: ${GITHUB_CLIENT_ID}
github.client.secret: ${GITHUB_CLIENT_SECRET}
github.base.url: https://github.com/
github.api.url: https://api.github.com/
github.gist.url: https://gist.github.com/
github.user.whitelist: ${GITHUB_USER_WHITELIST}
goodbye.page: goodbye.R
EOGHG

else

  cat <<EOGG >> /data/rcloud/conf/rcloud.conf
gist.backend: gitgist
gist.git.root: ${ROOT}/data/gists
goodbye.page: dockerbye.R
EOGG

fi

cat <<EOM >> /data/rcloud/conf/rcloud.conf
rcloud.alluser.addons: rcloud.viewer, rcloud.enviewer, rcloud.notebook.info, rcloud.logo, rcloud.htmlwidgets, rcloud.rmd, rcloud.flexdashboard
rcloud.languages: rcloud.r, rcloud.python, rcloud.rmarkdown, rcloud.sh
#compute.separation.modes: IDE
rcloud.deployment: Docker
rcloud.deployment.color: orange
CRAN.mirror: http://r.research.att.com/
Welcome.page: index.html
EOM

if [ -n "${REDIS_HOST}" ]; then
  cat <<EOR >> /data/rcloud/conf/rcloud.conf
rcs.engine: redis
rcs.redis.host: ${REDIS_HOST}
EOR
fi

if [ -n "${SOLR_HOST}" ]; then
  cat <<EOS >> /data/rcloud/conf/rcloud.conf
solr.url: http://${SOLR_HOST}:8983/solr/rcloudnotebooks
EOS
fi

sudo su - rcloud -c "ROOT=/data/rcloud /data/rcloud/conf/start"
sudo su - rcloud -c "/data/rcloud/docker/ulogd/ulogd /data/rcloud/run/ulog"
