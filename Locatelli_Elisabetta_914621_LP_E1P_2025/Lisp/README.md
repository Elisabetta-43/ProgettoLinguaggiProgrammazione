## Elisabetta Locatelli 914621
## Matteo Lorenzin 914593
## Simone Frijio 914366

## Common Lisp: a functional language
Common Lisp is a powerful, paradigm programming language that supports mainly
functional programming style. It is a standardized dialect of the Lisp
programming language, known for its flexibility and rich set of features.
Common Lisp provides dynamic typing, garbage collection and an extensive set
of built-in functions and libraries.
Its unique syntax, characterized by the extensive use of parentheses,
allows for expressive and highly flexible code.

### Key Features:
- Support for multiple programming paradigms
  (procedural, functional, object-oriented)
- Dynamic typing and automatic garbage collection
- Extensive standard library
- Macro system that allows code transformation
- Interactive development environment

## URI String Parsing in Common Lisp
The library, developed in Common Lisp, is designed using the functional
programming paradigm and aims to analyze a string representing a URI and
decompose it into its fundamental components according to a simplified syntax.
[RFC3986](http://tools.ietf.org/html/rfc3986)

## How the Library Works:
URI parsing is managed through the function `URILIB-PARSE`, which returns a
structure (`URILIB-STRUCTURE`) containing the various URI components derived
from the input string in textual format.  
The parsing process involves several stages:

1. **Extraction** (`extract-schema`) and **identification** of the **SCHEMA**,
which is characterized by either a "standard" or "special" syntax.  

2. **Components extraction**: once the syntax is identified, all the fields
of the `URILIB-STRUCTURE` are populated through various functions that
recursively extract characters one by one, provided no errors occur due to
incorrect URI string format or invalid characters.
Each predicate parses individual components. Depending on the scheme used,
whether special or general, different syntactic rules are
applied until the string is decomposed and the result is returned.

## Functions for Accessing Individual Components
To access each component of the URI, the library provides an access function
that returns the individual component from the `URILIB-STRUCTURE`:
- `URILIB-SCHEME`
- `URILIB-USERINFO`
- `URILIB-HOST`
- `URILIB-PORT`
- `URILIB-PATH`
- `URILIB-QUERY`
- `URILIB-FRAGMENT`

**Note**: The library recognizes only the following schemes:
- `"http"` (with default port 80)
- `"https"` (with default port 443)
- `"ftp"` (with default port 21)
- `"mailto"` (with default port 80)
- `"news"` (with default port 80)
- `"tel"` or `"fax"` (with default port 80)
- `"zos"` (with default port 3270)

## Functions in the Library:

### `urilib-parse(uri)`
Main function to parse a URI string. It extracts all the components
(schema, userinfo, host, port, path, query, and fragment) and returns a
`Urilib-Structure` containing the parsed components.

### `urilib-display(uri, stream)`
Displays the components of a URI in a human-readable format. It prints
the schema, userinfo, host, port, path, query, and fragment to the specified
stream or to the default stream if no stream is provided.

### `standard-schema-p(schema)`
Checks if the provided schema matches a standard URI schema
(e.g., `http`, `https`, `ftp`).

### `special-schema-p(schema)`
Checks if the provided schema matches a special URI schema
(e.g., `mailto`, `news`, `tel`).

## Parsing Functions:

### `extract-schema(chars)`
Extracts the schema (e.g., `http`, `https`, etc.) from the input string.

### `extract-authority(chars, schema)`
Extracts the authority section (userinfo, host, port) from the input string
based on the provided schema.

### `extract-path(chars)`
Extracts the path section of the URI, typically following the host and port.

### `extract-query(chars)`
Extracts the query string from the URI (the part after the `?` symbol).

### `extract-fragment(chars)`
Extracts the fragment identifier from the URI (the part after the `#` symbol).

### `extract-userinfo(chars)`
Extracts the userinfo section from the URI, which is usually in the format
`userinfo@`.

### `extract-host(chars)`
Extracts the host part of the URI, which could be a domain name or an
IP address.

### `extract-host-ip(chars)`
Extracts the host part of the URI when it is a IP address with the following
format: NNN.NNN.NNN.NNN (where 'N' is a digit).

### `extract-port(chars)`
Extracts the port number from the URI string.

## Handling Special Schemes:

### `extract-special-host(chars, schema)`
Handles extracting the host for special URI schemas, such as `mailto`
and `news`.

### `extract-special-userinfo(chars)`
Handles extracting the userinfo for special URI schemas, such as `mailto`
and `tel`.

### `extract-special-uri(schema, chars)`
Decomposes a URI in the case of schemes characterized by "special syntax".
This function handles specific schemas such as `mailto`, `news`, `tel`, `fax`
and `zos`. It extracts the relevant components such as userinfo, host, port
and path, and performs validation where necessary.

### `extract-zos-path(chars)`
Extracts the path corresponding to the "Zos" schema. It validates the
correctness of parentheses and ensures that both components of the path,
`Id44` and `Id8`, begin with an alphabetic character. Further validation is
performed on the length of both components.

### `extract-id44(chars, chars-id44)`
Recursively extracts the characters of `Id44`, ensuring that each character
is alphanumeric or a period (`.`), that the first is alphabetic, that the
length is allowed and that id44 doesn't and with `.`. If an invalid character
is encountered, an error is raised.

### `extract-id8(chars, chars-id8)`
Recursively extracts the characters of `Id8`, ensuring that each character
is alphanumeric , that the first is alphabetic and that the length is allowed.
If an invalid character is encountered, an error is raised.

### `valid-character(char)`
Predicate that determines whether a passed character is valid according to  
the URI specification. Valid characters include alphanumeric characters and
symbols like `_`, `=`, `+`, and `-`.

### `valid-number-ip(number)`
Predicate that determines whether the passed number is within the valid
range for an IP address, which is between `[0, 255]`.

### `digitp(c)`
Checks if a character is a digit (0-9).

### `letterap(c)`
Checks if a character is an alphabetic letter (A-Z or a-z).


## Display Function:
The function `URILIB-DISPLAY`, when given an input, will print the output
to the specified destination stream (if provided as input). Otherwise, the
output will be printed to the current stream.

## Support Functions:
The library includes a set of support functions for:
- Recognizing valid characters (`valid-character` and `valid-number-ip`)
- Assigning a default port if not specified (`default-port`)
- Checking for the presence of a component separator (`contains-separator`)
- Distinguishing between the two possible host formats (`is-ip`)
- Verifying that the digits in the IP address have the correct division
  (`count-dots`) and many more...
These functions greatly enhance readability and avoid redundancy in the code.

In summary, the library provides a functional implementation for URI parsing
in Common Lisp, enabling easy extraction of the various URI components from
an input string in textual format.
