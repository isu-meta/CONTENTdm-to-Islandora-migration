<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- Templates for cleanup of ContentDM-to-MODS crosswalk output prior to ingest to Islandora.  -->
    
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
                <xsl:when test="$call_number='MS 21'">
                    <xsl:text>https://n2t.net/ark:/87292/w95n0d</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 105'">
                    <xsl:text>https://n2t.net/ark:/87292/w93f3v</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 109'">
                    <xsl:text>https://n2t.net/ark:/87292/w9q453</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 204'">
                    <xsl:text>https://n2t.net/ark:/87292/w9047b</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 481'">
                    <xsl:text>https://n2t.net/ark:/87292/w9rf44</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 588'">
                    <xsl:text>https://n2t.net/ark:/87292/w93f5m</xsl:text>
                </xsl:when>
                <xsl:when test="$call_number='MS 595'">
                    <xsl:text>https://n2t.net/ark:/87292/w99x9t</xsl:text>
                </xsl:when>
            </xsl:choose>
        </identifier>
    </xsl:template>
    
    <xsl:template match="mods:title | mods:abstract" exclude-result-prefixes="#all">
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
    
    <xsl:template match="//mods:subject[@authority = 'naf']" exclude-result-prefixes="#all">
        <!-- 
        Split corporate and personal subject names.
        -->
        <xsl:variable name="tokens" select="tokenize(mods:name/mods:namePart/text(), ';')" />
        <xsl:variable name="personal_names" select="$tokens[contains(., ',')]" />
        <xsl:variable name="corporate_names" select="$tokens[not(contains(., ','))]" />
        
        <subject authority="naf" xmlns="http://www.loc.gov/mods/v3">
            <xsl:for-each select="$personal_names">
                <name type="personal" xmlns="http://www.loc.gov/mods/v3">
                    <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(.)" /></namePart>
                </name>
            </xsl:for-each>
            
            <xsl:for-each select="$corporate_names">
                <name type="corporate" xmlns="http://www.loc.gov/mods/v3">
                    <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(.)" /></namePart>
                </name>
            </xsl:for-each>
        </subject>
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