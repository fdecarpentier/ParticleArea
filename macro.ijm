//Adapted from Will Armour https://willarmour.science/how-to-automate-image-particle-analysis-by-creating-a-macro-in-imagej/

macro "ParticleArea" {
//Allows the user to choose the folder containing the images and the folder for the results 
inputFolder=getDirectory("Choose input folder");
outputFolder=getDirectory("Choose output folder for the results");

Dialog.create("Watershed");
Dialog.addCheckbox("Activate Watershed", true);
Dialog.show();
watershed = Dialog.getCheckbox();

//Puts the name of the files in a list
list=getFileList(inputFolder);

//In batch mode the windows are not shown so it is faster.
setBatchMode(true);

run("Set Measurements...", "area redirect=None decimal=3");

for(i=0; i<list.length; i++) {
 //Open the images
 loc=inputFolder+list[i];
 if(endsWith(loc, ".jpg")) open(loc);
  print(loc); //I don't know why but it doesn't work without printing the value of loc
 
 run("Set Scale...", "distance=2.85 known=1 unit=µm");
 
 //Processes of the image to measure the area of each particle and add an overlay
 if(nImages>=1) {
  outputPath=outputFolder+list[i];
  //The following two lines removes the file extension
  fileExtension=lastIndexOf(outputPath,"."); 
  if(fileExtension!=-1) outputPath=substring(outputPath,0,fileExtension);
  if(watershed!=false) outputPath=outputPath+"_ws";
  run("Duplicate...", " ");
  //run("8-bit"); //Convert to black and white
  run("RGB Stack"); //
  run("Slice Remover", "first=1 last=2 increment=1"); //Select de desired channel, for R: 2;3;1 / G: 1;3;2 /B: 1;2;1
  run("Gaussian Blur...", "sigma=1"); //Blur the cells to be sure to select the objects and not the sub-objects
  setAutoThreshold("Default");
  setOption("BlackBackground", false);
  run("Convert to Mask");
  run("Close");
  if(watershed!=false) run("Watershed");  
  run("Fill Holes"); 
  run("Analyze Particles...","size=0-Infinity display clear add");
  close();
  selectWindow(list[i]);
  roiManager("Show All without labels"); //transfer the label from the bw image to color image
  roiManager("Set Color", "ff5def"); 
  roiManager("Set Line Width", 3);
  run("Flatten");
  saveAs("Jpeg", outputPath+ "_overlay.jpg"); 
  close(); 
  selectWindow("Results");
  saveAs("Measurements", outputPath+"_results.csv");
  run("Close"); //closes Results window
  close(); //closes the current image
  }
 showProgress(i, list.length);  //Shows a progress bar  
}
setBatchMode(false);
}