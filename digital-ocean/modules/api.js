// ///////////////////////////////
// Settings & variables
// ///////////////////////////////
require( 'dotenv' ).config()
const { personal_access_token, defaultRegion } = process.env

// Library
const { default: DigitalOcean } = require("do-wrapper")
const api = new DigitalOcean( personal_access_token )

// Helpers
const { log } = require( './helpers' )

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
exports.createVolume = ( size=500, namePrefix='everplot-ams', region ) => {
	const config = {
		size_gigabytes: size,
		name: `${ namePrefix }-${ new Date().getHours() }-${ Math.round( new Date().getMinutes() / 10 ) * 10 }-${ Date.now() }`,
		region: defaultRegion || region,
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
exports.create_2vCPU_4RAM_500Volume_Droplet = ( sshKeyId=702861, volume, namePrefix='everplot-ams', region ) => {

	const config = {
		name: `${ namePrefix }-${ new Date().getHours() }-${ Math.round( new Date().getMinutes() / 10 ) * 10 }-${ Date.now() }`,
		region: defaultRegion || region,
		size: 'c-2', // 2vcpu, 4gb ram
		image: 'ubuntu-20-04-x64',
		ssh_keys: [ sshKeyId ],
		monitoring: true,
		volumes: volume && [ volume ]
	}
	log( 'Creating droplet with: ', config )
	return api.droplets.create( config ).then( ( { droplet } ) => droplet )

}

exports.getDropletIpById = id => api.droplets.getById( id )