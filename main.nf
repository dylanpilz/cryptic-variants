#!/usr/bin/env nextflow

/*
 *  Wastewater Cryptic Variant Detection
 */

// Enable DSL 2 syntax
nextflow.enable.dsl = 2

// Define default parameters
params.input = "$baseDir/data/input/*.bam"
params.is_trimmed = true

// Sars-Cov-2 specific parameters
params.ref = "$PWD/data/NC_045512_Hu-1.fasta"
params.primer_bed = "$PWD/data/nCov-2019_v3.primer.bed"

// Freyja covariants parameters
params.min_site = 21563
params.max_site = 25384

// Cryptic variant detection parameters
params.detect_cryptic_script = "$PWD/scripts/detect_cryptic.py"
params.min_WW_count = 10
params.max_gisaid_count = 10
params.location_id = "USA"

ref = file(params.ref)
primer_bed = file(params.primer_bed)
detect_cryptic_script = file(params.detect_cryptic_script)

// Import modules
include {
    SORT;
    TRIM;
    COVARIANTS;
    DETECT_CRYPTIC;
} from "./modules.nf"

Channel 
    .fromPath(params.input)
    .set { input_bam_ch }

workflow {
    SORT(input_bam_ch)

    if (!params.is_trimmed) {
        TRIM(SORT.out)
        COVARIANTS(TRIM.out, ref)
    } else {
        COVARIANTS(SORT.out, ref)
    }
    DETECT_CRYPTIC(COVARIANTS.out, detect_cryptic_script)
}