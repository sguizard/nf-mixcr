process MIXCR_EXPORTQC_ALIGN {
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    val(study) 
    tuple val(id), path(clns)
    path(library)

    output:
    path("*_exportQC_align.pdf"), emit: qc_align_pdf
    path("*_exportQC_align.png"), emit: qc_align_png
    path "versions.yml"         , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: id

    """
    mixcr exportQc align *.clns ${study}_exportQC_align.pdf
    mixcr exportQc align *.clns ${study}_exportQC_align.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${study}_exportQC_align.pdf
    touch ${study}_exportQC_align.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
