%% udp testing script

RemoteHost = '144.82.135.90'; % this is the ZMAZE address
RemotePort = 1103;
u = udp(RemoteHost, RemotePort, 'LocalPort', 1001);
h = 0; % pointing to root in the beginning
set(u, 'DatagramReceivedFcn', 'h = vrLoggerCallback(u, h);');
fopen(u);
% echoudp('off');

% fclose(u);
% delete(u);

% fclose(u); fopen(u);