# WhatFlower

We learned how to convert other ML models into CoreML model. Specifically, we converted caffe model to core ml model using coremltools.

I removed the converted model from the project before uploading on github because the file is too large. 


## IMPORTANT
The classification returns a "MultiArray : Double 1 × 1 × 102 × 1 × 1 array" (amongst other things). 
The 102 elements of the array are Doubles, which I couldn't make sense of (due to lack of documentation for this model).
So, to continue with the tutorial, I decided to use the "prob" for my wiki's API request.

