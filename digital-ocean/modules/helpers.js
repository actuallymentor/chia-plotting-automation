exports.log = ( ...messages ) => {
	if( process.env.debug ) console.log( `[ ${ new Date() } ]`, ...messages )
}

exports.wait = timeinMs => new Promise( resolve => {
	setTimeout( resolve, timeinMs )
} )