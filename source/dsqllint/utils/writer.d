module dsqllint.utils.writer;

import std.stdio;
import std.file;

public class ConsoleWriter {
	public static void write(string data)
	{
		writeln(data);
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
