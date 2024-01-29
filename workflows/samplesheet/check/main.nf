workflow SAMPLESHEET_CHECK {
    take:
    samplesheet

    main: 
    def header      = true

    file(samplesheet).eachLine { line ->
        // println("line ==> "+line)
        if ( header && line != "id,read1,read2" ) {
            println("ERROR: Check samplesheet header line please. Should be: id,read1,read2.")
            System.exit(0)
        }
        if ( line.split(',').size() != 3 ) {
            valid = false
            println("ERROR: Check samplesheet sample line please. Wrong number of elements on a line. (Wrong separator?)")
            System.exit(0)
        }
        header = false
    }

    Channel
        .fromPath( file(samplesheet) )
        .splitCsv(header: true, sep:',')
        .map { [ [id:it.id], file(it.read1), file(it.read2) ] }
        .set { mixcr_input }


    emit: 
    mixcr_input
}
