module dsqllint.utils.writer;

import std.stdio;
import std.file;

public class ConsoleWriter {
	public static void write(string args...)
	{
		writeln(args);
	}

	public static void writeError(string args...)
	{
		stderr.writeln(args);
	}
}

public class FileWriter {
	public this(string filePath)
	{
		this.file = File(filePath, "wb");
	}

	public void write(string args...)
	{
		file.writeln(args);
	}

	File file;
}
