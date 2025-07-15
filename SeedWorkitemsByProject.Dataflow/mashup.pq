[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Query_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "WorkItemId", DestinationColumnName = "WorkItemId"], [SourceColumnName = "AnalyticsUpdatedDate", DestinationColumnName = "AnalyticsUpdatedDate"], [SourceColumnName = "Title", DestinationColumnName = "Title"], [SourceColumnName = "WorkItemType", DestinationColumnName = "WorkItemType"], [SourceColumnName = "CreatedDate", DestinationColumnName = "CreatedDate"], [SourceColumnName = "State", DestinationColumnName = "State"], [SourceColumnName = "ClosedDate", DestinationColumnName = "ClosedDate"]}], DynamicSchema = false, UpdateMethod = [Kind = "Append"], TypeSettings = [Kind = "Table"]]]}]
shared Query = let
  ParsedStartDate = if Text.Length(ImportStartDate) > 0 then DateTime.FromText(ImportStartDate) else null,
  ParsedStopDate = if Text.Length(ImportStopDate) > 0 then DateTime.FromText(ImportStopDate) else null,
  BaseFilter = "ProjectSK eq " & ProjectSK,
  FilterWithStartDate = if ParsedStartDate <> null then
    BaseFilter & " and AnalyticsUpdatedDate ge " & DateTime.ToText(ParsedStartDate, "yyyy-MM-ddTHH:mm:ssZ")
  else
    BaseFilter,
  FilterWithStopDate = if ParsedStopDate <> null then
    FilterWithStartDate & " and AnalyticsUpdatedDate le " & DateTime.ToText(ParsedStopDate, "yyyy-MM-ddTHH:mm:ssZ")
  else
    FilterWithStartDate,
  QueryUrl = "https://analytics.dev.azure.com/"&Organization&"/_odata/v4.0-preview/WorkItems?$filter=" & FilterWithStopDate & "&$select=WorkItemId,WorkItemType,Title,CreatedDate,ClosedDate,State,AnalyticsUpdatedDate",
  ProjectsSource = OData.Feed(QueryUrl, null, [Implementation="2.0",OmitValues = ODataOmitValues.Nulls,ODataVersion = 4]),
  #"Changed column type" = Table.TransformColumnTypes(ProjectsSource, {{"AnalyticsUpdatedDate", type datetime}, {"CreatedDate", type datetime}, {"ClosedDate", type datetime}})
in
  #"Changed column type";
shared Organization = "DevUtopia" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = ""];
shared ProjectName = "Starter" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = ""];
shared ProjectSK = "42d5b55c-5403-48dc-8945-05436901c533" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = ""];
shared ImportStartDate = "" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = null];
shared ImportStopDate = "" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = ""];
shared Query_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "36a59297-f3e9-471c-b564-ac15bf815938"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "630ac908-f597-443a-9d83-6aed868f27f7"]}[Data],
  TableNavigation = Navigation_2{[Item = ProjectName, Schema = "dbo"]}?[Data]?
in
  TableNavigation;
