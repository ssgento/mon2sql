test_data='data_all_in/data/mspider/test.json'
tables_data='data_all_in/data/mspider/tables.json'
tables_out='data_all_in/data/tables.bin'
test_out='data_all_in/data/test.bin'
syntax_test_out='data_all_in/data/test_syntax.json'
test_sampling_out='data_all_in/data/test_sampling.json'
configs='configs_mt5/data_pre_test.json'
seq2seq_test_dataset='data_all_in/data/output/seq2seq_test_dataset_pre.json'
seq2seq_test_out1='data_all_in/data/output/seq2seq_test_dataset.bin'
seq2seq_test_dataset_final='data_all_in/data/output/seq2seq_test_dataset_mspidert.json'
graph_output_test_path='data_all_in/data/output/graph_pedia_test_mspidert.bin'


# serialize databases
echo "Starting to serialize databases ..."
python3 seq2seq/run_peteshaw_test_mt5.py ${configs}

# question relation injection
echo "Starting to split question relations into subwords ..."
python3 -u data_all_in/map_subword_question.py --syntax_path ${syntax_test_out} --dataset_path ${seq2seq_test_dataset} \
--dataset_output_path ${seq2seq_test_out1} --plm /workspace/model/pretrained/plm/mt5/mt5-large --mspider

# database relation injection
echo "Starting to split schema relations into subwords ..."
python3 -u data_all_in/map_subword_schema.py --dataset_path ${seq2seq_test_out1} --dataset_output_path ${seq2seq_test_out1} \
--plm /workspace/model/pretrained/plm/mt5/mt5-large --mspider --table_path ${tables_out} --is_ranked

# schema_linking relation injection
echo "Starting to split schema-linking relations into subwords ..."
python3 -u data_all_in/map_subword_schema_linking.py --dataset_path ${seq2seq_test_out1} --dataset_output_path ${seq2seq_test_out1}

# construct graph now:
echo "Starting to generate graph examples ..."
python3 -u data_all_in/Graph_Processing.py --dataset_path ${seq2seq_test_out1} --output_path ${seq2seq_test_dataset_final} \
--graph_output_path ${graph_output_test_path}

