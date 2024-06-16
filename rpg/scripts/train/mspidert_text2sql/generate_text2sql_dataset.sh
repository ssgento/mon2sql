set -e
source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg
# generate text2sql training dataset with noise_rate 0.2
python text2sql_data_generator.py \
    --input_dataset_path "./data/preprocessed_data/mspidert_preprocessed_train.json" \
    --output_dataset_path "./graphix/data_all_in/data/resdsql_train_mspidert.json" \
    --topk_table_num 6 \
    --topk_column_num 8 \
    --mode "train" \
    --noise_rate 0.2 \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"

# predict probability for each schema item in the eval set
python schema_item_classifier.py \
    --batch_size 32 \
    --device "0" \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/resdsql/mt5_encoder_text2sql_schema_item_classifier-xl-final-66" \
    --dev_filepath "./data/preprocessed_data/mspidert_preprocessed_dev.json" \
    --output_filepath "./data/preprocessed_data/mspidert_dev_with_probs.json" \
    --use_contents \
    --add_fk_info \
    --mode "eval" \
    --mt5

# generate text2sql development dataset
python text2sql_data_generator.py \
    --input_dataset_path "./data/preprocessed_data/mspidert_dev_with_probs.json" \
    --output_dataset_path "./graphix/data_all_in/data/resdsql_dev_mspidert.json" \
    --topk_table_num 6 \
    --topk_column_num 8 \
    --mode "eval" \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"
