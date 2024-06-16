set -e
source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg
# preprocess train_cspider dataset
python preprocessing.py \
    --mode "train" \
    --table_path "./data/mspider/tables.json" \
    --input_dataset_path "./data/mspider/train.json" \
    --output_dataset_path "./data/preprocessed_data/mspidert_preprocessed_train.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --target_type "sql"

# preprocess dev dataset
python preprocessing.py \
    --mode "eval" \
    --table_path "./data/mspider/tables.json" \
    --input_dataset_path "./data/mspider/dev.json" \
    --output_dataset_path "./data/preprocessed_data/mspidert_preprocessed_dev.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --target_type "sql"


