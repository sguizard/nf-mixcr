process MIXCR_EXPORTREPORTS {
    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(id), path(clns)
    path(library)

    output:
    path("*.report.json"), emit: exportReports_json
    path("*.report.txt") , emit: exportReports_txt
    path "versions.yml"  , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: id

    """
    mixcr exportReports --json $clns ${id}.report.json
    mixcr exportReports $clns ${id}.report.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${id}.report.json
    touch ${id}.report.txt

    cat <<-END_VERSIONS > versions.yml
    MIXCR_ANALYZE:
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
