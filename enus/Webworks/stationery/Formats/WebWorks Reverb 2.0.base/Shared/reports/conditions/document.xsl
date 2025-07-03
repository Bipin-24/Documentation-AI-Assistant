<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Reports-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
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
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              xmlns:wwstageinfo="urn:WebWorks-XSLT-Extension-StageInfo"
                              exclude-result-prefixes="xsl msxsl wwlocale wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwenv wwstageinfo"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwformat:Transforms/reports.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/reports.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/reports.xsl')))" />
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
 <xsl:variable name="GlobalConditionsUnknownSeverity" select="wwprojext:GetFormatSetting('report-conditions-unknown-condition')" />

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-conditions-generate', 'true') = 'true'" />
   <xsl:variable name="VarRequestedPipeline" select="wwenv:RequestedPipeline($GlobalPipelineName)" />
   <xsl:variable name="VarGenerateReport" select="($VarGenerateReportSetting) or ($VarRequestedPipeline)" />

   <xsl:if test="$VarGenerateReport">
    <!-- Configure stage info -->
    <!--                      -->
    <xsl:if test="string-length(wwstageinfo:Get('document-position')) = 0">
     <xsl:variable name="VarInitDocumentPosition" select="wwstageinfo:Set('document-position', '0')" />
    </xsl:if>
    
    <xsl:for-each select="$GlobalFiles[1]">
     <!-- Iterate input documents -->
     <!--                         -->
     <xsl:for-each select="$GlobalInput[1]">
      <!-- Documents -->
      <!--           -->
      <xsl:variable name="VarDocumentFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />
      <xsl:for-each select="$VarDocumentFiles">
       <xsl:variable name="VarDocumentFile" select="." /><!-- It's me the WIF file (inside files.info) -->
       
       <xsl:variable name="VarDocumentPosition" select="position()" />

       <!-- Check For & Get Conditions Needed to Write Report -->
       <!--                                                   -->

       <!-- FrameMaker System Conditions -->
       <!--                              -->
       <xsl:variable name="VarFMSystemConditions">
        <wwdoc:DocumentCondition name="FM8_SYSTEM_HIDEELEMENT" />
        <wwdoc:DocumentCondition name="FM8_TRACK_CHANGES_ADDED" />
        <wwdoc:DocumentCondition name="FM8_TRACK_CHANGES_DELETED" />
       </xsl:variable>
       
       <!-- Get all conditions from Source (WIF) file -->
       <!--                                           -->
       <xsl:variable name="VarDocumentAsXML" select="wwexsldoc:LoadXMLWithoutResolver($VarDocumentFile/@path)" />
       
       <xsl:variable name="VarDocumentConditions" select="$VarDocumentAsXML/wwdoc:Document/wwdoc:DocumentConditions/wwdoc:DocumentCondition | $VarDocumentAsXML/wwdoc:Document/wwdoc:Content/wwdoc:Paragraph/wwdoc:TextRun/wwdoc:Conditions/wwdoc:Condition" />
       
       <!-- Load the first paragraph's ID so we can -->
       <!-- open the document from the report       -->
       <xsl:variable name="VarFirstParagraphID" select="$VarDocumentAsXML/wwdoc:Document/wwdoc:Content/wwdoc:Paragraph[1]/@id" />
       
       <xsl:if test="count($VarDocumentConditions) &gt; 0">
          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <!-- Up-to-date? -->
           <!--             -->
           <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
           <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarDocumentFile/@groupID, $VarDocumentFile/@documentID, $GlobalActionChecksum)" />
           <xsl:if test="not($VarUpToDate)">
            <xsl:variable name="VarResultAsTreeFragment">
             <xsl:call-template name="Condition-Report">
              <!-- Create the template Condition-Report using the WIF file as a parameter -->
              <!-- This template should be creating a node set to write to reports-conditions-document -->
              <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
              <xsl:with-param name="ParamDocumentConditions" select="$VarDocumentConditions" />
              <xsl:with-param name="ParamFMSystemConditions" select="$VarFMSystemConditions" />
              <xsl:with-param name="ParamID" select="$VarFirstParagraphID" />
             </xsl:call-template>
            </xsl:variable>
            <xsl:if test="not(wwprogress:Abort())">
             <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
            </xsl:if>
           </xsl:if>
         
           <!-- Update stage info -->
           <!--                   -->
           <xsl:if test="not(wwprogress:Abort())">
            <xsl:variable name="VarUpdateDocumentPosition" select="wwstageinfo:Set('document-position', string($VarDocumentPosition))" />
           </xsl:if>

           <!-- Report generated files -->
           <!--                        -->
           <xsl:if test="not(wwprogress:Abort())">
            <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ConditionsReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
             <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
             <wwfiles:Depends path="{$VarDocumentFile/@path}" checksum="{$VarDocumentFile/@checksum}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" />
            </wwfiles:File>
           </xsl:if>
          </xsl:if>
         </xsl:if>
       
       <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
      </xsl:for-each>
      <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>
   
  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Condition-Report">
  <xsl:param name="ParamDocumentFile" /> <!-- WIF File Reference in files.info -->
  <xsl:param name="ParamDocumentConditions" /> <!-- DocumentConditions from WIF file -->
  <xsl:param name="ParamFMSystemConditions" /> <!-- FramMaker System Conditions -->
  <xsl:param name="ParamID" />
  
   <!-- Start building report -->
   <!--                       -->
   <wwreport:Report version="1.0">
    <xsl:variable name="VarTargetConditions" select="$GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID = wwprojext:GetFormatID()]/wwproject:Conditions/wwproject:Condition" />
    
    <xsl:for-each select="$ParamDocumentConditions">
     <xsl:variable name="VarDocumentCondition" select="." />
     
     <!-- Condition loaded, query various reporting circumstances -->
     <!--                                                         -->
     
     <!-- Unknown conditions -->
     <!--                         -->
     <xsl:variable name="VarUnknownConditionFound" select="count($VarTargetConditions[@Name = $VarDocumentCondition/@name]) + count(msxsl:node-set($ParamFMSystemConditions)//wwdoc:DocumentCondition[@name = $VarDocumentCondition/@name])" />
     
     <xsl:if test="($VarUnknownConditionFound = 0) and ($GlobalConditionsUnknownSeverity != 'ignore')">
      <xsl:call-template name="Write-Entry">
       <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
       <xsl:with-param name="ParamConditionName" select="$VarDocumentCondition/@name" />
       <xsl:with-param name="ParamEntryType" select="'unknown-condition'" />
       <xsl:with-param name="ParamSeverity" select="$GlobalConditionsUnknownSeverity" />
       <xsl:with-param name="ParamParagraphID" select="$ParamID" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
    
   </wwreport:Report>
 </xsl:template>
 
 <xsl:template name="Write-Entry">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamConditionName" />
  <xsl:param name="ParamEntryType" />
  <xsl:param name="ParamSeverity" />
  <xsl:param name="ParamParagraphID" />
  
  <!-- Load the correct description based on what type of entry we're writing -->
  <!--                                                                        -->
  <xsl:variable name="VarDescription">
   <xsl:if test="$ParamEntryType = 'unknown-condition'">
    <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnknownConditionInUse']/@value, $ParamConditionName)" />
   </xsl:if>
  </xsl:variable>
   
  <!-- Write an entry on the conditions report -->
   <!--                       -->
  <wwreport:Entry context="conditions" type="{$ParamEntryType}" severity="{$ParamSeverity}">
    <wwreport:Description>
    <xsl:value-of select="$VarDescription" />
    </wwreport:Description>

    <wwreport:Navigation context="source">
     <wwreport:Link protocol="adapter">
      <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
      <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
      <wwreport:Data key="ID" value="{$ParamParagraphID}" />
     </wwreport:Link>
    </wwreport:Navigation>

    <wwreport:Navigation context="details">
     <wwreport:Link protocol="wwh5api">
      <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
      <wwreport:Data key="Context" value="preparing" />
     <wwreport:Data key="Topic" value="{$ParamEntryType}" />
     </wwreport:Link>
    </wwreport:Navigation>
   </wwreport:Entry>
   
 </xsl:template>
</xsl:stylesheet>
