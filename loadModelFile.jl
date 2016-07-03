function loadModelFile(modelFileName)
	# open the file and init the model variables
	in_file = open(modelFileName)
	A = Float32[]
	B = Float32[]
	pi = Float32[]
	
	# read the contents of the file item by item
	arrToPut = ""
	for ln in eachline(in_file)
		items = split(ln," ")
		
		for item in items
			item = strip(item)
			if length(item) > 0
				# if the item being input is A,B or Pi
				if item == "A" || item == "B" || item == "Pi"
					# change the name of the array where the next numeric items will be 
					arrToPut = item
				else
					# put the numeric items according to the name of the array
					if arrToPut == "A"
						push!(A,parse(Float64,item))
					elseif arrToPut == "B"
						push!(B,parse(Float64,item))
					elseif arrToPut == "Pi"
						push!(pi,parse(Float64,item))
					end
				end
			end
		end
	end
	
	# convert A and B into matrices
	pi = pi'
	numOfStates = size(pi,2)
	A = reshape(A,(numOfStates,numOfStates))'
	numOfObservations = Int(size(B,1) / numOfStates)
	B = reshape(B,(numOfObservations,numOfStates))'
	
	close(in_file)
	
	return A,B,pi
end
