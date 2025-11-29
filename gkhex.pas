program gkhex;
uses crt;
type
	bin_file = file of byte;


procedure print_help();
begin
	writeln(#10 + '  --- GKHEX editor help ---' + #10);
	writeln('  r: overwrite the file with zeros');
	writeln('  p: print_file');
	writeln('  a: print file in ascii');
	writeln('  c: change address in file');
	writeln('  w: write data in file');
	writeln('  l: convert string to hex');
	writeln('  C: clear screen');
	writeln('  e: exit');
end;


procedure get_command(var all, command, args: string);
var
	i: byte = 1;
	len: byte;
begin
	len := length(all);
	command := '';
	args := '';
	while (all[i] = ' ') and (i <= len) do
		i := i + 1;
	if i > len then
		exit;
	while (all[i] <> ' ') and (i <= len) do
	begin
		command := command + all[i];
		i := i + 1;
	end;
	if i > len then
		exit;
	while (all[i] = ' ') and (i <= len) do
		i := i + 1;
	if i > len then
		exit;
	while (all[i] <> #10) and (i <= len) do
	begin
		args := args + all[i];
		i := i + 1;
	end;
end;


function hex_to_dec(first, second: char): integer;
var
	ok: integer = 0;
	tmp: byte;
	res: byte = 1;
begin
	if ('0' <= first) and (first <= '9') then
		val(first, res, ok)
	else
	begin
		case first of
			'A': res := 10;
			'B': res := 11;
			'C': res := 12;
			'D': res := 13;
			'E': res := 14;
			'F': res := 15;
		end;
	end;
	if ('0' <= second) and (second <= '9') then
	begin
		val(second, tmp, ok);
		res := res * 16 + tmp;
	end
	else
	begin
		case second of
			'A': res := res * 16 + 10;
			'B': res := res * 16 + 11;
			'C': res := res * 16 + 12;
			'D': res := res * 16 + 13;
			'E': res := res * 16 + 14;
			'F': res := res * 16 + 15;
		end;
	end;
	hex_to_dec := res;
end;


procedure write_data(var f: bin_file; var args: string);
var
	curr_pos: longword;
	i: byte = 1;
	first, second: char;
begin
	curr_pos := filepos(f);
	while i <= length(args) do
	begin
		first := args[i];
		second := args[i + 1];
		write(f, hex_to_dec(first, second));
		i := i + 3;
		{ write(hex_to_dec(first, second), ' '); }
	end;
	writeln;
	seek(f, curr_pos);
end;


procedure rewrite_file(var f: bin_file; var args: string);
var
	size, i: longword;              { size of binary file }
	ok: integer = 0;
begin
	val(args, size, ok);
	for i := 1 to size * 16 do
		write(f, 00);
	seek(f, 0);
end;


procedure print_file(var f: bin_file; curr_address: longword);
{ curr_addr -> variable to print file (not real address)}
{ curr_address -> real address in file }
var
	curr_addr: longword = 0;
	curr_pos: longword;
	i: byte = 0;
	b: byte;
begin
	curr_pos := filepos(f);
	seek(f, 0);
	TextColor(lightgreen);
	writeln(#10 + '            0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F');
	while not eof(f) do
	begin
		if i = 0 then
		begin
			writeln;
			i := 16;
			if curr_addr = curr_address then
			begin
				TextColor(lightred);
				write('  ' + HexStr(curr_addr, 8) + ': ');
				write(#27'[0m');
			end
			else
			begin
				TextColor(yellow);
				write('  ' + HexStr(curr_addr, 8) + ': ');
				write(#27'[0m');
			end;
		end;
		read(f, b);
		write(HexStr(b, 2), ' ');
		i := i - 1;
		curr_addr := curr_addr + 1;
	end;
	writeln;
	seek(f, curr_pos);
end;


procedure print_ascii(var f: bin_file; curr_address: longword);
var
	curr_addr: longword = 0;
	curr_pos: longword;
	i: byte = 16;
	b: byte;
begin
	curr_pos := filepos(f);
	seek(f, 0);
	while not eof(f) do
	begin
		if i = 16 then
		begin
			write(#10 + '  ');
			i := 0;
		end;
		read(f, b);
		if (b >= 32) and (b <= 126) then
			write(chr(b))
		else
			write('-');
		i := i + 1;
		curr_addr := curr_addr + 1;
	end;
	writeln;
	seek(f, curr_pos);
end;


procedure change_address(var f: bin_file; args: string; var curr_addr: longword);
var
	address: longword;
	ok: integer;
begin
	val(args, address, ok);
	seek(f, address * 16);
	curr_addr := address * 16;
	writeln(address * 16);
end;


procedure string_to_hex(var s: string);
var
	i: byte;
begin
	write('  ');
	for i := 1 to length(s) do
	begin
		write(HexStr(ord(s[i]), 2), ' ');
	end;
	writeln()
end;


procedure execute_command(var command, args: string; var f: bin_file;
						var curr_addr: longword);
begin
	case command of
		'r': rewrite_file(f, args);
		'p': print_file(f, curr_addr);
		'a': print_ascii(f, curr_addr);
		'c': change_address(f, args, curr_addr);
		'w': write_data(f, args);
		'l': string_to_hex(args);
		'C': clrscr;
		'help': print_help();
		else writeln('  Bad command');
	end;
end;


{$I-}
var
	curr_file: bin_file;
	all, command, args: string;
	curr_address: longword = 0;
begin
	if ParamCount < 1 then
	begin
		writeln('Please, pecify a file...');
		halt(0);
	end;
	assign(curr_file, ParamStr(1));
	reset(curr_file);
	if IOresult <> 0 then
	begin
		writeln('Error: file does not exist');
		halt(1);
	end;
	writeln;
	writeln('  Welcome to gkhex, simple hex editor. To get help, input `help`.');
	TextColor(lightblue);
	write(#10 + '  [', HexStr(curr_address, 8), ']', #27'[0m');
	write(' -> ');
	readln(all);
	while all <> 'e' do
	begin
		get_command(all, command, args);
		if all <> '' then
			execute_command(command, args, curr_file, curr_address);
		TextColor(lightblue);
		write(#10 + '  [', HexStr(curr_address, 8), ']', #27'[0m');
		write(' -> ');
		readln(all);
	end;
	close(curr_file);
end.

