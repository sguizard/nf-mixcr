#!/usr/bin/env nextflow

// TODO: Add --help option/function

nextflow.enable.dsl = 2

// Workflows
include { PIPELINE_INITIALISATION   } from './workflows/pipeline_initialisation'
include { SAMPLESHEET_CHECK         } from './workflows/samplesheet/check'

// Modules
include { MIXCR_ANALYZE             } from './modules/mixcr/analyze'
include { MIXCR_EXPORTCLONES        } from './modules/mixcr/exportClones'
include { MIXCR_EXPORTQC_ALIGN      } from './modules/mixcr/exportQc/align'
include { MIXCR_EXPORTQC_CHAINUSAGE } from './modules/mixcr/exportQc/chainUsage'
include { MIXCR_EXPORTQC_COVERAGE   } from './modules/mixcr/exportQc/coverage'
include { MIXCR_EXPORTQC_TAGS       } from './modules/mixcr/exportQc/tags'
include { MIXCR_EXPORTREPORTS       } from './modules/mixcr/exportReports'

workflow {

    PIPELINE_INITIALISATION()

    // Set up Channels (recycled channels)
    ch_preset  = Channel.value(params.preset)
    ch_library = Channel.value(file(params.library))
    ch_study   = Channel.value(params.study)

    println ""
    println "= 🏃 PIPELINE RUNNING ================"

    // Check and prepare input channel
    SAMPLESHEET_CHECK(params.samplesheet)

    // Run Mixcr analysis
    MIXCR_ANALYZE(SAMPLESHEET_CHECK.out.mixcr_input, ch_preset, ch_library)

    // Export assembled clone list
    MIXCR_EXPORTCLONES(MIXCR_ANALYZE.out.clns, ch_library)

    ch_all_clns = 
        MIXCR_ANALYZE.out.clns
        .map { [it[1]] }
        .collect()

    // Export QCs
    MIXCR_EXPORTQC_ALIGN     (ch_study, ch_all_clns  , ch_library)
    MIXCR_EXPORTQC_CHAINUSAGE(ch_study, ch_all_clns  , ch_library)
    MIXCR_EXPORTQC_COVERAGE  (MIXCR_ANALYZE.out.vdjca, ch_library)

    // Export reports
    MIXCR_EXPORTREPORTS(MIXCR_ANALYZE.out.clns, ch_library)


    workflow.onComplete = {
    println "======================================"
    println ""

    def success = workflow.success ? '✅' : '❌'

    println ""
    println "= ${success} PIPELINE COMPLETED =============="
    println "Started at  : ${workflow.start}"
    println "Completed at: ${workflow.complete}"
    println "Duration    : ${workflow.duration}"
    println "======================================"

}

}

