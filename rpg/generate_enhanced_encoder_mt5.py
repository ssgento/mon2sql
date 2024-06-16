from transformers import MT5ForConditionalGeneration,MT5TokenizerFast
from utils.classifier_model import MyClassifier
from tokenizers import AddedToken
classifier_path="/workspace/model/private/xrj/classifier/classifier-mt5-large-mnc"
out_path="/workspace/model/private/xrj/enhance"
mt5_path="/workspace/model/pretrained/plm/mt5/mt5-large"
import torch
def get_parser():
    pass
def main():

    tokenizer_class = MT5TokenizerFast
    tokenizer = tokenizer_class.from_pretrained(
        classifier_path,
        add_prefix_space=True
    )

    classifier = MyClassifier(
        model_name_or_path=classifier_path,
        vocab_size=len(tokenizer),
        mode='test'
    )
    # load fine-tuned params
    classifier.load_state_dict(torch.load(classifier_path + "/dense_classifier.pt", map_location=torch.device('cpu')))

    mt5 = MT5ForConditionalGeneration.from_pretrained(mt5_path)
    print(mt5.encoder)

    mt5.encoder=classifier.plm_encoder.encoder
    mt5.resize_token_embeddings(len(tokenizer))
    print(classifier.plm_encoder.encoder)
    mt5.save_pretrained(save_directory=out_path + "/mt5-large-enhanced-mnc")
    tokenizer.save_pretrained(save_directory=out_path + "/mt5-large-enhanced-mnc")
if __name__=="__main__":
    main()