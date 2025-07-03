<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwadapter="urn:WebWorks-XSLT-Extension-Adapter"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode html wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwunits wwprojext wwadapter wwimaging wwexsldoc"
>
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwfiles-files-by-path" match="wwfiles:File" use="@path" />
 <xsl:key name="wwsplits-splits-by-documentid" match="wwsplits:Split" use="@documentID" />
 <xsl:key name="wwtoc-entry-by-documentid" match="wwtoc:Entry" use="@documentID" />


 <xsl:template name="Wrappers">
  <xsl:param name="ParamInput" />
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamFiles" />
  <xsl:param name="ParamLinksType" />
  <xsl:param name="ParamDependsType" />
  <xsl:param name="ParamSplitsType" />
  <xsl:param name="ParamBehaviorsType" />
  <xsl:param name="ParamTOCDataType" />
  <xsl:param name="ParamThumbnailType" />

  <!-- Load project links -->
  <!--                    -->
  <xsl:for-each select="$ParamFiles[1]">
   <xsl:variable name="VarLinksPath" select="key('wwfiles-files-by-type', $ParamLinksType)/@path" />
   <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksPath, false())" />

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$ParamProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarIgnore1Start" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <!-- Splits -->
    <!--        -->
    <xsl:variable name="VarIgnore2Start" select="wwprogress:Start(1)" />
    <xsl:for-each select="$ParamInput[1]">
     <xsl:variable name="VarSplitsFiles" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParamSplitsType))" />
     <xsl:for-each select="$VarSplitsFiles[1]">
      <xsl:variable name="VarSplitsFile" select="." />

      <!-- Load splits -->
      <!--             -->
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path, false())" />
      <xsl:if test="count($VarSplits//wwsplits:Frame) &gt; 0">
       <!-- Group TOC -->
       <!--           -->
       <xsl:variable name="VarFilesTOCData" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParamTOCDataType))" />
       <xsl:variable name="VarTOCData" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesTOCData/@path, false())" />

       <!-- Documents -->
       <!--           -->
       <xsl:variable name="VarProjectDocuments" select="$VarProjectGroup//wwproject:Document" />
       <xsl:variable name="VarIgnore3Start" select="wwprogress:Start(count($VarProjectDocuments))" />
       <xsl:for-each select="$VarProjectDocuments">
        <xsl:variable name="VarProjectDocument" select="." />

        <xsl:variable name="VarIgnore4Start" select="wwprogress:Start(1)" />

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <!-- Process document WIF? -->
         <!--                       -->
         <xsl:for-each select="$ParamInput[1]">
          <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParamDependsType]" />
          <xsl:for-each select="$VarWIFFiles">
           <xsl:variable name="VarWIFFile" select="." />

           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <!-- Wrapper files for thumbnails required? -->
            <!--                                        -->
            <xsl:for-each select="$ParamFiles[1]">
             <xsl:variable name="VarDocumentThumbnailFiles" select="key('wwfiles-files-by-documentid', $VarWIFFile/@documentID)[@type = $ParamThumbnailType]" />
             <xsl:for-each select="$VarDocumentThumbnailFiles[1]">
              <!-- Thumbnail files exist, need to generate wrappers -->
              <!--                                                  -->

              <!-- Load document WIF -->
              <!--                   -->
              <xsl:variable name="VarWIF" select="wwexsldoc:LoadXMLWithoutResolver($VarWIFFile/@path, false())" />

              <!-- Load behaviors -->
              <!--                -->
              <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-documentid', $VarWIFFile/@documentID)[@type = $ParamBehaviorsType][1]" />
              <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

              <!-- Locate full size frames that need wrapper files -->
              <!--                                                 -->
              <xsl:for-each select="$VarSplits[1]">
               <xsl:variable name="VarDocumentSplits" select="key('wwsplits-splits-by-documentid', $VarWIFFile/@documentID)" />
               <xsl:for-each select="$VarDocumentSplits">
                <xsl:variable name="VarSplit" select="." />

                <!-- Aborted? -->
                <!--          -->
                <xsl:if test="not(wwprogress:Abort())">
                 <!-- Locate TOC entry for breadcrumb starting point -->
                 <!--                                                -->
                 <xsl:for-each select="$VarTOCData[1]">
                  <xsl:variable name="VarDocumentTOCEntries" select="key('wwtoc-entry-by-documentid', $VarSplit/@documentID)" />
                  <xsl:variable name="VarPossibleBreadcrumbTOCEntries" select="$VarDocumentTOCEntries[@documentposition &lt;= $VarSplit/@documentstartposition]" />
                  <xsl:variable name="VarBreadcrumbTOCEntry" select="$VarPossibleBreadcrumbTOCEntries[count($VarPossibleBreadcrumbTOCEntries)]" />

                  <xsl:for-each select="$VarSplit/wwsplits:Frame">
                   <xsl:variable name="VarSplitsFrame" select="." />

                   <!-- Aborted? -->
                   <!--          -->
                   <xsl:if test="not(wwprogress:Abort())">
                    <!-- Thumbnail file exists for this frame? -->
                    <!--                                       -->
                    <xsl:for-each select="$ParamFiles[1]">
                     <xsl:variable name="VarThumbnailExists" select="count(key('wwfiles-files-by-path', $VarSplitsFrame/wwsplits:Thumbnail/@path)[1]) &gt; 0" />

                     <xsl:if test="$VarThumbnailExists">
                      <xsl:call-template name="Wrapper">
                       <xsl:with-param name="ParamFilesSplits" select="$VarSplitsFile" />
                       <xsl:with-param name="ParamSplits" select="$VarSplits" />
                       <xsl:with-param name="ParamBehaviorsFile" select="$VarBehaviorsFile" />
                       <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
                       <xsl:with-param name="ParamLinks" select="$VarLinks" />
                       <xsl:with-param name="ParamTOCData" select="$VarTOCData" />
                       <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$VarBreadcrumbTOCEntry" />
                       <xsl:with-param name="ParamFilesDocumentNode" select="$VarWIFFile" />
                       <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
                       <xsl:with-param name="ParamDocument" select="$VarWIF" />
                      </xsl:call-template>
                     </xsl:if>
                    </xsl:for-each>
                   </xsl:if>
                  </xsl:for-each>
                 </xsl:for-each>
                </xsl:if>
               </xsl:for-each>
              </xsl:for-each>
             </xsl:for-each>
            </xsl:for-each>
           </xsl:if>
          </xsl:for-each>
         </xsl:for-each>
        </xsl:if>

        <xsl:variable name="VarIgnore4End" select="wwprogress:End()" />

       </xsl:for-each>
       <xsl:variable name="VarIgnore3End" select="wwprogress:End()" />

      </xsl:if>

     </xsl:for-each>

    </xsl:for-each>
    <xsl:variable name="VarIgnore2End" select="wwprogress:End()" />

   </xsl:for-each>
   <xsl:variable name="VarIgnore1End" select="wwprogress:End()" />
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
