process MIXCR_EXPORTREPORTS {
    tag "$meta.id"
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(meta), path(clns)
    path(library)

    output:
    path("*.report.json"), emit: exportReports_json
    path("*.report.txt") , emit: exportReports_txt
    path "versions.yml"  , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: meta.id

    """
    mixcr exportReports --json $clns ${prefix}.report.json
    mixcr exportReports $clns ${prefix}.report.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${prefix}.report.json
    touch ${prefix}.report.txt

    cat <<-END_VERSIONS > versions.yml
    MIXCR_ANALYZE:
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
