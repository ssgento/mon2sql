import pickle,json
if __name__=="__main__":
    with open("./data_all_in/data/train.bin","rb") as f1:
        data=pickle.load(f1)[0]
    for key in data:
        print(key)
    #print(data["schema_linking"][1])
    for i in data["schema_linking"][1]:
        print(i)
    print(len(data['schema_linking'][1][1]))