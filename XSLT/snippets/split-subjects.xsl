<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <xsl:template match="//mods:subject[mods:topic]" exclude-result-prefixes="#all">
        <!--
        Split the topic element contents. Move events and personal and corporate names out
        of topics and into their own subject fields.
        -->
        <xsl:variable name="tokens" select="tokenize(mods:topic/text(), ';')" />
        <xsl:variable name="corporate_names_p" select="'*** INSERT PATTERN FOR CORPORATE NAMES ***'" />
        <xsl:variable name="events_p" select="'*** INSERT PATTERN FOR EVENT NAMES ***'" />
        <xsl:variable name="topics" select="$tokens[not(contains(., ',')) and not(matches(., $corporate_names_p)) and not(matches(., $events_p))]" />
        <xsl:variable name="personal_names" select="$tokens[contains(., ',')]" />
        <xsl:variable name="corporate_names" select="$tokens[matches(., $corporate_names_p)]" />
        <xsl:variable name="events" select="$tokens[matches(., $events_p)]" />
        <subject authority="lcsh" xmlns="http://www.loc.gov/mods/v3">
            <topic xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="string-join($topics, ';')" /></topic>
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