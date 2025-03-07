process MIXCR_EXPORTQC_CHAINUSAGE {
    tag "$study"
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    val(study) 
    path(clns)
    path(library)

    output:
    path("*_exportQC_chainUsage.pdf"), emit: qc_chainusage_pdf
    path("*_exportQC_chainUsage.png"), emit: qc_chainusage_png
    path "versions.yml"              , emit: versions

    script:
    """
    export _JAVA_OPTIONS="-XX:-UsePerfData"

    mixcr exportQc chainUsage *.clns ${study}_exportQC_chainUsage.pdf
    mixcr exportQc chainUsage *.clns ${study}_exportQC_chainUsage.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    """
    touch ${study}_exportQC_chainUsage.pdf
    touch ${study}_exportQC_chainUsage.png

    cat <<-END_VERSIONS > versions.yml
    MIXCR_ANALYZE:
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
