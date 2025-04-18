Jakarta Query
=============

Jakarta Query defines an object-oriented query language designed for use with 
Jakarta Persistence and Jakarta Data, consisting of a core language that can 
be implemented by Jakarta Data providers using non-relational datastores and 
an extended language tailored for Jakarta Persistence providers or other 
persistence technologies backed by relational databases.

The language is closely based on the existing query languages defined by 
Jakarta Persistence and Jakarta Data, and is backward compatible with both.

Jakarta Query prioritizes clients written in Java. However, it is not by 
nature limited to Java, and implementations in other sufficiently Java-like 
programming languages are encouraged.

Object-oriented query languages
-------------------------------
A data structure in an object-oriented language is a graph of objects 
interconnected by unidirectional object references, which may be polymorphic. 
Some non-relational databases support similar representations. On the other 
hand, relational databases represent relationships between entities using 
foreign keys, and therefore SQL has no syntactic construct representing 
navigation of an association. Similarly, inheritance and polymorphism can be 
easily represented within the relational model, but are not present as 
first-class constructs in the SQL language. An object-oriented query language 
is a dialect of SQL with support for associations and subtype polymorphism.

Historical background
---------------------
Object-oriented dialects of SQL have existed since at least the early 90s. 
The Object Query Language (OQL) was an early example, targeting object 
databases, but was never widely used, since object databases were themselves 
not widely adopted. Hibernate Query Language (HQL) and the Enterprise JavaBeans 
Query Language (EJB-QL) were both introduced in 2001 as query languages 
intended for use with object/relational mapping. HQL was widely adopted by the 
Java community and was eventually standardized as the Java Persistence Query 
Language (JPQL) by JSR-220 in 2006. JPQL has been implemented by at least five 
different products and is in extremely wide use today. On the other hand, since 
JPQL is defined as part of the Jakarta Persistence specification, it has not 
been reused outside the context of object/relational mapping in Java. More 
recently, Jakarta Data 1.0 introduced the Jakarta Data Query Language (JDQL), 
a strict subset of JPQL intended for use with non-relational databases. It is 
now inconvenient that JDQL and JPQL are maintained separately by different 
groups, and so the Jakarta Query project has taken on responsibility for their
evolution.
