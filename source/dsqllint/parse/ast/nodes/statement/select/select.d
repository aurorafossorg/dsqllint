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

module dsqllint.parse.ast.nodes.statement.select.select;

import dsqllint.parse.ast.nodes.base;
import dsqllint.parse.ast.nodes.clause.orderby;
import dsqllint.parse.ast.nodes.expression;
import dsqllint.parse.ast.nodes.comment;
import dsqllint.parse.ast.nodes.hint.ihint;
import dsqllint.parse.ast.nodes.clause.withsubquery;
import dsqllint.parse.ast.nodes.statement.select.iquery;
import dsqllint.parse.ast.nodes.statement.statement;
import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.parser;
import dsqllint.parse.ast.object;

import aurorafw.stdx.exception;
import std.typecons;

public abstract class SQLSelectNode : SQLBaseNode
{
	//TODO:
	public this()
	{
		throw new NotImplementedException("TODO:");
	}

	public static SQLSelectNode parse(TokenIterator it, SQLWithSubqueryClause withSubQuery = null)
	{
		auto beforeComments = SQLParser.parseComments(it);
		return parse(it, beforeComments, withSubQuery);
	}

	public static SQLSelectNode parse(
		TokenIterator it,
		SQLCommentNode[] beforeComments,
		SQLWithSubqueryClause withSubQuery = null,
		SQLObject parent = null
		)
	{

		throw new NotImplementedException("Feature not implemented!");
	}

	protected SQLWithSubqueryClause withSubQuery;
	protected SQLSelectQuery query;
	protected SQLOrderByNode orderBy;

	protected SQLHint[] hints;

	protected SQLBaseNode restriction;

	protected bool forBrowse;
	protected string[] forXmlOptions = null;
	protected SQLExpression xmlPath;

	protected SQLExpression rowCount;
	protected SQLExpression offset;
}

public final class SQLSelectStatementNode : SQLStatementNode
{
	public this(SQLSelectNode select)
	{
		this.select = select;
	}

	public static SQLSelectStatementNode parse(
		TokenIterator it,
		size_t startIndex,
		Flag!"withToken" withToken,
		SQLObject parent = null)
	{
		return parse(
			it,
			startIndex,
			withToken,
			SQLParser.parseComments(it),
			parent
		);
	}

	public static SQLSelectStatementNode parse(
		TokenIterator it,
		size_t startIndex,
		Flag!"withToken" withToken,
		SQLCommentNode[] beforeComments,
		SQLObject parent = null)
	{
		SQLSelectNode select;
		if(withToken)
		{
			SQLWithSubqueryClause withSubQuery = SQLWithSubqueryClause.parse(it, beforeComments);
			select = SQLSelectNode.parse(it, withSubQuery);
		}
		else
			select = SQLSelectNode.parse(it, beforeComments);

		auto ret = new SQLSelectStatementNode(select);
		ret.parent = parent;
		select.parent = ret;
		ret.beforeComments = beforeComments;
		SQLStatementNode.parseAfter(it, ret);
		ret.tokens = it.tokens[startIndex .. it.index];

		return ret;
	}

	protected SQLSelectNode select;
}
