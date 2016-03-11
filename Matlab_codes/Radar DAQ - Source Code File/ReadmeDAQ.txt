Collection for the Radar System - ICDT/BSP Lab Summer 2015
Author - Shadman Zaman Samin

This code includes visualization, guided intructions and scripted tagging for the collection data for a more robust data collection.

The follow main function does the following:
  
main_radarCollection - The function collects data in the background once the user specifies a length of the collection and sampling rate. This function has no graphical visualization it only collects data and prompts the hardware.

main_scriptingVisualization - This function has multiple feature added to it. It has a graphical user interface but does not include data visualization. But once the user specifies the sampling rate and hits the PLAY button. A series of guided text popups on the screen with a background beep noise to notify the user to perform a certain action during the colleciton.
 
main_radarContinuous - This function comes with a GUI and a plot for real-time data visualization. The PLAY buttons starts the collection and the bottom figure plots 3 second worth of data onto the screen and top plot is a elliptical plot of the two data extraction values from the hardware to show shifts in phase as the sensor is moved back and forth from the Radar.

main_radarCollectionScripting - This function is short scripted collection in lengths of minutes. The way this function works is that it stops collection and restarts collection every step and state to perform a certain action. Then an array is used to concatenate all the array to see changes in phase. This software includes a guided audioo instruction for the user to perform different actions.

  The ccode is compatible to MCC DAQ with a legacy based system. The
  function prompts the user to select a sampling rate. The GUI is then
  generated, where the user is asked to start the collection using the START
  button. The CLEAR button closes the figure and prompts the user to save
  the file in a designated location. 

  --------------------- Hardware Set up ---------------------------------
  Below, is the detail layout of the hardware connections with the IR GAIT
  system 
  Analog Pin Connections ------------------------------------------------
  Pin 1 ----> Radar
  Pin 2 ----> Sensor (Scattered Amplified Signal)
 
 
 
  ----------------------- GUI Layout -----------------------------------
  The GUI has few different components. The GUI has a sliding windows of 3
  seconds. The toolbar allows the user to make changes in the plot in real
  time. The buttons on the user interface is as follows. 
  PLAY button starts the collection. 
  CLEAR button ends collection and prompts the users to save the data. 