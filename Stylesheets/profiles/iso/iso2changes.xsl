<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:cals="http://www.oasis-open.org/specs/tm9901"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:iso="http://www.iso.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:tbx="http://www.lisa.org/TBX-Specification.33.0.html"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:h="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="tei cals tbx"
                version="2.0">
   <xsl:import href="isoutils.xsl"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
      <desc>

         <p> This library is free software; you can redistribute it and/or
      modify it under the terms of the GNU Lesser General Public License as
      published by the Free Software Foundation; either version 2.1 of the
      License, or (at your option) any later version. This library is
      distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
      without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
      PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
      details. You should have received a copy of the GNU Lesser General Public
      License along with this library; if not, write to the Free Software
      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA </p>
         <p>Author: See AUTHORS</p>
         <p>Id: $Id$</p>
         <p>Copyright: 2008, TEI Consortium</p>
      </desc>
   </doc>

   <xsl:param name="dpi">72</xsl:param>
   <xsl:key name="frontDiv" match="tei:div[ancestor::tei:front]" use="1"/>
   <xsl:key name="bodyDiv" match="tei:div[ancestor::tei:body]" use="1"/>
   <xsl:key name="backDiv" match="tei:div[ancestor::tei:back]" use="1"/>
   <xsl:output method="xhtml" encoding="utf-8"/>
   <xsl:template match="/tei:TEI">
      <xsl:variable name="today">
         <xsl:call-template name="whatsTheDate"/>
      </xsl:variable>
      <xsl:variable name="isotitle">
         <xsl:call-template name="generateTitle"/>
      </xsl:variable>
      <xsl:variable name="isonumber">
         <xsl:call-template name="getiso_documentNumber"/>
      </xsl:variable>
      <xsl:variable name="isopart">
         <xsl:call-template name="getiso_partNumber"/>
      </xsl:variable>
      <xsl:variable name="isoyear">
         <xsl:call-template name="getiso_year"/>
      </xsl:variable>
      <html>
         <head>
            <title>Report on 
    <xsl:value-of select="$isotitle"/>:
    <xsl:value-of select="$isoyear"/>:
    <xsl:value-of select="$isonumber"/>:
    <xsl:value-of select="$isopart"/>
            </title>
            <link href="iso.css" rel="stylesheet" type="text/css"/>
  
         </head>
         <body>
            <h1 class="maintitle">
	
	              <xsl:value-of select="$isotitle"/>:
	<xsl:value-of select="$isoyear"/>:
	<xsl:value-of select="$isonumber"/>:
	<xsl:value-of select="$isopart"/>
            </h1>
      
            <xsl:for-each select="tei:text/tei:front">
	              <xsl:apply-templates/>
	              <hr/>
            </xsl:for-each>
            <xsl:for-each select="tei:text/tei:body">
	              <xsl:apply-templates/>
	              <hr/>
            </xsl:for-each>
            <xsl:for-each select="tei:text/tei:back">
	              <xsl:apply-templates/>
            </xsl:for-each>
         </body>
      </html>
   </xsl:template>

   <xsl:template match="tei:div[not(@type='termHeading')]">
      <xsl:variable name="depth" select="count(ancestor::tei:div)+2"/>
      <xsl:variable name="stuff">
         <xsl:apply-templates/>
      </xsl:variable>
      <xsl:if test="$stuff/h:p">
         <xsl:element name="h{$depth}">
            <xsl:call-template name="head"/>
         </xsl:element>
         <xsl:copy-of select="$stuff"/>
      </xsl:if>
   </xsl:template>

   <xsl:template match="*">
      <xsl:apply-templates select="*"/>
   </xsl:template>

   <xsl:template match="tei:add|tei:del">
      <xsl:if test="not(preceding-sibling::tei:del|preceding-sibling::tei:add)">
         <p>
            <xsl:for-each select="parent::*">
               <xsl:choose>
                  <xsl:when test="preceding-sibling::tei:*[1][self::tei:addSpan]">
	                    <span class="add">ADD</span>
	                    <xsl:text> </xsl:text>
                  </xsl:when>
                  <xsl:when test="preceding-sibling::tei:*[1][self::tei:delSpan]">
	                    <span class="del">DELETE</span>
	                    <xsl:text> </xsl:text>
                  </xsl:when>
               </xsl:choose>
	      <xsl:call-template name="Identify"/>
            </xsl:for-each>
	 </p>
         <blockquote>
	   <xsl:for-each select="parent::*">
	     <xsl:apply-templates mode="show"/>
	   </xsl:for-each>
	 </blockquote>
      </xsl:if>
   </xsl:template>



   <xsl:template match="*" mode="show">
      <xsl:apply-templates mode="show"/>
   </xsl:template>


   <xsl:template match="tei:graphic" mode="show">

      <xsl:variable name="File">
	<xsl:value-of select="@url"/>
      </xsl:variable>
      <img src="{$File}">
	<xsl:if test="@width">
	  <xsl:call-template name="setDimension">
	    <xsl:with-param name="value">
	      <xsl:value-of select="@width"/>
	    </xsl:with-param>
	    <xsl:with-param name="name">width</xsl:with-param>
	  </xsl:call-template>
	</xsl:if>
	<xsl:if test="@height">
	  <xsl:call-template name="setDimension">
	    <xsl:with-param name="value">
	      <xsl:value-of select="@height"/>
	    </xsl:with-param>
	    <xsl:with-param name="name">height</xsl:with-param>
	  </xsl:call-template>
	</xsl:if>
      </img>
   </xsl:template>

   <xsl:template match="tei:add|tei:del" mode="show">
      <span class="{local-name()}">
         <xsl:apply-templates mode="show"/>
	 <span class="changeAttribution-{local-name()}">
	   <xsl:text> [</xsl:text>
	   <xsl:choose>
	     <xsl:when test="@type">
	       <xsl:value-of select="@type"/>
	     </xsl:when>
	     <xsl:otherwise>
	       <xsl:value-of select="@resp"/>
	     </xsl:otherwise>
	   </xsl:choose>
	   <xsl:text> </xsl:text>
	   <xsl:value-of select="@n"/>
	   <xsl:text>]</xsl:text>
	 </span>
      </span>

   </xsl:template>

   <xsl:template name="head">
      <xsl:choose>
         <xsl:when test="ancestor::tei:front">
            <xsl:number count="tei:div" from="tei:front" format="i" level="multiple"/>
         </xsl:when>
         <xsl:when test="ancestor::tei:body">
            <xsl:number count="tei:div" from="tei:body" format="1" level="multiple"/>
         </xsl:when>
         <xsl:when test="ancestor::tei:back">
	   Annex <xsl:number count="tei:div" from="tei:back" format="A.1.1" level="multiple"/>
         </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="tei:head" mode="ok"/>
   </xsl:template>

   <xsl:template match="tei:del" mode="ok"/>

  <xsl:template name="setDimension">
      <xsl:param name="name"/>
      <xsl:param name="value"/>

      <xsl:variable name="calcvalue">
         <xsl:choose>
            <xsl:when test="contains($value,'in')">
               <xsl:value-of select="round($dpi * number(substring-before($value,'in')))"/>
            </xsl:when>
            <xsl:when test="contains($value,'pt')">
               <xsl:value-of select="round($dpi * (number(substring-before($value,'pt')) div 72))"/>
            </xsl:when>
            <xsl:when test="contains($value,'cm')">
               <xsl:value-of select="round($dpi * (number(substring-before($value,'cm')) div 2.54 ))"/>
            </xsl:when>
            <xsl:when test="contains($value,'px')">
               <xsl:value-of select="substring-before($value,'px')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$value"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="{$name}">
         <xsl:value-of select="$calcvalue"/>
      </xsl:attribute>
  </xsl:template>

   <xsl:template match="tei:ref[@rend='TableFootnoteXref']" mode="show">
     <span class="superscript">
       <xsl:apply-templates mode="show"/>
     </span>
   </xsl:template>

   <xsl:template match="text()" mode="show">
       <xsl:value-of select="translate(.,'&#2011;','-')"/>
   </xsl:template>

 <xsl:template name="block-element">
     <xsl:param name="select"/>
     <xsl:param name="style"/>
     <xsl:param name="pPr"/>
     <xsl:param name="nop"/>
     <xsl:param name="bookmark-name"/>
     <xsl:param name="bookmark-id"/>
   </xsl:template>

   <xsl:template name="termNum"/>

</xsl:stylesheet>