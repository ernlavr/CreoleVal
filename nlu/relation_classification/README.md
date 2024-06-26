# CreoleVal - Relation Classification

```
relation_classification/
├─ data/
│  ├─ relation_extraction/
├─ src/
│  ├─ data_generation/
│  ├─ ZS_BERT/
│  │  ├─ Wiki-ZSL/
├─ output/
├─ model/
```

## Getting Started

The codes for `ZS-BERT` are adapted from the repository https://github.com/dinobby/ZS-BERT, paper https://aclanthology.org/2021.naacl-main.272/.


### Environment Setup
Tested with: `Python 3.10` and `conda`, Ubuntu 22 with Nvidia GPU
- `conda create -n re python=3.10`
- `python3 -m pip install -r requirements.txt`
  - `nvidia` packages are for Linux machine with GPUs.
  

### Training
1. Enable your Python environment;
2. Run the `run_train.sh` for full training or `run_zs_bert_training.sh` for single model. The `relation_classification/` should be your working directory in order for all the relative paths to be resolved correctly;
3. After the training is done, the output will be stored in the `saved_models/` directory

This will train the zero-shot relatione extraction model 
with the transformer  `bert-base-multilingual-cased` and 
sentence embedder `bert-base-nli-mean-tokens`. Output is stored in `model/` directory.

The `run_train.sh` and `run_zs_bert_training.sh` scripts will automatically pull and store the data in the directory `src/ZS_BERT/Wiki-ZSL`.
Data is fetched from HuggingFace [yiyic/ukp_m5](https://huggingface.co/datasets/yiyic/ukp_m5).


### Pretrained Weights
The trained ZS-Bert models, fine-tuned on `bert-base-multilingual-cased` and `xlm-roberta-base`, combined with 
4 different sentence transformers, `bert-base-nli-mean-tokens`, `bert-large-nli-mean-tokens`, `xlm-r-bert-base-nli-mean-tokens`
and `xlm-r-100langs-bert-base-nli-mean-tokens` are uploaded to HuggingFace. 

1. [`yiyic/ZSBert_mBERT-finetuned`](https://huggingface.co/yiyic/ZSBert_mBERT-finetuned) 
2. [`yiyic/ZSBert_xlmr-finetuned`](https://huggingface.co/yiyic/ZSBert_xlmr-finetuned).

Use `bash get_pretrained_weights.sh` to download the weights, these will be saved in the `./pretrained_weights/` directory.



### 3. Inference
To run inference
1. Activate your `python` environment
2. Run the script `./infer_zsbert.sh` with the corresponding arguments.

E.g. `run_inference.sh bert-base-multilingual-cased bert-base-multilingual-cased pretrained_weights 1 2`
This will use the `mBERT base model` with `BERT sentence embedder` from the `pretrained_weights` directory using `random_seed=1` and `batch_size=2`

Modify these arguments to suit your needs.



## Data Generation
Directory `src/data_generation`

See the details in the paper. 

[//]: # ()
[//]: # (## Preprocessing )

[//]: # ()
[//]: # (1. read wikidumps, preprocessing text by removing HTML tags, annotate the items where there is a wikipedia link or by OpenTapioca)

[//]: # (`WikiReader.py`)

[//]: # (- Input: Wikidumps)

[//]: # (- Output: `data/processed_wikidumps/`)

[//]: # ()
[//]: # (2. processing the preprocessed wikidumps and prepare for Relation Extraction.)

[//]: # (- `processing_re.py`)

[//]: # (- input: `data/processed_wikidumps/`)

[//]: # (- output: `data/ent_extraction`)

[//]: # (  - json files, including tokens and the locations of the entities.)

[//]: # ()
[//]: # (## Clustering and Data Selection)

[//]: # ()
[//]: # (1. processing the preprocessed wikidumps)

[//]: # (`clustering_kmeans.py`)

[//]: # (- `load_json_data`)

[//]: # (- `save_dfs`)

[//]: # (- output: `data/clustering/dfs`)

[//]: # ()
[//]: # (2. Fuzzywuzzy, Affinity Propagation, LCS suffix tree.)

[//]: # (=> clustering the potential similar sentences together. )

[//]: # ()
[//]: # (- input: `data/clustering/dfs` )

[//]: # (- output: `data/affinityPropagation/results/`)

[//]: # (  - split by 500)

[//]: # (  - affinity clustering, the longest common sequence.)

[//]: # ()
[//]: # ()
[//]: # (## Post-processing results)

[//]: # ()
[//]: # (script `src/Relation Extraction/strech_data.py`)

[//]: # (- `get_properties_for_each_lang`)

[//]: # (  - inputfile `data/triples-wd/#LANG.csv`)

[//]: # (  - outputfile: `data/properties` the properties for each language for the datasets)

[//]: # (- `stretching_triples`)

[//]: # (  - get the triples from `data/triples-wd/#LANG.csv` into json files `data/triples-wd/#LANG.json`)

[//]: # (  )
[//]: # (- `post_processing`)

[//]: # (  -processing the ZS_BERT results with the wikidata_ids)

[//]: # (  - input: `ZS_BERT/output` and `data/processed_wikidumps/#_anno.csv`)

[//]: # (  - output: `data/post-processed/partial`)

[//]: # ()
[//]: # (## Check triples)

[//]: # (`python src/data_generation/check_triples.py xxx`)

[//]: # (- input files from `data/relation_extraction/properties`)

[//]: # (- check if the triples exist in wikidata.)



## List of Properties in the Generated Datasets:
ID: _LABEL_, Description
* __P106__ : _occupation_, occupation of a person; see also "field of work" (Property:P101), "position held" (Property:P39)	
* __P131__ : _located in the administrative territorial entity_ , the item is located on the territory of the following administrative entity. Use P276 (location) for specifying locations that are non-administrative places and for items about events	
* __P17__ : _country_,	sovereign state of this item; don't use on humans
* __P30__ : _continent_, continent of which the subject is a part
* __P31__ : _instance of_,	that class of which this subject is a particular example and member
* __P36__ : _capital_,	primary city of a country, province, state or other type of administrative territorial entity
* __P37__ : _official language_, language designated as official by this item
* __P39__ : _position held_, subject currently or formerly holds the object position or public office
* __P495__ : _country of origin_, 	country of origin of this item (creative work, food, phrase, product, etc.)
* __P1376__ : _capital of country_ , state, department, canton or other administrative division of which the municipality is the governmental seat
* __P2341__ : _indigenous to_,	area or ethnic group that a language, folk dance, cooking style, food or other cultural expression is found (or was originally found)
* __P2936__ : _language used_,	language widely used (spoken or written) in this place or at this event
* __P361__ : _part of_,	object of which the subject is a part (if this subject is already part of object A which is a part of object B, then please only make the subject part of object A). Inverse property of "has part" (P527, see also "has parts of the class" (P2670)).

Note that of these 13 Properties, 4 have no samples in the English Wiki-SZL train dataset: P1376, P2341, P2936, and P361. 

For further details on the distribution of these Properties across the Creole datasets, please see the [relation classification analysis]() 

[//]: # ()
[//]: # (- selected `data/relation_extraction/selected`)

[//]: # (- #1.output files from zs-bert `data/relation_extraction/zs-output`)

[//]: # ()
[//]: # (- use the selected json files to run inference again. )

[//]: # (` python inference.py ../../data/relation_extraction/selected/tpi.json ../../data/relation_extraction/selected/properties/tpi.json ../output/01`)

[//]: # ()

