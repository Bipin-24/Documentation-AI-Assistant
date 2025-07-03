<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwfilteredbaggage="urn:WebWorks-Filtered-Baggage-Schema"
                              xmlns:wwsearch="urn:WebWorks-XSLT-Extension-Search"
                              xmlns:exsl="http://exslt.org/common"
                              xmlns:wwsearchsettings="urn:WebWorks-Settings-Schema"
                              xmlns:wwwarning="urn:WebWorks-Warning-Schema"
                              exclude-result-prefixes="xsl wwmode wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwprojext wwexsldoc wwfilteredbaggage wwsearch exsl wwsearchsettings wwwarning"
	>

 <xsl:template name="Analize-HTML-And-PDF">
  <xsl:param name="ParamBaggageFile"/>
  <xsl:param name="ParamSearchFilePath"/>
  <xsl:param name="ParamFilesByBaggageXHTMLType"/>
  <xsl:param name="ParamBaggageGroupPath"/>
  <xsl:param name="ParamBaggageFilesCount"/>
  <xsl:param name="ParamGroupID" select="''"/>
  <xsl:param name="ParamDocumentID" select="''"/>

  <xsl:variable name="index">
   <xsl:number value="position()" format="1"/>
  </xsl:variable>

  <xsl:variable name="VarConnectFileName">
   <xsl:call-template name="Connect-File-Path">
    <xsl:with-param name="ParamPath" select="wwfilesystem:GetFileName($ParamBaggageFile/@source)" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarPath" select="$ParamBaggageFile/@output"/>

  <!-- Page URI -->
  <!--          -->
  <xsl:variable name="VarPageURI">
   <xsl:choose>
    <xsl:when test="$ParamBaggageFile/@type = $ParameterExternalType">
     <xsl:value-of select="$ParamBaggageFile/@url"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="wwuri:GetRelativeTo($VarPath, $ParamSearchFilePath)"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Path attribute for the current warning node -->
  <!--                                             -->
  <xsl:variable name="VarWarningPath">
   <xsl:choose>
    <xsl:when test="$ParamBaggageFile/@type = $ParameterExternalType">
     <xsl:value-of select="$ParamBaggageFile/@url"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$ParamBaggageFile/@source"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Name to show in the reports page (short name) -->
  <!--                                               -->
  <xsl:variable name="VarNameToShowInReport">
   <xsl:choose>
    <xsl:when test="$ParamBaggageFile/@type = $ParameterExternalType">
     <xsl:value-of select="$VarWarningPath"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="wwfilesystem:GetFileName($VarWarningPath)"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Search pairs file -->
  <!--                   -->
  <xsl:variable name="VarSearchPairsPath" select="wwfilesystem:Combine($ParamBaggageGroupPath, 'pairs', concat('bpair', $index, '.js'))" />
  <xsl:variable name="VarSearchPairsURI" select="wwuri:GetRelativeTo($VarSearchPairsPath, $ParamSearchFilePath)" />

  <!-- Getting Pre-Defined Title and Summary -->
  <!--                                       -->
  <xsl:variable name="VarTitlePreDefined" select="$ParamBaggageFile/@title"/>
  <xsl:variable name="VarSummaryPreDefined" select="$ParamBaggageFile/@summary"/>

  <!-- Getting the relevance weight for the Title and Summary -->
  <!--                                                        -->
  <xsl:variable name="VarTitleWeight">
   <xsl:variable name="TempW" select="$ScoringPrefs/wwsearchsettings:title/@weight"/>
   <xsl:value-of select="$TempW"/>
   <xsl:if test="not($TempW)">
    <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
   </xsl:if>
  </xsl:variable>

  <xsl:variable name="VarSummaryWeight">
   <xsl:variable name="TempW" select="$ScoringPrefs/wwsearchsettings:meta[@name='summary']/@weight"/>
   <xsl:value-of select="$TempW"/>
   <xsl:if test="not($TempW)">
    <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
   </xsl:if>
  </xsl:variable>

  <!-- CASE it is an HTML file -->
  <!--                         -->
  <xsl:if test="(wwfilesystem:GetExtension($ParamBaggageFile/@source)='.html') or (wwfilesystem:GetExtension($ParamBaggageFile/@source)='.htm') or (wwfilesystem:GetExtension($ParamBaggageFile/@source)='.shtml') or (wwfilesystem:GetExtension($ParamBaggageFile/@source)='.shtm') or (wwfilesystem:GetExtension($ParamBaggageFile/@source)='.xhtml') or (wwfilesystem:GetExtension($ParamBaggageFile/@source)='.xhtm')">
   <!-- Load XHTML Content from temp file -->
   <!--                                   -->
   <xsl:variable name="TempXHTMLFilePath" select="$ParamFilesByBaggageXHTMLType[child::wwfiles:Depends/@path=$ParamBaggageFile/@source][1]/@path" />

   <xsl:variable name="ParamBaggageFileContent" select="wwexsldoc:LoadXHTML($TempXHTMLFilePath)" />

   <!-- Identify page body -->
   <!--                    -->
   <xsl:variable name="VarBodyContent" select="$ParamBaggageFileContent/html:html/html:body" />

   <!-- Identify page title -->
   <!--                     -->

   <xsl:variable name="VarTitleCheck1" select="$ParamBaggageFileContent/html:html/html:head/html:title"/>
   <xsl:variable name="VarTitleCheck2" select="$ParamBaggageFileContent/html:html/html:body/html:title"/><!-- YouTube -->

   <xsl:variable name="VarTitleText">
    <xsl:choose>

     <!-- Use title attribute value specified in Baggage Files List entry. -->
     <xsl:when test="normalize-space($VarTitlePreDefined)">
      <xsl:value-of select="$VarTitlePreDefined"/>
      <xsl:variable name="VarAddWordsFromTitle" select="wwsearch:AddNewWords(normalize-space($VarTitlePreDefined), $VarTitleWeight)" />
     </xsl:when>

     <!-- Use first non-zero length Title element from page. -->
     <xsl:when test="normalize-space($VarTitleCheck1/text())">
      <xsl:value-of select="$VarTitleCheck1/text()"/>
     </xsl:when>
     <xsl:when test="normalize-space($VarTitleCheck2/text())">
      <xsl:value-of select="$VarTitleCheck2/text()"/>
     </xsl:when>

     <!-- Use filename of URL for page. -->
     <xsl:otherwise>
      <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($ParamBaggageFile/@source)"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Log and Report messages -->
   <!--                         -->
   <xsl:if test="normalize-space($VarTitlePreDefined)='' and normalize-space($VarTitleCheck1/text())='' and normalize-space($VarTitleCheck2/text())=''">
    <xsl:variable name="VarWarningDescription" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogBaggageFilesNoTitle']/@value, $VarWarningPath, $VarTitleText)"/>
    <xsl:variable name="NoTitleInHtml" select="wwlog:Message($VarWarningDescription)"/>
    <wwwarning:Warning type="notitle" description="{wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportBaggageFilesNoTitle']/@value, $VarNameToShowInReport)}" path="{$VarWarningPath}" pathtolower="{wwstring:ToLower($VarWarningPath)}"/>
   </xsl:if>

   <!-- Identify meta -->
   <!--               -->
   <xsl:variable name="VarMeta" select="$ParamBaggageFileContent/html:html/*/html:meta[@name='description' or @name='author' or @name='keywords']"/>

   <!-- Summary -->
   <!--         -->
   <xsl:variable name="VarSummaryClassTag" select="$VarBodyContent//*[@class='summary'][1]"/>
   <xsl:variable name="VarSummaryClass">
    <xsl:apply-templates select="$VarSummaryClassTag" mode="wwmode:page-summary"/>
   </xsl:variable>
   <xsl:variable name="VarDescriptionMetaTag" select="$VarMeta[@name='description'][1]/@content"/>
   <xsl:variable name="ParagraphWithText">
    <xsl:variable name="VarFirstParagraphWithText" select="$VarBodyContent//html:p[normalize-space(text())!='']"/>
    <xsl:apply-templates select="$VarFirstParagraphWithText[1]" mode="wwmode:page-summary"/>
   </xsl:variable>

   <xsl:variable name="VarHtmlSummary">
    <xsl:choose>
     <xsl:when test="normalize-space($VarSummaryPreDefined)">
      <!--Get the summary from the baggage_list file-->
      <xsl:value-of select="$VarSummaryPreDefined"/>
      <xsl:variable name="VarAddWordsFromSummary" select="wwsearch:AddNewWords(normalize-space($VarSummaryPreDefined), $VarSummaryWeight)" />
     </xsl:when>
     <xsl:when test="normalize-space($VarDescriptionMetaTag)!=''">
      <!--Get the summary from the meta tag description-->
      <xsl:value-of select="$VarDescriptionMetaTag"/>
     </xsl:when>
     <xsl:when test="normalize-space($VarSummaryClass)">
      <!--Get the summary from the summary class-->
      <xsl:value-of select="normalize-space($VarSummaryClass)"/>
     </xsl:when>
     <xsl:otherwise>
      <!--Get the summary from the first paragraph tag-->
      <xsl:value-of select="$ParagraphWithText"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Log and Report messages -->
   <!--                         -->
   <xsl:if test="normalize-space($VarSummaryPreDefined)='' and normalize-space($VarSummaryClass)='' and normalize-space($VarDescriptionMetaTag)=''">
    <xsl:variable name="VarWarningDescription" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogBaggageFilesNoSummary']/@value, $VarWarningPath, $ParagraphWithText)"/>
    <xsl:variable name="GettingFirstParagraphWithText" select="wwlog:Message($VarWarningDescription)"/>
    <wwwarning:Warning type="nosummary" description="{wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportBaggageFilesNoSummary']/@value, $VarNameToShowInReport)}" path="{$VarWarningPath}" pathtolower="{wwstring:ToLower($VarWarningPath)}"/>
    <xsl:if test="normalize-space($ParagraphWithText)=''">
     <xsl:variable name="VarWarningNoPDescription" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogBaggageFilesNoSummaryNoParagraph']/@value"/>
     <xsl:variable name="EmptyParagraphs" select="wwlog:Message($VarWarningNoPDescription)"/>
    </xsl:if>
   </xsl:if>

   <!-- Include meta tags -->
   <!--                   -->
   <xsl:apply-templates select="$VarMeta" mode="wwmode:page-content"/>

   <xsl:apply-templates select="$VarBodyContent" mode="wwmode:page-content"/>

   <xsl:variable name="VarWords" select="wwsearch:IndexContent($GlobalMinimumWordLength, $GlobalStopWords, $VarPageURI, $VarTitleText, normalize-space($VarHtmlSummary), $VarSearchPairsPath, $VarSearchPairsURI, concat($ParamBaggageFile/@type,'-html'), $ParamGroupID)" />
  </xsl:if>

  <!-- CASE it is a PDF file -->
  <!--                       -->
  <xsl:if test="wwfilesystem:GetExtension($ParamBaggageFile/@source)='.pdf'">
   <xsl:variable name="PdfText" select="wwsearch:ExtractTextFromPdf($ParamBaggageFile/@source)"/>

   <!-- Identify PDF title -->
   <!--                    -->
   <xsl:variable name="VarPdfTitle">
    <xsl:choose>
     <xsl:when test="normalize-space($VarTitlePreDefined)">
      <xsl:value-of select="$VarTitlePreDefined"/>
      <xsl:variable name="VarAddWordsFromTitle" select="wwsearch:AddNewWords(normalize-space($VarTitlePreDefined), $VarTitleWeight)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($ParamBaggageFile/@source)"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Log and Report messages -->
   <!--                         -->
   <xsl:if test="normalize-space($VarTitlePreDefined)=''">
    <xsl:variable name="VarWarningDescription" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogBaggageFilesNoTitle']/@value, $VarWarningPath, $VarPdfTitle)"/>
    <xsl:variable name="NoTitleInPdf" select="wwlog:Message($VarWarningDescription)"/>
    <wwwarning:Warning type="notitle" description="{wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportBaggageFilesNoTitle']/@value, $VarNameToShowInReport)}" path="{$VarWarningPath}" pathtolower="{wwstring:ToLower($VarWarningPath)}"/>
   </xsl:if>

   <!-- Summary -->
   <!--         -->
   <xsl:variable name="SummaryFromText" select="normalize-space(concat(substring($PdfText, 0, $GlobalMaxSummaryLength),'...'))"/>
   <xsl:variable name="VarPdfSummary">
    <xsl:choose>
     <xsl:when test="normalize-space($VarSummaryPreDefined)">
      <xsl:value-of select="$VarSummaryPreDefined"/>
      <xsl:variable name="VarAddWordsFromSummary" select="wwsearch:AddNewWords(normalize-space($VarSummaryPreDefined), $VarSummaryWeight)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$SummaryFromText"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Log and Report messages -->
   <!--                         -->
   <xsl:if test="normalize-space($VarSummaryPreDefined)=''">
    <xsl:variable name="VarWarningDescription" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogBaggageFilesNoSummary']/@value, $VarWarningPath, $SummaryFromText)"/>
    <xsl:variable name="NoSummaryInPdf" select="wwlog:Message($VarWarningDescription)"/>
    <wwwarning:Warning type="nosummary" description="{wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportBaggageFilesNoSummary']/@value, $VarNameToShowInReport)}" path="{$VarWarningPath}" pathtolower="{wwstring:ToLower($VarWarningPath)}"/>
   </xsl:if>

   <xsl:variable name="VarAddWords" select="wwsearch:AddNewWords(normalize-space($PdfText), $DefaultPdfRelevanceForBaggageFiles)" />

   <xsl:variable name="VarWords" select="wwsearch:IndexContent($GlobalMinimumWordLength, $GlobalStopWords, $VarPageURI, $VarPdfTitle, $VarPdfSummary, $VarSearchPairsPath, $VarSearchPairsURI, concat($ParamBaggageFile/@type,'-pdf'), $ParamGroupID)" />
  </xsl:if>

  <wwfiles:File path="{$VarSearchPairsPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSearchPairsPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', $ParamBaggageFilesCount)}" groupID="{$ParamGroupID}" documentID="{$ParamDocumentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
   <wwfiles:Depends path="{$ParamBaggageFile/@source}" checksum="{wwfilesystem:GetChecksum($ParamBaggageFile/@source)}" groupID="{$ParamBaggageFile/@groupID}" documentID="{$ParamBaggageFile/@documentID}" />
  </wwfiles:File>

 </xsl:template>

 <xsl:template match="html:script" mode="wwmode:page-summary">
  <!-- Do nothing -->
  <!--            -->
 </xsl:template>

 <xsl:template match="html:*" mode="wwmode:page-summary">
  <xsl:apply-templates mode="wwmode:page-summary"/>
 </xsl:template>

 <xsl:template match="text()" mode="wwmode:page-summary">
  <xsl:text> </xsl:text>
  <xsl:value-of select="."/>
 </xsl:template>

 <xsl:template match="html:script | html:style | html:svg | html:link" mode="wwmode:page-content">
  <!-- Do nothing -->
 </xsl:template>

 <xsl:template match="html:meta" mode="wwmode:page-content">
  <xsl:variable name="NameAttr" select="@name"/>

  <xsl:if test="(@name='description') or (@name='keywords') or (@name='author')">
   <xsl:variable name="Weight">
    <xsl:variable name="TempW" select="$ScoringPrefs/wwsearchsettings:meta[@name=$NameAttr]/@weight"/>
    <xsl:value-of select="$TempW"/>
    <xsl:if test="not($TempW)">
     <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
    </xsl:if>
   </xsl:variable>

   <xsl:apply-templates select="@content" mode="wwmode:page-content">
    <xsl:with-param name="ParamSearchRelevance" select="$Weight" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="html:img" mode="wwmode:page-content">

  <xsl:variable name="Weight">
   <xsl:variable name="TempW" select="$ScoringPrefs/wwsearchsettings:img/@weight"/>
   <xsl:value-of select="$TempW"/>
   <xsl:if test="not($TempW)">
    <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
   </xsl:if>
  </xsl:variable>

  <xsl:apply-templates select="@alt" mode="wwmode:page-content">
   <xsl:with-param name="ParamSearchRelevance" select="$Weight" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="html:a" mode="wwmode:page-content">

  <xsl:variable name="Weight">
   <xsl:variable name="TempW" select="$ScoringPrefs/wwsearchsettings:a/@weight"/>
   <xsl:value-of select="$TempW"/>
   <xsl:if test="not($TempW)">
    <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
   </xsl:if>
  </xsl:variable>

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSearchRelevance" select="$Weight" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="html:*" mode="wwmode:page-content">
  <xsl:param name="ParamSearchRelevance" select="$DefaultRelevanceForBaggageFiles"/>
  <xsl:variable name="LabelTagLocalName" select="local-name()"/>
  <xsl:variable name="LabelTagLocalNameClassAttr" select="@class"/>
  <xsl:variable name="VarHaveClassInSettings" select="$ScoringPrefs/wwsearchsettings:*[local-name()=$LabelTagLocalName][@class=$LabelTagLocalNameClassAttr]/@weight"/>
  <xsl:variable name="VarWithoutClassInSettings" select="$ScoringPrefs/wwsearchsettings:*[local-name()=$LabelTagLocalName]/@weight"/>

  <xsl:variable name="Weight">
   <xsl:variable name="TempW">
    <xsl:variable name="TagWeight">
     <xsl:choose>
      <xsl:when test="$LabelTagLocalNameClassAttr">
       <xsl:choose>
        <xsl:when test="count($VarHaveClassInSettings)">
         <xsl:value-of select="$VarHaveClassInSettings[1]"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:choose>
          <xsl:when test="count($VarWithoutClassInSettings)">
           <xsl:value-of select="$VarWithoutClassInSettings[1]"/>
          </xsl:when>
          <xsl:otherwise>
           <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
          </xsl:otherwise>
         </xsl:choose>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
       <xsl:choose>
        <xsl:when test="count($VarWithoutClassInSettings)">
         <xsl:value-of select="$VarWithoutClassInSettings[1]"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="$DefaultRelevanceForBaggageFiles"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$TagWeight"/>
   </xsl:variable>
   <xsl:choose>
    <xsl:when test="$ParamSearchRelevance">
     <xsl:choose>
      <xsl:when test="$ParamSearchRelevance &gt; $TempW">
       <xsl:value-of select="$ParamSearchRelevance"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$TempW"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$TempW"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:apply-templates mode="wwmode:page-content">
   <xsl:with-param name="ParamSearchRelevance" select="$Weight" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="text()|@*" mode="wwmode:page-content">
  <xsl:param name="ParamSearchRelevance" select="$DefaultRelevanceForBaggageFiles"/>

  <xsl:if test="normalize-space(.)">
   <xsl:variable name="VarWords" select="wwsearch:AddNewWords(normalize-space(.), $ParamSearchRelevance)" />
  </xsl:if>
 </xsl:template>

</xsl:stylesheet>
