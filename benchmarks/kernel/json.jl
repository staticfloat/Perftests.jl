# This file is a part of Julia. License is MIT: http://julialang.org/license

#JSON Parser
#Adapted from http://www.mathworks.com/matlabcentral/fileexchange/23393
#Original BSD Licence, (c) 2011, François Glineur

function parse_json(strng::AbstractString)
    pos = 1
    len = length(strng)
    # AbstractString delimiters and escape characters are identified beforehand to improve speed
    # esc = regexp(str, "[\"\\\\]"); index_esc = 1; len_esc = length(esc);  #TODO Enable for speed

    function parse_object()
        parse_char('{')
        object = Dict{AbstractString, Any}()
        if next_char() != '}'
            while true
                str = parse_string()
                if isempty(str)
                    error("Name of value at position $pos cannot be empty")
                end
                parse_char(':')
                val = parse_value()
                object[str] = val
                if next_char() == '}'
                    break
                end
                parse_char(',')
            end
        end
        parse_char('}')
        return object
    end

    function parse_array()
        parse_char('[')
        object = Set()
        if next_char != ']'
            while true
                val = parse_value()
                push!(object, val)
                if next_char() == ']'
                    break
                end
                parse_char(',')
            end
        end
        parse_char(']')
        return object
    end

    function parse_char(c::Char)
        skip_whitespace()
        if pos > len || strng[pos] != c
            error("Expected $c at position $pos")
        else
            pos = pos + 1
            skip_whitespace()
        end
    end

    function next_char()
        skip_whitespace()
        if pos > len
            c = '\0'
        else
            c = strng[pos]
        end
    end

    function skip_whitespace()
        while pos <= len && isspace(strng[pos])
            pos = pos + 1
        end
    end

    function parse_string()
        if strng[pos] != '"'
            error("AbstractString starting with quotation expected at position $pos")
        else
            pos = pos + 1
        end
        str = ""
        while pos <= len
            # while index_esc <= len_esc && esc(index_esc) < pos
            #     index_esc = index_esc + 1
            # end
            # if index_esc > len_esc
            #     str = string(str, strng[pos:end])
            #     pos = len + 1
            #     break
            # else
            #     str = string(str, strng[pos:esc(index_esc)-1])
            #     pos = esc(index_esc)
            # end
            nc = strng[pos]
            if nc == '"'
                pos = pos + 1
                return string(str)
            elseif nc ==  '\\'
                if pos+1 > len
                    error_pos("End of file reached right after escape character")
                end
                pos = pos + 1
                anc = strng[pos]
                if anc == '"' || anc == '\\' || anc == '/'
                    str = string(str, strng[pos])
                    pos = pos + 1
                elseif anc ==  'b' || anc == 'f'|| anc == 'n' || anc == 'r' || anc == 't'
                    str = string(str, '\\', string[pos])
                    pos = pos + 1
                elseif anc == 'u'
                    if pos+4 > len
                        error_pos("End of file reached in escaped unicode character")
                    end
                    str = string(str, strng[pos-1:pos+4])
                    pos = pos + 5
                end
            else # should never happen
                str = string(str,strng[pos])
                pos = pos + 1
            end
        end
        error("End of file while expecting end of string")
    end

    function parse_number()
        num_regex = r"^[\w]?[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?[\w]?"
        m = match(num_regex, strng[pos:min(len,pos+20)])
        if m === nothing
            error("Error reading number at position $pos")
        end
        delta = m.offset + length(m.match)
        pos = pos + delta -1
        return float(m.match)
    end

    function  parse_value()
        nc = strng[pos]
        if nc == '"'
            val = parse_string()
            return val
        elseif nc == '['
            val = parse_array()
            return val
        elseif nc == '{'
            val = parse_object()
            return val
        elseif nc == '-' || nc == '0' || nc == '1' || nc == '2' || nc == '3' || nc == '4' || nc == '5' || nc == '6' || nc == '7' || nc == '8' || nc == '9'
            val = parse_number()
            return val
        elseif nc == 't'
            if pos+3 <= len && strng[pos:pos+3] == "true"
                val = true
                pos = pos + 4
                return val
            end
        elseif nc == 'f'
            if pos+4 <= len && strng[pos:pos+4] == "false"
                val = false
                pos = pos + 5
                return val
            end
        elseif nc == 'n'
            if pos+3 <= len && strng[pos:pos+3] == "null"
                val = []
                pos = pos + 4
                return val
            end
        end
        error("Value expected at position $pos")
    end

    if pos <= len
        nc = next_char()
        if nc == '{'
            return parse_object()
        elseif nc ==  '['
            return parse_array()
        else
            error("Outer level structure must be an object or an array")
        end
    end
end


