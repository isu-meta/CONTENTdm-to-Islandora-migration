<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="* | @*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | * | text() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match='//mods:genre[@authority="dct"]' exclude-result-prefixes="#all">
        <!--
        Add a typeofResource field after <genre authority="dct"> mapping the
        Dublin Core Type to the MODS typeOfResource vocabulary following the
        Library of Congress guidelines provided here: 
        http://www.loc.gov/standards/mods/mods-dcsimple.html.
        -->
        <xsl:variable name="dc_type" select="lower-case(text())" />
        <xsl:variable name="type_of_resource">
            <xsl:choose>
                <xsl:when test="'text' = $dc_type">
                    <xsl:text>text</xsl:text>
                </xsl:when>
                <xsl:when test="'image' = $dc_type or 'stillimage' = $dc_type">
                    <xsl:text>still image</xsl:text>
                </xsl:when>
                <xsl:when test="'movingimage' = $dc_type">
                    <xsl:text>moving image</xsl:text>
                </xsl:when>
                <xsl:when test="'physicalobject' = $dc_type">
                    <xsl:text>three dimensional object</xsl:text>
                </xsl:when>
                <xsl:when test="'sound' = $dc_type">
                    <xsl:text>sound recording</xsl:text>
                </xsl:when>
                <xsl:when test="'' = $dc_type">
                    <xs:text>
                        <xsl:value-of select="$dc_type" />
                    </xs:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
        <typeOfResource xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$type_of_resource" /></typeOfResource>
    </xsl:template>
    
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
    
    <xsl:template match="//mods:subject[@authority='gbif']/mods:topic" exclude-result-prefixes="#all">
        <!--
        Copy topics with the format "Scientific_name | Common_name" from LCSH subject headings.
        Strip it down to only the scientific name and copy into the GBIF topic element.
        -->
        <xsl:variable name="gbif_text" select="text()" />
        <xsl:variable name="topic_text" select="../../mods:subject[@authority='lcsh']/mods:topic/text()" />
        <xsl:variable name="tokens" select="tokenize($topic_text, ';')" />
        <xsl:variable name="bird_topics_raw" select="$tokens[contains(., '|')]" />
        <xsl:variable name="bird_topics_filtered">
            <xsl:for-each select="$bird_topics_raw">
                <xsl:sequence select="substring-before(., ' |')" />
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="bird_topics" select="normalize-space(string-join(tokenize($bird_topics_filtered, '\s'), '; '))" />
        
        <topic xmlns="http://www.loc.gov/mods/v3">
            <xsl:choose>
                <xsl:when test="not($gbif_text)">
                    <xsl:value-of select="$bird_topics" />
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
        <xsl:variable name="tokens" select="tokenize(text(), ';')" />
        <topic xmlns="http://www.loc.gov/mods/v3">
            <xsl:value-of select="normalize-space(string-join($tokens[not(contains(., '|'))], ';'))"/>
        </topic>
    </xsl:template>
    
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
    
    <xsl:template match="//mods:name[mods:role/mods:roleTerm/text() = 'creator']" exclude-result-prefixes="#all">
        <!-- 
        Split corporate and personal creator names.
        -->
        <xsl:variable name="tokens" select="tokenize(mods:namePart/text(), ';')" />
        <xsl:variable name="personal_names" select="$tokens[contains(., ',')]" />
        <xsl:variable name="corporate_names" select="$tokens[not(contains(., ','))]" />
        
        <name type="personal" xmlns="http://www.loc.gov/mods/v3">
            <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($personal_names, ';'))" /></namePart>
            <role xmlns="http://www.loc.gov/mods/v3">
                <roleTerm authority="marcrelator" xmlns="http://www.loc.gov/mods/v3">creator</roleTerm>
            </role>
        </name>
        <name type="corporate" xmlns="http://www.loc.gov/mods/v3">
            <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($corporate_names, ';'))" /></namePart>
            <role xmlns="http://www.loc.gov/mods/v3">
                <roleTerm authority="marcrelator" xmlns="http://www.loc.gov/mods/v3">creator</roleTerm>
            </role>
        </name>
    </xsl:template>
    
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