<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Reports-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwbehaviors wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwenv"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwformat:Transforms/reports.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-files-by-documentID" match="wwlinks:File" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/reports.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/reports.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- UI Locale -->
 <!--           -->
 <xsl:variable name="GlobalUILocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterUILocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalUILocalePathChecksum" select="wwfilesystem:GetChecksum($GlobalUILocalePath)" />
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />


 <!-- Severities -->
 <!--            -->
 <xsl:variable name="GlobalTopicsLinkSeverity" select="wwprojext:GetFormatSetting('report-topics-link', 'message')" />
 <xsl:variable name="GlobalTopicsDuplicateSeverity" select="wwprojext:GetFormatSetting('report-topics-duplicate', 'warning')" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-topics-generate', 'true') = 'true'" />
   <xsl:variable name="VarRequestedPipeline" select="wwenv:RequestedPipeline($GlobalPipelineName)" />
   <xsl:variable name="VarGenerateReport" select="($VarGenerateReportSetting) or ($VarRequestedPipeline)" />

   <xsl:if test="$VarGenerateReport">
    <!-- Load project links -->
    <!--                    -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarLinksFileInfo" select="key('wwfiles-files-by-type', $ParameterLinksType)" />
     <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksFileInfo/@path, false())" />

     <!-- Iterate input documents -->
     <!--                         -->
     <xsl:for-each select="$GlobalInput[1]">
      <!-- Documents -->
      <!--           -->
      <xsl:variable name="VarDocumentFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />
      <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarDocumentFiles))" />
      <xsl:for-each select="$VarDocumentFiles">
       <xsl:variable name="VarDocumentFile" select="." />

       <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <!-- Up-to-date? -->
        <!--             -->
        <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarDocumentFile/@groupID, $VarDocumentFile/@documentID, $GlobalActionChecksum)" />
        <xsl:if test="not($VarUpToDate)">
         <xsl:variable name="VarResultAsTreeFragment">
          <xsl:call-template name="Topics-Report">
           <xsl:with-param name="ParamLinks" select="$VarLinks" />
           <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
        </xsl:if>

        <!-- Report generated files -->
        <!--                        -->
        <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TopicsReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
         <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
         <wwfiles:Depends path="{$VarLinksFileInfo/@path}" checksum="{$VarLinksFileInfo/@checksum}" groupID="{$VarLinksFileInfo/@groupID}" documentID="{$VarLinksFileInfo/@documentID}" />
         <wwfiles:Depends path="{$VarDocumentFile/@path}" checksum="{$VarDocumentFile/@checksum}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" />
        </wwfiles:File>
       </xsl:if>

       <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
      </xsl:for-each>

      <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:topics">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamLinkFile" />

  <xsl:apply-templates mode="wwmode:topics">
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamLinkFile" select="$ParamLinkFile" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwlinks:Paragraph" mode="wwmode:topics">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamLinkFile" />
  <xsl:param name="ParamLinkParagraph" select="." />

  <!-- Check for topic attribute -->
  <!--                           -->
  <xsl:if test="string-length($ParamLinkParagraph/@topic) &gt; 0">
   <xsl:if test="$GlobalTopicsLinkSeverity != 'ignore'">
    <wwreport:Entry context="topics" type="topic-link" severity="{$GlobalTopicsLinkSeverity}">
     <wwreport:Description>
      <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TopicsLink']/@value, $ParamLinkParagraph/@topic, wwfilesystem:GetFileName($ParamLinkFile/@path))" />
     </wwreport:Description>

     <wwreport:Navigation context="source">
      <wwreport:Link protocol="adapter">
       <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
       <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
       <wwreport:Data key="ID" value="{$ParamLinkParagraph/@id}" />
      </wwreport:Link>
     </wwreport:Navigation>

     <!-- Get topic navigation link from format itself -->
     <!--                                              -->
     <xsl:variable name="VarLinkAsXML">
      <xsl:call-template name="Report-TopicLink">
       <xsl:with-param name="ParamProject" select="$GlobalProject" />
       <xsl:with-param name="ParamLinksContext" select="$ParamLinkParagraph" />
       <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
       <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
       <xsl:with-param name="ParamTopic" select="$ParamLinkParagraph/@topic" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
     <xsl:if test="count($VarLink) = 1">
      <wwreport:Navigation context="output">
       <xsl:copy-of select="$VarLink" />
      </wwreport:Navigation>
     </xsl:if>

     <wwreport:Navigation context="details">
      <wwreport:Link protocol="wwh5api">
       <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
       <wwreport:Data key="Context" value="preparing" />
       <wwreport:Data key="Topic" value="topic_links" />
      </wwreport:Link>
     </wwreport:Navigation>
    </wwreport:Entry>
   </xsl:if>
  </xsl:if>

  <!-- Report duplicate topic alias -->
  <!--                              -->
  <xsl:if test="string-length($ParamLinkParagraph/@duplicate-topic) &gt; 0">
   <xsl:if test="$GlobalTopicsDuplicateSeverity != 'ignore'">
    <wwreport:Entry context="topics" type="topic-duplicate" severity="{$GlobalTopicsDuplicateSeverity}">
     <wwreport:Description>
      <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TopicsDuplicate']/@value, $ParamLinkParagraph/@duplicate-topic, wwfilesystem:GetFileName($ParamLinkFile/@path))" />
     </wwreport:Description>

     <wwreport:Navigation context="source">
      <wwreport:Link protocol="adapter">
       <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
       <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
       <wwreport:Data key="ID" value="{$ParamLinkParagraph/@id}" />
      </wwreport:Link>
     </wwreport:Navigation>

     <!-- Get output navigation link from format itself -->
     <!--                                               -->
     <xsl:variable name="VarLinkAsXML">
      <xsl:call-template name="Report-OutputLink">
       <xsl:with-param name="ParamProject" select="$GlobalProject" />
       <xsl:with-param name="ParamLinksContext" select="$ParamLinkParagraph" />
       <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
       <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
       <xsl:with-param name="ParamParagraphID" select="$ParamLinkParagraph/@id" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
     <xsl:if test="count($VarLink) = 1">
      <wwreport:Navigation context="output">
       <xsl:copy-of select="$VarLink" />
      </wwreport:Navigation>
     </xsl:if>

     <wwreport:Navigation context="details">
      <wwreport:Link protocol="wwh5api">
       <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
       <wwreport:Data key="Context" value="preparing" />
       <wwreport:Data key="Topic" value="topic_duplicate" />
      </wwreport:Link>
     </wwreport:Navigation>
    </wwreport:Entry>
   </xsl:if>
  </xsl:if>

  <xsl:apply-templates mode="wwmode:topics">
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamLinkFile" select="$ParamLinkFile" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template name="Topics-Report">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />

  <!-- Generate report -->
  <!--                 -->
  <wwreport:Report version="1.0">

   <xsl:for-each select="$ParamLinks[1]">
    <xsl:variable name="VarLinkFiles" select="key('wwlinks-files-by-documentID', $ParamDocumentFile/@documentID)" />

    <xsl:for-each select="$VarLinkFiles">
     <xsl:variable name="VarLinkFile" select="." />

     <xsl:apply-templates select="$VarLinkFile/*" mode="wwmode:topics">
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamLinkFile" select="$VarLinkFile" />
     </xsl:apply-templates>
    </xsl:for-each>
   </xsl:for-each>

  </wwreport:Report>
 </xsl:template>
</xsl:stylesheet>
