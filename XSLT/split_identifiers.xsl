<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <xsl:output method="xml" indent="yes" />
  <!-- Splits identifiers like 
  <identifier>0694b001f001i019&lt;br&gt;https://n2t.net/ark:/87292/w9h01b</identifier> 
  into <identifierLocal>0694b001f001i019</identifierLocal>
  and <identifierARK>https://n2t.net/ark:/87292/w9h01b</identifierARK>, removing
  the original identifier element. All other elements are copied unchanged. -->
  <xsl:mode on-no-match="shallow-copy" />
  <xsl:template name="split-identifier" match="identifier">
    <xsl:variable name="id_txt" select="text()" />
      <xsl:variable name="first_id" select="substring-before($id_txt, '&lt;')" />
      <xsl:variable name="second_id" select="substring-after($id_txt, '&gt;')" />
      <xsl:choose>
	<xsl:when test="contains($first_id, 'http')">
	  <identifierLocal><xsl:value-of select="$second_id" /></identifierLocal>
	  <identifierARK><xsl:value-of select="$first_id" /></identifierARK>
        </xsl:when>
	<xsl:when test="contains($second_id, 'http')">
	  <identifierLocal><xsl:value-of select="$first_id" /></identifierLocal>
	  <identifierARK><xsl:value-of select="$second_id" /></identifierARK>
        </xsl:when>
	<xsl:otherwise>
	  <identifierLocal><xsl:value-of select="$id_txt" /></identifierLocal>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="identifier" />
  </xsl:template>
</xsl:stylesheet>
    
