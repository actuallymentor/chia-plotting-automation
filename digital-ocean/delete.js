const { get_droplet_ids_by_name, delete_droplets_by_ids, get_volume_ids_by_name, delete_volumes_by_ids } = require( './modules/api' )
const { wait, log } = require( './modules/helpers' )
require( 'dotenv' ).config()

// ///////////////////////////////
// Create 2vCPU/4GB/500GB PS
// ///////////////////////////////
const deleteEverplotDroplets = async f => {

	try {

		const droplets = await get_droplet_ids_by_name( 'everplot' )
		log( 'Droplets to be deleted: ', droplets.length )

		const volumes = await get_volume_ids_by_name( 'everplot' )
		log( 'Volumes to be deleted: ', volumes.length )

		for ( let i = 10; i >= 0; i--) {
			log( `Starting destruction in `, i )
			await wait( 1000 )
		}

		await Promise.all( droplets.map( droplet => delete_droplets_by_ids( droplet ) ) )
		await Promise.all( volumes.map( volume => delete_volumes_by_ids( volume ) ) )

	} catch( e ) {

		log( 'Something went wrong: ', e )

	}

}

deleteEverplotDroplets( ).catch( log )