<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="mods:title | cdm:title | mods:abstract | cdm:description | cdm:transcription" exclude-result-prefixes="#all">
        <!--
        Remove doubled quotes from a tag's text. Depending on the collection,
        these may take the form of "", &quot;&quot;, or &amp;quot;&amp;quot;.
        
        This template replaces doubled quotes in any of the above forms with a
        single quotation mark.
        -->
        <xsl:variable name="tag_text" select="text()" />
        <xsl:variable name="too_many_quotes">(&amp;quot;|&quot;|")+</xsl:variable>
        <xsl:variable name="quote_string">"</xsl:variable>
        <xsl:copy>
            <xsl:value-of select="replace($tag_text, $too_many_quotes, $quote_string)" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>