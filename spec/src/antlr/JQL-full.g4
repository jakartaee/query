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
    : select_query | '(' union ')'
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
    : update_clause where_clause?
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
      (',' (identification_variable_declaration | collection_member_declaration))*
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
    : join_spec join_association_path_expression
      'AS'? identification_variable
      join_condition?
    ;

fetch_join
    : join_spec 'FETCH' join_association_path_expression
    ;

join_spec
    : ('INNER' | 'LEFT' 'OUTER'?)?
      'JOIN'
    ;

join_condition
    : 'ON' conditional_expression
    ;

join_association_path_expression
    : join_collection_valued_path_expression
    | join_single_valued_path_expression
    | 'TREAT' '(' join_collection_valued_path_expression 'AS' subtype ')'
    | 'TREAT' '(' join_single_valued_path_expression 'AS' subtype ')'
    ;

join_collection_valued_path_expression
    : (identification_variable '.')?
      (single_valued_embeddable_object_field '.')*
      collection_valued_field
    ;

join_single_valued_path_expression
    : (identification_variable '.')?
      (single_valued_embeddable_object_field '.')*
      single_valued_object_field
    ;

// deprecated
collection_member_declaration
    : 'IN' '(' collection_valued_path_expression ')'
      'AS'? identification_variable
    ;

qualified_identification_variable
    : map_field_identification_variable
    | 'ENTRY' '(' identification_variable ')'
    ;

map_field_identification_variable
    : 'KEY' '(' identification_variable ')'
    | 'VALUE' '(' identification_variable ')';

single_valued_path_expression
    : qualified_identification_variable
    | 'TREAT' '(' qualified_identification_variable 'AS' subtype ')'
    | state_field_path_expression
    | single_valued_object_path_expression
    ;

general_identification_variable
    : identification_variable
    | map_field_identification_variable
    ;

general_subpath
    : simple_subpath
    | treated_subpath
      ('.' single_valued_object_field)*
    ;

simple_subpath
    : general_identification_variable
      ('.' single_valued_object_field)*
    ;

treated_subpath
    : 'TREAT' '(' general_subpath 'AS' subtype ')'
    ;

state_field_path_expression
    : (general_subpath '.')?
      state_field
    ;

state_valued_path_expression
    : state_field_path_expression
    | general_identification_variable
    ;

single_valued_object_path_expression
    : general_subpath.single_valued_object_field
    ;

collection_valued_path_expression
    : general_subpath
      '.' collection_valued_field
    ;

update_clause
    : 'UPDATE' entity_name
      ('AS'? identification_variable)?
      'SET' update_item (',' update_item)*
    ;

update_item
    : identification_variable '.'?
      (single_valued_embeddable_object_field '.')*
      (state_field | single_valued_object_field)
      '=' new_value
    ;

new_value
    : scalar_expression
    | simple_entity_expression
    | 'NULL';

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
    : single_valued_path_expression
    | scalar_expression
    | aggregate_expression
    | identification_variable
    | 'OBJECT' '(' identification_variable ')'  //deprecated
    | constructor_expression
    ;

constructor_expression
    : 'NEW' constructor_name
      '(' constructor_item (',' constructor_item)* ')'
    ;

constructor_item
    : single_valued_path_expression
    | scalar_expression
    | aggregate_expression
    | identification_variable
    ;

aggregate_expression
    : ('AVG' | 'MAX' | 'MIN' | 'SUM')
      '(' 'DISTINCT'? state_valued_path_expression ')'
    | 'COUNT'
      '(' 'DISTINCT'?
      ( identification_variable
      | state_valued_path_expression
      | single_valued_object_path_expression
      ) ')'
    | function_invocation;

where_clause
    : 'WHERE' conditional_expression
    ;

groupby_clause
    : 'GROUP' 'BY'
      groupby_item (',' groupby_item)*
    ;

groupby_item
    : single_valued_path_expression
    | identification_variable
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
    : state_field_path_expression
    | general_identification_variable
    | result_variable
    | scalar_expression
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
      (',' subselect_identification_variable_declaration | collection_member_declaration)*
    ;

subselect_identification_variable_declaration
    : identification_variable_declaration
    | derived_path_expression 'AS'? identification_variable join*
    | derived_collection_member_declaration
    ;

