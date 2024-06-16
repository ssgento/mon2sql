eval_data='data_all_in/data/respider/dev.json'
tables_data='data_all_in/data/respider/tables.json'
tables_out='data_all_in/data/tables.bin'
eval_out='data_all_in/data/dev.bin'
syntax_eval_out='data_all_in/data/dev_syntax.json'
eval_sampling_out='data_all_in/data/dev_sampling.json'
configs='configs_mt5/data_pre_dev.json'
seq2seq_eval_dataset='data_all_in/data/output/seq2seq_dev_dataset_pre.json'
seq2seq_eval_out1='data_all_in/data/output/seq2seq_dev_dataset.bin'
seq2seq_eval_dataset_final='data_all_in/data/output/seq2seq_dev_dataset_respider_wq.json'
graph_output_dev_path='data_all_in/data/output/graph_pedia_dev_respider_wq.bin'


# serialize databases
echo "Starting to serialize databases ..."
python3 seq2seq/run_peteshaw_dev_mt5.py ${configs}

# question relation injection
echo "Starting to split question relations into subwords ..."
python3 -u data_all_in/map_subword_question.py --syntax_path ${syntax_eval_out} --dataset_path ${seq2seq_eval_dataset} \
--dataset_output_path ${seq2seq_eval_out1} --plm /workspace/model/pretrained/plm/mt5/mt5-large --mspider

# database relation injection
echo "Starting to split schema relations into subwords ..."
python3 -u data_all_in/map_subword_schema.py --dataset_path ${seq2seq_eval_out1} --dataset_output_path ${seq2seq_eval_out1} \
--plm /workspace/model/pretrained/plm/mt5/mt5-large  --table_path ${tables_out} --is_ranked

# schema_linking relation injection
echo "Starting to split schema-linking relations into subwords ..."
python3 -u data_all_in/map_subword_schema_linking.py --dataset_path ${seq2seq_eval_out1} --dataset_output_path ${seq2seq_eval_out1}

# construct graph now:
echo "Starting to generate graph examples ..."
python3 -u data_all_in/Graph_Processing.py --dataset_path ${seq2seq_eval_out1} --output_path ${seq2seq_eval_dataset_final} \
--graph_output_path ${graph_output_dev_path}

