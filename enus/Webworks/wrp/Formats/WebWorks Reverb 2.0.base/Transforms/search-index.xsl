<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Document-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwsearch="urn:WebWorks-XSLT-Extension-Search"
                              xmlns:js="urn:WebWorks-XSLT-Extension-Javascript"
                              xmlns:cs="urn:WebWorks-XSLT-Extension-CSharp"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles
                                                       wwdoc wwbehaviors wwsplits wwvars wwproject wwpage
                                                       wwlocale wwprogress wwlog wwfilesystem
                                                       wwuri wwstring wwfilesext wwprojext
                                                       wwexsldoc wwsearch"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterSearchSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="wwdoc" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-files-by-type" match="wwsplits:File" use="@type" />
 <xsl:key name="wwsplits-split-by-documentid" match="wwsplits:Split" use="@documentID" />
 <xsl:key name="wwsplits-split-by-id" match="wwsplits:Split" use="@id" />
 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Locale -->
 <!--        -->
 <xsl:variable name="GlobalLocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterLocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalLocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalLocalePath)" />


 <!-- Search configuration -->
 <!--                      -->
 <xsl:variable name="GlobalMinSummaryLength" select="number(200)" />
 <xsl:variable name="GlobalMaxSummaryLength" select="number(300)" />
 <xsl:variable name="GlobalMinimumWordLength" select="number($GlobalLocale/wwlocale:Locale/wwlocale:Search/wwlocale:MinimumWordLength/@value)" />
 <xsl:variable name="GlobalStopWords" select="$GlobalLocale/wwlocale:Locale/wwlocale:Search/wwlocale:StopWords/text()" />
 <xsl:variable name="GlobalSynonyms" select="$GlobalLocale/wwlocale:Locale/wwlocale:Search/wwlocale:Synonyms/*" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">
   <!-- Generate search indices -->
   <!--                         -->

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

     <!-- Access splits -->
     <!--               -->
     <xsl:for-each select="$GlobalInput[1]">
      <xsl:variable name="VarFilesNameInfo" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarProjectGroup/@GroupID]" />
      <xsl:for-each select="$VarFilesNameInfo[1]">
       <xsl:variable name="VarSplitsFileInfo" select="." />

       <!-- Load splits -->
       <!--             -->
       <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFileInfo/@path, false())" />

       <xsl:for-each select="$VarSplits[1]">
        <!-- Split -->
        <!--       -->
        <xsl:variable name="VarSearchFile" select="key('wwsplits-files-by-type', $ParameterSearchSplitFileType)[@groupID = $VarProjectGroup/@GroupID][1]" />

        <!-- Access input documents -->
        <!--                        -->
        <xsl:for-each select="$GlobalFiles[1]">
         <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

         <!-- Call template -->
         <!--               -->
         <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarSearchFile/@path, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType)), $VarSearchFile/@groupID, $VarSearchFile/@documentID, $GlobalActionChecksum)" />
         <xsl:if test="not($VarUpToDate)">
          <xsl:variable name="VarProgressDocumentWIFsStart" select="wwprogress:Start(count($VarFilesByType))" />

          <!-- Reset for group -->
          <!--                 -->
          <xsl:variable name="VarReset" select="wwsearch:Reset()" />

          <xsl:for-each select="$VarFilesByType">
           <xsl:variable name="VarFilesDocumentNode" select="." />

           <xsl:variable name="VarProgressDocumentWIFStart" select="wwprogress:Start(1)" />

           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <!-- Load document -->
            <!--               -->
            <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocumentNode/@path, false())" />

            <!-- Load behaviors -->
            <!--                -->
            <xsl:for-each select="$GlobalFiles[1]">
             <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-type', $ParameterBehaviorsType)[@documentID = $VarFilesDocumentNode/@documentID]" />
             <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

             <!-- Process splits -->
             <!--                -->
             <xsl:for-each select="$VarSplits[1]">
              <xsl:variable name="VarDocumentSplits" select="key('wwsplits-split-by-documentid', $VarFilesDocumentNode/@documentID)" />

              <xsl:variable name="VarProgressDocumentSplitsStart" select="wwprogress:Start(count($VarDocumentSplits))" />

              <xsl:for-each select="$VarDocumentSplits">
               <xsl:variable name="VarDocumentSplit" select="." />
               <xsl:variable name="VarSplitBehaviors" select="$VarBehaviors/wwbehaviors:Behaviors/wwbehaviors:Split[@id = $VarDocumentSplit/@id]" />

               <xsl:variable name="VarProgressDocumentSplitStart" select="wwprogress:Start(1)" />

               <!-- Page URI -->
               <!--          -->
               <xsl:variable name="VarPageURI" select="wwuri:GetRelativeTo($VarDocumentSplit/@path, $VarSearchFile/@path)" />

               <!-- Identify page content -->
               <!--                       -->
               <xsl:variable name="VarContent" select="$VarDocument/wwdoc:Document/wwdoc:Content/*[(position() &gt;= $VarDocumentSplit/@documentstartposition) and (position() &lt;= $VarDocumentSplit/@documentendposition)]" />

               <!-- Look for Description marker as the Summary -->
               <!--                                            -->
               <xsl:variable name="VarDescription" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'description'][1]//wwdoc:Text[1]/@value" />

               <!-- Choose Description Marker or accumulate paragraph text -->
               <xsl:variable name="VarPageSummary">
                <xsl:choose>
                 <xsl:when test="string-length($VarDescription) &gt; 0">
                  <xsl:value-of select="$VarDescription" />
                 </xsl:when>

                 <xsl:otherwise>
                  <!-- Process VarContent to accumulate Summary -->
                  <!--                                          -->
                  <xsl:variable name="VarResetSummary" select="wwsearch:ResetSummary()" />

                  <xsl:variable name="VarAccumulatePageSummary">
                   <xsl:apply-templates select="$VarContent" mode="wwmode:page-summary">
                    <xsl:with-param name="ParamSplit" select="$VarDocumentSplit" />
                    <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
                    <xsl:with-param name="ParamLength" select="-1" />
                   </xsl:apply-templates>
                  </xsl:variable>

                  <xsl:value-of select="wwsearch:GetSummary()" />

                 </xsl:otherwise>
                </xsl:choose>
               </xsl:variable>

               <!-- Index content -->
               <!--               -->
               <xsl:apply-templates select="$VarContent" mode="wwmode:page-content">
                <xsl:with-param name="ParamSplit" select="$VarDocumentSplit" />
                <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
               </xsl:apply-templates>

               <!-- Include keyword, description, and other markers -->
               <!--                                                 -->
               <xsl:variable name="VarMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'description' or @behavior = 'keywords' or @behavior = 'table-summary' or @behavior = 'image-alt-text' or @behavior = 'image-area-alt-text' or @behavior = 'image-long-description-text' or @behavior = 'image-long-description-by-reference' or @behavior = 'link-title']" />
               <xsl:for-each select="$VarMarkers">
                <xsl:variable name="VarMarker" select="." />

                <!-- Getting the relevance for every marker -->
                <!--                                        -->
                <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Marker', $VarMarker/wwdoc:Marker/@name, $VarDocumentSplit/@documentID, $VarMarker/@id)" />
                <xsl:variable name="VarSearchRelevanceWeightOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'search-relevance-weight']/@Value" />

                <!-- Index Markers -->
                <!--               -->
                <xsl:apply-templates select="$VarMarker/wwdoc:Marker" mode="wwmode:marker-content">
                 <xsl:with-param name="ParamSplit" select="$VarDocumentSplit" />
                 <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />

                 <!-- Passing a new parameter for saving the relevance weight -->
                 <!--                                                         -->
                 <xsl:with-param name="ParamRelevance" select="$VarSearchRelevanceWeightOption" />
                </xsl:apply-templates>
               </xsl:for-each>

               <!-- Index content -->
               <!--               -->
               <xsl:variable name="VarSearchPairsPath" select="$VarDocumentSplit/wwsplits:SearchPairs/@path" />
               <xsl:variable name="VarSearchPairsURI" select="wwuri:GetRelativeTo($VarSearchPairsPath, $VarSearchFile/@path)" />
               <!-- Removed the parameter for passing the whole text -->
               <!--                                                  -->
               <xsl:variable name="VarGroupID" select="$VarSearchFile/@groupID"/>
               <xsl:variable name="VarWords" select="wwsearch:IndexContent($GlobalMinimumWordLength, $GlobalStopWords, $VarPageURI, $VarDocumentSplit/@title, $VarPageSummary, $VarSearchPairsPath, $VarSearchPairsURI, 'content-page', $VarGroupID)" />

               <xsl:variable name="VarProgressDocumentSplitEnd" select="wwprogress:End()" />
              </xsl:for-each>

              <xsl:variable name="VarProgressDocumentSplitsEnd" select="wwprogress:End()" />
             </xsl:for-each>
            </xsl:for-each>
           </xsl:if>

           <xsl:variable name="VarProgressDocumentWIFEnd" select="wwprogress:End()" />
          </xsl:for-each>

          <xsl:variable name="VarProgressDocumentWIFsEnd" select="wwprogress:End()" />

          <!-- Write result -->
          <!--              -->
          <xsl:if test="not(wwprogress:Abort())">

           <xsl:call-template name="AddSynonyms">
            <xsl:with-param name="ParamSynonyms" select="$GlobalSynonyms"/>
           </xsl:call-template>
           <xsl:variable name="VarWriteJSON" select="wwsearch:WriteJSON($VarSearchFile/@path)" />
          </xsl:if>
         </xsl:if>

         <!-- Aborted? -->
         <!--          -->
         <xsl:if test="not(wwprogress:Abort())">
          <!-- Report files -->
          <!--              -->
          <wwfiles:File path="{$VarSearchFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSearchFile/@path)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType))}" groupID="{$VarSearchFile/@groupID}" documentID="{$VarSearchFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
           <wwfiles:Depends path="{$GlobalLocalePath}" checksum="{wwfilesystem:GetChecksum($GlobalLocalePath)}" groupID="" documentID="" />
           <xsl:for-each select="$VarFilesByType">
            <xsl:variable name="VarFilesDocumentNode" select="." />

            <wwfiles:Depends path="{$VarFilesDocumentNode/@path}" checksum="{$VarFilesDocumentNode/@checksum}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" />
           </xsl:for-each>
          </wwfiles:File>

          <!-- Search pairs -->
          <!--              -->
          <xsl:for-each select="$VarFilesByType">
           <xsl:variable name="VarFilesDocumentNode" select="." />

           <!-- Search pair files -->
           <!--                   -->
           <xsl:for-each select="$VarSplits[1]">
            <xsl:variable name="VarDocumentSplits" select="key('wwsplits-split-by-documentid', $VarFilesDocumentNode/@documentID)" />

            <xsl:for-each select="$VarDocumentSplits">
             <xsl:variable name="VarDocumentSplit" select="." />

             <xsl:variable name="VarSearchPairsPath" select="$VarDocumentSplit/wwsplits:SearchPairs/@path" />

             <wwfiles:File path="{$VarSearchPairsPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSearchPairsPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType))}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
              <wwfiles:Depends path="{$VarFilesDocumentNode/@path}" checksum="{$VarFilesDocumentNode/@checksum}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" />
             </wwfiles:File>
            </xsl:for-each>
           </xsl:for-each>
          </xsl:for-each>
         </xsl:if>
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>
   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
  </wwfiles:Files>
 </xsl:template>


 <!-- generate-output -->
 <!--                 -->

 <xsl:template match="/" mode="wwmode:generate-output">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:generate-output">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamParagraph" select="." />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <xsl:for-each select="$ParamBehaviors[1]">
    <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $ParamParagraph/@id)[1]" />
    <xsl:variable name="VarPopupOnly" select="($VarParagraphBehavior/@popup = 'define-no-output') or ($VarParagraphBehavior/@popup = 'append-no-output')" />
    <xsl:variable name="VarRelatedTopicOnly" select="$VarParagraphBehavior/@relatedtopic = 'define-no-output'" />

    <xsl:if test="not(($VarPopupOnly) or ($VarRelatedTopicOnly))">
     <xsl:value-of select="true()" />
    </xsl:if>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:generate-output">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:generate-output">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- page-summary -->
 <!--              -->

 <xsl:template match="/" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLength" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamLength" select="$ParamLength" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:List | wwdoc:ListItem | wwdoc:Block" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLength" />

  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', ./@stylename, $ParamSplit/@documentID, ./@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <xsl:if test="$VarGenerateOutput">
   <xsl:apply-templates mode="wwmode:page-summary">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamLength" select="$ParamLength" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

  <xsl:template match="wwdoc:Table" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarTable" select="." />
  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Table', $VarTable/@stylename, $ParamSplit/@documentID, $VarTable/@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <xsl:if test="$VarGenerateOutput">
  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Caption" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableHead" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableBody" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableFoot" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableRow" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableCell" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLength" />
  <xsl:param name="ParamParagraph" select="." />

  <xsl:variable name="VarIsFirst" select="$ParamParagraph/@id = $ParamSplit/@id" />

  <!-- First paragraph becomes the result title, do not add to summary -->
  <!--                                                                 -->
  <xsl:if test="not($VarIsFirst)">
   <!-- Process paragraph to determine if it should be used in summary -->
   <!--                                                                -->
   <xsl:variable name="VarGenerateOutputAsText">
    <xsl:apply-templates select="$ParamParagraph" mode="wwmode:generate-output">
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    </xsl:apply-templates>
   </xsl:variable>
   <xsl:variable name="VarGenerateOutput" select="$VarGenerateOutputAsText = string(true())" />

   <!-- Keep paragraph in Summary? -->
   <!--                            -->
   <xsl:if test="$VarGenerateOutput">
    <!-- Collect up child text and normalize whitespace -->
    <!--                                                -->
    <xsl:variable name="VarParagraphText">
      <xsl:apply-templates select="$ParamParagraph" mode="wwmode:page-summary-content">
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
      </xsl:apply-templates>
     </xsl:variable>

    <!-- Accumulate Paragraph into Summary -->
    <!--                                   -->
    <xsl:variable name="VarAddNormalizedParagraphTextToSummary" select="wwsearch:AddParagraphToSummary($GlobalMinSummaryLength, $GlobalMaxSummaryLength, normalize-space($VarParagraphText))" />
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLength" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:page-summary">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLength" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


  <!-- page-summary-content -->
  <!--                      -->

 <xsl:template match="/" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:List | wwdoc:ListItem | wwdoc:Block" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', ./@stylename, $ParamSplit/@documentID, ./@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <xsl:if test="$VarGenerateOutput">
  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Table" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarTable" select="." />
  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Table', $VarTable/@stylename, $ParamSplit/@documentID, $VarTable/@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <xsl:if test="$VarGenerateOutput">
  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Caption" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableHead" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableBody" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableFoot" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableRow" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableCell" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-summary-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamParagraph" select="." />

  <!-- Getting the relevance for every stylename -->
  <!--                                           -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputAsText">
   <xsl:apply-templates select="$ParamParagraph" mode="wwmode:generate-output">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="VarGenerateOutput" select="$VarGenerateOutputAsText = string(true())" />

  <xsl:if test="$VarGenerateOutput">
   <xsl:variable name="VarWords">
    <xsl:apply-templates mode="wwmode:page-summary-content">
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    </xsl:apply-templates>
   </xsl:variable>

   <!-- Emit Word(s) -->
   <!--              -->
   <xsl:if test="normalize-space($VarWords)">
    <xsl:value-of select="normalize-space($VarWords)" />
     <!-- Delimit paragraphs -->
     <!--                    -->
     <xsl:text> </xsl:text>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:TextRun" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarTextRun" select="." />
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Character', $VarTextRun/@stylename, $ParamSplit/@documentID, $VarTextRun/@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />

  <xsl:if test="$VarGenerateOutputOption = string(true())">
   <xsl:apply-templates mode="wwmode:page-summary-content">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Number" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamNumber" select="." />

  <!-- Use numbering? -->
  <!--                  -->
  <xsl:variable name="VarParagraph" select="$ParamNumber/parent::wwdoc:Paragraph" />
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
  <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
  <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption != 'false')" />
  <xsl:if test="$VarUseNumbering">
   <xsl:apply-templates mode="wwmode:page-summary-content">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Delimit line breaks -->
  <!--                     -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:value-of select="@value" />

 </xsl:template>

 <xsl:template match="*" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:page-summary-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- page-content -->
 <!--              -->

 <xsl:template match="/" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:List | wwdoc:ListItem | wwdoc:Block" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', ./@stylename, $ParamSplit/@documentID, ./@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <xsl:if test="$VarGenerateOutput">
  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Table" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarTable" select="." />
  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Table', $VarTable/@stylename, $ParamSplit/@documentID, $VarTable/@id)" />
  <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <xsl:if test="$VarGenerateOutput">
  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Caption" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableHead" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableBody" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableFoot" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableRow" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:TableCell" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamParagraph" select="." />

  <!-- Getting the relevance for every stylename -->
  <!--                                           -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />
  <xsl:variable name="VarSearchRelevanceWeightOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'search-relevance-weight']/@Value" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputAsText">
   <xsl:apply-templates select="$ParamParagraph" mode="wwmode:generate-output">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="VarGenerateOutput" select="$VarGenerateOutputAsText = string(true())" />

  <xsl:if test="$VarGenerateOutput">
   <xsl:variable name="VarWords">
    <xsl:apply-templates mode="wwmode:page-content">
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
     <!-- Passing a new parameter for saving the relevance weight -->
     <!--                                                         -->
     <xsl:with-param name="ParamRelevance" select="$VarSearchRelevanceWeightOption" />
    </xsl:apply-templates>
   </xsl:variable>

   <!-- Save in a dictionary the words with their relevance -->
   <!--                                                     -->
   <xsl:if test="normalize-space($VarWords)">
    <xsl:variable name="VarGettingWords" select="wwsearch:AddNewWords(normalize-space($VarWords), $VarSearchRelevanceWeightOption)" />
   </xsl:if>

  </xsl:if>

  <!-- Delimit paragraphs -->
  <!--                    -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="wwdoc:Marker" mode="wwmode:marker-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamRelevance" select="1" />

  <xsl:variable name="VarMarkerWords">
   <xsl:apply-templates mode="wwmode:page-content">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <!-- Passing a new parameter for saving the relevance weight -->
    <!--                                                         -->
    <xsl:with-param name="ParamRelevance" select="$ParamRelevance" />
   </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="normalize-space($VarMarkerWords)">
   <xsl:variable name="VarGettingWords" select="wwsearch:AddNewWords(normalize-space($VarMarkerWords), $ParamRelevance)" />
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:TextRun" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <!-- New parameter for getting the relevance weight -->
  <!--                                                -->
  <xsl:param name="ParamRelevance" select="1" />

  <xsl:variable name="VarTextRun" select="." />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Character', $VarTextRun/@stylename, $ParamSplit/@documentID, $VarTextRun/@id)" />

  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />

  <xsl:if test="$VarGenerateOutputOption = string(true())">
   <xsl:apply-templates mode="wwmode:page-content">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <!-- Passing a new parameter for saving the relevance weight -->
    <!--                                                         -->
    <xsl:with-param name="ParamRelevance" select="$ParamRelevance" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Number" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamNumber" select="." />

  <!-- Use numbering? -->
  <!--                  -->
  <xsl:variable name="VarParagraph" select="$ParamNumber/parent::wwdoc:Paragraph" />
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
  <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
  <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption != 'false')" />
  <xsl:if test="$VarUseNumbering">
   <xsl:apply-templates mode="wwmode:page-content">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Delimit line breaks -->
  <!--                     -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <!-- Parameter for getting the relevance weight -->
  <!--                                            -->
  <xsl:param name="ParamRelevance" select="1"/>

  <xsl:value-of select="@value" />

 </xsl:template>

 <xsl:template match="wwdoc:Frame" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamRelevance" select="1" />

  <xsl:apply-templates select="wwdoc:Description" mode="wwmode:page-content-inside-frame">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamRelevance" select="$ParamRelevance" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Description" mode="wwmode:page-content-inside-frame">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamRelevance" select="1" />

  <xsl:text> </xsl:text>
  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamRelevance" select="$ParamRelevance" />
  </xsl:apply-templates>
 </xsl:template>

 <!-- Make sure to include IndexMarkers in the indexed content. -->
 <!--                                                           -->
 <xsl:template match="wwdoc:IndexMarker" mode="wwmode:page-content">
  <xsl:apply-templates select="wwdoc:Entry" mode="wwmode:page-content-inside-IndexMarker">
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Entry" mode="wwmode:page-content-inside-IndexMarker">
  <xsl:apply-templates select="*" mode="wwmode:page-content-inside-IndexMarker">
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Content/wwdoc:TextRun/wwdoc:Text" mode="wwmode:page-content-inside-IndexMarker">
  <xsl:variable name="VarWords" select="normalize-space(@value)" />

  <xsl:if test="$VarWords">
   <!-- Save in a dictionary the words with a relevance of 10 -->
   <!--                                                       -->
   <xsl:variable name="VarGettingWords" select="wwsearch:AddNewWords($VarWords, 10)" />
  </xsl:if>

 </xsl:template>

 <xsl:template match="*" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:page-content">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template name="AddSynonyms">
  <xsl:param name="ParamSynonyms" />

  <xsl:for-each select="$ParamSynonyms">
   <xsl:variable name="VarWord" select="." />

   <xsl:if test="normalize-space($VarWord/@value)">
    <xsl:for-each select="$VarWord/*">
     <xsl:variable name="VarSynonym" select="." />

     <xsl:if test="normalize-space($VarSynonym/@value)">
      <xsl:variable name="VarAddSynonym" select="wwsearch:AddSynonym(normalize-space($VarSynonym/@value), normalize-space($VarWord/@value))" />
     </xsl:if>

    </xsl:for-each>
   </xsl:if>

  </xsl:for-each>

 </xsl:template>

 <msxsl:script language="c#" implements-prefix="wwsearch">
  <msxsl:assembly name="System.Core" />
  <msxsl:using namespace="System.Collections.Generic" />
  <msxsl:using namespace="System.IO" />
  <msxsl:using namespace="System.Text" />

  <![CDATA[
    private StringBuilder mBuffer = new StringBuilder();
    //Dictionary for saving all words with the same relevance, where the relevance is the key
    //
    private Dictionary<float, StringBuilder> mParamStringRelevance = new Dictionary<float, StringBuilder> ();
    private Dictionary<string, Dictionary<string, float>> mIndex = new Dictionary<string, Dictionary<string, float>>();
    private Dictionary<string, long> mPageURIs = new Dictionary<string, long>();
    private Dictionary<string, string> mPageTitles = new Dictionary<string, string>();
    private Dictionary<string, string> mPageSummaries = new Dictionary<string, string>();
    private Dictionary<string, string> mPagePairURIs = new Dictionary<string, string>();
    private Dictionary<string, string> mPageTypes = new Dictionary<string, string>();
    private Dictionary<string, string> mGroupIDs = new Dictionary<string, string>();
    private Dictionary<string, HashSet<string>> mSynonyms = new Dictionary<string, HashSet<string>>();
    private StringBuilder mParagraphSummary = new StringBuilder();

    public void ResetSummary()
    {
      this.mParagraphSummary.Clear();
    }

    public string GetSummary()
    {
      return this.mParagraphSummary.ToString();
    }

    public void AddParagraphToSummary(int paramMinLength,
                                      int paramMaxLength,
                                      string paramParagraph)
    {
      int totalLength = this.mParagraphSummary.Length + paramParagraph.Length;
      int partialLength = paramMaxLength - this.mParagraphSummary.Length;

      if (this.mParagraphSummary.Length > 0)
      {
        // Account for space to be added between paragraphs
        //
        totalLength += 1;
        partialLength -= 1;
      }

      if ((totalLength <= paramMinLength) || (totalLength <= paramMaxLength))
      {
        // Append the entire paragraph
        //
        if (this.mParagraphSummary.Length > 0)
          this.mParagraphSummary.Append(" ");

        this.mParagraphSummary.Append(paramParagraph);
      }
      else if (partialLength > 0 )
      {
        // Append just the allowed characters remaining in the max. allowed summary length
        //
        if (this.mParagraphSummary.Length > 0)
          this.mParagraphSummary.Append(" ");

        if (partialLength < paramParagraph.Length)
        {
          // Truncate the paragraph to the remaining allowed characters
          //
          this.mParagraphSummary.Append(paramParagraph, 0, partialLength);
          this.mParagraphSummary.Append("...");
        }
        else
        {
          // The paragraph was smaller than the remaining allowed characters
          //
          this.mParagraphSummary.Append(paramParagraph);
        }
      }
    }

    public void Reset()
    {
      this.mIndex.Clear();
      this.mPageURIs.Clear();
      this.mPageTitles.Clear();
      this.mPageSummaries.Clear();
      this.mPagePairURIs.Clear();
      this.mPageTypes.Clear();
      this.mGroupIDs.Clear();
      this.mSynonyms.Clear();
      //Cleaning the dictionary
      //
      this.mParamStringRelevance.Clear();
    }

    //Fills out the dictionary mParamStringRelevance with all the words and its relevances
    //
    public void AddNewWords(string words, float relevance)
    {
      //Building the variable that is going to contain all the words with its relevances. It's built here and used in Search_IndexWords
      //
      if( ! mParamStringRelevance.ContainsKey(relevance))
        mParamStringRelevance[relevance] = new StringBuilder();
      mParamStringRelevance[relevance].Append(words+"\n ");
    }

    public void AddSynonym(string word, string synonym)
    {
      synonym = synonym.ToLower();
      word = word.ToLower();

      if(!mSynonyms.ContainsKey(word))
        mSynonyms.Add(word, new HashSet<string>());

      mSynonyms[word].Add(synonym);
    }

    private Dictionary<string, float> Search_IndexWords(int paramMinimumWordLength,
                                                        Dictionary<string, bool> paramStopWords,
                                                        string paramPagePairsPath)
    {
      Dictionary<string, float> result = new Dictionary<string, float>();
      Dictionary<string, Dictionary<string, int>> pageWordPairs;
      Dictionary<string, int> secondWords;

      pageWordPairs = new Dictionary<string, Dictionary<string, int>>();
      // Iterate for all the content chunks grouped by their relevance
      //
      foreach(float relevance in mParamStringRelevance.Keys)
      {
        string chunk = mParamStringRelevance[relevance].ToString();
        string[] paragraphsInOrder = Search_ParseParagraphs(chunk);

        // Iterate for all paragraphs in the chunk
        //
        foreach (string paragraph in paragraphsInOrder)
        {
          // Apply complex word breaks to further delimit valid words using white space
          // Then parse into ordered array of valid words
          //
          string paragraphWords = Search_ApplyWordBreaks(paragraph);
          string [] wordsInOrder = Search_ParseWords(paragraphWords);
          string previousWord = null; // track previous word for 'phrase pairing'

          // Iterate all words in paragraph recording words and word pairs
          //
          foreach (string word in wordsInOrder)
          {
            string wordToLower = word.ToLower();

            // If word meets minimum word length requirement and
            // is not a stop word
            //
            if ((wordToLower.Length >= paramMinimumWordLength) &&
                (!paramStopWords.ContainsKey(wordToLower)))
            {
              // Track word and assign score
              //
              if (result.ContainsKey(wordToLower))
              {
                // Add to every word its relevance
                //
                result[wordToLower] += relevance;
              }
              else
              {
                // Assign to every word its relevance
                //
                result[wordToLower] = relevance;
              }

              // Track word pairs
              //   Do we need to worry about word pairs across any significant boundaries?
              //
              if (!String.IsNullOrEmpty(previousWord))
              {
                if ( ! pageWordPairs.ContainsKey(previousWord))
                {
                  pageWordPairs[previousWord] = new Dictionary<string, int>();
                }
                secondWords = pageWordPairs[previousWord];
                if ( ! secondWords.ContainsKey(wordToLower))
                {
                  secondWords[wordToLower] = 1;
                }
              }
              previousWord = wordToLower;
            }
          }
        }
      }

      // Emit page pairs
      //
      using (StreamWriter writer = new StreamWriter(paramPagePairsPath))
      {
        // Words
        //
        bool first = true;
        writer.Write("var pairs =\n");
        writer.Write("{\n");
        foreach (string firstWord in pageWordPairs.Keys)
        {
          if ( ! first)
          {
            writer.Write(",");
          }
          first = false;

          writer.Write("\"" + this.JavaScriptEncoding(firstWord) + "\":{");
          bool first_second_word = true;
          secondWords = pageWordPairs[firstWord];
          foreach (string secondWord in secondWords.Keys)
          {
            if ( ! first_second_word)
            {
              writer.Write(",");
            }
            first_second_word = false;

            writer.Write("\"" + this.JavaScriptEncoding(secondWord) + "\":1");
          }
          writer.Write("}\n");
        }
        writer.Write("}\n");
        writer.Write(";Search.control.loadWordPairs(pairs);\n");
      }

      return result;
    }

    private Dictionary<string, float> Search_IndexWords(int paramMinimumWordLength,
                                                        string paramStopWords,
                                                        string paramPagePairsPath)
    {
      Dictionary<string, float> result;
      string[] stopWordsAsArray;
      Dictionary<string, bool> stopWords;

      // Parse stop words
      //
      stopWordsAsArray = paramStopWords.Split(' ');
      stopWords = new Dictionary<string, bool>();
      foreach (string stopWord in stopWordsAsArray)
      {
        string trimmedStopWord;

        trimmedStopWord = stopWord.Trim();
        if (trimmedStopWord.Length > 0)
        {
          stopWords[trimmedStopWord.ToLower()] = true;
        }
      }

      // Score words
      //
      result = Search_IndexWords(paramMinimumWordLength
        , stopWords
        , paramPagePairsPath
      );

      return result;
    }

    private string [] Search_ParseParagraphs(string paramString)
    {
      // Strip out line delimiter characters and build ordered array of paragraphs
      //

      return paramString.Split(new Char [] {'\n', '\r'}, StringSplitOptions.RemoveEmptyEntries);
    }

    private string [] Search_ParseWords(string paramString)
    {
      // Strip out white space characters and build ordered array of words
      //

      return paramString.Split(new Char [] {' ', '\t', '\n', '\r'}, StringSplitOptions.RemoveEmptyEntries);
    }

    private string Search_ApplyWordBreaks(string paramString)
    {
      StringBuilder result = new StringBuilder();
      int           index;
      bool          insert_break;

      // Apply Unicode rules for word breaking
      // These rules taken from http://www.unicode.org/unicode/reports/tr29/
      //
      for (index=0; index < paramString.Length; index++) {
        // Break?
        //
        insert_break = Unicode_CheckBreakAtIndex(paramString, index);
        if (insert_break) {
          result.Append(" ");
        }
        result.Append(paramString[index]);
      }

      return result.ToString();
    }


    public void IndexContent(int paramMinimumWordLength,
                             string paramStopWords,
                             string paramPageURI,
                             string paramPageTitle,
                             string paramPageSummary,
                             string paramPagePairsPath,
                             string paramPagePairsURI,
                             string paramPageType,
                             string paramGroupID)
    {
      string parentDirectoryPath;
      Dictionary<string, float> scoredWords;

      // Ensure page pairs path directory hierarchy exists
      //
      parentDirectoryPath = Path.GetDirectoryName(paramPagePairsPath);
      while ( ! Directory.Exists(parentDirectoryPath))
      {
        Directory.CreateDirectory(parentDirectoryPath);

        parentDirectoryPath = Path.GetDirectoryName(parentDirectoryPath);
      }

      // Index words
      //
      scoredWords = Search_IndexWords(paramMinimumWordLength
        , paramStopWords
        , paramPagePairsPath
      );

      // Add page to collected info
      //
      if ( ! this.mPageURIs.ContainsKey(paramPageURI))
      {
        this.mPageURIs[paramPageURI] = this.mPageURIs.Count;
      }
      this.mPageTitles[paramPageURI] = paramPageTitle;
      this.mPageSummaries[paramPageURI] = paramPageSummary;
      this.mPagePairURIs[paramPageURI] = paramPagePairsURI;
      this.mPageTypes[paramPageURI] = paramPageType;
      this.mGroupIDs[paramPageURI] = paramGroupID;
      foreach (string scoredWord in scoredWords.Keys)
      {
        // Word scores
        //
        if ( ! this.mIndex.ContainsKey(scoredWord))
        {
          this.mIndex[scoredWord] = new Dictionary<string, float>();
        }
        this.mIndex[scoredWord][paramPageURI] = scoredWords[scoredWord];
      }

      //Clean the dictionary after finishing indexing all its words
      //
      mParamStringRelevance.Clear();
    }

    private string JavaScriptEncoding(string  value)
    {
      StringBuilder  result;

      result = this.mBuffer;
      result.Length = 0;

      if (value.Length > 0)
      {
        char  character;
        int   characterAsInt;

        for (int  index = 0 ; index < value.Length ; index++)
        {
          character = value[index];
          characterAsInt = Convert.ToInt32(character);

          // Hex encode if outside of the normal ASCII range
          //
          if ((characterAsInt < 0x0020) ||
              (characterAsInt > 0x007F))
          {
            // Unicode escape
            //
            result.AppendFormat("\\u{0:X4}", Convert.ToInt32(value[index]));
          }
          else if (characterAsInt == 0x0022)
          {
            // Escape " character
            //
            result.Append("\\u0022");
          }
          else if (characterAsInt == 0x0027)
          {
            // Escape ' character
            //
            result.Append("\\u0027");
          }
          else if (characterAsInt == 0x002F)
          {
            // Escape / character
            //
            result.Append("\\u002F");
          }
          else if (characterAsInt == 0x005C)
          {
            // Escape \ character
            //
            result.Append("\\u005C");
          }
          else
          {
            // Append character as is
            //
            result.Append(character);
          }
        }
      }

      return result.ToString();
    }

    public void WriteJSON(string paramPath)
    {
      System.Globalization.CultureInfo customCulture = (System.Globalization.CultureInfo)System.Threading.Thread.CurrentThread.CurrentCulture.Clone();
      customCulture.NumberFormat.NumberDecimalSeparator = ".";
      System.Threading.Thread.CurrentThread.CurrentCulture = customCulture;

      using(StreamWriter writer = new StreamWriter(paramPath))
      {
        Dictionary<long, string> pageIndexes = new Dictionary<long, string>();

        // Pages
        //
        pageIndexes = new Dictionary<long, string>();
        foreach (string pageURI in this.mPageURIs.Keys)
        {
          pageIndexes[this.mPageURIs[pageURI]] = pageURI;
        }
        bool first = true;
        writer.Write("var info =\n");
        writer.Write("{\n");
        writer.Write("\"pages\":\n");
        writer.Write("[\n");
        for (int index = 0; index < pageIndexes.Count; index += 1)
        {
          string pageURI = pageIndexes[index];

          if ( ! first)
          {
            writer.Write(",");
          }
          first = false;

          writer.Write(String.Format("[\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\"]\n"
            , this.JavaScriptEncoding(pageURI)
            , this.JavaScriptEncoding(this.mPageTitles[pageURI])
            , this.JavaScriptEncoding(this.mPageSummaries[pageURI])
            , this.JavaScriptEncoding(this.mPagePairURIs[pageURI])
            , this.JavaScriptEncoding(this.mPageTypes[pageURI])
            , this.JavaScriptEncoding(this.mGroupIDs[pageURI])
          ));
        }
        writer.Write("],\n");

        // Words
        //
        first = true;
        writer.Write("\"words\":\n");
        writer.Write("{\n");
        foreach (string item in this.mIndex.Keys)
        {
          if ( ! first)
          {
            writer.Write(",");
          }
          first = false;

          Dictionary<string, float> itemPages;
          itemPages = this.mIndex[item];
          writer.Write("\"" + this.JavaScriptEncoding(item) + "\":[");
          bool first_page_index = true;
          foreach (string page in itemPages.Keys)
          {
            if ( ! first_page_index)
            {
              writer.Write(",");
            }
            first_page_index = false;

            writer.Write(this.mPageURIs[page]);
            writer.Write(",");
            writer.Write(itemPages[page].ToString());
          }
          writer.Write("]\n");
        }
        writer.Write("},\n");

        // Synonyms
        //
        first = true;
        writer.Write("\"synonyms\":\n");
        writer.Write("{\n");

        foreach (string word in this.mSynonyms.Keys)
        {
          if ( ! first)
          {
            writer.Write(",");
          }
          first = false;

          writer.Write("\"" + this.JavaScriptEncoding(word) + "\":[");
          HashSet<string> synonymsOfWord = this.mSynonyms[word];
          bool first_synonym_word = true;
          foreach (string synonym in synonymsOfWord)
          {
            if ( ! first_synonym_word)
            {
              writer.Write(",");
            }
            first_synonym_word = false;

            writer.Write("\"" + this.JavaScriptEncoding(synonym) + "\"");
          }
          writer.Write("]\n");
        }

        writer.Write("}\n");
        writer.Write("}\n");
        writer.Write(";Search.control.advance(info);\n");
      }
    }

    private bool Unicode_Break_CheckBreak_Sequence(char ParamPrevious,
                                                   char ParamCurrent)
    {
      bool VarResult = true;

      if (ParamPrevious == ' ') {
        VarResult = false;
      }
      else if ((UnicodeInfo_Korean_L(ParamPrevious)) &&
               (UnicodeInfo_Korean_L(ParamCurrent))) {
        VarResult = false;
      }
      else if (((UnicodeInfo_Korean_L(ParamPrevious)) ||
               (UnicodeInfo_Korean_LV(ParamPrevious))) &&
               (UnicodeInfo_Korean_LV(ParamCurrent))) {
        VarResult = false;
      }
      else if ((UnicodeInfo_Korean_L(ParamPrevious)) ||
               (UnicodeInfo_Korean_LV(ParamPrevious)) &&
               (UnicodeInfo_Korean_V(ParamCurrent))) {
        VarResult = false;
      }
      else if ((UnicodeInfo_Korean_L(ParamPrevious)) &&
               (UnicodeInfo_Korean_LVT(ParamCurrent))) {
        VarResult = false;
      }
      else if ((UnicodeInfo_Korean_L(ParamPrevious))
               ||
               (UnicodeInfo_Korean_LV(ParamPrevious))
               ||
               (UnicodeInfo_Korean_V(ParamPrevious))
               ||
               (UnicodeInfo_Korean_LVT(ParamPrevious))
               ||
               (UnicodeInfo_Korean_T(ParamPrevious))
               &&
               (UnicodeInfo_Korean_T(ParamCurrent))) {
        VarResult = false;
      }
      else if (
               (
               (UnicodeInfo_ALetter(ParamPrevious))
                 ||
               (UnicodeInfo_ABaseLetter(ParamPrevious))
                 ||
               (UnicodeInfo_ACMLetter(ParamPrevious))
                 ||
               (UnicodeInfo_Numeric(ParamPrevious))
                 ||
               (UnicodeInfo_MidNum(ParamPrevious))
                 ||
               (UnicodeInfo_MidNumLet(ParamPrevious))
                 ||
               (UnicodeInfo_MidLetter(ParamPrevious))
                 ||
               (UnicodeInfo_Katakana(ParamPrevious))
                 ||
               (UnicodeInfo_Hiragana(ParamPrevious))
                 ||
               (UnicodeInfo_Ideographic(ParamPrevious))
                 ||
               (UnicodeInfo_Korean_L(ParamPrevious))
                 ||
               (UnicodeInfo_Korean_LV(ParamPrevious))
                 ||
               (UnicodeInfo_Korean_V(ParamPrevious))
                 ||
               (UnicodeInfo_Korean_LVT(ParamPrevious))
                 ||
               (UnicodeInfo_Korean_T(ParamPrevious))
                 ||
               (UnicodeInfo_Extend(ParamPrevious))
               )
               &&
               (
               (UnicodeInfo_Extend(ParamCurrent))
               )
              )
      {
        VarResult = false;
      }
      else if (
                (
                (UnicodeInfo_ALetter(ParamPrevious))
                  ||
                (UnicodeInfo_Extend(ParamPrevious))
                )
                &&
                (
                (UnicodeInfo_ALetter(ParamCurrent))
                )
              )
      {
        VarResult = false;
      }
      else if (
                (
                 (UnicodeInfo_Katakana(ParamPrevious))
                )
                &&
                (
                 (UnicodeInfo_Katakana(ParamCurrent))
                )
              )
      {
        VarResult = false;
      }
      else if (
                (
                (UnicodeInfo_Numeric(ParamPrevious))
                  ||
                (UnicodeInfo_MidNumLet(ParamPrevious))
                  ||
                (UnicodeInfo_MidLetter(ParamPrevious))
                  ||
                (UnicodeInfo_Extend(ParamPrevious))
                )
                &&
                (
                (UnicodeInfo_ABaseLetter(ParamCurrent))
                  ||
                (UnicodeInfo_ACMLetter(ParamCurrent))
                )
              )
      {
        VarResult = false;
      }
      else if (
                (
                (UnicodeInfo_ALetter(ParamPrevious))
                  ||
                (UnicodeInfo_ABaseLetter(ParamPrevious))
                  ||
                (UnicodeInfo_ACMLetter(ParamPrevious))
                  ||
                (UnicodeInfo_Extend(ParamPrevious))
                )
                &&
                (
                (UnicodeInfo_MidNumLet(ParamCurrent))
                  ||
                (UnicodeInfo_MidLetter(ParamCurrent))
                )
              )
      {
        VarResult = false;
      }
      else if (
                (
                (UnicodeInfo_ABaseLetter(ParamPrevious))
                  ||
                (UnicodeInfo_ACMLetter(ParamPrevious))
                  ||
                (UnicodeInfo_MidNum(ParamPrevious))
                  ||
                (UnicodeInfo_MidNumLet(ParamPrevious))
                  ||
                (UnicodeInfo_Numeric(ParamPrevious))
                  ||
                (UnicodeInfo_Extend(ParamPrevious))
                )
                &&
                (
                (UnicodeInfo_Numeric(ParamCurrent))
                )
              )
      {
        VarResult = false;
      }
      else if (
                (
                (UnicodeInfo_Numeric(ParamPrevious))
                  ||
                (UnicodeInfo_Extend(ParamPrevious))
                )
                &&
                (
                (UnicodeInfo_MidNum(ParamCurrent))
                  ||
                (UnicodeInfo_MidNumLet(ParamCurrent))
                )
              )
      {
        VarResult = false;
      }
      else if (
               (
               (UnicodeInfo_Hiragana(ParamCurrent))
                 ||
               (UnicodeInfo_Ideographic(ParamCurrent))
               )
              )
      {
        VarResult = true;
      }

      return VarResult;
    }

    private bool Unicode_CheckBreakAtIndex(string ParamString,
                                           int    ParamIndex)
    {
      bool VarResult = false;

      if (ParamIndex < ParamString.Length)
      {
        if (ParamString.Length == 1) {
          VarResult = false;
        }
        else if (ParamString.Length > 1) {
          // String is at least two characters long
          //
          if (ParamIndex == 0) {
            VarResult = false;
          }
          else {
            char  VarPrevious = ParamString[ParamIndex - 1];
            char  VarCurrent = ParamString[ParamIndex];

            VarResult = Unicode_Break_CheckBreak_Sequence(VarPrevious, VarCurrent);

            // Check ending
            //
            if (!VarResult)
            {
              // Ending with a middle character?
              //
              if ((UnicodeInfo_MidLetter(VarCurrent))
                   ||
                   (UnicodeInfo_MidNumLet(VarCurrent))
                   ||
                   (UnicodeInfo_MidNum(VarCurrent))) {
                // Check next character
                //
                if ((ParamIndex + 1) == ParamString.Length) {
                  // Break at end of search string
                  //
                  VarResult = true;
                }
                else {
                  char  VarNext = ParamString[ParamIndex + 1];

                  // Depends on the next character
                  //
                  VarResult = Unicode_Break_CheckBreak_Sequence(VarCurrent, VarNext);
                }
              }
            }
          }
        }
      }

      return VarResult;
    }

    // unidata
    //
    // Copyright (c) 2009-2017 Quadralay Corporation.  All rights reserved.
    //

    // Derived from icu/source/data/unidata/DerivedCoreProperties.txt
    //
    // Editor: Visual Studio C# Express 2005
    //
    //   ^{[0-9A-F][0-9A-F][0-9A-F][0-9A-F]}\.\.{[0-9A-F][0-9A-F][0-9A-F][0-9A-F]} +;.*$
    //     if (('\\u\1' <= c) && (c <= '\\u\2')) return true;
    //
    //   ^{[0-9A-F][0-9A-F][0-9A-F][0-9A-F]} +;.*$
    //     if (c == '\\u\1') return true;
    //
    //   ^{[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]}\.\.{[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]} +;.*$
    //     if (('\\u\1' <= c) && (c <= '\\u\2')) return true;
    //
    //   ^{[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]} +;.*$
    //    if (c == '\\u\1') return true;

    public bool UnicodeInfo_Alphabetic(char c)
    {
      if (('\u0041' <= c) && (c <= '\u005A')) return true;
      if (('\u0061' <= c) && (c <= '\u007A')) return true;
      if (c == '\u00AA') return true;
      if (c == '\u00B5') return true;
      if (c == '\u00BA') return true;
      if (('\u00C0' <= c) && (c <= '\u00D6')) return true;
      if (('\u00D8' <= c) && (c <= '\u00F6')) return true;
      if (('\u00F8' <= c) && (c <= '\u01BA')) return true;
      if (c == '\u01BB') return true;
      if (('\u01BC' <= c) && (c <= '\u01BF')) return true;
      if (('\u01C0' <= c) && (c <= '\u01C3')) return true;
      if (('\u01C4' <= c) && (c <= '\u0236')) return true;
      if (('\u0250' <= c) && (c <= '\u02AF')) return true;
      if (('\u02B0' <= c) && (c <= '\u02C1')) return true;
      if (('\u02C6' <= c) && (c <= '\u02D1')) return true;
      if (('\u02E0' <= c) && (c <= '\u02E4')) return true;
      if (c == '\u02EE') return true;
      if (c == '\u0345') return true;
      if (c == '\u037A') return true;
      if (c == '\u0386') return true;
      if (('\u0388' <= c) && (c <= '\u038A')) return true;
      if (c == '\u038C') return true;
      if (('\u038E' <= c) && (c <= '\u03A1')) return true;
      if (('\u03A3' <= c) && (c <= '\u03CE')) return true;
      if (('\u03D0' <= c) && (c <= '\u03F5')) return true;
      if (('\u03F7' <= c) && (c <= '\u03FB')) return true;
      if (('\u0400' <= c) && (c <= '\u0481')) return true;
      if (('\u048A' <= c) && (c <= '\u04CE')) return true;
      if (('\u04D0' <= c) && (c <= '\u04F5')) return true;
      if (('\u04F8' <= c) && (c <= '\u04F9')) return true;
      if (('\u0500' <= c) && (c <= '\u050F')) return true;
      if (('\u0531' <= c) && (c <= '\u0556')) return true;
      if (c == '\u0559') return true;
      if (('\u0561' <= c) && (c <= '\u0587')) return true;
      if (('\u05B0' <= c) && (c <= '\u05B9')) return true;
      if (('\u05BB' <= c) && (c <= '\u05BD')) return true;
      if (c == '\u05BF') return true;
      if (('\u05C1' <= c) && (c <= '\u05C2')) return true;
      if (c == '\u05C4') return true;
      if (('\u05D0' <= c) && (c <= '\u05EA')) return true;
      if (('\u05F0' <= c) && (c <= '\u05F2')) return true;
      if (('\u0610' <= c) && (c <= '\u0615')) return true;
      if (('\u0621' <= c) && (c <= '\u063A')) return true;
      if (c == '\u0640') return true;
      if (('\u0641' <= c) && (c <= '\u064A')) return true;
      if (('\u064B' <= c) && (c <= '\u0657')) return true;
      if (('\u066E' <= c) && (c <= '\u066F')) return true;
      if (c == '\u0670') return true;
      if (('\u0671' <= c) && (c <= '\u06D3')) return true;
      if (c == '\u06D5') return true;
      if (('\u06D6' <= c) && (c <= '\u06DC')) return true;
      if (('\u06E1' <= c) && (c <= '\u06E4')) return true;
      if (('\u06E5' <= c) && (c <= '\u06E6')) return true;
      if (('\u06E7' <= c) && (c <= '\u06E8')) return true;
      if (c == '\u06ED') return true;
      if (('\u06EE' <= c) && (c <= '\u06EF')) return true;
      if (('\u06FA' <= c) && (c <= '\u06FC')) return true;
      if (c == '\u06FF') return true;
      if (c == '\u0710') return true;
      if (c == '\u0711') return true;
      if (('\u0712' <= c) && (c <= '\u072F')) return true;
      if (('\u0730' <= c) && (c <= '\u073F')) return true;
      if (('\u074D' <= c) && (c <= '\u074F')) return true;
      if (('\u0780' <= c) && (c <= '\u07A5')) return true;
      if (('\u07A6' <= c) && (c <= '\u07B0')) return true;
      if (c == '\u07B1') return true;
      if (('\u0901' <= c) && (c <= '\u0902')) return true;
      if (c == '\u0903') return true;
      if (('\u0904' <= c) && (c <= '\u0939')) return true;
      if (c == '\u093D') return true;
      if (('\u093E' <= c) && (c <= '\u0940')) return true;
      if (('\u0941' <= c) && (c <= '\u0948')) return true;
      if (('\u0949' <= c) && (c <= '\u094C')) return true;
      if (c == '\u0950') return true;
      if (('\u0958' <= c) && (c <= '\u0961')) return true;
      if (('\u0962' <= c) && (c <= '\u0963')) return true;
      if (c == '\u0981') return true;
      if (('\u0982' <= c) && (c <= '\u0983')) return true;
      if (('\u0985' <= c) && (c <= '\u098C')) return true;
      if (('\u098F' <= c) && (c <= '\u0990')) return true;
      if (('\u0993' <= c) && (c <= '\u09A8')) return true;
      if (('\u09AA' <= c) && (c <= '\u09B0')) return true;
      if (c == '\u09B2') return true;
      if (('\u09B6' <= c) && (c <= '\u09B9')) return true;
      if (c == '\u09BD') return true;
      if (('\u09BE' <= c) && (c <= '\u09C0')) return true;
      if (('\u09C1' <= c) && (c <= '\u09C4')) return true;
      if (('\u09C7' <= c) && (c <= '\u09C8')) return true;
      if (('\u09CB' <= c) && (c <= '\u09CC')) return true;
      if (c == '\u09D7') return true;
      if (('\u09DC' <= c) && (c <= '\u09DD')) return true;
      if (('\u09DF' <= c) && (c <= '\u09E1')) return true;
      if (('\u09E2' <= c) && (c <= '\u09E3')) return true;
      if (('\u09F0' <= c) && (c <= '\u09F1')) return true;
      if (('\u0A01' <= c) && (c <= '\u0A02')) return true;
      if (c == '\u0A03') return true;
      if (('\u0A05' <= c) && (c <= '\u0A0A')) return true;
      if (('\u0A0F' <= c) && (c <= '\u0A10')) return true;
      if (('\u0A13' <= c) && (c <= '\u0A28')) return true;
      if (('\u0A2A' <= c) && (c <= '\u0A30')) return true;
      if (('\u0A32' <= c) && (c <= '\u0A33')) return true;
      if (('\u0A35' <= c) && (c <= '\u0A36')) return true;
      if (('\u0A38' <= c) && (c <= '\u0A39')) return true;
      if (('\u0A3E' <= c) && (c <= '\u0A40')) return true;
      if (('\u0A41' <= c) && (c <= '\u0A42')) return true;
      if (('\u0A47' <= c) && (c <= '\u0A48')) return true;
      if (('\u0A4B' <= c) && (c <= '\u0A4C')) return true;
      if (('\u0A59' <= c) && (c <= '\u0A5C')) return true;
      if (c == '\u0A5E') return true;
      if (('\u0A70' <= c) && (c <= '\u0A71')) return true;
      if (('\u0A72' <= c) && (c <= '\u0A74')) return true;
      if (('\u0A81' <= c) && (c <= '\u0A82')) return true;
      if (c == '\u0A83') return true;
      if (('\u0A85' <= c) && (c <= '\u0A8D')) return true;
      if (('\u0A8F' <= c) && (c <= '\u0A91')) return true;
      if (('\u0A93' <= c) && (c <= '\u0AA8')) return true;
      if (('\u0AAA' <= c) && (c <= '\u0AB0')) return true;
      if (('\u0AB2' <= c) && (c <= '\u0AB3')) return true;
      if (('\u0AB5' <= c) && (c <= '\u0AB9')) return true;
      if (c == '\u0ABD') return true;
      if (('\u0ABE' <= c) && (c <= '\u0AC0')) return true;
      if (('\u0AC1' <= c) && (c <= '\u0AC5')) return true;
      if (('\u0AC7' <= c) && (c <= '\u0AC8')) return true;
      if (c == '\u0AC9') return true;
      if (('\u0ACB' <= c) && (c <= '\u0ACC')) return true;
      if (c == '\u0AD0') return true;
      if (('\u0AE0' <= c) && (c <= '\u0AE1')) return true;
      if (('\u0AE2' <= c) && (c <= '\u0AE3')) return true;
      if (c == '\u0B01') return true;
      if (('\u0B02' <= c) && (c <= '\u0B03')) return true;
      if (('\u0B05' <= c) && (c <= '\u0B0C')) return true;
      if (('\u0B0F' <= c) && (c <= '\u0B10')) return true;
      if (('\u0B13' <= c) && (c <= '\u0B28')) return true;
      if (('\u0B2A' <= c) && (c <= '\u0B30')) return true;
      if (('\u0B32' <= c) && (c <= '\u0B33')) return true;
      if (('\u0B35' <= c) && (c <= '\u0B39')) return true;
      if (c == '\u0B3D') return true;
      if (c == '\u0B3E') return true;
      if (c == '\u0B3F') return true;
      if (c == '\u0B40') return true;
      if (('\u0B41' <= c) && (c <= '\u0B43')) return true;
      if (('\u0B47' <= c) && (c <= '\u0B48')) return true;
      if (('\u0B4B' <= c) && (c <= '\u0B4C')) return true;
      if (c == '\u0B56') return true;
      if (c == '\u0B57') return true;
      if (('\u0B5C' <= c) && (c <= '\u0B5D')) return true;
      if (('\u0B5F' <= c) && (c <= '\u0B61')) return true;
      if (c == '\u0B71') return true;
      if (c == '\u0B82') return true;
      if (c == '\u0B83') return true;
      if (('\u0B85' <= c) && (c <= '\u0B8A')) return true;
      if (('\u0B8E' <= c) && (c <= '\u0B90')) return true;
      if (('\u0B92' <= c) && (c <= '\u0B95')) return true;
      if (('\u0B99' <= c) && (c <= '\u0B9A')) return true;
      if (c == '\u0B9C') return true;
      if (('\u0B9E' <= c) && (c <= '\u0B9F')) return true;
      if (('\u0BA3' <= c) && (c <= '\u0BA4')) return true;
      if (('\u0BA8' <= c) && (c <= '\u0BAA')) return true;
      if (('\u0BAE' <= c) && (c <= '\u0BB5')) return true;
      if (('\u0BB7' <= c) && (c <= '\u0BB9')) return true;
      if (('\u0BBE' <= c) && (c <= '\u0BBF')) return true;
      if (c == '\u0BC0') return true;
      if (('\u0BC1' <= c) && (c <= '\u0BC2')) return true;
      if (('\u0BC6' <= c) && (c <= '\u0BC8')) return true;
      if (('\u0BCA' <= c) && (c <= '\u0BCC')) return true;
      if (c == '\u0BD7') return true;
      if (('\u0C01' <= c) && (c <= '\u0C03')) return true;
      if (('\u0C05' <= c) && (c <= '\u0C0C')) return true;
      if (('\u0C0E' <= c) && (c <= '\u0C10')) return true;
      if (('\u0C12' <= c) && (c <= '\u0C28')) return true;
      if (('\u0C2A' <= c) && (c <= '\u0C33')) return true;
      if (('\u0C35' <= c) && (c <= '\u0C39')) return true;
      if (('\u0C3E' <= c) && (c <= '\u0C40')) return true;
      if (('\u0C41' <= c) && (c <= '\u0C44')) return true;
      if (('\u0C46' <= c) && (c <= '\u0C48')) return true;
      if (('\u0C4A' <= c) && (c <= '\u0C4C')) return true;
      if (('\u0C55' <= c) && (c <= '\u0C56')) return true;
      if (('\u0C60' <= c) && (c <= '\u0C61')) return true;
      if (('\u0C82' <= c) && (c <= '\u0C83')) return true;
      if (('\u0C85' <= c) && (c <= '\u0C8C')) return true;
      if (('\u0C8E' <= c) && (c <= '\u0C90')) return true;
      if (('\u0C92' <= c) && (c <= '\u0CA8')) return true;
      if (('\u0CAA' <= c) && (c <= '\u0CB3')) return true;
      if (('\u0CB5' <= c) && (c <= '\u0CB9')) return true;
      if (c == '\u0CBD') return true;
      if (c == '\u0CBE') return true;
      if (c == '\u0CBF') return true;
      if (('\u0CC0' <= c) && (c <= '\u0CC4')) return true;
      if (c == '\u0CC6') return true;
      if (('\u0CC7' <= c) && (c <= '\u0CC8')) return true;
      if (('\u0CCA' <= c) && (c <= '\u0CCB')) return true;
      if (c == '\u0CCC') return true;
      if (('\u0CD5' <= c) && (c <= '\u0CD6')) return true;
      if (c == '\u0CDE') return true;
      if (('\u0CE0' <= c) && (c <= '\u0CE1')) return true;
      if (('\u0D02' <= c) && (c <= '\u0D03')) return true;
      if (('\u0D05' <= c) && (c <= '\u0D0C')) return true;
      if (('\u0D0E' <= c) && (c <= '\u0D10')) return true;
      if (('\u0D12' <= c) && (c <= '\u0D28')) return true;
      if (('\u0D2A' <= c) && (c <= '\u0D39')) return true;
      if (('\u0D3E' <= c) && (c <= '\u0D40')) return true;
      if (('\u0D41' <= c) && (c <= '\u0D43')) return true;
      if (('\u0D46' <= c) && (c <= '\u0D48')) return true;
      if (('\u0D4A' <= c) && (c <= '\u0D4C')) return true;
      if (c == '\u0D57') return true;
      if (('\u0D60' <= c) && (c <= '\u0D61')) return true;
      if (('\u0D82' <= c) && (c <= '\u0D83')) return true;
      if (('\u0D85' <= c) && (c <= '\u0D96')) return true;
      if (('\u0D9A' <= c) && (c <= '\u0DB1')) return true;
      if (('\u0DB3' <= c) && (c <= '\u0DBB')) return true;
      if (c == '\u0DBD') return true;
      if (('\u0DC0' <= c) && (c <= '\u0DC6')) return true;
      if (('\u0DCF' <= c) && (c <= '\u0DD1')) return true;
      if (('\u0DD2' <= c) && (c <= '\u0DD4')) return true;
      if (c == '\u0DD6') return true;
      if (('\u0DD8' <= c) && (c <= '\u0DDF')) return true;
      if (('\u0DF2' <= c) && (c <= '\u0DF3')) return true;
      if (('\u0E01' <= c) && (c <= '\u0E30')) return true;
      if (c == '\u0E31') return true;
      if (('\u0E32' <= c) && (c <= '\u0E33')) return true;
      if (('\u0E34' <= c) && (c <= '\u0E3A')) return true;
      if (('\u0E40' <= c) && (c <= '\u0E45')) return true;
      if (c == '\u0E46') return true;
      if (c == '\u0E4D') return true;
      if (('\u0E81' <= c) && (c <= '\u0E82')) return true;
      if (c == '\u0E84') return true;
      if (('\u0E87' <= c) && (c <= '\u0E88')) return true;
      if (c == '\u0E8A') return true;
      if (c == '\u0E8D') return true;
      if (('\u0E94' <= c) && (c <= '\u0E97')) return true;
      if (('\u0E99' <= c) && (c <= '\u0E9F')) return true;
      if (('\u0EA1' <= c) && (c <= '\u0EA3')) return true;
      if (c == '\u0EA5') return true;
      if (c == '\u0EA7') return true;
      if (('\u0EAA' <= c) && (c <= '\u0EAB')) return true;
      if (('\u0EAD' <= c) && (c <= '\u0EB0')) return true;
      if (c == '\u0EB1') return true;
      if (('\u0EB2' <= c) && (c <= '\u0EB3')) return true;
      if (('\u0EB4' <= c) && (c <= '\u0EB9')) return true;
      if (('\u0EBB' <= c) && (c <= '\u0EBC')) return true;
      if (c == '\u0EBD') return true;
      if (('\u0EC0' <= c) && (c <= '\u0EC4')) return true;
      if (c == '\u0EC6') return true;
      if (c == '\u0ECD') return true;
      if (('\u0EDC' <= c) && (c <= '\u0EDD')) return true;
      if (c == '\u0F00') return true;
      if (('\u0F40' <= c) && (c <= '\u0F47')) return true;
      if (('\u0F49' <= c) && (c <= '\u0F6A')) return true;
      if (('\u0F71' <= c) && (c <= '\u0F7E')) return true;
      if (c == '\u0F7F') return true;
      if (('\u0F80' <= c) && (c <= '\u0F81')) return true;
      if (('\u0F88' <= c) && (c <= '\u0F8B')) return true;
      if (('\u0F90' <= c) && (c <= '\u0F97')) return true;
      if (('\u0F99' <= c) && (c <= '\u0FBC')) return true;
      if (('\u1000' <= c) && (c <= '\u1021')) return true;
      if (('\u1023' <= c) && (c <= '\u1027')) return true;
      if (('\u1029' <= c) && (c <= '\u102A')) return true;
      if (c == '\u102C') return true;
      if (('\u102D' <= c) && (c <= '\u1030')) return true;
      if (c == '\u1031') return true;
      if (c == '\u1032') return true;
      if (c == '\u1036') return true;
      if (c == '\u1038') return true;
      if (('\u1050' <= c) && (c <= '\u1055')) return true;
      if (('\u1056' <= c) && (c <= '\u1057')) return true;
      if (('\u1058' <= c) && (c <= '\u1059')) return true;
      if (('\u10A0' <= c) && (c <= '\u10C5')) return true;
      if (('\u10D0' <= c) && (c <= '\u10F8')) return true;
      if (('\u1100' <= c) && (c <= '\u1159')) return true;
      if (('\u115F' <= c) && (c <= '\u11A2')) return true;
      if (('\u11A8' <= c) && (c <= '\u11F9')) return true;
      if (('\u1200' <= c) && (c <= '\u1206')) return true;
      if (('\u1208' <= c) && (c <= '\u1246')) return true;
      if (c == '\u1248') return true;
      if (('\u124A' <= c) && (c <= '\u124D')) return true;
      if (('\u1250' <= c) && (c <= '\u1256')) return true;
      if (c == '\u1258') return true;
      if (('\u125A' <= c) && (c <= '\u125D')) return true;
      if (('\u1260' <= c) && (c <= '\u1286')) return true;
      if (c == '\u1288') return true;
      if (('\u128A' <= c) && (c <= '\u128D')) return true;
      if (('\u1290' <= c) && (c <= '\u12AE')) return true;
      if (c == '\u12B0') return true;
      if (('\u12B2' <= c) && (c <= '\u12B5')) return true;
      if (('\u12B8' <= c) && (c <= '\u12BE')) return true;
      if (c == '\u12C0') return true;
      if (('\u12C2' <= c) && (c <= '\u12C5')) return true;
      if (('\u12C8' <= c) && (c <= '\u12CE')) return true;
      if (('\u12D0' <= c) && (c <= '\u12D6')) return true;
      if (('\u12D8' <= c) && (c <= '\u12EE')) return true;
      if (('\u12F0' <= c) && (c <= '\u130E')) return true;
      if (c == '\u1310') return true;
      if (('\u1312' <= c) && (c <= '\u1315')) return true;
      if (('\u1318' <= c) && (c <= '\u131E')) return true;
      if (('\u1320' <= c) && (c <= '\u1346')) return true;
      if (('\u1348' <= c) && (c <= '\u135A')) return true;
      if (('\u13A0' <= c) && (c <= '\u13F4')) return true;
      if (('\u1401' <= c) && (c <= '\u166C')) return true;
      if (('\u166F' <= c) && (c <= '\u1676')) return true;
      if (('\u1681' <= c) && (c <= '\u169A')) return true;
      if (('\u16A0' <= c) && (c <= '\u16EA')) return true;
      if (('\u16EE' <= c) && (c <= '\u16F0')) return true;
      if (('\u1700' <= c) && (c <= '\u170C')) return true;
      if (('\u170E' <= c) && (c <= '\u1711')) return true;
      if (('\u1712' <= c) && (c <= '\u1713')) return true;
      if (('\u1720' <= c) && (c <= '\u1731')) return true;
      if (('\u1732' <= c) && (c <= '\u1733')) return true;
      if (('\u1740' <= c) && (c <= '\u1751')) return true;
      if (('\u1752' <= c) && (c <= '\u1753')) return true;
      if (('\u1760' <= c) && (c <= '\u176C')) return true;
      if (('\u176E' <= c) && (c <= '\u1770')) return true;
      if (('\u1772' <= c) && (c <= '\u1773')) return true;
      if (('\u1780' <= c) && (c <= '\u17B3')) return true;
      if (c == '\u17B6') return true;
      if (('\u17B7' <= c) && (c <= '\u17BD')) return true;
      if (('\u17BE' <= c) && (c <= '\u17C5')) return true;
      if (c == '\u17C6') return true;
      if (('\u17C7' <= c) && (c <= '\u17C8')) return true;
      if (c == '\u17D7') return true;
      if (c == '\u17DC') return true;
      if (('\u1820' <= c) && (c <= '\u1842')) return true;
      if (c == '\u1843') return true;
      if (('\u1844' <= c) && (c <= '\u1877')) return true;
      if (('\u1880' <= c) && (c <= '\u18A8')) return true;
      if (c == '\u18A9') return true;
      if (('\u1900' <= c) && (c <= '\u191C')) return true;
      if (('\u1920' <= c) && (c <= '\u1922')) return true;
      if (('\u1923' <= c) && (c <= '\u1926')) return true;
      if (('\u1927' <= c) && (c <= '\u1928')) return true;
      if (('\u1929' <= c) && (c <= '\u192B')) return true;
      if (('\u1930' <= c) && (c <= '\u1931')) return true;
      if (c == '\u1932') return true;
      if (('\u1933' <= c) && (c <= '\u1938')) return true;
      if (('\u1950' <= c) && (c <= '\u196D')) return true;
      if (('\u1970' <= c) && (c <= '\u1974')) return true;
      if (('\u1D00' <= c) && (c <= '\u1D2B')) return true;
      if (('\u1D2C' <= c) && (c <= '\u1D61')) return true;
      if (('\u1D62' <= c) && (c <= '\u1D6B')) return true;
      if (('\u1E00' <= c) && (c <= '\u1E9B')) return true;
      if (('\u1EA0' <= c) && (c <= '\u1EF9')) return true;
      if (('\u1F00' <= c) && (c <= '\u1F15')) return true;
      if (('\u1F18' <= c) && (c <= '\u1F1D')) return true;
      if (('\u1F20' <= c) && (c <= '\u1F45')) return true;
      if (('\u1F48' <= c) && (c <= '\u1F4D')) return true;
      if (('\u1F50' <= c) && (c <= '\u1F57')) return true;
      if (c == '\u1F59') return true;
      if (c == '\u1F5B') return true;
      if (c == '\u1F5D') return true;
      if (('\u1F5F' <= c) && (c <= '\u1F7D')) return true;
      if (('\u1F80' <= c) && (c <= '\u1FB4')) return true;
      if (('\u1FB6' <= c) && (c <= '\u1FBC')) return true;
      if (c == '\u1FBE') return true;
      if (('\u1FC2' <= c) && (c <= '\u1FC4')) return true;
      if (('\u1FC6' <= c) && (c <= '\u1FCC')) return true;
      if (('\u1FD0' <= c) && (c <= '\u1FD3')) return true;
      if (('\u1FD6' <= c) && (c <= '\u1FDB')) return true;
      if (('\u1FE0' <= c) && (c <= '\u1FEC')) return true;
      if (('\u1FF2' <= c) && (c <= '\u1FF4')) return true;
      if (('\u1FF6' <= c) && (c <= '\u1FFC')) return true;
      if (c == '\u2071') return true;
      if (c == '\u207F') return true;
      if (c == '\u2102') return true;
      if (c == '\u2107') return true;
      if (('\u210A' <= c) && (c <= '\u2113')) return true;
      if (c == '\u2115') return true;
      if (('\u2119' <= c) && (c <= '\u211D')) return true;
      if (c == '\u2124') return true;
      if (c == '\u2126') return true;
      if (c == '\u2128') return true;
      if (('\u212A' <= c) && (c <= '\u212D')) return true;
      if (('\u212F' <= c) && (c <= '\u2131')) return true;
      if (('\u2133' <= c) && (c <= '\u2134')) return true;
      if (('\u2135' <= c) && (c <= '\u2138')) return true;
      if (c == '\u2139') return true;
      if (('\u213D' <= c) && (c <= '\u213F')) return true;
      if (('\u2145' <= c) && (c <= '\u2149')) return true;
      if (('\u2160' <= c) && (c <= '\u2183')) return true;
      if (c == '\u3005') return true;
      if (c == '\u3006') return true;
      if (c == '\u3007') return true;
      if (('\u3021' <= c) && (c <= '\u3029')) return true;
      if (('\u3031' <= c) && (c <= '\u3035')) return true;
      if (('\u3038' <= c) && (c <= '\u303A')) return true;
      if (c == '\u303B') return true;
      if (c == '\u303C') return true;
      if (('\u3041' <= c) && (c <= '\u3096')) return true;
      if (('\u309D' <= c) && (c <= '\u309E')) return true;
      if (c == '\u309F') return true;
      if (('\u30A1' <= c) && (c <= '\u30FA')) return true;
      if (('\u30FC' <= c) && (c <= '\u30FE')) return true;
      if (c == '\u30FF') return true;
      if (('\u3105' <= c) && (c <= '\u312C')) return true;
      if (('\u3131' <= c) && (c <= '\u318E')) return true;
      if (('\u31A0' <= c) && (c <= '\u31B7')) return true;
      if (('\u31F0' <= c) && (c <= '\u31FF')) return true;
      if (('\u3400' <= c) && (c <= '\u4DB5')) return true;
      if (('\u4E00' <= c) && (c <= '\u9FA5')) return true;
      if (('\uA000' <= c) && (c <= '\uA48C')) return true;
      if (('\uAC00' <= c) && (c <= '\uD7A3')) return true;
      if (('\uF900' <= c) && (c <= '\uFA2D')) return true;
      if (('\uFA30' <= c) && (c <= '\uFA6A')) return true;
      if (('\uFB00' <= c) && (c <= '\uFB06')) return true;
      if (('\uFB13' <= c) && (c <= '\uFB17')) return true;
      if (c == '\uFB1D') return true;
      if (c == '\uFB1E') return true;
      if (('\uFB1F' <= c) && (c <= '\uFB28')) return true;
      if (('\uFB2A' <= c) && (c <= '\uFB36')) return true;
      if (('\uFB38' <= c) && (c <= '\uFB3C')) return true;
      if (c == '\uFB3E') return true;
      if (('\uFB40' <= c) && (c <= '\uFB41')) return true;
      if (('\uFB43' <= c) && (c <= '\uFB44')) return true;
      if (('\uFB46' <= c) && (c <= '\uFBB1')) return true;
      if (('\uFBD3' <= c) && (c <= '\uFD3D')) return true;
      if (('\uFD50' <= c) && (c <= '\uFD8F')) return true;
      if (('\uFD92' <= c) && (c <= '\uFDC7')) return true;
      if (('\uFDF0' <= c) && (c <= '\uFDFB')) return true;
      if (('\uFE70' <= c) && (c <= '\uFE74')) return true;
      if (('\uFE76' <= c) && (c <= '\uFEFC')) return true;
      if (('\uFF21' <= c) && (c <= '\uFF3A')) return true;
      if (('\uFF41' <= c) && (c <= '\uFF5A')) return true;
      if (('\uFF66' <= c) && (c <= '\uFF6F')) return true;
      if (c == '\uFF70') return true;
      if (('\uFF71' <= c) && (c <= '\uFF9D')) return true;
      if (('\uFF9E' <= c) && (c <= '\uFF9F')) return true;
      if (('\uFFA0' <= c) && (c <= '\uFFBE')) return true;
      if (('\uFFC2' <= c) && (c <= '\uFFC7')) return true;
      if (('\uFFCA' <= c) && (c <= '\uFFCF')) return true;
      if (('\uFFD2' <= c) && (c <= '\uFFD7')) return true;
      if (('\uFFDA' <= c) && (c <= '\uFFDC')) return true;
      if ((char.ConvertFromUtf32(0x10000)[0] <= c) && (c <= char.ConvertFromUtf32(0x1000B)[0])) return true;
      if ((char.ConvertFromUtf32(0x1000D)[0] <= c) && (c <= char.ConvertFromUtf32(0x10026)[0])) return true;
      if ((char.ConvertFromUtf32(0x10028)[0] <= c) && (c <= char.ConvertFromUtf32(0x1003A)[0])) return true;
      if ((char.ConvertFromUtf32(0x1003C)[0] <= c) && (c <= char.ConvertFromUtf32(0x1003D)[0])) return true;
      if ((char.ConvertFromUtf32(0x1003F)[0] <= c) && (c <= char.ConvertFromUtf32(0x1004D)[0])) return true;
      if ((char.ConvertFromUtf32(0x10050)[0] <= c) && (c <= char.ConvertFromUtf32(0x1005D)[0])) return true;
      if ((char.ConvertFromUtf32(0x10080)[0] <= c) && (c <= char.ConvertFromUtf32(0x100FA)[0])) return true;
      if ((char.ConvertFromUtf32(0x10300)[0] <= c) && (c <= char.ConvertFromUtf32(0x1031E)[0])) return true;
      if ((char.ConvertFromUtf32(0x10330)[0] <= c) && (c <= char.ConvertFromUtf32(0x10349)[0])) return true;
      if (c == char.ConvertFromUtf32(0x1034A)[0]) return true;
      if ((char.ConvertFromUtf32(0x10380)[0] <= c) && (c <= char.ConvertFromUtf32(0x1039D)[0])) return true;
      if ((char.ConvertFromUtf32(0x10400)[0] <= c) && (c <= char.ConvertFromUtf32(0x1044F)[0])) return true;
      if ((char.ConvertFromUtf32(0x10450)[0] <= c) && (c <= char.ConvertFromUtf32(0x1049D)[0])) return true;
      if ((char.ConvertFromUtf32(0x10800)[0] <= c) && (c <= char.ConvertFromUtf32(0x10805)[0])) return true;
      if (c == char.ConvertFromUtf32(0x10808)[0]) return true;
      if ((char.ConvertFromUtf32(0x1080A)[0] <= c) && (c <= char.ConvertFromUtf32(0x10835)[0])) return true;
      if ((char.ConvertFromUtf32(0x10837)[0] <= c) && (c <= char.ConvertFromUtf32(0x10838)[0])) return true;
      if (c == char.ConvertFromUtf32(0x1083C)[0]) return true;
      if (c == char.ConvertFromUtf32(0x1083F)[0]) return true;
      if ((char.ConvertFromUtf32(0x1D400)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D454)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D456)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D49C)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D49E)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D49F)[0])) return true;
      if (c == char.ConvertFromUtf32(0x1D4A2)[0]) return true;
      if ((char.ConvertFromUtf32(0x1D4A5)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D4A6)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D4A9)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D4AC)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D4AE)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D4B9)[0])) return true;
      if (c == char.ConvertFromUtf32(0x1D4BB)[0]) return true;
      if ((char.ConvertFromUtf32(0x1D4BD)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D4C3)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D4C5)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D505)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D507)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D50A)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D50D)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D514)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D516)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D51C)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D51E)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D539)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D53B)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D53E)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D540)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D544)[0])) return true;
      if (c == char.ConvertFromUtf32(0x1D546)[0]) return true;
      if ((char.ConvertFromUtf32(0x1D54A)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D550)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D552)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D6A3)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D6A8)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D6C0)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D6C2)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D6DA)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D6DC)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D6FA)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D6FC)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D714)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D716)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D734)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D736)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D74E)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D750)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D76E)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D770)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D788)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D78A)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D7A8)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D7AA)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D7C2)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D7C4)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D7C9)[0])) return true;
      if ((char.ConvertFromUtf32(0x20000)[0] <= c) && (c <= char.ConvertFromUtf32(0x2A6D6)[0])) return true;
      if ((char.ConvertFromUtf32(0x2F800)[0] <= c) && (c <= char.ConvertFromUtf32(0x2FA1D)[0])) return true;

      return false;
    }

    public bool UnicodeInfo_Grapheme_Extend(char c)
    {
      if (('\u0300' <= c) && (c <= '\u0357')) return true;
      if (('\u035D' <= c) && (c <= '\u036F')) return true;
      if (('\u0483' <= c) && (c <= '\u0486')) return true;
      if (('\u0488' <= c) && (c <= '\u0489')) return true;
      if (('\u0591' <= c) && (c <= '\u05A1')) return true;
      if (('\u05A3' <= c) && (c <= '\u05B9')) return true;
      if (('\u05BB' <= c) && (c <= '\u05BD')) return true;
      if (c == '\u05BF') return true;
      if (('\u05C1' <= c) && (c <= '\u05C2')) return true;
      if (c == '\u05C4') return true;
      if (('\u0610' <= c) && (c <= '\u0615')) return true;
      if (('\u064B' <= c) && (c <= '\u0658')) return true;
      if (c == '\u0670') return true;
      if (('\u06D6' <= c) && (c <= '\u06DC')) return true;
      if (c == '\u06DE') return true;
      if (('\u06DF' <= c) && (c <= '\u06E4')) return true;
      if (('\u06E7' <= c) && (c <= '\u06E8')) return true;
      if (('\u06EA' <= c) && (c <= '\u06ED')) return true;
      if (c == '\u0711') return true;
      if (('\u0730' <= c) && (c <= '\u074A')) return true;
      if (('\u07A6' <= c) && (c <= '\u07B0')) return true;
      if (('\u0901' <= c) && (c <= '\u0902')) return true;
      if (c == '\u093C') return true;
      if (('\u0941' <= c) && (c <= '\u0948')) return true;
      if (c == '\u094D') return true;
      if (('\u0951' <= c) && (c <= '\u0954')) return true;
      if (('\u0962' <= c) && (c <= '\u0963')) return true;
      if (c == '\u0981') return true;
      if (c == '\u09BC') return true;
      if (c == '\u09BE') return true;
      if (('\u09C1' <= c) && (c <= '\u09C4')) return true;
      if (c == '\u09CD') return true;
      if (c == '\u09D7') return true;
      if (('\u09E2' <= c) && (c <= '\u09E3')) return true;
      if (('\u0A01' <= c) && (c <= '\u0A02')) return true;
      if (c == '\u0A3C') return true;
      if (('\u0A41' <= c) && (c <= '\u0A42')) return true;
      if (('\u0A47' <= c) && (c <= '\u0A48')) return true;
      if (('\u0A4B' <= c) && (c <= '\u0A4D')) return true;
      if (('\u0A70' <= c) && (c <= '\u0A71')) return true;
      if (('\u0A81' <= c) && (c <= '\u0A82')) return true;
      if (c == '\u0ABC') return true;
      if (('\u0AC1' <= c) && (c <= '\u0AC5')) return true;
      if (('\u0AC7' <= c) && (c <= '\u0AC8')) return true;
      if (c == '\u0ACD') return true;
      if (('\u0AE2' <= c) && (c <= '\u0AE3')) return true;
      if (c == '\u0B01') return true;
      if (c == '\u0B3C') return true;
      if (c == '\u0B3E') return true;
      if (c == '\u0B3F') return true;
      if (('\u0B41' <= c) && (c <= '\u0B43')) return true;
      if (c == '\u0B4D') return true;
      if (c == '\u0B56') return true;
      if (c == '\u0B57') return true;
      if (c == '\u0B82') return true;
      if (c == '\u0BBE') return true;
      if (c == '\u0BC0') return true;
      if (c == '\u0BCD') return true;
      if (c == '\u0BD7') return true;
      if (('\u0C3E' <= c) && (c <= '\u0C40')) return true;
      if (('\u0C46' <= c) && (c <= '\u0C48')) return true;
      if (('\u0C4A' <= c) && (c <= '\u0C4D')) return true;
      if (('\u0C55' <= c) && (c <= '\u0C56')) return true;
      if (c == '\u0CBC') return true;
      if (c == '\u0CBF') return true;
      if (c == '\u0CC2') return true;
      if (c == '\u0CC6') return true;
      if (('\u0CCC' <= c) && (c <= '\u0CCD')) return true;
      if (('\u0CD5' <= c) && (c <= '\u0CD6')) return true;
      if (c == '\u0D3E') return true;
      if (('\u0D41' <= c) && (c <= '\u0D43')) return true;
      if (c == '\u0D4D') return true;
      if (c == '\u0D57') return true;
      if (c == '\u0DCA') return true;
      if (c == '\u0DCF') return true;
      if (('\u0DD2' <= c) && (c <= '\u0DD4')) return true;
      if (c == '\u0DD6') return true;
      if (c == '\u0DDF') return true;
      if (c == '\u0E31') return true;
      if (('\u0E34' <= c) && (c <= '\u0E3A')) return true;
      if (('\u0E47' <= c) && (c <= '\u0E4E')) return true;
      if (c == '\u0EB1') return true;
      if (('\u0EB4' <= c) && (c <= '\u0EB9')) return true;
      if (('\u0EBB' <= c) && (c <= '\u0EBC')) return true;
      if (('\u0EC8' <= c) && (c <= '\u0ECD')) return true;
      if (('\u0F18' <= c) && (c <= '\u0F19')) return true;
      if (c == '\u0F35') return true;
      if (c == '\u0F37') return true;
      if (c == '\u0F39') return true;
      if (('\u0F71' <= c) && (c <= '\u0F7E')) return true;
      if (('\u0F80' <= c) && (c <= '\u0F84')) return true;
      if (('\u0F86' <= c) && (c <= '\u0F87')) return true;
      if (('\u0F90' <= c) && (c <= '\u0F97')) return true;
      if (('\u0F99' <= c) && (c <= '\u0FBC')) return true;
      if (c == '\u0FC6') return true;
      if (('\u102D' <= c) && (c <= '\u1030')) return true;
      if (c == '\u1032') return true;
      if (('\u1036' <= c) && (c <= '\u1037')) return true;
      if (c == '\u1039') return true;
      if (('\u1058' <= c) && (c <= '\u1059')) return true;
      if (('\u1712' <= c) && (c <= '\u1714')) return true;
      if (('\u1732' <= c) && (c <= '\u1734')) return true;
      if (('\u1752' <= c) && (c <= '\u1753')) return true;
      if (('\u1772' <= c) && (c <= '\u1773')) return true;
      if (('\u17B7' <= c) && (c <= '\u17BD')) return true;
      if (c == '\u17C6') return true;
      if (('\u17C9' <= c) && (c <= '\u17D3')) return true;
      if (c == '\u17DD') return true;
      if (('\u180B' <= c) && (c <= '\u180D')) return true;
      if (c == '\u18A9') return true;
      if (('\u1920' <= c) && (c <= '\u1922')) return true;
      if (('\u1927' <= c) && (c <= '\u1928')) return true;
      if (c == '\u1932') return true;
      if (('\u1939' <= c) && (c <= '\u193B')) return true;
      if (('\u200C' <= c) && (c <= '\u200D')) return true;
      if (('\u20D0' <= c) && (c <= '\u20DC')) return true;
      if (('\u20DD' <= c) && (c <= '\u20E0')) return true;
      if (c == '\u20E1') return true;
      if (('\u20E2' <= c) && (c <= '\u20E4')) return true;
      if (('\u20E5' <= c) && (c <= '\u20EA')) return true;
      if (('\u302A' <= c) && (c <= '\u302F')) return true;
      if (('\u3099' <= c) && (c <= '\u309A')) return true;
      if (c == '\uFB1E') return true;
      if (('\uFE00' <= c) && (c <= '\uFE0F')) return true;
      if (('\uFE20' <= c) && (c <= '\uFE23')) return true;
      if (c == char.ConvertFromUtf32(0x1D165)[0]) return true;
      if ((char.ConvertFromUtf32(0x1D167)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D169)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D16E)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D16F)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D17B)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D182)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D185)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D18B)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D1AA)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D1AD)[0])) return true;
      if ((char.ConvertFromUtf32(0xE0100)[0] <= c) && (c <= char.ConvertFromUtf32(0xE01EF)[0])) return true;

      return false;
    }

    public bool UnicodeInfo_Extend(char c)
    {
      return (UnicodeInfo_Grapheme_Extend(c) ||
              UnicodeInfo_WWNoBreak(c));
    }

    // http://en.wikipedia.org/wiki/Kana
    //
    // Hiragana range in Unicode is U+3040 ... U+309F, and the Katakana range is U+30A0 ... U+30FF.
    //

    public bool UnicodeInfo_Hiragana(char c)
    {
      if (('\u3040' <= c) && (c <= '\u309F')) return true;

      return false;
    }

    public bool UnicodeInfo_Katakana(char c)
    {
      if (('\u30A0' <= c) && (c <= '\u30FF')) return true;
      if (c == '\u30FC') return true;
      if (c == '\uFF70') return true;
      if (c == '\uFF9E') return true;
      if (c == '\uFF9F') return true;

      return false;
    }

    public bool UnicodeInfo_Ideographic(char c)
    {
      if (('\u1100' <= c) && (c <= '\u1159')) return true;
      if (c == '\u115F') return true;
      if (('\u2E80' <= c) && (c <= '\u2E99')) return true;
      if (('\u2E9B' <= c) && (c <= '\u2EF3')) return true;
      if (('\u2F00' <= c) && (c <= '\u2FD5')) return true;
      if (('\u2FF0' <= c) && (c <= '\u2FFB')) return true;
      if (c == '\u3000') return true;
      if (('\u3003' <= c) && (c <= '\u3004')) return true;
      if (('\u3006' <= c) && (c <= '\u3007')) return true;
      if (('\u3012' <= c) && (c <= '\u3013')) return true;
      if (('\u3020' <= c) && (c <= '\u3029')) return true;
      if (('\u3030' <= c) && (c <= '\u303A')) return true;
      if (('\u303D' <= c) && (c <= '\u303F')) return true;
      if (c == '\u3042') return true;
      if (c == '\u3044') return true;
      if (c == '\u3046') return true;
      if (c == '\u3048') return true;
      if (('\u304A' <= c) && (c <= '\u3062')) return true;
      if (('\u3064' <= c) && (c <= '\u3082')) return true;
      if (c == '\u3084') return true;
      if (c == '\u3086') return true;
      if (('\u3088' <= c) && (c <= '\u308D')) return true;
      if (('\u308F' <= c) && (c <= '\u3094')) return true;
      if (c == '\u309F') return true;
      if (c == '\u30A2') return true;
      if (c == '\u30A4') return true;
      if (c == '\u30A6') return true;
      if (c == '\u30A8') return true;
      if (('\u30AA' <= c) && (c <= '\u30C2')) return true;
      if (('\u30C4' <= c) && (c <= '\u30E2')) return true;
      if (c == '\u30E4') return true;
      if (c == '\u30E6') return true;
      if (('\u30E8' <= c) && (c <= '\u30ED')) return true;
      if (('\u30EF' <= c) && (c <= '\u30F4')) return true;
      if (('\u30F7' <= c) && (c <= '\u30FA')) return true;
      if (c == '\u30FC') return true;
      if (('\u30FE' <= c) && (c <= '\u30FF')) return true;
      if (('\u3105' <= c) && (c <= '\u312C')) return true;
      if (('\u3131' <= c) && (c <= '\u318E')) return true;
      if (('\u3190' <= c) && (c <= '\u31B7')) return true;
      if (('\u3200' <= c) && (c <= '\u321C')) return true;
      if (('\u3220' <= c) && (c <= '\u3243')) return true;
      if (('\u3251' <= c) && (c <= '\u327B')) return true;
      if (('\u327F' <= c) && (c <= '\u32CB')) return true;
      if (('\u32D0' <= c) && (c <= '\u32FE')) return true;
      if (('\u3300' <= c) && (c <= '\u3376')) return true;
      if (('\u337B' <= c) && (c <= '\u33DD')) return true;
      if (('\u33E0' <= c) && (c <= '\u33FE')) return true;
      if (('\u3400' <= c) && (c <= '\u4DB5')) return true;
      if (('\u4E00' <= c) && (c <= '\u9FA5')) return true;
      if (('\uA000' <= c) && (c <= '\uA48C')) return true;
      if (('\uA490' <= c) && (c <= '\uA4C6')) return true;
      if (('\uAC00' <= c) && (c <= '\uD7A3')) return true;
      if (('\uF900' <= c) && (c <= '\uFA2D')) return true;
      if (('\uFA30' <= c) && (c <= '\uFA6A')) return true;
      if (('\uFE30' <= c) && (c <= '\uFE34')) return true;
      if (('\uFE45' <= c) && (c <= '\uFE46')) return true;
      if (('\uFE49' <= c) && (c <= '\uFE4F')) return true;
      if (c == '\uFE51') return true;
      if (c == '\uFE58') return true;
      if (('\uFE5F' <= c) && (c <= '\uFE66')) return true;
      if (c == '\uFE68') return true;
      if (c == '\uFE6B') return true;
      if (('\uFF02' <= c) && (c <= '\uFF03')) return true;
      if (('\uFF06' <= c) && (c <= '\uFF07')) return true;
      if (('\uFF0A' <= c) && (c <= '\uFF0B')) return true;
      if (c == '\uFF0D') return true;
      if (('\uFF0F' <= c) && (c <= '\uFF19')) return true;
      if (('\uFF1C' <= c) && (c <= '\uFF1E')) return true;
      if (('\uFF20' <= c) && (c <= '\uFF3A')) return true;
      if (c == '\uFF3C') return true;
      if (('\uFF3E' <= c) && (c <= '\uFF5A')) return true;
      if (c == '\uFF5C') return true;
      if (c == '\uFF5E') return true;
      if (('\uFFE2' <= c) && (c <= '\uFFE4')) return true;

      return false;
    }

    public bool UnicodeInfo_ALetter(char c)
    {
      if (c == '\u05F3') return true;
      if (UnicodeInfo_Ideographic(c)) return false;
      if (UnicodeInfo_Katakana(c)) return false;
      if (UnicodeInfo_Alphabetic(c)) return true;

      return false;
    }

    public bool UnicodeInfo_ABaseLetter(char c)
    {
      if (UnicodeInfo_Grapheme_Extend(c)) return false;
      if (UnicodeInfo_ALetter(c)) return true;

      return false;
    }

    public bool UnicodeInfo_ACMLetter(char c)
    {
      if (UnicodeInfo_Grapheme_Extend(c))
      {
        if (UnicodeInfo_ALetter(c)) return true;
      }

      return false;
    }

    public bool UnicodeInfo_MidLetter(char c)
    {
      if (c == '\u0027') return true;
      if (c == '\u00B7') return true;
      if (c == '\u05F4') return true;
      if (c == '\u2019') return true;
      if (c == '\u2027') return true;

      return false;
    }

    public bool UnicodeInfo_MidNumLet(char c)
    {
      if (c == '\u002E') return true;
      if (c == '\u003A') return true;

      return false;
    }

    public bool UnicodeInfo_MidNum(char c)
    {
      if (c == '\u002C') return true;
      if (c == '\u002E') return true;
      if (c == '\u003a') return true;
      if (c == '\u003b') return true;
      if (c == '\u0589') return true;

      return false;
    }

    public bool UnicodeInfo_Numeric(char c)
    {
      if (('\u0030' <= c) && (c <= '\u0039')) return true;
      if (('\u0660' <= c) && (c <= '\u0669')) return true;
      if (('\u066B' <= c) && (c <= '\u066C')) return true;
      if (('\u06F0' <= c) && (c <= '\u06F9')) return true;
      if (('\u07C0' <= c) && (c <= '\u07C9')) return true;
      if (('\u0966' <= c) && (c <= '\u096F')) return true;
      if (('\u09E6' <= c) && (c <= '\u09EF')) return true;
      if (('\u0A66' <= c) && (c <= '\u0A6F')) return true;
      if (('\u0AE6' <= c) && (c <= '\u0AEF')) return true;
      if (('\u0B66' <= c) && (c <= '\u0B6F')) return true;
      if (('\u0BE6' <= c) && (c <= '\u0BEF')) return true;
      if (('\u0C66' <= c) && (c <= '\u0C6F')) return true;
      if (('\u0CE6' <= c) && (c <= '\u0CEF')) return true;
      if (('\u0D66' <= c) && (c <= '\u0D6F')) return true;
      if (('\u0E50' <= c) && (c <= '\u0E59')) return true;
      if (('\u0ED0' <= c) && (c <= '\u0ED9')) return true;
      if (('\u0F20' <= c) && (c <= '\u0F29')) return true;
      if (('\u1040' <= c) && (c <= '\u1049')) return true;
      if (('\u17E0' <= c) && (c <= '\u17E9')) return true;
      if (('\u1810' <= c) && (c <= '\u1819')) return true;
      if (('\u1946' <= c) && (c <= '\u194F')) return true;
      if (('\u19D0' <= c) && (c <= '\u19D9')) return true;
      if (('\u1B50' <= c) && (c <= '\u1B59')) return true;
      if ((char.ConvertFromUtf32(0x104A0)[0] <= c) && (c <= char.ConvertFromUtf32(0x104A9)[0])) return true;
      if ((char.ConvertFromUtf32(0x1D7CE)[0] <= c) && (c <= char.ConvertFromUtf32(0x1D7FF)[0])) return true;

      return false;
    }

    public bool UnicodeInfo_Korean_L(char c)
    {
      if (('\u1100' <= c) && (c <= '\u115f')) return true;
      if (('\uac00' <= c) && (c <= '\ud7a3')) return true;

      return false;
    }

    public bool UnicodeInfo_Korean_V(char c)
    {
      if (('\u1160' <= c) && (c <= '\u11a2')) return true;

      return false;
    }

    public bool UnicodeInfo_Korean_T(char c)
    {
      if (('\u11a8' <= c) && (c <= '\u11f9')) return true;

      return false;
    }

    private void InitFromArray(char[] character_array, ref Dictionary<char, bool> character_dictionary)
    {
      if (character_dictionary == null)
      {
        character_dictionary = new Dictionary<char, bool>();
        for (int index = 0; index < character_array.Length; index += 1)
        {
          character_dictionary[character_array[index]] = true;
        }
      }
    }

    private Dictionary<char, bool> UnicodeInfo_Korean_LV_Data = null;
    private char[] UnicodeInfo_Korean_LV_Array = new char[]{
        '\uac00', '\uac1c', '\uac38', '\uac54', '\uac70','\uac8c', '\uaca8', '\uacc4', '\uace0', '\uacfc', '\uad18', '\uad34', '\uad50', '\uad6c', '\uad88', '\uada4',
        '\uadc0', '\uaddc', '\uadf8', '\uae14', '\uae30', '\uae4c', '\uae68', '\uae84', '\uaea0', '\uaebc', '\uaed8', '\uaef4', '\uaf10', '\uaf2c', '\uaf48', '\uaf64',
        '\uaf80', '\uaf9c', '\uafb8', '\uafd4', '\uaff0', '\ub00c', '\ub028', '\ub044', '\ub060', '\ub07c', '\ub098', '\ub0b4', '\ub0d0', '\ub0ec', '\ub108', '\ub124',
        '\ub140', '\ub15c', '\ub178', '\ub194', '\ub1b0', '\ub1cc', '\ub1e8', '\ub204', '\ub220', '\ub23c', '\ub258', '\ub274', '\ub290', '\ub2ac', '\ub2c8', '\ub2e4',
        '\ub300', '\ub31c', '\ub338', '\ub354', '\ub370', '\ub38c', '\ub3a8', '\ub3c4', '\ub3e0', '\ub3fc', '\ub418', '\ub434', '\ub450', '\ub46c', '\ub488', '\ub4a4',
        '\ub4c0', '\ub4dc', '\ub4f8', '\ub514', '\ub530', '\ub54c', '\ub568', '\ub584', '\ub5a0', '\ub5bc', '\ub5d8', '\ub5f4', '\ub610', '\ub62c', '\ub648', '\ub664',
        '\ub680', '\ub69c', '\ub6b8', '\ub6d4', '\ub6f0', '\ub70c', '\ub728', '\ub744', '\ub760', '\ub77c', '\ub798', '\ub7b4', '\ub7d0', '\ub7ec', '\ub808', '\ub824',
        '\ub840', '\ub85c', '\ub878', '\ub894', '\ub8b0', '\ub8cc', '\ub8e8', '\ub904', '\ub920', '\ub93c', '\ub958', '\ub974', '\ub990', '\ub9ac', '\ub9c8', '\ub9e4',
        '\uba00', '\uba1c', '\uba38', '\uba54', '\uba70', '\uba8c', '\ubaa8', '\ubac4', '\ubae0', '\ubafc', '\ubb18', '\ubb34', '\ubb50', '\ubb6c', '\ubb88', '\ubba4',
        '\ubbc0', '\ubbdc', '\ubbf8', '\ubc14', '\ubc30', '\ubc4c', '\ubc68', '\ubc84', '\ubca0', '\ubcbc', '\ubcd8', '\ubcf4', '\ubd10', '\ubd2c', '\ubd48', '\ubd64',
        '\ubd80', '\ubd9c', '\ubdb8', '\ubdd4', '\ubdf0', '\ube0c', '\ube28', '\ube44', '\ube60', '\ube7c', '\ube98', '\ubeb4', '\ubed0', '\ubeec', '\ubf08', '\ubf24',
        '\ubf40', '\ubf5c', '\ubf78', '\ubf94', '\ubfb0', '\ubfcc', '\ubfe8', '\uc004', '\uc020', '\uc03c', '\uc058', '\uc074', '\uc090', '\uc0ac', '\uc0c8', '\uc0e4',
        '\uc100', '\uc11c', '\uc138', '\uc154', '\uc170', '\uc18c', '\uc1a8', '\uc1c4', '\uc1e0', '\uc1fc', '\uc218', '\uc234', '\uc250', '\uc26c', '\uc288', '\uc2a4',
        '\uc2c0', '\uc2dc', '\uc2f8', '\uc314', '\uc330', '\uc34c', '\uc368', '\uc384', '\uc3a0', '\uc3bc', '\uc3d8', '\uc3f4', '\uc410', '\uc42c', '\uc448', '\uc464',
        '\uc480', '\uc49c', '\uc4b8', '\uc4d4', '\uc4f0', '\uc50c', '\uc528', '\uc544', '\uc560', '\uc57c', '\uc598', '\uc5b4', '\uc5d0', '\uc5ec', '\uc608', '\uc624',
        '\uc640', '\uc65c', '\uc678', '\uc694', '\uc6b0', '\uc6cc', '\uc6e8', '\uc704', '\uc720', '\uc73c', '\uc758', '\uc774', '\uc790', '\uc7ac', '\uc7c8', '\uc7e4',
        '\uc800', '\uc81c', '\uc838', '\uc854', '\uc870', '\uc88c', '\uc8a8', '\uc8c4', '\uc8e0', '\uc8fc', '\uc918', '\uc934', '\uc950', '\uc96c', '\uc988', '\uc9a4',
        '\uc9c0', '\uc9dc', '\uc9f8', '\uca14', '\uca30', '\uca4c', '\uca68', '\uca84', '\ucaa0', '\ucabc', '\ucad8', '\ucaf4', '\ucb10', '\ucb2c', '\ucb48', '\ucb64',
        '\ucb80', '\ucb9c', '\ucbb8', '\ucbd4', '\ucbf0', '\ucc0c', '\ucc28', '\ucc44', '\ucc60', '\ucc7c', '\ucc98', '\uccb4', '\uccd0', '\uccec', '\ucd08', '\ucd24',
        '\ucd40', '\ucd5c', '\ucd78', '\ucd94', '\ucdb0', '\ucdcc', '\ucde8', '\uce04', '\uce20', '\uce3c', '\uce58', '\uce74', '\uce90', '\uceac', '\ucec8', '\ucee4',
        '\ucf00', '\ucf1c', '\ucf38', '\ucf54', '\ucf70', '\ucf8c', '\ucfa8', '\ucfc4', '\ucfe0', '\ucffc', '\ud018', '\ud034', '\ud050', '\ud06c', '\ud088', '\ud0a4',
        '\ud0c0', '\ud0dc', '\ud0f8', '\ud114', '\ud130', '\ud14c', '\ud168', '\ud184', '\ud1a0', '\ud1bc', '\ud1d8', '\ud1f4', '\ud210', '\ud22c', '\ud248', '\ud264',
        '\ud280', '\ud29c', '\ud2b8', '\ud2d4', '\ud2f0', '\ud30c', '\ud328', '\ud344', '\ud360', '\ud37c', '\ud398', '\ud3b4', '\ud3d0', '\ud3ec', '\ud408', '\ud424',
        '\ud440', '\ud45c', '\ud478', '\ud494', '\ud4b0', '\ud4cc', '\ud4e8', '\ud504', '\ud520', '\ud53c', '\ud558', '\ud574', '\ud590', '\ud5ac', '\ud5c8', '\ud5e4',
        '\ud600', '\ud61c', '\ud638', '\ud654', '\ud670', '\ud68c', '\ud6a8', '\ud6c4', '\ud6e0', '\ud6fc', '\ud718', '\ud734', '\ud750', '\ud76c', '\ud788'
    };

    public bool UnicodeInfo_Korean_LV(char c)
    {
      InitFromArray(UnicodeInfo_Korean_LV_Array, ref UnicodeInfo_Korean_LV_Data);
      if (UnicodeInfo_Korean_LV_Data.ContainsKey(c) == true) return true;

      return false;
    }

    public bool UnicodeInfo_Korean_LVT(char c)
    {
      if ( ! UnicodeInfo_Korean_LV(c))
      {
        if (('\uac00' <= c) && (c <= '\ud7a3')) return true;
      }
      return false;
    }

    // These characters are not letters but are considered to be part of a word
    //
    private Dictionary<char, bool> UnicodeInfo_WWNoBreak_Data = null;
    private char[] UnicodeInfo_WWNoBreak_Array = new char[]{
        '\u2027',
        '\u00AD',
        '\u2011',
        '\u2010',
        '\u2043',
        '\u002D',
        '\u005f',
        '\u0332',
        '\u0040',
        '\u0026',
        '\u0024'
    };

    public bool UnicodeInfo_WWNoBreak(char c)
    {
      InitFromArray(UnicodeInfo_WWNoBreak_Array, ref UnicodeInfo_WWNoBreak_Data);
      if (UnicodeInfo_WWNoBreak_Data.ContainsKey(c))
      {
        return true;
      }

      return false;
    }
   ]]>
 </msxsl:script>
</xsl:stylesheet>
