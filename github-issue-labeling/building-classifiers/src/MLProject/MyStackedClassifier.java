package MLProject;

import java.util.Random;

import weka.classifiers.Classifier;
import weka.classifiers.Evaluation;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.functions.Logistic;
import weka.classifiers.functions.SMO;
import weka.classifiers.meta.Stacking;
import weka.classifiers.rules.JRip;
import weka.classifiers.trees.J48;
import weka.core.Instances;
import weka.core.converters.ConverterUtils.DataSource;

public class MyStackedClassifier {

	
	private static final int NUM_FOLDS = 10;
	public static void main(String[] args) throws Exception {
		
		//Load the column features data
		DataSource source1 = new DataSource("CV_Boolean.arff");
		Instances columnFeatureInstances1 = source1.getDataSet();
		
		columnFeatureInstances1.setClassIndex(columnFeatureInstances1.numAttributes()-1);
		System.out.println("Column features: "+columnFeatureInstances1.numAttributes());
		System.out.println("Column features - Instances: "+columnFeatureInstances1.numInstances());

		DataSource source2 = new DataSource("CV_Not_Boolean.arff");
		Instances columnFeatureInstances2 = source2.getDataSet();
		System.out.println("Column features: "+columnFeatureInstances2.numAttributes());
		System.out.println("Column features - Instances: "+columnFeatureInstances2.numInstances());
		
		columnFeatureInstances2.setClassIndex(columnFeatureInstances2.numAttributes()-1);

		
		NaiveBayes stack1Classifier = new NaiveBayes();
		SMO stack2Classifier = new SMO();
		
		
		
		//Load the text features data
		
		source1 = new DataSource("CV_Text.arff");
		Instances textFeatureInstances = source1.getDataSet();
		
		textFeatureInstances.setClassIndex(textFeatureInstances.numAttributes()-1);
		System.out.println("Text features: "+textFeatureInstances.numAttributes());
		System.out.println("Text features - Instances: "+textFeatureInstances.numInstances());
		
		NaiveBayes nbClassifier = new NaiveBayes();
		
		//Meta data classifier try J48 or JRip
		
		JRip metaClassifier = new JRip();
		
		//Create a stacking instance
		
		MyStacking stackingClassifier = new MyStacking();
		Classifier[] classifiersForStacking = {stack1Classifier,stack2Classifier, nbClassifier};
		stackingClassifier.setClassifiers(classifiersForStacking);
		stackingClassifier.setMetaClassifier(metaClassifier);
		Instances[] data = new Instances[3];
		data[0]=columnFeatureInstances1;
		data[1]=columnFeatureInstances2;
		data[2] =textFeatureInstances ;
		stackingClassifier.buildClassifier(data);
		Evaluation[] eval = stackingClassifier.crossValidateMetaClassifier(NUM_FOLDS,new Random(2));
		double[] successRate = new double[NUM_FOLDS];
		double[] kappa = new double[NUM_FOLDS];
		for (int i = 0; i < eval.length; i++) {
			successRate[i] = eval[i].pctCorrect()/100;
			kappa[i] = eval[i].kappa();
		}
		System.out.println();
		for (int i = 0; i < NUM_FOLDS; i++) {
			System.out.println(round(successRate[i], 2));
		}
		System.out.println();
		for (int i = 0; i < NUM_FOLDS; i++) {
			System.out.println(round(kappa[i],2));
		}
		
		//Evaluation.evaluateModel(stackingClassifier, new String[0]);
		//build the classifier
		//Evaluation eval = new Evaluation(columnFeatureInstances);
		
	}
	private static double round(double d, int i) {
		double val = (d * Math.pow(10, i));
		val = Math.floor(val);
		
		return val/100;
	}
}
