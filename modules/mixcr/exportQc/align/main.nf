process MIXCR_EXPORTQC_ALIGN {
    tag "$study"
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    val(study) 
    path(clns)
    path(library)

    output:
    path("*_exportQC_align.pdf"), emit: qc_align_pdf
    path("*_exportQC_align.png"), emit: qc_align_png
    path "versions.yml"         , emit: versions

    script:
    """
    export _JAVA_OPTIONS="-XX:-UsePerfData"

    mixcr exportQc align *.clns ${study}_exportQC_align.pdf
    mixcr exportQc align *.clns ${study}_exportQC_align.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    """
    touch ${study}_exportQC_align.pdf
    touch ${study}_exportQC_align.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
