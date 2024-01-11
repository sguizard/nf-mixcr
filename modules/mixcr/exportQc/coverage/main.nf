process MIXCR_EXPORTQC_COVERAGE {
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(id), path(vdjca)
    path(library)

    output:
    path("*_exportQC_coverage.pdf")  , emit: qc_coverage_pdf
    path("*_exportQC_coverage_*.png"), emit: qc_coverage_png
    path "versions.yml"              , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: id

    """
    mixcr exportQc coverage $vdjca ${id}_exportQC_coverage.pdf
    mixcr exportQc coverage $vdjca ${id}_exportQC_coverage.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${id}_exportQC_coverage_R1.pdf
    touch ${id}_exportQC_coverage_R1.png

    cat <<-END_VERSIONS > versions.yml
    MIXCR_ANALYZE:
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
