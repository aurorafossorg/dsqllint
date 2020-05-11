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

module dsqllint.parse.ast.nodes.base;

import dsqllint.parse.ast.nodes.comment;
import dsqllint.parse.ast.visitor;
import dsqllint.parse.ast.object;
import dsqllint.parse.ast.context;
import dsqllint.parse.tokenize.tok;
import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.parser;

import std.algorithm : map, joiner;
import std.array;

abstract class SQLBaseNode : SQLObject
{
	// protected this(const(SQLBaseNode) obj)
	// {
	//     this.parent = obj.parent;
	//     this.toks = obj.toks;
	// }

	// SQLBaseNode dup() const
	// {
	//     return new SQLBaseNode(this);
	// }

	public @property SQLObject parent()
	{
		return _parent;
	}

	protected @property void parent(SQLObject parent)
	{
		this._parent = parent;
	}

	public const(SQLTokenContent)[] tokens() @property
	{
		return _toks;
	}

	protected void tokens(const(SQLTokenContent)[] tokens) @property
	{
		_toks = tokens;
	}

	public void accept(SQLASTVisitor visitor) const
	{
		// visitor.preVisit(this);
		// accept0(visitor);
		// visitor.postVisit(this);
	}

	// protected abstract void accept0(SQLASTVisitor visitor) const;

	override public string toString() const
	{
		return _toks.map!(t => t.content).join;
	}

	public bool hasBeforeComment() const @property
	{
		return !_beforeComments.empty;
	}

	public bool hasAfterComment() const @property
	{
		return !_afterComments.empty;
	}

	public SQLCommentNode[] beforeComments() @property
	{
		return _beforeComments;
	}

	public SQLCommentNode[] afterComments() @property
	{
		return _afterComments;
	}

	protected void beforeComments(SQLCommentNode[] val) @property
	{
		_beforeComments = val;
	}

	protected void afterComments(SQLCommentNode[] val) @property
	{
		_afterComments = val;
	}

	protected void applyContext(SQLContext context)
	{
		parent = context.parent;
		_beforeComments = context.beforeComments;
	}

	protected void parseAfter(TokenIterator it)
	{
		_afterComments = (_afterComments == null)
			? SQLParser.parseComments(it)
			: _afterComments ~ SQLParser.parseComments(it);
	}

	protected void applyTokens(size_t startIndex, TokenIterator it)
	{
		_toks = it.tokens[startIndex .. it.index];
	}

	protected SQLObject _parent;
	protected const(SQLTokenContent)[] _toks;
	protected SQLCommentNode[] _beforeComments;
	protected SQLCommentNode[] _afterComments;
}
