#!/usr/bin/env nextflow

// TODO: Add --help option/function
// TODO: Check for mandatory options

nextflow.enable.dsl = 2

// Workflows
include { SAMPLESHEET_CHECK         } from './workflows/samplesheet/check'

// Modules
include { MIXCR_ANALYZE             } from './modules/mixcr/analyze'
include { MIXCR_EXPORTCLONES        } from './modules/mixcr/exportClones'
include { MIXCR_EXPORTQC_ALIGN      } from './modules/mixcr/exportQc/align'
include { MIXCR_EXPORTQC_CHAINUSAGE } from './modules/mixcr/exportQc/chainUsage'
include { MIXCR_EXPORTQC_COVERAGE   } from './modules/mixcr/exportQc/coverage'
include { MIXCR_EXPORTQC_TAGS       } from './modules/mixcr/exportQc/tags'
include { MIXCR_EXPORTREPORTS       } from './modules/mixcr/exportReports'

// Utils functions
def printOptions (option, val) {
    println "PARAMS: $option = $val" 
}

// Summarize parameters
println ""
println "= PARAMETERS ========================="
printOptions("samplesheet", params.samplesheet)
printOptions("preset"     , params.preset)
printOptions("library"    , params.library)
printOptions("study"      , params.study)
println "======================================"
println ""

// Set up Channels
ch_library = Channel.fromPath(params.library)

workflow {
    // Check and prepare input channel
    SAMPLESHEET_CHECK(params.samplesheet)

    // Run Mixcr analysis
    MIXCR_ANALYZE(SAMPLESHEET_CHECK.out.mixcr_input, params.preset, ch_library)

    // Export assembled clone list
    MIXCR_EXPORTCLONES(MIXCR_ANALYZE.out.clns, ch_library)

    // Export QCs
    MIXCR_EXPORTQC_ALIGN(params.study, MIXCR_ANALYZE.out.clns.collect(), ch_library)
    MIXCR_EXPORTQC_CHAINUSAGE(params.study, MIXCR_ANALYZE.out.clns.collect(), ch_library)
    MIXCR_EXPORTQC_COVERAGE(MIXCR_ANALYZE.out.vdjca, ch_library)

    // Export reports
    MIXCR_EXPORTREPORTS(MIXCR_ANALYZE.out.clns, ch_library)
}
