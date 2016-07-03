function obsv_prob(testSeqFile,modelFile)
	# load the test sequence and model
    test_file = open(testSeqFile)
    line = readline(test_file)
    testSeqStr = split(line," ")
    testSeq = map(x->parse(Int,x),testSeqStr)
    
    println(testSeq)
    
    # init the model vars
    A,B,pi = loadModelFile(modelFile)
    
    # obtain number of states, the number of observations in sequence
    # and initialize alpha and c
    numOfStates = size(pi,2)
    timeTaken = size(testSeq,1)
    alpha = zeros(timeTaken,numOfStates)
    c = zeros(1,timeTaken)
    
    # forward algorithm, initialization step
    for i in 1:numOfStates
        alpha[1,i] = pi[i]*B[i,testSeq[1]+1]
        # scaling step
        c[1] = 1 / sum(alpha[1,:])
    end
    # forward algorithm init. step, scaling cont'd
    alpha[1,:] = c[1]*alpha[1,:];
    
    # forward algorithm, inductive step
    for t in 1:(timeTaken-1)
        for j in 1:numOfStates
            summ = 0;
            for i in 1:numOfStates
                summ = summ + alpha[t,i]*A[i,j]
            end

            alpha[t+1,j] = summ*B[j,testSeq[t+1]+1]
        end
        
        # forward algorithm, inductive step, scaling part
        c[t+1] = 1 / sum(alpha[t+1,:])
        alpha[t+1,:] = c[t+1]*alpha[t+1,:]
    end
    
    # using scales, compute the probability with its logarithm
    logprob = -sum(log(c))
    probOGivenLambda = exp(logprob);
    
    return probOGivenLambda,logprob
end
