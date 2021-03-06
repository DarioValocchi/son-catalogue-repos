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

module BSON
  class ObjectId
    def to_json(*)
      to_s.to_json
    end
    def as_json(*)
      to_s.as_json
    end
  end
end

module Mongoid
  module Document
    def serializable_hash(options = nil)
      h = super(options)
      h['uuid'] = h.delete('_id') if(h.has_key?('_id'))
      h
    end
  end
end

# This is the Class for Network Services Records
class Nsr
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Mongoid::Attributes::Dynamic
  store_in collection: 'nsr'
  # Sonata schema NSD Fields
  field :id, type: String
  field :name, type: String
  field :vendor, type: String
  field :version, type: String
  field :vnfds, type: String
  field :vnffgrd, type: Array
  field :lifecycle_event, type: Object
  field :vnf_dependency, type: Array
  field :monitoring_parameter, type: Array
  field :vld, type: Object
  field :sla, type: Array
  field :auto_scale_policy, type: Object
  field :connection_point, type: Array
  # nsr ETSI fields MAN001 6.2.2.1
  field :service_deployment_flavour, type: String
  field :vnfr, type: Array
  field :pnfr, type: Array
  field :descriptor_reference, type: String
  field :resource_reservation, type: Array
  field :runtime_policy_info, type: Array
  field :status, type: String
  field :notification, type: String
  field :lifecycle_event_history, type: Array
  field :audit_log, type: Array
  # Sonata's custom fields
  field :mapping_time, type: Time
  field :instantiation_start_time, type: Time
  field :instantiation_end_time, type: Time
  # future fields: Slicing and Recursiveness
end
