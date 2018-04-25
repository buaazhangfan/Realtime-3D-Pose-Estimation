%% Video writer
vidObj=VideoWriter('/Users/apple/Desktop/OMCNN_2CLSTM-master/416-240-BasketballPass_out.avi');  
open(vidObj);  
aviobj.Quality = 100;  
aviobj.Fps = 5;  
aviobj.compression='None';  
for i=1:246     
      fname=strcat(strcat(num2str(i),'.jpg'));  
      rootpath = '/Users/apple/Desktop/OMCNN_2CLSTM-master/output/';
      path = [rootpath,fname];
      adata=imread(path);  
      writeVideo(vidObj,adata);  
 end  
close(vidObj); 