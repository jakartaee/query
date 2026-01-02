grammar JCQL;

statement : select_statement | update_statement | delete_statement;

select_statement : select_clause? from_clause? where_clause? orderby_clause?;
update_statement : update_clause set_clause where_clause?;
delete_statement : delete_clause where_clause?;

from_clause : 'FROM' this_implicit_variable;
this_implicit_variable : entity_name;

where_clause : 'WHERE' conditional_expression;

update_clause : 'UPDATE' entity_name;
set_clause : 'SET' update_item (',' update_item)*;
update_item : simple_path_expression '=' new_value;
new_value
    : scalar_expression
    | 'NULL'
    ;

delete_clause : 'DELETE' 'FROM' entity_name;

select_clause : 'SELECT' (select_item | select_items);
select_item
    : simple_path_expression
    | id_expression
    | aggregate_expression
    ;
select_items
    : simple_path_expression (',' simple_path_expression)+
    ;

orderby_clause : 'ORDER' 'BY' orderby_item (',' orderby_item)*;
orderby_item : orderby_expression ('ASC' | 'DESC');
orderby_expression
    : simple_path_expression
    | id_expression
    ;

conditional_expression
    // highest to lowest precedence
    : '(' conditional_expression ')'
    | null_comparison_expression
    | in_expression
    | between_expression
    | like_expression
    | comparison_expression
    | 'NOT' conditional_expression
    | conditional_expression 'AND' conditional_expression
    | conditional_expression 'OR' conditional_expression
    ;

comparison_expression : scalar_expression comparison_operator scalar_expression;
between_expression : scalar_expression 'NOT'? 'BETWEEN' scalar_expression 'AND' scalar_expression;
like_expression : scalar_expression 'NOT'? 'LIKE' escaped_pattern;

comparison_operator
    : '='
    | '>'
    | '>='
    | '<'
    | '<='
    | '<>'
    ;

escaped_pattern
    : literal_pattern
      ('ESCAPE' escape_character)?
    ;

in_expression : simple_path_expression 'NOT'? 'IN' in_item_list;
in_item_list : '(' in_item (',' in_item)* ')' ;
in_item : literal | enum_literal | input_parameter;

null_comparison_expression : simple_path_expression 'IS' 'NOT'? 'NULL';

scalar_expression
    // highest to lowest precedence
    : '(' scalar_expression ')'
    | primary_expression
    | ('+' | '-') scalar_expression
    | scalar_expression ('*' | '/') scalar_expression
    | scalar_expression ('+' | '-') scalar_expression
    | scalar_expression '||' scalar_expression
    ;

primary_expression
    : function_expression
    | special_expression
    | id_expression
    | simple_path_expression
    | enum_literal
    | input_parameter
    | literal
    ;

id_expression : 'ID' '(' 'THIS' ')' ;

aggregate_expression : 'COUNT' '(' 'THIS' ')';

function_expression
    : 'ABS' '(' scalar_expression ')'
    | 'LENGTH' '(' scalar_expression ')'
    | 'LOWER' '(' scalar_expression ')'
    | 'UPPER' '(' scalar_expression ')'
    | 'LEFT' '(' scalar_expression ',' scalar_expression ')'
    | 'RIGHT' '(' scalar_expression ',' scalar_expression ')'
    ;

special_expression
    : special_boolean_expression
    | special_datetime_expression
    ;

special_boolean_expression
    : 'TRUE'
    | 'FALSE'
    ;

special_datetime_expression
    : 'LOCAL' 'DATE'
    | 'LOCAL' 'TIME'
    | 'LOCAL' 'DATETIME'
    ;

simple_path_expression : IDENTIFIER ('.' IDENTIFIER)*;

entity_name : IDENTIFIER; // no ambiguity

enum_literal : IDENTIFIER ('.' IDENTIFIER)*; // ambiguity with simple_path_expression resolvable semantically

input_parameter : ':' IDENTIFIER | '?' INTEGER;

literal : string_literal | numeric_literal;

numeric_literal : INTEGER | DOUBLE;

string_literal : STRING;

literal_pattern : STRING;

escape_character : CHARACTER;

