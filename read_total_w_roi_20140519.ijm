

path=newArray("W:\\photoncerber\\2017\\August\\20170805_tbetxai95_aon_black_w20170611_R\\t3\\reg");


roi=newArray("RoiSet_20170806.zip");



for (kk=0; kk <path.length ;kk++){
	wait(300);

run("Input/Output...", "jpeg=85 gif=-1 file=.txt use_file");

if (isOpen("ROI Manager")) {
     selectWindow("ROI Manager");
     wait(100);

     run("Close");
     wait(100);

  }
wait(500);

filename= getFileList(path[kk]);

TargetRoi=path[kk]+"\\"+roi[kk];

File.makeDirectory(path[kk]+"\\ROI_Results");
File.makeDirectory(path[kk]+"\\ROI_Results\\Roi_coordinate1");

imagenum=0;
setBatchMode(true); 
for (j=0 ; j < filename.length; j++){
	if(endsWith(filename[j],".tif")){
	open(path[kk]+"//"+filename[j]);
	wait(2000);
	imagenum++;
	//run("16-bit");
	rename(filename[j]);

	selectWindow(filename[j]);
	if(imagenum == 1){
		run("ROI Manager...");
		roiManager("Open", TargetRoi);
		num_roi=roiManager("count");
		for (nn=0; nn<num_roi;nn++){
			roi_index=toString(nn+1);
			selectWindow(filename[j]);	
			roiManager("Select", nn);
			run("Clear Results"); 
			Roi.getCoordinates(x, y);
			for (cd=0; cd<x.length; cd++){
				setResult("X",cd,x[cd]);
				setResult("Y",cd,y[cd]);
			}
			roi_name= path[kk]+"\\ROI_Results\\Roi_coordinate1\\Roi_"+roi_index+"coordinate.txt";			
			updateResults; 
			saveAs("Results", roi_name);
			//selectWindow("Log");
			//close();
			wait(100);
		}
			
		selectWindow(filename[j]);	
		run("Set Measurements...", "  area centroid redirect=None decimal=3");
		roiManager("Select all");
		roiManager("Measure");
		saveAs("Results",path[kk]+"//ROI_Results//Roi_areaNcentroid.txt" );
		run("Set Measurements...", "  mean redirect=None decimal=3");
		
	}

		roiManager("Multi Measure");
		saveAs("Results",path[kk]+"//ROI_Results//"+filename[j]+".txt" );
		wait(1000);
	
	selectWindow(filename[j]);
	close();
	wait(500);	
	beep();
	}
	
}

}
setBatchMode(false);
updateDisplay(); 


if (isOpen("ROI Manager")) {
wait(300);

     selectWindow("ROI Manager");
     wait(300);

     run("Close");
     wait(300);

  }



beep();
wait(200);

beep();
wait(200);
beep();
wait(200);
beep()