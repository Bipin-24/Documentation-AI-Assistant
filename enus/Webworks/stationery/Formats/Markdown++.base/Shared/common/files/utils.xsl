<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 
 <xsl:variable name="GlobalFilenameSpacesToUnderscores" select="wwprojext:GetFormatSetting('filename-spaces-to-underscores', 'false') = 'true'" />
 <xsl:variable name="GlobalGroupnameReplaceSpaces" select="wwprojext:GetFormatSetting('groupname-convert-spaces', $GlobalFilenameSpacesToUnderscores) = 'true'" />
 <xsl:variable name="GlobalFilenameReplaceSpacesWith" select="wwprojext:GetFormatSetting('filename-replace-spaces-with', '_')" />
 <xsl:variable name="GlobalFilenameConvertTo" select="wwprojext:GetFormatSetting('filename-convert-name-to', 'normal')" />
 
 <xsl:variable name="GlobalFilenameSpacesToUnderscoresSearchString">
  <xsl:if test="($GlobalFilenameSpacesToUnderscores or $GlobalGroupnameReplaceSpaces) and not($GlobalFilenameReplaceSpacesWith='ignore')">
   <xsl:text> </xsl:text>
  </xsl:if>
 </xsl:variable>
 
 <xsl:variable name="GlobalFilenameSpacesToUnderscoresReplaceString">
  <xsl:if test="($GlobalFilenameSpacesToUnderscores or $GlobalGroupnameReplaceSpaces) and not($GlobalFilenameReplaceSpacesWith='ignore')">
   <xsl:choose>
    <xsl:when test="$GlobalFilenameReplaceSpacesWith = 'no-space'">
     <xsl:text></xsl:text>
    </xsl:when> 
    <xsl:otherwise>
     <xsl:value-of select="$GlobalFilenameReplaceSpacesWith"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:variable>

 <!--
  Note: allowing '/' and '\\' characters because they are component separators.

  RegExp for Invalid Path Characters =
    ["#$%&*+,:;<=>?\[\]|]

  XML Encoded =
    &#91;&#34;&#35;&#36;&#37;&#38;&#42;&#43;&#44;&#58;&#59;&#60;&#61;&#62;&#63;&#92;&#91;&#92;&#93;&#124;&#93;
  -->
 <xsl:variable name="GlobalInvalidPathCharactersExpression" select="'&#91;&#34;&#35;&#36;&#37;&#38;&#42;&#43;&#44;&#58;&#59;&#60;&#61;&#62;&#63;&#92;&#91;&#92;&#93;&#124;&#93;'" />


  <xsl:template name="ConvertNameTo">
  <xsl:param name="ParamText"/>

  <xsl:choose>
   <xsl:when test="$GlobalFilenameConvertTo = 'lowecase'">
    <xsl:value-of select="wwstring:ToLower($ParamText)" />
   </xsl:when>
   <xsl:when test="$GlobalFilenameConvertTo = 'uppercase'">
    <xsl:value-of select="wwstring:ToUpper($ParamText)" />
   </xsl:when>
   <xsl:when test="$GlobalFilenameConvertTo = 'camelcase'">
    <xsl:value-of select="wwstring:ToCamel($ParamText)" />
   </xsl:when>
   <xsl:when test="$GlobalFilenameConvertTo = 'pascalcase'">
    <xsl:value-of select="wwstring:ToPascal($ParamText)" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$ParamText" />
   </xsl:otherwise>
  </xsl:choose> 
  
 </xsl:template>
 
 <xsl:template name="ReplaceGroupNameSpacesWith">
  <xsl:param name="ParamText"/>
  
  <xsl:choose>
   <xsl:when test="$GlobalGroupnameReplaceSpaces"> 
    <xsl:value-of select="wwstring:Replace($ParamText, $GlobalFilenameSpacesToUnderscoresSearchString, $GlobalFilenameSpacesToUnderscoresReplaceString)" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$ParamText" />
   </xsl:otherwise>
  </xsl:choose> 
  
 </xsl:template>
 
 <xsl:template name="ReplaceFileNameSpacesWith">
  <xsl:param name="ParamText"/>
 
  <xsl:choose>
   <xsl:when test="$GlobalFilenameSpacesToUnderscores">
    <xsl:value-of select="wwstring:Replace($ParamText, $GlobalFilenameSpacesToUnderscoresSearchString, $GlobalFilenameSpacesToUnderscoresReplaceString)" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$ParamText" />
   </xsl:otherwise>
  </xsl:choose> 
  
 </xsl:template>
</xsl:stylesheet>
