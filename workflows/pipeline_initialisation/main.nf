workflow PIPELINE_INITIALISATION {

    main:
    // Does the user need a copy of mixcr analysis config file? 
    if (params.get_ma_conf) { getMixcrAnalyzeConf() }


    // Checking mandatory parameters
    def error_message = []
    if (params.samplesheet == null) { error_message.add("ERROR: --samplesheet mandatory parameter is missing") }
    if (params.preset      == null) { error_message.add("ERROR: --preset mandatory parameter is missing"     ) }

    if (error_message) {log.info error_message.join('\n'); System.exit(0) }

    // Run INFO
    log.info ""
    log.info "= 📄 RUN INFO ========================="
    printLabVal("Pipeline Version", workflow.manifest.version)
    printLabVal("Command Line"    , workflow.commandLine)
    printLabVal("Config Files"    , workflow.configFiles)
    printLabVal("Profile"         , workflow.profile)
    printLabVal("Revision"        , workflow.revision)
    printLabVal("RunName"         , workflow.runName)
    printLabVal("LaunchDir"       , workflow.launchDir)
    printLabVal("WorkDir"         , workflow.workDir)
    printLabVal("Start"           , workflow.start)
    log.info "======================================"
    log.info "\n"


    // Summarize parameters
    log.info ""
    log.info "= ⚙️  PARAMETERS ======================"
    printLabVal("Samplesheet", params.samplesheet)
    printLabVal("Preset"     , params.preset)
    printLabVal("Library"    , params.library)
    printLabVal("Study"      , params.study)
    printLabVal("Outdir"     , params.outdir)
    log.info "======================================"
    log.info "\n"


    // Checking if custom config id needed
    log.info ""
    log.info "= ❓ Check configuration requirement ="
    checkMixcrAnalyzeConf(workflow.configFiles)
    log.info "======================================"
    log.info "\n"

}

//////////////////////////////////////////////////
// Utils Functions
//////////////////////////////////////////////////
def printLabVal(String lab, val) {
    def spacer = " ".repeat(16 - lab.length())
    if (val instanceof List) {
        val.each { log.info "$lab$spacer = $it" }
    } else {
        log.info "$lab$spacer = $val"
    }
}

def isTestProfile (String profiles) {
    if (profiles =~ 'test') { return true  }
    else                    { return false }
}

def printConfHelp () {
    log.info """
    Dear user, thanks for using nf-mixcr. 
    You just hit a small error and we will work together to fix it ⚒️. 
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
    
    if      (!isT &&  ok) { log.info "Regular Run: mixcr_analyze.config ✅" }
    else if ( isT && !ok) { log.info "Test Run: mixcr_analyze.config not needed ✅" }
    else if (!isT && !ok) { 
        log.info "Regular Run: mixcr_analyze.config ❌"; 
        printConfHelp(); 
        log.info "======================================"
        log.info ""
        System.exit(0)
    }
}

def getMixcrAnalyzeConf() {
    def cmd = 'wget -O mixcr_analyze.config https://raw.githubusercontent.com/sguizard/nf-mixcr/dev/configs/mixcr_analyze_template.config'
    cmd.execute()
    
    log.info """
    📦  Package delivered!

    (mixcr_analyze_template.config pulled from Github repo and renamed into mixcr_analyze.config)"
    """
    System.exit(0)
}


