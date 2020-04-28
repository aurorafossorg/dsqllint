module dsqllint.utils.writer;

import std.stdio;
import std.file;

version(unittest) import aurorafw.unit.assertion;

public class ConsoleWriter {
	public static void write(string data)
	{
		stdout.writeln(data);
	}

	public static void writeError(string data)
	{
		stderr.writeln(data);
	}
}

public class FileWriter {
	public this(string filePath)
	{
		this.file = File(filePath, "wb");
	}

	public void write(string data)
	{
		file.writeln(data);
	}

	File file;
}

@("Writers: FileWriter")
unittest
{
	auto file = deleteme ~ "FileWriter";
	scope(exit) remove(file);

	auto fw = new FileWriter(file);
	fw.write("foo");
	fw.file.flush();

	import std.ascii : newline;
	assertEquals("foo" ~ newline, readText(file));
}
