module dsqllint.utils.logger;

import dsqllint.utils.formatter;
import dsqllint.utils.message;
import dsqllint.utils.writer;

import core.sync.mutex : Mutex;

//based on std.experimental.logger.core
enum LogLevel : ubyte
{
	/**
	 * Low-level information about the program should be displayed with this
	 * level.
	 */
	Info = 1 << 0,

	/// Warnings about the program should be displayed with this level.
	Warning = 1 << 1,

	/// Critical errors about the program should be logged with this level.
	Critical = 1 << 2,

	/// Information about errors should be logged with this level.
	Error = 1 << 3
}

/// Function type to write logs
alias LogWriter = void function(string...);

interface ILogger
{
	void write(DSQLLintMessage message);

	public void write(LogLevel level)(
		string filename,
		size_t line,
		size_t column,
		string description)
	{
		this.write!(level)(filename, line, column, null, description);
	}

	public void write(LogLevel level)(
		string filename,
		size_t line,
		size_t column,
		string rule,
		string description)
	{
		auto message = DSQLLintMessage(
				filename, line, column,
				rule, level, description
			);

		this.write(message);
	}
}

public final class DSQLLinterLogger : ILogger
{
	public this(IFormatter fmt, LogLevel level = LogLevel.Info)
	{
		this.formatter = fmt;
		this.maxLevel = level;

		this.writeLock = new Mutex();
		this.writers = [
			&ConsoleWriter.write,
		];
		this.errorWriters = [
			&ConsoleWriter.writeError,
		];
	}

	///
	public void write(DSQLLintMessage message)
	{
		LogWriter[] usedWriters;

		if(message.level == LogLevel.Error || message.level == LogLevel.Critical)
			usedWriters = this.errorWriters;
		else
			usedWriters = this.writers;

		writeLock.lock();
		foreach(writer; usedWriters)
			writer(formatter.toString(message));
		writeLock.unlock();
	}

	/// List of log writers to write the logged messages
	public LogWriter[] writers;

	/// List of log writers to write logged error messages
	public LogWriter[] errorWriters;

	private IFormatter formatter;
	private LogLevel maxLevel;
	private Mutex writeLock;
}
