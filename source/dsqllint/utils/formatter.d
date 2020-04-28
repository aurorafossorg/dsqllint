module dsqllint.utils.formatter;

import dsqllint.utils.message;
import dsqllint.utils.logger;
import std.range;

version(unittest) import aurorafw.unit.assertion;

interface IFormatter
{
	string toString(DSQLLintMessage msg);
}


public class DSQLLintFormatter : IFormatter
{
	// TODO: Detect if stdin is present or not to disable colors on pipes
	public this()
	{
		import core.sys.posix.unistd : isatty, STDERR_FILENO, STDIN_FILENO;
		if(isatty(STDIN_FILENO) && isatty(STDERR_FILENO))
			this.withColors = true;
		else
			this.withColors = false;
	}

	public this(bool withColors)
	{
		this.withColors = withColors;
	}

	public string toString(DSQLLintMessage msg) const
	{
		import std.conv : to;

		string colorizeLevel(LogLevel level)
		{
			string init;
			final switch(level)
			{
				case LogLevel.Info:
					init = "\033[96m";
					break;
				case LogLevel.Warning:
					init = "\033[93m";
					break;
				case LogLevel.Critical:
				case LogLevel.Error:
					init = "\033[91m";
					break;
			}

			return "\033[1m" ~ init ~ msg.level.to!string ~ ": " ~ "\033[0m";
		}

		/// this will make fileInfo text colorizerd (in white bold)
		string colorizeFileInfo(string fileInfo)
		{
			return "\033[1m\033[97m" ~ fileInfo ~ "\033[0m";
		}

		string columnText = (msg.column != 0)
			? ":" ~ msg.column.to!string
			: "";

		import std.path : relativePath;
		string fileInfo = relativePath(msg.filename)
			~ ((msg.line != 0) ? "(" ~ msg.line.to!string ~ columnText ~ ")" : "") ~ ": ";
		string fileInfoText = (withColors)
			? colorizeFileInfo(fileInfo)
			: fileInfo;

		string levelText = (withColors)
			? colorizeLevel(msg.level)
			: msg.level.to!string ~ ": ";

		return fileInfoText
			~ levelText
			~ ((!msg.rule.empty) ? msg.rule ~ ": " : "")
			~ msg.description;
	}

	private bool withColors;
}

version(unittest)
{
	package class UnittestDummyFormatter : IFormatter
	{
		string toString(DSQLLintMessage msg)
		{
			import std.conv : to;
			return msg.to!string;
		}
	}
}


@("Formatter: toString")
unittest
{
	auto fmt = new DSQLLintFormatter(false);

	auto msg = DSQLLintMessage(
		"error", 2, 3, "ErrorRule", LogLevel.Error,
		"this is an error"
	);

	assertEquals("error(2:3): Error: ErrorRule: this is an error", fmt.toString(msg));

	msg = DSQLLintMessage(
		"error", 2, 0, "ErrorRule", LogLevel.Error,
		"this is an error"
	);
	assertEquals("error(2): Error: ErrorRule: this is an error", fmt.toString(msg));

	msg = DSQLLintMessage(
		"error", 0, 0, "ErrorRule", LogLevel.Error,
		"this is an error"
	);
	assertEquals("error: Error: ErrorRule: this is an error", fmt.toString(msg));

	msg = DSQLLintMessage(
		"error", 0, 0, "", LogLevel.Error,
		"this is an error"
	);
	assertEquals("error: Error: this is an error", fmt.toString(msg));
}
