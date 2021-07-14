// ///////////////////////////////
// Settings & variables
// ///////////////////////////////
require( 'dotenv' ).config()
const { personal_access_token, defaultRegion, fallbackRegion } = process.env

// Library
const { default: DigitalOcean } = require( 'do-wrapper' )
const api = new DigitalOcean( personal_access_token )

// Helpers
const { log, wait } = require( './helpers' )

// ///////////////////////////////
// Meta data management
// ///////////////////////////////
exports.getMeta = f => Promise.all( [
	api.images.getAll(  ),
	api.regions.getAll(),
	api.sizes.get( '', true )
] ).then( ( [ images, regions, sizes ] ) => {
	log( 'Images: ', images )
	log( 'Regions: ', regions )
	log( 'Sizes: ', sizes )
} )

exports.getRegions = f => api.regions.getAll().then( ( { regions } ) => {
	log( 'Regions: ', regions )
	log( 'defaultRegion: ', regions.find( ( { slug } ) => slug == defaultRegion ) )
	log( 'fallbackRegion: ', regions.find( ( { slug } ) => slug == fallbackRegion ) )
} )

// ///////////////////////////////
// Keys management
// ///////////////////////////////
// returns { id, name, fingerprint, public_key }
exports.getSSHKeyIdByName = async namefilter => {

	log( 'Getting ssh keys matching ', namefilter.toLowerCase() )
	const { ssh_keys: keys } = await api.keys.getAll()
	const thekey = keys.find( ( { name } ) => name.toLowerCase().includes( namefilter.toLowerCase() ) )
	return thekey

}

// ///////////////////////////////
// Volume management
// ///////////////////////////////
// returns { id, name created_at, description, droplet_ids, region={}, size_gigabytes, filesystem_type, filesystem_label }
exports.createVolume = async ( size=500, namePrefix='everplot-ams', region ) => {

	// Choose the best region based on availability
	let bestRegion = defaultRegion
	const { regions } = await api.regions.getAll()

	// If default is available choose it
	const defaultRegionAvailability = regions.find( ( { slug } ) => slug == defaultRegion )
	const fallbackRegionAvailability = regions.find( ( { slug } ) => slug == fallbackRegion )

	// Best case, default is available
	if( defaultRegionAvailability.available && defaultRegionAvailability.features.includes( 'storage' ) ) {
		bestRegion = defaultRegion
	}
	// Second best, fallback is available
	else if ( fallbackRegionAvailability.available && fallbackRegionAvailability.features.includes( 'storage' ) ) {
		bestRegion = fallbackRegion
	}
	// Both are full, pick the first available
	else {
		const { slug } = regions.find( ( { features, available } ) => available && features.includes( 'storage' ) )
		bestRegion = slug
	}

	// Make config
	const config = {
		size_gigabytes: size,
		name: `${ namePrefix }-${ new Date().getHours() }-${ Math.round( new Date().getMinutes() / 10 ) * 10 }-${ Date.now() }`,
		region: region || bestRegion || defaultRegion,
		filesystem_type: "ext4",
		description: 'created via api'
	}
	log( 'Creating volume with ', config )
	return api.volumes.create( config ).then( ( { volume } ) => volume )
}

// ///////////////////////////////
// Droplet management
// ///////////////////////////////
// returns { id, name, memory, vcpus, disk, created_at, features=[], size_slug, volume_ids=[], region={} }
exports.create_2vCPU_4RAM_500Volume_Droplet = async ( sshKeyId=702861, volume, namePrefix='everplot-ams', region, size='c-2' ) => {

	// Choose the best region based on availability
	let bestRegion = defaultRegion
	const { regions } = await api.regions.getAll()

	// If default is available choose it
	const defaultRegionAvailability = regions.find( ( { slug } ) => slug == defaultRegion )
	const fallbackRegionAvailability = regions.find( ( { slug } ) => slug == fallbackRegion )

	// Best case, default is available
	if( defaultRegionAvailability.available && defaultRegionAvailability.sizes.includes( size ) ) {
		bestRegion = defaultRegion
	}
	// Second best, fallback is available
	else if ( fallbackRegionAvailability.available && fallbackRegionAvailability.sizes.includes( size ) ) {
		bestRegion = fallbackRegion
	}
	// Both are full, pick the first available
	else {
		const { slug } = regions.find( ( { sizes, available } ) => available && sizes.includes( size ) )
		bestRegion = slug
	}

	const config = {
		name: `${ namePrefix }-${ new Date().getHours() }-${ Math.round( new Date().getMinutes() / 10 ) * 10 }-${ Date.now() }`,
		region: defaultRegion || region,
		size: size, // 2vcpu, 4gb ram
		image: 'ubuntu-20-04-x64',
		ssh_keys: [ sshKeyId ],
		monitoring: true,
		volumes: volume && [ volume ]
	}
	log( 'Creating droplet with: ', config )
	return api.droplets.create( config ).then( ( { droplet } ) => droplet )

}

