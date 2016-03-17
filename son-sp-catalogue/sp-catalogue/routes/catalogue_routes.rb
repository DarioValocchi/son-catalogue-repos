=begin
APIDOC comment
=end

# @see SonCatalogue
class SonataCatalogue < Sinatra::Application

	before do

		# Gatekeepr authn. code will go here for future implementation
		# --> Gatekeeper authn. disabled
		#if request.path_info == '/gk_credentials'
		#	return
		#end

		if settings.environment == 'development'
			return
		end

		#authorized?
	end


	### NSD API METHODS ###

	# @method get_log
	# @overload get '/network-services/log'
	#	Returns contents of log file
	# Management method to get log file of catalogue remotely
	get '/log' do
		filename = 'log/development.log'

		# For testing purposes only
		begin
			txt = open(filename)

		rescue => err
			logger.error "Error reading log file: #{err}"
			return 500, "Error reading log file: #{err}"
		end

		#return 200, nss.to_json
		return 200, txt.read.to_s
	end


	# @method get_root
	# @overload get '/'
	# Get all available interfaces
	# -> Get all interfaces
	get '/' do
		halt 200, interfaces_list.to_yaml
	end


	# @method get_nss
	# @overload get '/network-services'
	#	Returns a list of NSs
	# -> List all NSs
	get '/network-services' do
		params[:offset] ||= 1
		params[:limit] ||= 10

		# Only accept positive numbers
		params[:offset] = 1 if params[:offset].to_i < 1
		params[:limit] = 2 if params[:limit].to_i < 1

		# Get paginated list
		nss = Ns.paginate(:page => params[:offset], :limit => params[:limit])

		# Build HTTP Link Header
		headers['Link'] = build_http_link_ns(params[:offset].to_i, params[:limit])

		begin
			nss_json = nss.to_json
			#puts 'NSS: ', nss_json
			nss_yml = json_to_yaml(nss_json)
			#puts 'NSS: ', nss_yml
		rescue
			logger.error "Error Establishing a Database Connection"
			return 500, "Error Establishing a Database Connection"
		end

		#return 200, nss.to_json
		return 200, nss_yml
	end


	# @method get_ns_external_ns_id
	# @overload get '/network-services/id/:external_ns_id'
	#	Show a NS
	#	@param [Integer] external_ns_id NS external ID
	# Show a NS
	get '/network-services/id/:external_ns_id' do
		begin
			ns = Ns.find(params[:external_ns_id] )
			#ns = Ns.find_by( { "nsd.id" =>  params[:external_ns_id]})
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		ns_json = ns.to_json
		#puts 'NSS: ', nss_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, ns.nsd.to_json
	end


	# @method get_nss_ns_name
	# @overload get '/network-services/:external_ns_name'
	#	Show a NS or NS list
	#	@param [String] external_ns_name NS external Name
	# Show a NS by name
	get '/network-services/name/:external_ns_name' do
		raise NotImplementedError
		#params[:offset] ||= 1
		#params[:limit] ||= 10

		# Only accept positive numbers
		#params[:offset] = 1 if params[:offset].to_i < 1
		#params[:limit] = 2 if params[:limit].to_i < 1

		begin
			# Get paginated list
			#ns = Ns.paginate(:page => params[:offset], :limit => params[:limit])

			# Build HTTP Link Header
			#headers['Link'] = build_http_link_name(params[:offset].to_i, params[:limit], params[:external_ns_name])

			#ns = Ns.distinct( "nsd.version" )#.where({ "nsd.name" =>  params[:external_ns_name]})
			ns = Ns.where({"ns_name" => params[:external_ns_name]})
			puts 'NS: ', ns.size.to_s

			if ns.size.to_i == 0
				logger.error "ERROR: NSD not found"
				return 404
			end

		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end
		ns_json = ns.to_json
		#puts 'NS: ', ns_json[0]
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
	end


	# @method get_nsd_external_ns_version
	# @overload get '/network-services/:external_ns_name/version/:version'
	#	Show a NS
	#	@param [String] external_ns_name NS external Name
	# Show a NS name
	#	@param [Integer] external_ns_version NS version
	# Show a NS version
	get '/network-services/name/:external_ns_name/version/:version' do
		begin
			ns = Ns.find_by({"ns_name" =>  params[:external_ns_name], "ns_version" => params[:version]})
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		ns_json = ns.to_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, ns.nsd.to_json
	end


	# @method get_nsd_external_ns_last_version
	# @overload get '/network-services/:external_ns_name/last'
	#	Show a NS last version
	#	@param [String] external_ns_name NS external Name
	# Show a NS name
	get '/network-services/name/:external_ns_name/last' do

		# Search and get all items of NS by name
		begin
			puts 'params', params
			# Get paginated list
			#ns = CatalogueModels.paginate(:page => params[:offset], :limit => params[:limit])

			# Build HTTP Link Header
			#headers['Link'] = build_http_link_name(params[:offset].to_i, params[:limit], params[:external_ns_name])

			#ns = Ns.distinct( "nsd.version" )#.where({ "nsd.name" =>  params[:external_ns_name]})
			#ns = Ns.where({"nsd.name" => params[:external_ns_name]})
			ns = Ns.where({"ns_name" => params[:external_ns_name]}).sort({"ns_version" => -1}).limit(1).first()
			puts 'NS: ', ns

			if ns == nil
				logger.error "ERROR: NSD not found"
				return 404
			end

		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		# Got a list, then for each item convert version field to float and get the higher

		#puts 'NS size: ', ns.size.to_s
		#puts 'version example', '4.1'.to_f

		ns_json = ns.to_json
		puts 'NS: ', ns_json

		#if ns_json == 'null'
		#	logger.error "ERROR: NSD not found"
		#	return 404
		#end
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml

		#return 200, ns.nsd.to_json
		#return 200, ns.to_json
	end


	# @method post_nss
	# @overload post '/network-services'
	# Post a NS in YAML format
	# @param [YAML] NS in YAML format
	# Post a NSD
	post '/network-services' do
		# Return if content-type is invalid
		return 415 unless request.content_type == 'application/x-yaml'

		# Support compatibility for JSON content-type??
		#return 415 unless request.content_type == 'application/json'

		# Validate YAML format
		ns, errors = parse_yaml(request.body.read)
		#ns, errors = parse_yaml(request.body)
		#puts 'NS :', ns.to_yaml
		#puts 'errors :', errors.to_s

		return 400, errors.to_json if errors

		# Translate from YAML format to JSON format
		#ns_yml = ns.nsd.to_json
		ns_json = yaml_to_json(ns)
		#ns_json = yaml_to_json(request.body.read)

		# Validate JSON format
		#ns, errors = parse_json(request.body.read)
		#ns, errors = parse_json(ns.to_json)
		ns, errors = parse_json(ns_json)
		puts 'ns: ', ns.to_json
		return 400, errors.to_json if errors

		#logger.debug ns
		# Validate NS
		#return 400, 'ERROR: NS Name not found' unless ns.has_key?('name')
		#return 400, 'ERROR: NSD not found' unless ns.has_key?('nsd')

		return 400, 'ERROR: NS Name not found' unless ns.has_key?('ns_name')
		return 400, 'ERROR: NS Group not found' unless ns.has_key?('ns_group')
		return 400, 'ERROR: NS Version not found' unless ns.has_key?('ns_version')


		# --> Validation disabled
		# Validate NSD
		#begin
		#	RestClient.post settings.nsd_validator + '/nsds', ns.to_json, :content_type => :json
		#rescue => e
		#	halt 500, {'Content-Type' => 'text/plain'}, "Validator mS unrechable."
		#end
		
		#vnfExists(ns['nsd']['vnfds'])
		# Check if NS already exists in the catalogue by name, group and version
		begin
			ns = Ns.find_by({"ns_name" =>  ns['ns_name'], "ns_group" => ns['ns_group'], "ns_version" => ns['ns_version']})
			return 400, 'ERROR: Duplicated NS Name, Group and Version'
		rescue Mongoid::Errors::DocumentNotFound => e
		end
		# Check if NSD has an ID (it should not) and if it already exists in the catalogue
		begin
			ns = Ns.find_by({"_id" =>  ns['_id']})
			return 400, 'ERROR: Duplicated NS ID'
		rescue Mongoid::Errors::DocumentNotFound => e
		end

		# Save to DB
		begin
			# Generate the UUID for the descriptor
			ns['_id'] = SecureRandom.uuid
			new_ns = Ns.create!(ns)
		rescue Moped::Errors::OperationFailure => e
			return 400, 'ERROR: Duplicated NS ID' if e.message.include? 'E11000'
		end

		puts 'New NS has been added'
		ns_json = new_ns.to_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, new_ns.to_json
	end


	# @method update_nss
	# @overload put '/network-services/id/'
	# Update a NS in YAML format
	# @param [YAML] NS in YAML format
	# Update a NS
	## Catalogue - UPDATE
	put '/network-services/id/:external_ns_id' do

		# Return if content-type is invalid
		return 415 unless request.content_type == 'application/x-yaml'
		#return 415 unless request.content_type == 'application/json'

		# Validate YAML format
		# When updating a NSD, the json object sent to API must contain just data inside
		# of the nsd, without the json field nsd: before <- this might be resolved
		ns, errors = parse_yaml(request.body.read)
		return 400, errors.to_json if errors

		# Translate from YAML format to JSON format
		new_ns_json = yaml_to_json(ns)

		# Validate JSON format
		new_ns, errors = parse_json(new_ns_json)
		puts 'ns: ', new_ns.to_json
		puts 'new_ns id', new_ns['_id'].to_json
		return 400, errors.to_json if errors


		# Validate JSON format
		# When updating a NSD, the json object sent to API must contain just data inside
		# of the nsd, without the json field nsd: before <- this might be resolved
		#new_ns, errors = parse_json(request.body.read)
		#return 400, errors.to_json if errors

		# TODO: Check if same Group, Name, Version do already exists in the database
		# Retrieve stored version
		begin
			puts 'Searching ' + params[:external_ns_id].to_s

			ns = Ns.find_by( { "_id" =>  params[:external_ns_id] })

			puts 'NS is found'
		rescue Mongoid::Errors::DocumentNotFound => e
			return 400, 'This NSD does not exists'
		end

		# Update to new version
		nsd = {}
		prng = Random.new
		puts 'Updating...'
		#puts 'new_ns', new_ns['id']
		#new_id = new_ns['id'].to_i + prng.rand(1000)
		#new_ns['id'] = new_id.to_s
		#new_ns['id'] = new_ns['id'].to_s + prng.rand(1000).to_s # Without unique IDs
		#new_ns['_id'] = new_ns['_id'].to_s + prng.rand(1000).to_s	# Unique IDs per NSD entries
		new_ns['_id'] = SecureRandom.uuid
		nsd = new_ns # TODO: Avoid having multiple 'nsd' fields containers


		# --> Validation disabled
		# Validate NSD
		#begin
		#	RestClient.post settings.nsd_validator + '/nsds', nsd.to_json, :content_type => :json
		#rescue => e
		#	logger.error e.response
		#	return e.response.code, e.response.body
		#end

		begin
			new_ns = Ns.create!(nsd)
		rescue Moped::Errors::OperationFailure => e
			return 400, 'ERROR: Duplicated NS ID' if e.message.include? 'E11000'
		end

		ns_json = new_ns.to_json
		ns_yml = json_to_yaml(ns_json)
		return 200, ns_yml
		#return 200, new_ns.to_json
	end


	# @method delete_nsd_external_ns_id
	# @overload delete '/network-service/:external_ns_id'
	#	Delete a NS by its ID
	#	@param [Integer] external_ns_id NS external ID
	# Delete a NS
	delete '/network-services/id/:external_ns_id' do
		#logger.error params[:external_ns_id]
		begin
			#ns = CatalogueModels.find( params[:external_ns_id] )
			ns = Ns.find_by(params[:external_ns_id] )
		rescue Mongoid::Errors::DocumentNotFound => e
			return 404,'ERROR: Operation failed'
		end
		ns.destroy
		return 200, 'OK: NSD removed'
	end


	### VNFD API METHODS ###

	# @method get_vnfs
	# @overload get '/vnfs'
	#	Returns a list of VNFs
	# List all VNFs
	get '/vnfs' do
		params[:offset] ||= 1
		params[:limit] ||= 2

		# Only accept positive numbers
		params[:offset] = 1 if params[:offset].to_i < 1
		params[:limit] = 2 if params[:limit].to_i < 1

		# Get paginated list
		vnfs = Vnf.paginate(:page => params[:offset], :limit => params[:limit])

		# Build HTTP Link Header
		headers['Link'] = build_http_link_vnf(params[:offset].to_i, params[:limit])

		begin
			vnfs_json = vnfs.to_json
			#puts 'VNFS: ', vnfs_json
			vnfs_yml = json_to_yaml(vnfs_json)
				#puts 'VNFS: ', vnfs_yml
		rescue
			logger.error "Error Establishing a Database Connection"
			return 500, "Error Establishing a Database Connection"
		end

		#halt 200, vnfs.to_json
		return 200, vnfs_yml

	end


	# @method get_vnfs_id
	# @overload get '/vnfs/id/:id'
	#	Show a VNF
	#	@param [String] id VNF ID
	# Show a VNF
	get '/vnfs/id/:id' do
		begin
			vnf = Vnf.find(params[:id])
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			halt 404
		end

		vnf_json = vnf.to_json
		#puts 'VNFS: ', vnf_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml

		#halt 200, vnf.to_json
	end


	# @method get_vnfs_vnf_name
	# @overload get '/vnfs/:external_vnf_name'
	#	Show a VNF or VNF list
	#	@param [String] vnf_name VNF external Name
	# Show a VNF by name
	get '/vnfs/name/:vnf_name' do
		raise NotImplementedError
		#params[:offset] ||= 1
		#params[:limit] ||= 10

		# Only accept positive numbers
		#params[:offset] = 1 if params[:offset].to_i < 1
		#params[:limit] = 2 if params[:limit].to_i < 1

		begin
			# Get paginated list
			#ns = Vnf.paginate(:page => params[:offset], :limit => params[:limit])

			# Build HTTP Link Header
			#headers['Link'] = build_http_link_name(params[:offset].to_i, params[:limit], params[:vnf_name])

			#ns = Ns.distinct( "nsd.version" )#.where({ "nsd.name" =>  params[:external_ns_name]})
			vnf = Vnf.where({"vnf_name" => params[:vnf_name]})
			puts 'VNF: ', vnf.size.to_s

			if vnf.size.to_i == 0
				logger.error "ERROR: VNFD not found"
				return 404
			end

		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end
		vnf_json = vnf.to_json
		#puts 'VNF: ', vnf_json[0]
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
	end


	# @method get_vnfd_external_vnf_version
	# @overload get '/vnfs/:external_vnf_name/version/:version'
	#	Show a VNF
	#	@param [String] external_vnf_name VNF external Name
	# Show a VNF name
	#	@param [Integer] external_vnf_version VNF version
	# Show a VNF version
	get '/vnfs/name/:external_vnf_name/version/:version' do
		begin
