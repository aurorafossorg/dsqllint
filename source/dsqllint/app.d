/*
  ____      ____  ____  _     _     _  _    _  _____
 |  _"\    / ___\/  _ \/ \   / \   / \/ \  / |/__ __\
/| | | |   |    \| / \|| |   | |   | || |\ | |  / \
U| |_| |\  \___ || \_\|| |_/\| |_/\| || | \| |  | |
 |____/ u  \____/\____\\____/\____/\_/\_/  \_|  \_/
  |||_
 (__)_)

Copyright (C) 2019-2020 Aurora Free Open Source Software.
Copyright (C) 2019-2020 Luís Ferreira <luis@aurorafoss.org>

This file is part of the Aurora Free Open Source Software. This
organization promote free and open source software that you can
redistribute and/or modify under the terms of the GNU Lesser General
Public License Version 3 as published by the Free Software Foundation or
(at your option) any later version approved by the Aurora Free Open Source
Software Organization. The license is available in the package root path
as 'LICENSE' file. Please review the following information to ensure the
GNU Lesser General Public License version 3 requirements will be met:
https://www.gnu.org/licenses/lgpl.html .

Alternatively, this file may be used under the terms of the GNU General
Public License version 3 or later as published by the Free Software
Foundation. Please review the following information to ensure the GNU
General Public License requirements will be met:
http://www.gnu.org/licenses/gpl-3.0.html.

NOTE: All products, services or anything associated to trademarks and
service marks used or referenced on this file are the property of their
respective companies/owners or its subsidiaries. Other names and brands
may be claimed as the property of others.

For more info about intellectual property visit: aurorafoss.org or
directly send an email to: contact (at) aurorafoss.org .
 */

module dsqllint.app;

import dsqllint.parse.lexer;
import dsqllint.parse.tokenize.tokens;
import dsqllint.parse.parser;
import dsqllint.utils.printer;
import dsqllint.parse.file;
import dsqllint.utils.logger;
import dsqllint.utils.formatter;

import std.stdio;
import std.format;
import std.array;
import std.file;
import std.parallelism;
import std.algorithm;
import std.conv : to;
import std.datetime;

import aurorafw.stdx.exception;

DirEntry[] getFileEntries(string[] args)
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
		if(path.isFile)
			files ~= DirEntry(path);
		else
			files ~= recursiveSearch(path);
	}

	return files[];
}

version(unittest) {}
else
{
	int main(string[] args)
	{
		IFormatter formatter = new DSQLLintFormatter();
		ILogger logger = new DSQLLinterLogger(
			formatter
		);

		auto sqlFiles = getFileEntries(args[1 .. $]);

		foreach (file; sqlFiles)
		{
			try {
				SQLFile(file.name);
			} catch(InvalidSQLFileException e) {
				string reportedRule =
					(typeid(InvalidSQLParseException) == typeid(e)) ? "Parser" : "Lexer";

				logger.write!(LogLevel.Critical)(
					file.name,
					e.fileLocation.line,
					e.fileLocation.column,
					reportedRule,
					e.msg
				);
			}
			// temporary catch
			catch(NotImplementedException e)
			{
				logger.write!(LogLevel.Critical)(
					e.file,
					e.line,
					0,
					"NotImplementedException",
					e.msg
				);

				//TODO: print this on verbose mode
				//writeln(e.info);
			}
		}

		return 0;
	}
}
