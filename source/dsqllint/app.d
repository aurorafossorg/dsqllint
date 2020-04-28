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
import dsqllint.utils.filesearch;

import std.format;
import std.parallelism;
import std.conv : to;
import std.datetime;
import std.experimental.logger : info, trace;

import aurorafw.stdx.exception;

version(unittest) {}
else
{
	int main(string[] args)
	{
		IFormatter formatter = new DSQLLintFormatter();
		ILogger logger = new DSQLLinterLogger(
			formatter
		);

		auto sqlFiles = getFileEntries(args[1 .. $], logger);

		foreach (file; sqlFiles)
		{
			auto before = MonoTime.currTime;
			try {
				SQLFile(file.name);
			}
			catch(InvalidSQLFileException e) {
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

				trace(e.info);
			}
			info("Analized " ~ file.name ~ " in ", MonoTime.currTime - before);
		}

		return 0;
	}
}
