<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwnotes="urn:WebWorks-Footnote-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />


 <xsl:variable name="VarRelativeRootPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'dummy.component')" />

 <xsl:template name="Connect-Context">
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamGroupID" />

  <!-- Merge context -->
  <!--               -->
  <xsl:variable name="VarMergeGroupContext">
   <xsl:for-each select="$ParamProject[1]">
    <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
    <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

    <xsl:variable name="VarMergeGroup" select="$VarMergeSettings//wwproject:MergeGroup[@GroupID = $ParamGroupID]" />
    <xsl:if test="count($VarMergeGroup) &gt; 0">
     <xsl:value-of select="$VarMergeGroup/@Context" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
   <!-- Merge context -->
   <!--               -->
   <xsl:when test="string-length($VarMergeGroupContext)">
    <xsl:value-of select="wwstring:WebWorksHelpContextOrTopic($VarMergeGroupContext)" />
   </xsl:when>

   <!-- Project group name -->
   <!--                    -->
   <xsl:otherwise>
    <xsl:variable name="VarReplacedGroupName">
     <xsl:call-template name="ReplaceGroupNameSpacesWith">
      <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamGroupID)" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="wwstring:WebWorksHelpContextOrTopic(wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Connect-BookTitle">
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamGroupID" />

  <!-- Group context -->
  <!--               -->
  <xsl:variable name="VarMergeGroupTitle">
   <xsl:for-each select="$ParamProject[1]">
    <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
    <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

    <xsl:variable name="VarMergeGroup" select="$VarMergeSettings//wwproject:MergeGroup[@GroupID = $ParamGroupID]" />
    <xsl:if test="count($VarMergeGroup) &gt; 0">
     <xsl:value-of select="$VarMergeGroup/@Title" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
   <!-- Group title -->
   <!--               -->
   <xsl:when test="string-length($VarMergeGroupTitle)">
    <xsl:value-of select="$VarMergeGroupTitle" />
   </xsl:when>

   <!-- Group name -->
   <!--            -->
   <xsl:otherwise>
    <xsl:value-of select="wwprojext:GetGroupName($ParamGroupID)" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Connect-URI-GetRelativeTo">
  <xsl:param name="ParamDestinationURI" />
  <xsl:param name="ParamSourceURI" />

  <!-- Force path to resolve relative to the target output directory -->
  <!--                                                               -->
  <xsl:variable name="VarSourceToRelativeRootWithDummyComponent" select="wwuri:GetRelativeTo($VarRelativeRootPath, $ParamSourceURI)" />
  <xsl:variable name="VarSourceToRelativeRoot">
   <xsl:choose>
    <!-- Already at root? -->
    <!--                  -->
    <xsl:when test="$VarSourceToRelativeRootWithDummyComponent = 'dummy.component'">
     <!-- Empty string! -->
     <!--               -->
     <xsl:text></xsl:text>
    </xsl:when>

    <!-- Use relative path -->
    <!--                   -->
    <xsl:otherwise>
     <xsl:value-of select="substring-before($VarSourceToRelativeRootWithDummyComponent, '/dummy.component')" />
     <xsl:text>/</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarRelativeRootToDestination" select="wwuri:GetRelativeTo($ParamDestinationURI, $VarRelativeRootPath)" />

  <!-- Return result -->
  <!--               -->
  <xsl:value-of select="$VarSourceToRelativeRoot" />
  <xsl:value-of select="$VarRelativeRootToDestination" />
 </xsl:template>

 <xsl:template name="Connect-File-Path">
  <xsl:param name="ParamPath" />

  <xsl:value-of select="translate($ParamPath, '#&quot;?', '___')" />
 </xsl:template>
</xsl:stylesheet>