// returns { id, name, memory, vcpus, disk, created_at, features=[], size_slug, volume_ids=[], region={} }
exports.create_16vCPU_128RAM_No_Volume_Droplet = async ( sshKeyId=702861, namePrefix='everplot-ams', region, size='m-16vcpu-128gb' ) => {

	// Choose the best region based on availability
	let bestRegion = defaultRegion
	const { regions } = await api.regions.getAll()

	// If default is available choose it
	const defaultRegionAvailability = regions.find( ( { slug } ) => slug == defaultRegion )
	const fallbackRegionAvailability = regions.find( ( { slug } ) => slug == fallbackRegion )

	// Best case, default is available
	if( defaultRegionAvailability.available && defaultRegionAvailability.sizes.includes( size ) ) {
		bestRegion = defaultRegion
	}
	// Second best, fallback is available
	else if ( fallbackRegionAvailability.available && fallbackRegionAvailability.sizes.includes( size ) ) {
		bestRegion = fallbackRegion
	}
	// Both are full, pick the first available
	else {
		const { slug } = regions.find( ( { sizes, available } ) => available && sizes.includes( size ) )
		bestRegion = slug
	}

	const config = {
		name: `${ namePrefix }-${ new Date().getHours() }-${ Math.round( new Date().getMinutes() / 10 ) * 10 }-${ Date.now() }`,
		region: defaultRegion || region,
		size: size, // 2vcpu, 4gb ram
		image: 'ubuntu-20-04-x64',
		ssh_keys: [ sshKeyId ],
		monitoring: true
	}
	log( 'Creating droplet with: ', config )
	return api.droplets.create( config ).then( ( { droplet } ) => droplet )

}

// ///////////////////////////////
//  Droplet management
// ///////////////////////////////

exports.getDropletIpById = id => api.droplets.getById( id )
exports.getDroplets = filter => api.droplets.getAll( null, null, null, 100 ).then( ( { droplets } ) => {
	log( 'droplets: ', droplets )

	const ips = droplets.filter( ( { name } ) => {
		return name.includes( 'everplot' )
	} ).map( ( { networks } ) => {
		return networks.v4.find( ( { type } ) => type == 'public' )[ 'ip_address' ]
	} ).join( ' ' )

	log( 'Ips of everplotters: ', ips )
	if( !process.env.debug ) console.log( ips )
} )
exports.get_droplet_ids_by_name = filter => api.droplets.getAll( null, null, null, 100 ).then( ( { droplets } ) => {
	return droplets.filter( ( { name } ) => name.includes( filter ) )
} )

exports.get_volume_ids_by_name = filter => api.volumes.getAll( null, null, null, 100 ).then( ( { volumes } ) => {
	return volumes.filter( ( { name } ) => name.includes( filter ) )
} )

exports.delete_droplets_by_ids = ( { id } ) => {

	// guardrails
	if( !id ) throw 'No id provided to delete_droplets_by_ids'

	// Delete them
	return api.droplets.deleteById( id )

}

exports.delete_volumes_by_ids = ( { id } ) => {

	// guardrails
	if( !id ) throw 'No id provided to delete_volumes_by_ids'

	// Delete them
	return api.volumes.deleteById( id )

}