<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="//mods:subject[@authority='geonames']/mods:geographic" exclude-result-prefixes="#all">
        <!--
        Strip verticle bars and trailing information, so locations like
        "Clear Lake | Municipality" become "Clear Lake".
        -->
        <xsl:variable name="tokens" select="tokenize(text(), ';')" />
        <xsl:variable name="stripped">
            <xsl:for-each select="$tokens">
                <xsl:choose>
                    <xsl:when test="contains(., '|')">
                        <xsl:value-of select="concat(substring-before(., ' |'), '; ')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(., '; ')" /> 
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="stripped-spaced" select="normalize-space($stripped)" />
        
        <geographic xmlns="http://www.loc.gov/mods/v3">
            <xsl:value-of select="substring($stripped-spaced, 1, string-length($stripped-spaced) - 1)" />
        </geographic>
    </xsl:template>
</xsl:stylesheet>