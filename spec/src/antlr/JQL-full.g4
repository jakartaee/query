grammar JQLFull;

statement
    : select_statement
    | update_statement
    | delete_statement
    ;

select_statement
    : union
    ;

union
    : intersection
    | union
      ('UNION' 'ALL'? | 'EXCEPT' 'ALL'?)
      intersection
    ;

intersection
    : query_expression
    | intersection
      'INTERSECT' 'ALL'?
      query_expression
    ;

query_expression
    : select_query
    | '(' union ')'
    ;

select_query
    : select_clause?
      from_clause
      where_clause?
      groupby_clause?
      having_clause?
      orderby_clause?
    ;

update_statement
    : update_clause set_clause where_clause?
    ;

delete_statement
    : delete_clause where_clause?
    ;

from_clause
    : 'FROM' (this_implicit_variable | identification_variable_declarations)
    ;

this_implicit_variable
    : entity_name
    ;

identification_variable_declarations
    : identification_variable_declaration
      (',' identification_variable_declaration)*
    ;

identification_variable_declaration
    : range_variable_declaration
      (join | fetch_join)*
    ;

range_variable_declaration
    : entity_name
      'AS'? identification_variable
    ;

join
    : range_join
    | path_join
    ;

range_join
    : join_spec range_variable_declaration
      join_condition?
    ;

path_join
    : join_spec join_association_expression
      'AS'? identification_variable
      join_condition?
    ;

fetch_join
    : join_spec 'FETCH' join_association_expression
    ;

join_spec
    : ('INNER' | 'LEFT' 'OUTER'?)?
      'JOIN'
    ;

join_condition
    : 'ON' conditional_expression
    ;

join_association_expression
    : joinable_path_expression
    | treated_joinable_path_expression
    ;

treated_joinable_path_expression
    : 'TREAT' '(' joinable_path_expression 'AS' subtype ')'
    ;

joinable_path_expression
    // Note that unlike in derived_path_expression,
    // JPQL does not allow use of TREAT() here
    // TODO: Should we allow KEY(), VALUE() here?
    : (identification_variable '.')?
      (structure_field '.')*
      (entity_field | collection_field)
    ;

map_entry_identification_variable
    : 'ENTRY' '(' identification_variable ')'
    ;

map_keyvalue_identification_variable
    : 'KEY' '(' identification_variable ')'
    | 'VALUE' '(' identification_variable ')'
    ;

single_valued_path_expression
    : atomic_valued_path_expression
    | embeddable_valued_path_expression
    | entity_valued_path_expression
    | map_entry_identification_variable
    ;

atomic_valued_path_expression
    : (root_entity_expression '.')?
      (structure_field '.')*
      atomic_field
    | map_keyvalue_identification_variable
    ;

embeddable_valued_path_expression
    : (root_entity_expression '.')?
      (structure_field '.')*
      embedded_field
    | map_keyvalue_identification_variable
    ;

entity_valued_path_expression
    : (root_entity_expression '.')?
      (structure_field '.')*
      entity_field
    | identification_variable
    | map_keyvalue_identification_variable
    ;

collection_valued_path_expression
    : (root_entity_expression '.')?
      (structure_field '.')*
      collection_field
    ;

root_entity_expression
    : identification_variable
    | map_keyvalue_identification_variable
    | treated_entity_path_expression
    ;

treated_entity_path_expression
    : 'TREAT' '(' entity_valued_path_expression 'AS' subtype ')'
    ;

update_clause
    // TODO: Could be:
    //       'UPDATE' (this_implicit_variable | range_variable_declaration)
    : 'UPDATE' entity_name
      ('AS'? identification_variable)?
    ;

set_clause
    : 'SET' update_item (',' update_item)*
    ;

update_item
    : updatable_path_expression '=' new_value
    ;

updatable_path_expression
    // must resolve to entity or atomic type (cannot have implicit joins)
    : (identification_variable '.')?
      (embedded_field '.')*
      (atomic_field | entity_field)
    ;

new_value
    : scalar_expression
    | simple_entity_expression
    | 'NULL';

