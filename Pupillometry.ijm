macro "Pupillometry"{
run("Close All");
roiManager("reset");
run("Clear Results");
// Folder manager
Extension=".avi";
DIR=getDirectory("Select a directory ");
DIR_ANA=DIR+"\\Pupil_Analysis\\";
File.makeDirectory(DIR_ANA);
DIR_OVE=DIR+"\\Pupil_Overlay\\";
File.makeDirectory(DIR_OVE);
DIR_INT=DIR+"\\Pupil_Intensity\\";
File.makeDirectory(DIR_INT);
LIST_ALL=getFileList(DIR);
LIST=ExtList(LIST_ALL,Extension);
LengthOfList=lengthOf(LIST);
// Parameters
LengthForRandom=LengthOfList-2;
testbatch=false;
testcrop=true;
testthreshold=true;
testBinOp=true;
testOverlay=false;
testpad=true;
mincirc=0.8;
minsize=400;
EyeCoordinates=newArray(0,0,0,0);
EyeThreshold=newArray(0,30);
// Adjust Parameters \\
while (testbatch==false) {
    thisTrial=floor(random()*LengthForRandom);
    run("Movie (FFMPEG)...", "choose="+DIR+LIST[thisTrial]+" first_frame=0 last_frame=-1");
	setTool("rectangle");
	if (testcrop==true){
		waitForUser("draw a square around the eye and add to roiManager");
		while (roiManager("count")<=0){
			waitForUser("draw a square around the eye AND add to roiManager");
		}
	}
	if(EyeCoordinates[1]>0 && roiManager("count")==0){
		makeRectangle(EyeCoordinates[0],EyeCoordinates[1],EyeCoordinates[2],EyeCoordinates[3]);
		roiManager("Add");
	}
	roiManager("select", 0);
	Roi.getBounds(EyeCoordinates[0],EyeCoordinates[1],EyeCoordinates[2],EyeCoordinates[3]);
	run("Crop");
	run("Set... ", "zoom=400");
    run("8-bit");
    rename("Eye");
    run("Duplicate...","title=EyeBin duplicate");
    run("Set... ", "zoom=400");
	if (testthreshold==true) {
	    selectWindow("EyeBin");
	    run("Threshold...");
	    setThreshold(EyeThreshold[0],EyeThreshold[1]);
	    waitForUser("adjust threshold");
	    getThreshold(EyeThreshold[0],EyeThreshold[1]);
	    run("Smooth", "stack");
		run("Convert to Mask", "method=Default background=Default");
		if (testBinOp==true){
		run("Options...", "iterations=2 count=1 do=Nothing");
		run("Open", "stack");
		run("Close-", "stack");
		run("Erode", "stack");
		run("Dilate", "stack");
		}
		run("Analyze Particles...", "size="+minsize+"-Infinity circularity="+mincirc+"-1.00 show=Ellipses display exclude clear include stack");
		selectWindow("Drawing of EyeBin");
		run("Analyze Particles...", "  show=Nothing exclude include add stack");
		selectWindow("Eye");
		run("From ROI Manager");
		close("Drawing of EyeBin");
		waitForUser("Preview of elipse fitting");
	}  
    Dialog.create("Happy?");
    Dialog.addCheckbox("Adjust Eye croping",false);
    Dialog.addCheckbox("Adjust Threshold",testthreshold);
    Dialog.addNumber("Minimal circularity",mincirc);
    Dialog.addNumber("Minimal Size",minsize);
	Dialog.addCheckbox("Perform erosion/dilatation",testBinOp);
    Dialog.addCheckbox("Proceed to batch analysis",testbatch);
    Dialog.addCheckbox("Pad file number",testpad);
    Dialog.addCheckbox("Save Elipse overlay",testOverlay);
    Dialog.show;  
    testcrop=Dialog.getCheckbox();
    testthreshold=Dialog.getCheckbox();
    mincirc=Dialog.getNumber();
    minsize=Dialog.getNumber();
	testBinOp=Dialog.getCheckbox();
    testbatch=Dialog.getCheckbox();
    testpad=Dialog.getCheckbox();
    testOverlay=Dialog.getCheckbox();
	counter=counter+1;
	run("Close All");
	roiManager("reset");
}
// Batch Processing \\
setBatchMode(true);
run("Options...", "iterations=2 count=1 do=Nothing");
for (thisTrial=0; thisTrial<LengthOfList;thisTrial++){
	showProgress(thisTrial/LengthOfList);
	run("Close All");
	roiManager("reset");	
	run("Movie (FFMPEG)...", "choose="+DIR+LIST[thisTrial]+" first_frame=0 last_frame=-1");
	NAMEwo=File.nameWithoutExtension;
	if (testpad==1){
		NAMEwo=substring(NAMEwo,0,lastIndexOf(NAMEwo,'_'))+'_'+IJ.pad(substring(NAMEwo,lastIndexOf(NAMEwo,'_')+1),3);
	}
	makeRectangle(EyeCoordinates[0],EyeCoordinates[1],EyeCoordinates[2],EyeCoordinates[3]);
	run("Crop");
    run("8-bit");
    rename("Eye");
// mean and std of the eye image 
	run("Set Measurements...", "mean standard min redirect=None decimal=3");
	makeRectangle(0,0,EyeCoordinates[2],EyeCoordinates[3]);
	roiManager("add")
	roiManager("multi measure one");
	saveAs("Results", DIR_INT+NAMEwo+"_intensity.txt");
    roiManager("reset");
// Pupil    
    run("Duplicate...","title=EyeBin duplicate");
    selectWindow("EyeBin");
	run("Smooth", "stack");
	setThreshold(EyeThreshold[0],EyeThreshold[1]);
	run("Convert to Mask", "method=Default background=Default");
	if (testBinOp==true){
		run("Open", "stack");
		run("Close-", "stack");
		run("Erode", "stack");
		run("Dilate", "stack");
	}
	run("Set Measurements...", "area centroid fit shape stack redirect=None decimal=3");
	run("Analyze Particles...", "size="+minsize+"-Infinity circularity="+mincirc+"-1.00 show=Ellipses display exclude clear include stack");
	saveAs("Results", DIR_ANA+NAMEwo+"_particles.txt");
	run("Clear Results");  
// Overlay	
	if (testOverlay==true){
		selectWindow("Drawing of EyeBin");
		run("Analyze Particles...", "  show=Nothing exclude include add stack");
		selectWindow("Eye");
		run("From ROI Manager");
		saveAs("tiff",DIR_OVE+NAMEwo+".tif");
	}
}
} // End Macro
// Functions
function ExtList (LIST_ALL,ext){
	NB_EXT=0;
	for(i=0; i<LIST_ALL.length; i++){
		if(endsWith(LIST_ALL[i], ext)){
			NB_EXT=NB_EXT+1;
		}
	}
	LIST_EXT=newArray(NB_EXT);
	j=0;
	for(i=0; i<LIST_ALL.length; i++){
		if(endsWith(LIST_ALL[i], ext)){
			LIST_EXT[j]=LIST_ALL[i];
			j=j+1;
		}
	}
	return LIST_EXT;
}