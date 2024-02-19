# nf-mixcr: TCR repertoire building with MiXCR

`nf-mixcr` is nextflow pipeline running MiXCR to build T-cell repertoire from illumina sequencing.
Nextflow makes your life easier by managing for you the input files, output files and jobs without having to install any program apart Nextflow itself and a container runner (singularity or docker).

The pipeline run the `mixcr analyze` program on each reads pairs placed listed in a samplesheet file, generates the QC and clones tables automatically.

```mermaid
flowchart TD
    A(Samplesheet) --> B[Mixcr Analyze]
    B[Samplesheet Check] -->|on each sample| C[Mixcr Analyze]
    C -->|on each sample| D[mixcr exportclones]
    C -->|on all sample| E[<a href='https://mixcr.com/mixcr/reference/mixcr-exportQc'>mixcr exportQC align</a>]
    C -->|on all sample| F[<a href='https://mixcr.com/mixcr/reference/mixcr-exportQc'>mixcr exportQC chainusage</a>]
    C -->|on each sample| G[<a href='https://mixcr.com/mixcr/reference/mixcr-exportQc'>mixcr exportQC coverage</a>]
    C -->|on each sample| H[mixcr export report]
```


## Requirements
**NB:** I assume you have a minimal knowledge of terminal and bash and you'll be able to run the following lines.

