<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.uni-goettingen.de/kellia">
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="/">


        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>

        <html lang="de">
            <head>
                <meta charset="utf-8"/>
                <title>Kellia - digital editions (eDitions)</title>
                <!--<link rel="stylesheet" href="digitale_editionen.css"/>-->

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
                        <div class="col-md-12 description">
                            <h3>Project Description</h3>
                            <xsl:apply-templates select="projectDesc/desc"/>
                        </div>
                    </div>
                    <!--<div class="row">
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
                    </div>-->
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
                            <xsl:apply-templates select="revision"/>
                        </div>
                        <div class="col-md-4"> </div>
                        <div class="col-md-4"> </div>
                    </div>

                </div>
            </div>
            <!--</div>-->
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="projectDesc/desc">
        <div class="desc col-md-12">
            <xsl:choose>
                <xsl:when test="@source">
                    <strong>Description from <a>
                            <xsl:variable name="source-url"
                                select="translate(@source, '&amp;', '&amp;')"/>
                            <xsl:attribute name="href" select="$source-url"
                                > </xsl:attribute><xsl:value-of select="@source"/></a>: </strong>
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </xsl:when>
                <xsl:when test="@resp">
                    <xsl:variable name="resp_id" select="upper-case(substring-after(@resp, '#'))"/>

                    <xsl:variable name="researcher-path" select="//kelliaHead/researcher/@path"/>
                    <xsl:variable name="researchers-xml"
                        select="document(concat('../xml-data/', $researcher-path))"/>

                    <strong>Kellia-Description from <xsl:choose>
                            <xsl:when
                                test="$researchers-xml//researcher//person[@xml:id = $resp_id]">
                                <xsl:variable name="person"
                                    select="$researchers-xml//researcher//person[@xml:id = $resp_id]"/>
                                <xsl:variable name="resp_name" select="$person/name"/>
                                <xsl:variable name="resp_mail" select="$person/email"/>
                                <xsl:variable name="resp_desc" select="$person/desc"/>
                                <a>
                                    <xsl:attribute name="href" select="concat('mailto:', $resp_mail)"/>
                                    <xsl:attribute name="title" select="$resp_desc" />
                                    <xsl:value-of select="$resp_name"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>Unknown researcher (add to <xsl:value-of
                                    select="concat('../xml-data/', $researcher-path)"
                                />)
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>:</xsl:text>
                    </strong>


                    <div style="margin-left: 10px">
                        <xsl:call-template name="pro_desc"/>
                    </div>
                </xsl:when>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <!--<xsl:template match="@resp">
        <xsl:variable name="resp_id" select="upper-case(substring-after(@resp, '#'))"/>
        
        <xsl:variable name="researcher-path" select="//kelliaHead/researcher/@path"/>
        <xsl:variable name="researchers-xml"
            select="document(concat('../xml-data/', $researcher-path))"/>
        
        <xsl:variable name="person"
            select="$researchers-xml//researcher//person[@xml:id = $resp_id]"/>
        <xsl:variable name="resp_name" select="$person/name"/>
        <xsl:variable name="resp_mail" select="$person/email"/>
        
        <a><xsl:attribute name="href" select="concat('mailto:', $resp_mail)"
        /><xsl:value-of select="$resp_name"/></a>
    </xsl:template>-->

    <xsl:template name="pro_desc">

        <table class="table table-striped">
            <tr>
                <xsl:if test="searchWord">
                    <th>SearchWord (<xsl:value-of select="searchWord/@key"/>)</th>
                </xsl:if>
                <xsl:if test="kelliaRating">
                    <th>KelliaRating</th>
                </xsl:if>
                <xsl:if test="goal">
                    <th>Project aims</th>
                </xsl:if>
                <xsl:if test="institution">
                    <th>Institution</th>
                </xsl:if>
            </tr>
            <tr>
                <xsl:if test="searchWord">
                    <td>
                        <xsl:value-of select="searchWord"/>
                    </td>
                </xsl:if>
                <xsl:if test="kelliaRating">
                    <td><xsl:value-of select="kelliaRating"/><xsl:text> </xsl:text>(
                                <strong><xsl:value-of select="kelliaRating/@points"/></strong>
                        <xsl:text> </xsl:text>
                        <img src="star.png" alt=""/> )</td>
                </xsl:if>
                <xsl:if test="goal">
                    <td>
                        <xsl:value-of select="goal"/>
                    </td>
                </xsl:if>
                <xsl:if test="institution">
                    <td>
                        <xsl:value-of select="institution"/>
                        <xsl:text> </xsl:text> (<xsl:value-of select="institution/@role"/>) </td>
                </xsl:if>
            </tr>
        </table>
        <xsl:apply-templates select="respStmt"/>

    </xsl:template>



    <xsl:template match="projectDesc/title">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="ancestor::project/@url"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- Revisionsbeschreibungen -->
    <xsl:template match="revision">
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
        <div>
            <strong>Responsibilities:<br/></strong>
            <xsl:value-of select="resp"/>
            <ul>
                <xsl:for-each select="person">
                    <li>
                        <xsl:apply-templates select="."/>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
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
            <h3> Dataset <xsl:number format="1" count="dataSet"/>
            </h3>
            <xsl:if test="@type and string-length(@type) &gt; 0">
                <strong>
                    <xsl:value-of select="@type"/>
                </strong>
                <xsl:text> | </xsl:text>
            </xsl:if>
            <xsl:for-each select="url">
                <xsl:value-of select="@type"/>
                <xsl:text>: </xsl:text>
                <a>
                    <xsl:attribute name="href" select="@target"/>
                    <xsl:value-of select="@target"/>
                </a>
                <br/>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="desc">
                    <xsl:apply-templates select="desc"/>
                </xsl:when>
                <xsl:otherwise> no description </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="example">
                    <h4>Datasample</h4>
                    <xmp>
                        <!--<xsl:text>&lt;![CDATA[</xsl:text>-->
                        <xsl:apply-templates select="example"/>
                        <!--<xsl:text>]]&gt;</xsl:text>-->
                    </xmp>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="example//*">

        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates/>
        </xsl:copy>



    </xsl:template>

    <xsl:template match="ref">
        <a>
            <xsl:attribute name="href" select="@target"/>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="standards"/>
    <xsl:template match="formats"/>

</xsl:stylesheet>
