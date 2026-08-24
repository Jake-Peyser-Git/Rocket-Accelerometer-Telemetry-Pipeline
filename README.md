Designed a wireless telemetry system using a Raspberry Pi Pico and WiFi-based data acquisition pipeline (Pico -> WiFi router -> PC) for 3-axis flight data with a calibration protocol for sensor bias, orientation determination, and axis scaling. This was accomplished via a combination of interconnected scripts across C++, Python, and MATLAB. The procedure was preformed as follows:

(1) Set up wireless WiFi router and PC for data collection

(2) Upload C++ accelerometer script to the pico-accelerometer unit, which instructs the pico to send accelerometer data packets to the set IP

(3) Run the python calibration script while the accelerometer is at rest in 3 distinct orientations and collect the reported instrumentation gains/biases

(4) Run the python crash test script, which prints the (desired) accelerometer data to the console and a CSV/excel file

(5) Insert the data file into the MATLAB code in conjunction with the calibration gains/biases and run the script

The output returns a plot of the raw and calibrated accelerometer data. That's it! This was an integrated sub-component of an engineering project at the Cooper Union, and so I also included the (supplementary) project report that went with it. See the appendix for the calibration algorithm documentation. 

Much thanks to Mike Giglia @ the Cooper Union for his extremely helpful software guidance. 
Another major thanks to my colleague David Brokhin for his essential hardware implementation design.

Example pre/post calibration (400g) accelerometer plots:
<img width="717" height="528" alt="image" src="https://github.com/user-attachments/assets/eb6546f9-c844-4697-9755-735d03f2fd82" />
<img width="727" height="535" alt="image" src="https://github.com/user-attachments/assets/d816ce53-bb1b-430d-b9a4-431f025499d3" />
<img width="780" height="575" alt="image" src="https://github.com/user-attachments/assets/e5c7ca93-6df0-4544-b202-3d3a15920e8f" />
<img width="773" height="558" alt="image" src="https://github.com/user-attachments/assets/d86f21d7-d0e2-44eb-96a5-12b5110749f1" />
<img width="757" height="560" alt="image" src="https://github.com/user-attachments/assets/078d444e-0f75-4f4e-8cc8-7962c8c49ac8" />
<img width="768" height="554" alt="image" src="https://github.com/user-attachments/assets/b0cce6a5-e80f-46b9-a75b-f6dcd0532158" />
