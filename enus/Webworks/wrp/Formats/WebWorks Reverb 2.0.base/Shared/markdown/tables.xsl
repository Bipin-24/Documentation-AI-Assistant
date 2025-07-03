<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
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
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
>
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-split-by-documentid" match="wwsplits:Split" use="@documentID" />
 <xsl:key name="wwdoc-tables-by-id" match="wwdoc:Table" use="@id" />


 <xsl:template name="DocumentsTables">
  <xsl:param name="ParamInput" />
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamFiles" />
  <xsl:param name="ParamLinksType" />
  <xsl:param name="ParamDependsType" />
  <xsl:param name="ParamSplitsType" />
  <xsl:param name="ParamBehaviorsType" />

  <!-- Load project links -->
  <!--                    -->
  <xsl:for-each select="$ParamFiles[1]">
   <xsl:variable name="VarLinksPath" select="key('wwfiles-files-by-type', $ParamLinksType)/@path" />
   <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksPath, false())" />

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$ParamProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:for-each select="$ParamFiles[1]">
      <!-- Group Splits -->
      <!--              -->
      <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParamSplitsType))" />
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

      <!-- Iterate input documents -->
      <!--                         -->
      <xsl:for-each select="$ParamInput[1]">
       <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParamDependsType)" />

       <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarFilesByType))" />

       <xsl:for-each select="$VarFilesByType">
        <xsl:variable name="VarFile" select="." />

        <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <!-- Behaviors -->
         <!--           -->
         <xsl:for-each select="$ParamFiles[1]">
          <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-documentid', $VarFile/@documentID)[@type = $ParamBehaviorsType][1]" />
          <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

          <!-- Call template -->
          <!--               -->
          <xsl:call-template name="Tables">
           <xsl:with-param name="ParamLinks" select="$VarLinks" />
           <xsl:with-param name="ParamFilesDocumentNode" select="$VarFile" />
           <xsl:with-param name="ParamFilesSplits" select="$VarFilesSplits" />
           <xsl:with-param name="ParamSplits" select="$VarSplits" />
           <xsl:with-param name="ParamBehaviorsFile" select="$VarBehaviorsFile" />
           <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
          </xsl:call-template>
         </xsl:for-each>
        </xsl:if>

        <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
       </xsl:for-each>

       <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Tables">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />

  <!-- Load document -->
  <!--               -->
  <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocumentNode/@path, false())" />

  <!-- Break document into chunks -->
  <!--                            -->
  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarDocumentSplits" select="key('wwsplits-split-by-documentid', $ParamFilesDocumentNode/@documentID)" />

   <xsl:value-of select="wwprogress:Start(count($VarDocumentSplits))" />

   <xsl:for-each select="$VarDocumentSplits">
    <xsl:variable name="VarSplit" select="." />

    <xsl:value-of select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Process tables -->
     <!--                -->
     <xsl:variable name="VarSplitTables" select="$VarSplit/wwsplits:Table" />
     <xsl:variable name="VarProgressTablesStart" select="wwprogress:Start(count($VarSplitTables))" />
     <xsl:for-each select="$VarSplitTables">
      <xsl:variable name="VarSplitTable" select="." />

      <xsl:variable name="VarProgressTableStart" select="wwprogress:Start(1)" />

      <!-- Content -->
      <!--         -->
      <xsl:for-each select="$VarDocument[1]">
       <xsl:variable name="VarContent" select="key('wwdoc-tables-by-id', $VarSplitTable/@id)" />

       <!-- Table -->
       <!--       -->
       <xsl:call-template name="Content-Table">
        <xsl:with-param name="ParamFilesSplits" select="$ParamFilesSplits" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
        <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamFilesDocumentNode" select="$ParamFilesDocumentNode" />
        <xsl:with-param name="ParamSplit" select="$VarSplitTable" />
        <xsl:with-param name="ParamDocument" select="$VarDocument" />
        <xsl:with-param name="ParamContent" select="$VarContent" />
       </xsl:call-template>
      </xsl:for-each>

      <xsl:variable name="VarProgressTableEnd" select="wwprogress:End()" />
     </xsl:for-each>
     <xsl:variable name="VarProgressTablesEnd" select="wwprogress:End()" />
    </xsl:if>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:value-of select="wwprogress:End()" />
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
