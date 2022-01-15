// This is a modified Dark-Channel-Prior dehaze algorithm.
// We modified the algorithm such that the algorithm is hardware friendly.
// It can acheive real-time performance on FPGA.

/*
Our Approach:
Our approach make uses of some techniques in DCP algorithm, but there're some differences. However, our approach is hardware-friendly. It's easy to implement the algorithm in hardware. And it can also dehaze the image or video effectively.

Assumption:
We assume that the airlight for R,G,B are the same, which means that the three channel of the light are uniform. And we can adjust the value of A to get the best dehaze effect. (255 is OK!)

Steps:
1. Dark-channel image computation (without patch)
2. Iterative transmission map calculation
3. Scene recovery

1. Dark-channel image computation (without patch)
Create a grayscale image with the same size as the haze image. The pixel value is equal to the minimum between the R, G, B channel value.


2. Iterative transmission map calculation
First create the transmission map with the dark-channel image in step.1 (They are the same in the beginning).
Go through the transmission map and replace the pixel with the new value T.

3. Scene recovery
*/

// Usage (Make sure that you have installed opencv in your device)
// 1. mkdir build
// 2. cd build
// 3. cmake..
// 4. make
// 5. ./dehaze <path of the image file>

#include <iostream>
#include <opencv2/opencv.hpp>
#include <vector> // vector
#include <fstream>

using namespace cv;
using namespace std;

const int A = 255;

int main(int argc, char *argv[]){
    // ofstream file_dcp("golden_dcp.txt");
    // ofstream file_tmap;
    // file_tmap.open("golden_tmap.txt");
    // ofstream file_recover;
    // file_recover.open("golden_recover.txt");
    
    // read the image
    Mat img = imread(argv[1]);

    int rows = img.rows;
    int cols = img.cols;

    // Create dc image natrix
    Mat Dark_channel_img(rows, cols, CV_8UC1, Scalar(0));
    
    // convert RGB to grayscale(if needed)
    for(int i = 0; i < rows; i++){
        for (int j = 0; j < cols; j++){
            // color sequence: B->G->R
            Dark_channel_img.at<uchar>(i,j) = min(min(img.at<Vec3b>(i,j)[0], img.at<Vec3b>(i,j)[1]), img.at<Vec3b>(i,j)[2]);
        }
    }


    // T_map (iteration) caculation
    for(int i = 1; i < rows-1; i++){
        for (int j = 1; j < cols-1; j++){
            // color sequence: B->G->R
            int min_temp = 255;
            for(int r = -1; r < 2; r++){
                for(int c = -1; c < 2; c++){
                    int temp = Dark_channel_img.at<uchar>(i+r,j+c);
                    if(temp < min_temp){
                        min_temp = temp;
                    }
                }
            }
            file_dcp << min_temp << endl;
            Dark_channel_img.at<uchar>(i,j) = A - 0.75*min_temp;
        }
    }

    // // write tmap golden file
    // for(int i = 0; i < rows; i++){
    //     for (int j = 0; j < cols; j++){
    //         // color sequence: B->G->R
    //         file_tmap << int(Dark_channel_img.at<uchar>(i,j)) << endl;
    //     }
    // }


    Mat T_map(Dark_channel_img);

    Mat result;
    img.copyTo(result);
    
    // Recovering the image
    for(int i = 1; i < rows-1; i++){
        for (int j = 1; j < cols-1; j++){
            for (int k = 0; k < 3; k++){
                result.at<Vec3b>(i,j)[k] = (A/max({(double)T_map.at<uchar>(i,j), 0.1*A}))*(img.at<Vec3b>(i,j)[k]-A)+A;
            }
        }
    }

    // // write recover golden file
    // for(int i = 0; i < rows; i++){
    //     for (int j = 0; j < cols; j++){
    //         for (int k = 0; k < 3; k++){
    //             result.at<Vec3b>(i,j)[k] = (A/max({(double)T_map.at<uchar>(i,j), 0.1*A}))*(img.at<Vec3b>(i,j)[k]-A)+A;
    //         }
    //         file_recover << int(result.at<Vec3b>(i,j)[0]) << endl;
    //         file_recover << int(result.at<Vec3b>(i,j)[1]) << endl;
    //         file_recover << int(result.at<Vec3b>(i,j)[2]) << endl;
    //     }
    // }

    // Show the image
    imshow("Original Image", img);
    imshow("Transmission Map", T_map);
    imshow("Recovery", result);
    waitKey(0);


}

    
