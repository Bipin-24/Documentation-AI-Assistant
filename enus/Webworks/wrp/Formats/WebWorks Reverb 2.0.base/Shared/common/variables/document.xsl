<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Variables-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwvars wwfilesext wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwvars" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-split-by-documentid" match="wwsplits:Split" use="@documentID" />
 <xsl:key name="wwvars-variables-by-name" match="wwvars:Variable" use="@name" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:for-each select="$GlobalFiles[1]">
      <!-- Load group splits -->
      <!--                   -->
      <xsl:variable name="VarSplitsFile" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarProjectGroup/@GroupID][1]" />
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path, false())" />

      <!-- Iterate input documents -->
      <!--                         -->
      <xsl:for-each select="$GlobalInput[1]">
       <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

       <xsl:variable name="VarProgressWIFFilesStart" select="wwprogress:Start(count($VarWIFFiles))" />

       <xsl:for-each select="$VarWIFFiles">
        <xsl:variable name="VarWIFFile" select="." />

        <xsl:variable name="VarProgressWIFFileStart" select="wwprogress:Start(1)" />

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <!-- Up to date? -->
         <!--             -->
         <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarWIFFile/@path), concat(translate($ParameterType, ':', '_'), '.xml'))" />
         <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarWIFFile/@groupID, $VarWIFFile/@documentID, $GlobalActionChecksum)" />
         <xsl:if test="not($VarUpToDate)">
          <xsl:variable name="VarResultAsXML">
           <!-- Document Variables -->
           <!--                    -->
           <xsl:call-template name="Variables-Document">
            <xsl:with-param name="ParamSplits" select="$VarSplits" />
            <xsl:with-param name="ParamWIFFile" select="$VarWIFFile" />
           </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
          <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
         </xsl:if>

         <!-- Report generated file -->
         <!--                       -->
         <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
          <wwfiles:Depends path="{$VarSplitsFile/@path}" checksum="{$VarSplitsFile/@checksum}" groupID="{$VarSplitsFile/@groupID}" documentID="{$VarSplitsFile/@documentID}" />
          <wwfiles:Depends path="{$VarWIFFile/@path}" checksum="{$VarWIFFile/@checksum}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" />
         </wwfiles:File>
        </xsl:if>

        <xsl:variable name="VarProgressWIFFileEnd" select="wwprogress:End()" />
       </xsl:for-each>

       <xsl:variable name="VarProgressWIFFilesEnd" select="wwprogress:End()" />
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Variables-Document">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamWIFFile" />

  <!-- Load WIF -->
  <!--          -->
  <xsl:variable name="VarWIF" select="wwexsldoc:LoadXMLWithoutResolver($ParamWIFFile/@path, false())" />

  <wwvars:Variables>
   <!-- Document variable context -->
   <!--                           -->
   <wwvars:Document groupID="{$ParamWIFFile/@groupID}" documentID="{$ParamWIFFile/@documentID}">

    <!-- Break document into chunks -->
    <!--                            -->
    <xsl:for-each select="$ParamSplits[1]">
     <xsl:variable name="VarDocumentSplits" select="key('wwsplits-split-by-documentid', $ParamWIFFile/@documentID)" />

     <!-- Process variables in each split -->
     <!--                                 -->
     <xsl:variable name="VarProgressSplitsStart" select="wwprogress:Start(count($VarDocumentSplits))" />
     <xsl:for-each select="$VarDocumentSplits">
      <xsl:variable name="VarSplit" select="." />

      <xsl:variable name="VarProgressSplitStart" select="wwprogress:Start(1)" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Split variable context -->
       <!--                        -->
       <wwvars:Split>
        <xsl:copy-of select="$VarSplit/@*" />

        <!-- Content -->
        <!--         -->
        <xsl:variable name="VarSplitStartElement" select="$VarWIF/wwdoc:Document/wwdoc:Content/*[@id = $VarSplit/@id]" />
        <xsl:variable name="VarSplitPositionCount" select="$VarSplit/@documentendposition - $VarSplit/@documentstartposition" />
        <xsl:variable name="VarContent" select="$VarSplitStartElement | $VarSplitStartElement/following-sibling::*[position() &lt;= $VarSplitPositionCount]" />

        <!-- Process variables -->
        <!--                   -->
        <xsl:variable name="VarSplitVariablesAsXML">
         <xsl:apply-templates select="$VarContent" mode="wwmode:variable">
          <xsl:with-param name="ParamSplit" select="$VarSplit" />
         </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="VarSplitVariables" select="msxsl:node-set($VarSplitVariablesAsXML)/wwvars:Variable" />

        <!-- Determine unique variable names -->
        <!--                                 -->
        <xsl:variable name="VarUniqueVariablesAsXML">
         <xsl:for-each select="$VarSplitVariables">
          <xsl:variable name="VarVariable" select="." />

          <xsl:variable name="VarFirstVariableWithName" select="key('wwvars-variables-by-name', $VarVariable/@name)[1]" />
          <xsl:if test="count($VarFirstVariableWithName | $VarVariable) = 1">
           <xsl:copy-of select="$VarVariable" />
          </xsl:if>
         </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="VarUniqueVariables" select="msxsl:node-set($VarUniqueVariablesAsXML)/wwvars:Variable" />

        <!-- Return last unique variable instance -->
        <!--                                      -->
        <xsl:for-each select="$VarUniqueVariables">
         <xsl:variable name="VarUniqueVariable" select="." />

         <xsl:for-each select="$VarSplitVariables[1]">
          <xsl:variable name="VarVariablesWithName" select="key('wwvars-variables-by-name', $VarUniqueVariable/@name)" />

          <xsl:for-each select="$VarVariablesWithName[last()]">
           <xsl:variable name="VarVariable" select="." />

           <xsl:copy-of select="$VarVariable" />
          </xsl:for-each>
         </xsl:for-each>
        </xsl:for-each>
       </wwvars:Split>
      </xsl:if>

      <xsl:variable name="VarProgressSplitEnd" select="wwprogress:End()" />
     </xsl:for-each>
     <xsl:variable name="VarProgressSplitsEnd" select="wwprogress:End()" />
    </xsl:for-each>

   </wwvars:Document>
  </wwvars:Variables>
 </xsl:template>


 <xsl:template match="wwdoc:*" mode="wwmode:variable">
  <xsl:param name="ParamSplit" />

  <xsl:apply-templates mode="wwmode:variable">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:variable">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" select="." />

  <!-- Access context rule -->
  <!--                     -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />

  <xsl:call-template name="Variables-Node">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
   <xsl:with-param name="ParamNode" select="$ParamParagraph" />
  </xsl:call-template>

  <xsl:apply-templates mode="wwmode:variable">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:TextRun" mode="wwmode:variable">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTextRun" select="." />

  <!-- Access context rule -->
  <!--                     -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Character', $ParamTextRun/@stylename, $ParamSplit/@documentID, $ParamTextRun/@id)" />

  <xsl:call-template name="Variables-Node">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
   <xsl:with-param name="ParamNode" select="$ParamTextRun" />
  </xsl:call-template>

  <xsl:apply-templates mode="wwmode:variable">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Marker" mode="wwmode:variable">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamMarker" select="." />

  <!-- Access context rule -->
  <!--                     -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Marker', $ParamMarker/@name, $ParamSplit/@documentID, $ParamMarker/@id)" />

  <xsl:call-template name="Variables-Node">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
   <xsl:with-param name="ParamNode" select="$ParamMarker" />
  </xsl:call-template>

  <xsl:apply-templates mode="wwmode:variable">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template name="Variables-Node">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamNode" />

  <!-- Treat as a variable? -->
  <!--                      -->
  <xsl:variable name="VarVariableOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'variable']/@Value" />
  <xsl:choose>
   <!-- No variable name defined -->
   <!--                          -->
   <xsl:when test="string-length($VarVariableOption) = 0">
    <!-- Nothing to do -->
    <!--               -->
   </xsl:when>

   <!-- Record variable -->
   <!--                 -->
   <xsl:otherwise>
    <wwvars:Variable name="{$VarVariableOption}">
     <xsl:copy-of select="$ParamNode" />
    </wwvars:Variable>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
