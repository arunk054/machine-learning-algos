package MLProject;
import java.util.Random;

import weka.classifiers.Classifier;
import weka.classifiers.Evaluation;
import weka.classifiers.meta.Stacking;
import weka.core.Instance;
import weka.core.Instances;
import weka.core.Range;


public class MyStacking extends Stacking{

	protected Instances m_MetaData;
	
	public MyStacking() {
		super();
	}
	
	
	public void buildClassifier(Instances[] data)throws Exception{
		
	    if (m_MetaClassifier == null) {
		      throw new IllegalArgumentException("No meta classifier has been set");
		    }
	    
	    
	    m_BaseFormat = new Instances(data[0], 0);
	    Random random = new Random(m_Seed);
	    Instances[] newData = new Instances[data.length];
	    for (int i = 0; i < data.length; i++) {
		    newData[i] = new Instances(data[i]);
		    newData[i].deleteWithMissingClass();
		    newData[i].randomize(random);
		    if (newData[i].classAttribute().isNominal()) {
			      newData[i].stratify(m_NumFolds);
		    }
		}

	    // Create meta level
	    generateMetaLevel(newData, random);
	    m_MetaClassifier.buildClassifier(m_MetaData);

	}
	
	protected void generateMetaLevel(Instances[] newData, Random random)
	    throws Exception {

	    Instances metaData = metaFormat(newData[0]);
	    m_MetaFormat = new Instances(metaData, 0);
	    for (int j = 0; j < m_NumFolds; j++) {
	      

	      // Build base classifiers
	      for (int i = 0; i < m_Classifiers.length; i++) {
	    	  	Instances train = newData[i].trainCV(m_NumFolds, j, random);
	    	  	getClassifier(i).buildClassifier(train);
	      }

	      // Classify test instances and add to meta data
	      Instances[] test = new Instances[newData.length];
	      for (int i = 0; i < newData.length; i++) {
	    	  	test[i] = newData[i].testCV(m_NumFolds, j);
		}
	    	  //The number of instances in each array element of test is same
	      //e.g. test[i].numInstances() = test[j].numInstances();
	      for (int i = 0; i < test[0].numInstances(); i++) {
	    	  	Instance[] newTestArray = new Instance[test.length];
	    	  	for (int k = 0; k < newTestArray.length; k++) {
					newTestArray[k] = test[k].instance(i);
				}
	    	  	metaData.add(metaInstance(newTestArray));
	      }
	    }

	    m_MetaData = metaData;
	    
	  }
		
		public Evaluation testInstances(Instances[] test) throws Exception{
			Instances metaData = metaFormat(test[0]);
			for (int i = 0; i < test[0].numInstances(); i++) {
				Instance[] newTestArray = new Instance[test.length];
				for (int k = 0; k < newTestArray.length; k++) {
					newTestArray[k] = test[k].instance(i);
				}
				Instance newMetaInstance = metaInstance(newTestArray);
				metaData.add(newMetaInstance);
			}
			
			//m_MetaClassifier.buildClassifier(m_MetaData);
			Evaluation eval = new Evaluation(m_MetaData);
			eval.evaluateModel(m_MetaClassifier, metaData);
			return eval;
		}
	
	  public Evaluation[] crossValidateMetaClassifier(int numFolds, Random random) throws Exception{
		    
		  return crossValidateModel(m_MetaClassifier, m_MetaData, numFolds, random);
	  }
	  
	  //The following code is taken from the Evaluation class in Weka
	  public Evaluation[] crossValidateModel(Classifier classifier, Instances data, int numFolds, Random random)
			    throws Exception {

			    // Make a copy of the data we can reorder
			    data = new Instances(data);
			    data.randomize(random);
			    if (data.classAttribute().isNominal()) {
			      data.stratify(numFolds);
			    }
			    Evaluation[] returnEvals = new Evaluation [numFolds];

			    for (int i = 0; i < numFolds; i++) {
			      Instances train = data.trainCV(numFolds, i, random);
			      Evaluation eval = new Evaluation(train);
			      Classifier copiedClassifier = Classifier.makeCopy(classifier);
			      copiedClassifier.buildClassifier(train);
			      Instances test = data.testCV(numFolds, i);
			      double[] predictions = eval.evaluateModel(copiedClassifier, test);
			      returnEvals[i] = eval;
			    }
			    return returnEvals;
	  }
	  
	  protected Instance metaInstance(Instance[] instance) throws Exception {

		    double[] values = new double[m_MetaFormat.numAttributes()];
		    Instance metaInstance;
		    int i = 0;
		    for (int k = 0; k < m_Classifiers.length; k++) {
		      Classifier classifier = getClassifier(k);
		      if (m_BaseFormat.classAttribute().isNumeric()) {
		    	  values[i++] = classifier.classifyInstance(instance[k]);
		      } else {
		    	  double[] dist = classifier.distributionForInstance(instance[k]);
		    	  for (int j = 0; j < dist.length; j++) {
		    		  values[i++] = dist[j];
		    	  }
		      }
		    }
		    values[i] = instance[0].classValue();
		    metaInstance = new Instance(1, values);
		    metaInstance.setDataset(m_MetaFormat);
		    return metaInstance;
	  }

	
}
