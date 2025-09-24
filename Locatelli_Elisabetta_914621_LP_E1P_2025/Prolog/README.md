## Elisabetta Locatelli 914621
## Matteo Lorenzin 914593
## Simone Frijio 914366

# Prolog: a logic programming language
Prolog is a high-level programming language primarily used for
**logic programming**, where programs are written as a set of facts and rules.
Prolog uses a process called backtracking to find solutions to queries by
exploring possible logical relationships between facts and rules, as
demonstrated in this project.

Additionally, Prolog is declarative, meaning that you specify **what** the
problem is rather than **how** to solve it. This makes it an extremely
powerful tool for **knowledge representation**.

## URI String Parsing in Prolog
This library, developed in **Prolog**, is designed to decompose a URI string
into its individual components according to a simplified syntax, inspired by
[RFC3986](http://tools.ietf.org/html/rfc3986). The library takes a string
representing a URI and breaks it down into its constituent parts, such as
schema, host, path, query, and fragment.

## How the Library Works:
The core of the parsing process is the predicate `urilib_parse/2`, which takes
a URI string as input and returns a Prolog structure (`uri/7`) containing the
parsed components. The URI is analyzed in several stages:

1. **Extraction of the Schema**: The URI's schema is identified
   (either standard or special syntax).

2. **Component Extraction**: Based on the schema, various predicates are
applied to extract the URI components. This step involves recursively parsing
the string character by character while validating the syntax and structure
of each component. If errors are encountered, such as incorrect formats
or invalid characters, they are handled gracefully.

## Accessing Individual URI Components:
The library provides predicates to access the components from the parsed
URI structure. For example:
- `urilib_scheme/2` - Extracts the **scheme** from the URI structure.
- `urilib_userinfo/2` - Extracts the **userinfo** part.
- `urilib_host/2` - Extracts the **host**.
- `urilib_port/2` - Extracts the **port**.
- `urilib_path/2` - Extracts the **path**.
- `urilib_query/2` - Extracts the **query**
- `urilib_fragment/2` - Extracts the **fragment**.

This parser handles the URI's components, many of which can be optional,
depending on the URI Scheme, the presence or the lack of the authority and
of some special characters used as separators.

## Management of special cases:
The generic_special_schemes/3 predicate handles different special schemes
and parses the URI structure accordingly.

Some of the implemented rules include:
- **Common schemes** like http, https, ftp: These schemes are handled, and the
  URI components are extracted accordingly.
- **Zos scheme**: The parser handles the zos scheme with custom parsing logic.
- **Other schemes** like mailto, news, tel, fax: These schemes are also
  supported and handled separately based on their specifications.

## Other main functions:
- `Extracting the schema`: The scheme/3 function extracts the Schema
   from the URI.
- `Extracting the authority`: The authorithy/6 function handles the URI
   authority part, including userinfo, host, and port.
- `Host parsing`: The host/3 and ip/3 functions handle the URI host and
   IP address.
- `Port parsing`: The parser extracts the port, if present, using the
   port_parser/3 function.

## Functions in the Library

### `urilib_parse/2`
 Main function to parse a URI string. It extracts all the components
 (schema, userinfo, host, port, path, query, and fragment) and returns the
 parsed components.

### `scheme/3`
 Extracts the schema (e.g., `http`, `https`, etc.) from the input string.

### `authority/6`
 Extracts the authority section (userinfo, host, port) from the input string
 based on the provided schema.

### `userinfo/3`
 Extracts the userinfo section from the URI, which is usually in the format
 `userinfo@`.

### `host/3`
 Extracts the host part of the URI, which could be a domain name or an
 IP address.

### `ip/3`
 Extracts the host part of the URI when it is a IP address with the following
 format: NNN.NNN.NNN.NNN (where 'N' is a digit).

### `path_parser/3`, `path_special/3`, `path_special_zos/3`, etc.
 These predicates handle the parsing of URI paths. They support different
 types of paths, including standard paths, special paths like `zos` and
 paths that may include query parameters or fragments.

### `port/3` and `port_parser/3`
  These predicates parse a URI's port component. The port is extracted from
  the URI if present, and it is validated to ensure it is a valid number.

### `query/3` and `fragment/3`
 These predicates handle the parsing of query parameters (`?`) and fragment
 identifiers (`#`). They ensure that the query and fragment components are
 correctly extracted from the URI.

### `path_zos/1`
 Validates paths that follow the `zos` format, ensuring that the path
 contains a valid identifier (id44), which must not exceed 44 characters
 and must not end with a period.

### `id44/3` and `id8/3`
 These predicates parse and validate `id44` (a general identifier) and `id8`
 (a special identifier used in `zos` paths). They handle parsing alphanumeric
 characters and special symbols (like `.` and `-`), with constraints on the
 length of these identifiers.

### `urilib_display/2` and `urilib_display/1`
 These predicates are responsible for displaying the parsed URI in a
 readable format. They output the various components of the URI
 (Scheme, User Info, Host, Port, Path, Query, Fragment) to the specified
 stream or the current output stream.

### `identificatore_generale/1`
 These predicates define valid characters for various URI components, such
 as general identifiers, host identifiers, etc.
 They handle alphanumeric characters and a few special characters
 (`=`, `_`, `+`, etc.).

### `identificatore_zos/1`
 These predicates define valid characters for zos URI components, such
 as general identifiers, host identifiers.
 They handle alphanumeric characters and a few special characters
 (`=`, `_`, `+`, etc.).
 P.S. '(' ')' included in the parsing because not intended as delimiters

### `caratteri/1`
 Defines valid characters for URI components, allowing alphanumeric
 characters and symbols like `_`, `=`, `+`, and `-`.

### `generic_special_schemes/3`
 This predicate supports parsing special URI schemes like `mailto`, `news`,
 `tel`, `fax`, and others. It ensures each scheme is parsed according to
 its specific rules.

## Support functions
This library also contains a series of other components that support the main
extraction functions.

This parser is a useful tool for parsing URIs in Prolog. It can be easily
extended to support additional URI schemes and handle more complex URI formats.
Using Prolog allows for leveraging the power of logical programming to
efficiently parse and manipulate URIs.
