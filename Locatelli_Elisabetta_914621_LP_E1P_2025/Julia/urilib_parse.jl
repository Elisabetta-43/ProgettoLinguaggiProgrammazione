### Elisabetta Locatelli 914621
### Matteo Lorenzin 914593
### Simone Frijio 914366

###  -*- Mode: Julia -*-
### urilib_parse.jl starts here
### RFC3986 (http://tools.ietf.org/html/rfc3986)

module URILibParse

### Struct containing every URI field  
struct URILib_structure
    scheme
    userinfo  
    host  
    port  
    path  
    query 
    fragment 
end

### function used to check if a character is a digit
function digitp(c :: Char)
    if (48 <= Int(c) <= 57)
        true
    else
        false
    end
end

### function used to check if a character is an alphabetic symbol
function letterap(c :: Char)
    if (65 <= Int(c) <= 90 || 97 <= Int(c) <= 122)
        true
    else
        false
    end
end

### function used to check if a character respect the syntax defined in 
### <carattere>
function caratterep(c :: Char)
    if (letterap(c) || digitp(c) || c in ['+', '-', '=', '_'])
        true
    else
        false
    end
end

### function used to check if a character is an alphanumeric symbol
function alphanump(c :: Char)
    if (letterap(c) || digitp(c))
        true
    else
        false
    end
end

### function used to validate the single part of the host and the path
### for example given an ip address 192.168.011.001 as an input value,
### the output produced is 192
function identificatore(host :: String, sep, endline, controller)
    if (host == "" || host[begin] == sep || host[begin] in endline)
        return ("",host[begin:end])
    else
        if (controller(host[begin]))
            (host[begin] 
            * identificatore(host[begin+1:end], sep, endline, controller)[1], 
            identificatore(host[begin+1:end], sep, endline, controller)[2] )
        else
            error("invalid URI character")
        end
    end
end

### function used to return nothing if the return value of a function is an
### empty string
function nullfy(uri_string)
    if (uri_string == "")
        nothing
    else
        uri_string
    end 
end

### function used to return the default port based on the scheme
function default_port(uri_port, uri_scheme)
    if (uri_port == "")
        if (uri_scheme == "http")
            "80"
        elseif (uri_scheme == "https")
            "443"
        elseif (uri_scheme == "ftp")
            "21"
        else 
            "3270"
        end
    else
        uri_port
    end
end

### function used to remove characters from string s until it finds character c
### if the character c does not occur in s, the function returns an empty 
### string. The number n is an optional parameter that indicates how many 
### times the character c (and all the character before) must be removed 
### after the first occurence of c 
function remove(c :: Char,s ::String, n = 0)
    if ( s == "" || s[begin] == c)
        if (n == 0)
            s[begin+1:end]
        else
            remove(c, s[begin+1:end], n -1) 
        end
    else
        remove(c, s[begin+1:end], n) 
    end
end

### function used to get the scheme from the URI string
function parse_scheme(uri_string :: String)
    if (uri_string == "")
        error("Scheme is not valid")
    end
    if (uri_string[begin] == ':')
        ""
    else                        
       if (caratterep(uri_string[begin]))  
        uri_string[begin] * parse_scheme(uri_string[begin+1:end])
       else
        error("invalid scheme character")
       end
    end
end

### function used to check the authorithy is present in the URI string
function check_authorithy(uri_string :: String)
    if (length(uri_string) >= 2 && uri_string[begin + 1] == '/' 
        && uri_string[begin] == '/')
        false
    else
        true
    end
end

### function used to get the userinfo from the URI string
function parse_userinfo(authorithy :: String)
    if (occursin('@', authorithy))
        if (authorithy[begin] == '@')
            ""
        else
            if (caratterep(authorithy[begin]))
                authorithy[begin] * parse_userinfo(authorithy[begin + 1:end])
            else
                error("invalid userinfo character")
            end
        end
    else
        nothing
    end
end

### function used to get the host from the URI string
function parse_host(authorithy :: String)
    if (authorithy == "")
        error("error: empty host")
    end
    if (letterap(authorithy[begin]))
        parse_host_chars(authorithy)
    elseif (digitp(authorithy[begin]))
        if (remove('.',parse_host_IP(authorithy),2) == ""  
            || occursin('.', remove('.',parse_host_IP(authorithy),2)))
            error("invalid ip address")
        end
        parse_host_IP(authorithy)
    else
        error("Host is not valid")
    end
end

### function used to get the host from the URI string if the host respect the
### syntax: <identificatore> [‘/’ <identificatore>]*
function parse_host_chars(authorithy :: String)
    host = identificatore(authorithy, '.', [':', '/'], alphanump)
    if ( host[2] == "" || host[2][begin] == ':' || host[2][begin] == '/')
        host[1]
    else
         if (host[2][begin] == '.')
            if (host[2][begin+1:end] != "" && letterap(host[2][begin+1]))
                host[1] * '.' * parse_host_chars(host[2][begin+1:end])
            else
                error("invalid host character") 
            end
         else
            error("Host is not valid")
         end
    end
