function viterbi(testSeqFile,modelFile)
    # load the test sequence and model
    test_file = open(testSeqFile)
    line = readline(test_file)
    testSeqStr = split(line," ")
    testSeq = map(x->parse(Int,x),testSeqStr)
    
    # init the model vars
    A,B,pi = loadModelFile(modelFile)
    
    # obtain the number of states, the number of observations in each sequence
    # and initialize delta and phi arrays
    numOfStates = size(pi,2)
    timeTaken = size(testSeq,1)
    delta = zeros(timeTaken,numOfStates)
    phi = zeros(timeTaken,numOfStates)
    
    # viterbi algorithm using loglikelihood, initialization step
    for i in 1:numOfStates
        delta[1,i] = log(pi[i]) + log(B[i,testSeq[1]+1])
        phi[1,i] = 0
    end
    
    # viterbi algorithm using loglikelihood, recursive step
    for t in 2:timeTaken
        for j in 1:numOfStates
            maxPath = delta[t-1,1] + log(A[1,j])
            maxState = 1
            
            for i in 2:numOfStates
                candidate = delta[t-1,i] + log(A[i,j])
                
                # update the path giving the maximum probability iteratively
                if candidate > maxPath
                    maxPath = candidate
                    maxState = i
                end
            end
            
            delta[t,j] = maxPath + log(B[j,testSeq[t]+1])
            phi[t,j] = maxState
        end
    end
    
    # viterbi algorithm, finding the last state of the optimal sequence
    # together with log(P*)
    optimalLogProb = delta[timeTaken,1]
    optimalLastState = 1
    for i in 2:numOfStates
        if optimalLogProb < delta[timeTaken,i]
            optimalLogProb = delta[timeTaken,i]
            optimalLastState = i
        end
    end
    
    # find the probability of being this optimal sequence, P*
    optimalProb = exp(optimalLogProb)
    
    # viterbi algorithm, backtracking
    optimalSequence = zeros(1,timeTaken)
    timesReversed = fliplr(collect(2:timeTaken)')
    optimalSequence[timeTaken] = optimalLastState
    for t in timesReversed
        optimalSequence[t-1] = phi[t,optimalSequence[t]]
    end
    
    # find the number of necessary state transitions
    numOfNecessaryTransitions = 0
    transitions = zeros(0,2)
    
    for t in 1:(timeTaken-1)
        if optimalSequence[t] != optimalSequence[t+1]
            matchIndex = -1
            numOfRecentTransitions = size(transitions,1)
            
            # in the sequence, record all unique state transitions
            for tr in 1:numOfRecentTransitions
                if transitions[tr,1] == optimalSequence[t] && transitions[tr,2] == optimalSequence[t+1]
                    matchIndex = tr
                end
            end
            
            if matchIndex == -1
				transitions = cat(1,transitions,[optimalSequence[t] optimalSequence[t+1]])
            end
        end
    end
    
    # the size of these unique transitions will give the number of
    # necessary state transitions
    numOfNecessaryTransitions = size(transitions,1)
    
    return map(x->convert(Int,x),optimalSequence-1),optimalProb,optimalLogProb,numOfNecessaryTransitions
end
