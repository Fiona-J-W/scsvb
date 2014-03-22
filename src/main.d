#!/usr/bin/rdmd

import std.algorithm, std.array, std.conv, std.csv, std.datetime, 
	std.file, std.getopt, std.stdio, std.string, std.typecons;

void printHelp(string name){
	writeln(
		"Usage: ", name, " [options]\n\n",
		"Options:\n",
		"\t-f, --datafile=FILE   set the datafile                (mandatory)\n",
		"\t-o, --output=FILE     set the output                  (default=stdout)\n",
		"\t-s, --start=VALUE     set the initial account balance (default=0)\n",
		"\t    --datefield=NAME  set the name of the datefield   (default=“Valutadatum”)\n",
		"\t    --divfield=NAME   set the name of the divfield    (default=“Betrag”)\n",
		"\t-h, -?, --help        print this help\n"
	);
}

int main(string[] args){
	string csvFileName;
	string outFileName;
	string dateFieldName = "Valutadatum";
	string divFieldName = "Betrag";
	int startVal = 0;
	bool exit = false;
	getopt(args,
		"datafile|f", &csvFileName,
		"output|o", &outFileName,
		"start|s", &startVal,
		"datefield", &dateFieldName,
		"divfield", &divFieldName,
		"help|h|?", delegate(){exit=true; printHelp(args[0]);}
		);
	if(exit){
		return 0;
	}
	
	if(!csvFileName.length){
		printHelp(args[0]);
		return 1;
	}
	auto csvData = csvReader!(string[string])(readText(csvFileName), null, ';');
	File output;
	if(outFileName.length){
		output = File(outFileName,"w");
	}
	else{
		output = stdout;
	}
	int[Date] data;
	foreach(name; [dateFieldName, divFieldName]){
		if(!(name in csvData.front)){
			stderr.writefln("ERROR: Invalid input: There is no coloumn named “%s”", name);
			return 2;
		}
	}
	foreach(record; csvData){
		auto tmp = split(record[dateFieldName], ".");
		if(tmp.length!=3){
			stderr.writefln("Warning: invalid date: “%s”",tmp);
			continue;
		}
		auto tmpDate = Date(2000 + to!int(tmp[2]),to!int(tmp[1]),to!int(tmp[0]));
		data[tmpDate] += to!int( removechars(record[divFieldName],","));
	}
	int money = startVal;
	foreach(date; data.keys.sort.reverse){
		money += data[date];
		output.writeln(date.toISOExtString(), "  ", to!double(money)/100);
	}
	return 0;
}
