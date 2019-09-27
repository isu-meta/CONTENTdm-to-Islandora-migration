<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    <xsl:template match="//mods:physicalDescription[@displayLabel='imt-wrapper']" exclude-result-prefixes="#all">
        <!--
        Combine split IMT/MIME type into single field.
        -->
        <xsl:variable name="imt-prefix" select="mods:note[@type='imt-type-prefix']/text()" />
        <xsl:variable name="imt-suffix" select="mods:note[@type='imt-type']/text()" />
        <genre authority="imt" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$imt-prefix" />/<xsl:value-of select="$imt-suffix"/></genre>
    </xsl:template>
</xsl:stylesheet>