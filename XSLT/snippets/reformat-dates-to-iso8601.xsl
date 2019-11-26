<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="//mods:originInfo/mods:dateCreated" exclude-result-prefixes="#all">
        <!-- Reformat dates to match ISO 8601. -->
        <dateCreated keyDate="yes" encoding="iso8601" xmlns="http://www.loc.gov/mods/v3">
            <xsl:choose>
                <xsl:when test="contains(text(), ' - ')">
                    <xsl:value-of select="replace(text(), ' - ', '/')"/>
                </xsl:when>
                <xsl:when test="text() = '-'">
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(text(), ' -', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </dateCreated>
    </xsl:template>
</xsl:stylesheet>