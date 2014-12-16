package MLProject;

import java.io.File;
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

public class BaselinePerformance {

	
	public static void main(String[] args) throws Exception {
		
		//Load the column features data
		DataSource source1 = new DataSource("CV_Not_Boolean.arff");
		Instances columnFeatureInstances1 = source1.getDataSet();
		
		columnFeatureInstances1.setClassIndex(columnFeatureInstances1.numAttributes()-1);
		System.out.println("Column features: "+columnFeatureInstances1.numAttributes());
		System.out.println("Column features - Instances: "+columnFeatureInstances1.numInstances());

		SMO baseClassifier = new SMO();
//		Evaluation eval = new Evaluation (columnFeatureInstances1);
//		eval.crossValidateModel(baseClassifier, columnFeatureInstances1, 10, new Random(2));
//		
//		System.out.println(eval.toSummaryString());
				
		Random rand = new Random(2);   // create seeded number generator
		columnFeatureInstances1.randomize(rand);
		int NUM_FOLDS=10;
		columnFeatureInstances1.stratify(NUM_FOLDS);
		double[] successRate = new double[NUM_FOLDS];
		double[] kappa = new double[NUM_FOLDS];
		
		for (int i = 0; i < NUM_FOLDS; i++) {

			Instances train = columnFeatureInstances1.trainCV(NUM_FOLDS, i);
			Instances test = columnFeatureInstances1.testCV(NUM_FOLDS, i);

			Classifier copiedClassifier = Classifier.makeCopy(baseClassifier);
		      copiedClassifier.buildClassifier(train);

			Evaluation eval = new Evaluation(train);

			double[] predictions = eval.evaluateModel(copiedClassifier,test);

			successRate[i]=eval.pctCorrect()/100;//(eval.correct()/predictions.length);
			kappa[i] = eval.kappa();
			
		}
		System.out.println();
		for (int i = 0; i < NUM_FOLDS; i++) {
			System.out.println(round(successRate[i], 2));
		}
		System.out.println();
		for (int i = 0; i < NUM_FOLDS; i++) {
			System.out.println(round(kappa[i],2));
		}
	}

	private static double round(double d, int i) {
		double val = (d * Math.pow(10, i));
		val = Math.floor(val);
		
		return val/100;
	}
}
