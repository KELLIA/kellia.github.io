<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>

        <html lang="de">
            <head>
                <meta charset="utf-8"/>
                <title> Kellia </title>
                <link rel="stylesheet" href="digitale_editionen.css"/>

                <!-- Latest compiled and minified CSS -->
                <link rel="stylesheet"
                    href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
                    integrity="sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ=="
                    crossorigin="anonymous"/>

                <!-- Optional theme -->
                <link rel="stylesheet"
                    href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css"
                    integrity="sha384-aUGj/X2zp5rLCbBxumKTCw2Z50WgIr1vs/PFN4praOTvYXWlVyh2UtNUU0KAUhAX"
                    crossorigin="anonymous"/>

                <!-- Latest compiled and minified JavaScript -->
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"/>
            </head>
            <body>
                <div class="container">
                    <h1>Kellia: Projects</h1>
                    <p>Desciption</p>
                    <xsl:apply-templates/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="projects">
        <div class="section">
            <p>
                <xsl:value-of select="count(//project)"/>
                <xsl:text> projects in list</xsl:text>
            </p>
            <table class="table table-hover">
                <tr class="active">
                    <th>project</th>
                    <th>tags</th>
                </tr>
                <xsl:call-template name="project-sort"/>
            </table>

        </div>
    </xsl:template>

    <xsl:template name="project-sort">
        <!--<xsl:param name="type"/>-->
        <xsl:for-each select="project">
            <xsl:sort select="normalize-space(upper-case(title))"/>

            <xsl:variable name="tags" select="tokenize(normalize-space(tag), '\s+')"/>


            <tr class="project-head info">
                <td>

                    <h3 style="display: inline-block; margin-bottom: 10px; margin-top:10px;">
                        <!--<xsl:number level="multiple" format="1. "/>-->
                        <xsl:apply-templates select="title"/>
                    </h3>
                </td>
                <td>
                    <sup>
                        <xsl:for-each select="$tags">
                            <xsl:value-of select="."/>
                            <xsl:if test="not(position() = last())">, </xsl:if>
                        </xsl:for-each>
                    </sup>
                </td>
            </tr>
            <tr class="project-data">
                <td colspan="2" style="padding-bottom: 30px;">
                    <xsl:choose>
                        <xsl:when test="data">
                            <section class="data">
                                <xsl:apply-templates select="data"/>
                            </section>
                        </xsl:when>
                        <xsl:otherwise> no export format available </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>



    <xsl:template match="project/title">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="parent::project/@url"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="project/data">
        <div class="row">
            <xsl:apply-templates select="dataSet"/>
        </div>
    </xsl:template>

    <xsl:template match="dataSet">
        <div class="col-md-2">
            <div class="data-set">
                <span>
                    <strong>
                        <xsl:value-of select="@type"/>
                    </strong>
                    <xsl:text> (</xsl:text>
                    <em>
                        <xsl:value-of select="@format"/>
                    </em>
                    <xsl:text>)</xsl:text>
                </span>
                <ul>
                    <xsl:apply-templates select="resource"/>
                </ul>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="resource">
        <li>
            <xsl:choose>
                <xsl:when test="parent::dataSet[@format='html']">
                    <xsl:choose>
                        <xsl:when test="url">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="url/text()"/>
                                </xsl:attribute>HTML</a>
                        </xsl:when>
                        <xsl:otherwise>HTML</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="url">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="url/text()"/>
                                </xsl:attribute>
                                <xsl:value-of select="formatDesc"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="formatDesc"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="standards"/>

</xsl:stylesheet>
