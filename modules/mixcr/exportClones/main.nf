process MIXCR_EXPORTCLONES {
    tag "$meta.id"

    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(meta), path(clns)
    path(library)

    output:
    tuple val(meta), path("*_exportClones_*.tsv"), emit: tables
    path  "versions.yml"                         , emit: versions

    script:
    def prefix = task.ext.prefix ?: meta.id

    """
    export _JAVA_OPTIONS="-XX:-UsePerfData"

    mixcr exportClones $clns ${prefix}_exportClones.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: meta.id
    """
    touch ${prefix}_exportClones.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
