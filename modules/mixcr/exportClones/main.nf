process MIXCR_EXPORTCLONES {
    tag "$id"

    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(id), path(clns)
    path(library)

    output:
    tuple val(id), path("*_exportClones_*.tsv"), emit: tables
    path  "versions.yml"                       , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: id

    """
    mixcr exportClones $clns ${prefix}_exportClones.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${id}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
