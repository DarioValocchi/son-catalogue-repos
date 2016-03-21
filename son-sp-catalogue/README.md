[![Build Status](http://jenkins.sonata-nfv.eu/buildStatus/icon?job=son-sp-catalogue)](http://jenkins.sonata-nfv.eu/job/son-sp-catalogue/)

# SONATA WP4

## Service Platform (SP) NS - VNF - Package Descriptors Catalogues

The following repository contains the SONATA CATALOGUE (son-catalogue component) code which implements:

* SON-SP-CATALOGUE API for various elements' Descriptors (meta-data) such NSDs and VNFDs for the Service Platform.

*Support for Package Descriptors (PDs) will be added soon.


### Requirements

It is recommended to use Ubuntu 14.04.4 LTS (Trusty Tahr).

This code has been run on Ruby 2.1.

MongoDB is required, this code has been run using MongoDB version 3.2.1.

Root folder provides a script "installation_mongodb.sh" to install and set up MongoDB.


### Gems used

* [Sinatra](http://www.sinatrarb.com/) - Ruby framework
* [Thin](https://github.com/macournoyer/thin/) - Web server
* [json](https://github.com/flori/json) - JSON specification
* [sinatra-contrib](https://github.com/sinatra/sinatra-contrib) - Sinatra extensions
* [Nokogiri](https://github.com/sparklemotion/nokogiri) - XML parser
* [JSON-schema](https://github.com/ruby-json-schema/json-schema) - JSON schema validator
* [Rest-client](https://github.com/rest-client/rest-client) - HTTP and REST client
* [Yard](https://github.com/lsegal/yard) - Documentation generator tool
* [rerun](https://github.com/alexch/rerun) - Restarts the app when a file changes (used in development environment)
* [SecureRandom] (https://rubygems.org/gems/rubysl-securerandom) - Ruby standard lib for UUID generation


### Installation

Before installing the Catalogues API from source code, it is recommended to install a fresh MongoDB database. It can be done with the "installation_mongodb.sh" script provided in the root folder. This script installs MongoDB and uses the "dbs.js" script to build a database structure in the MongoDB for each catalogue. The default IP address for local development environment is 'localhost:27017'. However, if the MongoDB is already installed, "dbs.js" script can be used standalone, just follow the instructions inside the file. If the MongoDB is found remotely, then the "dbs.js" script needs to be changed according to the IP and Port address of the MongoDB.

For the Catalogues, after cloning the source code from the repository, you can run:

```sh
bundle install
```

It will install all the gems needed to run the SON-CATALOGUE API.

### Tests

TODO: Unit-tests, integration-tests

For manual testings, please visit the wikipage link below which contains some information to interact and test the Catalogues API.

* [Testing the code](http://wiki.sonata-nfv.eu/index.php/SONATA_Catalogues) - Inside SDK Catalogue API Documentation (It currently works for SP Catalogues)


### API Documentation

The API documentation is expected to be generated with APIDOC soon. Further information can be found on SONATA's wikipages link for SONATA Catalogues:

* [SONATA Catalogues](http://wiki.sonata-nfv.eu/index.php/SONATA_Catalogues) - SONATA Catalogues on wikipages

* [son-catalogue wiki]() - Github wikipages (Soon...)


Currently, the API is documented with yardoc and can be built with a rake task:

```sh
rake yard
```

From here you can use the yard server to browse the docs from the source root:

```sh
yard server
```

And they can be viewed from http://localhost:8808/

### Run Server

The following shows how to start the API server:

```sh
rake start
```


### Data model

Last version of the API supports the Network Service Descriptors (NSD) and Virtual Network Functions Descriptors (VNFD) following the data model specified in the 'son-schema' repository in YAML format.
Next work is to feature support of Package Descriptors.


### Useful tools

To support working and testing with the son-catalogue database it is optional to use next tools:

* [Robomongo](https://robomongo.org/download) - Robomongo 0.9.0-RC4

* [POSTMAN](https://www.getpostman.com/) - Chrome Plugin for HTTP communication



### Lead developers

The following lead developers are responsible for this repository:

* Shuaib Siddiqui (shuaibsiddiqui)

* Daniel Guija (dang03)


