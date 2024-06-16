source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg

python preprocessing.py \
    --mode "test" \
    --table_path './data/mspider/tables.json' \
    --input_dataset_path './data/mspider/test.json' \
    --output_dataset_path "./data/preprocessed_data/preprocessed_test.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --target_type "sql"

# predict probability for each schema item
python schema_item_classifier.py \
    --batch_size 32 \
    --device '0' \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/resdsql/mt5_encoder_text2sql_schema_item_classifier-xl-final-66" \
    --dev_filepath "./data/preprocessed_data/preprocessed_test.json" \
    --output_filepath "./data/preprocessed_data/test_with_probs.json" \
    --use_contents \
    --add_fk_info \
    --mode "test" \
    --mt5

# generate text2sql test set
python text2sql_data_generator.py \
    --input_dataset_path "./data/preprocessed_data/test_with_probs.json" \
    --output_dataset_path "./graphix/data_all_in/data/resdsql_test_mspidert.json" \
    --topk_table_num 6 \
    --topk_column_num 8 \
    --mode "test" \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"

# inference using the best text2sql ckpt
python text2sql_graphix.py \
    --batch_size 12 \
    --device 0 \
    --seed 42 \
    --save_path '/workspace/model/private/xrj/sota/mspidert/rpg/checkpoint-42665' \
    --mode "test" \
    --dev_filepath "./graphix/data_all_in/data/resdsql_dev_mspider.json" \
    --original_dev_filepath "./data/mspider/dev.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output './test/pred.sql'\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset_mspidert.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_mspidert.bin"

python text2sql_graphix.py \
    --batch_size 12 \
    --device 0 \
    --seed 42 \
    --save_path '/workspace/model/private/xrj/sota/mspidert/rpg/checkpoint-42665' \
    --mode "test" \
    --dev_filepath "./graphix/data_all_in/data/resdsql_test_mspider.json" \
    --original_dev_filepath "./data/mspider/test.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output './test/pred.sql'\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_test_dataset_mspidert.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_test_mspidert.bin"
