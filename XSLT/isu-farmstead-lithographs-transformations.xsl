<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- Template for cleanup of ContentDM-to-MODS crosswalk output prior to ingest to Islandora.  -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="* | @*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | * | text() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match='//mods:genre[@authority="dct"]' exclude-result-prefixes="#all">
        <!--
        All items are of DC Type "Image" in the farmstead lithograph collection.
        -->
        <genre authority="dct" xmlns="http://www.loc.gov/mods/v3">
            <xsl:text>Image</xsl:text>
        </genre>
        <typeOfResource xmlns="http://www.loc.gov/mods/v3"><xsl:text>still image</xsl:text></typeOfResource>
    </xsl:template>

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

    <xsl:template match="//mods:subject[mods:topic]" exclude-result-prefixes="#all">
        <!--
        Split the topic element contents. Move the personal names out of topics
        and into their own subject field.
        
        Additionally, clean up formatting by removing unnecessary spaces. Remove
        the space before semicolons and around the double-hyphen that joins complex
        subject headings.
        -->
        <xsl:variable name="tokens" select="tokenize(mods:topic/text(), ' *;')" />
        <xsl:variable name="topics" select="$tokens[not(contains(., ','))]" />
        <xsl:variable name="names" select="$tokens[contains(., ',') and not(contains(., 'Mount Prospect Farm (Johnson County, Iowa)'))]" />
        <xsl:variable name="farm" select="$tokens[contains(., 'Mount Prospect Farm (Johnson County, Iowa)')]" />
        <subject authority="lcsh" xmlns="http://www.loc.gov/mods/v3">
            <topic xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="replace(string-join($topics, ';'), ' *-- *', '--')" /></topic>
        </subject>
        <subject authority="naf" xmlns="http://www.loc.gov/mods/v3">
            <name type="personal" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($names, ';'))" /></namePart>
            </name>
        </subject>
        <subject authority="naf" xmlns="http://www.loc.gov/mods/v3">
            <name type="corporate" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($farm, ''))" /></namePart>
            </name>
        </subject>
    </xsl:template>

    <xsl:template match="mods:title | cdm:title | mods:abstract | cdm:description | cdm:transcription" exclude-result-prefixes="#all">
        <!--
        Remove double-quotes from a tag's text.
        
        This template replaces '&amp;quot;&amp;quot;' with a single 
        quotation mark ('"').
        -->
        <xsl:variable name="tag_text" select="text()" />
        <xsl:variable name="too_many_quotes">(&amp;quot;)+</xsl:variable>
        <xsl:variable name="quote_string">"</xsl:variable>
        <xsl:copy>
            <xsl:value-of select="replace($tag_text, $too_many_quotes, $quote_string)" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mods:relatedItem[@displayLabel='Collection']/mods:identifier[@displayLabel='Call Number']" exclude-result-prefixes="#all">
        <!--
        Add <identifier type="ark"> element based on the collection's call number.
        -->
        <xsl:variable name="call_number" select="text()" />
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
        <identifier type="ark" xmlns="http://www.loc.gov/mods/v3">
            <xsl:choose>
                <xsl:when test="$call_number='MS 390'">
                    <xsl:text>https://n2t.net/ark:/87292/w95x86</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 194'">
                    <xsl:text>https://n2t.net/ark:/87292/w94x98</xsl:text>
                </xsl:when>
            </xsl:choose>
        </identifier>
</xsl:template>
</xsl:stylesheet>