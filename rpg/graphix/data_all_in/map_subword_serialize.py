import os, json, pickle, argparse, sys, time
import pdb
import torch
from collections import defaultdict
import numpy as np
import re

def quote_normalization(question):
    """ Normalize all usage of quotation marks into a separate \" """
    new_question, quotation_marks = [], ["'", '"', '`', '‘', '’', '“', '”', '``', "''", "‘‘", "’’"]
    for idx, tok in enumerate(question):
        if len(tok) > 2 and tok[0] in quotation_marks and tok[-1] in quotation_marks:
            new_question += ["\"", tok[1:-1], "\""]
        elif len(tok) > 2 and tok[0] in quotation_marks:
            new_question += ["\"", tok[1:]]
        elif len(tok) > 2 and tok[-1] in quotation_marks:
            new_question += [tok[:-1], "\"" ]
        elif tok in quotation_marks:
            new_question.append("\"")
        elif len(tok) == 2 and tok[0] in quotation_marks:
            # special case: the length of entity value is 1
            if idx + 1 < len(question) and question[idx + 1] in quotation_marks:
                new_question += ["\"", tok[1]]
            else:
                new_question.append(tok)
        else:
            new_question.append(tok)
    return new_question

def match_multi_words(cur_idx: int, column_cur_idx: list, seq_lst):
    column_cur_idx.append(cur_idx)
    if seq_lst[cur_idx + 1] in [",", "|"]:
        return column_cur_idx
    else:
        match_multi_words(cur_idx + 1, column_cur_idx, seq_lst)

def subword_dict(input_ids):
    word_subword_mapping = defaultdict()
    for sub_idx, word_idx in enumerate(input_ids):
        if word_idx is None:
            break
        if word_idx in word_subword_mapping:
            word_subword_mapping[word_idx].append(sub_idx)
        else:
            word_subword_mapping[word_idx] = [sub_idx]

    return word_subword_mapping

def expand_ids(split_ids: list, subword_dict: dict):
    expand_ids_lst = []
    for id in split_ids:
        expand_ids_lst += subword_dict[id]

    return expand_ids_lst


def ids_mapping(idx_lst: list, subword_dict: dict, schema_items: list):
    new_ids_mapping = defaultdict()
    # key: index of schema items; value: indexes of subword ids in tokenized ids
    for i, sub_idx in enumerate(idx_lst):
        if type(sub_idx) is int:
            new_ids_mapping[i] = subword_dict[sub_idx]
        else:
            # home town -> [32, 34]
            new_ids_mapping[i] = expand_ids(sub_idx, subword_dict)

    return new_ids_mapping

def question_subword_matrix(processed_question_toks, relations, tokenizer,mspider=False):

    # question: a str of question
    # relations: matrix of relations
    # return: new subword-based relation matrix
    question_dict = defaultdict()
    question = " ".join(processed_question_toks) + " ;"
    tokenized_question = tokenizer(question)
    word_ids,tok_len=[],[]
    word_idss,tokenized_question_toks_ids = [],[]
    all_tok_len=0
    question_toks=list(processed_question_toks)
    question_toks.append(";")
    for i in question_toks:
        tok_id_list=tokenizer(i)['input_ids'][:-1]
        all_tok_len+=len(tok_id_list)
        tok_len.append(len(tok_id_list))
        word_idss+=tok_id_list
    question_len=len(tokenized_question["input_ids"][:-1])

    if all_tok_len!=question_len:
        for i in range(all_tok_len):
            if word_idss[i]!=tokenized_question["input_ids"][:-1][i]:
                print(i)
                print(word_idss[i])
                print(tokenizer.decode(word_idss[i]))
                break
        print(question)
        print(tokenizer.decode(word_idss+[1]))
        print(tokenizer.decode(tokenized_question["input_ids"]))
    for i in range(len(tok_len)):
        for j in range(tok_len[i]):
            word_ids.append(i)

    aword_ids = tokenized_question.word_ids()
    # reduce the special token like ("101", "102")
    aword_ids = aword_ids[:-1]
    subword_matrix = [['symbol'] * len(word_ids) for _ in range(len(word_ids))]
    if mspider:
        relations=subword_matrix

    # contruct a dict mapping from idx of original tokens --> list of subwords: {5: [5, 6], 6: [7], }
    for i,j in enumerate(word_ids):
        # i: index of sub words
        # j: index of original tokens
        if j in question_dict:
            question_dict[j].append(i)
        else:
            question_dict[j] = [i]
    if len(processed_question_toks) + 1 != len(question_dict):
        # qu_list=[]
        # for _,i in question_dict.items():
        #     templist=[]
        #     for j in i:
        #         templist.append(tokenized_question["input_ids"][j])
        #     qu_list.append(templist)
        # print(tokenizer.decode(qu_list[-1]))
        print(tokenizer.decode(word_idss+[1]))
        print(tokenizer.decode(tokenized_question["input_ids"]))
        print("{} processed_question_toks".format(len(processed_question_toks)))
        print("question dict is {}".format(question_dict))
        print("computed length of question_dict is {}".format(len(question_dict)))
        print("processed_question_toks: {}".format(processed_question_toks))

    assert len(processed_question_toks) + 1 == len(question_dict)

    # fully connect subwords as new matrix:
    for r in range(len(processed_question_toks)):
        for c in range(len(processed_question_toks)):
            for sub_idx_r in question_dict[r]:
                for sub_idx_c in question_dict[c]:
                    subword_matrix[sub_idx_r][sub_idx_c] = relations[r][c]

    subword_matrix = np.array(subword_matrix, dtype='<U100')
    subword_matrix = subword_matrix.tolist()

    return subword_matrix, question_dict,word_idss+[1]

