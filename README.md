# Jakarta Query


[Jakarta Persistence]: https://jakarta.ee/specifications/persistence/
[Jakarta Data]: https://jakarta.ee/specifications/data/
[Jakarta NoSQL]: https://jakarta.ee/specifications/nosql/
[Java Persistence Query Language]: https://jakarta.ee/specifications/persistence/3.2/jakarta-persistence-spec-3.2#a4665
[Jakarta Data Query Language]: https://jakarta.ee/specifications/data/1.0/jakarta-data-1.0#_jakarta_data_query_language
[JSR-220]: https://jcp.org/en/jsr/detail?id=220

Jakarta Query serves as a unifying specification that provides a common object-oriented query language for the Jakarta ecosystem. It establishes a shared foundation that can be used consistently across [Jakarta Persistence][], [Jakarta Data][], and [Jakarta NoSQL][], ensuring that developers rely on a single query model rather than separate, independently evolving languages.

```mermaid
graph LR
    JP([Jakarta Persistence]):::spec -->|depends on| JQ([Jakarta Query]):::main
    JD([Jakarta Data]):::spec -->|depends on| JQ
    JN([Jakarta NoSQL]):::spec -->|depends on| JQ

    classDef main fill:#019DDC,stroke:#1D5183,stroke-width:2px,color:#fff,font-weight:bold
    classDef spec fill:#F8F7F7,stroke:#1D5183,stroke-width:1px,color:#1D5183
```

To accommodate the diversity of datastores in the Jakarta ecosystem, Jakarta Query distinguishes between two levels of the language: a core subset, designed for use by [Jakarta Data][] and [Jakarta NoSQL][] providers targeting non-relational databases, and an extended form, tailored for [Jakarta Persistence][] and other providers working with relational technologies.

- a core language that can be implemented by Jakarta Data and Jakarta NoSQL 
  providers using non-relational datastores, and 
- an extended language tailored for Jakarta Persistence providers or other 
  persistence technologies backed by relational databases.

> ⚠️ **Note**  
> While [Jakarta Data][] primarily targets the Core language, it may also support  
> the Extended language if its implementation is based on [Jakarta Persistence][].

The language is closely based on the existing query languages defined by
Jakarta Persistence and Jakarta Data, and is backward compatible with both.

```mermaid
graph TB
    JQ([Jakarta Query]):::main

    subgraph Extended["Extended Language"]
        Core((Core Language)):::core
    end

    Core --> JD[Jakarta Data]:::spec
    Core --> JN[Jakarta NoSQL]:::spec
    Extended --> JP[Jakarta Persistence]:::spec

    JQ --> Extended

    classDef main fill:#019DDC,stroke:#1D5183,stroke-width:2px,color:#fff,font-weight:bold
    classDef core fill:#F8F7F7,stroke:#1D5183,stroke-width:2px,color:#1D5183
    classDef spec fill:#ffffff,stroke:#999,stroke-width:1px,color:#1D5183
```

Jakarta Query prioritizes clients written in Java. However, it is not by 
nature limited to Java, and implementations in other sufficiently Java-like 
programming languages are encouraged.

## Core Language

The **Core language** is the common subset of Jakarta Query, focusing on portable operations such as selection, restriction, ordering, and simple projection. To illustrate, consider the following JSON representation of a `Room` document:  

```json
{
  "id": "R-101",
  "type": "DELUXE",
  "status": "AVAILABLE",
  "number": 42
}
````

Using the Core language, a query might retrieve all deluxe rooms that are available, ordered by their number:

```sql
from Room where type = 'DELUXE' and status = 'AVAILABLE' order by number
```


## Object-oriented query languages

A data structure in an object-oriented language is a graph of objects 
interconnected by unidirectional object references, which may be polymorphic. 
Some non-relational databases support similar representations. On the other 
hand, relational databases represent relationships between entities using 
foreign keys, and therefore SQL has no syntactic construct representing 
navigation of an association. Similarly, inheritance and polymorphism can be 
easily represented within the relational model, but are not present as 
first-class constructs in the SQL language. An object-oriented query language 
is a dialect of SQL with support for associations and subtype polymorphism.

## Historical background

Object-oriented dialects of SQL have existed since at least the early 90s. 
The Object Query Language (OQL) was an early example, targeting object 
databases, but was never widely used, since object databases were themselves 
not widely adopted. Hibernate Query Language (HQL) and the Enterprise JavaBeans 
Query Language (EJB-QL) were both introduced in 2001 as query languages 
intended for use with object/relational mapping. HQL was widely adopted by the 
Java community and was eventually standardized as the [Java Persistence Query 
Language][] (JPQL) by [JSR-220][] in 2006. JPQL has been implemented by at 
least five different products and is in extremely wide use today. On the other 
hand, since JPQL is defined as part of the Jakarta Persistence specification, 
it has not been reused outside the context of object/relational mapping in Java. 
More recently, Jakarta Data 1.0 introduced the [Jakarta Data Query Language][] 
(JDQL), a strict subset of JPQL intended for use with non-relational databases. 
It is now inconvenient that JDQL and JPQL are maintained separately by different 
groups, and so the Jakarta Query project has taken on responsibility for their 
evolution.

```mermaid
timeline
  title Evolution of Object-Oriented Query Languages in Java
  1990s : OQL introduced for object databases (never widely adopted)
  2001  : HQL (Hibernate Query Language) and EJB-QL introduced
  2006  : JPQL standardized in JSR-220 (Jakarta Persistence)
  2023  : JDQL released with Jakarta Data 1.0 for non-relational databases
  2025  : Jakarta Query unifies JPQL and JDQL into one specification
```