simple_entity_expression
    : identification_variable
    | single_valued_input_parameter
    ;

delete_clause
    : 'DELETE' 'FROM' entity_name
      ('AS'? identification_variable)?
    ;

select_clause
    : 'SELECT' 'DISTINCT'?
      select_item (',' select_item)*
    ;

select_item
    : select_expression
      ('AS'? result_variable)?
    ;

select_expression
    : single_valued_path_expression  // embeddables are allowed
    | scalar_expression
    | aggregate_expression
    | constructor_expression
    ;

constructor_expression
    : 'NEW' constructor_name
      '(' constructor_item (',' constructor_item)* ')'
    ;

constructor_item
    : single_valued_path_expression  // embeddables are allowed
    | scalar_expression
    | aggregate_expression
    ;

aggregate_expression
    : ('AVG' | 'MAX' | 'MIN' | 'SUM') '(' 'DISTINCT'? atomic_valued_path_expression ')'
    | 'COUNT' '(' 'DISTINCT'? (atomic_valued_path_expression | entity_valued_path_expression) ')'
    | function_invocation;

where_clause
    : 'WHERE' conditional_expression
    ;

groupby_clause
    : 'GROUP' 'BY'
      groupby_item (',' groupby_item)*
    ;

groupby_item
    : atomic_valued_path_expression
    | entity_valued_path_expression
    ;

having_clause
    : 'HAVING' conditional_expression
    ;

orderby_clause
    : 'ORDER' 'BY'
      orderby_item (',' orderby_item)*
    ;

orderby_item
    : orderby_expression
      ('ASC' | 'DESC')?
      ('NULLS' ('FIRST' | 'LAST'))?
    ;

orderby_expression
    : atomic_valued_path_expression
    | result_variable
    | scalar_expression
    ;

subquery_expression
    : '(' subquery ')'
    ;

subquery
    : simple_select_clause
      subquery_from_clause
      where_clause?
      groupby_clause?
      having_clause?
    ;

subquery_from_clause
    : 'FROM' subselect_identification_variable_declaration
      (',' subselect_identification_variable_declaration)*
    ;

subselect_identification_variable_declaration
    : identification_variable_declaration
    | derived_path_expression 'AS'? identification_variable join*
    ;

derived_path_expression
    // TODO: Is support for TREAT() here really a requirement?
    //       We don't allow it in joinable_path_expression
    // TODO: Should we allow KEY(), VALUE() here?
    : ((identification_variable | treated_entity_path_expression) '.')?
      (structure_field '.')*
      (entity_field | collection_field)
    ;

simple_select_clause
    : 'SELECT' 'DISTINCT'? simple_select_expression
    ;

simple_select_expression
    : atomic_valued_path_expression
    | entity_valued_path_expression
    | scalar_expression
    | aggregate_expression
    ;

scalar_expression
    : arithmetic_expression
    | string_expression
    | enum_expression
    | datetime_expression
    | boolean_expression
    | case_expression
    | entity_type_expression
    | entity_id_or_version_function
    ;

conditional_expression
    : conditional_term
    | conditional_expression 'OR' conditional_term
    ;

conditional_term
    : conditional_factor
    | conditional_term 'AND' conditional_factor
    ;

conditional_factor
    : 'NOT'? conditional_primary
    ;

conditional_primary
    : simple_conditional_expression
    | '(' conditional_expression ')'
    ;

simple_conditional_expression
    : comparison_expression
    | between_expression
    | in_expression
    | like_expression
    | null_comparison_expression
    | empty_collection_comparison_expression
    | collection_member_of_expression
    | exists_expression
    ;

between_expression
    : arithmetic_expression 'NOT'? 'BETWEEN' arithmetic_expression 'AND' arithmetic_expression
    | string_expression 'NOT'? 'BETWEEN' string_expression 'AND' string_expression
    | datetime_expression 'NOT'? 'BETWEEN' datetime_expression 'AND' datetime_expression
    ;

in_expression
    : (atomic_valued_path_expression | type_discriminator)  // TODO: Much too restrictive
      'NOT'? 'IN'
      (in_item_list | subquery_expression | collection_valued_input_parameter)
    ;

