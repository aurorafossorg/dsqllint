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

module dsqllint.parse.ast.nodes.clause.withsubquery;

import dsqllint.parse.ast.nodes.base;
import dsqllint.parse.ast.nodes.expression.name;
import dsqllint.parse.ast.nodes.statement;
import dsqllint.parse.ast.nodes.comment;
import dsqllint.parse.ast.object;
import dsqllint.parse.ast.nodes.statement.tablesource.tablesource;
import dsqllint.parse.ast.nodes.statement.select;
import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.parser;
import dsqllint.parse.tokenize.tokens;
import dsqllint.parse.ast.context;

public class SQLWithSubqueryClause : SQLBaseNode
{
	public this()
	{}

	public static class Entry : SQLTableSourceNode
	{
		public static Entry parse(
			SQLContext context)
		{
			SQLParser.accept!"WITH"(context.iterator);
			SQLWithSubqueryClause.Entry ret = new SQLWithSubqueryClause.Entry();
			ret.parent = context.parent;

			return ret;
		}

		protected SQLName[] columns;
	protected SQLSelectNode subQuery;
	protected SQLStatement returningStatement;
	}

	public static SQLWithSubqueryClause parse(SQLContext context)
	{
		context.parseBeforeCommentsIfNull();

		SQLWithSubqueryClause ret;

		// validate WITH token
		SQLParser.accept!"WITH"(context.iterator);
		ret = new SQLWithSubqueryClause();

		if(context.iterator.current.token.name == SQLToken.get!"RECURSIVE".name)
		{
			context.iterator.next();
			ret.recursive = true;
		}

		do {
			ret.entries ~= Entry.parse(SQLContext(context.iterator, ret));
		} while(context.iterator.hasNext);

		return ret;
	}


	private bool recursive;
	private Entry[] entries;
}
