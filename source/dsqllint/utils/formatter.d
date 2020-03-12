module dsqllint.utils.formatter;

import dsqllint.utils.message;
import dsqllint.utils.logger;

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

	public this(bool withColors = true)
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
			~ "(" ~ msg.line.to!string ~ columnText ~ "): ";
		string fileInfoText = (withColors)
			? colorizeFileInfo(fileInfo)
			: fileInfo;

		string levelText = (withColors)
			? colorizeLevel(msg.level)
			: msg.level.to!string ~ ": ";

		return fileInfoText
			~ levelText
			~ msg.rule ~ ": "
			~ msg.description;
	}

	private bool withColors;
}

@safe pure
@("Formatter: Level")
unittest {

}
