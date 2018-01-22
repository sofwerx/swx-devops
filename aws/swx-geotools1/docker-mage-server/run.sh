#!/bin/bash -x

# Default the Environment Variables honored by MAGE
PORT="${PORT:-4242}"
ADDRESS="${ADDRESS:-0.0.0.0}"

# Use the docker container name of the mongo container by default.
# The docker-compose use of a network: allows one container to resolve the container name of another container on that same network.

MONGOHOST="${MONGOHOST:-mongo}"

# This really should be turned into proper 12factor.net environment variables as a PR upstream, instead of this silliness:
cat <<ENV_JS > environment/local/env.js
var util = require('util');

var environment = {};

environment.port = process.env.PORT || 4242;
environment.address = process.env.ADDRESS || "0.0.0.0";

var mongoConfig = {
  // username: 'changeme',
  // password: 'changeme',
  // ssl: true,
  scheme: 'mongodb',
  host: "${MONGOHOST}",
  port: 27017,
  db: "magedb",
  poolSize: 5
};

var credentials = (mongoConfig.username || mongoConfig.password) ?  util.format('%s:%s@', mongoConfig.username, mongoConfig.password) : '';
environment.mongo = {
  uri: mongoConfig.scheme + '://' + credentials + mongoConfig.host +  ':' + mongoConfig.port + '/' + mongoConfig.db + "?" + util.format('ssl=%s', mongoConfig.ssl),
  scheme: mongoConfig.scheme,
  host: mongoConfig.host,
  port: mongoConfig.port,
  db: mongoConfig.db,
  ssl: mongoConfig.ssl,
  poolSize: mongoConfig.poolSize
};

var serverOptions = {
  poolSize: mongoConfig.poolSize
};

// SSL configuration
// Comment out as nessecary to setup ssl between MAGE application MongoDB server
// Refer to the nodejs mongo driver docs for more information about these options
// http://mongodb.github.io/node-mongodb-native/2.0/tutorials/enterprise_features/
// You will also need to setup SSL on the mongodb side: https://docs.mongodb.com/v3.0/tutorial/configure-ssl/

// 2-way ssl configuration with x509 certificate
// environment.mongo.options = {
//   server: serverOptions,
//   user: '',
//   auth: {
//      authdb: '$external' ,
//      authMechanism: 'MONGODB-X509'
//    }
// };

// serverOptions.ssl = true;
// serverOptions.sslValidate = false;
// serverOptions.sslCA = fs.readFileSync('/etc/ssl/mongodb-cert.crt');
// serverOptions.sslKey = fs.readFileSync('/etc/ssl/mongodb.pem');
// serverOptions.sslCert = fs.readFileSync('/etc/ssl/mongodb-cert.crt');

environment.mongo.options = {
  server: serverOptions
};

environment.userBaseDirectory = '/var/lib/mage/users';
environment.iconBaseDirectory = '/var/lib/mage/icons';
environment.attachmentBaseDirectory = '/var/lib/mage/attachments';

environment.tokenExpiration = 28800;

module.exports = environment;
ENV_JS

# Having to dynamically patch the source to change the auth mechnism also needs some upstream PR help.
cat <<CONFIG > config.js
var packageJson = require('./package');
var version = packageJson.version.split(".");

module.exports = {
  api: {
    "name": packageJson.name,
    "description": packageJson.description,
    "version": {
      "major": parseInt(version[0]),
      "minor": parseInt(version[1]),
      "micro": parseInt(version[2])
    },
    "authenticationStrategies": {
      //"anonymous": {
      //  "everythingisfine": 1
      //}
      "local": {
        "passwordMinLength": 5
      }
      // "google": {
      //   "url": " ",
      //   "callbackURL": " ",
      //   "clientID": " ",
      //   "clientSecret": " "
      // }
    },
    "provision": {
      "strategy": "uid"
    }
  },
  server: {
    "locationServices": {
     // "enabled": true,
      "userCollectionLocationLimit": 100
    },
    "mongodb": {
      "host": "${MONGOHOST}",
      "port": 27017,
      "db": "magedb",
      "poolSize": 5
    },
    "userBaseDirectory": "/var/lib/mage/users",
    "iconBaseDirectory": "/var/lib/mage/icons",
    "attachment": {
      "baseDirectory": "/var/lib/mage/attachments"
    },
    "token": {
      "expiration": 28800
    },
  }
};
CONFIG

# We don't need the ESRI "EPIC" plugin by default yet, but we really should allow some environment variables to set these values.
cat <<EPIC_CONFIG > plugins/mage-epic/config.json
{
  "enable": ${ESRI_ENABLE:-false},
  "esri": {
    "url": {
      "host": "${ESRI_URL_HOST}",
      "site": "${ESRI_URL_SITE}",
      "restServices": "${ESRI_URI_REST_SERVICES}",
      "folder": "${ESRI_URI_FOLDER}",
      "serviceName": "${ESRI_URL_SERVICE_NAME}",
      "serviceType": "${ESRI_URL_SERVICE_TYPE}",
      "layerId": "${ESRI_URL_LAYER_ID}"
    },
    "observations": {
      "7": {
        "enable": true,
        "interval": 30,
        "fields": [{
          "type": "Date",
          "mage": "timestamp",
          "esri": "EVENTDATE"
        },{
          "type": "Type",
          "mage": "type",
          "esri": "TYPE"
        },{
          "type": "String",
          "mage": "EVENTLEVEL",
          "esri": "EVENTLEVEL"
        },{
          "type": "String",
          "mage": "TEAM",
          "esri": "TEAM"
        },{
          "type": "String",
          "mage": "DESCRIPTION",
          "esri": "DESCRIPTION"
        }]
      }
    },
    "attachments": {
      "enable":true,
      "interval": 60
    }
  },
  "mongodb": {
    "url": "mongodb://${MONGOHOST}/magedb",
    "poolSize": 1
  }
}
EPIC_CONFIG

# This plugin generates image thumbnails. Enable it by default.
cat <<IMAGE_CONFIG > plugins/mage-image/config.json
{
  "enable": ${IMAGE_ENABLE:-false},
  "image": {
    "orient": true,
    "thumbSizes": [150, 320, 800, 1024, 2048],
    "interval": 60
  },
  "mongodb": {
    "url": "mongodb://${MONGOHOST}/magedb",
    "poolSize": 1
  }
}
IMAGE_CONFIG

# This plugin posts things to another MAGE server. Disabled by default.
cat <<RAGE_CONFIG > plugins/mage-rage/config.json
{
	"enable": ${RAGE_ENABLE:-false},
	"url": "",
	"credentials": {
		"username": "",
		"uid": "",
		"password": ""
	},
	"interval": 60,
        "mongodb": {
	  "url": "mongodb://${MONGOHOST}/magedb",
	  "poolSize": 1
	}
}
RAGE_CONFIG

if [ -d node_modules/environment ] ; then
  rm -rf node_modules/environment
fi
if [ -d node_modules/local-environment ] ; then
  rm -rf node_modules/local-environment
fi
npm install

# MAGE database setup
npm run migrate

#exec forever start app.js
exec node app.js