derived_path_expression
    : general_derived_path '. 'single_valued_object_field
    | general_derived_path '.' collection_valued_field
    ;

general_derived_path
    : simple_derived_path
    | treated_derived_path
      ('.' single_valued_object_field)*
    ;

simple_derived_path
    : superquery_identification_variable
      ('.' single_valued_object_field)*
    ;

treated_derived_path
    : 'TREAT' '(' general_derived_path 'AS' subtype ')'
    ;

derived_collection_member_declaration
    : 'IN' superquery_identification_variable '.'
      (single_valued_object_field '.')*
      collection_valued_field
    ;

simple_select_clause
    : 'SELECT' 'DISTINCT'? simple_select_expression
    ;

simple_select_expression
    : single_valued_path_expression
    | scalar_expression
    | aggregate_expression
    | identification_variable
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
    : simple_cond_expression
    | '(' conditional_expression ')'
    ;

simple_cond_expression
    : comparison_expression
    | between_expression
    | in_expression
    | like_expression
    | null_comparison_expression
    | empty_collection_comparison_expression
    | collection_member_expression
    | exists_expression
    ;

between_expression
    : arithmetic_expression 'NOT'? 'BETWEEN' arithmetic_expression 'AND' arithmetic_expression
    | string_expression 'NOT'? 'BETWEEN' string_expression 'AND' string_expression
    | datetime_expression 'NOT'? 'BETWEEN' datetime_expression 'AND' datetime_expression
    ;

in_expression
    : (state_valued_path_expression | type_discriminator)
      'NOT'? 'IN'
      ( '(' in_item (',' in_item)* ')'
      | '(' subquery ')'
      | collection_valued_input_parameter
      )
    ;

in_item
    : literal
    | single_valued_input_parameter
    ;

like_expression
    : string_expression
      'NOT'? 'LIKE' pattern_value
      ('ESCAPE' escape_character)?
    ;

null_comparison_expression
    : (single_valued_path_expression | input_parameter)
      'IS' 'NOT'? 'NULL'
    ;

empty_collection_comparison_expression
    : collection_valued_path_expression
      'IS' 'NOT'? 'EMPTY'
    ;

collection_member_expression
    : entity_or_value_expression
      'NOT'? 'MEMBER' 'OF'?
      collection_valued_path_expression
    ;

entity_or_value_expression
    : single_valued_object_path_expression
    | state_field_path_expression
    | simple_entity_or_value_expression
    ;

simple_entity_or_value_expression
    : identification_variable
    | input_parameter
    | literal
    ;

exists_expression
    : 'NOT'? 'EXISTS'
      '(' subquery ')'
    ;

all_or_any_expression
    : ('ALL' | 'ANY' | 'SOME')
      '(' subquery ')'
    ;

comparison_expression
    : string_expression
      comparison_operator
      (string_expression | all_or_any_expression)
    | boolean_expression
      ('=' | '<>')
      (boolean_expression | all_or_any_expression)
    | enum_expression
      ('=' | '<>')
      (enum_expression | all_or_any_expression)
    | datetime_expression
      comparison_operator
      (datetime_expression | all_or_any_expression)
    | entity_expression
      ('=' | '<>')
      (entity_expression | all_or_any_expression)
    | arithmetic_expression comparison_operator
      (arithmetic_expression | all_or_any_expression)
    | entity_id_or_version_function
      ('=' | '<>')
      input_parameter
    | entity_type_expression
      ('=' | '<>')
      entity_type_expression
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
    : state_valued_path_expression
    | numeric_literal
    | '(' arithmetic_expression ')'
    | input_parameter
    | functions_returning_numerics
    | aggregate_expression
    | case_expression
    | function_invocation
    | arithmetic_cast_function
    | '(' subquery ')'
    ;

string_expression
    : state_valued_path_expression
    | string_literal
    | input_parameter
    | functions_returning_strings
    | aggregate_expression
    | case_expression
    | function_invocation
    | string_cast_function
    | string_expression '||' string_expression
    | '(' subquery ')'
    ;

datetime_expression
    : state_valued_path_expression
    | input_parameter
    | functions_returning_datetime
    | aggregate_expression
    | case_expression
    | function_invocation
    | date_time_timestamp_literal
    | '(' subquery ')'
    ;

