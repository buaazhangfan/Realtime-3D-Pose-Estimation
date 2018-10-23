#include<iostream>
using namespace std;
#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
using namespace cv;

const int row = 16;
const int col = 16;
const int side = 25;//mm
const int startPoint = 25;//mm
const int width = (col+2)*side;//450mm
const int height = (row+2)*side;//450mm

const int side_pixel = 100;
const int width_pixel = side_pixel / side * width;//1800
const int height_pixel = side_pixel / side * height;//1800
const int startPoint_pixel = side_pixel / side * startPoint;//100


int main()
{
	Mat ChessBoard(width_pixel,height_pixel,CV_8U,255);
	
	for(int i=startPoint_pixel; i<height_pixel-startPoint_pixel; i+=2*side_pixel)
	{
		for(int ii = i;ii<i+2*side_pixel;ii++)
		//for(int ii = i;ii<209;ii++)
		{
			for(int j=startPoint_pixel; j<width_pixel-startPoint_pixel; j+=2*side_pixel)
			{
				int jj;
				for(jj = j;jj<j+2*side_pixel;jj++)
				{
					
					if((ii<i+side_pixel && jj<j+side_pixel)||(ii>i+side_pixel && jj>j+side_pixel))
					{
						ChessBoard.at<uchar>(jj,ii) = 0;
					}
				}
				//cout<<"i"<<i<<" "<<"jj"<<jj<<endl;
				//cout<<height_pixel<<endl;
			}
		}	
	}
	imshow("ChessBoard",ChessBoard);
	imwrite("ChessBoard.jpg",ChessBoard);
	waitKey(0);

	return 0;
}