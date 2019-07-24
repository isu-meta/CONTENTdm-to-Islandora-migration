<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="//mods:identifier[@type='local-and-arks']" exclude-result-prefixes="#all">
        <!-- 
        Splits identifiers like 
        <identifier type="local-and-arks">0694b001f001i019&lt;br&gt;https://n2t.net/ark:/87292/w9h01b</identifier> 
        into <identifier type="local">0694b001f001i019</identifier>
        and <identifier type="ark">https://n2t.net/ark:/87292/w9h01b</identifier>, removing
        the original identifier element.
        -->
        <xsl:variable name="id_txt" select="text()" />
        <xsl:variable name="first_id" select="substring-before($id_txt, '&lt;')" />
        <xsl:variable name="second_id" select="substring-after($id_txt, '&gt;')" />
        <xsl:choose>
            <xsl:when test="contains($first_id, 'http')">
                <identifier type="local" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$second_id" /></identifier>
                <identifier type="ark" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$first_id" /></identifier>
            </xsl:when>
            <xsl:when test="contains($second_id, 'http')">
                <identifier type="local" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$first_id" /></identifier>
                <identifier type="ark" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$second_id" /></identifier>
            </xsl:when>
            <xsl:when test="$first_id='' and $second_id=''">
                <xsl:choose>
                    <xsl:when test="contains($id_txt, 'http')">
                        <identifier type="ark" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$id_txt" /></identifier>
                    </xsl:when>
                    <xsl:otherwise>
                        <identifier type="local" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$id_txt" /></identifier>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>