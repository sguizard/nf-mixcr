process MIXCR_ANALYZE {
    tag "$meta.id"

    container 'ghcr.io/milaboratory/mixcr/mixcr:4.6.0'
    // container 'https://github.com/sguizard/mixcr-singularity-container/blob/master/mixcr.sif'

    input:
    tuple val(meta), path(r1), path(r2)
    val(preset)
    path(library)
    path(license)

    output:
    tuple val(meta), path("*.align.report.json")   , emit: align_report_json
    tuple val(meta), path("*.align.report.txt")    , emit: align_report_txt
    tuple val(meta), path("*.assemble.report.json"), emit: assemble_report_json
    tuple val(meta), path("*.assemble.report.txt") , emit: assemble_report_txt
    tuple val(meta), path("*.clns")                , emit: clns
    tuple val(meta), path("*.clones_TRB.tsv")      , emit: clones_TRB_tsv
    tuple val(meta), path("*.qc.json")             , emit: qc_json
    tuple val(meta), path("*.qc.txt")              , emit: qc_txt
    tuple val(meta), path("*_non_refined.vdjca")   , emit: vdjca
    tuple val(meta), path("*.refined.vdjca")       , emit: refined_vdjca
    tuple val(meta), path("*.refine.report.json")  , emit: refine_report_json
    tuple val(meta), path("*.refine.report.txt")   , emit: refine_report_txt
    tuple val(meta), path("*.log")                 , emit: log
    path  "versions.yml"                           , emit: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: meta.id
    def lib    = library.toString() == 'NO_FILE' ? '' : "--library ${library}"
    lib = lib.replaceFirst('.json.gz', '')

    """
    export MI_LICENSE_FILE="$PWD/${license}"

    mixcr analyze \\
        $preset \\
        $args \\
        $lib \\
        --threads ${task.cpus} \\
        $r1 \\
        $r2 \\
        ${prefix} > ${prefix}.log

    mv ${prefix}.vdjca ${prefix}_non_refined.vdjca

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
    touch ${prefix}_non_refined.vdjca

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MiXCR: \$( mixcr --version | grep -e 'MiXCR' | sed 's/MiXCR v//' | sed 's/ .\\+//' )
    END_VERSIONS
    """
}
