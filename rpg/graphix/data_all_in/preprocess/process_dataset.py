#coding=utf8
import os, json, pickle, argparse, sys, time
#sys.path.append("/workspace/algorithm/rpg/graphix")
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from preprocess.common_utils import Preprocessor
# Inherit from LGESQL processing

def process_example(processor, entry,resdsql_item,db, trans, verbose=False,mspider=False):
    # preprocess raw tokens
    entry = processor.pipeline(entry, db,resdsql_item,verbose=verbose,mspider=mspider)
    return entry

def process_tables(processor, tables_list, output_path=None, verbose=False,mspider=False):
    tables = {}
    for each in tables_list:
        if verbose:
            print('*************** Processing database %s **************' % (each['db_id']))
        tables[each['db_id']] = processor.preprocess_database(each, verbose=verbose,mspider=mspider)
    print('In total, process %d databases .' % (len(tables)))
    if output_path is not None:
        pickle.dump(tables, open(output_path, 'wb'))
    return tables

def process_dataset(processor, dataset, tables,resdsql_data, output_path=None, skip_large=False, verbose=False,mspider=False):
    processed_dataset = []
    assert len(resdsql_data)==len(dataset)
    for idx, entry in enumerate(dataset):
        if skip_large and len(tables[entry['db_id']]['column_names']) > 100: continue

        if idx % 1000 == 0:
            print('*************** Processing %d-th sample **************' % (idx))
        if verbose:
            print('*************** Processing %d-th sample **************' % (idx))
        entry = process_example(processor, entry, resdsql_data[idx],tables[entry['db_id']], trans=None, verbose=verbose,mspider=mspider)
        processed_dataset.append(entry)
    print('In total, process %d samples , skip %d extremely large databases.' % (len(processed_dataset), len(dataset) - len(processed_dataset)))
    if output_path is not None:
        # serialize preprocessed dataset
        pickle.dump(processed_dataset, open(output_path, 'wb'))
    return processed_dataset

if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--db_dir', type=str, default='data_all_in/data/spider/database')
    arg_parser.add_argument('--dataset_path', type=str, required=True, help='dataset path')
    arg_parser.add_argument('--raw_table_path', type=str, help='raw tables path')
    arg_parser.add_argument('--resdsql_dataset_path', type=str, help='resdsql data')
    arg_parser.add_argument('--table_path', type=str, required=True, help='processed table path')
    arg_parser.add_argument('--output_path', type=str, required=True, help='output preprocessed dataset')
    arg_parser.add_argument('--skip_large', action='store_true', help='whether skip large databases')
    arg_parser.add_argument('--verbose', action='store_true', help='whether print processing information')
    arg_parser.add_argument('--mspider',action='store_true', help='whether is mspider,preprocess will differe')
    args = arg_parser.parse_args()

    processor = Preprocessor(db_dir=args.db_dir, db_content=True)
    # loading database and dataset

    if args.raw_table_path:
        # need to preprocess database items
        tables_list = json.load(open(args.raw_table_path, 'r'))
        print('Firstly, preprocess the original databases ...')
        start_time = time.time()
        tables = process_tables(processor, tables_list, args.table_path, args.verbose,args.mspider)
        print('Databases preprocessing costs %.4fs .' % (time.time() - start_time))
    else:
        tables = pickle.load(open(args.table_path, 'rb'))
    dataset = json.load(open(args.dataset_path, 'r'))

    if args.resdsql_dataset_path:
        with open(args.resdsql_dataset_path, 'r') as f1:
            resdsql_data = json.load(f1)

    start_time = time.time()
    print(len(dataset))
    dataset = process_dataset(processor, dataset, tables,resdsql_data, args.output_path, args.skip_large, verbose=args.verbose,mspider=args.mspider)

    print('Dataset preprocessing costs %.4fs .' % (time.time() - start_time))
