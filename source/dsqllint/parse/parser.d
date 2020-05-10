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

module dsqllint.parse.parser;

import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.ast.nodes.statement.sequence;
import dsqllint.parse.ast.nodes.comment;
import dsqllint.parse.ast;
import dsqllint.parse.tokenize.tok;
import dsqllint.parse.tokenize.tokens;
import dsqllint.parse.file;
import dsqllint.parse.ast.context;

import std.conv : to;

import std.exception;

@safe pure
class InvalidSQLParseException : InvalidSQLFileException
{
	///
	@safe pure
	public this(
		string msg,
		SQLFile.Location fileLocation,
		string file = __FILE__,
		size_t line = __LINE__,
		Throwable nextInChain = null)
	{
		super(msg, fileLocation, file, line, nextInChain);
	}
}

struct SQLParser
{
	@safe
	this(TokenIterator it)
	{
		this.it = it;
	}

	SQLTree parse()
	{
		auto statements = StatementSequenceNode.parse(SQLContext(it));
		return new SQLTree(statements);
	}

	static SQLCommentNode[] parseComments(TokenIterator it)
	{
		import std.array : appender;
		auto ret = appender!(SQLCommentNode[])();
		whileIterator: while(it.hasNext)
		{
			auto cur = it.current.token;

			switch(cur.name)
			{
				case "LINE_COMMENT":
				case "MULTI_LINE_COMMENT":
					ret.put(new SQLCommentNode(it.current));
					goto case;
				case "WHITESPACE":
					it.next();
					continue;
				default: break whileIterator;
			}
		}

		return ret.data;
	}

	static void accept(string tokName)(TokenIterator it, bool hasNext = true)
	{
		accept(it, SQLToken.get!tokName.name, hasNext);
	}

	static void accept(TokenIterator it, string tokName, bool hasNext = true)
	{
		//alias vars
		auto cur = it.current;
		auto curName = cur.token.name;

		if(curName == tokName)
		{
			if(hasNext) it.next();
		}
		else
			throw new InvalidSQLParseException(
				"syntax error in "
				~ cur.startLine.to!string ~ ":" ~ cur.startCol.to!string
				~ " expected " ~ tokName ~ " but got " ~ cur.token.name,
				SQLFile.Location(cur.startLine, cur.startCol)
			);
	}

	private TokenIterator it;
}
