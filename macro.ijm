//Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
//Inspired by Will Armour, 2018 (https://willarmour.science/how-to-automate-image-particle-analysis-by-creating-a-macro-in-imagej/)

//Allows the user to choose the folder containing the images and the folder for the results 
inputFolder=getDirectory("Choose input folder");
outputFolder=getDirectory("Choose output folder for the results");

Dialog.create("Options");
Dialog.addNumber("Distance in pixels", 1);
Dialog.addNumber("Known distance", 1);
Dialog.addCheckbox("Activate Watershed", true);
Dialog.show();
disPix = Dialog.getNumber();
disKnown = Dialog.getNumber();  
watershed = Dialog.getCheckbox();

watershedLabel = ""; 
if(watershed!=false) watershedLabel="_ws";
//Puts the name of the files in a list
list=getFileList(inputFolder);

//In batch mode the windows are not shown so it is faster.
setBatchMode(true);

run("Clear Results");
run("Set Measurements...", "area mean perimeter shape limit redirect=None decimal=4");

for(i=0; i<list.length; i++) {
	//Open the images
	loc=inputFolder+list[i];
	if(endsWith(loc, ".jpg")) open(loc);
	print(loc); //I don't know why but it doesn't work without printing the value of loc

	run("Set Scale...", "distance="+ disPix+ " known="+ disKnown);

	//Processes of the image to measure the area of each particle and add an overlay
	if(nImages>=1) {
		outputPath=outputFolder+list[i];
		//The following two lines removes the file extension
		fileExtension=lastIndexOf(outputPath,"."); 
		if(fileExtension!=-1) outputPath=substring(outputPath,0,fileExtension);
		currentNResults = nResults;
		run("Duplicate...", " ");
		//run("8-bit"); //Convert to black and white
		run("RGB Stack"); //
		run("Slice Remover", "first=1 last=2 increment=1"); //Select de desired channel, for R: 2;3;1 / G: 1;3;2 /B: 1;2;1
		run("Gaussian Blur...", "sigma=1"); //Blur the particles to be sure to select the objects and not the sub-objects
		setAutoThreshold("Default");
		run("Convert to Mask");
		run("Close");
		if(watershed!=false) run("Watershed");  
		run("Fill Holes"); 
		run("Analyze Particles...","size=0-Infinity add display");
		for (row = currentNResults; row < nResults; row++) //This add the file name in a row 
		{
			setResult("Label", row, list[i]);
		}
		selectWindow(list[i]);
		roiManager("Show All without labels"); //transfer the label from the bw image to color image
		roiManager("Set Color", "red"); 
		roiManager("Set Line Width", 2);
		run("Flatten");
		roiManager("Delete");
		saveAs("Jpeg", outputPath+ watershedLabel+ ".jpg");
		close("*");
	}
	showProgress(i, list.length);  //Shows a progress bar  
}
setOption("ShowRowNumbers", false); 
saveAs("results", outputFolder+ "results"+ watershedLabel+ ".csv"); 
selectWindow("Results");
run("Close"); 
setBatchMode(false);