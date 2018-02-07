<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xpath-default-namespace="http://www.uni-goettingen.de/kellia">
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>

        <html lang="de">
            <head>
                <meta charset="utf-8"/>
                <title>Kellia - digital editions (eDitions)</title>
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
                    <h1>KELLIA[eDitions]: Projects</h1>
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
            <div id="projects" class="container-fluid">
                <xsl:call-template name="project-sort"/>
            </div>

        </div>
    </xsl:template>

    <xsl:template name="project-sort">
        <!--<xsl:param name="type"/>-->
        <xsl:for-each select="project">
            <xsl:sort select="normalize-space(upper-case(projectDesc/title))"/>

            <xsl:variable name="tags" select="tokenize(normalize-space(tag), '\s+')"/>


            <!--<div class="row project">-->
            <div class="panel panel-primary">
                <div class="panel-heading project-head">
                    <h3 class="panel-title">
                        <xsl:apply-templates select="projectDesc/title"/>
                    </h3>
                </div>
                <div class="panel-body project-body">
                    <div class="row">
                        <div class="col-md-4">
                            <xsl:for-each select="projectDesc/desc/respStmt">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </div>
                        <div class="col-md-4">
                            <strong>rating:</strong>
                        </div>
                        <div class="col-md-4">
                            <strong>Dates:</strong>
                            <br/>
                            <xsl:for-each select="projectDesc/dates/date">
                                <xsl:value-of select="@when"/>: <xsl:value-of select="."/><br/>
                            </xsl:for-each>
                        </div>
                    </div>
                    <xsl:choose>
                        <xsl:when test="dataDesc">
                            <xsl:apply-templates select="dataDesc"/>
                        </xsl:when>
                        <xsl:otherwise> no export format available </xsl:otherwise>
                    </xsl:choose>
                </div>
                <div class="panel-footer">
                    <!--<h5>metadata:</h5>-->
                    <div class="row">
                        <div class="col-md-4">
                            <xsl:apply-templates select="revisionDesc"/>
                        </div>
                        <div class="col-md-4"> </div>
                        <div class="col-md-4"> </div>
                    </div>

                </div>
            </div>
            <!--</div>-->
        </xsl:for-each>
    </xsl:template>



    <xsl:template match="projectDesc/title">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="ancestor::projectData/@url"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- Revisionsbeschreibungen -->
    <xsl:template match="revisionDesc">
        <ul>
            <xsl:for-each select="date">
                <li>
                    <xsl:value-of select="@when"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="."/>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>

    <xsl:template match="respStmt">
        <xsl:value-of select="resp"/>
        <ul>
            <xsl:for-each select="person">
                <li>
                    <xsl:apply-templates select="."/>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>



    <xsl:template match="person">
        <xsl:value-of select="name"/>
        <xsl:choose>
            <xsl:when test="email or web">
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="email and web">
                        <a>
                            <xsl:attribute name="href" select="web"/> web </a>
                        <xsl:text> | </xsl:text>
                        <a>
                            <xsl:attribute name="href" select="web"/> web </a>
                    </xsl:when>
                    <xsl:when test="email">
                        <a>
                            <xsl:attribute name="href" select="email"/> mail </a>
                    </xsl:when>
                    <xsl:when test="web">
                        <a>
                            <xsl:attribute name="href" select="web"/> web </a>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dataDesc">
        <div class="row data">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="dataSet">
        <div class="col-md-12 data-set">
            <xsl:if test="@type and string-length(@type) &gt; 0">
                <strong>
                    <xsl:value-of select="@type"/>
                </strong>
                <xsl:text> | </xsl:text>
            </xsl:if>
            <xsl:for-each select="url">
                <xsl:value-of select="@type" />
                <xsl:text>: </xsl:text>
                <a>
                    <xsl:value-of select="@target" />
                </a><br></br>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="desc">
                    <xsl:apply-templates select="desc" />
                </xsl:when>
                <xsl:otherwise>
                    no descrition
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="ref">
        <a>
            <xsl:attribute name="href" select="@target" />
            <xsl:apply-templates />
        </a>
    </xsl:template>

    <xsl:template match="resource">
        <li>
            <xsl:choose>
                <xsl:when test="parent::dataSet[@format = 'html']">
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
    <xsl:template match="formats"/>

</xsl:stylesheet>
