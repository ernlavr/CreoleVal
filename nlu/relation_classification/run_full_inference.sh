#!/usr/bin/bash

: '
This script is used to run the full inference process for a set of models and 
sentence embedders on Creoles: bi, cbk-zam, jam, pih, tpi.

The script first creates the necessary directories if they do not exist.
Then it loops over each model and sentence embedder, and for each combination, it runs the inference process for each Creole language.
The results are logged in a log file specific to the model and sentence embedder combination.
'

# add usage

function script_usage() {
    cat << EOF
Usage: run_full_inference.sh <SEED> <BATCH_SIZE>

Arguments:
    SEED            Seed for the random number generator
    BATCH_SIZE      Batch size for the inference process
EOF
}

if [[ $# -ne 2 ]]; then
    echo "Error: Found $# positional arguments; expected 2"
    script_usage
    exit 1
fi

mkdirs() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdirs "$(dirname "$dir")"
        mkdir "$dir"
    fi
}

SEED=$1
BATCH_SIZE=$2
model=('bert-base-multilingual-cased' 'xlm-roberta-base')
sentence=('bert-base-nli-mean-tokens' 'bert-large-nli-mean-tokens' 'xlm-r-bert-base-nli-mean-tokens' 'xlm-r-100langs-bert-base-nli-mean-tokens')
Creole=('bi' 'cbk-zam' 'jam' 'tpi')

# Necessary for relative paths

log_dir="log_infer"
data_dir="data/relation_extraction"
proper_dir="data/relation_extraction/properties"
model_dir="pretrained_weights/"
output_dir="output"

mkdirs "$output_dir"

for mm in "${model[@]}"; do
    for ss in "${sentence[@]}"; do
        mkdirs "$log_dir"
        log_file="${log_dir}/${mm}_${ss}.log"
        > "$log_file"
        echo "$mm" | tee -a "$log_file"
        echo "$ss" | tee -a "$log_file"
        best_model="${model_dir}/${mm}/${ss}/${model_name}"
        for dd in "${Creole[@]}"; do
            echo "Running with parameters; Model: $mm, Sentence Embedder: $ss, Seed: $SEED, Batch Size: $BATCH_SIZE, Creole: $dd"
            bash infer_zsbert.sh "$mm" "$ss" "$SEED" "$BATCH_SIZE" "$dd" | tee -a "$log_file"
        done
    done
done