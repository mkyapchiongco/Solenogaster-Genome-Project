#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --mem=100G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 8 #cores per task
#SBATCH -o slurm_output-BUSCO.%J
#SBATCH -e slurm_error-BUSCO.%J
#SBATCH -p threaded
#SBATCH --qos threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu

export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init

use busco
use augustus

export BUSCO_CONFIG_FILE="/kmk/scripts/busco/config.ini"
export AUGUSTUS_CONFIG_PATH="/kmk/scripts/augustus-3.3.2/config"

#You may want to change "metazoa" to "mollusca" or vice versa for the different databses we are likely to use
#This script uses the new "--long" feature that is more sensitive
busco -c 8 -m genome --long --offline -l /kmk/databases/metazoa_odb10 -i edited_out_JBAT.FINAL.filtered.fa -o BUSCO
