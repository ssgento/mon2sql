cd /workspace/algorithm/rpg/graphix

source /root/anaconda3/bin/activate rpg
echo "train rpg"
CUDA_VISIBLE_DEVICES=0 python seq2seq/run_seq2seq_train_mt5.py configs_mt5/train1.json