<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <!--
    SIMPLE SPLITTING TEMPLATES: this document is a collection of templates to split up semicolon-
    delimited fields into seperate XML nodes. They do no additional clean up.
    -->

    <xsl:template match="//mods:subject[@authority='lcsh']/mods:topic" exclude-result-prefixes="#all">
        <!--
        Split semicolon-delimited LCSH subject topics into their own nodes.
        -->
        <xsl:variable name="tokens" select="tokenize(text(), '; ')" />
        <xsl:for-each select="$tokens">
            <topic xmlns="http://www.loc.gov/mods/v3">
                <xsl:value-of select="normalize-space(.)"/>
            </topic>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="//mods:subject[@authority='lcsh']/mods:geographic" exclude-result-prefixes="#all">
        <!--
        Split semicolon-delimited LCSH geographic subjects into their own nodes.
        -->
        <xsl:variable name="tokens" select="tokenize(text(), '; ')" />
        <xsl:for-each select="$tokens">
            <geographic xmlns="http://www.loc.gov/mods/v3">
                <xsl:value-of select="normalize-space(.)"/>
            </geographic>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="//mods:subject[@authority='local']/mods:geographic" exclude-result-prefixes="#all">
        <!--
        Split semicolon-delimited local geographic subjects into their own nodes.
        -->
        <xsl:variable name="tokens" select="tokenize(text(), '; ')" />
        <xsl:for-each select="$tokens">
            <geographic xmlns="http://www.loc.gov/mods/v3">
                <xsl:value-of select="normalize-space(.)"/>
            </geographic>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="//mods:subject/mods:temporal" exclude-result-prefixes="#all">
        <!--
        Split semicolon-delimited temporal subjects into their own nodes.
        -->
        <xsl:variable name="tokens" select="tokenize(text(), '; ')" />
        <xsl:for-each select="$tokens">
            <temporal xmlns="http://www.loc.gov/mods/v3">
                <xsl:value-of select="normalize-space(.)"/>
            </temporal>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mods:genre[@authority='aat']" exclude-result-prefixes="#all">
        <!-- Split semicolon-delimited AAT genre terms into their own nodes. -->
        <xsl:variable name="tokens" select="tokenize(text(), ';')" />
        <xsl:for-each select="$tokens">
            <genre authority="aat" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(.)" /></genre>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>