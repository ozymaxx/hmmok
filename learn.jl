function learn(numOfStates,dataFile,hmmModelFile)
    # load the training data
    dataF = open(dataFile)
    line = ""
    numOfTrainData = 0
    
    while !eof(dataF)
		line = readline(dataF)
		numOfTrainData = numOfTrainData + 1
    end
    
    observationCount = size(split(strip(line)," "),1)
    close(dataF)
    
    data = zeros(numOfTrainData,observationCount)
    dataF = open(dataFile)
    
    row = 1
    while !eof(dataF)
		line = strip(readline(dataF))
		dataRowStr = split(line," ")
		dataRow = map(x->parse(Int,x),dataRowStr)
		data[row,:] = dataRow
		row = row + 1
    end
    
    close(dataF)
    
    # obtain the number of observations
    uniqueObservations = []
    for i in 1:numOfTrainData
        for j in 1:observationCount
            if sum(uniqueObservations .== data[i,j]) == 0
				push!(uniqueObservations,data[i,j])
            end
        end
    end
    numOfObservations = size(uniqueObservations,1)
    
    # initialize A,B and pi
    A = ones(numOfStates,numOfStates)*(1/numOfStates)
    B = 10*rand(numOfStates,numOfObservations)
    pii = ones(1,numOfStates)*(1/numOfStates)
    for i in 1:numOfStates
        B[i,:] = B[i,:] / sum(B[i,:])
    end
    
    # init alpha,beta,epsilon and gamma
    alphas = zeros(numOfTrainData,observationCount,numOfStates)
    betas = zeros(numOfTrainData,observationCount,numOfStates)
    epsilons = zeros(numOfTrainData,observationCount-1,numOfStates,numOfStates)
    gammas = zeros(numOfTrainData,observationCount-1,numOfStates)
    
    # repeat the reestimation operation many times, to reach a convergence
    for epoch in 1:200
        # keep the probability of each training sequence in an array
        P = zeros(1,numOfTrainData)
        
        # for each data in the training set
        for td in 1:numOfTrainData
            # keep the scales in an array
            c = zeros(1,observationCount)
            
            # forward algorithm, init step
            for i in 1:numOfStates
                alphas[td,1,i] = pii[i]*B[i,data[td,1]+1]
                # forward algorithm, init step, scaling
                c[1] = 1 / sum(alphas[td,1,:])
            end
            # forward algorithm, init step, scaling cont'd
            alphas[td,1,:] = c[1]*alphas[td,1,:]
            
            # forward algorithm, inductive step
            for t in 1:(observationCount-1)
                for j in 1:numOfStates
                    summ = 0;
                    for i in 1:numOfStates
                        summ = summ + alphas[td,t,i]*A[i,j]
                    end

                    alphas[td,t+1,j] = summ*B[j,data[td,t+1]+1]
                end
                
                # forward algorithm, inductive step, scaling
                c[t+1] = 1 / sum(alphas[td,t+1,:])
                alphas[td,t+1,:] = c[t+1]*alphas[td,t+1,:]
            end
            
            # obtain the probability of a training sequence
            P[td] = -sum(log(c))
            
            # backward algorithm, init step
            for i in 1:numOfStates
                betas[td,observationCount,i] = 1
            end
            # backward algortihm, init step, scaling
            betas[td,observationCount,:] = c[observationCount]*betas[td,observationCount,:]
            
            # backward algorithm, inductive step
            timesReversed = fliplr(collect(2:observationCount)')
            for t in timesReversed
                for i in 1:numOfStates
                    summ = 0

                    for j in 1:numOfStates
                        summ = summ + A[i,j]*B[j,data[td,t]+1]*betas[td,t,j]
                    end

                    betas[td,t-1,i] = summ
                end
                
                # backward algorithm, inductive step, scaling
                betas[td,t,:] = c[t]*betas[td,t,:]
            end
            
            # compute epsilon for each training data, using the formula
            # given in Rabiner's tutorial paper
            for t in 1:(observationCount-1)
                denominator = 0

                for i in 1:numOfStates
                    for j in 1:numOfStates
                        denominator = denominator + alphas[td,t,i]*A[i,j]*B[j,data[td,t+1]+1]*betas[td,t+1,j]
                    end
                end

                for i in 1:numOfStates
                    for j in 1:numOfStates
                        epsilons[td,t,i,j] = alphas[td,t,i]*A[i,j]*B[j,data[td,t+1]+1]*betas[td,t+1,j] / denominator
                    end
                end
            end
            
            # compute gamma for each training sequence, using the formula
            # given in Rabiner's tutorial paper
            for t in 1:(observationCount-1)
                for i in 1:numOfStates
                    gammas[td,t,i] = sum(epsilons[td,t,i,:])
                end
            end
        end

        # start computing the estimates of the parameters
        AEstimate = zeros(numOfStates,numOfStates)
        BEstimate = zeros(numOfStates,numOfObservations)
        piEstimate = zeros(1,numOfStates)
        
        # computing estimate of A, using the formula in the paper
        for i in 1:numOfStates
            for j in 1:numOfStates
                numerator = 0
                denominator = 0

                for td in 1:numOfTrainData
                    subn = 0
                    subd = 0

                    for t in 1:(observationCount-1)
                        subn = subn + epsilons[td,t,i,j]
                        subd = subd + gammas[td,t,i]
                    end

                    numerator = numerator + subn
                    denominator = denominator + subd
                end

                AEstimate[i,j] = numerator / denominator
            end
        end

        # computing estimate of B, using the formula in the paper
        for i in 1:numOfStates
            for l in 1:numOfObservations
                numerator = 0
                denominator = 0

                for td in 1:numOfTrainData
                    subn = 0
                    subd = 0

                    for t in 1:(observationCount-1)
                        if data[td,t]+1 == l
                            subn = subn + gammas[td,t,i]
                        end

                        subd = subd + gammas[td,t,i]
                    end

                    numerator = numerator + subn
                    denominator = denominator + subd
                end

                BEstimate[i,l] = numerator / denominator
            end
        end
        
        # computing estimate of pi, using the formula in the paper
        for i in 1:numOfStates
            piEstimate[i] = mean(gammas[:,1,i])
        end
        
        # use these estimates in the next epoch
        A = AEstimate
        B = BEstimate
        pii = piEstimate
        
        # display the loglikelihood reached in each epoch
        println("Epoch #$epoch, log(O|Lambda) = $(sum(P))")
    end
    
    println("Training done! Parameters of the model has been written to $(hmmModelFile) file.")
    
    # save the model to a txt file
    writeModel(hmmModelFile,A,B,pii)
    
    return A,B,pii
end
