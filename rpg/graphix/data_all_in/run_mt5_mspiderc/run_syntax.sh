train_mode='train'
train_data='data_all_in/data/mspider/train.json'
tables_data='data_all_in/data/mspider/tables.json'
tables_out='data_all_in/data/tables.bin'
train_out='data_all_in/data/train.bin'
syntax_train_out='data_all_in/data/train_syntax.json'
resdsql_train_data='data_all_in/data/resdsql_train_mspider_l.json'
resdsql_dev_data='data_all_in/data/resdsql_dev_mspider_l.json'
eval_mode='dev'
eval_data='data_all_in/data/mspider/dev.json'
tables_data='data_all_in/data/mspider/tables.json'
tables_out='data_all_in/data/tables.bin'
eval_out='data_all_in/data/dev.bin'
syntax_eval_out='data_all_in/data/dev_syntax.json'


# '''all bashes'''
# contextual semantic match
#export PATH="/opt/conda/bin:$PATH"

echo "Starting to preprocess the basic train dataset"
python3 -u data_all_in/preprocess/process_dataset.py --dataset_path ${train_data} --raw_table_path ${tables_data} --table_path ${tables_out} \
--output_path ${train_out}  --mspider --resdsql_dataset_path ${resdsql_train_data}


#python3 -u data_all_in/preprocess/process_dataset.py --dataset_path ${train_data}  --table_path ${tables_out} \
#--output_path ${train_out} --skip_large --mspider --resdsql_dataset_path ${resdsql_train_data}

# inject syntax
echo "Starting to preprocess the train dataset for training..."
python3 -u data_all_in/preprocess/inject_syntax.py --dataset_path ${train_out} --mode ${train_mode} --output_path ${syntax_train_out} --flag 'mspider'

# '''all bashes'''
# contextual semantic match
echo "Starting to preprocess the basic dev dataset"
python3 -u data_all_in/preprocess/process_dataset.py --dataset_path ${eval_data} --table_path ${tables_out} \
--output_path ${eval_out}  --mspider --resdsql_dataset_path ${resdsql_dev_data}


# inject syntax
echo "Starting to preprocess the eval dataset for dev..."
python3 -u data_all_in/preprocess/inject_syntax.py --dataset_path ${eval_out} --mode ${eval_mode} --output_path ${syntax_eval_out} --flag 'mspider'


test_mode='test'
test_data='data_all_in/data/mspider/test.json'
tables_data='data_all_in/data/mspider/tables.json'
tables_out='data_all_in/data/tables.bin'
test_out='data_all_in/data/test.bin'
syntax_test_out='data_all_in/data/test_syntax.json'
resdsql_test_data='data_all_in/data/resdsql_test_mspider.json'
python3 -u data_all_in/preprocess/process_dataset.py --dataset_path ${test_data} --table_path ${tables_out} \
--output_path ${test_out} --skip_large --mspider --resdsql_dataset_path ${resdsql_test_data}


# inject syntax
echo "Starting to preprocess the eval dataset for test..."
python3 -u data_all_in/preprocess/inject_syntax.py --dataset_path ${test_out} --mode ${test_mode} --output_path ${syntax_test_out}