def schema_subword_matrix(data,db_sep, init_idx, tables, tokenizer,ranked_relation,table_items=None, column_items=None,is_ranked=False):


    struct_in = "schema: {} | *".format(db_sep)
    # normalize struct_in:
    struct_in = re.sub('  +', ' ', struct_in)

    table_idx_lst, column_idx_lst, db_id = find_schema_idx(db_seq=struct_in, table_items=table_items,
                                                                       column_items=column_items,init_idx=0)

    if len(table_idx_lst + column_idx_lst) != len(column_items + table_items):
        print('hello')
        print("wrong: {}".format(struct_in))
        pdb.set_trace()

    assert len(table_idx_lst + column_idx_lst) == len(column_items + table_items)
    if is_ranked:
        schema_relations = ranked_relation
    else:
        schema_relations = tables[db_id]['relations']
    schema_idx_lst = table_idx_lst + column_idx_lst

    schema_subword_token = tokenizer(struct_in, max_length=1024) # 546 is the longest input seq for schema

    schema_ids = schema_subword_token.word_ids()[:-1]
    # print(struct_in)
    # print(schema_subword_token.tokens())
    # print(schema_ids)

    # pdb.set_trace()
    subword_mapping_dict = subword_dict(schema_ids)
    subword_matrix = [['symbol'] * len(schema_ids) for _ in range(len(schema_ids))]
    # print(subword_mapping_dict)
    # for _,i in subword_mapping_dict.items():
    #     ls=[]
    #
    #     for j in i:
    #         ls.append(schema_subword_token['input_ids'][j])
    #     print(tokenizer.decode(ls),end=f" {i}\n")
    # quit()
    # get the mapping dict for original schema items:
    schema_items = table_items + column_items
    schema_to_ids = ids_mapping(idx_lst=schema_idx_lst, subword_dict=subword_mapping_dict, schema_items=schema_items)

    assert len(schema_to_ids) == len(schema_idx_lst)
    # for _,i in schema_to_ids.items():
    #     ls=[]
    #
    #     for j in i:
    #         ls.append(schema_subword_token['input_ids'][j])
    #     print(tokenizer.decode(ls),end=f" {i}\n")
    # print(schema_items)
    # quit()
    # fully-connected subwords as new matrix including dummy symbols:

    for r in range(len(schema_idx_lst)):
        for c in range(len(schema_idx_lst)):
            for sub_idx_r in schema_to_ids[r]:
                for sub_idx_c in schema_to_ids[c]:
                    subword_matrix[sub_idx_r][sub_idx_c] = schema_relations[r][c]

    subword_matrix = np.array(subword_matrix, dtype='<U100')
    subword_matrix = subword_matrix.tolist()

    return subword_matrix, subword_mapping_dict, struct_in, schema_to_ids

