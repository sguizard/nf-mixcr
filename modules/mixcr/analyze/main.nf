process MIXCR_ANALYZE {
    tag "$id"

    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'

    input:
    tuple val(id), path(reads)
    val(preset)
    path(library)

    output:
    tuple val(id), path("*.align.report.json")   , emit: align_report_json
    tuple val(id), path("*.align.report.txt")    , emit: align_report_txt
    tuple val(id), path("*.assemble.report.json"), emit: assemble_report_json
    tuple val(id), path("*.assemble.report.txt") , emit: assemble_report_txt
    tuple val(id), path("*.clns")                , emit: clns
    tuple val(id), path("*.clones_TRB.tsv")      , emit: clones_TRB_tsv
    tuple val(id), path("*.qc.json")             , emit: qc_json
    tuple val(id), path("*.qc.txt")              , emit: qc_txt
    tuple val(id), path("*.refined.vdjca")       , emit: refined_vdjca
    tuple val(id), path("*.refine.report.json")  , emit: refine_report_json
    tuple val(id), path("*.refine.report.txt")   , emit: refine_report_txt
    tuple val(id), path("*.vdjca")               , emit: vdjca
    path  "versions.yml"                         , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: id
    def lib    = library.toString() == 'NO_FILE' ? '' : "--library ${library}"
    lib.replaceFirst('.json.gz', '')
    def r1     = reads[0]
    def r2     = reads[1]

    """
    mixcr analyze \\
        $preset \\
        $args \\
        $lib \\
        --threads ${task.cpus} \\
        $r1 \\
        $r2 \\
        $id

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: id
    """
    touch ${prefix}.align.report.json
    touch ${prefix}.align.report.txt
    touch ${prefix}.assemble.report.json
    touch ${prefix}.assemble.report.txt
    touch ${prefix}.clns
    touch ${prefix}.clones_TRB.tsv
    touch ${prefix}.qc.json
    touch ${prefix}.qc.txt
    touch ${prefix}.refined.vdjca
    touch ${prefix}.refine.report.json
    touch ${prefix}.refine.report.txt
    touch ${prefix}.vdjca

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
