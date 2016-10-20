function h = vrLoggerCallback(u, h)

% fprintf('%s:%d\n', u.DatagramAddress, u.DatagramPort),
% u.RemoteHost=u.DatagramAddress;
% u.RemotePort=u.DatagramPort;
% disp('now reading data');

persistent folders filename

ip=u.DatagramAddress;
port=u.DatagramPort;
% these are needed for proper echo
u.RemoteHost=ip;
u.RemotePort=port;
data=fread(u);
str=char(data');
fprintf('Received ''%s'' from %s:%d\n', str, ip, port);

delimiter = ' +'; % one or more spaces
message=regexp(str, delimiter, 'split');
instruction = message{1};
% subject = message{2};

switch instruction
    case 'hello'
        %         fwrite(u, data);
    case 'Filename'
        % this is the file on the zserver, which is updated after every
        % trial with all the session info
        filename = message{2};
    case 'ExpStart'
        load the EXP structure and extract all the experiment parameters
        draw the maze map with a mouse in it
        %         fwrite(u, data);
    case 'ExpEnd'
        %         fwrite(u, data);
    case 'BlockStart'
        %         fwrite(u, data);
    case 'BlockEnd'
        %         fwrite(u, data);
    case 'StimStart'
        %         fwrite(u, data);
    case 'StimEnd'
        %         fwrite(u, data);
    case 'Position'
        update the mouse position on the map
    case 'Event'
    otherwise
        fprintf('Unknown instruction : %s', info.instruction);
        %         fwrite(u, data);
end

% disp('now the addresses are:');
% fprintf('%s:%d\n', u.DatagramAddress, u.DatagramPort),
% fprintf('now sending %s to the remote host\n', char(data(:))');
% fprintf('%s\n', char(data(:))');
% fprintf

end
%===========================================================
%

