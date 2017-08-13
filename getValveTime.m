function dur = getValveTime(waterAmount)

[waterCal, durCal] = getValveCalibrationData;
p = polyfit(waterCal, durCal, 1);
dur = p(1)*waterAmount + p(2);