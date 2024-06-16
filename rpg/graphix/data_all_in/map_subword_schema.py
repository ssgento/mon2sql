import json
import pdb

# from map_subword_serialize_sampling import schema_subword_matrix
from map_subword_serialize import schema_subword_matrix
import argparse
from transformers import AutoTokenizer
import pickle
from tokenizers import AddedToken
def schema_subword_dataset(seq2seq_dataset, tokenizer, tables,is_ranked=False,output_path = None):
    i = 0
    print(f'is_ranked:{is_ranked}')
    for i_str, data in seq2seq_dataset.items():

        if not is_ranked:
            table_items = data['db_table_names']
            column_items = data['db_column_names']['column_name']
            # sampled_columns_idx = data['sampled_columns_idx']
            # new_mapping = data['new_mapping'] # TODO
            db_id = data['db_id']
            # db_sep = data['struct_in']
            db_sep = data['serialized_schema']
        if is_ranked:
            table_items=data['ranked_data']['table_names_original']
            column_items=[i[1] for i in data['ranked_data']['column_names_original']]
            db_sep=data['ranked_serialized_schema']
            ranked_relation=data['ranked_relation']

        # db_sep = 'schema: {}'.format(data['struct_in'])
        subword_matrix, subword_mapping_dict, new_struct_in, schema_to_ids = schema_subword_matrix(data=data,db_sep=db_sep, table_items=table_items, tokenizer=tokenizer,
                                                                    column_items=column_items, init_idx=0, tables=tables,is_ranked=is_ranked,ranked_relation=ranked_relation)
                                                                    # column_items=column_items, new_mapping=new_mapping, init_idx=0, tables=tables)
                                                                    # column_items=column_items, init_idx=0, tables=tables, sampled_columns_idx=sampled_columns_idx)

        # ls=tokenizer.encode(new_struct_in)
        # s=""
        # for _,i in schema_to_ids.items():
        #     templ=[]
        #     for j in i:
        #         templ.append(ls[i])
        #     s+=tokenizer.decode(templ)
        # print(s)

        data['schema_subword_relations'] = subword_matrix
        data['schema_subword_mapping_dict'] = subword_mapping_dict
        data['new_struct_in'] = new_struct_in
        data['schema_to_ids'] = schema_to_ids
        data['input_ids']=data['question_ids']+tokenizer.encode(new_struct_in)
        data['attention_mask']=[1 for _ in range(len(data['input_ids']))]

        # data['schema_idx_ori'] = schema_idx_ori
        # data['sampled_columns_idx'] = sampled_columns_idx
        i += 1
        if i % 1000 == 0:
            print("******************************* processing {}th datasets *******************************".format(i))


    if output_path:
        pickle.dump(seq2seq_dataset, open(output_path, "wb"))

    return seq2seq_dataset


if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--dataset_path', type=str, required=False, help='dataset path')
    arg_parser.add_argument('--table_path', type=str, required=False, help='table path')
    arg_parser.add_argument('--dataset_output_path', type=str, required=False, help='dataset_output_path')
    arg_parser.add_argument('--schema_output_path', type=str, required=False, help='schema_output_path')
    arg_parser.add_argument('--plm', type=str, required=True, help='plm path')
    arg_parser.add_argument('--mspider', action='store_true', help='whether is mspider,preprocess will differe')
    arg_parser.add_argument('--is_ranked', action='store_true', help='whether is mspider,preprocess will differe')
    args = arg_parser.parse_args()

    tokenizer = AutoTokenizer.from_pretrained(args.plm)
    if args.mspider:
        tokenizer.add_special_tokens({"additional_special_tokens": [AddedToken("\u202f")]})
        print('add mspider token')
    else:
        tokenizer.add_tokens([' <', ' <='])
        print('add t5 token')
    tables = pickle.load(open(args.table_path, "rb"))

    seq2seq_dataset = pickle.load(open(args.dataset_path, "rb"))
    new_tables = schema_subword_dataset(seq2seq_dataset=seq2seq_dataset, tokenizer=tokenizer, tables=tables,
                                        output_path=args.dataset_output_path,is_ranked=args.is_ranked)

    print(" schema subword construction finished ")