in_item_list
    : '(' in_item (',' in_item)* ')'
    ;

in_item
    : literal
    | enum_literal
    | entity_type_literal
    | special_boolean_expression
    | single_valued_input_parameter
    ;

like_expression
    : string_expression
      'NOT'? 'LIKE' escaped_pattern
    ;

escaped_pattern
    : pattern_value
      ('ESCAPE' escape_character)?
    ;

pattern_value
    : literal_pattern
    | single_valued_input_parameter
    ;

null_comparison_expression
    : nullable_expression
      'IS' 'NOT'? 'NULL'
    ;

nullable_expression
    : atomic_valued_path_expression
    | entity_valued_path_expression
    | single_valued_input_parameter
    ;

empty_collection_comparison_expression
    : collection_valued_path_expression
      'IS' 'NOT'? 'EMPTY'
    ;

collection_member_of_expression
    : collection_member_element_expression
      'NOT'? 'MEMBER' 'OF'?
      collection_valued_path_expression
    ;

collection_member_element_expression
    : entity_valued_path_expression
    | atomic_valued_path_expression
    | single_valued_input_parameter
    | literal
    | enum_literal
    | special_boolean_expression
    ;

exists_expression
    : 'NOT'? 'EXISTS'
      subquery_expression
    ;

all_or_any_expression
    : ('ALL' | 'ANY' | 'SOME')
      subquery_expression
    ;

comparison_expression
    : string_expression comparison_operator (string_expression | all_or_any_expression)
    | boolean_expression equality_operator (boolean_expression | all_or_any_expression)
    | enum_expression equality_operator (enum_expression | all_or_any_expression)
    | datetime_expression comparison_operator (datetime_expression | all_or_any_expression)
    | entity_expression equality_operator (entity_expression | all_or_any_expression)
    | arithmetic_expression comparison_operator (arithmetic_expression | all_or_any_expression)
    | entity_id_or_version_function equality_operator single_valued_input_parameter
    | entity_type_expression equality_operator entity_type_expression
    ;

equality_operator
    : '='
    | '<>'
    ;

comparison_operator
    : '='
    | '>'
    | '>='
    | '<'
    | '<='
    | '<>'
    ;

arithmetic_expression
    : arithmetic_term
    | arithmetic_expression ('+' | '-') arithmetic_term
    ;

arithmetic_term
    : arithmetic_factor
    | arithmetic_term ('*' | '/') arithmetic_factor
    ;

arithmetic_factor
    : ('+' | '-')? arithmetic_primary
    ;

arithmetic_primary
    : atomic_valued_path_expression
    | numeric_literal
    | '(' arithmetic_expression ')'
    | single_valued_input_parameter
    | functions_returning_numerics
    | aggregate_expression
    | case_expression
    | function_invocation
    | subquery_expression
    ;

string_expression
    : atomic_valued_path_expression
    | string_literal
    | '(' string_expression ')'
    | single_valued_input_parameter
    | functions_returning_strings
    | aggregate_expression
    | case_expression
    | function_invocation
    | string_expression '||' string_expression
    | subquery_expression
    ;

datetime_expression
    : atomic_valued_path_expression
    | single_valued_input_parameter
    | functions_returning_datetime
    | special_datetime_expression
    | aggregate_expression
    | case_expression
    | function_invocation
    | subquery_expression
    ;

boolean_expression
    : atomic_valued_path_expression
    | special_boolean_expression
    | single_valued_input_parameter
    | case_expression
    | function_invocation
    | subquery_expression
    ;

enum_expression
    : atomic_valued_path_expression
    | enum_literal
    | single_valued_input_parameter
    | case_expression
    | subquery_expression
    ;

entity_expression
    : entity_valued_path_expression
    | single_valued_input_parameter
    ;

entity_type_expression
    : type_discriminator
    | entity_type_literal
    | single_valued_input_parameter
    ;

type_discriminator
    : 'TYPE' '(' entity_valued_path_expression ')'
    ;

