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
## Neither the name of the SONATA-NFV
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).

# @see SonCatalogue
class SonataCatalogue < Sinatra::Application
  require 'json'
  require 'yaml'
  require 'digest/md5'

  # Read config settings from config file
  # @return [String, Integer] the address and port of the API
  def read_config
    begin
      config = YAML.load_file('config/config.yml')
      puts config['address']
      puts config['port']
    rescue YAML::LoadError => e
      # If config file is not found or valid, return with errors
      logger.error "read config error: #{e}"
    end

    return config['address'], config['port']
  end

  # Checks if a JSON message is valid
  # @param [JSON] message some JSON message
  # @return [Hash, nil] if the parsed message is a valid JSON
  # @return [Hash, String] if the parsed message is an invalid JSON
  def parse_json(message)
    # Check JSON message format
    begin
      parsed_message = JSON.parse(message) # parse json message
    rescue JSON::ParserError => e
      # If JSON not valid, return with errors
      logger.error "JSON parsing: #{e}"
      return message, e.to_s + "\n"
    end

    return parsed_message, nil
  end

  # Checks if a YAML message is valid
  # @param [YAML] message some YAML message
  # @return [Hash, nil] if the parsed message is a valid YAML
  # @return [Hash, String] if the parsed message is an invalid YAML
  def parse_yaml(message)
    # Check YAML message format
    begin
      parsed_message = YAML.load(message) # parse YAML message
        #puts 'PARSED_MESSAGE: ', parsed_message.to_yaml
    rescue YAML::ParserError => e
      # If YAML not valid, return with errors
      logger.error "YAML parsing: #{e}"
      return message, e.to_s + "\n"
    end

    return parsed_message, nil
  end

  # Translates a message from YAML to JSON
  # @param [YAML] input_yml some YAML message
  # @return [Hash, nil] if the input message is a valid YAML
  # @return [Hash, String] if the input message is an invalid YAML
  def yaml_to_json(input_yml)
    #puts input_yml.to_s
    puts 'Parsing from YAML to JSON'

    begin
      #output_json = JSON.dump(YAML::load(input_yml))
      #puts 'input: ', input_yml.to_json
      output_json = JSON.dump(input_yml)
        #output_json = JSON.dump(input_yml.to_json)
    rescue
      logger.error 'Error parsing from YAML to JSON'
    end

    #puts 'Parsing DONE', output_json
    output_json
  end

  # Translates a message from JSON to YAML
  # @param [JSON] input_json some JSON message
  # @return [Hash, nil] if the input message is a valid JSON
  # @return [Hash, String] if the input message is an invalid JSON
  def json_to_yaml(input_json)
    require 'json'
    require 'yaml'

    begin
      output_yml = YAML.dump(JSON.parse(input_json))
    rescue
      logger.error 'Error parsing from JSON to YAML'
    end

    output_yml
  end

  def apply_limit_and_offset(input, offset= nil, limit= nil)
    @result = input
    @result = offset ? input.drop(offset.to_i) : @result
    @result = limit ? @result.first(limit.to_i) : @result
  end

  # Builds an HTTP link for pagination
  # @param [Integer] offset link offset
  # @param [Integer] limit link limit position
  def build_http_link_ns(offset, limit)
    link = ''
    # Next link
    next_offset = offset + 1
    next_nss = Ns.paginate(page: next_offset, limit: limit)

    address, port = read_config

    begin
      link << '<' + address.to_s + ':' + port.to_s + '/catalogues/network-services?offset=' + next_offset.to_s +
          '&limit=' + limit.to_s + '>; rel="next"' unless next_nss.empty?
    rescue
      logger.error 'Error Establishing a Database Connection'
    end

    unless offset == 1
      # Previous link
      previous_offset = offset - 1
      previous_nss = Ns.paginate(page: previous_offset, limit: limit)
      unless previous_nss.empty?
        link << ', ' unless next_nss.empty?
        link << '<' + address.to_s + ':' + port.to_s + '/catalogues/network-services?offset=' + previous_offset.to_s +
            '&limit=' + limit.to_s + '>; rel="last"'
      end
    end
    link
  end

  # Builds an HTTP pagination link header
  # @param [Integer] offset the pagination offset requested
  # @param [Integer] limit the pagination limit requested
  # @return [String] the built link to use in header
  def build_http_link_vnf(offset, limit)
    link = ''
    # Next link
    next_offset = offset + 1
    next_vnfs = Vnf.paginate(page: next_offset, limit: limit)

    address, port = read_config

    link << '<' + address.to_s + ':' + port.to_s + '/catalogues/vnfs?offset=' + next_offset.to_s + '&limit=' +
        limit.to_s + '>; rel="next"' unless next_vnfs.empty?

    unless offset == 1
      # Previous link
      previous_offset = offset - 1
      previous_vnfs = Vnf.paginate(page: previous_offset, limit: limit)
      unless previous_vnfs.empty?
        link << ', ' unless next_vnfs.empty?
        link << '<' + address.to_s + ':' + port.to_s + '/catalogues/vnfs?offset=' + previous_offset.to_s +
            '&limit=' + limit.to_s + '>; rel="last"'
      end
    end
    link
  end

  # Extension of build_http_link
  def build_http_link_ns_name(offset, limit, name)
    link = ''
    # Next link
    next_offset = offset + 1
    next_nss = Ns.paginate(page: next_offset, limit: limit)
    address, port = read_config

    begin
      link << '<' + address.to_s + ':' + port.to_s + '/catalogues/network-services/name/' + name.to_s +
          '?offset=' + next_offset.to_s + '&limit=' + limit.to_s + '>; rel="next"' unless next_nss.empty?
    rescue
      logger.error 'Error Establishing a Database Connection'
    end

    unless offset == 1
      # Previous link
      previous_offset = offset - 1
      previous_nss = Ns.paginate(page: previous_offset, limit: limit)
      unless previous_nss.empty?
        link << ', ' unless next_nss.empty?
        link << '<' + address.to_s + ':' + port.to_s + '/catalogues/network-services/name/' + name.to_s +
            '?offset=' + previous_offset.to_s + '&limit=' + limit.to_s + '>; rel="last"'
      end
    end
    link
  end

  def checksum(contents)
    result = Digest::MD5.hexdigest contents #File.read
    result
  end

  def keyed_hash(hash)
    Hash[hash.map { |(k, v)| [k.to_sym, v] }]
  end

  class Pair
    attr_accessor :one, :two

    def initialize(one, two)
      @one = one
      @two = two
    end
  end

  # Method that returns an error code and a message in json format
  def json_error(code, message)
    msg = {'error' => message}
    logger.error msg.to_s
    halt code, {'Content-type' => 'application/json'}, msg.to_json
  end

  # Method that returns a code and a message in json format
  def json_return(code, message)
    msg = {'OK' => message}
    logger.info msg.to_s
    halt code, {'Content-type' => 'application/json'}, msg.to_json
  end

  # Method which lists all available interfaces
  # @return [Array] an array of hashes containing all interfaces
  def interfaces_list
    [
      {
        'uri' => '/catalogues',
        'method' => 'GET',
        'purpose' => 'REST API Structure and Capability Discovery'
      },
      {
        'uri' => '/catalogues/network-services',
        'method' => 'GET',
        'purpose' => 'List all NSs or specific NS',
        'special' => 'Use version=last to retrieve NSs last version'
      },
      {
        'uri' => '/catalogues/network-services/{id}',
        'method' => 'GET',
        'purpose' => 'List a specific NS by its uuid'
      },
      {
        'uri' => '/catalogues/network-services',
        'method' => 'POST',
        'purpose' => 'Store a new NS'
      },
      {
        'uri' => '/catalogues/network-services',
        'method' => 'PUT',
        'purpose' => 'Update a stored NS specified by vendor, name, version'
      },
      {
        'uri' => '/catalogues/network-services/{id}',
        'method' => 'PUT',
        'purpose' => 'Update a stored NS by its uuid',
        'special' => 'Use status=[inactive, active, delete] to update NSD status'
      },
      {
        'uri' => '/catalogues/network-services',
        'method' => 'DELETE',
        'purpose' => 'Delete a specific NS specified by vendor, name, version'
      },
      {
        'uri' => '/catalogues/network-services/{id}',
        'method' => 'DELETE',
        'purpose' => 'Delete a specific NS by its uuid'
      },
      {
        'uri' => '/catalogues/vnfs',
        'method' => 'GET',
        'purpose' => 'List all VNFs or specific VNF',
        'special' => 'Use version=last to retrieve VNFs last version'
      },
      {
        'uri' => '/catalogues/vnfs/{id}',
        'method' => 'GET',
        'purpose' => 'List a specific VNF by its uuid'
      },
      {
        'uri' => '/catalogues/vnfs',
        'method' => 'POST',
        'purpose' => 'Store a new VNF'
      },
      {
        'uri' => '/catalogues/vnfs',
        'method' => 'PUT',
        'purpose' => 'Update a stored VNF specified by vendor, name, version'
      },
      {
        'uri' => '/catalogues/vnfs/{id}',
        'method' => 'PUT',
        'purpose' => 'Update a stored VNF by its uuid',
        'special' => 'Use status=[inactive, active, delete] to update VNFD status'
      },
      {
        'uri' => '/catalogues/vnfs',
        'method' => 'DELETE',
        'purpose' => 'Delete a specific VNF specified by vendor, name, version'
      },
      {
        'uri' => '/catalogues/vnfs/{id}',
        'method' => 'DELETE',
        'purpose' => 'Delete a specific VNF by its uuid'
      },
      {
        'uri' => '/catalogues/packages',
        'method' => 'GET',
        'purpose' => 'List all Packages or specific Package',
        'special' => 'Use version=last to retrieve Packages last version'
      },
      {
        'uri' => '/catalogues/packages/{id}',
        'method' => 'GET',
        'purpose' => 'List a specific Package by its uuid'
      },
      {
        'uri' => '/catalogues/packages',
        'method' => 'POST',
        'purpose' => 'Store a new Package'
      },
      {
        'uri' => '/catalogues/packages',
        'method' => 'PUT',
        'purpose' => 'Update a stored Package specified by vendor, name, version'
      },
      {
        'uri' => '/catalogues/packages/{id}',
        'method' => 'PUT',
        'purpose' => 'Update a stored Package by its uuid',
        'special' => 'Use status=[inactive, active, delete] to update PD status'
      },
      {
        'uri' => '/catalogues/packages',
        'method' => 'DELETE',
        'purpose' => 'Delete a specific Package specified by vendor, name, version'
      },
      {
        'uri' => '/catalogues/packages/{id}',
        'method' => 'DELETE',
        'purpose' => 'Delete a specific Package by its uuid'
      },
      {
        'uri' => '/catalogues/son-packages',
        'method' => 'GET',
        'purpose' => 'List all son-packages or specific son-package'
      },
      {
        'uri' => '/catalogues/son-packages',
        'method' => 'POST',
        'purpose' => 'Store a new son-package'
      },
      {
        'uri' => '/catalogues/son-packages/{id}',
        'method' => 'GET',
        'purpose' => 'List a specific son-package by its uuid'
      },
      {
        'uri' => '/catalogues/son-packages/{id}',
        'method' => 'DELETE',
        'purpose' => 'Remove a son-package'
      }
    ]
  end
end
