const { getSSHKeyIdByName, createVolume, create_2vCPU_4RAM_500Volume_Droplet, getDropletIpById } = require( './modules/api' )
const { wait, log } = require( './modules/helpers' )
require( 'dotenv' ).config()
const { sshKeyNameInDO, volumeSizeOverride } = process.env

// ///////////////////////////////
// Create 2vCPU/4GB/500GB PS
// ///////////////////////////////
const createPlotter = async f => {

	try {

		const { id: sshKeyId } = await getSSHKeyIdByName( sshKeyNameInDO || 'mentorkey' )
		const { id: VolumeId } = await createVolume( volumeSizeOverride || 350 )
		const droplet = await create_2vCPU_4RAM_500Volume_Droplet( sshKeyId, VolumeId )
		log( 'Created droplet: ', droplet )

		// Wait for IP to be registered
		let ip = undefined
		while( !ip ) {

			let { droplet: dropletData } = await getDropletIpById( droplet.id )
			log( 'Droplet data: ', dropletData, dropletData.networks.v4 )
			let { ip_address } = dropletData.networks.v4.length && dropletData.networks.v4.find( ( { type } ) => type == 'public' )
			ip = ip_address
			await wait( 10000 )

		}

		console.log( 'Plotter ip address: ', ip )

	} catch( e ) {

		log( 'Something went wrong: ', e )

	}

}

createPlotter( )