end

### function used to get the host from the URI string if the host is an 
### ip address
function parse_host_IP(authorithy :: String)
    host = identificatore(authorithy, '.', [':', '/'], digitp)
    if (parse(Int, host[1]) > 255)
        error("ip address must be less than 255")
    end
    if ( host[2] == "" || host[2][begin] == ':'|| host[2][begin] == '/')
        host[1]
    else
         if (host[2][begin] == '.')
            host[1] * '.' * parse_host_IP(host[2][begin+1:end])
         else
            error("Host is not valid")
         end
    end
end

### function used to get the port from the URI string
function parse_port(port :: String)
    if (port == "" || port[begin] == '/')
        ""
    else
        if (digitp(port[begin]))
            port[begin] * parse_port(port[begin+1:end])
        else
            error("invalid port character")
        end
    end
end

### function used to get the path from the URI string
function parse_path(uri_string :: String)
     path = identificatore(uri_string, '/', ['?', '#'], caratterep)
     if ( path[2] == "" || path[2][begin] in ['?', '#'] )
        path[1]
    else
         if (path[2][begin] == '/')
            path[1] * '/' * parse_path(path[2][begin+1:end])
         else
            error("path is not valid")
         end
    end

end

### function used to get the query from the URI string
function parse_query(uri_string :: String)
    if (uri_string == "" || uri_string[begin] == '#')
        ""
    else
        if (caratterep(uri_string[begin]))
            uri_string[begin] * parse_query(uri_string[begin+1:end])
        else
            error("invalid query character")
        end
    end
end

### function used to get the fragment from the URI string
function parse_fragment(uri_string :: String)
    if (uri_string == "")
        ""
    else
        if (caratterep(uri_string[begin]))
            uri_string[begin] * parse_fragment(uri_string[begin+1:end])
        else
            error("invalid fragment character")
        end
    end
end

### function used to get the userinfo from the URI string in the case of a 
### special sintax
function parse_userinfo_special(authorithy :: String)
    if (authorithy == "" || authorithy[begin] == '@')
        ""
    else
        if (caratterep(authorithy[begin]))
            authorithy[begin] * parse_userinfo_special(authorithy[begin+1:end])
        else
            error("invalid userinfo character")
        end
    end
end

### function used to get the path from the URI string if the scheme is "zos"
function parse_path_zos(uri_string :: String)
    if (uri_string == "")
        error("empty path")
    end
    uri_id44 = parse_id44(uri_string)
    if (uri_id44 == "" || (uri_id44[end] == '.' 
        || length(uri_id44) > 44 || !letterap(uri_id44[begin])))
        error("invalid zos path")
    end
    if (remove('(',uri_string) == "")
        uri_id8 = ""
    else
        uri_id8 = parse_id8(remove('(',uri_string))
    end
    if (length(uri_id8) > 9)
        if (uri_id8 != "" && !letterap(uri_id8[begin]))
            error("invalid zos path")
        end
    end
    if (uri_id8 == "")
        uri_id44
    else
        uri_id44 * "(" * uri_id8
    end
end

### function used to get the id44 component from the path in the zos scheme
function parse_id44(path :: String)
    if (path == "" || path[begin] in ['(', '?', '#'])
        ""
    else
        if (path[begin] == '.' || alphanump(path[begin]))
            path[begin] * parse_id44(path[begin+1:end])
        else
            error("invalid path character")
        end
    end
end

### function used to get the id8 component from the path in the zos scheme
function parse_id8(path :: String)
    if (path == "")
        error("invalid path character")
    elseif (path[begin] == ')')
        path[begin]
    else
        if (letterap(path[begin]) || digitp(path[begin]))
            path[begin] * parse_id8(path[begin+1:end])
        else
            error("invalid path character")
        end
    end
end

