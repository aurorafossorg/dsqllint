project('dsqllint', 'd',
	meson_version: '>=0.49.0',
	version: '0.0.1',
	license: 'LGPL-3.0')

d_dsqllint_inc = include_directories('source')

d_dsqllint_src = [
	'source/dsqllint/app.d',
	'source/dsqllint/utils/message.d',
	'source/dsqllint/utils/printer.d',
	'source/dsqllint/parse/tokenize/package.d',
	'source/dsqllint/parse/tokenize/iterator.d',
	'source/dsqllint/parse/tokenize/tokens.d',
	'source/dsqllint/parse/tokenize/tok.d',
	'source/dsqllint/parse/ast/package.d',
	'source/dsqllint/parse/ast/models/replacable.d',
	'source/dsqllint/parse/ast/models/orderspec.d',
	'source/dsqllint/parse/ast/visitor.d',
	'source/dsqllint/parse/ast/tree.d',
	'source/dsqllint/parse/ast/object.d',
	'source/dsqllint/parse/ast/nodes/datatype/idatatype.d',
	'source/dsqllint/parse/ast/nodes/datatype/package.d',
	'source/dsqllint/parse/ast/nodes/datatype/node.d',
	'source/dsqllint/parse/ast/nodes/datatype/array.d',
	'source/dsqllint/parse/ast/nodes/datatype/map.d',
	'source/dsqllint/parse/ast/nodes/argument.d',
	'source/dsqllint/parse/ast/nodes/statement/tablesource/itablesource.d',
	'source/dsqllint/parse/ast/nodes/statement/tablesource/tablesource.d',
	'source/dsqllint/parse/ast/nodes/statement/package.d',
	'source/dsqllint/parse/ast/nodes/statement/sequence.d',
	'source/dsqllint/parse/ast/nodes/statement/tableelement.d',
	'source/dsqllint/parse/ast/nodes/statement/statement.d',
	'source/dsqllint/parse/ast/nodes/statement/select/package.d',
	'source/dsqllint/parse/ast/nodes/statement/select/select.d',
	'source/dsqllint/parse/ast/nodes/statement/select/orderbyitem.d',
	'source/dsqllint/parse/ast/nodes/statement/select/iquery.d',
	'source/dsqllint/parse/ast/nodes/hint/ihint.d',
	'source/dsqllint/parse/ast/nodes/comment.d',
	'source/dsqllint/parse/ast/nodes/limit.d',
	'source/dsqllint/parse/ast/nodes/base.d',
	'source/dsqllint/parse/ast/nodes/parameter.d',
	'source/dsqllint/parse/ast/nodes/expression/package.d',
	'source/dsqllint/parse/ast/nodes/expression/expression.d',
	'source/dsqllint/parse/ast/nodes/expression/name.d',
	'source/dsqllint/parse/ast/nodes/clause/orderby.d',
	'source/dsqllint/parse/ast/nodes/clause/withsubquery.d',
	'source/dsqllint/parse/ast/nodes/declareitem.d',
	'source/dsqllint/parse/ast/nodes/keep.d',
	'source/dsqllint/parse/lexer.d',
	'source/dsqllint/parse/parser.d',
	'source/dsqllint/parse/file.d'
]

aurorafw_stdx_dep = dependency('aurorafw:stdx', method: 'dub')

d_dsqllint_exe = executable('dsqllint',
	d_dsqllint_src,
	include_directories: [d_dsqllint_inc],
	dependencies: [
		aurorafw_stdx_dep,
	],
	install: true,
)
