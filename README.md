# hmmok
My basic HMM implementation. I just coded it for fun :P

## How it works
Here are 3 major functions:

###obsv_prob 
This calculates the probability (with its logarithm) of a given observation sequence. The first argument is the name of the text file having the test sequence where the observations are numbered from 0 to `(number_of_unique_observations)-1`. The second argument is the name of the text file including the HMM model (lambda, A,B and pi) in the following format:

```
A
(a number of states x number of states matrix)
B
(a number of states x number of unique observations matrix)
Pi
(a 1 x number of states matrix)
```

###viterbi
This calculates the most probable state sequence given the observation sequence with the name given in the first argument. Again, the second parameter includes the name of the text file having the HMM model. It outputs a tuple containing the best state sequence, the probability of this sequence with its logarithm and the number of necessary transitions in the sequence.

###learn
It constructs the best HMM model given a set of observation sequences with the name given in the second argument. The first argument is the number of states expected in the model. Having finished the training, the contents of the model will be written to the file with the given name in the third argument.

##Running the code
Before using the functions, please include all the necessary files as shown below:

```
necessaryFiles = ["loadModelFile.jl","writeModel.jl","obsv_prob.jl","viterbi.jl","learn.jl"]

for file in necessaryFiles
    include(file)
end
```

##Credits
Like many people learning how to use and implement HMMs, I referred to [this paper of Rabiner et. al.](http://www.ece.ucsb.edu/Faculty/Rabiner/ece259/Reprints/tutorial%20on%20hmm%20and%20applications.pdf)