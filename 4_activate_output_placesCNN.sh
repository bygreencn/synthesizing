#/bin/bash

if [ "$#" -ne "1" ]; then
  echo "Provide 1 output unit number e.g. 198 for waiting room (MIT Places 205)."
  exit 1
fi

# Get label for each unit
path_labels="synset_words.txt"
IFS=$'\n' read -d '' -r -a labels < ${path_labels}

opt_layer=fc6
act_layer=fc8
units="${1}" #"643 10 304 629 945 437"
xy=0

# Net
net_weights="nets/placesCNN/places205CNN_iter_300000.caffemodel"
net_definition="nets/placesCNN/places205CNN_deploy.prototxt"

# Hyperparam settings for visualizing AlexNet
iters="200"
weights="99"
rates="8.0"
end_lr=1e-10

# Clipping
clip=0
multiplier=3
bound_file=act_range/${multiplier}x/${opt_layer}.txt
init_file="None" #"images/cat.jpg"

# Debug
debug=0
if [ "${debug}" -eq "1" ]; then
  rm -rf debug
  mkdir debug
fi

# Output dir
output_dir="test"
rm -rf ${output_dir}
mkdir ${output_dir}

# Running optimization across a sweep of hyperparams
for unit in ${units}; do

  for seed in {0..0}; do
  #for seed in {0..8}; do

    for n_iters in ${iters}; do
      for w in ${weights}; do
        for lr in ${rates}; do

          L2="0.${w}"

          # Optimize images maximizing fc8 unit
          python ./act_max.py \
              --act_layer ${act_layer} \
              --opt_layer ${opt_layer} \
              --unit ${unit} \
              --xy ${xy} \
              --n_iters ${n_iters} \
              --start_lr ${lr} \
              --end_lr ${end_lr} \
              --L2 ${L2} \
              --seed ${seed} \
              --clip ${clip} \
              --bound ${bound_file} \
              --debug ${debug} \
              --output_dir ${output_dir} \
              --init_file ${init_file} \
              --net_weights ${net_weights} \
              --net_definition ${net_definition}
        done
      done
    done
  
  done
done
