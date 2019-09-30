<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="//mods:subject[@authority='gbif']/mods:topic" exclude-result-prefixes="#all">
        <!--
        Copy topics with the format "Scientific_name | Common_name" from LCSH subject headings.
        Strip it down to only the scientific name and copy into the GBIF topic element.
        -->
        <xsl:variable name="gbif_text" select="text()" />
        <xsl:variable name="topic_text" select="../../mods:subject[@authority='lcsh']/mods:topic/text()" />
        <xsl:variable name="tokens" select="tokenize($topic_text, '; ')" />
        <xsl:variable name="bird_topics_raw" select="$tokens[contains(., '|')]" />
        <xsl:variable name="bird_topics_filtered">
            <xsl:for-each select="$bird_topics_raw">
                <xsl:sequence select="substring-before(., ' |')" />
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="bird_topics" select="normalize-space(string-join(tokenize($bird_topics_filtered, '\s+'), '; '))" />
        
        <topic xmlns="http://www.loc.gov/mods/v3">
            <xsl:choose>
                <xsl:when test="not($gbif_text)">
                    <xsl:value-of select="$bird_topics" />
                </xsl:when>
                <xsl:when test="not($bird_topics)">
                    <xsl:value-of select="$gbif_text" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$gbif_text"/>; <xsl:value-of select="$bird_topics" />
                </xsl:otherwise>
            </xsl:choose>
        </topic>
    </xsl:template>
    
    <xsl:template match="//mods:subject[@authority='lcsh']/mods:topic" exclude-result-prefixes="#all">
        <!--
        Remove tokens moved to GBIF topic elements from LCSH topic elements.
        -->
        <xsl:variable name="tokens" select="tokenize(text(), '; ')" />
        <topic xmlns="http://www.loc.gov/mods/v3">
            <xsl:value-of select="normalize-space(string-join($tokens[not(contains(., '|'))], '; '))"/>
        </topic>
    </xsl:template>
</xsl:stylesheet>