# Include some test JSON data
_json_data = "{\"web-app\": {
  \"servlet\": [
    {
      \"servlet-name\": \"cofaxCDS\",
      \"servlet-class\": \"org.cofax.cds.CDSServlet\",
      \"init-param\": {
        \"configGlossary:installationAt\": \"Philadelphia, PA\",
        \"configGlossary:adminEmail\": \"ksm@pobox.com\",
        \"configGlossary:poweredBy\": \"Cofax\",
        \"configGlossary:poweredByIcon\": \"/images/cofax.gif\",
        \"configGlossary:staticPath\": \"/content/static\",
        \"templateProcessorClass\": \"org.cofax.WysiwygTemplate\",
        \"templateLoaderClass\": \"org.cofax.FilesTemplateLoader\",
        \"templatePath\": \"templates\",
        \"templateOverridePath\": \"\",
        \"defaultListTemplate\": \"listTemplate.htm\",
        \"defaultFileTemplate\": \"articleTemplate.htm\",
        \"useJSP\": false,
        \"jspListTemplate\": \"listTemplate.jsp\",
        \"jspFileTemplate\": \"articleTemplate.jsp\",
        \"cachePackageTagsTrack\": 200,
        \"cachePackageTagsStore\": 200,
        \"cachePackageTagsRefresh\": 60,
        \"cacheTemplatesTrack\": 100,
        \"cacheTemplatesStore\": 50,
        \"cacheTemplatesRefresh\": 15,
        \"cachePagesTrack\": 200,
        \"cachePagesStore\": 100,
        \"cachePagesRefresh\": 10,
        \"cachePagesDirtyRead\": 10,
        \"searchEngineListTemplate\": \"forSearchEnginesList.htm\",
        \"searchEngineFileTemplate\": \"forSearchEngines.htm\",
        \"searchEngineRobotsDb\": \"WEB-INF/robots.db\",
        \"useDataStore\": true,
        \"dataStoreClass\": \"org.cofax.SqlDataStore\",
        \"redirectionClass\": \"org.cofax.SqlRedirection\",
        \"dataStoreName\": \"cofax\",
        \"dataStoreDriver\": \"com.microsoft.jdbc.sqlserver.SQLServerDriver\",
        \"dataStoreUrl\": \"jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon\",
        \"dataStoreUser\": \"sa\",
        \"dataStorePassword\": \"dataStoreTestQuery\",
        \"dataStoreTestQuery\": \"SET NOCOUNT ON;select test='test';\",
        \"dataStoreLogFile\": \"/usr/local/tomcat/logs/datastore.log\",
        \"dataStoreInitConns\": 10,
        \"dataStoreMaxConns\": 100,
        \"dataStoreConnUsageLimit\": 100,
        \"dataStoreLogLevel\": \"debug\",
        \"maxUrlLength\": 500}},
    {
      \"servlet-name\": \"cofaxEmail\",
      \"servlet-class\": \"org.cofax.cds.EmailServlet\",
      \"init-param\": {
      \"mailHost\": \"mail1\",
      \"mailHostOverride\": \"mail2\"}},
    {
      \"servlet-name\": \"cofaxAdmin\",
      \"servlet-class\": \"org.cofax.cds.AdminServlet\"},

    {
      \"servlet-name\": \"fileServlet\",
      \"servlet-class\": \"org.cofax.cds.FileServlet\"},
    {
      \"servlet-name\": \"cofaxTools\",
      \"servlet-class\": \"org.cofax.cms.CofaxToolsServlet\",
      \"init-param\": {
        \"templatePath\": \"toolstemplates/\",
        \"log\": 1,
        \"logLocation\": \"/usr/local/tomcat/logs/CofaxTools.log\",
        \"logMaxSize\": \"\",
        \"dataLog\": 1,
        \"dataLogLocation\": \"/usr/local/tomcat/logs/dataLog.log\",
        \"dataLogMaxSize\": \"\",
        \"removePageCache\": \"/content/admin/remove?cache=pages&id=\",
        \"removeTemplateCache\": \"/content/admin/remove?cache=templates&id=\",
        \"fileTransferFolder\": \"/usr/local/tomcat/webapps/content/fileTransferFolder\",
        \"lookInContext\": 1,
        \"adminGroupID\": 4,
        \"betaServer\": true}}],
  \"servlet-mapping\": {
    \"cofaxCDS\": \"/\",
    \"cofaxEmail\": \"/cofaxutil/aemail/*\",
    \"cofaxAdmin\": \"/admin/*\",
    \"fileServlet\": \"/static/*\",
    \"cofaxTools\": \"/tools/*\"},

  \"taglib\": {
    \"taglib-uri\": \"cofax.tld\",
    \"taglib-location\": \"/WEB-INF/tlds/cofax.tld\"}}}"
