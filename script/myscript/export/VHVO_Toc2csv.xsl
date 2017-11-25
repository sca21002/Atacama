<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
	<xsl:output method="text" encoding="iso-8859-1" version="1.0" />
	   <xsl:variable name="pid" select="//root/@PID"/>
    <xsl:template match="/">
       <!--pid;ID;Kapitelueberschrift;ErsteSeite;LetzteSeite;Anzahl_Seiten;PID_ersteSeite;Anzahl_weitereGliederungsebenen;DeeplinkingUrl-->   
	   <!-- Beschränkung auf erste Gliederungsebene -->
	   <xsl:apply-templates select="//root/ch"/>
	</xsl:template>
<xsl:template match="ch">
    <!-- Mutmaßung Nr. 1: Abbildung kommt wohl als Zwischengliederung regulär vor und kann ignoriert werden -->
    <xsl:variable name="weitereEbenen" select="count(descendant::ch[@LABEL !='Abbildung'])"/>

	<xsl:value-of select="$pid"/>;<!--
	--><xsl:value-of select="@ID"/>;<!--
	-->&quot;<xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="@LABEL"/></xsl:call-template>&quot;;<!--
	-->&quot;<xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="descendant::pg[1]/@LABEL"/></xsl:call-template>&quot;;<!--
	-->&quot;<xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="descendant::pg[last()]/@LABEL"/></xsl:call-template>&quot;;<!--
	--><xsl:value-of select="count(descendant::pg)"/>;<!--
	--><xsl:value-of select="descendant::pg[1]/@PID"/>;<!--
  	--><xsl:value-of select="$weitereEbenen"/>;<!--
	--><xsl:text>http://digital.bib-bvb.de/webclient/DeliveryManager?custom_att_2=simple_viewer&amp;pid=</xsl:text><xsl:value-of select="$pid"/><xsl:text>&amp;childpid=</xsl:text><xsl:value-of select="descendant::pg[1]/@PID"/><!--
    --><xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'&quot;')">
          <xsl:value-of select="concat(substring-before($s,'&quot;'),'&quot;&quot;')"/>
          <xsl:call-template name="escape-quot-string">
            <xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
          </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
          <xsl:value-of select="$s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
	
</xsl:stylesheet>
