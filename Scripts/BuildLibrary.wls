#!/usr/bin/env wolframscript
(* ::Package:: *)

Get["CCompilerDriver`"]; 

$libraryLinkVersion := $libraryLinkVersion = If[(StringCases[ToString[#], "LibraryVersionInformation"] // Flatten // Length) > 0, 7, #] &@
LibraryVersionInformation[FindLibrary["demo"]]["WolframLibraryVersion"]; 


Block[{$directory, $libSrc, $libDir, $linkerOptions, $liblink = $libraryLinkVersion}, 
	$directory = DirectoryName[If[$InputFileName == "", 
		NotebookFileName[], 
		$InputFileName
	], 2]; 

	$libSrc = File[FileNameJoin[{
		$directory, 
		"Source", 
		If[$OperatingSystem === "Windows", "wsockets.c", "usockets.c"]
	}] ]; 


	$libDir = FileNameJoin[{
		$directory, 
		"LibraryResources", 
		ToString[$liblink],
		$SystemID
	}]; 


	If[!FileExistsQ[$libDir], CreateDirectory[]];

	CreateLibrary[$libSrc, "csockets", 
		"TargetDirectory" -> $libDir, 
		"Debug" -> True, 
		"CompileOptions"->{"-Wl,-rpath,'$ORIGIN'"},
		"Libraries" -> If[$OperatingSystem === "Windows", {"ws2_32"}, If[$OperatingSystem === "MacOSX", {"/opt/homebrew/lib/libuv.a"}, {"/home/kirill/Desktop/CSocketListener/LibraryResources/7/Linux-x86-64/libuv.so"}] ],
		"IncludeDirectories" ->  If[$OperatingSystem === "Windows", {}, If[$OperatingSystem === "MacOSX", {"/opt/homebrew/include"}, {"/home/kirill/Desktop/libuv/include"}] ]
	]
]; 
