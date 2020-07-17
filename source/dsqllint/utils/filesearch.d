module dsqllint.utils.filesearch;

import dsqllint.utils.logger;

import std.array;
import std.file;
import std.algorithm;

version(unittest)
{
	import dsqllint.utils.formatter;
	import dsqllint.utils.message;
	import aurorafw.unit.assertion;
}

DirEntry[] getFileEntries(string[] args, ILogger logger = null)
{
	auto recursiveSearch(string path)
	{
		return dirEntries(
				path,
				SpanMode.depth
			).filter!(f => f.isFile && f.name.endsWith(".sql"));
	}

	if(args.empty)
		return recursiveSearch("").array;

	auto files = Appender!(DirEntry[])();

	foreach(path; args)
	{
		if(!path.exists)
		{
			if(logger !is null)
				logger.write!(LogLevel.Warning)(
					path,
					0,
					0,
					"",
					"No such file or directory"
				);
		}
		else if(path.isFile)
			files ~= DirEntry(path);
		else
			files ~= recursiveSearch(path);
	}

	return files[];
}

///
@system
@("App: File Entries")
unittest
{
	import std.path : buildPath;
	import std.exception : assertThrown;
	import std.conv : to;

	string[] output;

	void outputWriter(string data)
	{
		output ~= data;
	}

	UnittestDummyFormatter unittestFmt = new UnittestDummyFormatter();
	DSQLLinterLogger logger = new DSQLLinterLogger(unittestFmt);

	// unittest dummy writers
	import std.functional : toDelegate;
	logger.writers = [toDelegate(&outputWriter)];
	logger.errorWriters = logger.writers;

	auto dir = deleteme ~ "dir";
	auto cwdir = getcwd;

	dir.mkdir;
	scope(exit) dir.rmdirRecurse;

	mkdir(dir.buildPath("a"));
	mkdir(dir.buildPath("b"));

	dir.chdir;
	scope(exit) cwdir.chdir;

	void assertEmptyFileEntries(){
		assertEquals([], getFileEntries([]));
		assertEquals([], getFileEntries([dir]));
	}

	assertEquals([], getFileEntries([dir.buildPath("thisfiledoesntexist.txt")]));
	assertEquals([], getFileEntries([dir.buildPath("thisfiledoesntexist.txt")], logger));
	assertEquals(
		DSQLLintMessage(
			dir.buildPath("thisfiledoesntexist.txt"), 0, 0, "", LogLevel.Warning,
			"No such file or directory"
		).to!string,
		output.front);

	output = [];

	// test only with directories
	assertEmptyFileEntries();

	// test with a .sql directory but with no relevant files
	mkdir(dir.buildPath("ups.sql"));
	assertEmptyFileEntries();

	// add random file
	write(dir.buildPath("4.txt"), []);
	assertEmptyFileEntries();

	// add some relevant files
	write(dir.buildPath("a", "1.sql"), []);
	write(dir.buildPath("a", "2.sql"), []);
	write(dir.buildPath("b", "3.sql"), []);

	auto fileArgs = [dir.buildPath("a", "1.sql")];
	assertEquals(
		fileArgs,
		getFileEntries(fileArgs));

	assertEquals([
		buildPath("a", "1.sql"),
		buildPath("a", "2.sql"),
		buildPath("b", "3.sql"),
	], getFileEntries([]).sort.array);

	assertEquals([
		dir.buildPath("a", "1.sql"),
		dir.buildPath("a", "2.sql"),
		dir.buildPath("b", "3.sql"),
	], getFileEntries([dir]).sort.array);

	assertTrue(dir.exists);
}
