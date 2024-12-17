fs = 1000;
fc = 100;
order = 100;

wc = 2*fc/fs;

b = fir1(order, wc);

freqz(b,1,1024,fs);

