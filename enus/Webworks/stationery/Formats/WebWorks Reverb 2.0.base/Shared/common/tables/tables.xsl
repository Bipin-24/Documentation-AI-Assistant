<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwnotes="urn:WebWorks-Footnote-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwtableinfo="urn:WebWorks-TableInfo-Script"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc wwtableinfo"
>
 <msxsl:script language="C#" implements-prefix="wwtableinfo">
  <![CDATA[
    System.Collections.Generic.Dictionary<string, int> mIDsToColumns = null;
    XmlNamespaceManager mNamespaceManager = null;

    private XmlNamespaceManager NamespaceManager
    {
      get
      {
        if (this.mNamespaceManager == null)
        {
          this.mNamespaceManager = new XmlNamespaceManager(new NameTable());
          this.mNamespaceManager.AddNamespace("wwdoc", "urn:WebWorks-Document-Schema");
        }

        return this.mNamespaceManager;
      }
    }

    public void Reset()
    {
      this.mIDsToColumns = null;
    }

    private void AddTableCellInfo(System.Collections.Generic.Dictionary<int, System.Collections.Generic.Dictionary<int, bool>> paramLayout,
                                  string paramTableCellID,
                                  int paramRow,
                                  int paramInitialColumn,
                                  int paramRowSpan,
                                  int paramColSpan)
    {
      System.Collections.Generic.Dictionary<int, bool> rowInfo;
      int column;

      // Access row information
      //
      if (paramLayout.ContainsKey(paramRow))
      {
        rowInfo = paramLayout[paramRow];
      }
      else
      {
        rowInfo = new System.Collections.Generic.Dictionary<int, bool>();
        paramLayout[paramRow] = rowInfo;
      }

      // Determine column
      //
      column = paramInitialColumn;
      while (rowInfo.ContainsKey(column))
      {
        column += 1;
      }
      rowInfo[column] = true;
      this.mIDsToColumns[paramTableCellID] = column;

      // Add cell information
      //
      for (int count = 1; count < paramColSpan; count += 1)
      {
        rowInfo[column + count] = true;
      }

      // Add entries for row spans
      //
      if (paramRowSpan > 1)
      {
        this.AddTableCellInfo(
          paramLayout,
          paramTableCellID,
          paramRow + 1,
          column,
          paramRowSpan - 1,
          paramColSpan
        );
      }
    }

    private int GetSpan(XPathNavigator paramTableCell,
                        string paramAttributeName)
    {
      int result = 1;

      try
      {
        string xpathQuery;
        XPathNodeIterator styleAttributeIterator;

        xpathQuery = String.Format(
            "./wwdoc:Style/wwdoc:Attribute[@name = '{0}']", paramAttributeName
        );
        styleAttributeIterator = paramTableCell.Select(xpathQuery, this.NamespaceManager);
        while (styleAttributeIterator.MoveNext())
        {
          string spanAsString;
          spanAsString = styleAttributeIterator.Current.GetAttribute("value", String.Empty);
          if (!String.IsNullOrEmpty(spanAsString))
          {
            int spanAsInt;

            spanAsInt = int.Parse(
                spanAsString,
                System.Globalization.CultureInfo.InvariantCulture.NumberFormat
            );
            result = spanAsInt;
          }
          break;
        }
      }
      catch
      {
        // Ignore
        //
      }

      return result;
    }

    private void ProcessTableCell(System.Collections.Generic.Dictionary<int, System.Collections.Generic.Dictionary<int, bool>> paramLayout,
                                  int paramRow,
                                  int paramInitialColumn,
                                  XPathNavigator paramTableCell)
    {
      string id;
      int rowspan, colspan;

      // Determine table cell ID
      //
      id = paramTableCell.GetAttribute("id", String.Empty);
      if (!String.IsNullOrEmpty(id))
      {
        // Determine rowspan
        //
        rowspan = this.GetSpan(paramTableCell, "row-span");

        // Determine colspan
        //
        colspan = this.GetSpan(paramTableCell, "column-span");

        // Track table cell info
        //
        this.AddTableCellInfo(
          paramLayout, id, paramRow, paramInitialColumn, rowspan, colspan
        );
      }
    }

    public void ProcessTable(XPathNavigator paramTableNavigator)
    {
      System.Collections.Generic.Dictionary<int, System.Collections.Generic.Dictionary<int, bool>> layout;
      int row;
      XPathNodeIterator sectionIterator;

      // Reset info
      //
      this.mIDsToColumns = new System.Collections.Generic.Dictionary<string, int>();

      // Process table sections
      //
      layout = new System.Collections.Generic.Dictionary<int, System.Collections.Generic.Dictionary<int, bool>>();
      row = 0;
      sectionIterator = paramTableNavigator.Select(
        "./wwdoc:TableHead[1] | ./wwdoc:TableBody[1] | ./wwdoc:TableFoot[1]",
        this.NamespaceManager
      );
      while (sectionIterator.MoveNext())
      {
        XPathNavigator sectionNavigator;
        XPathNodeIterator rowIterator;

        // Process table rows
        //
        sectionNavigator = sectionIterator.Current;
        rowIterator = sectionNavigator.Select("./wwdoc:TableRow", this.NamespaceManager);
        while (rowIterator.MoveNext())
        {
          XPathNavigator rowNavigator;
          XPathNodeIterator cellIterator;
          int rowCellCount;

          // Bump row index
          //
          row += 1;

          // Process table row cells
          //
          rowNavigator = rowIterator.Current;
          cellIterator = rowNavigator.Select("./wwdoc:TableCell", this.NamespaceManager);
          rowCellCount = 0;
          while (cellIterator.MoveNext())
          {
            XPathNavigator cellNavigator;

            cellNavigator = cellIterator.Current;
            rowCellCount += 1;
            this.ProcessTableCell(layout, row, rowCellCount, cellNavigator);
          }
        }
      }
    }

    public int LookupTableCellColumn(string paramTableCellID)
    {
      int result = 0;

      if (
          (this.mIDsToColumns != null)
           &&
          (this.mIDsToColumns.ContainsKey(paramTableCellID))
         )
      {
        result = this.mIDsToColumns[paramTableCellID];
      }

      return result;
    }
  ]]>
 </msxsl:script>

 <xsl:template name="Table-CellWidths-Data">
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamReportAllCellWidths" select="false()" />

  <!-- Parse Table Info -->
  <!--                  -->
  <xsl:variable name="VarParseTableInfo" select="wwtableinfo:ProcessTable($ParamTable)" />

  <!-- Select rows -->
  <!--             -->
  <xsl:variable name="VarSectionRows" select="$ParamTable/wwdoc:TableHead[1]/wwdoc:TableRow | $ParamTable/wwdoc:TableBody[1]/wwdoc:TableRow | $ParamTable/wwdoc:TableFoot[1]/wwdoc:TableRow" />

  <!-- Determine maximum row cell count -->
  <!--                                  -->
  <xsl:variable name="VarTableColumnCount">
   <xsl:for-each select="$VarSectionRows[1]">
    <xsl:variable name="VarFirstTableRow" select="." />

    <xsl:call-template name="Table-Row-Column-Count">
     <xsl:with-param name="ParamTableCell" select="$VarFirstTableRow/wwdoc:TableCell[1]" />
     <xsl:with-param name="ParamColumnCount" select="0" />
    </xsl:call-template>
   </xsl:for-each>
  </xsl:variable>

  <!-- Process rows -->
  <!--              -->
  <xsl:choose>
   <!-- Avoid recursion since all rows processed -->
   <!--                                          -->
   <xsl:when test="$ParamReportAllCellWidths">
    <xsl:for-each select="$VarSectionRows">
     <xsl:variable name="VarTableRow" select="." />

     <!-- Determine cell widths -->
     <!--                       -->
     <xsl:call-template name="Table-RecursiveCellWidths">
      <xsl:with-param name="ParamTable" select="$ParamTable" />
      <xsl:with-param name="ParamTableColumnCount" select="$VarTableColumnCount" />
      <xsl:with-param name="ParamTableCell" select="$VarTableRow/wwdoc:TableCell[1]" />
      <xsl:with-param name="ParamRowIndex" select="position()" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:when>

   <!-- Recurse on table rows -->
   <!--                       -->
   <xsl:otherwise>
    <xsl:for-each select="$VarSectionRows[1]">
     <xsl:variable name="VarFirstTableRow" select="." />

     <!-- Determine cell widths -->
     <!--                       -->
     <xsl:call-template name="Table-Row-RecursiveCellWidths">
      <xsl:with-param name="ParamTable" select="$ParamTable" />
      <xsl:with-param name="ParamTableColumnCount" select="$VarTableColumnCount" />
      <xsl:with-param name="ParamTableRow" select="$VarFirstTableRow" />
      <xsl:with-param name="ParamRowIndex" select="1" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Table-Row-Column-Count">
  <xsl:param name="ParamTableCell" />
  <xsl:param name="ParamColumnCount" />

  <!-- Calculate column span -->
  <!--                       -->
  <xsl:variable name="VarColumnSpan">
   <xsl:variable name="VarColumnSpanHint" select="$ParamTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'column-span']/@value" />
   <xsl:choose>
    <xsl:when test="string-length($VarColumnSpanHint) &gt; 0">
     <xsl:value-of select="$VarColumnSpanHint" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="1" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarNextTableCell" select="$ParamTableCell/following-sibling::wwdoc:TableCell[1]" />
  <xsl:choose>
   <!-- More cells in row -->
   <!--                   -->
   <xsl:when test="count($VarNextTableCell) = 1">
    <xsl:call-template name="Table-Row-Column-Count">
     <xsl:with-param name="ParamTableCell" select="$VarNextTableCell" />
     <xsl:with-param name="ParamColumnCount" select="$ParamColumnCount + $VarColumnSpan" />
    </xsl:call-template>
   </xsl:when>

   <!-- End of the row -->
   <!--                -->
   <xsl:otherwise>
    <xsl:value-of select="$ParamColumnCount + $VarColumnSpan" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Table-Row-RecursiveCellWidths">
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamTableColumnCount" />
  <xsl:param name="ParamTableRow" />
  <xsl:param name="ParamRowIndex" />

  <!-- Determine cell widths -->
  <!--                       -->
  <xsl:for-each select="$ParamTableRow/wwdoc:TableCell[1]">
   <xsl:variable name="VarFirstTableRowCell" select="." />

   <xsl:call-template name="Table-RecursiveCellWidths">
    <xsl:with-param name="ParamTable" select="$ParamTable" />
    <xsl:with-param name="ParamTableColumnCount" select="$ParamTableColumnCount" />
    <xsl:with-param name="ParamTableCell" select="$VarFirstTableRowCell" />
    <xsl:with-param name="ParamRowIndex" select="$ParamRowIndex" />
   </xsl:call-template>
  </xsl:for-each>

  <!-- Recurse? -->
  <!--          -->
  <xsl:if test="count($ParamTableRow/wwdoc:TableCell) != $ParamTableColumnCount">
   <xsl:for-each select="$ParamTableRow/following-sibling::wwdoc:TableRow[1] | $ParamTableRow/parent::wwdoc:*/following-sibling::wwdoc:*/wwdoc:TableRow[1]">
    <xsl:variable name="VarNextTableRow" select="." />

    <xsl:call-template name="Table-Row-RecursiveCellWidths">
     <xsl:with-param name="ParamTable" select="$ParamTable" />
     <xsl:with-param name="ParamTableColumnCount" select="$ParamTableColumnCount" />
     <xsl:with-param name="ParamTableRow" select="$VarNextTableRow" />
     <xsl:with-param name="ParamRowIndex" select="$ParamRowIndex + 1" />
    </xsl:call-template>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Table-RecursiveCellWidths">
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamTableColumnCount" />
  <xsl:param name="ParamTableCell" />
  <xsl:param name="ParamRowIndex" />

  <!-- Calculate column span -->
  <!--                       -->
  <xsl:variable name="VarColumnSpan">
   <xsl:variable name="VarColumnSpanHint" select="$ParamTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'column-span']/@value" />
   <xsl:choose>
    <xsl:when test="string-length($VarColumnSpanHint) &gt; 0">
     <xsl:value-of select="$VarColumnSpanHint" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="1" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- End column index -->
  <!--                  -->
  <xsl:variable name="VarTableCellColumnStartIndex" select="wwtableinfo:LookupTableCellColumn($ParamTableCell/@id)" />
  <xsl:variable name="VarTableCellColumnEndIndex" select="$VarTableCellColumnStartIndex + $VarColumnSpan - 1" />

  <!-- Determine width of column span -->
  <!--                                -->
  <xsl:variable name="VarCellWidth">
   <xsl:call-template name="Table-ColumnWidth">
    <xsl:with-param name="ParamTableColumn" select="$ParamTable/wwdoc:TableColumns/wwdoc:TableColumn[1]" />
    <xsl:with-param name="ParamTableColumnIndex" select="1" />
    <xsl:with-param name="ParamAccumulatedWidth" select="'0pt'" />
    <xsl:with-param name="ParamTableColumnStartIndex" select="$VarTableCellColumnStartIndex" />
    <xsl:with-param name="ParamTableColumnEndIndex" select="$VarTableCellColumnEndIndex" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Cell width -->
  <!--            -->
  <wwdoc:TableCellWidth id="{$ParamTableCell/@id}" row="{$ParamRowIndex}" width="{$VarCellWidth}">
   <!-- @column -->
   <!--         -->
   <xsl:if test="$VarColumnSpan = 1">
    <xsl:attribute name="column">
     <xsl:value-of select="$VarTableCellColumnStartIndex" />
    </xsl:attribute>
   </xsl:if>

   <!-- @position -->
   <!--           -->
   <xsl:choose>
    <xsl:when test="($VarTableCellColumnStartIndex = 1) and ($VarColumnSpan = 1)">
     <xsl:attribute name="position">
      <xsl:text>first</xsl:text>
     </xsl:attribute>
    </xsl:when>

    <xsl:when test="($VarTableCellColumnStartIndex = $ParamTableColumnCount) and ($VarColumnSpan = 1)">
     <xsl:attribute name="position">
      <xsl:text>last</xsl:text>
     </xsl:attribute>
    </xsl:when>
   </xsl:choose>
  </wwdoc:TableCellWidth>

  <!-- More cells in row? -->
  <!--                    -->
  <xsl:for-each select="$ParamTableCell/following-sibling::wwdoc:TableCell[1]">
   <xsl:variable name="VarNextTableCell" select="." />

   <xsl:call-template name="Table-RecursiveCellWidths">
    <xsl:with-param name="ParamTable" select="$ParamTable" />
    <xsl:with-param name="ParamTableColumnCount" select="$ParamTableColumnCount" />
    <xsl:with-param name="ParamTableCell" select="$VarNextTableCell" />
    <xsl:with-param name="ParamRowIndex" select="$ParamRowIndex" />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Table-ColumnWidth">
  <xsl:param name="ParamTableColumn" />
  <xsl:param name="ParamTableColumnIndex" />
  <xsl:param name="ParamAccumulatedWidth" />
  <xsl:param name="ParamTableColumnStartIndex" />
  <xsl:param name="ParamTableColumnEndIndex" />

  <!-- Determine new accumulated width -->
  <!--                                 -->
  <xsl:variable name="VarAccumulatedWidth">
   <xsl:choose>
    <!-- Start accumulating widths -->
    <!--                           -->
    <xsl:when test="$ParamTableColumnIndex = $ParamTableColumnStartIndex">
     <!-- Use entry as is -->
     <!--                 -->
     <xsl:value-of select="$ParamTableColumn/@width" />
    </xsl:when>

    <!-- Extend accumulated width -->
    <!--                          -->
    <xsl:when test="($ParamTableColumnIndex &gt;= $ParamTableColumnStartIndex) and ($ParamTableColumnIndex &lt;= $ParamTableColumnEndIndex)">
     <xsl:variable name="VarAccumulatedNumber" select="wwunits:NumericPrefix($ParamAccumulatedWidth)" />
     <xsl:variable name="VarAccumulatedUnits" select="wwunits:UnitsSuffix($ParamAccumulatedWidth)" />
     <xsl:variable name="VarColumnNumber" select="wwunits:NumericPrefix($ParamTableColumn/@width)" />
     <xsl:variable name="VarColumnUnits" select="wwunits:UnitsSuffix($ParamTableColumn/@width)" />

     <xsl:variable name="VarColumnNumberInAccumulatedUnits" select="wwunits:Convert($VarColumnNumber, $VarColumnUnits, $VarAccumulatedUnits)" />

     <!-- Result -->
     <!--        -->
     <xsl:value-of select="$VarAccumulatedNumber + $VarColumnNumberInAccumulatedUnits" />
     <xsl:value-of select="$VarAccumulatedUnits" />
    </xsl:when>

    <!-- Preserve current accumulated width as is -->
    <!--                                          -->
    <xsl:otherwise>
     <xsl:value-of select="$ParamAccumulatedWidth" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit result or keep accumulating column widths -->
  <!--                                                -->
  <xsl:choose>
   <xsl:when test="$ParamTableColumnIndex = $ParamTableColumnEndIndex">
    <xsl:value-of select="$VarAccumulatedWidth" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:call-template name="Table-ColumnWidth">
     <xsl:with-param name="ParamTableColumn" select="$ParamTableColumn/following-sibling::wwdoc:TableColumn[1]" />
     <xsl:with-param name="ParamTableColumnIndex" select="$ParamTableColumnIndex + 1" />
     <xsl:with-param name="ParamAccumulatedWidth" select="$VarAccumulatedWidth" />
     <xsl:with-param name="ParamTableColumnStartIndex" select="$ParamTableColumnStartIndex" />
     <xsl:with-param name="ParamTableColumnEndIndex" select="$ParamTableColumnEndIndex" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Table-CellWidths-FirstLast">
  <xsl:param name="ParamTableCellWidths" />
  <xsl:param name="ParamFirstTableCellWidth" />
  <xsl:param name="ParamLastTableCellWidth" />
  <xsl:param name="ParamEmitFirstLastOnly" />

  <xsl:for-each select="$ParamTableCellWidths">
   <xsl:variable name="VarTableCellWidth" select="." />

   <xsl:choose>
    <xsl:when test="(string-length($ParamFirstTableCellWidth) &gt; 0) and ($VarTableCellWidth/@position = 'first')">
     <xsl:copy>
      <xsl:copy-of select="@*[name() != 'width']" />
      <xsl:attribute name="width">
       <xsl:value-of select="$ParamFirstTableCellWidth" />
      </xsl:attribute>
     </xsl:copy>
    </xsl:when>

    <xsl:when test="(string-length($ParamLastTableCellWidth) &gt; 0) and ($VarTableCellWidth/@position = 'last')">
     <xsl:copy>
      <xsl:copy-of select="@*[name() != 'width']" />
      <xsl:attribute name="width">
       <xsl:value-of select="$ParamLastTableCellWidth" />
      </xsl:attribute>
     </xsl:copy>
    </xsl:when>

    <xsl:otherwise>
     <xsl:if test="$ParamEmitFirstLastOnly = false()">
      <xsl:if test="string-length($VarTableCellWidth/@width) &gt; 0">
       <xsl:copy-of select="$VarTableCellWidth" />
      </xsl:if>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Table-CellWidths">
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamReportAllCellWidths" select="false()" />
  <xsl:param name="ParamFirstTableCellWidth" select="''" />
  <xsl:param name="ParamLastTableCellWidth" select="''" />
  <xsl:param name="ParamEmitFirstLastOnly" select="false()" />

  <!-- Determine cell widths -->
  <!--                       -->
  <xsl:variable name="VarTableCellWidthsAsXML">
   <xsl:call-template name="Table-CellWidths-Data">
    <xsl:with-param name="ParamTable" select="$ParamTable" />
    <xsl:with-param name="ParamReportAllCellWidths" select="$ParamReportAllCellWidths" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarTableCellWidths" select="msxsl:node-set($VarTableCellWidthsAsXML)/wwdoc:TableCellWidth" />

  <!-- Handle first and last table cell widths -->
  <!--                                         -->
  <xsl:call-template name="Table-CellWidths-FirstLast">
   <xsl:with-param name="ParamTableCellWidths" select="$VarTableCellWidths" />
   <xsl:with-param name="ParamFirstTableCellWidth" select="$ParamFirstTableCellWidth" />
   <xsl:with-param name="ParamLastTableCellWidth" select="$ParamLastTableCellWidth" />
   <xsl:with-param name="ParamEmitFirstLastOnly" select="$ParamEmitFirstLastOnly" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Table-CellWidthsAsPercentage">
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamReportAllCellWidths" select="false()" />
  <xsl:param name="ParamFirstTableCellWidth" select="''" />
  <xsl:param name="ParamLastTableCellWidth" select="''" />
  <xsl:param name="ParamEmitFirstLastOnly" select="false()" />

  <!-- Determine cell widths -->
  <!--                       -->
  <xsl:variable name="VarTableCellWidthsAsXML">
   <xsl:call-template name="Table-CellWidths-Data">
    <xsl:with-param name="ParamTable" select="$ParamTable" />
    <xsl:with-param name="ParamReportAllCellWidths" select="$ParamReportAllCellWidths" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarTableCellWidths" select="msxsl:node-set($VarTableCellWidthsAsXML)/wwdoc:TableCellWidth" />

  <!-- Determine table width -->
  <!--                       -->
  <xsl:variable name="VarTableWidth">
   <xsl:choose>
    <xsl:when test="count($VarTableCellWidths[1]) = 1">
     <xsl:variable name="VarUnitsSuffix" select="wwunits:UnitsSuffix($VarTableCellWidths[1]/@width)" />
     <xsl:variable name="VarAccumulationUnits">
      <xsl:choose>
       <xsl:when test="string-length($VarUnitsSuffix) &gt; 0">
        <xsl:value-of select="$VarUnitsSuffix" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>pt</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <xsl:variable name="VarAccumulatedRowWidth">
      <xsl:text>0</xsl:text>
      <xsl:value-of select="$VarAccumulationUnits" />
     </xsl:variable>

     <xsl:call-template name="Table-RowWidth">
      <xsl:with-param name="ParamAccumulatedRowWidth" select="$VarAccumulatedRowWidth" />
      <xsl:with-param name="ParamTableCellWidth" select="$VarTableCellWidths[1]" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>0pt</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Convert to percentage widths -->
  <!--                              -->
  <xsl:variable name="VarTableCellPercentageWidthsAsXML">
   <xsl:apply-templates select="$VarTableCellWidths" mode="wwmode:table-percentage-widths">
    <xsl:with-param name="ParamTableWidth" select="$VarTableWidth" />
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="VarTableCellPercentageWidths" select="msxsl:node-set($VarTableCellPercentageWidthsAsXML)/wwdoc:TableCellWidth" />

  <!-- Handle first and last table cell widths -->
  <!--                                         -->
  <xsl:call-template name="Table-CellWidths-FirstLast">
   <xsl:with-param name="ParamTableCellWidths" select="$VarTableCellPercentageWidths" />
   <xsl:with-param name="ParamFirstTableCellWidth" select="$ParamFirstTableCellWidth" />
   <xsl:with-param name="ParamLastTableCellWidth" select="$ParamLastTableCellWidth" />
   <xsl:with-param name="ParamEmitFirstLastOnly" select="$ParamEmitFirstLastOnly" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Table-RowWidth">
  <xsl:param name="ParamAccumulatedRowWidth" />
  <xsl:param name="ParamTableCellWidth" />

  <!-- Updated accumulated row width -->
  <!--                               -->
  <xsl:variable name="VarAccumulatedRowWidthNumber" select="wwunits:NumericPrefix($ParamAccumulatedRowWidth)" />
  <xsl:variable name="VarAccumulatedRowWidthUnits" select="wwunits:UnitsSuffix($ParamAccumulatedRowWidth)" />
  <xsl:variable name="VarTableCellWidthNumber" select="wwunits:NumericPrefix($ParamTableCellWidth/@width)" />
  <xsl:variable name="VarTableCellWidthUnits" select="wwunits:UnitsSuffix($ParamTableCellWidth/@width)" />
  <xsl:variable name="VarTableCellWidthNumberInAccumulatedUnits" select="wwunits:Convert($VarTableCellWidthNumber, $VarTableCellWidthUnits, $VarAccumulatedRowWidthUnits)" />
  <xsl:variable name="VarAccumulatedRowWidth">
   <xsl:value-of select="$VarAccumulatedRowWidthNumber + $VarTableCellWidthNumberInAccumulatedUnits" />
   <xsl:value-of select="$VarAccumulatedRowWidthUnits" />
  </xsl:variable>

  <!-- Locate next table cell width -->
  <!--                              -->
  <xsl:variable name="VarNextTableCellWidth" select="$ParamTableCellWidth/following-sibling::wwdoc:TableCellWidth[1]" />
  <xsl:choose>
   <!-- Check for row change -->
   <!--                      -->
   <xsl:when test="count($VarNextTableCellWidth) = 1">
    <!-- Same row? -->
    <!--           -->
    <xsl:choose>
     <!-- Same Row -->
     <!--          -->
     <xsl:when test="$VarNextTableCellWidth/@row = $ParamTableCellWidth/@row">
      <!-- Accumulate next cell width -->
      <!--                            -->
      <xsl:call-template name="Table-RowWidth">
       <xsl:with-param name="ParamAccumulatedRowWidth" select="$VarAccumulatedRowWidth" />
       <xsl:with-param name="ParamTableCellWidth" select="$VarNextTableCellWidth" />
      </xsl:call-template>
     </xsl:when>

     <!-- Row changed -->
     <!--             -->
     <xsl:otherwise>
      <!-- Return result -->
      <!--               -->
      <xsl:value-of select="$VarAccumulatedRowWidth" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <!-- Row complete, out of table widths -->
   <!--                                   -->
   <xsl:otherwise>
    <xsl:value-of select="$VarAccumulatedRowWidth" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- wwmode:table-percentage-widths -->
 <!--                                -->

 <xsl:template match="/" mode="wwmode:table-percentage-widths">
  <xsl:param name="ParamTableWidth" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <xsl:template match="*" mode="wwmode:table-percentage-widths">
  <xsl:param name="ParamTableWidth" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <xsl:template match="wwdoc:TableCellWidth" mode="wwmode:table-percentage-widths">
  <xsl:param name="ParamTableWidth" />
  <xsl:param name="ParamTableCellWidth" select="." />

  <!-- Convert widths to standard units -->
  <!--                                  -->
  <xsl:variable name="VarTableWidthNumber" select="wwunits:NumericPrefix($ParamTableWidth)" />
  <xsl:variable name="VarTableWidthUnits" select="wwunits:UnitsSuffix($ParamTableWidth)" />
  <xsl:variable name="VarTableCellWidthNumber" select="wwunits:NumericPrefix($ParamTableCellWidth/@width)" />
  <xsl:variable name="VarTableCellWidthUnits" select="wwunits:UnitsSuffix($ParamTableCellWidth/@width)" />
  <xsl:variable name="VarTableCellWidthNumberInTableWidthUnits" select="wwunits:Convert($VarTableCellWidthNumber, $VarTableCellWidthUnits, $VarTableWidthUnits)" />

  <!-- Convert to percentage width -->
  <!--                             -->
  <xsl:variable name="VarTableCellWidthAsPercentage" select="floor(($VarTableCellWidthNumberInTableWidthUnits div $VarTableWidthNumber) * 1000) div 10" />

  <!-- Emit table cell width entry -->
  <!--                             -->
  <wwdoc:TableCellWidth>
   <xsl:copy-of select="$ParamTableCellWidth/@*[name() != 'width']" />
   <xsl:attribute name="width">
    <xsl:value-of select="$VarTableCellWidthAsPercentage" />
    <xsl:text>%</xsl:text>
   </xsl:attribute>
  </wwdoc:TableCellWidth>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:table-percentage-widths">
  <xsl:param name="ParamTableWidth" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>
</xsl:stylesheet>
