process MIXCR_EXPORTQC_TAGS {
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(id), path(vdjca)
    path(library)

    output:
    path("*_exportQC_tags.pdf"), emit: qc_tags_pdf
    path("*_exportQC_tags.png"), emit: qc_tags_png
    path "versions.yml"        , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: id

    """
    mixcr exportQc tags $vdjca ${id}_exportQC_tags.pdf
    mixcr exportQc tags $vdjca ${id}_exportQC_tags.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${id}_exportQC_tags.pdf
    touch ${id}_exportQC_tags.png

    cat <<-END_VERSIONS > versions.yml
    MIXCR_ANALYZE:
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
