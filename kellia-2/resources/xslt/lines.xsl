<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:template match="/">
        <xsl:call-template name="sourceDoc"/>
    </xsl:template>
    <xsl:template name="sourceDoc">
        <!--<xsl:value-of select="TEI/teiHeader//title/text()"/>-->
        <xsl:for-each select="//sourceDoc/surface">
            <div class="surface">
                <xsl:apply-templates/>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="zone">
        <span class="zone">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="line">
        <div class="line">
            <canvas class="res" style="font-size: 25px; vertical-align: 5px">
                <xsl:value-of select="."/>
            </canvas>
        </div>
    </xsl:template>
</xsl:stylesheet>