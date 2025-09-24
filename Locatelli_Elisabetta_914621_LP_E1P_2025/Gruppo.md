## Elisabetta Locatelli 914621
## Matteo Lorenzin 914593
## Simone Frijio 914366

## PARSER-URI
Project created for the Programming Languages course (2024/2025) at the
University of Milan-Bicocca.

This project involves a parser that, given an input URI string, decomposes it
into a data structure that identifies its various components (listed below),
in accordance with the simplified RFC specification
[RFC 3986](http://tools.ietf.org/html/rfc3986), which defines its syntax
and format.

A URI ("Uniform Resource Identifier") string is a sequence of characters that
allows universal and unique identification of a resource accessible via
existing protocols. The components of a URI are: **Scheme**, **Userinfo**,
**Host**, **Port**, **Path**, **Query**, and **Fragment**.

The project contains three libraries implemented in three distinct
programming languages:
- **Prolog**, which adopts the logical programming paradigm and where parsing
  is carried out through logical rules and facts.
- **Common Lisp** and **Julia** ("bonus language"), which adopt the functional
  programming paradigm.

The aim of the project is to provide a URI string parser that allows the
decomposition of each of its components so that they can be easily identified,
isolated, and manipulated. This decomposition and extraction are done through
a series of functions implemented for each of the previously mentioned
programming languages. Furthermore, the adoption of various default ports and
the management of different URI schemes ensures that the library can flexibly
handle the most common URIs, covering a wide range of scenarios and reducing
the risk of errors.

### The URI components include the following:
- **Schema** (e.g., `http`, `mailto`): recognized as the part before the `:`.
- **Authority** (e.g., `//user@host:100`): the part separated by `//`.
- **Path** (e.g., `/path/to/resource`): the URI path separated by `/`.
- **Query** (e.g., `?key=value`): the part starting with `?`.
- **Fragment** (e.g., `#section1`): the part starting with `#`.

### Authority components:
- **Userinfo** (e.g., `user`): the part always followed by `@`
- **Host** (e.g., `example.com`): the mandatory Authority component.
- **Port** (e.g., `80`): the part starting with `:`.

It is specified that, in all the libraries developed, the corresponding default
ports are assumed for schemes with "standard" syntax and for the "zos" scheme,
while **80** is used for all other cases.
