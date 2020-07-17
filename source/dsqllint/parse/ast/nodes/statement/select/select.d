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
import dsqllint.parse.ast.nodes.hint.hint;
import dsqllint.parse.ast.nodes.clause.withsubquery;
import dsqllint.parse.ast.nodes.statement.select.iquery;
import dsqllint.parse.ast.nodes.statement.statement;
import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.parser;
import dsqllint.parse.ast.object;
import dsqllint.parse.ast.context;
import dsqllint.parse.ast.visitor;

import aurorafw.stdx.exception;
import std.typecons;

public abstract class SQLSelectNode : SQLBaseNode
{
	//TODO:
	public this()
	{
		throw new NotImplementedException("TODO:");
	}

	///
	override
	protected void accept0(SQLASTVisitor visitor)
	{
        if (visitor.visit(this))
		{
            acceptChild(visitor, withSubQuery);
            acceptChild(visitor, query);
            acceptChild(visitor, restriction);
            acceptChild(visitor, orderBy);

            acceptChild!SQLHint(visitor, hints);

            acceptChild(visitor, offset);
            acceptChild(visitor, rowCount);
        }

        visitor.endVisit(this);
    }

	public static SQLSelectNode parse(
		SQLContext context,
		SQLWithSubqueryClause withSubQuery = null,
		)
	{
		context.parseBeforeCommentsIfNull();

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

	///
	override
	protected void accept0(SQLASTVisitor visitor)
	{
        if (visitor.visit(this))
            acceptChild(visitor, select);

        visitor.endVisit(this);
    }

	public static SQLSelectStatementNode parse(
		SQLContext context,
		size_t startIndex,
		Flag!"withToken" withToken)
	{
		context.parseBeforeCommentsIfNull();

		SQLSelectNode select;
		if(withToken)
		{
			SQLWithSubqueryClause withSubQuery = SQLWithSubqueryClause.parse(SQLContext(context.iterator, null, context.beforeComments));
			select = SQLSelectNode.parse(SQLContext(context.iterator), withSubQuery);
			withSubQuery.parent = select;
		}
		else
		{
			select = SQLSelectNode.parse(SQLContext(context.iterator, null, context.beforeComments));
		}

		auto ret = new SQLSelectStatementNode(select);
		select.parent = ret;

		ret.applyContext(context);
		ret.parseAfter(context.iterator);
		ret.applyTokens(startIndex, context.iterator);

		return ret;
	}

	protected SQLSelectNode select;
}
