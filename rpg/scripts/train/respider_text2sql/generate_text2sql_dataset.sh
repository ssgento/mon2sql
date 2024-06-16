set -e

# generate text2sql training dataset with noise_rate 0.2
python text2sql_data_generator.py \
    --input_dataset_path "./data/preprocessed_data/preprocessed_train.json" \
    --output_dataset_path "./graphix/data_all_in/data/respider_train.json" \
    --topk_table_num 4 \
    --topk_column_num 5 \
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
    --save_path "/workspace/model/private/xrj/resdsql/xlm-roberta-large-en" \
    --dev_filepath "./data/preprocessed_data/respider_preprocessed_dev.json" \
    --output_filepath "./data/preprocessed_data/respider_dev_with_probs.json" \
    --use_contents \
    --add_fk_info \
    --mode "eval"

# generate text2sql development dataset
python text2sql_data_generator.py \
    --input_dataset_path "./data/preprocessed_data/respider_dev_with_probs.json" \
    --output_dataset_path "./graphix/data_all_in/data/respider_dev.json" \
    --topk_table_num 4 \
    --topk_column_num 5 \
    --mode "eval" \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"