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

module dsqllint.parse.tokenize.tokens;

import dsqllint.parse.tokenize.tok;

import std.algorithm.iteration : uniq, filter;
import std.algorithm.searching : any;
import std.typecons : tuple;
import std.array : array;
import std.exception;

version(unittest) import aurorafw.unit.assertion;

@safe pure
struct SQLToken {
	static immutable spec = [
		// Special tokens
		sqlTokDec!("WHITESPACE", `(\s+)`, ""),
		sqlTokDec!("LINE_COMMENT", `(--.*)`),
		sqlTokDec!("MULTI_LINE_COMMENT", `((/\*)+?[\w\W]+?(\*/))`, ""),

		// DQL keywords
		sqlTokDecStatement!("SELECT"),

		// DML keywords
		sqlTokDecWord!("INSERT", SQLTokType.Statement | SQLTokType.Keyword),
		sqlTokDecStatement!("UPDATE"),
		sqlTokDecStatement!("DELETE"),

		// DDL keywords
		sqlTokDecStatement!("CREATE"),
		sqlTokDecStatement!("ALTER"),
		sqlTokDecStatement!("DROP"),

		// DDL Related Tokens (keywords)
		sqlTokDecWord!("PRIMARY"),
		sqlTokDecWord!("KEY"),
		sqlTokDecWord!("DEFAULT"),
		sqlTokDecWord!("CONSTRAINT"),
		sqlTokDecWord!("CHECK"),
		sqlTokDecWord!("UNIQUE"),
		sqlTokDecWord!("FOREIGN"),
		sqlTokDecWord!("REFERENCES"),

		// DCL keywords
		sqlTokDecWord!("GRANT"),
		sqlTokDecWord!("REVOKE"),

		// DTL keywords
		sqlTokDecWord!("COMMIT"),
		sqlTokDecWord!("ROLLBACK"),

		// Clauses keywords
		sqlTokDecWord!("FROM"),
		sqlTokDecWord!("HAVING"),
		sqlTokDecWord!("WHERE"),
		sqlTokDecWord!("ORDER"),
		sqlTokDecWord!("BY"),
		sqlTokDecWord!("GROUP"),

		// Logical operators keywords
		sqlTokDecWord!("NOT"),
		sqlTokDecWord!("AND"),
		sqlTokDecWord!("OR"),
		sqlTokDecWord!("XOR"),

		// Syntax tokens
		sqlTokDecWord!("SET"),
		sqlTokDecWord!("INTO"),
		sqlTokDecWord!("AS"),
		sqlTokDecWord!("DISTINCT"),
		sqlTokDecWord!("TABLE"),
		sqlTokDecWord!("TABLESPACE"),
		sqlTokDecWord!("VIEW"),
		sqlTokDecWord!("SEQUENCE"),
		sqlTokDecWord!("TRIGGER"),
		sqlTokDecWord!("USER"),
		sqlTokDecWord!("INDEX"),
		sqlTokDecWord!("SESSION"),
		sqlTokDecWord!("PROCEDURE"),
		sqlTokDecWord!("FUNCTION"),
		sqlTokDecWord!("EXPLAIN"),
		sqlTokDecWord!("FOR"),
		sqlTokDecWord!("IF"),
		sqlTokDecWord!("SORT"),
		sqlTokDecWord!("ALL"),
		sqlTokDecWord!("UNION"),
		sqlTokDecWord!("EXCEPT"),
		sqlTokDecWord!("INTERSECT"),
		sqlTokDecWord!("MINUS"),
		sqlTokDecWord!("INNER"),
		sqlTokDecWord!("LEFT"),
		sqlTokDecWord!("RIGHT"),
		sqlTokDecWord!("FULL"),
		sqlTokDecWord!("OUTER"),
		sqlTokDecWord!("JOIN"),
		sqlTokDecWord!("ON"),
		sqlTokDecWord!("SCHEMA"),
		sqlTokDecWord!("CAST"),
		sqlTokDecWord!("COLUMN"),
		sqlTokDecWord!("USE"),
		sqlTokDecWord!("DATABASE"),
		sqlTokDecWord!("TO"),
		sqlTokDecWord!("CASE"),
		sqlTokDecWord!("WHEN"),
		sqlTokDecWord!("THEN"),
		sqlTokDecWord!("ELSE"),
		sqlTokDecWord!("ELSIF"),
		sqlTokDecWord!("END"),
		sqlTokDecWord!("EXISTS"),
		sqlTokDecWord!("IN"),
		sqlTokDecWord!("CONTAINS"),
		sqlTokDecWord!("RLIKE"),
		sqlTokDecWord!("FULLTEXT"),
		sqlTokDecWord!("NEW"),
		sqlTokDecWord!("ASC"),
		sqlTokDecWord!("DESC"),
		sqlTokDecWord!("IS"),
		sqlTokDecWord!("LIKE"),
		sqlTokDecWord!("ESCAPE"),
		sqlTokDecWord!("BETWEEN"),
		sqlTokDecWord!("VALUES"),
		sqlTokDecWord!("INTERVAL"),
		sqlTokDecWord!("LOCK"),
		sqlTokDecWord!("SOME"),
		sqlTokDecWord!("ANY"),
		sqlTokDecWord!("TRUNCATE"),
		sqlTokDecWord!("RETURN"),
		sqlTokDecWord!("LIMIT"),
		sqlTokDecWord!("KILL"),
		sqlTokDecWord!("IDENTIFIED"),
		sqlTokDecWord!("PASSWORD"),
		sqlTokDecWord!("ALGORITHM"),
		sqlTokDecWord!("DUAL"),
		sqlTokDecWord!("BINARY"),
		sqlTokDecWord!("SHOW"),
		sqlTokDecWord!("REPLACE"),
		sqlTokDecWord!("BITS"),
		sqlTokDecWord!("WHILE"),
		sqlTokDecWord!("DO"),
		sqlTokDecWord!("LEAVE"),
		sqlTokDecWord!("ITERATE"),
		sqlTokDecWord!("REPEAT"),
		sqlTokDecWord!("UNTIL"),
		sqlTokDecWord!("OPEN"),
		sqlTokDecWord!("CLOSE"),
		sqlTokDecWord!("OUT"),
		sqlTokDecWord!("INOUT"),
		sqlTokDecWord!("EXIT"),
		sqlTokDecWord!("UNDO"),
		sqlTokDecWord!("SQLSTATE"),
		sqlTokDecWord!("CONDITION"),
		sqlTokDecWord!("DIV"),
		sqlTokDecWord!("WINDOW"),
		sqlTokDecWord!("OFFSET"),
		sqlTokDecWord!("ROW"),
		sqlTokDecWord!("ROWS"),
		sqlTokDecWord!("ONLY"),
		sqlTokDecWord!("FIRST"),
		sqlTokDecWord!("NEXT"),
		sqlTokDecWord!("FETCH"),
		sqlTokDecWord!("OF"),
		sqlTokDecWord!("SHARE"),
		sqlTokDecWord!("NOWAIT"),
		sqlTokDecWord!("RECURSIVE"),
		sqlTokDecWord!("TEMPORARY"),
		sqlTokDecWord!("TEMP"),
		sqlTokDecWord!("UNLOGGED"),
		sqlTokDecWord!("RESTART"),
		sqlTokDecWord!("IDENTITY"),
		sqlTokDecWord!("CONTINUE"),
		sqlTokDecWord!("CASCADE"),
		sqlTokDecWord!("RESTRICT"),
		sqlTokDecWord!("USING"),
		sqlTokDecWord!("CURRENT"),
		sqlTokDecWord!("RETURNING"),
		sqlTokDecWord!("COMMENT"),
		sqlTokDecWord!("OVER"),
		sqlTokDecWord!("TYPE"),
		sqlTokDecWord!("ILIKE"),
		sqlTokDecWord!("START"),
		sqlTokDecWord!("PRIOR"),
		sqlTokDecWord!("CONNECT"),
		sqlTokDecWord!("WITH", SQLTokType.Statement | SQLTokType.Keyword),
		sqlTokDecWord!("EXTRACT"),
		sqlTokDecWord!("CURSOR"),
		sqlTokDecWord!("MODEL"),
		sqlTokDecWord!("MERGE"),
		sqlTokDecWord!("MATCHED"),
		sqlTokDecWord!("ERRORS"),
		sqlTokDecWord!("REJECT"),
		sqlTokDecWord!("UNLIMITED"),
		sqlTokDecWord!("BEGIN"),
		sqlTokDecWord!("EXCLUSIVE"),
		sqlTokDecWord!("MODE"),
		sqlTokDecWord!("WAIT"),
		sqlTokDecWord!("ADVISE"),
		sqlTokDecWord!("SYSDATE"),
		sqlTokDecWord!("DECLARE"),
		sqlTokDecWord!("EXCEPTION"),
		sqlTokDecWord!("LOOP"),
		sqlTokDecWord!("GOTO"),
		sqlTokDecWord!("SAVEPOINT"),
		sqlTokDecWord!("CROSS"),
		sqlTokDecWord!("PCTFREE"),
		sqlTokDecWord!("INITRANS"),
		sqlTokDecWord!("MAXTRANS"),
		sqlTokDecWord!("INITIALLY"),
		sqlTokDecWord!("ENABLE"),
		sqlTokDecWord!("DISABLE"),
		sqlTokDecWord!("SEGMENT"),
		sqlTokDecWord!("CREATION"),
		sqlTokDecWord!("IMMEDIATE"),
		sqlTokDecWord!("DEFERRED"),
		sqlTokDecWord!("STORAGE"),
		sqlTokDecWord!("MINEXTENTS"),
		sqlTokDecWord!("MAXEXTENTS"),
		sqlTokDecWord!("MAXSIZE"),
		sqlTokDecWord!("PCTINCREASE"),
		sqlTokDecWord!("FLASH_CACHE"),
		sqlTokDecWord!("CELL_FLASH_CACHE"),
		sqlTokDecWord!("NONE"),
		sqlTokDecWord!("LOB"),
		sqlTokDecWord!("STORE"),
		sqlTokDecWord!("CHUNK"),
		sqlTokDecWord!("CACHE"),
		sqlTokDecWord!("NOCACHE"),
		sqlTokDecWord!("LOGGING"),
		sqlTokDecWord!("NOCOMPRESS"),
		sqlTokDecWord!("KEEP_DUPLICATES"),
		sqlTokDecWord!("EXCEPTIONS"),
		sqlTokDecWord!("PURGE"),
		sqlTokDecWord!("COMPUTE"),
		sqlTokDecWord!("ANALYZE"),
		sqlTokDecWord!("OPTIMIZE"),
		sqlTokDecWord!("TOP"),
		sqlTokDecWord!("ARRAY"),
		sqlTokDecWord!("DISTRIBUTE"),

		//TODO:
		// Syntax literals
		sqlTokDec!("TRUE", `(TRUE)[^_a-zA-Z0-9]*`, "i", SQLTokType.Keyword),
		sqlTokDec!("FALSE", `(FALSE)[^_a-zA-Z0-9]*`, "i", SQLTokType.Keyword),
		sqlTokDec!("NULL", `(NULL)[^_a-zA-Z0-9]*`, "i", SQLTokType.Keyword),

		sqlTokDec!(
			"IDENTIFIER",
			`([_a-zA-Z][_a-zA-Z0-9]*)`,
			"",
			SQLTokType.Word | SQLTokType.Other
		),

		// Logical operators symbols
		sqlTokDec!("EQEQ",`(==)`),
		sqlTokDec!("LTEQGT", `(\<\=\>)`),
		sqlTokDec!("LTEQ",`(<=)`),
		sqlTokDec!("LTGT",`(<>)`),
		sqlTokDec!("GTEQ",`(>=)`),
		sqlTokDec!("EQGT", `(\=\>)`),

		sqlTokDec!("EQ",`(=)`),

		sqlTokDec!("LTLT", `(\<\<)`),
		sqlTokDec!("LT_MONKEYS_AT", `(\<\@)`),
		sqlTokDec!("GTGT", `(\>\>)`),

		sqlTokDec!("GT",`(>)`),
		sqlTokDec!("LT",`(<)`),

		//TODO: Implement literals https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/ef/language-reference/literals-entity-sql
		sqlTokDec!("LITERAL_HEX", `(0x[1-9A-F]+)`, "i"), //FIXME:
		sqlTokDec!("LITERAL_FLOAT", `([0-9]*[.][0-9]+)`),
		sqlTokDec!("LITERAL_INT", `([0-9]+)`), //FIXME:
		//LITERAL_OCTAL = `^0[1-7][0-7]*`

		//TODO: Deal with escape chars
		sqlTokDec!("LITERAL_STRING", `((\'[\w\W]*?\')|(\"[\w\W]*?\"))`, ""),

		// Syntax symbols
		sqlTokDec!("LCURLY", `(\{)`),
		sqlTokDec!("RCURLY", `(\})`),
		sqlTokDec!("LPAREN", `(\()`),
		sqlTokDec!("RPAREN", `(\))`),
		sqlTokDec!("LBRACKET", `(\[)`),
		sqlTokDec!("RBRACKET", `(\])`),

		sqlTokDec!("SEMICOLON", `(;)`),
		sqlTokDec!("COMMA", `(,)`),
		sqlTokDec!("DOT", `(\.)`),
		sqlTokDec!("STAR",`(\*)`),

		sqlTokDec!("BANGBANG", `(\!\!)`),
		sqlTokDec!("BANG_TILDE_STAR", `(\!\~\*)`),
		sqlTokDec!("BANG_TILDE", `(\!\~)`),
		sqlTokDec!("BANGEQ", `(\!\=)`),
		sqlTokDec!("BANGGT", `(\!\>)`),
		sqlTokDec!("BANGLT", `(\!\<)`),
		sqlTokDec!("BANG", `(\!)`),

		sqlTokDec!("TILDE_STAR", `(\~\*)`),
		sqlTokDec!("TILDE_EQ", `(\~\=)`),
		sqlTokDec!("TILDE", `(\~)`),

		sqlTokDec!("QUESBAR", `(\?\|)`),
		sqlTokDec!("QUESAMP", `(\?\&)`),
		sqlTokDec!("QUESQUES", `(\?\?)`),
		sqlTokDec!("QUES", `(\?)`),

		sqlTokDec!("COLONEQ", `(\:\=)`),
		sqlTokDec!("COLONCOLON", `(\:\:)`),
		sqlTokDec!("COLON", `(\:)`),

		sqlTokDec!("AMPAMP", `(\&\&)`),
		sqlTokDec!("AMP", `(\&)`),

		sqlTokDec!("BARBARSLASH", `(\|\|\/)`),
		sqlTokDec!("BARBAR", `(\|\|)`),
		sqlTokDec!("BARSLASH", `(\|\/)`),
		sqlTokDec!("BAR", `(\|)`),

		sqlTokDec!("PLUS", `(\+)`),
		sqlTokDec!("SUBGT", `(\-\>)`),
		sqlTokDec!("SUB", `(\-)`),

		sqlTokDec!("SLASH", `(\/)`),
		sqlTokDec!("CARETEQ", `(\^\=)`),
		sqlTokDec!("CARET", `(\^)`),
		sqlTokDec!("PERCENT", `(\%)`),

		sqlTokDec!("MONKEYS_AT_AT", `(\@\@)`),
		sqlTokDec!("MONKEYS_AT_GT", `(\@\>)`),
		sqlTokDec!("MONKEYS_AT", `(\@)`),

		sqlTokDec!("POUNDGTGT", `(\#\>\>)`),
		sqlTokDec!("POUNDGT", `(\#\>)`),
		sqlTokDec!("POUND", `(\#)`),

//     DOTDOT = "..",
//     DOTDOTDOT = "..,",
//     LT_SUB_GT = "<->",
//     SUBGTGT = "->>",

//     HINT = "HINT",
//     VARIANT = "VARIANT",
//     LITERAL_CHARS = "LITERAL_CHARS",
//     LITERAL_NCHARS = "LITERAL_NCHARS",

//     LITERAL_ALIAS = "LITERAL_ALIAS",
//     MULTI_LINE_COMMENT = "MULTI_LINE_COMMENT",

//     PARTITION = "PARTITION",
//     PARTITIONED = "PARTITIONED",
//     OVERWRITE = "OVERWRITE",

//     SEL = "SEL",
//     LOCKING = "LOCKING",
//     ACCESS = "ACCESS",
//     VOLATILE = "VOLATILE",
//     MULTISET = "MULTISET",
//     POSITION = "POSITION",
//     RANGE_N = "RANGE_N",
//     FORMAT = "FORMAT",
//     QUALIFY = "QUALIFY",
//     MOD = "MOD",

//     CONCAT = "CONCAT",

//     UPSERT = "UPSERT",

//     LPAREN = " = ",
//     //RPAREN = "",

		sqlTokDecSpecial!("EOF"),
		sqlTokDecSpecial!("ERROR"),
	].uniq!"a.assertSame(b)".array;


	@safe pure
	static template get(string name)
	{
		auto apply(string name)
		{
			foreach(t; spec)
				if(t.name == name)
					return t;

			assert(0, "Unknown token name!");
		}

		enum get = apply(name);
	}
}

@safe pure
@("Tokens: get")
unittest {
	// alias
	enum tokName = "WHITESPACE";
	enum _tokDec = sqlTokDec!("WHITESPACE", `(\s+)`, "");

	import std.range : front;
	auto frontToken = SQLToken.spec.front;

	assertEquals(SQLToken.get!tokName, frontToken);
	assertEquals(tokName, frontToken.name);

	assertEquals(_tokDec, frontToken);
	assertEquals(_tokDec, SQLToken.get!tokName);
}
