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

public class EvaluateFinalTestSet {

	
	private static final int NUM_FOLDS = 10;
	public static void main(String[] args) throws Exception {
		
		//Load the column features data
		DataSource source1 = new DataSource("CV_Stack_column_features-boolean.arff");
		Instances columnFeatureInstances1 = source1.getDataSet();
		
		columnFeatureInstances1.setClassIndex(columnFeatureInstances1.numAttributes()-1);
		System.out.println("Column features: "+columnFeatureInstances1.numAttributes());
		System.out.println("Column features - Instances: "+columnFeatureInstances1.numInstances());

		DataSource source2 = new DataSource("CV_stack_column_features-all.arff");
		Instances columnFeatureInstances2 = source2.getDataSet();
		System.out.println("Column features: "+columnFeatureInstances2.numAttributes());
		System.out.println("Column features - Instances: "+columnFeatureInstances2.numInstances());
		
		columnFeatureInstances2.setClassIndex(columnFeatureInstances2.numAttributes()-1);

		
		NaiveBayes stack1Classifier = new NaiveBayes();
		SMO stack2Classifier = new SMO();
		
		
		
		//Load the text features data
		
		source1 = new DataSource("CV_Stack_text_features.arff");
		Instances textFeatureInstances = source1.getDataSet();
		
		textFeatureInstances.setClassIndex(textFeatureInstances.numAttributes()-1);
		System.out.println("Text features: "+textFeatureInstances.numAttributes());
		System.out.println("Text features - Instances: "+textFeatureInstances.numInstances());
		
		NaiveBayes nbClassifier = new NaiveBayes();
		
		DataSource testSource1 = new DataSource("Test_Stack_column_features-boolean.arff");
		Instances testInstances1 = testSource1.getDataSet();
		testInstances1.setClassIndex(testInstances1.numAttributes()-1);
		
		stack1Classifier.buildClassifier(columnFeatureInstances1);
		Evaluation eval = new Evaluation (columnFeatureInstances1);
		eval.evaluateModel(stack1Classifier, testInstances1);
		System.out.println(eval.toSummaryString());
		/*
		//Meta data classifier try J48 or JRip
		
		JRip metaClassifier = new JRip();
		
		//Create a stacking instance
		
		MyStacking stackingClassifier = new MyStacking();
		Classifier[] classifiersForStacking = {stack1Classifier,stack2Classifier, nbClassifier};
		stackingClassifier.setClassifiers(classifiersForStacking);
		stackingClassifier.setMetaClassifier(metaClassifier);
		Instances[] data = {columnFeatureInstances1,columnFeatureInstances2,textFeatureInstances};
		stackingClassifier.buildClassifier(data);
		//Evaluation[] eval = stackingClassifier.crossValidateMetaClassifier(NUM_FOLDS,new Random(2));
		
		System.out.println("Final model built ");
		System.out.println();
		
		//Get the test data

		DataSource testSource1 = new DataSource("Test_Stack_column_features-boolean.arff");
		Instances testInstances1 = testSource1.getDataSet();
		
		testInstances1.setClassIndex(testInstances1.numAttributes()-1);
		System.out.println("Column features: "+testInstances1.numAttributes());
		System.out.println("Column features - Instances: "+testInstances1.numInstances());


		DataSource testSource2 = new DataSource("Test_Stack_column_features-all.arff");
		Instances testInstances2 = testSource2.getDataSet();
		
		testInstances2.setClassIndex(testInstances2.numAttributes()-1);
		System.out.println("Column features: "+testInstances2.numAttributes());
		System.out.println("Column features - Instances: "+testInstances2.numInstances());
		
		DataSource testSource3 = new DataSource("Test_Stack_text_features.arff");
		Instances testInstances3 = testSource3.getDataSet();
		
		testInstances3.setClassIndex(testInstances3.numAttributes()-1);
		System.out.println("Column features: "+testInstances3.numAttributes());
		System.out.println("Column features - Instances: "+testInstances3.numInstances());
		
		Instances[] tData = {testInstances1,testInstances2,testInstances3};

		Evaluation testEval = stackingClassifier.testInstances(tData);
		System.out.println(testEval.toSummaryString());
		*/
	}
	private static double round(double d, int i) {
		double val = (d * Math.pow(10, i));
		val = Math.floor(val);
		
		return val/100;
	}
}