### function used to extracts all the components
### (scheme, userinfo, host, port, path, query, and fragment) and returns a
### URILib_structure containing the parsed components
function urilib_parse(uri_string :: String)
    uri_scheme = parse_scheme(uri_string)
    if !(uri_scheme in ["http", "https", "ftp", 
        "mailto", "news", "tel", "fax", "zos"])
    error("Scheme is not valid")
    end
    if (uri_scheme in ["http", "https", "ftp", "zos"] &&
        check_authorithy(remove(':', uri_string)))
        if (remove(':', uri_string) == "" && uri_scheme != "zos")
            return URILib_structure(
             uri_scheme,
             nothing, 
             nothing, 
             default_port("", uri_scheme),
             nothing,
             nothing,
             nothing
             )
        else
            return URILib_structure(
                uri_scheme,
                nothing, 
                nothing, 
                default_port("", uri_scheme),
                let
                    if (uri_scheme == "zos" && remove(':', uri_string) == "")
                        error("missing path")
                    end
                    if (first(remove(':', uri_string)) == '/')
                        if (uri_scheme == "zos")
                            nullfy(parse_path_zos(remove('/', uri_string)))
                        else
                            nullfy(parse_path(remove('/', uri_string)))
                        end
                    else
                        if (uri_scheme == "zos")
                            nullfy(parse_path_zos(remove(':', uri_string)))
                        else
                            nullfy(parse_path(remove(':', uri_string)))
                        end
                    end
                end,
                nullfy(parse_query(remove('?', uri_string))),
                nullfy(parse_fragment(remove('#', uri_string)))
            )    
        end    
    else
        if (uri_scheme == "mailto")
            return URILib_structure(
                uri_scheme,
                let
                    if (parse_userinfo_special(remove(':', uri_string)) == "")
                        error("missing userinfo")
                    end
                    parse_userinfo_special(remove(':', uri_string))
                end,
                let
                    if (occursin('@', uri_string))
                        if (length((remove('@', uri_string))) > 
                            length(parse_host((remove('@',uri_string)))))
                            error("invalid mailto syntax")
                        end
                        parse_host((remove('@', uri_string)))
                    else
                        nothing
                    end
                end, 
                80,
                nothing,
                nothing,
                nothing
                )   
        end
        if (uri_scheme == "news")
            if (length(uri_string) > length(uri_scheme) 
                + length(parse_host(remove(':', uri_string))) + 1)
                error("invalid news syntax")
            end
            return URILib_structure(
                uri_scheme,
                nothing, 
                parse_host(remove(':', uri_string)), 
                80,
                nothing,
                nothing,
                nothing
                )
        end
        if (uri_scheme in ["tel","fax"])
            if (length(remove(':', uri_string)) != 
                length(parse_userinfo_special(remove(':', uri_string))))
                error("invalid userinfo character")
            end
            return URILib_structure(
                uri_scheme,
                parse_userinfo_special(remove(':', uri_string)), 
                nothing, 
                80,
                nothing,
                nothing,
                nothing
                )
        end
        if (uri_scheme in ["http", "https", "ftp", "zos"])
            return URILib_structure(
                uri_scheme,
                nullfy(parse_userinfo(remove('/', uri_string, 1))), 
                let
                    if (occursin('@', uri_string))
                        nullfy(parse_host(remove('@',uri_string)))  
                    else
                        nullfy(parse_host(remove('/', uri_string, 1)))
                    end
                end, 
                default_port(parse_port(remove(':',uri_string,1)),uri_scheme),
                let
                    if (uri_scheme == "zos")
                        nullfy(parse_path_zos(remove('/', uri_string, 2))) 
                    else
                        nullfy(parse_path(remove('/', uri_string, 2)))
                    end 
                end,
                nullfy(parse_query(remove('?', uri_string))),
                nullfy(parse_fragment(remove('#', uri_string)))
                )
        end
        
    end

end

### function that return the scheme from a URILib_structure
function urilib_scheme(uri_struct :: URILib_structure)
    uri_struct.scheme
end

### function that return the userinfo from a URILib_structure
function urilib_userinfo(uri_struct :: URILib_structure)
    uri_struct.userinfo
end

### function that return the host from a URILib_structure
function urilib_host(uri_struct :: URILib_structure)
    uri_struct.host
end

### function that return the port from a URILib_structure
function urilib_port(uri_struct :: URILib_structure)
    uri_struct.port
end

### function that return the path from a URILib_structure
function urilib_path(uri_struct :: URILib_structure)
    uri_struct.path
end

### function that return the query from a URILib_structure
function urilib_query(uri_struct :: URILib_structure)
    uri_struct.query
end

### function that return the fragment from a URILib_structure
function urilib_fragment(uri_struct :: URILib_structure)
    uri_struct.fragment
end

### function used to print an URILib_structure values
function urilib_display(uri_struct :: URILib_structure, stream = nothing)
    println("Schema:         ", uri_struct.scheme)
    println("Userinfo:       ", uri_struct.userinfo)
    println("Host:           ", uri_struct.port)
    println("Port:           ", uri_struct.port)
    println("Path:           ", uri_struct.path)
    println("Query:          ", uri_struct.query)
    println("Fragment:       ", uri_struct.fragment)
    if (typeof(stream) == IO)
        close(stream)
    end
    true
end

export urilib_display, urilib_scheme, urilib_userinfo, urilib_host,
 urilib_port, urilib_path, urilib_query, urilib_fragment, urilib_parse
end

### urilib_parse.jl ends here
