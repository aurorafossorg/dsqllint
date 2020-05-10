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

module dsqllint.parse.ast.nodes.statement.statement;

import dsqllint.parse.ast.nodes.base;
import dsqllint.parse.ast.object;
import dsqllint.parse.ast.nodes.comment;
import dsqllint.parse.ast.visitor;
import dsqllint.parse.parser;
import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.tokenize.tok;
import dsqllint.parse.tokenize.tokens;
import dsqllint.parse.ast.nodes.statement.select;
import dsqllint.parse.file;
import dsqllint.parse.ast.context;

import aurorafw.stdx.exception;

import std.format;
import std.typecons;

public interface SQLStatement : SQLObject
{}

abstract class SQLStatementNode : SQLBaseNode, SQLStatement
{
	public this()
	{
		throw new NotImplementedException("TODO:");
	}

	public static SQLStatementNode parse(
		SQLContext context)
	{
		context.parseBeforeCommentsIfNull();

		if(context.iterator.hasNext)
		{
			size_t startIndex = context.iterator.index;

			//alias
			auto cur = context.iterator.current.token;

			switch(cur.name)
			{
				case SQLToken.get!"WITH".name:
					return SQLSelectStatementNode.parse(
						context,
						startIndex,
						Yes.withToken);
				case SQLToken.get!"SELECT".name:
					return SQLSelectStatementNode.parse(
						context,
						startIndex,
						No.withToken);
				case SQLToken.get!"UPDATE".name:
					throw new NotImplementedException("TODO:");
					// break;
				case SQLToken.get!"INSERT".name:
				{
					SQLTokenContent nxt;
					if(context.iterator.hasNext && (nxt = context.iterator.peekNext(Yes.skipBlankTokens)).token.name == SQLToken.get!"INTO".name)
					{
						throw new NotImplementedException("TODO:");
					}
					else
						throw new InvalidSQLParseException(
							format!"Expected INTO token but got %s"(
								(context.iterator.hasNext) ? nxt.token.name : SQLToken.get!"EOF".name),
							SQLFile.Location(context.iterator.current.startLine, context.iterator.current.startCol));
				}

				default:
					throw new InvalidSQLParseException(
						format!"Expected statement token but got %s"(cur.name),
						SQLFile.Location(context.iterator.current.startLine, context.iterator.current.startCol)
					);
			}
		}

		throw new InvalidSQLParseException(
			"Expected statement token but got EOF",
			SQLFile.Location(context.iterator.current.endLine, context.iterator.current.endCol));
	}

	override
	protected void parseAfter(TokenIterator it)
	{
		_afterComments = SQLParser.parseComments(it);

		if(it.hasNext && it.current.token.name == SQLToken.get!"SEMICOLON".name)
		{
			afterSemi = true;
			it.next();
			super.parseAfter(it);
		}
	}

	protected string dbType;
	protected bool afterSemi;
}
