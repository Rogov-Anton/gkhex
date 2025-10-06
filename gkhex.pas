program gkhex;
type
	hex_file = file of byte;


procedure print_help();
begin
	writeln('  --- GKHEX editor help ---');
	writeln('');
end;


procedure get_command(var all, command, txt: string);
var
	len: byte;
	i: byte = 1;
begin
	len := length(all);
	while (i <= len) and (all[i] = ' ') do
		i := i + 1;
	if i = len then
	begin
		command := '';
		txt := '';
		exit;
	end;

	while (i <= len) and (all[i] <> ' ') do
	begin
		command := command + all[i];
		i := i + 1;
	end;
	if i = len then
	begin
		txt := '';
		exit;
	end;

	while (i <= len) do
	begin
		i := i + 1;
		txt := txt + all[i]
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


procedure write_data(var f: hex_file; var txt: string);
var
	i: byte = 1;
	first, second: char;
begin
	while i <= 47 do
	begin
		first := txt[i];
		second := txt[i + 1];
		i := i + 3;
		write(hex_to_dec(first, second), ' ');
		writeln;
	end;
end;


procedure set_file_size(var f: hex_file; var txt: string);
var
	size, i: longword;		{ size of binary file }
	ok: integer = 0;
begin
	val(txt, size, ok);
	for i := 1 to size * 16 do
		write(f, 00);
end;


procedure print_file(var f: hex_file);
var
	i: byte = 0;
	b: byte;
begin
	while not eof do
	begin
		read(f, b);
		writeln(b);
		i += 1;
		if i > 15 then
		begin
			i := 0;
			writeln;
		end;
	end;
end;


procedure execute_command(var command, txt: string; var f: hex_file);
var
	index: byte;
begin
	case command of
		's': set_file_size(f, txt);
		'p': print_file(f);
		'w': write_data(f, txt);
	end;
end;


var
	curr_file: hex_file;
	all, command, txt: string;
begin
	if ParamCount < 1 then
	begin
		writeln('Please, pecify a file...');
		halt(0);
	end;
	assign(curr_file, ParamStr(1));
	rewrite(curr_file);
	writeln;

	writeln('  Welcome to gkhex, simple hex editor. To get help, input `help`');
	write(#10 + '  -> ');
	readln(all);
	while all <> 'exit' do
	begin
		command := ''; txt := '';
		get_command(all, command, txt);
		execute_command(command, txt, curr_file);
		write('  -> ');
		readln(all);
	end;
	close(curr_file);
end.
