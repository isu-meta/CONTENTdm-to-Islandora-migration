<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="//mods:subject[@authority = 'naf']" exclude-result-prefixes="#all">
        <!-- 
        Split corporate and personal subject names.
        -->
        <xsl:variable name="tokens" select="tokenize(mods:name/mods:namePart/text(), ';')" />
        <xsl:variable name="personal_names" select="$tokens[contains(., ',')]" />
        <xsl:variable name="corporate_names" select="$tokens[not(contains(., ','))]" />
        
        <subject authority="naf" xmlns="http://www.loc.gov/mods/v3">
            <name type="personal" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($personal_names, ';'))" /></namePart>
            </name>
            <name type="corporate" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($corporate_names, ';'))" /></namePart>
            </name>
        </subject>
    </xsl:template>
</xsl:stylesheet>