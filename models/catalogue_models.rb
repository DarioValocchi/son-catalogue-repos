##
## Copyright 2015-2017 i2CAT Foundation
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##   http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

# Convert BSON ID to String
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

# Sonata class for Catalogue Services
class Ns
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Mongoid::Attributes::Dynamic
  store_in collection: 'nsd'

  field :vendor, type: String
  field :name, type: String
  field :version, type: String

  validates :vendor, :name, :version, presence: true
end

# Sonata class for Catalogue Functions
class Vnf
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  # include Mongoid::Versioning
  include Mongoid::Attributes::Dynamic
  store_in collection: 'vnfd'

  field :vendor, type: String
  field :name, type: String
  field :version, type: String
  # field :vnf_manager, type: String # <- Not applicable yet

  validates :vendor, :name, :version, presence: true
end

# Sonata class for Catalogue Packages
class Package
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  # include Mongoid::Versioning
  include Mongoid::Attributes::Dynamic
  store_in collection: 'pd'

  field :vendor, type: String
  field :name, type: String
  field :version, type: String

  validates :vendor, :name, :version, presence: true
end

# Class model for binary data storage on database
require 'mongoid/grid_fs'

# Sonata class for Catalogue son-packages
class FileContainer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  store_in collection: 'file_containers'

  field :grid_fs_id, type: String
  # field :grid_fs_vendor, type: String
  field :grid_fs_name, type: String
  # field :grid_fs_version, type: String
  field :md5, type: String
end
