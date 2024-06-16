import json
import pdb

from map_subword_serialize import question_subword_matrix
import argparse
from transformers import AutoTokenizer
import pickle
from tokenizers import AddedToken
def find_word(word_list,word):
    for i in range(len(word_list)):
        if word==word_list[i]:
            return i
    return -1
def question_subword_dataset(seq2seq_dataset, syntax_dataset, tokenizer, output_path = None,mspider=False):

    for i_str, data in seq2seq_dataset.items():
        processed_question_toks = data['raw_question_toks']
        relations=syntax_dataset[int(i_str)]['relations']  if not mspider  else []
        question_sub_matrix, question_subword_dict,word_idss = \
        question_subword_matrix(processed_question_toks=processed_question_toks, relations=relations, tokenizer=tokenizer,mspider=mspider)
        data['question_subword_matrix'], data['question_subword_dict'] = question_sub_matrix, question_subword_dict
        data['question_token_relations'] = relations
        data['schema_linking'] = syntax_dataset[int(i_str)]['schema_linking']
        data['graph_idx'] = syntax_dataset[int(i_str)]['graph_idx']
        data['ranked_data']=syntax_dataset[int(i_str)]['ranked_data']
        data['ranked_serialized_schema']=syntax_dataset[int(i_str)]['ranked_serialized_schema']
        data['ranked_relation']=syntax_dataset[int(i_str)]['ranked_relation']
        data['output_sequence']=syntax_dataset[int(i_str)]['output_sequence']
        #存储questionid
        word_idss=word_idss[:-1]
        data['question_ids']=word_idss

        if int(i_str) % 500 == 0:
            print("processing {}th data".format(int(i_str)))

    if output_path:
        pickle.dump(seq2seq_dataset, open(output_path, "wb"))
    return seq2seq_dataset

if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--dataset_path', type=str, required=True, help='dataset path')
    arg_parser.add_argument('--syntax_path', type=str, required=False, help='syntax_dataset path')
    arg_parser.add_argument('--dataset_output_path', type=str, required=False, help='dataset_output_path')
    arg_parser.add_argument('--schema_output_path', type=str, required=False, help='schema_output_path')
    arg_parser.add_argument('--plm', type=str, required=True, help='plm path')
    arg_parser.add_argument('--mspider', action='store_true', help='whether is mspider,preprocess will differe')
    args = arg_parser.parse_args()

    tokenizer = AutoTokenizer.from_pretrained(args.plm, use_fast=True)
    if args.mspider:
        tokenizer.add_special_tokens({"additional_special_tokens": [AddedToken("\u202f")]})
        print('mspider tokenizer add token')
    else:
        tokenizer.add_tokens([' <', ' <='])
        print('t5 tokenizer add token')
    syntax_dataset = json.load(open(args.syntax_path, "r"))
    seq2seq_dataset = json.load(open(args.dataset_path, "r"))
    new_dataset = question_subword_dataset(seq2seq_dataset=seq2seq_dataset, syntax_dataset=syntax_dataset, tokenizer=tokenizer, output_path=args.dataset_output_path,mspider=args.mspider)

    print("finished question preprocessing")