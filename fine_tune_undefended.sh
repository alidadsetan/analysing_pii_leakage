#!/bin/bash
#SBATCH --gres=gpu:a40:1
#SBATCH -J fine-tune-undefended
#SBATCH -c 16
#SBATCH --mem=32GB
#SBATCH --output="/h/dadsetan/fine_tune_undefended.log"
#SBATCH --open-mode=append
#SBATCH --time=16:00:00

#SBATCH --signal=B:USR1@10

if [ "$#" -eq 0 ]
then
  echo "please provide the run number"
  exit 1
fi


RUN_NUMBER="$1"

handler()
{
echo "function handler called at $(date)"
echo "$0, $RUN_NUMBER"
sbatch $0 $RUN_NUMBER
}

# register signal handler
trap handler SIGUSR1


# setup the environment
source $HOME/pii_leakage_env.sh
eval "$(/h/dadsetan/anaconda/bin/conda shell.bash hook)"
conda activate $HOME/condaenvs/pii_leakage
CHECKPOINT_PATH="/checkpoint/dadsetan/fine_tune_undefended_$1"
if [ ! -d $CHECKPOINT_PATH ]; then
  mkdir $CHECKPOINT_PATH
fi

# running the script
cd $HOME/analysing_pii_leakage
python ./examples/fine_tune.py --config_path ./configs/fine-tune/echr-gpt2-small-undefended.yml --output_dir $CHECKPOINT_PATH &
wait
