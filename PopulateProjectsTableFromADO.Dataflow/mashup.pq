[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Query_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "ProjectName", DestinationColumnName = "ProjectName"], [SourceColumnName = "ProjectSK", DestinationColumnName = "ProjectSK"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared Query = let
  ProjectsSource = OData.Feed("https://analytics.dev.azure.com/"&Organization&"/_odata/v4.0-preview/Projects?$select=ProjectSK,ProjectName", null, [Implementation="2.0",OmitValues = ODataOmitValues.Nulls,ODataVersion = 4])
in
  ProjectsSource;
[Description = "ADO Organization"]
shared Organization = "DevUtopia" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
shared Query_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "36a59297-f3e9-471c-b564-ac15bf815938"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "630ac908-f597-443a-9d83-6aed868f27f7"]}[Data],
  TableNavigation = Navigation_2{[Schema = "dbo", Item = "ProjectTracking"]}[Data]
in
  TableNavigation;
