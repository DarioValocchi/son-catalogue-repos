##
## Copyright (c) 2015 SONATA-NFV
## ALL RIGHTS RESERVED.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## Neither the name of the SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).

source 'https://rubygems.org'

gem 'addressable'
gem 'rake'
gem 'sinatra', '~> 1.4.3', require: 'sinatra/base'
gem 'sinatra-contrib', '~> 1.4.1', require: false
gem 'puma'
gem 'json', '~>1.8'
# gem 'nokogiri', '~>1.6'
gem 'json-schema', '~>2.5'
gem 'rest-client', '~>1.8'
# gem 'rubysl-securerandom', '~> 2.0'
gem 'ci_reporter_rspec'
# gem 'logstash-logger'

group :development, :test do
  gem 'webmock'
  # gem 'rerun'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec-its'
  # gem 'database_cleaner'
  # gem 'factory_girl'
  gem 'rubocop'
  gem 'rubocop-checkstyle_formatter', require: false
  # gem 'json_spec', '~>1.1.4'
  # gem 'database_cleaner'
  # gem 'mongoid-rspec', '~> 2.2.0'
  gem 'license_finder'
end

group :doc do
  gem 'yard', '~>0.8'
end

# Database
gem 'mongoid', '~>4.0' # MongoDB driver
gem 'mongoid-pagination', '~>0.2' # Pagination library
gem 'mongoid-grid_fs', '~>2.2' # mongoid-grid_fs-2.2 - GridFS for store bin data
# gem 'sinatra-gkauth', '~>0.2.0', path: '../sinatra-gkauth-gem' # <- Disabled
