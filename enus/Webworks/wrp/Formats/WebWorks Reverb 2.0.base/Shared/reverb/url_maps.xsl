<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Reports-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              exclude-result-prefixes="xsl msxsl wwlocale wwmode wwlinks wwfiles wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwenv wwproject"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterEntryType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />
 <xsl:param name="ParameterCopyBaggageType" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/files/utils.xsl" /> <!-- TODO: This should be included within connect_utilities.xsl -->
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Links -->
 <!--        -->
 <xsl:variable name="GlobalLinksPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterDependsType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalLinks" select="wwexsldoc:LoadXMLWithoutResolver($GlobalLinksPath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarIsGenerateEnabled" select="wwprojext:GetFormatSetting('connect-url-maps', 'true') = 'true'" />

   <xsl:if test="$VarIsGenerateEnabled">
    <xsl:variable name="VarProject" select="$GlobalProject/wwproject:Project" />
    <xsl:variable name="VarFormatVersion">
     <xsl:choose>
      <xsl:when test="$VarProject/@FormatVersion = '{Current}'">
       <xsl:value-of select="$VarProject/@RuntimeVersion" />
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$VarProject/@FormatVersion" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <xsl:variable name="VarOutputDirectoryPath" select="wwprojext:GetTargetOutputDirectoryPath()" />
    <xsl:variable name="VarOutputUri" select="wwuri:AsURI(wwfilesystem:Combine($VarOutputDirectoryPath, 'dummy.component'))" />
    <xsl:variable name="VarDefaultEntryUri" select="wwstring:EncodeURI(wwprojext:GetFormatSetting('connect-entry'))" />
    <xsl:variable name="VarURLMapsPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, wwprojext:GetFormatSetting('connect-url-maps-name'))" />
    
    <xsl:variable name="VarResultAsTreeFragment">
     <wwreport:Report version="1.0">
      <wwreport:Project projectID="{$VarProject/@ProjectID}" formatVersion="{$VarFormatVersion}" runtimeVersion="{$VarProject/@RuntimeVersion}">
       <wwreport:Entry name="default" href="{$VarDefaultEntryUri}" />
       <wwreport:TopicMap>
        <xsl:for-each select="$GlobalLinks/wwlinks:Links/wwlinks:File/wwlinks:Paragraph[string-length(@topic) &gt; 0]">
         <xsl:variable name="VarFile" select=".." />
         <xsl:variable name="VarContext">
          <xsl:call-template name="Connect-Context">
           <xsl:with-param name="ParamProject" select="$GlobalProject" />
           <xsl:with-param name="ParamGroupID" select="$VarFile/@groupID" />
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarParagraph" select="." />
         <xsl:variable name="VarHref" select="concat($VarDefaultEntryUri, '#context/', wwstring:EncodeURI($VarParagraph/@topic))" />
         <xsl:variable name="VarHrefExact" select="concat($VarDefaultEntryUri, '#context/', $VarContext, '/', wwstring:EncodeURI($VarParagraph/@topic))" />
         <wwreport:Topic context="{$VarContext}" topic="{$VarParagraph/@topic}" path="{wwfilesystem:GetRelativeTo($VarFile/@path, $VarURLMapsPath)}" title="{$VarFile/@title}" href="{$VarHref}" hrefExact="{$VarHrefExact}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" />
        </xsl:for-each>
       </wwreport:TopicMap>
       <wwreport:PageMap>
        <xsl:for-each select="$GlobalLinks/wwlinks:Links/wwlinks:File">
         <xsl:variable name="VarFile" select="." />
         <xsl:variable name="VarFileUri" select="wwuri:AsURI($VarFile/@path)" />
         <xsl:variable name="VarRelPath" select="wwuri:GetRelativeTo($VarFileUri, $VarOutputUri)" />
         <xsl:variable name="VarHref" select="concat($VarDefaultEntryUri, '#page/', $VarRelPath)" />
         <wwreport:Page basename="{wwfilesystem:GetFileName($VarFile/@path)}" path="{wwfilesystem:GetRelativeTo($VarFile/@path, $VarURLMapsPath)}" title="{$VarFile/@title}" href="{$VarHref}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" />
        </xsl:for-each>
       </wwreport:PageMap>
       <wwreport:BaggageMap>
        <xsl:for-each select="$GlobalFiles[1]">
         <xsl:variable name="VarBaggageFiles" select="key('wwfiles-files-by-type', $ParameterCopyBaggageType)" />
         <xsl:for-each select="$VarBaggageFiles">
          <xsl:variable name="VarBaggageFile" select="." />
          <xsl:if test="wwfilesystem:FileExists($VarBaggageFile/@path)">
           <wwreport:Baggage basename="{wwfilesystem:GetFileName($VarBaggageFile/@path)}" path="{wwfilesystem:GetRelativeTo($VarBaggageFile/@path, $VarURLMapsPath)}" groupID="{$VarBaggageFile/@groupID}" />
          </xsl:if>
         </xsl:for-each>
        </xsl:for-each>
       </wwreport:BaggageMap>
      </wwreport:Project>
     </wwreport:Report>
    </xsl:variable>
    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarURLMapsPath, 'utf-8', 'xml', '1.0', 'yes')" />
    
    <!-- Report Files -->
    <!--              -->
    <wwfiles:File path="{$VarURLMapsPath}" displayname="" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarURLMapsPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}" />

   </xsl:if>
  </wwfiles:Files>
 </xsl:template>

</xsl:stylesheet>