#			ns = CatalogueModels.find( params[:external_ns_id] )
			vnf = Vnf.find_by( { "vnf_name" =>  params[:external_vnf_name], "vnf_version" => params[:version]})
		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		vnf_json = vnf.to_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
		#return 200, ns.nsd.to_json
	end


	# @method get_vnfd_external_vnf_last_version
	# @overload get '/vnfs/:external_vnf_name/last'
	#	Show a VNF last version
	#	@param [String] external_ns_name NS external Name
	# Show a VNF name
	get '/vnfs/name/:external_vnf_name/last' do

		# Search and get all items of NS by name
		begin
			puts 'params', params
			vnf = Vnf.where({"vnf_name" => params[:external_vnf_name]}).sort({"vnf_version" => -1}).limit(1).first()
			puts 'VNF: ', vnf

			if vnf == nil
				logger.error "ERROR: VNFD not found"
				return 404
			end

		rescue Mongoid::Errors::DocumentNotFound => e
			logger.error e
			return 404
		end

		vnf_json = vnf.to_json
		puts 'VNF: ', vnf_json

		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
	end


	# @method post_vnfs
	# @overload post '/vnfs'
	# 	Post a VNF in YAML format
	# 	@param [JSON] VNF in YAML format
	# Post a VNFD
	post '/vnfs' do
		# Return if content-type is invalid
		return 415 unless request.content_type == 'application/x-yaml'

		# Support compatibility for JSON content-type??
		#halt 415 unless request.content_type == 'application/json'

		# Validate YAML format
		vnf, errors = parse_yaml(request.body.read)
		#ns, errors = parse_yaml(request.body)
		#puts 'NS :', ns.to_yaml
		#puts 'errors :', errors.to_s
		#vnf = parse_json(request.body.read)
		return 400, errors.to_json if errors

		# Translate from YAML format to JSON format
		vnf_json = yaml_to_json(vnf)

		# Validate JSON format
		vnf, errors = parse_json(vnf_json)
		puts 'vnf: ', vnf.to_json
		return 400, errors.to_json if errors

		# Validate VNF
		#halt 400, 'ERROR: VNFD not found' unless vnf.has_key?('vnfd')
		return 400, 'ERROR: VNF Group not found' unless vnf.has_key?('vnf_group')
		return 400, 'ERROR: VNF Name not found' unless vnf.has_key?('vnf_name')
		return 400, 'ERROR: VNF Version not found' unless vnf.has_key?('vnf_version')

		# --> Validation disabled
		# Validate VNFD
		#begin
		#	RestClient.post settings.vnfd_validator + '/vnfds', vnf['vnfd'].to_json, 'X-Auth-Token' => @client_token, :content_type => :json
		#rescue Errno::ECONNREFUSED
		#	halt 500, 'VNFD Validator unreachable'
		#rescue => e
		#	logger.error e.response
		#	halt e.response.code, e.response.body
		#end

		# Check if VNF already exists in the catalogue by name, group and version
		begin
			vnf = Vnf.find_by( {"vnf_name"=>vnf['vnf_name'], "vnf_group" => vnf['vnf_group'], "vnf_version"=>vnf['vnf_version']} )
			return 400, 'ERROR: Duplicated VNF Name, Group and Version'
		rescue Mongoid::Errors::DocumentNotFound => e
		end
		# Check if VNFD has an ID (it should not) and if it already exists in the catalogue
		begin
			vnf = Ns.find_by({"_id" =>  vnf['_id']})
			return 400, 'ERROR: Duplicated VNF ID'
		rescue Mongoid::Errors::DocumentNotFound => e
		end

		# Save to BD
		begin
			# Generate the UUID for the descriptor
			vnf['_id'] = SecureRandom.uuid
			new_vnf = Vnf.create!(vnf)
		rescue Moped::Errors::OperationFailure => e
			halt 400, 'ERROR: Duplicated VNF ID' if e.message.include? 'E11000'
			halt 400, e.message
		end

		puts 'New VNF has been added'
		vnf_json = new_vnf.to_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
		#return 200, new_vnf.to_json
	end


	# @method update_vnfs
	# @overload put '/vnfs/id/:id'
	#	Update a VNF by its ID
	#	@param [String] id VNF ID
	# Update a VNF
	put '/vnfs/id/:id' do
		# Return if content-type is invalid
		return 415 unless request.content_type == 'application/x-yaml'
		#halt 415 unless request.content_type == 'application/json'

		# Validate JSON format
		#new_vnf = parse_json(request.body.read)

		# Validate YAML format
		# When updating a NSD, the json object sent to API must contain just data inside
		# of the nsd, without the json field nsd: before <- this might be resolved
		new_vnf, errors = parse_yaml(request.body.read)
		return 400, errors.to_json if errors

		# Translate from YAML format to JSON format
		new_vnf_json = yaml_to_json(new_vnf)

		# Validate JSON format
		new_vnf, errors = parse_json(new_vnf_json)
		puts 'vnf: ', new_vnf.to_json
		puts 'new_vnf id', new_vnf['_id'].to_json
		return 400, errors.to_json if errors

		# Validate VNF
		# TODO: Check if same Group, Name, Version do already exists in the database
		#halt 400, 'ERROR: VNFD not found' unless vnf.has_key?('vnfd')
		return 400, 'ERROR: VNF Group not found' unless new_vnf.has_key?('vnf_group')
		return 400, 'ERROR: VNF Name not found' unless new_vnf.has_key?('vnf_name')
		return 400, 'ERROR: VNF Version not found' unless new_vnf.has_key?('vnf_version')

		# Validate VNFD
		#begin
		#	RestClient.post settings.vnfd_validator + '/vnfds', new_vnf['vnfd'].to_json, 'X-Auth-Token' => @client_token, :content_type => :json
		#rescue Errno::ECONNREFUSED
		#	halt 500, 'VNFD Validator unreachable'
		#rescue => e
		#	logger.error e.response
		#	halt e.response.code, e.response.body
		#end

		# Retrieve stored version
		begin
			vnf = Vnf.find(params[:id])
		rescue Mongoid::Errors::DocumentNotFound => e
			halt 404 # 'This VNFD does not exists'
		end

		# Update to new version
		#vnf.update_attributes(new_vnf)
		vnfd = {}
		prng = Random.new
		puts 'Updating...'

		#new_vnf['_id'] = new_vnf['_id'].to_s + prng.rand(1000).to_s	# Unique IDs per VNFD entries
		new_vnf['_id'] = SecureRandom.uuid
		vnfd = new_vnf # TODO: Avoid having multiple 'vnfd' fields containers

		begin
			new_vnf = Vnf.create!(vnfd)
		rescue Moped::Errors::OperationFailure => e
			return 400, 'ERROR: Duplicated VNF ID' if e.message.include? 'E11000'
		end

		vnf_json = new_vnf.to_json
		vnf_yml = json_to_yaml(vnf_json)
		return 200, vnf_yml
		#halt 200, vnf.to_json
	end


	# @method delete_vnfd_external_vnf_id
	# @overload delete '/vnfs/id/:id'
	#	Delete a VNF by its ID
	#	@param [String] id VNF ID
	# Delete a VNF
	delete '/vnfs/id/:id' do
		begin
			vnf = Vnf.find(params[:id])
		rescue Mongoid::Errors::DocumentNotFound => e
			halt 404, e.to_s
		end

		vnf.destroy

		return 200, 'OK: VNFD removed'
	end

end