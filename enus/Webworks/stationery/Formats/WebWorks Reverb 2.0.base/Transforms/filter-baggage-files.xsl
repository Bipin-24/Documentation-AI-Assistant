<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Baggage-Unique-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
                              xmlns:wwfilteredbaggage="urn:WebWorks-Filtered-Baggage-Schema"
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
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwbaggagelist="urn:WebWorks-Baggage-List-Schema"
                              xmlns:wwfilter="urn:WebWorks-XSLT-Extension-Filter"
                              exclude-result-prefixes="html xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwbaggage wwfilteredbaggage wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwbaggagelist wwfilter"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterBaggageType" /><!--baggage:group-->
 <xsl:param name="ParameterType" /><!--baggage:filter-->
 <xsl:param name="ParameterInternalType" /><!--internal-->
 <xsl:param name="ParameterExternalType" /><!--external-->
 <xsl:param name="ParameterUILocaleType" /><!--uilocale:project-->

 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwbaggagelist-files-by-path" match="wwbaggagelist:File" use="@noindex" />

 <!-- Baggage Settings -->
 <!--                  -->
 <xsl:variable name="GlobalBaggageFilesListValue" select="wwprojext:GetFormatSetting('baggage-files-list')" />
 <xsl:variable name="VarUseFirstFileFolder" select="starts-with($GlobalBaggageFilesListValue, '$FirstDocDir;')" />
 <xsl:variable name="GlobalBaggageFilesListPath">
  <xsl:choose>
   <xsl:when test="$VarUseFirstFileFolder = 'true'">
    <!-- Search the baggage info list next to the first document -->
    <!--                                                         -->
    <xsl:variable name="VarFirstFile">
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:value-of select="key('wwfiles-files-by-type', 'engine:conversion')[1]/wwfiles:Depends/@path" />
     </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="VarFirstFileFolder" select="wwfilesystem:GetDirectoryName($VarFirstFile)"/>
    <!-- Substituting the variable $FirstDocDir; in the Target Settings for the First Document Folder path -->
    <!--                                                                                                   -->
    <xsl:value-of select="wwstring:ReplaceWithExpressionForCount($GlobalBaggageFilesListValue, '\$FirstDocDir;', $VarFirstFileFolder, 1)"/>
   </xsl:when>
   <xsl:when test="$GlobalBaggageFilesListValue = wwfilesystem:GetBaseName($GlobalBaggageFilesListValue)">
    <!-- Search for the override in the Targets or Formats Folder -->
    <!--                                                          -->
    <xsl:value-of select="wwuri:AsFilePath(concat('wwformat:Transforms/', $GlobalBaggageFilesListValue))"/>
   </xsl:when>
   <xsl:otherwise>
    <!-- Try to get the Absolute or Relative Path to the project -->
    <!--                                                         -->
    <xsl:value-of select="wwfilesystem:GetAbsoluteFrom($GlobalBaggageFilesListValue, concat(wwprojext:GetProjectDirectoryPath(), '\\'))" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="GlobalIndexExternalBaggageFiles" select="wwprojext:GetFormatSetting('index-external-baggage-files')" />
 <xsl:variable name="GlobalIndexBaggageFiles" select="wwprojext:GetFormatSetting('index-baggage-files')" />
 <xsl:variable name="GlobalCopyBaggageFileDependents" select="wwprojext:GetFormatSetting('copy-baggage-file-dependents')" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($GlobalBaggageFilesListPath), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($GlobalBaggageFilesListPath)))" />
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
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />


 <xsl:variable name="GlobalBaggageFilesListEntriesTemp">
  <xsl:if test="wwfilesystem:FileExists($GlobalBaggageFilesListPath)">
   <xsl:copy>
    <xsl:copy-of select="wwexsldoc:LoadXMLWithoutResolver($GlobalBaggageFilesListPath)/wwbaggagelist:Files/wwbaggagelist:File"/>
   </xsl:copy>
  </xsl:if>
 </xsl:variable>

 <xsl:variable name="GlobalBaggageFilesListEntries" select="msxsl:node-set($GlobalBaggageFilesListEntriesTemp)/wwbaggagelist:File"/>

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarDefineTypes" select="wwfilter:DefineValueTypes($ParameterInternalType, $ParameterExternalType)"/>
   <xsl:variable name="VarProjectChecksum" select="$GlobalProject/wwproject:Project/@ChangeID"/>

   <xsl:for-each select="$GlobalFiles[1]">

    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterBaggageType)" />
    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <xsl:variable name="VarFilesDocument" select="." />
     <xsl:variable name="VarGroupID" select="$VarFilesDocument/@groupID"/>
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), $VarGroupID, concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $VarProjectChecksum, '', '', $GlobalActionChecksum)" />

     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarInitializeEntries" select="wwfilter:InitializeEntries()"/>

      <xsl:call-template name="CreateEntries">
       <xsl:with-param name="ParamBaggageFilesFile" select="key('wwfiles-files-by-type', $ParameterBaggageType)[@groupID = $VarGroupID][1]"/>
       <xsl:with-param name="ParamDataDirectoryPath" select="wwprojext:GetGroupDataDirectoryPath($VarGroupID)"/>
      </xsl:call-template>

      <!-- Determine Baggage Output Directory Path -->
      <!--                                         -->
      <xsl:variable name="VarGroupName" select="wwprojext:GetGroupName($VarGroupID)" />
      <xsl:variable name="VarReplacedGroupName">
       <xsl:call-template name="ReplaceGroupNameSpacesWith">
        <xsl:with-param name="ParamText" select="$VarGroupName" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarGroupOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />
      <xsl:variable name="VarGroupBaggageOutputDirectoryPath" select="wwfilesystem:Combine($VarGroupOutputDirectoryPath, 'baggage')" />

      <!-- Renaming Output Files -->
      <!--                       -->
      <xsl:call-template name="RenamingOutputFiles">
       <xsl:with-param name="ParamFilteredFilePath" select="$VarPath"/>
       <xsl:with-param name="ParamGroupBaggageOutputDirectoryPath" select="$VarGroupBaggageOutputDirectoryPath"/>
      </xsl:call-template>
     </xsl:if>

     <!-- Report this File -->
     <!--                  -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$VarProjectChecksum}" groupID="{$VarGroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="" use="">
     </wwfiles:File>

     <!-- Add the downloaded files to files.info -->
     <!--                                        -->
     <xsl:for-each select="wwexsldoc:LoadXMLWithoutResolver($VarPath)/wwfilteredbaggage:Baggage/wwfilteredbaggage:File[@type = $ParameterExternalType]">
      <wwfiles:File type="{$ParameterExternalType}" path="{@source}"/>
     </xsl:for-each>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>

 </xsl:template>


 <!-- Add Baggage List file entries not already indexed by being linked to in source files -->
 <!--                                                                                      -->
 <xsl:template match="wwbaggagelist:File">
  <xsl:param name="ParamDataDirectoryPath"/>

  <xsl:variable name="isUrl" select="(starts-with(@path, 'http:') or starts-with(@path, 'https:'))"/>

  <xsl:if test="(string-length(@path) &gt; 0) and not(@noindex = 'true')">
   <xsl:choose>
    <xsl:when test="$isUrl and ($GlobalIndexExternalBaggageFiles = 'true')">
     <!--$isUrl and we want to index it-->
     <xsl:if test="wwfilter:ContainsUrl(@path) = 'false'">
      <!-- Download the URL from the baggage_list -->
      <!--                                        -->
      <xsl:variable name="VarLogDownloading" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogDownloading']/@value, @path)"/>
      <xsl:variable name="LogDownloading" select="wwlog:Message($VarLogDownloading)"/>
      <xsl:variable name="VarDownloadeBaggageFilePath" select="wwfilter:DownloadExternalBaggageFile(@path, $ParamDataDirectoryPath, $GlobalInvalidPathCharactersExpression)"/>
      <xsl:choose>
       <xsl:when test="$VarDownloadeBaggageFilePath = ''">
        <!-- Download failed -->
        <!--                 -->
        <xsl:variable name="VarWarningDescription" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogMissingURLBaggageFilesInBaggageList']/@value, @path, $GlobalBaggageFilesListPath)"/>
        <xsl:variable name="MissingBaggageFile" select="wwlog:Warning($VarWarningDescription)"/>
       </xsl:when>
       <xsl:otherwise>
        <xsl:variable name="VarBaggageFileExternalEntry" select="wwfilter:AddExternalEntry($VarDownloadeBaggageFilePath, wwstring:ToLower($VarDownloadeBaggageFilePath), @path, wwstring:ToLower(@path))"/>
        <xsl:variable name="VarAddTitleBaggageFile" select="wwfilter:AddTitleAndSummary(wwstring:ToLower($VarDownloadeBaggageFilePath), @title, @summary)"/>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:if>
    </xsl:when>
    <xsl:when test="not($isUrl) and $GlobalIndexBaggageFiles = 'true'">
     <!--not($isUrl) and we want to index it-->
     <!-- Calculating the absolute path -->
     <!--                               -->
     <xsl:variable name="VarAbsPath" select="wwfilesystem:GetAbsoluteFrom(@path, $GlobalBaggageFilesListPath)"/>
     <xsl:if test="wwfilter:ContainsKey($VarAbsPath) = 'false'">
      <xsl:choose>
       <xsl:when test="not(wwfilesystem:FileExists($VarAbsPath))">
        <!-- File doesn't exist -->
        <!--                    -->
        <xsl:variable name="VarWarningDescription" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogMissingBaggageFilesInBaggageList']/@value, @path, $GlobalBaggageFilesListPath)"/>
        <xsl:variable name="MissingBaggageFile" select="wwlog:Warning($VarWarningDescription)"/>
       </xsl:when>
       <xsl:otherwise>
        <xsl:variable name="VarBaggageFileInternalEntry" select="wwfilter:AddInternalEntry($VarAbsPath, wwstring:ToLower($VarAbsPath), $GlobalIndexBaggageFiles)"/>
        <xsl:variable name="VarAddTitleBaggageFile" select="wwfilter:AddTitleAndSummary(wwstring:ToLower($VarAbsPath), @title, @summary)"/>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:if>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <xsl:template name="AddNewEntriesFromBaggageList">
  <xsl:param name="ParamDataDirectoryPath"/>

  <xsl:if test="count($GlobalBaggageFilesListEntries) > 0">
   <xsl:apply-templates select="$GlobalBaggageFilesListEntries">
    <xsl:with-param name="ParamDataDirectoryPath" select="$ParamDataDirectoryPath"/>
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template name="CreateEntries">
  <xsl:param name="ParamBaggageFilesFile"/>
  <xsl:param name="ParamDataDirectoryPath"/>

  <xsl:variable name="VarBaggageFiles" select="wwexsldoc:LoadXMLWithoutResolver($ParamBaggageFilesFile/@path)/wwbaggage:Baggage/wwbaggage:File" />
  <xsl:value-of select="wwprogress:Start(count($VarBaggageFiles))" />

  <xsl:for-each select="$VarBaggageFiles">
   <xsl:value-of select="wwprogress:Start(1)" />
   <xsl:variable name="VarBaggageFile" select="."/>
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:choose>
     <xsl:when test="$VarBaggageFile/@type=$ParameterInternalType">
      <xsl:variable name="BaggageListEntry" select="$GlobalBaggageFilesListEntries[wwfilesystem:GetAbsoluteFrom(@path, $GlobalBaggageFilesListPath)=$VarBaggageFile/@path][1]"/>
      <!-- Checks if the entry is in the BaggageList and its attribute @noindex!=TRUE -->
      <!--                                                                            -->
      <xsl:variable name="indexMe">
       <xsl:choose>
        <xsl:when test="$GlobalIndexBaggageFiles = 'false'">
         <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:when test="$BaggageListEntry and ($BaggageListEntry/@noindex='true')">
         <!-- If the file is present in the baggage list and has the property of no indexing to 'true' -->
         <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:otherwise>
         <!-- If the file isn't present in the baggage list or it is but doesn't have the @noindex property -->
         <xsl:value-of select="true()"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <xsl:if test="wwfilter:ContainsKey($VarBaggageFile/@path) = 'false'">
       <xsl:variable name="VarBaggageFileInternalEntry" select="wwfilter:AddInternalEntry($VarBaggageFile/@path, $VarBaggageFile/@pathtolower, $indexMe)"/>
       <xsl:variable name="VarAddTitleBaggageFile" select="wwfilter:AddTitleAndSummary($VarBaggageFile/@pathtolower, $BaggageListEntry/@title, $BaggageListEntry/@summary)"/>
      </xsl:if>
     </xsl:when>
     <xsl:otherwise>
      <xsl:variable name="BaggageListEntry" select="$GlobalBaggageFilesListEntries[@path=$VarBaggageFile/@path][1]"/>
      <xsl:if test="(not($BaggageListEntry) or not($BaggageListEntry/@noindex='true')) and wwfilter:ContainsUrl($VarBaggageFile/@path) = 'false'">
       <xsl:variable name="VarLogDownloading" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogDownloading']/@value, $VarBaggageFile/@path)"/>
       <xsl:variable name="LogDownloading" select="wwlog:Message($VarLogDownloading)"/>
       <xsl:variable name="VarBaggageFileDownloadedURL" select="wwfilter:DownloadExternalBaggageFile($VarBaggageFile/@path, $ParamDataDirectoryPath, $GlobalInvalidPathCharactersExpression)"/>
       <xsl:if test="not($VarBaggageFileDownloadedURL = '')">
        <xsl:variable name="VarBaggageFileExternalEntry" select="wwfilter:AddExternalEntry($VarBaggageFileDownloadedURL, wwstring:ToLower($VarBaggageFileDownloadedURL), $VarBaggageFile/@path, $VarBaggageFile/@pathtolower)"/>
        <xsl:variable name="VarAddTitleBaggageFile" select="wwfilter:AddTitleAndSummary(wwstring:ToLower($VarBaggageFileDownloadedURL), $BaggageListEntry/@title, $BaggageListEntry/@summary)"/>
       </xsl:if>
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
   <xsl:value-of select="wwprogress:End()" />
  </xsl:for-each>
  <xsl:value-of select="wwprogress:End()" />
 </xsl:template>

 <xsl:template name="RenamingOutputFiles">
  <xsl:param name="ParamFilteredFilePath"/>
  <xsl:param name="ParamGroupBaggageOutputDirectoryPath"/>

  <!-- Renames the output files (if needed) so there's warranty that there are not repeated names -->
  <!--                                                                                            -->
  <xsl:variable name="GettingOutput" select="wwfilter:GettingOutput($ParamGroupBaggageOutputDirectoryPath, $GlobalInvalidPathCharactersExpression)"/>
  <xsl:variable name="VarResultAsXML">
   <wwfilteredbaggage:Baggage version="1.0">
    <xsl:variable name="VarCount" select="wwfilter:GetArray()"/>

    <xsl:call-template name="WriteEntries">
     <xsl:with-param name="ParamCount" select="$VarCount"/>
     <xsl:with-param name="ParamIndex" select="0"/>
    </xsl:call-template>

   </wwfilteredbaggage:Baggage>

  </xsl:variable>
  <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />

  <!-- Write the Generated XML to a file -->
  <!--                                   -->
  <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $ParamFilteredFilePath, 'utf-8', 'xml', '1.0', 'yes')" />

 </xsl:template>

 <xsl:template name="WriteEntries">
  <xsl:param name="ParamCount"/>
  <xsl:param name="ParamIndex"/>

  <xsl:if test="number($ParamIndex) &lt; number($ParamCount)">
   <xsl:variable name="VarGetElement" select="wwfilter:GetElementAt($ParamIndex)"/>
   <xsl:variable name="VarType" select="wwfilter:GetCurrentType()"/>
   <xsl:variable name="VarTitle" select="wwfilter:GetCurrentTitle()"/>
   <xsl:variable name="VarSummary" select="wwfilter:GetCurrentSummary()"/>

   <!-- Creating each entry reading from the Dictionary "FilteredEntries" -->
   <!--                                                                   -->
   <wwfilteredbaggage:File>

    <xsl:attribute name="source">
     <xsl:value-of select="wwfilter:GetCurrentSource()"/>
    </xsl:attribute>
    <xsl:attribute name="sourcetolower">
     <xsl:value-of select="wwfilter:GetCurrentSourceToLower()"/>
    </xsl:attribute>
    <xsl:attribute name="type">
     <xsl:value-of select="$VarType"/>
    </xsl:attribute>
    <xsl:attribute name="index">
     <xsl:value-of select="wwfilter:GetCurrentIndex()"/>
    </xsl:attribute>

    <xsl:if test="string-length($VarTitle) &gt; 0">
     <xsl:attribute name="title">
      <xsl:value-of select="$VarTitle"/>
     </xsl:attribute>
    </xsl:if>
    <xsl:if test="string-length($VarSummary) &gt; 0">
     <xsl:attribute name="summary">
      <xsl:value-of select="$VarSummary"/>
     </xsl:attribute>
    </xsl:if>

    <xsl:choose>
     <xsl:when test="$VarType = $ParameterInternalType">
      <xsl:attribute name="output">
       <xsl:value-of select="wwfilter:GetCurrentOutput()"/>
      </xsl:attribute>
      <xsl:attribute name="outputtolower">
       <xsl:value-of select="wwfilter:GetCurrentOutputToLower()"/>
      </xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="url">
       <xsl:value-of select="wwfilter:GetCurrentUrl()"/>
      </xsl:attribute>
      <xsl:attribute name="urltolower">
       <xsl:value-of select="wwfilter:GetCurrentUrlToLower()"/>
      </xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>

   </wwfilteredbaggage:File>

   <xsl:call-template name="WriteEntries">
    <xsl:with-param name="ParamCount" select="$ParamCount"/>
    <xsl:with-param name="ParamIndex" select="$ParamIndex + 1"/>
   </xsl:call-template>
  </xsl:if>

 </xsl:template>

 <msxsl:script language="c#" implements-prefix="wwfilter">
  <msxsl:using namespace="System" />
  <msxsl:using namespace="System.Collections.Generic" />
  <msxsl:using namespace="System.IO" />
  <msxsl:using namespace="System.Net" />

  <![CDATA[

    // Stores all the baggage files where the KEY is the "sourcetolower"
    //
    private static Dictionary<string, FilteredEntry> _filteredEntries;
    // Stores the string values for the internal and external types
    //
    private static string _internalType, _externalType;

    public static void DefineValueTypes(string internalType, string externalType)
    {
      _internalType = internalType;
      _externalType = externalType;
    }


    // Cleans the dictionary for writing a new file
    //
    public static void InitializeEntries()
    {
      _filteredEntries = new Dictionary<string, FilteredEntry>();
    }

    // Creates a new External Filtered Entry if it doesn't exist, where the KEY is the "sourcetolower"
    //
    public static void AddExternalEntry(string source, string sourcetolower, string url, string urltolower)
    {
      if (!String.IsNullOrEmpty(source) && !String.IsNullOrWhiteSpace(source))
      {
        if (!_filteredEntries.ContainsKey(sourcetolower))
          _filteredEntries.Add(sourcetolower, new ExternalFilteredEntry(source, sourcetolower, url, urltolower));
      }
    }

    // Creates a new Internal Filtered Entry if it doesn't exist, where the KEY is the "sourcetolower"
    //
    public static void AddInternalEntry(string source, string sourcetolower, string index)
    {
      if (!String.IsNullOrEmpty(source) && !String.IsNullOrWhiteSpace(source))
      {
        if (!_filteredEntries.ContainsKey(sourcetolower))
          _filteredEntries.Add(sourcetolower, new InternalFilteredEntry(source, sourcetolower, index));
      }
    }

    // Adds a Title and a Summary to a Baggage File
    //
    public static void AddTitleAndSummary(string key, string title, string summary)
    {
      if (_filteredEntries.ContainsKey(key))
      {
        _filteredEntries[key].Title = title;
        _filteredEntries[key].Summary = summary;
      }
    }

    // Checks if there's an entry with the same path in the files
    //
    public static string Contains(string path, string indexBaggageFiles, string indexExternalLinks)
    {
      if(path.Trim().ToLower().StartsWith("http:") || path.Trim().ToLower().StartsWith("https:")){
        if(indexExternalLinks == "false" || ContainsUrl(path) == "true")
          return "true";
      }
      else if(indexBaggageFiles == "false" || ContainsKey(path) == "true")
        return "true";

      return "false";
    }

    // Checks if there's an ExternalFilteredEntry with the same URL
    //
    public static string ContainsUrl(string url)
    {
      foreach (var x in _filteredEntries.Values)
        if (x.Type == _externalType && ((ExternalFilteredEntry)x).UrlToLower != null &&
            ((ExternalFilteredEntry)x).UrlToLower == url.ToLower())
          return "true";
      return "false";
    }

    // Checks if there's a FilteredEntry with the same KEY
    //
    public static string ContainsKey(string key)
    {
      return _filteredEntries.ContainsKey(key.ToLower()) ? "true" : "false";
    }

    // For every InternalFilteredEntry calculates the Output path avoiding duplicates
    //
    public static void GettingOutput(string baseOutputPath, string invalidPathCharactersExpression)
    {
      foreach (var filteredEntriesValue in _filteredEntries.Values)
      {
        if (filteredEntriesValue.Type == _internalType)
        {
          InternalFilteredEntry current = (InternalFilteredEntry)filteredEntriesValue;
          string currentNameWithoutExt = CleanName(Path.GetFileNameWithoutExtension(current.Source), invalidPathCharactersExpression);
          string currentExt = Path.GetExtension(current.Source);
          string currentName = currentNameWithoutExt + currentExt;

          string currentPath = Path.Combine(baseOutputPath, currentName);
          int index = 1;
          while (RenameOutput(currentPath))
          {
            currentName = currentNameWithoutExt + "_" + index + currentExt;
            currentPath = Path.Combine(baseOutputPath, currentName);
            index++;
          }
          current.Output = currentPath;
          current.OutputToLower = currentPath.ToLower();
        }
      }
    }

    // Cleans the name avoiding Invalid Characters
    //
    private static string CleanName(string name, string invalidPathCharactersExpression)
    {
      string result = name.Replace('#', '_').Replace('\"', '_').Replace('?', '_');
      foreach (char c in invalidPathCharactersExpression)
        result = result.Replace(c, '_');
      return result;
    }

    // Checks if there's another InternalFilteredEntry with the same Output
    //
    private static bool RenameOutput(string currentPath)
    {
      foreach (var x in _filteredEntries.Values)
        if (x.Type == _internalType && ((InternalFilteredEntry)x).OutputToLower != null &&
            ((InternalFilteredEntry)x).OutputToLower == currentPath.ToLower())
          return true;
      return false;
    }

    // Class representing the common properties
    //
    public abstract class FilteredEntry
    {
      public string Source { get; set; }
      public string SourceToLower { get; set; }
      public string Title { get; set; }
      public string Summary { get; set; }
      public string Type { get; set; }
      public string Index { get; set; }

      protected FilteredEntry(string source, string sourcetolower)
      {
        Source = source;
        SourceToLower = sourcetolower;
      }

      protected FilteredEntry(string source, string sourcetolower, string index)
      {
        Source = source;
        SourceToLower = sourcetolower;
        Index = index;
      }
    }

    // Class representing the external baggage files
    //
    public class ExternalFilteredEntry : FilteredEntry
    {
      // In the case of an External one, the SOURCE is going to be the downloaded URL
      public string Url { get; set; }
      public string UrlToLower { get; set; }

      public ExternalFilteredEntry(string source, string sourcetolower, string url, string urltolower) : base(source, sourcetolower, "true")
      {
        Type = _externalType;
        Url = url;
        UrlToLower = urltolower;
      }
    }

    // Class representing the internal baggage files
    //
    public class InternalFilteredEntry : FilteredEntry
    {
      public string Output { get; set; }
      public string OutputToLower { get; set; }

      public InternalFilteredEntry(string source, string sourcetolower, string index) : base(source, sourcetolower, index)
      {
        Type = _internalType;
      }
    }

    // Array for iterating in XSLT
    //
    private static FilteredEntry[] _filteredEntriesArray;
    public static int GetArray()
    {
      _filteredEntriesArray = new FilteredEntry[_filteredEntries.Values.Count];
      _filteredEntries.Values.CopyTo(_filteredEntriesArray, 0);
      return _filteredEntriesArray.Length;
    }

    // FilteredEntry used when iterating the Array in XSLT
    //
    private static FilteredEntry _currentEntry;

    public static void GetElementAt(int position)
    {
      _currentEntry = _filteredEntriesArray[position];
    }

    public static string GetCurrentIndex()
    {
      return _currentEntry.Index;
    }
    public static string GetCurrentType()
    {
      return _currentEntry.Type;
    }
    public static string GetCurrentSource()
    {
      return _currentEntry.Source;
    }
    public static string GetCurrentSourceToLower()
    {
      return _currentEntry.SourceToLower;
    }
    public static string GetCurrentTitle()
    {
      return _currentEntry.Title ?? "";
    }
    public static string GetCurrentSummary()
    {
      return _currentEntry.Summary ?? "";
    }
    public static string GetCurrentUrl()
    {
      return ((ExternalFilteredEntry)_currentEntry).Url;
    }
    public static string GetCurrentUrlToLower()
    {
      return ((ExternalFilteredEntry)_currentEntry).UrlToLower;
    }
    public static string GetCurrentOutput()
    {
      return ((InternalFilteredEntry)_currentEntry).Output;
    }
    public static string GetCurrentOutputToLower()
    {
      return ((InternalFilteredEntry)_currentEntry).OutputToLower;
    }

    // Downloads the URL making sure it doesn't create duplicates
    //
    public static string DownloadExternalBaggageFile(string stringUri, string basePath, string invalidPathCharactersExpression)
    {
      string fullFilePath = "";
      Uri uri = new Uri(stringUri);

      HttpWebRequest request = WebRequest.Create(uri) as HttpWebRequest;
      if (request != null)
      {
        request.Method = WebRequestMethods.Http.Head;
        request.UserAgent = "Mozilla/4.0 (Compatible; Windows NT 5.1; MSIE 6.0) " + "(compatible; MSIE 6.0; Windows NT 5.1; " + ".NET CLR 1.1.4322; .NET CLR 2.0.50727)";
        try
        {
          HttpWebResponse response = request.GetResponse() as HttpWebResponse;

          if (response != null && response.StatusCode == HttpStatusCode.OK)
          {
            string contentType = response.ContentType;
            string pdfContentType = "application/pdf";
            string htmlContentType = "text/html";

            if (contentType.Contains(pdfContentType) || contentType.Contains(htmlContentType))
            {
              string extension = contentType.Contains(pdfContentType) ? ".pdf" : ".html";
              string tempFileName = response.ResponseUri.Segments[response.ResponseUri.Segments.Length - 1];
              if(tempFileName.EndsWith(extension))
                tempFileName = tempFileName.Substring(0, tempFileName.LastIndexOf(extension));
              string baseFileName = CleanName(string.IsNullOrEmpty(tempFileName) || string.IsNullOrWhiteSpace(tempFileName) || tempFileName == "/" ? "index" : tempFileName, invalidPathCharactersExpression);
              fullFilePath = Path.Combine(basePath, baseFileName + extension);

              int index = 0;
              while (_filteredEntries.ContainsKey(fullFilePath.ToLower()))
              {
                fullFilePath = Path.Combine(basePath, baseFileName + "_" + index + extension);
                index++;
              }
              using (WebClient web = new WebClient())
              {
                web.Headers["User-Agent"] = "Mozilla/4.0 (Compatible; Windows NT 5.1; MSIE 6.0) " + "(compatible; MSIE 6.0; Windows NT 5.1; " + ".NET CLR 1.1.4322; .NET CLR 2.0.50727)";
                web.Proxy = WebRequest.DefaultWebProxy;
                web.DownloadFile(uri, fullFilePath);
              }
            }
          }
          if (response != null)
            response.Close();
        }
        catch (Exception)
        {
          // ignored
        }
      }
      return fullFilePath;
    }

   ]]>

 </msxsl:script>

</xsl:stylesheet>
