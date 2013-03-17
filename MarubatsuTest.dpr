program MarubatsuTest;

{$APPTYPE CONSOLE}

uses
  Nullpobug.UnitTest in '.\Nullpobug.UnitTest.pas'
  , Nullpobug.Marubatsu in '.\Nullpobug.Marubatsu.pas'
  , Nullpobug.MarubatsuTest in '.\Nullpobug.MarubatsuTest.pas'
  , Nullpobug.Marubatsu.CPU in '.\Nullpobug.Marubatsu.CPU.pas'
  ;

begin
  Nullpobug.UnitTest.RunTest('MarubatsuTest.xml');
end.
