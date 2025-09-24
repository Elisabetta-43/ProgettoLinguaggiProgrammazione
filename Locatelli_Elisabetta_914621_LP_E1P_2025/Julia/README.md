## Elisabetta Locatelli 914621
## Matteo Lorenzin 914593
## Simone Frijio 914366

# URI String Parsing in Julia
This Julia library is designed to parse URI strings and break them down into
their individual components. The parsing process follows the syntax rules of
URI formatting, allowing the decomposition of the URI into its basic
components, such as the scheme, userinfo, host, port, path, query and fragment.

## Overview of the Library
The library provides a module `URILibParse`, which contains several functions
and helper utilities that help parse URI strings and extract their components.

### Key Components of the `URILib_structure`
The core data structure used to store the parsed URI components is
`URILib_structure`, which holds the following fields:

- `scheme` - The URI scheme (e.g., http, https, ftp).
- `userinfo` - The user information part of the URI (if present).
- `host` - The host (or IP address) part of the URI.
- `port` - The port number (if specified).
- `path` - The path of the URI.
- `query` - The query string (if present).
- `fragment` - The fragment identifier (if present).

## Functions in the Library

### `digitp(c::Char)`
Checks if a character is a digit (0-9).

### `letterap(c::Char)`
Checks if a character is an alphabetic letter (A-Z or a-z).

### `caratterep(c::Char)`
Checks if a character is a valid character according to the URI syntax
(alphanumeric characters and some special symbols like `+`, `-`, `_`, etc.).

### `alphanump(c::Char)`
Checks if a character is an alphanumeric character (letters or digits).

### `identificatore(host::String, sep, endline, controller)`
Identifies a part of the path and the host by recursively processing
the string and ensuring it matches valid syntax.

### `nullfy(uri_string)`
Returns `nothing` if the input string is empty, otherwise returns the
original string.

### `default_port(uri_port, uri_scheme)`
Returns the default port for a given URI scheme if no port is specified.
For example, "http" defaults to port 80, "https" defaults to port 443 and
so on.

### `remove(c::Char, s::String, n=0)`
Removes occurrences of a character `c` from a string `s`, up to `n`
occurrences, or until the character `c` is no longer found.

### `parse_scheme(uri_string::String)`
Extracts the scheme from the URI string. The scheme must be followed by a
colon (`:`).

### `check_authority(uri_string::String)`
Checks if the URI string contains an authority section (i.e., `//`).

### `parse_userinfo(authority::String)`
Extracts the userinfo (username and password) part from the authority section,
if present.

### `parse_host(authority::String)`
Extracts the host (domain name or IP address) from the authority section.

### `parse_host_chars(authority::String)`
Handles parsing the host if it consists of a sequence of identifiers
(e.g., `www.example.com`).

### `parse_host_IP(authority::String)`
Handles parsing the host if it is an IP address, ensuring that the
address is valid.

### `parse_port(port::String)`
Extracts the port number from the URI string if specified.

### `parse_path(uri_string::String)`
Extracts the path from the URI string, which typically follows the
host and port.

### `parse_query(uri_string::String)`
Extracts the query string from the URI (the part after the `?` symbol).

### `parse_fragment(uri_string::String)`
Extracts the fragment identifier from the URI (the part after the `#` symbol).

### `parse_userinfo_special(authority::String)`
Handles special parsing rules for userinfo in specific schemes
(e.g., mailto, tel).

### `parse_path_zos(uri_string::String)`
Handles parsing the path for the `zos` scheme, with special rules for path
components.

### `parse_id44(path::String)`
Extracts a 44-character identifier from the path in the `zos` scheme.

### `parse_id8(path::String)`
Extracts an 8-character identifier from the path in the `zos` scheme.

### `urilib_parse(uri_string::String)`
Main function to parse a URI string. It extracts all the components
(scheme, userinfo, host, port, path, query, and fragment) and returns a
`URILib_structure` containing the parsed components.

## Accessing URI Components
To access individual components of the parsed URI structure, the library
provides the following functions:

- `urilib_scheme(uri_struct::URILib_structure)` - Returns the scheme.
- `urilib_userinfo(uri_struct::URILib_structure)` - Returns the userinfo.
- `urilib_host(uri_struct::URILib_structure)` - Returns the host.
- `urilib_port(uri_struct::URILib_structure)` - Returns the port.
- `urilib_path(uri_struct::URILib_structure)` - Returns the path.
- `urilib_query(uri_struct::URILib_structure)` - Returns the query.
- `urilib_fragment(uri_struct::URILib_structure)` - Returns the fragment.

## Displaying the URI Components
To display the URI components, the library provides the
`urilib_display(uri_struct::URILib_structure, stream = nothing)` function.
This function prints the components to the specified output stream, or to the
default stream if no output stream is specified.

## Conclusion
This library allows for efficient URI string parsing in Julia, with support
for various URI components and schemes. It offers flexibility in handling
special cases, such as the zos scheme, and provides a structured approach
to work with URI components.
