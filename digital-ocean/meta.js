const { getRegions, getMeta } = require( './modules/api' )
const { wait, log } = require( './modules/helpers' )

if( process.env.regions ) {
	log( 'Regions requested' )
	getRegions()
}

if( process.env.all ) {
	log( 'All meta requested' )
	getMeta()
}