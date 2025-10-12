program gkhex;
type
	bin_file = file of byte;


procedure print_help();
begin
	writeln('  --- GKHEX editor help ---');
	writeln('');
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


procedure write_data(var f: bin_file; var txt: string);
var
	i: byte = 1;
	first, second: char;
begin
	while i <= 47 do
	begin
		first := txt[i];
		second := txt[i + 1];
		i := i + 3;
		write(f, hex_to_dec(first, second));
		write(hex_to_dec(first, second), ' ');
	end;
	writeln;
end;


procedure set_file_size(var f: bin_file; var txt: string);
var
	size, i: longword;              { size of binary file }
	ok: integer = 0;
begin
	val(txt, size, ok);
	for i := 1 to size * 16 do
		write(f, 00);
end;


procedure print_file(var f: bin_file);
var
	curr_addr: longword = 0;
	curr_pos: longword;
	i: byte = 0;
	b: byte;
begin
	curr_pos := filepos(f);
	seek(f, 0);
	write(#10 + '  ' + HexStr(curr_addr, 8) + ': ');
	while not eof(f) do
	begin
		read(f, b);
		write(HexStr(b, 2), ' ');
		i := i + 1;
		if i > 15 then
		begin
			writeln;
			write('  ' + HexStr(curr_addr, 8) + ': ');
			curr_addr := curr_addr + 16;
			i := 0;
		end;
	end;
	writeln('-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --');
	seek(f, curr_pos);
end;


procedure change_address(var f: bin_file; txt: string; var curr_addr: longword);
var
	address: longword;
	ok: integer;
begin
	val(txt, address, ok);
	seek(f, address * 16);
	curr_addr := address * 16;
	writeln(address * 16);
end;


procedure execute_command(var command, txt: string; var f: bin_file;
						var curr_addr: longword);
begin
	case command of
		's': set_file_size(f, txt);
		'p': print_file(f);
		'c': change_address(f, txt, curr_addr);
		'w': write_data(f, txt);
		else writeln('Bad command');
	end;
end;


var
	curr_file: bin_file;
	all, command, txt: string;
	curr_address: longword = 0;
begin
	if ParamCount < 1 then
	begin
		writeln('Please, pecify a file...');
		halt(0);
	end;
	assign(curr_file, ParamStr(1));
	rewrite(curr_file);
	writeln;
	writeln('  Welcome to gkhex, simple hex editor. To get help, input `help`.');
	write(#10 + '  [', HexStr(curr_address, 8), ']', ' -> ');
	readln(all);
	while all <> 'e' do
	begin
		get_command(all, command, txt);
		execute_command(command, txt, curr_file, curr_address);
		write(#10 + '  [', HexStr(curr_address, 8), ']', ' -> ');
		readln(all);
	end;
	close(curr_file);
end.

{
writeln('(DEBUG) all:     ', all);
writeln('(DEBUG) command: ', command);
writeln('(DEBUG) txt:     ', txt);
}