def find_schema_idx(db_seq, table_items, column_items, init_idx=0):
    #处理一个无下划线的列
    flag = False
    tl=[i.lower() for i in table_items]
    cl=[i.lower() for i in column_items]
    tp,cp={},{}
    for i in range(len(tl)):
        flag=True
        if ' ' in tl[i]:
            tp[i]=tl[i].replace(' ','_')
    for i in range(len(cl)):
        flag = True
        if ' ' in cl[i]:
            cp[i]=cl[i].replace(' ','_')
    for i,j in tp.items():
        if tl[i] in db_seq:
            db_seq=db_seq.replace(tl[i],j)
    for i,j in cp.items():
        if cl[i] in db_seq:
            db_seq=db_seq.replace(cl[i],j)

    seq_lst=db_seq.split(" ")

    for i,j in tp.items():
        for p in range(len(seq_lst)):
            if seq_lst[p] == j:
                seq_lst[p]=tl[i]
    for i,j in cp.items():
        for p in range(len(seq_lst)):
            if seq_lst[p] == j:
                seq_lst[p]=cl[i]


    special_token = ["|", ':', ',', 'schema:', '(', ')']
    table_idx_lst = []
    column_idx_lst = []
    schema_items = [item.lower() for item in table_items + column_items]
    if flag:
        schema_elements=schema_items

    else:
        schema_elements = " ".join(schema_items).split(" ")

    db_id = ""

    for i, item in enumerate(seq_lst):
        if item in special_token:
            continue
        if seq_lst[i - 1] == '(':
            continue

        if i < len(seq_lst) - 1:
            if seq_lst[i - 1] == seq_lst[i + 1] == '|':
                db_id = item

            elif seq_lst[i - 1] == '|' and seq_lst[i + 1] == ':':
                table_idx_lst.append(i + init_idx)

            elif seq_lst[i - 1] == ":":
                # head columns
                if seq_lst[i + 1] == ",":
                    # head columns without value
                    if item in schema_elements:
                        column_idx_lst.append(i + init_idx)
                elif seq_lst[i + 1] == "(":
                    # head columns with value
                    if item in schema_elements:
                        column_idx_lst.append(i + init_idx)

            elif seq_lst[i - 1] == ",":
                if seq_lst[i + 1] == "," or seq_lst[i + 1] == "(":
                    # middle columns (with values):
                    if item in schema_elements:
                        column_idx_lst.append(i + init_idx)
                elif seq_lst[i + 1] == "|":
                    # tail columns:
                    if item in schema_elements:
                        column_idx_lst.append(i + init_idx)

                elif seq_lst[i + 1] == ")":
                    continue

                else:
                    # columns with multiple words: "home town"
                    temp_idx_lst = []
                    match_multi_words(cur_idx=i + init_idx, column_cur_idx=temp_idx_lst, seq_lst=seq_lst)
                    if item in schema_elements:
                        column_idx_lst.append(temp_idx_lst)
                # append the last element:
        else:
            if item in schema_elements:
                if seq_lst[i - 1] == "," or seq_lst[i - 1] == ":" or item == '*':
                    column_idx_lst.append(i + init_idx)

    # put * into the head position:
    star_idx = column_idx_lst.pop()
    column_idx_lst.insert(0, star_idx)

    # pdb.set_trace()
    if len(table_idx_lst + column_idx_lst) != len(column_items + table_items):
        print("wrong: {}".format(db_seq))
        pdb.set_trace()
    assert len(table_idx_lst + column_idx_lst) == len(table_items + column_items)
    return table_idx_lst, column_idx_lst, db_id

def schema_linking_subword(question_subword_dict: dict, schema_2_ids: dict, schema_linking: tuple, question_subword_len: int, schema_subword_len: int,i=0,data=None):
    # assert dim match:
    q_schema_mat, schema_q_mat = schema_linking
    assert len(question_subword_dict) == len(q_schema_mat) + 1
    assert len(schema_2_ids) == len(schema_q_mat)

    q_schema_subword_matrix = [[0] * schema_subword_len for _ in range(question_subword_len)]
    schema_q_subword_matrix = [[0] * question_subword_len for _ in range(schema_subword_len)]
    # pdb.set_trace()

    # construct subword_matrix for q_schema_mat:
    for r in range(len(q_schema_mat)):
        for c in range(len(schema_2_ids)):
            temp_relation = q_schema_mat[r][c]
            for sub_idx_r in question_subword_dict[r]:
                for sub_idx_c in schema_2_ids[c]:
                    q_schema_subword_matrix[sub_idx_r][sub_idx_c] = temp_relation

    # construct subword_matrix for schema_q_mat:
    for r_s in range(len(schema_2_ids)):
        for c_q in range(len(q_schema_mat)):
            tmp_relation = schema_q_mat[r_s][c_q]
            for sub_idx_s in schema_2_ids[r_s]:
                for sub_idx_q in question_subword_dict[c_q]:
                    schema_q_subword_matrix[sub_idx_s][sub_idx_q] = tmp_relation

    q_schema_subword_matrix = np.array(q_schema_subword_matrix, dtype='<U100')
    schema_q_subword_matrix = np.array(schema_q_subword_matrix, dtype='<U100')

    subword_schema_linking = (q_schema_subword_matrix.tolist(), schema_q_subword_matrix.tolist())

    return subword_schema_linking


