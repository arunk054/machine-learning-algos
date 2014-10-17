import sys
import math





#Implementation of naive bayes with laplace smoothing
class NaiveBayes:


	def __init__(self,trainingData,trainingLabel,testData,testLabel):
		#Constants
		self.NO_OF_LABELS=20;
		self.SIZE_OF_VOCAB=61188;
	
		self.trainingData=trainingData
		self.trainingLabel=trainingLabel
		self.testData=testData
		self.testLabel=testLabel

		self.count = 0
		self.totalNumberOfDocs=0
		#This array holds the number of docs containing each term
		#Hence this has a size of |Vocabulary| 
		#This array also serves as IDF
		self.termsInAllDocs=[]
		#Again size of |Vocab|, each elem contains the sum of term frequencies across all docs
		#This will also be overwritten with prod of Tf, IDF
		self.frequencyArr = []
		for i in range(self.SIZE_OF_VOCAB):
			self.termsInAllDocs.append(0)
			self.frequencyArr.append(0.0)					
			
		#prior is an int array of 20 elements.
		#Each element is the number of occurrences of a class
		self.priorArr=[]
		#Initialize priorArr 
		for i in range(self.NO_OF_LABELS):
			self.priorArr.append(0)
		
		#likelihood is a 2D array of size 20 X |vocabulary|
		self.likelihood=[]
		for i in range(self.NO_OF_LABELS):
			self.likelihood.append([]);
			for j in range(self.SIZE_OF_VOCAB):
				self.likelihood[i].append(0)
		


	def logLikelihood(self):
		print "Computing log likelihood..."
		fLogLL = open("logLikelihood.csv",'w')
		#Iterate for each class label find the log likelihood of each word
		#Reuse the same array to store log likelihood
		for i in range(len(self.likelihood)):
			#denominator = math.log(sum(self.likelihood[i]))
			denominator=0
			for j in range(len(self.likelihood[i])):
				if (self.likelihood[i][j] != -1):
					denominator += self.likelihood[i][j]
			denominator = math.log(denominator)
			for j in range(len(self.likelihood[i])):
				if (self.likelihood[i][j] == -1):
					self.likelihood[i][j]=1
				elif (self.likelihood[i][j]!=0):
					self.likelihood[i][j] = math.log(self.likelihood[i][j]) - denominator
					fLogLL.write(str(i+1)+","+str(j+1)+","+str(self.likelihood[i][j])+'\n');
				#Output to csv file: Format - classLabel, term, logLikelihood

		fLogLL.close();
	
		
	def logPrior(self):
		print "Computing log prior..."

		#sum is actually the number of documents which is the denominator
		denominator = math.log(sum(self.priorArr))
		fLogPrior = open("logPrior.csv",'w')
		#reuse the same array to store the log likelihood		
		for i in range(len(self.priorArr)):
			self.priorArr[i] = math.log(self.priorArr[i]) - denominator
			#Output to csv file: Format - classLabel, logPrior
			fLogPrior.write(str(i+1)+","+str(self.priorArr[i])+'\n')		
		fLogPrior.close()
	
	def isPredictedCorrect(self,estimateP,actualClassLabel, fileNBC, docID):
		##Add prior, it was not added because the end of test data for this docID was unknown
		for i in range(len(self.priorArr)):
			estimateP[i]+=self.priorArr[i]
		maxP=0
		predictedClassLabel=1
		#Find the predicted class with highest estimated probability
		for i in range(len(estimateP)):
			if (estimateP[i] > maxP and maxP != 0):
				maxP=estimateP[i]
				predictedClassLabel=i+1
				
		#Output NBresults.csv :Format: DocID, ClassLabel
		fileNBC.write(str(docID)+","+str(predictedClassLabel)+'\n')		
		if (predictedClassLabel == actualClassLabel):
			return 1
		return 0
	
	
	
	def naiveBayesClassifier(self):
		print "Loading testing data..."
		print "Classifying using Naive Bayes..."
		fNBC = open("nbResults.csv",'w')

		#load test data
		fData = open(self.testData,'r')
		fLabel = open(self.testLabel,'r')
		
		predictedClassLabel=0
		#Array of size = #class labels. each element gives the log of estimated probabilities
		estimateP = []

		#This technique is the same used for reading training data, we could modularizie
		prevDocId=-1
		actualClassLabel=0
		totalNumber=0
		numberCorrect=0
		for line in fData:
			#extract tokens from each line
			vals=line.split(' ')
			curDocId=int(vals[0])
			curTermId=int(vals[1])-1
			curCount=int(vals[2])
			if (curDocId != prevDocId):
					#This check is just to make sure we are not here the first time
					if (prevDocId!=-1):
						numberCorrect+=self.isPredictedCorrect(estimateP,actualClassLabel,fNBC,curDocId)
						totalNumber+=1
		
					prevDocId=curDocId
					estimateP=[]
					#initialize estimated probabilities
					for i in range(len(self.priorArr)):
						estimateP.append(0)
					#Using this to read single line since readline() does not work
					for curClassStr in fLabel:
						actualClassLabel=int(curClassStr)
						break
			#compute the log likelihood of this term given a class, repeat for all class
			for i in range(len(self.priorArr)):
				if (self.likelihood[i][curTermId] < 0):
					estimateP[i]+=float(self.likelihood[i][curTermId]*curCount)
				
		
		numberCorrect+=self.isPredictedCorrect(estimateP,actualClassLabel,fNBC,curDocId)
		totalNumber+=1
		accuracy = float(float(numberCorrect)/float(totalNumber)*100)
		print "Accuracy is %0.2f"%(accuracy)
		fData.close()
		fLabel.close()
		fNBC.close()


	
	def performLaplaceSmoothing(self,k):
		print "Performing Laplace Smoothing with k=%d..."%(k)
		#We just increment count of a term for each classLabel by k
		#So those terms with 0 occurrences in a document will have k occurrences
		#The probablity gets adjusted because the denominator also increases by #terms*k times
		for i in range(len(self.likelihood)):
			for j in range(len(self.likelihood[i])):
				if(self.likelihood[i][j] != -1):
					if (self.likelihood[i][j]!=0):
						self.likelihood[i][j]+=(k*self.likelihood[i][j])
					else:
						self.likelihood[i][j]+=k


	def computeIDF(self):
		print "Computing IDF: Inverse Document Frequency..."	
		for i in range(len(self.termsInAllDocs)):
			#store the IDF back in the termsInAllDocs Array
			#Hence termsInAllDocs array ==> IDF
			#Using this increment in denominator to prevent divide by 0
			increment = 0
			
			if (self.termsInAllDocs[i]==0):
				increment=1
			self.termsInAllDocs[i]=float(math.log(float(self.totalNumberOfDocs)/(self.termsInAllDocs[i]+increment)))
			if (self.termsInAllDocs[i]<1):
				self.count+=1

			print "IDF"
			print self.count
		
	def computeTF_IDF(self):
		#We have to read the training data again since storing the tf will be memory intensive
		print "Computing TF: Term Frequency..."
		#Temporary array to store the current doc id's term frequency
		#The second array is to make use of sparsity, instead of storing for all terms, almost a simple hashtable
		curFrequencyArr=[]
		curFreqIndex=[]
				
		#read the training file
		fData = open(self.trainingData,'r')
		prevDocId=-1
		maxFreq=0

		for line in fData:
			vals=line.split(' ')
			curDocId=int(vals[0])
			curTermId=int(vals[1])-1
			curCount=int(vals[2])

			if (curDocId != prevDocId):

				#compute tf for this document, except when we are starting
				if (prevDocId != -1):
					#pick the top 5 terms from each document using tfIdf
					select=5
					j=0
					while (j<select):
						j+=1
						maxV=0
						maxI=-1
						for i in range(len(curFrequencyArr)):
							if (maxV<curFrequencyArr[i]):
								maxV = curFrequencyArr[i]
								maxI=i
						if (maxI!=-1):
							self.frequencyArr[curFreqIndex[maxI]]+=1
							curFrequencyArr[maxI]=0
					
					#for i in range(len(curFrequencyArr)):
						#using augmented frequency
						#tf = 0.5+(0.5*float(curFrequencyArr[i]) / float(maxFreq))
						#tf = float(curFrequencyArr[i])
						#self.frequencyArr[curFreqIndex[i]]+=float(tf)
						#tfIdf = float(tf)*self.termsInAllDocs[curFreqIndex[i]]
						#print "%0.2f,%d,%0.2f"%(tfIdf,tf,self.termsInAllDocs[curFreqIndex[i]])
						#if (tfIdf > 20):
							#self.frequencyArr[curFreqIndex[i]]+=1
					#print "====================================="

					#Reset all variables
					maxFreq=0
					curFrequencyArr=[]
					curFreqIndex=[]

				prevDocId=curDocId
				
			curFrequencyArr.append(self.termsInAllDocs[curTermId]*float(curCount))
			curFreqIndex.append(curTermId)
			if (maxFreq < curCount):
				maxFreq = curCount
		fData.close()		

		#pick the top 5 terms from each document using tfIdf
		select=5
		j=0
		while (j<select):
			j+=1
			maxV=0
			maxI=-1
			for i in range(len(curFrequencyArr)):
				if (maxV<curFrequencyArr[i]):
					maxV = curFrequencyArr[i]
					maxI=i
			if (maxI!=-1):
				self.frequencyArr[curFreqIndex[maxI]]+=1
				curFrequencyArr[maxI]=0
		#Compute TF for last doc Id in train data
		#for i in range(len(curFrequencyArr)):
			#using augmented frequency
			#tf = 0.5+(0.5*float(curFrequencyArr[i]) / float(maxFreq))
			#tf = curFrequencyArr[i]			
			#self.frequencyArr[curFreqIndex[i]]+=float(tf)
			#tfIdf = float(tf)*self.termsInAllDocs[curFreqIndex[i]]
			#print "%0.2f,%d,%0.2f"%(tfIdf,tf,self.termsInAllDocs[curFreqIndex[i]])
			#if (tfIdf > 10):
				#self.frequencyArr[curFreqIndex[i]]+=1


		#find TF*IDF 
		print "Computing TF * IDF..."
		#for i in range(len(self.frequencyArr)):
			#This step is computing Sum(TF)*IDF
		#	self.frequencyArr[i]=float(self.frequencyArr[i])*self.termsInAllDocs[i]

			
		#normalize TF-IDF
		maxFreq=max(self.frequencyArr)
		#for i in range(len(self.frequencyArr)):
		#	self.frequencyArr[i]=self.frequencyArr[i]/maxFreq

		cutoff =1
		print "Discarding a stop words from vocab with very low TF-IDF..."
		#Ideally we should select top N% of vocab with highest tf-idf
		discardedWords = 0
		#We basically set likelihood of all unselected terms to be 0
		#Selection criteria is based on if tf-idf is greater than a cutoff
		for i in range(len(self.frequencyArr)):
			if (self.frequencyArr[i]<cutoff):
				discardedWords+=1
				for j in range(len(self.likelihood)):
						if (self.likelihood[j][i] != 0):
							self.likelihood[j][i]=-1

		print "Number of Discarded words = %d"%(discardedWords)
		
		#Sort aray
		#Select top N% of words
		#print "Selecting top "
	
	def loadTrainingDataAndLabel(self):
		print "Loading training data..."
		fData = open(self.trainingData,'r')
		fLabel = open(self.trainingLabel,'r')
		self.totalNumberOfDocs=0

		#iterate through the training data file
		prevDocId=-1
		curClass=0
		for line in fData:
			#extract tokens from each line
			vals=line.split(' ')
			curDocId=int(vals[0])
			curTermId=int(vals[1])-1
			curCount=int(vals[2])
			#Check if the  docId in train.data changes between two lines
			#We can use this trick only when the file is sorted by docId
			if (curDocId != prevDocId):
				prevDocId=curDocId
				self.totalNumberOfDocs+=1
				#Using this to read single line since readline() does not work
				for curClassStr in fLabel:
					curClass=int(curClassStr)-1
					break
				self.priorArr[curClass]+=1
			#Increment the number of occurrences of the term for this class
			self.likelihood[curClass][curTermId]+=curCount
			self.termsInAllDocs[curTermId]+=1
		
		fLabel.close()
		fData.close()
		
		#Compute tf-IDF, since we cannot store the doc into term matrix, we will have to read the training file again
		self.computeIDF()
		self.computeTF_IDF()
		#Perform Laplace Smoothing, k=1 seems to be optimal
		self.performLaplaceSmoothing(5)
		
		


if __name__ == "__main__":
	myNB = NaiveBayes("data/train.data","data/train.label","data/test.data","data/test.label")
	myNB.loadTrainingDataAndLabel()
	myNB.logPrior()
	myNB.logLikelihood()
	myNB.naiveBayesClassifier()
	
	


