<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Index-Schema"
                              xmlns:wwindex="urn:WebWorks-Index-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwmode msxsl wwlinks wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterLocaleType" />


 <xsl:namespace-alias stylesheet-prefix="wwindex" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwlocale-members-by-match" match="wwlocale:Member" use="@match" />
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-paragraphs-by-id" match="wwlinks:Paragraph" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Access documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <!-- Load locale -->
    <!--             -->
    <xsl:variable name="VarFilesLocale" select="key('wwfiles-files-by-type', $ParameterLocaleType)" />
    <xsl:variable name="VarLocale" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesLocale/@path)" />

    <!-- Determine default index section -->
    <!--                                 -->
    <xsl:variable name="VarDefaultSection" select="$VarLocale/wwlocale:Locale/wwlocale:Index/wwlocale:Sections/wwlocale:Section[count(wwlocale:Members) = 0]" />

    <xsl:for-each select="key('wwfiles-files-by-type', $ParameterLinksType)[1]">
     <xsl:variable name="VarFilesProjectLinks" select="." />

     <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesProjectLinks/@path, false())" />

     <!-- Iterate input documents -->
     <!--                         -->
     <xsl:for-each select="$GlobalInput[1]">
      <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

      <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

      <xsl:for-each select="$VarFilesByType">
       <xsl:variable name="VarFilesDocument" select="." />

       <xsl:value-of select="wwprogress:Start(1)" />

       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsXML">
         <!-- Document index -->
         <!--                -->
         <xsl:call-template name="DocumentIndex">
          <xsl:with-param name="ParamDefaultSection" select="$VarDefaultSection" />
          <xsl:with-param name="ParamLinks" select="$VarLinks" />
          <xsl:with-param name="ParamFilesDocument" select="$VarFilesDocument" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
       </xsl:if>

       <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
        <wwfiles:Depends path="{$VarFilesLocale/@path}" checksum="{$VarFilesLocale/@checksum}" groupID="{$VarFilesLocale/@groupID}" documentID="{$VarFilesLocale/@documentID}" />
        <wwfiles:Depends path="{$VarFilesProjectLinks/@path}" checksum="{$VarFilesProjectLinks/@checksum}" groupID="{$VarFilesProjectLinks/@groupID}" documentID="{$VarFilesProjectLinks/@documentID}" />
        <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
       </wwfiles:File>

       <xsl:value-of select="wwprogress:End()" />
      </xsl:for-each>

      <xsl:value-of select="wwprogress:End()" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="DocumentIndex">
  <xsl:param name="ParamDefaultSection" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocument" />

  <wwindex:Index version="1.0">

   <!-- WIF document -->
   <!--              -->
   <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocument/@path, false())" />
   <xsl:variable name="VarContent" select="$VarDocument/wwdoc:Document/wwdoc:Content"/>

   <!-- TODO -->
   <xsl:for-each select="$VarContent/wwdoc:Paragraph | $VarContent/wwdoc:Table//wwdoc:Paragraph | $VarContent/wwdoc:List//wwdoc:Paragraph | $VarContent/wwdoc:Block//wwdoc:Paragraph">
    <xsl:call-template name="Paragraph">
     <xsl:with-param name="ParamDefaultSection" select="$ParamDefaultSection" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamFilesDocument" select="$ParamFilesDocument" />
     <xsl:with-param name="ParamParagraph" select="." />
    </xsl:call-template>
   </xsl:for-each>

  </wwindex:Index>
 </xsl:template>


 <xsl:template name="Paragraph">
  <xsl:param name="ParamDefaultSection" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocument" />
  <xsl:param name="ParamParagraph" />

  <xsl:for-each select="$ParamParagraph//wwdoc:TextRun/wwdoc:IndexMarker | $ParamParagraph//wwdoc:TextRun/wwdoc:Frame//wwdoc:IndexMarker">
   <xsl:call-template name="IndexMarker">
    <xsl:with-param name="ParamDefaultSection" select="$ParamDefaultSection" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamFilesDocument" select="$ParamFilesDocument" />
    <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
    <xsl:with-param name="ParamIndexMarker" select="." />
   </xsl:call-template>
  </xsl:for-each>

  <!-- Check for nested tables -->
  <!--                         -->
  <xsl:for-each select="$ParamParagraph//wwdoc:Table//wwdoc:Paragraph">
   <xsl:call-template name="Paragraph">
    <xsl:with-param name="ParamDefaultSection" select="$ParamDefaultSection" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamFilesDocument" select="$ParamFilesDocument" />
    <xsl:with-param name="ParamParagraph" select="." />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="IndexMarker">
  <xsl:param name="ParamDefaultSection" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocument" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamIndexMarker" />

  <xsl:for-each select="$ParamIndexMarker/wwdoc:Entry">
   <xsl:call-template name="Entry">
    <xsl:with-param name="ParamDefaultSection" select="$ParamDefaultSection" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamFilesDocument" select="$ParamFilesDocument" />
    <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
    <xsl:with-param name="ParamIndexMarker" select="$ParamIndexMarker" />
    <xsl:with-param name="ParamEntry" select="." />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Entry">
  <xsl:param name="ParamDefaultSection" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocument" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamIndexMarker" />
  <xsl:param name="ParamEntry" />

  <!-- Name -->
  <!--      -->
  <xsl:variable name="VarName">
   <xsl:for-each select="$ParamEntry/wwdoc:Content/wwdoc:TextRun/wwdoc:Text">
    <xsl:value-of select="@value" />
   </xsl:for-each>
  </xsl:variable>

  <!-- Sort -->
  <!--      -->
  <xsl:variable name="VarSortText">
   <xsl:for-each select="$ParamEntry/wwdoc:Sort/wwdoc:TextRun/wwdoc:Text">
    <xsl:value-of select="@value" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarSort">
   <xsl:choose>
    <xsl:when test="string-length($VarSortText) &gt; 0">
     <xsl:value-of select="$VarSortText" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarName" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Section Position -->
  <!--                  -->
  <xsl:variable name="VarSectionPosition">
   <xsl:choose>
    <xsl:when test="count($ParamDefaultSection[1]) = 1">
     <xsl:variable name="VarMemberKey" select="substring($VarSort, 1, 1)" />
     <xsl:variable name="VarMemberKeyUppercase" select="wwstring:ToUpper($VarMemberKey)" />
     <xsl:variable name="VarMemberKeyLowercase" select="wwstring:ToLower($VarMemberKey)" />

     <xsl:for-each select="$ParamDefaultSection[1]">
      <xsl:variable name="VarSectionPositionUppercase" select="key('wwlocale-members-by-match', $VarMemberKeyUppercase)/../../@position" />
      <xsl:variable name="VarSectionPositionLowercase" select="key('wwlocale-members-by-match', $VarMemberKeyLowercase)/../../@position" />

      <xsl:choose>
       <xsl:when test="$VarSectionPositionUppercase &gt; 0">
        <xsl:value-of select="$VarSectionPositionUppercase" />
       </xsl:when>

       <xsl:when test="$VarSectionPositionLowercase &gt; 0">
        <xsl:value-of select="$VarSectionPositionLowercase" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$ParamDefaultSection/@position" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:for-each>
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="0" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>


  <!-- Valid entry? -->
  <!--              -->
  <xsl:choose>
   <!-- Valid entry -->
   <!--             -->
   <xsl:when test="string-length($VarName) &gt; 0">
    <!-- Entry -->
    <!--       -->
    <wwindex:Entry name="{$VarName}" sort="{$VarSort}">
     <xsl:if test="string-length($ParamEntry/@see) &gt; 0">
      <xsl:attribute name="see">
       <xsl:value-of select="$ParamEntry/@see" />
      </xsl:attribute>
     </xsl:if>
     <xsl:if test="$VarSectionPosition &gt; 0">
      <xsl:attribute name="sectionposition">
       <xsl:value-of select="$VarSectionPosition" />
      </xsl:attribute>
     </xsl:if>

     <!-- Copy direct child non-Entry elements -->
     <!--                                      -->
     <xsl:for-each select="$ParamEntry/*[(local-name() != 'Entry') and (local-name() != 'Link')]">
      <xsl:copy-of select="." />
     </xsl:for-each>

     <!-- Link or child entries? -->
     <!--                        -->
     <xsl:choose>
      <xsl:when test="count($ParamEntry/wwdoc:Entry[1]) = 1">
       <!-- Process child entries -->
       <!--                       -->
       <xsl:for-each select="$ParamEntry/wwdoc:Entry">
        <xsl:call-template name="Entry">
         <xsl:with-param name="ParamDefaultSection" select="$ParamEntry/@*" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamFilesDocument" select="$ParamFilesDocument" />
         <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
         <xsl:with-param name="ParamIndexMarker" select="$ParamIndexMarker" />
         <xsl:with-param name="ParamEntry" select="." />
        </xsl:call-template>
       </xsl:for-each>
      </xsl:when>

      <xsl:when test="$ParamIndexMarker/@link != 'none'">
       <!-- Emit link -->
       <!--           -->
       <xsl:for-each select="$ParamLinks[1]">
        <xsl:variable name="VarParagraphLink" select="key('wwlinks-paragraphs-by-id', $ParamParagraphID)[../@documentID = $ParamFilesDocument/@documentID]" />

        <!-- Get link info -->
        <!--               -->
        <xsl:variable name="VarPath">
         <xsl:for-each select="$VarParagraphLink[1]">
          <xsl:value-of select="$VarParagraphLink/../@path" />
         </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="VarLinkID">
         <xsl:for-each select="$VarParagraphLink[1]">
          <xsl:value-of select="$VarParagraphLink/@linkid" />
         </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="VarFilePosition">
         <xsl:for-each select="$VarParagraphLink[1]">
          <xsl:value-of select="$VarParagraphLink/../@fileposition" />
         </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="VarFirst">
         <xsl:for-each select="$VarParagraphLink[1]">
          <xsl:value-of select="$VarParagraphLink/@first" />
         </xsl:for-each>
        </xsl:variable>

        <wwindex:Link>
         <xsl:if test="string-length($VarPath) &gt; 0">
          <xsl:attribute name="href">
           <xsl:value-of select="$VarPath" />
          </xsl:attribute>
         </xsl:if>
         <xsl:if test="string-length($VarLinkID) &gt; 0">
          <xsl:attribute name="anchor">
           <xsl:value-of select="$VarLinkID" />
          </xsl:attribute>
         </xsl:if>
         <xsl:if test="string-length($VarFilePosition) &gt; 0">
          <xsl:attribute name="fileposition">
           <xsl:value-of select="$VarFilePosition" />
          </xsl:attribute>
         </xsl:if>
         <xsl:if test="string-length($VarFirst) &gt; 0">
          <xsl:attribute name="first">
           <xsl:value-of select="$VarFirst" />
          </xsl:attribute>
         </xsl:if>

         <xsl:for-each select="$ParamEntry/wwdoc:Link/*">
          <xsl:copy-of select="." />
         </xsl:for-each>
        </wwindex:Link>
       </xsl:for-each>
      </xsl:when>
     </xsl:choose>
    </wwindex:Entry>
   </xsl:when>

   <!-- Process child entries -->
   <!--                       -->
   <xsl:otherwise>
    <xsl:if test="count($ParamEntry/wwdoc:Entry[1]) = 1">
     <!-- Process child entries -->
     <!--                       -->
     <xsl:for-each select="$ParamEntry/wwdoc:Entry">
      <xsl:call-template name="Entry">
       <xsl:with-param name="ParamDefaultSection" select="$ParamEntry/@*" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamFilesDocument" select="$ParamFilesDocument" />
       <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
       <xsl:with-param name="ParamIndexMarker" select="$ParamIndexMarker" />
       <xsl:with-param name="ParamEntry" select="." />
      </xsl:call-template>
     </xsl:for-each>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
