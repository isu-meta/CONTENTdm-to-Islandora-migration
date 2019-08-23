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
    
    <xsl:template match="//mods:mods[matches(mods:titleInfo/mods:title/text(), '(RS-13-20-51.*|Page [1-9]+)')]/mods:note[@type='transcript']" exclude-result-prefixes="#all">
        <!--
        Copy the value of mods:abstract into mods:note[@type="transcript"] for records with matching titles.
        -->
        <note type="transcript" xmlns="http://www.loc.gov/mods/v3">
               <xsl:value-of select="../mods:abstract" />
        </note>
    </xsl:template>
    
    <xsl:template match="//mods:mods[matches(mods:titleInfo/mods:title/text(), '(RS-13-20-51.*|Page [1-9]+)')]/mods:abstract" exclude-result-prefixes="#all">
        <!--
        Once the value of mods:abstract has been copied in the above template, delete it.
        -->
        <abstract xmlns="http://www.loc.gov/mods/v3" />
    </xsl:template>
    
    <xsl:template match="//mods:subject[mods:topic]" exclude-result-prefixes="#all">
        <!--
        Split the topic element contents. Move events and personal and corporate names out
        of topics and into their own subject fields.
        -->
        <xsl:variable name="tokens" select="tokenize(mods:topic/text(), ';')" />
        <xsl:variable name="corporate_names_p" select="'(Iowa State University($|[^-]+)|Iowa State College|University of Missouri|U\.S\. Naval Ordnance Laboratory Test Facility \(Md\.\)|Iowa State Board of Education|United States\. Navy Department\. Bureau of Ships|IBM Personal Computer Company|Sperry Rand \(Corporation\))'" />
        <xsl:variable name="events_p" select="'VEISHEA'" />
        <xsl:variable name="local_topics_p" select="'Atanasoff-Berry Computer'" />
        <xsl:variable name="topics" select="$tokens[not(contains(., ',')) and not(matches(., $corporate_names_p)) and not(matches(., $events_p)) and not(matches(., $local_topics_p)) and not(matches(., '^$'))]" />
        <xsl:variable name="personal_names" select="$tokens[contains(., ',')]" />
        <xsl:variable name="corporate_names" select="$tokens[matches(., $corporate_names_p)]" />
        <xsl:variable name="events" select="$tokens[matches(., $events_p)]" />
        <xsl:variable name="local_topics" select="$tokens[matches(., $local_topics_p)]" />
        <subject authority="lcsh" xmlns="http://www.loc.gov/mods/v3">
            <topic xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($topics, ';'))" /></topic>
        </subject>
        <subject xmlns="http://www.loc.gov/mods/v3" authority="local">
            <topic xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($local_topics, ';'))"/></topic>
        </subject>
        <subject authority="naf" xmlns="http://www.loc.gov/mods/v3">
            <name type="personal" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($personal_names, ';'))" /></namePart>
            </name>
            <name type="corporate" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="normalize-space(string-join($corporate_names, ';'))" /></namePart>
            </name>
        </subject>
        <subject xmlns="http://www.loc.gov/mods/v3">
            <name type="conference" xmlns="http://www.loc.gov/mods/v3">
                <namePart xmlns="http://www.loc.gov/mods/v3">
                    <xsl:value-of select="normalize-space(string-join($events, ';'))" />
                </namePart>
            </name>
        </subject>
    </xsl:template>
</xsl:stylesheet>