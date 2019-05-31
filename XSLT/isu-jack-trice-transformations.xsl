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
        Strip trailing ";" from genre text, then add a typeofResource field after 
        <genre authority="dct"> mapping the Dublin Core Type to the MODS typeOfResource 
        vocabulary following the Library of Congress guidelines provided here: 
        http://www.loc.gov/standards/mods/mods-dcsimple.html.
        -->
        <xsl:variable name="dc_type" select="lower-case(substring-before(text(), ';'))" />
        <xsl:variable name="type_of_resource">
            <xsl:choose>
                <xsl:when test="'text' = $dc_type">
                    <xsl:text>text</xsl:text>
                </xsl:when>
                <xsl:when test="'image' = $dc_type or 'stillimage' = $dc_type">
                    <xsl:text>still image</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- 
                        If the DC type isn't one of the above options, it's blank. 
                    -->
                    <xs:text>
                        <xsl:value-of select="$dc_type" />
                    </xs:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <genre authority="dct" xmlns="http://www.loc.gov/mods/v3">
            <xsl:value-of select="concat(upper-case(substring($dc_type, 1, 1)), substring($dc_type, 2))"/>
        </genre>
        <typeOfResource xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$type_of_resource" /></typeOfResource>
    </xsl:template>
    
    <xsl:template match="mods:title | cdm:title | mods:abstract | cdm:description | cdm:transcription" exclude-result-prefixes="#all">
        <!--
        Remove double-quotes from a tag's text.
        
        This template replaces '""' with a single double
        quote ('"').
        -->
        <xsl:variable name="tag_text" select="text()" />
        <xsl:variable name="too_many_quotes">("|&amp;quot;)+</xsl:variable>
        <xsl:variable name="quote_string">"</xsl:variable>
        <xsl:copy>
            <xsl:value-of select="replace($tag_text, $too_many_quotes, $quote_string)" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//mods:name[mods:role/mods:roleTerm/text() = 'Contributing Institution']/mods:namePart[text()='University Museums']/text()" exclude-result-prefixes="#all">
        <!-- 
        Replace "University Museums" with the LC NAF form.
        -->
        <xsl:text>Iowa State University. University Museums</xsl:text>
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
        <xsl:variable name="names" select="$tokens[contains(., ',')]" />
        <subject authority="lcsh" xmlns="http://www.loc.gov/mods/v3">
            <topic xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="replace(string-join($topics, ';'), ' *-- *', '--')" /></topic>
        </subject>
        <subject authority="naf" xmlns="http://www.loc.gov/mods/v3">
            <name type="personal" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="string-join($names, ';')" /></namePart>
            </name>
        </subject>
    </xsl:template>
    
    <xsl:template match="//mods:physicalDescription[@displayLabel='imt-wrapper']" exclude-result-prefixes="#all">
        <!--
        Combine two fields into one to overcome limitations of the MODS mapping template.
        -->
        <xsl:variable name="imt-prefix" select="mods:note[@type='imt-prefix']/text()" />
        <xsl:variable name="imt-suffix" select="mods:note[@type='imt-suffix']/text()" />
        <genre authority="imt" xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$imt-prefix" />/<xsl:value-of select="$imt-suffix"/></genre>
    </xsl:template>
        
</xsl:stylesheet>