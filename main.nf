#!/usr/bin/env nextflow

// TODO: add and test singularity
// TODO: Implement nf-test

nextflow.enable.dsl = 2

include { MIXCR_ANALYZE             } from './modules/mixcr/analyze'
include { MIXCR_EXPORTCLONES        } from './modules/mixcr/exportClones'
include { MIXCR_EXPORTQC_ALIGN      } from './modules/mixcr/exportQc/align'
include { MIXCR_EXPORTQC_CHAINUSAGE } from './modules/mixcr/exportQc/chainUsage'
include { MIXCR_EXPORTQC_COVERAGE   } from './modules/mixcr/exportQc/coverage'
include { MIXCR_EXPORTQC_TAGS       } from './modules/mixcr/exportQc/tags'
include { MIXCR_EXPORTREPORTS       } from './modules/mixcr/exportReports'

def printOptions (option, val) {
    println "PARAMS: $option = $val" 
}

println ""
printOptions("input_dir", params.input_dir)
printOptions("preset", params.preset)
printOptions("params.library", params.library)
printOptions("params.study", params.study)
println ""

ch_reads   = Channel.fromFilePairs("${params.input_dir}/*_{1,2}.{fastq,fastq.gz}")
ch_library = Channel.fromPath(params.library)

workflow {
    MIXCR_ANALYZE(ch_reads, params.preset, ch_library)
    MIXCR_EXPORTCLONES(MIXCR_ANALYZE.out.clns, ch_library)
    MIXCR_EXPORTQC_ALIGN(params.study, MIXCR_ANALYZE.out.clns.collect(), ch_library)
    MIXCR_EXPORTQC_CHAINUSAGE(params.study, MIXCR_ANALYZE.out.clns.collect(), ch_library)
    MIXCR_EXPORTQC_COVERAGE(MIXCR_ANALYZE.out.vdjca, ch_library)
    MIXCR_EXPORTREPORTS(MIXCR_ANALYZE.out.clns, ch_library)
}