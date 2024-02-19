#!/usr/bin/env nextflow

// TODO: Add --help option/function

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
def printLabVal (String lab, val) {
    spacer = " ".repeat(12 - lab.length())
    println "$lab$spacer = $val" 
}

def printLabVal (String lab, List val) {
    spacer = " ".repeat(12 - lab.length())
    val.each { println "$lab$spacer = $it" }
}

def isTestProfile (String profiles) {
    if (profiles =~ 'test') { return true  }
    else                    { return false }
}

def printConfHelp () {
    println """
    Dear user, thanks for using nf-mixcr. 
    You just hit a small error and we will work togehter to fix it ⚒️. 
    Mixcr is nice tool, but too big tool to implement all options it offers (and I'm too lazy for that 😪). 
    In order to configure mixcr analyze parameters you need a custom configuration file. 
    You can get a template by running the pipeline with --get_ma_conf option. 
    Open it with your favorite editor and edit the lines with your own information. 
    If you wish to add an option, add a newline with your option and its argument between simple quote and with a comma at the end. 
    Then re run the pipeline and add the following option '-c mixcr_analyze.config'.
    Hit Enter and Congrats! 🎉 You made it! 😎
    """
}

def checkMixcrAnalyzeConf (List confs) {
    def ok  = false
    def isT = isTestProfile(workflow.profile)

    confs.each {
        if (it.getFileName() =~ "mixcr_analyze.config") { ok = true }
    }
    
    if      (!isT &&  ok) { println "Regular Run: mixcr_analyze.config ✅" }
    else if ( isT && !ok) { println "Test Run: mixcr_analyze.config not needed ✅" }
    else if (!isT && !ok) { 
        println "Regular Run: mixcr_analyze.config ❌"; 
        printConfHelp(); 
        println "======================================"
        println ""
        System.exit(0)
    }
}

def getMixcrAnalyzeConf() {
    cmd = 'wget -O mixcr_analyze.config https://raw.githubusercontent.com/sguizard/nf-mixcr/dev/configs/mixcr_analyze_template.config'
    cmd.execute()
    
    println """
    📦 Package delivered!

    (mixcr_analyze_template.config pulled from Github repo and renamed into mixcr_analyze.config)"
    """
    System.exit(0)
}


// Does the user need a copy of mixcr analysis config file? 
if (params.get_ma_conf) { getMixcrAnalyzeConf() }


// Checking mandatory parameters
def error_message = []
if (params.samplesheet == null) { error_message.add("ERROR: --samplesheet mandatory parameter is missing") }
if (params.preset      == null) { error_message.add("ERROR: --preset mandatory parameter is missing"     ) }

if (error_message) {println error_message.join('\n'); System.exit(0) }


// Run INFO
println ""
println "= 📄 RUN INFO ========================="
printLabVal("Command Line", workflow.commandLine)
printLabVal("Config Files", workflow.configFiles)
printLabVal("Profile"     , workflow.profile)
printLabVal("Revision"    , workflow.revision)
printLabVal("RunName"     , workflow.runName)
printLabVal("LaunchDir"   , workflow.launchDir)
printLabVal("WorkDir"     , workflow.workDir)
printLabVal("Start"       , workflow.start)
println "======================================"
println ""


// Summarize parameters
println ""
println "= ⚙️  PARAMETERS ======================="
printLabVal("Samplesheet", params.samplesheet)
printLabVal("Preset"     , params.preset)
printLabVal("Library"    , params.library)
printLabVal("Study"      , params.study)
printLabVal("Outdir"     , params.outdir)
println "======================================"
println ""


// Checking if custom config id needed
println ""
println "= ❓ Check configuration requirement ="
checkMixcrAnalyzeConf(workflow.configFiles)
println "======================================"
println ""


// Set up Channels (recycled channels)
ch_preset  = Channel.value(params.preset)
ch_library = Channel.value(file(params.library))
ch_study   = Channel.value(params.study)


println ""
println "= 🏃 PIPELINE RUNNING ================"
workflow {
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
}

workflow.onComplete {
    println "======================================"
    println ""

    success = workflow.success ? '✅' : '❌'

    println ""
    println "= ${success} PIPELINE COMPLETED =============="
    println "Started at  : ${workflow.start}"
    println "Completed at: ${workflow.complete}"
    println "Duration    : ${workflow.duration}"
    println "======================================"

}

