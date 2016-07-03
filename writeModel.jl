function writeModel(modelFileName,A,B,pi)
    out_file = open(modelFileName,"w")
    
    # write contents of A
    write(out_file,"A\n")
    numOfStates = size(A,1)
    for sti in 1:numOfStates
        for stj in 1:numOfStates
            write(out_file,"$(A[sti,stj]) ")
        end
        
        write(out_file,"\n")
    end
    
    # write contents of B
    write(out_file,"B\n")
    numOfStates = size(B,1)
    numOfObservations = size(B,2)
    for st in 1:numOfStates
        for obs in 1:numOfObservations
            write(out_file,"$(B[st,obs]) ")
        end
        
        write(out_file,"\n")
    end
    
    # write contents of PI
    write(out_file,"Pi\n")
    numOfStates = size(pi,2)
    for st in 1:numOfStates
        write(out_file,"$(pi[st]) ")
    end
    write(out_file,"\n")
    
    close(out_file)
end
