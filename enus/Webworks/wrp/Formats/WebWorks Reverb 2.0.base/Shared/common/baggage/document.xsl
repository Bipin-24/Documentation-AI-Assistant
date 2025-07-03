<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Baggage-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwproject wwbaggage wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" /><!--"engine:wif"-->
 <xsl:param name="ParameterType" /><!--"baggage:document"-->
 <xsl:param name="ParameterInternalType" /><!--"internal"-->
 <xsl:param name="ParameterExternalType" /><!--"external"-->


 <xsl:namespace-alias stylesheet-prefix="wwbaggage" result-prefix="#default" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-documents-by-documentid" match="wwproject:Document" use="@DocumentID" />


 <!-- Baggage Settings -->
 <!--                  -->
 <xsl:variable name="GlobalIndexExternalBaggageFiles" select="wwprojext:GetFormatSetting('index-external-baggage-files')" />
 <xsl:variable name="GlobalPreserveUnknownFileLinks" select="wwprojext:GetFormatSetting('preserve-unknown-file-links')" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Project Documents via Absolute Path -->
 <!--                                     -->
 <xsl:variable name="GlobalProjectDocumentsAsXML">
  <wwproject:Documents>
   <xsl:for-each select="$GlobalProject/wwproject:Project/wwproject:Groups//wwproject:Document">
    <xsl:variable name="VarProjectDocument" select="." />

    <xsl:copy>
     <xsl:copy-of select="@*[local-name() != 'Path']" />
     <xsl:attribute name="Path">
      <xsl:value-of select="wwprojext:GetDocumentPath($VarProjectDocument/@DocumentID)" />
     </xsl:attribute>
    </xsl:copy>
   </xsl:for-each>
  </wwproject:Documents>
 </xsl:variable>
 <xsl:variable name="GlobalProjectDocuments" select="msxsl:node-set($GlobalProjectDocumentsAsXML)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressWIFFilesStart" select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarWIFFile" select="." />

     <xsl:variable name="VarProgressWIFFileStart" select="wwprogress:Start(1)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Up to date? -->
      <!--             -->
      <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarWIFFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarWIFFile/@groupID, $VarWIFFile/@documentID, $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <xsl:variable name="VarResultAsXML">
        <!-- Baggage Files -->
        <!--               -->
        <xsl:call-template name="BaggageFiles">
         <xsl:with-param name="ParamWIFFile" select="$VarWIFFile" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
      </xsl:if>

      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarWIFFile/@path}" checksum="{$VarWIFFile/@checksum}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" />
      </wwfiles:File>
     </xsl:if>

     <xsl:variable name="VarProgressWIFFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressWIFFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="BaggageFiles">
  <xsl:param name="ParamWIFFile" />

  <wwbaggage:Baggage version="1.0">
   <!-- WIF document -->
   <!--              -->
   <xsl:variable name="VarWIFDocument" select="wwexsldoc:LoadXMLWithoutResolver($ParamWIFFile/@path, false())" />

   <xsl:apply-templates select="$VarWIFDocument/wwdoc:Document/wwdoc:Content/*" mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </wwbaggage:Baggage>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:baggage">
  <xsl:param name="ParamParagraph" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamWIFFile/@documentID, $ParamParagraph/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:TextRun" mode="wwmode:baggage">
  <xsl:param name="ParamTextRun" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get rule -->
  <!--          -->
  <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $ParamTextRun/@stylename)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:baggage">
  <xsl:param name="ParamTable" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $ParamTable/@stylename, $ParamWIFFile/@documentID, $ParamTable/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:baggage">
  <xsl:param name="ParamList" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamList/@stylename, $ParamWIFFile/@documentID, $ParamList/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:baggage">
  <xsl:param name="ParamListItem" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamListItem/@stylename, $ParamWIFFile/@documentID, $ParamListItem/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:baggage">
  <xsl:param name="ParamBlock" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamBlock/@stylename, $ParamWIFFile/@documentID, $ParamBlock/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:baggage">
  <xsl:param name="ParamFrame" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamFrame/@stylename, $ParamWIFFile/@documentID, $ParamFrame/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Process nested links -->
   <!--                      -->
   <xsl:apply-templates mode="wwmode:baggage">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Link" mode="wwmode:baggage">
  <xsl:param name="ParamLink" select="." />
  <xsl:param name="ParamWIFFile" />

  <!-- File? -->
  <!--       -->
  <xsl:choose>
   <xsl:when test="wwuri:IsFile($ParamLink/@url)">
    <xsl:variable name="VarLinkPath" select="wwuri:AsFilePath($ParamLink/@url)" />
    <xsl:for-each select="$GlobalProjectDocuments[1]">
     <!-- In project? -->
     <!--             -->
     <xsl:variable name="VarDocumentID" select="wwprojext:GetDocumentID($VarLinkPath)" />
     <xsl:if test="string-length($VarDocumentID) = 0">
      <!-- Determine original document extension -->
      <!--                                       -->
      <xsl:variable name="VarDocumentExtension">
       <xsl:for-each select="$GlobalProject[1]">
        <xsl:for-each select="key('wwproject-documents-by-documentid', $ParamWIFFile/@documentID)[1]">
         <xsl:variable name="VarProjectDocument" select="." />

         <xsl:value-of select="wwstring:ToLower(wwfilesystem:GetExtension($VarProjectDocument/@Path))" />
        </xsl:for-each>
       </xsl:for-each>
      </xsl:variable>

      <!-- Determine link extension -->
      <!--                          -->
      <xsl:variable name="VarLinkExtension" select="wwstring:ToLower(wwfilesystem:GetExtension($VarLinkPath))" />

      <!-- Record file only if link extension does not match the original document extension -->
      <!-- Unless preserve-unknown-file-links is enabled then treat as baggage file          -->
      <!--                                                                                   -->
      <xsl:if test="$VarLinkExtension != $VarDocumentExtension or $GlobalPreserveUnknownFileLinks = 'true'">
       <!-- Unknown file -->
       <!--              -->
       <wwbaggage:File path="{$VarLinkPath}" pathtolower="{wwstring:ToLower($VarLinkPath)}" type="{$ParameterInternalType}"/>
      </xsl:if>
     </xsl:if>
    </xsl:for-each>
   </xsl:when>
   <xsl:when test="$GlobalIndexExternalBaggageFiles = 'true' and string-length($ParamLink/@url) &gt; 0 and (starts-with($ParamLink/@url, 'http://') or starts-with($ParamLink/@url, 'https://'))">
    <wwbaggage:File path="{$ParamLink/@url}" pathtolower="{wwstring:ToLower($ParamLink/@url)}" type="{$ParameterExternalType}"/>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwdoc:*" mode="wwmode:baggage">
  <xsl:param name="ParamNode" select="." />
  <xsl:param name="ParamWIFFile" />

  <xsl:apply-templates mode="wwmode:baggage">
   <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
  </xsl:apply-templates>
 </xsl:template>

</xsl:stylesheet>