`nf-mixcr` does not require lot of dependencies to run.
If you plan running it on a cluster (like Eddie), there's big chances you do not need install anything.
The only dependencies are:
- [Nextflow](https://www.nextflow.io/)
- [Docker](https://docs.docker.com/get-docker/) or [Singularity](https://sylabs.io/singularity/)
- [MixCr](https://mixcr.com/) (for activation only!)

My advise to install those is to use the package manager [conda (Miniforge)](https://github.com/conda-forge/miniforge).
```
conda create -n nf-mixcr_env
conda activate nf-mixcr_env
conda install -c milaboratories nextflow singularity mixcr
```

### MiXCR (once for licence activation)
Before going futher, you will need a licence for using MiXCR.
If you don't have one, please visit this [page](https://mixcr.com/mixcr/getting-started/milm/) and fill in the form.
If your an academic, lucky you, it's free! If you're not, please check the commercial licensing page.
Once you received your licence, please run the command `mixcr activate-license` and copy paste your licence key.


## Pipeline Installation

**NOPE!** 🎉

But first, let's check if the pipeline is running correctly.
The test profile can be use to run to the pipeline with toy dataset automatically downloaded from the repository.

You can start the test by running:
```
nextflow run sguizard/nf-mixcr -profile singularity,test,<Institution>
```

or if you use docker in place of singularity:

```
nextflow run sguizard/nf-mixcr -profile docker,test,<Institution>
```

The <Institution> place holder must replaced by your cluster profile. The list of available configs can be found on [nf-core website](https://nf-co.re/configs).

**NB:** `singularity` or `docker` profile might be skipped if they are already defined in your institution profile. 


## Preparing files and data for analysis
To keep files sorted between inputs, outputs and working directories, I start by create a directory for the analysis (TCR_project) and create a data directory where I store the reads and other inputs files:

```
TCR_project/
└── data
    ├── imgt.202312-3.sv8.json.gz
    ├── mixcr_analyze.config
    ├── read_1.fastq.gz
    ├── read_2.fastq.gz
    └── samplesheet.csv
```

### Samplesheet
A sampleesheet must be provided. This file is a three columns comma separated value table. The columns are `id`, `read1`, `read2` and each value must be separated by a comma. Each line gives the location of the fastq file associated with a uniq ID.
```
id,read1,read2
SAMP1,./data/read_1.fastq.gz,./data/read_2.fastq.gz
```

### Library (Optional)
If the specie studied is different from Human (hsa) or Mouse (mmu), you'll need to provide a library of reference V, D, J, C genes. The [IMGT](https://www.imgt.org/) provides libraries for a large panel of specie which can be used with mixcr. The data can be downloaded [here](https://github.com/repseqio/library-imgt/releases). Please, don't decompress the file and keep the **`'.json.gz'`** extension.

### mixcr analyze configuration file
Mixcr gather multiple tools and each of them are highly configurable. Implementing all mixcr options in the pipeline would be highly time consuming. As a tradeoff, I decided to make use of a configuration file to set up mixcr analyze parameters. You can find a template configuration file [here](https://github.com/sguizard/nf-mixcr/blob/0ef8ed865293ea6643b31865ab1963757a74cb34/configs/mixcr_analyze_template.config), modify it with your needs. You can also run the pipeline with the option `--get_ma_conf` to get a copy.


Each lines between the central square brackets is a mixcr analyze option. If needed, you can add options by inserting a new line at the end of the option, write your option between **simple quotes** and ending the line with a **comma**.
```
process {
    withName: MIXCR_ANALYZE {
        cpus = 8
        ext.args = {
            [
                '--species cat',
                '--rna',
                '--tag-pattern "^N{4:6}GCTCACCTTTTTCAGGTCCTC(R1:*)\\^N{4:6}GCAGTGGTATCAACGCAGAGT(UMI:TN{4}TN{4}TN{4}TCTTGGGG)(R2:*)"',
                '--rigid-left-alignment-boundary',
                '--floating-right-alignment-boundary J',
                '--ADDITIONAL-OPTION and_its_value', 
            ].join(' ').trim()
        }
    }
}
```


## Running the pipeline

The classical command line to run the pipeline looks like this:
```
nextflow run sguizard/nf-mixcr \
    -profile <Institution> \
    -c data/mixcr_analyze.config \
    --samplesheet data/samplesheet.csv \
    --preset generic-amplicon-with-umi \
    --study My_project
```

### Options description
You will set two kind of options:
- Nextflow options, with simple dash (eg. `-profile`)
- Pipeline options, with double dash (eg. `--samplesheet`)

The nextflow options that need to be used are:
- `-profile`: select the adhoc virtualization technology (docker or singularity) and the profile of your cluster (eg. eddie). Profiles are separated by commas (eg. docker,eddie).
- ` -c`: define additional configuration. Please add the mandatory `mixcr_analyze.config` file here.

The pipeline options are: 
- `--samplesheet`: The path to the samplesheet listing samples as describe above
- `--preset`: mixcr analyze preset to use. (eg. `generic-amplicon-with-umi`)
- `--library`: V, D, J, C reference genes library
- `--study`: An ID that will be used as prefix for global report files (**Default: TCR**)
- `--outdir`: the name of the directory where the results will be publish (**Default: results**)
- `--get_ma_conf`: Download a copy of template mixcr_analysis.config and stop


Some option must be defined for each run and can't be omitted. The compulsory options are:
- `-profile`
- `-c` (mixcr_analysis.config)
- `--samplesheet`
- `--preset`


## Output files
The results of the pipeline will will be store in the directory defined by the `--outdir` option. For each process/program, one directory will be created to store the results. An additional directory, `pipeline_info`, gather reports about pipeline execution.

```
<outdir name>/
|-- 01_mixcr_analysis
|-- 02_mixcr_exportClones
|-- 03_mixcr_exportQc_align
|-- 03_mixcr_exportQc_chainusage
|-- 03_mixcr_exportQc_coverage
|-- 04_mixcr_exportReports
`-- pipeline_info
```

### 01_mixcr_analysis
```
01_mixcr_analysis
|-- SAMP1.align.report.json
|-- SAMP1.align.report.txt
|-- SAMP1.assemble.report.json
|-- SAMP1.assemble.report.txt
|-- SAMP1.clns
|-- SAMP1.clones_TRB.tsv
|-- SAMP1.log
|-- SAMP1_non_refined.vdjca
|-- SAMP1.qc.json
|-- SAMP1.qc.txt
|-- SAMP1.refined.vdjca
|-- SAMP1.refine.report.json
`-- SAMP1.refine.report.txt
```

This directory gather the results of the programs launched by MiXCR. With the preset `generic-amplicon-with-umi`, `mixcr analyze align`, `mixcr analyze refineTagsAndSort`, `mixcr analyze assemble` and `mixcr analyze export` are run.


### 02_mixcr_exportClones
```
02_mixcr_exportClones
`-- SAMP1_exportClones_<TRB/IGL>.tsv
```

`mixcr exportClones` generates a tabulation separated value file listing detected clones. 


### 03_mixcr_exportQc_align
```
03_mixcr_exportQc_align
|-- TCR_exportQC_align.pdf
`-- TCR_exportQC_align.png
```

`mixcr exportQc align` used the results of each analyzed samples to generate [align report](https://mixcr.com/mixcr/reference/report-align/).
It describe 

### 03_mixcr_exportQc_chainusage
```
03_mixcr_exportQc_chainusage
|-- TCR_exportQC_chainUsage.pdf
`-- TCR_exportQC_chainUsage.png
```


### 03_mixcr_exportQc_coverage
```
03_mixcr_exportQc_coverage
|-- SAMP1_exportQC_coverage.pdf
|-- SAMP1_exportQC_coverage_R0.png
|-- SAMP1_exportQC_coverage_R1.png
`-- SAMP1_exportQC_coverage_R2.png
```


### 04_mixcr_exportReports
```
04_mixcr_exportReports
|-- SAMP1.report.json
`-- SAMP1.report.txt
```


### pipeline_info
```
pipeline_info
|-- <timestamp>_execution_report.html
|-- <timestamp>_execution_timeline.html
`-- <timestamp>_execution_trace.txt
```


TODO: Write output files
