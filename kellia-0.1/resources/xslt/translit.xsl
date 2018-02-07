<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:template match="/">
        <xsl:call-template name="body"/>
    </xsl:template>
    <xsl:template name="body">
        <!--<xsl:value-of select="TEI/teiHeader//title/text()"/>-->
        <xsl:for-each select="TEI//text/body/div[@type = 'transcription']//ab[@type = 'line']">
            <tr class="line">
                <xsl:apply-templates/>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="w">
        <td>
            <xsl:if test="@corresp">
                <xsl:variable name="pointer" select="tokenize(replace(@corresp, '#', ''), ' ')"/>
                <!-- <xsl:value-of select="count($pointer)" /> -->
                <span class="hiero">
                    <canvas class="res" style="font-size: 25px; vertical-align: 5px">
                        <xsl:value-of select="ancestor::TEI//*[@xml:id = $pointer]/text()"/>
                    </canvas>
                </span>
                <br/>
            </xsl:if>
            <span class="word">
                <xsl:apply-templates/>
            </span>
        </td>
    </xsl:template>
    <xsl:template match="ab[@type = 'line']/text()">
        <td>
            <xsl:value-of select="."/>
        </td>
    </xsl:template>
</xsl:stylesheet>