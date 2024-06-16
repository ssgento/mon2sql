set -e
source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg
# preprocess train_spider dataset
python preprocessing.py \
    --mode "train" \
    --table_path "./data/respider/tables.json" \
    --input_dataset_path "./data/respider/train.json" \
    --output_dataset_path "./data/preprocessed_data/respider_preprocessed_train.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --target_type "sql"

# preprocess dev dataset
python preprocessing.py \
    --mode "eval" \
    --table_path "./data/respider/tables.json" \
    --input_dataset_path "./data/respider/dev.json" \
    --output_dataset_path "./data/preprocessed_data/respider_preprocessed_dev.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database"\
    --target_type "sql"