boolean_expression
    : state_valued_path_expression
    | boolean_literal
    | input_parameter
    | case_expression
    | function_invocation
    | '(' subquery ')'
    ;

enum_expression
    : state_valued_path_expression
    | enum_literal
    | input_parameter
    | case_expression
    | '(' subquery ')'
    ;

entity_expression
    : single_valued_object_path_expression
    | simple_entity_expression
    ;

simple_entity_expression
    : identification_variable
    | input_parameter
    ;

entity_type_expression
    : type_discriminator
    | entity_type_literal
    | input_parameter
    ;

type_discriminator
    : 'TYPE'
      '(' ( general_identification_variable
          | single_valued_object_path_expression
          | input_parameter
          ) ')'
    ;

arithmetic_cast_function:
    'CAST'
    '(' string_expression 'AS' ('INTEGER' | 'LONG' | 'FLOAT' | 'DOUBLE') ')'
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
    | extract_datetime_field
    ;

functions_returning_datetime
    : 'CURRENT_DATE'
    | 'CURRENT_TIME'
    | 'CURRENT_TIMESTAMP'
    | 'LOCAL' 'DATE'
    | 'LOCAL' 'TIME'
    | 'LOCAL' 'DATETIME'
    | extract_datetime_part
    ;

string_cast_function
    : 'CAST' '(' scalar_expression 'AS' 'STRING' ')'
    ;

functions_returning_strings
    : 'CONCAT' '(' string_expression ',' string_expression (',' string_expression)* ')'
    | 'SUBSTRING' '(' string_expression ',' arithmetic_expression (',' arithmetic_expression)? ')'
    | 'TRIM' '(' (trim_specification? trim_character? 'FROM')? string_expression ')'
    | 'LOWER' '(' string_expression ')'
    | 'UPPER' '(' string_expression ')'
    ;

trim_specification
    : 'LEADING'
    | 'TRAILING'
    | 'BOTH'
    ;

function_invocation
    : 'FUNCTION'
      '(' function_name (',' function_arg)* ')'
    ;

extract_datetime_field
    : 'EXTRACT'
      '(' datetime_field 'FROM' datetime_expression ')'
    ;

datetime_field
    : identification_variable
    ;

extract_datetime_part
    : 'EXTRACT'
      '(' datetime_part 'FROM' datetime_expression ')'
    ;

datetime_part
    : identification_variable
    ;

function_arg
    : literal
    | state_valued_path_expression
    | input_parameter
    | scalar_expression
    ;

entity_id_or_version_function
    : id_function
    | version_function
    ;

id_function
    : 'ID'
      '(' (general_identification_variable | single_valued_object_path_expression) ')'
    ;

version_function
    : 'VERSION'
      '(' (general_identification_variable | single_valued_object_path_expression) ')'
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
    : state_valued_path_expression
    | type_discriminator
    ;

simple_when_clause
    : 'WHEN' scalar_expression
      'THEN' scalar_expression
      ;

coalesce_expression
    : 'COALESCE'
      '(' scalar_expression (',' scalar_expression)+ ')'
    ;

nullif_expression
    : 'NULLIF'
      '(' scalar_expression ',' scalar_expression ')'
    ;

identification_variable : IDENTIFIER;

superquery_identification_variable : identification_variable;

result_variable : IDENTIFIER;


entity_name : IDENTIFIER;

subtype : entity_name;

entity_type_literal : entity_name;


constructor_name : IDENTIFIER;


function_name : IDENTIFIER;


single_valued_object_field : IDENTIFIER;

single_valued_embeddable_object_field : IDENTIFIER;

collection_valued_field : IDENTIFIER;

state_field : IDENTIFIER;


input_parameter : ':' IDENTIFIER | '?' INTEGER;

collection_valued_input_parameter : input_parameter;

single_valued_input_parameter : input_parameter;


literal
    : string_literal
    | numeric_literal
    | boolean_literal
    | date_time_timestamp_literal
    | enum_literal
    ;

numeric_literal : INTEGER | DOUBLE;

string_literal : STRING;

boolean_literal : 'TRUE' | 'FALSE' ;

date_time_timestamp_literal : JDBC_ESCAPE ;

enum_literal : IDENTIFIER ('.' IDENTIFIER)*;


trim_character : CHARACTER;

pattern_value : STRING;

escape_character : CHARACTER;

