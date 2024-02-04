(* ::Package:: *)

(* ::Chapter:: *)
(*CSocketListener*)


(* ::Section:: *)
(*Begin package*)


BeginPackage["KirillBelov`CSockets`"]; 


(* ::Section:: *)
(*Names*)


CSocketObject::usage = 
"CSocketObject[socketId] socket representation."; 


CSocketOpen::usage = 
"CSocketOpen[port] returns new server socket."; 


CSocketConnect::usage = 
"CSocketConnect[host, port] connect to socket."; 


CSocketListener::usage = 
"CSocketListener[assoc] listener object."; 


(* ::Section:: *)
(*Private context*)


Begin["`Private`"]; 


(* ::Section:: *)
(*Implementation*)


CSocketObject[socketId_Integer]["DestinationPort"] := 
socketPort[socketId]; 


CSocketOpen[host_String: "localhost", port_Integer] := 
CSocketObject[socketOpen[host, ToString[port]]]; 


CSocketOpen[address_String ] /; 
StringMatchQ[address, __ ~~ ":" ~~ NumberString] := 
CSocketObject[Apply[socketOpen, Join[StringSplit[address, ":"], {}] ] ]; 



CSocketConnect[host_String: "localhost", port_Integer] := 
CSocketObject[socketConnect[host, ToString[port]]]; 


CSocketConnect[address_String] /; 
StringMatchQ[address, __ ~~ ":" ~~ NumberString] := 
CSocketObject[Apply[socketConnect, StringSplit[address, ":"]]]; 


CSocketObject /: BinaryWrite[CSocketObject[socketId_Integer], data_ByteArray] := 
socketBinaryWrite[socketId, data, Length[data], $bufferSize]; 


CSocketObject /: BinaryWrite[CSocketObject[socketId_Integer], data_List] := 
socketBinaryWrite[socketId, ByteArray[data], Length[data], $bufferSize];


CSocketObject /: WriteString[CSocketObject[socketId_Integer], data_String] := 
socketWriteString[socketId, data, StringLength[data], $bufferSize]; 


CSocketObject /: SocketReadMessage[CSocketObject[socketId_Integer], bufferSize_Integer: $bufferSize] := 
socketReadMessage[socketId, bufferSize]; 


CSocketObject /: SocketReadyQ[CSocketObject[socketId_Integer]] := 
socketReadyQ[socketId]; 


CSocketObject /: Close[CSocketObject[socketId_Integer]] := 
socketClose[socketId]; 


CSocketObject /: SocketListen[socket: CSocketObject[socketId_Integer], handler_, OptionsPattern[{SocketListen, "BufferSize" -> $bufferSize, "SocketEventsHandler" -> Print}]] := 
With[{messager = OptionValue["SocketEventsHandler"]},
	Module[{task}, 
		task = Internal`CreateAsynchronousTask[socketListen, {socketId, OptionValue["BufferSize"]}, 
			(With[{p = toPacket[##]}, Echo[p /. {a_Association :> handler[a], b_List :> (messager@@b)}] ] ) &
		]; 
		CSocketListener[<|
			"Socket" -> socket, 
			"Host" -> socket["DestinationHostname"], 
			"Port" -> socket["DestinationPort"], 
			"Handler" -> handler, 
			"TaskId" -> task[[2]], 
			"Task" -> task
		|>]
	]; 
];


CSocketListener /: DeleteObject[CSocketListener[assoc_Association]] := 
socketListenerTaskRemove[assoc["TaskId"]]; 


(* ::Section:: *)
(*Internal*)


$directory = DirectoryName[$InputFileName, 2]; 


$libFile = FileNameJoin[{
	$directory, 
	"LibraryResources", 
	$SystemID, 
	"csockets." <> Internal`DynamicLibraryExtension[]
}]; 


$bufferSize = 8192; 


If[!FileExistsQ[$libFile], 
	Get[FileNameJoin[{$directory, "Scripts", "BuildLibrary.wls"}]]
]; 

toPacket[task_, "Received", {serverId_, clientId_, data_}] :=
	<|
		"Socket" -> CSocketObject[serverId], 
		"SourceSocket" -> CSocketObject[clientId], 
		"DataByteArray" -> ByteArray[data]
	|>

toPacket[task_, "Closed", {serverId_, clientId_}] := {"Closed", CSocketObject[clientId]}





socketOpen = LibraryFunctionLoad[$libFile, "socketOpen", {String, String}, Integer]; 


socketClose = LibraryFunctionLoad[$libFile, "socketClose", {Integer}, Integer]; 


socketListen = LibraryFunctionLoad[$libFile, "socketListen", {Integer, Integer}, Integer]; 


socketListenerTaskRemove = LibraryFunctionLoad[$libFile, "socketListenerTaskRemove", {Integer}, Integer]; 


socketConnect = LibraryFunctionLoad[$libFile, "socketConnect", {String, String}, Integer]; 


socketBinaryWrite = LibraryFunctionLoad[$libFile, "socketBinaryWrite", {Integer, "ByteArray", Integer, Integer}, Integer]; 


socketWriteString = LibraryFunctionLoad[$libFile, "socketWriteString", {Integer, String, Integer, Integer}, Integer]; 


socketReadyQ = LibraryFunctionLoad[$libFile, "socketReadyQ", {Integer}, True | False]; 


socketReadMessage = LibraryFunctionLoad[$libFile, "socketReadMessage", {Integer, Integer}, "ByteArray"]; 


socketPort = LibraryFunctionLoad[$libFile, "socketPort", {Integer}, Integer]; 


(* ::Section:: *)
(*End private context*)


End[]; 


(* ::Section:: *)
(*End package*)


EndPackage[]; 
