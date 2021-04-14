const { getRegions, getMeta, getDroplets, get_droplet_ids_by_name } = require( './modules/api' )
const { wait, log } = require( './modules/helpers' )

if( process.env.regions ) {
	log( 'Regions requested' )
	getRegions()
}

if( process.env.droplets ) {
	log( 'All droplets requested' )
	getDroplets()
}

if( process.env.all ) {
	log( 'All meta requested' )
	getMeta()
}

