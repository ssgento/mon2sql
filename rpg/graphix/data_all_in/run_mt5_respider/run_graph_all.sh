graph_output_train_path='data_all_in/data/output/graph_pedia_train_respider.bin'
graph_output_dev_path='data_all_in/data/output/graph_pedia_dev_respider.bin'
graph_all_output_path='data_all_in/data/output/graph_pedia_total_respider.bin'

# '''all bashes'''
# contextual semantic match
python3 -u data_all_in/graph_pedia_merge.py --graph_train_path ${graph_output_train_path} --graph_dev_path ${graph_output_dev_path} --graph_all_output_path ${graph_all_output_path}