functions_returning_numerics
    : 'LENGTH' '(' string_expression ')'
    | 'LOCATE' '(' string_expression ',' string_expression (',' arithmetic_expression)? ')'
    | 'ABS' '(' arithmetic_expression ')'
    | 'CEILING' '(' arithmetic_expression ')'
    | 'EXP' '(' arithmetic_expression ')'
    | 'FLOOR' '(' arithmetic_expression ')'
    | 'LN' '(' arithmetic_expression ')'
    | 'SIGN' '(' arithmetic_expression ')'
    | 'SQRT' '(' arithmetic_expression ')'
    | 'MOD' '(' arithmetic_expression',' arithmetic_expression ')'
    | 'POWER' '(' arithmetic_expression',' arithmetic_expression ')'
    | 'ROUND' '(' arithmetic_expression',' arithmetic_expression ')'
    | 'SIZE' '(' collection_valued_path_expression ')'
    | 'INDEX' '(' identification_variable ')'
    | 'EXTRACT' '(' datetime_field 'FROM' datetime_expression ')'
    | 'CAST' '(' string_expression 'AS' ('INTEGER' | 'LONG' | 'FLOAT' | 'DOUBLE') ')'
    ;

functions_returning_datetime
    : 'EXTRACT' '(' datetime_part 'FROM' datetime_expression ')'
    ;

functions_returning_strings
    : 'CONCAT' '(' string_expression ',' string_expression (',' string_expression)* ')'
    | 'SUBSTRING' '(' string_expression ',' arithmetic_expression (',' arithmetic_expression)? ')'
    | 'TRIM' '(' (trim_specification? trim_character? 'FROM')? string_expression ')'
    | 'LOWER' '(' string_expression ')'
    | 'UPPER' '(' string_expression ')'
    | 'CAST' '(' scalar_expression 'AS' 'STRING' ')'
    ;

trim_specification
    : 'LEADING'
    | 'TRAILING'
    | 'BOTH'
    ;

function_invocation
    : 'FUNCTION' '(' function_name (',' scalar_expression)* ')'
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

entity_id_or_version_function
    : 'ID' '(' entity_valued_path_expression ')'
    | 'VERSION' '(' entity_valued_path_expression ')'
    ;

case_expression
    : general_case_expression
    | simple_case_expression
    | coalesce_expression
    | nullif_expression
    ;

general_case_expression
    : 'CASE' when_clause+
      'ELSE' scalar_expression
      'END'
    ;

when_clause
    : 'WHEN' conditional_expression
      'THEN' scalar_expression
    ;

simple_case_expression
    : 'CASE' case_operand simple_when_clause+
      'ELSE' scalar_expression
      'END'
    ;

case_operand
    : atomic_valued_path_expression
    | type_discriminator
    ;

simple_when_clause
    : 'WHEN' scalar_expression
      'THEN' scalar_expression
      ;

coalesce_expression
    : 'COALESCE' '(' scalar_expression (',' scalar_expression)+ ')'
    ;

nullif_expression
    : 'NULLIF' '(' scalar_expression ',' scalar_expression ')'
    ;

identification_variable : IDENTIFIER;

result_variable : IDENTIFIER;


entity_field
    : IDENTIFIER
    ;

embedded_field
    : IDENTIFIER
    ;

atomic_field
    : IDENTIFIER
    ;

collection_field
    : IDENTIFIER
    ;

structure_field
    : embedded_field
    | entity_field
    ;


datetime_field
    : IDENTIFIER
    ;

datetime_part
    : IDENTIFIER
    ;


entity_name : IDENTIFIER;

subtype : entity_name;

entity_type_literal : entity_name;


constructor_name : IDENTIFIER;


function_name : IDENTIFIER;


input_parameter : ':' IDENTIFIER | '?' INTEGER;

collection_valued_input_parameter : input_parameter;

single_valued_input_parameter : input_parameter;


literal : string_literal | numeric_literal;

numeric_literal : INTEGER | DOUBLE;

string_literal : STRING;

enum_literal : IDENTIFIER ('.' IDENTIFIER)*;


trim_character : CHARACTER;

escape_character : CHARACTER;

literal_pattern : STRING;